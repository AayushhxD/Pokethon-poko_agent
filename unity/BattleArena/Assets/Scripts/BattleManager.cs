using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using System;
using Newtonsoft.Json;

/// <summary>
/// Main Battle Manager for PokéAgents 3D Battle System
/// Handles deterministic turn-based combat simulation
/// Communicates with Flutter via UnityFlutterBridge
/// </summary>
public class BattleManager : MonoBehaviour
{
    [Header("Battle Configuration")]
    public float turnDuration = 0.5f;
    public float animationDelay = 0.15f;
    public bool debugMode = false;

    [Header("References")]
    public CharacterController playerCharacter;
    public CharacterController opponentCharacter;
    public ParticleSystemManager particleManager;
    public UnityFlutterBridge flutterBridge;

    // Battle State
    private BattleData battleData;
    private AgentData playerAgent;
    private AgentData opponentAgent;
    private List<TurnData> turns = new List<TurnData>();
    private int currentTurnIndex = 0;
    private bool battleActive = false;
    private string seed;
    private bool assetsPrewarmed = false;

    // Deterministic RNG
    private System.Random rng;

    void Start()
    {
        if (flutterBridge == null)
            flutterBridge = FindObjectOfType<UnityFlutterBridge>();

        if (flutterBridge != null)
        {
            SendStatus("unity-boot", "BattleManager awake");
            // Register for Flutter messages
            flutterBridge.OnMessageReceived += HandleFlutterMessage;
        }

        StartCoroutine(PrewarmBattleAssets());
    }

    void OnDestroy()
    {
        if (flutterBridge != null)
            flutterBridge.OnMessageReceived -= HandleFlutterMessage;
    }

    private System.Collections.IEnumerator PrewarmBattleAssets()
    {
        SendStatus("prewarm-start", "Priming characters and VFX");
        yield return null;

        PrewarmCharacters();
        particleManager?.Prewarm();

        yield return null;
        assetsPrewarmed = true;
        SendStatus("prewarm-complete", "Assets ready");
    }

    private void PrewarmCharacters()
    {
        if (playerCharacter != null)
            playerCharacter.Prewarm();
        if (opponentCharacter != null)
            opponentCharacter.Prewarm();
    }

    private void SendStatus(string status, string details = null)
    {
        if (flutterBridge == null) return;

        var payload = new Dictionary<string, object>
        {
            {"type", "status"},
            {"status", status},
            {"timestamp", DateTime.UtcNow.ToString("o")}
        };

        if (!string.IsNullOrEmpty(details))
        {
            payload["details"] = details;
        }

        flutterBridge.SendMessageToFlutter(JsonConvert.SerializeObject(payload));
    }

    /// <summary>
    /// Handle incoming messages from Flutter
    /// </summary>
    private void HandleFlutterMessage(string message)
    {
        try
        {
            var data = JsonConvert.DeserializeObject<Dictionary<string, object>>(message);
            
            if (data.ContainsKey("command"))
            {
                string command = data["command"].ToString();
                
                switch (command)
                {
                    case "InitBattle":
                        InitializeBattle(message);
                        break;
                    case "PauseBattle":
                        PauseBattle();
                        break;
                    case "ResumeBattle":
                        ResumeBattle();
                        break;
                    case "EndBattle":
                        EndBattle();
                        break;
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogError($"Error handling Flutter message: {e.Message}");
        }
    }

    /// <summary>
    /// Initialize battle from Flutter data
    /// </summary>
    public void InitializeBattle(string jsonData)
    {
        try
        {
            battleData = JsonConvert.DeserializeObject<BattleData>(jsonData);
            seed = battleData.seed;
            rng = new System.Random(seed.GetHashCode());

            playerAgent = battleData.playerAgent;
            opponentAgent = battleData.opponentAgent;

            SendStatus("battle-init-received", "Applying battle payload");

            // Setup characters
            if (playerCharacter != null)
                playerCharacter.Initialize(playerAgent);
            if (opponentCharacter != null)
                opponentCharacter.Initialize(opponentAgent);

            if (!assetsPrewarmed)
            {
                PrewarmCharacters();
                particleManager?.Prewarm();
                assetsPrewarmed = true;
            }

            // Generate deterministic battle simulation
            turns = GenerateDeterministicTurns();

            SendStatus("battle-ready", "Simulation prepared");

            // Send battle start event to Flutter immediately
            flutterBridge.SendBattleEvent(new BattleEvent
            {
                eventType = "battleStart",
                data = new Dictionary<string, object>
                {
                    {"battleId", battleData.battleId},
                    {"totalTurns", turns.Count}
                }
            });

            // Start battle immediately
            battleActive = true;
            StartCoroutine(RunBattleSequence());
        }
        catch (Exception e)
        {
            Debug.LogError($"Error initializing battle: {e.Message}");
        }
    }

    /// <summary>
    /// Generate deterministic turn sequence using seeded RNG
    /// Same algorithm as backend simulator.js
    /// </summary>
    private List<TurnData> GenerateDeterministicTurns()
    {
        List<TurnData> battleTurns = new List<TurnData>();
        int playerHp = playerAgent.hp;
        int opponentHp = opponentAgent.hp;
        int turnNumber = 1;
        const int maxTurns = 20;

        // Determine first attacker based on speed
        bool playerFirst = playerAgent.speed >= opponentAgent.speed;
        if (playerAgent.speed == opponentAgent.speed)
            playerFirst = NextRandom() < 0.5;

        while (playerHp > 0 && opponentHp > 0 && turnNumber <= maxTurns)
        {
            bool playerTurn = (turnNumber % 2 == 1) ? playerFirst : !playerFirst;

            if (playerTurn)
            {
                // Player attacks
                var turn = SimulateAttack(
                    playerAgent,
                    opponentAgent,
                    ref opponentHp,
                    turnNumber,
                    true
                );
                battleTurns.Add(turn);
            }
            else
            {
                // Opponent attacks
                var turn = SimulateAttack(
                    opponentAgent,
                    playerAgent,
                    ref playerHp,
                    turnNumber,
                    false
                );
                battleTurns.Add(turn);
            }

            turnNumber++;

            // Check for battle end
            if (playerHp <= 0 || opponentHp <= 0)
                break;
        }

        return battleTurns;
    }

    /// <summary>
    /// Simulate a single attack turn
    /// Deterministic damage formula: max(1, attack - defense/4) * randomFactor
    /// </summary>
    private TurnData SimulateAttack(
        AgentData attacker,
        AgentData defender,
        ref int defenderHp,
        int turnNumber,
        bool isPlayer)
    {
        // Calculate base damage
        float baseDamage = Mathf.Max(1, attacker.attack - defender.defense / 4f);
        
        // Apply random factor (0.85 to 1.0)
        float randomFactor = 0.85f + (float)NextRandom() * 0.15f;
        
        // Calculate final damage
        int damage = Mathf.RoundToInt(baseDamage * randomFactor);
        
        // Apply damage
        defenderHp = Mathf.Max(0, defenderHp - damage);

        // Determine move name
        string moveName = attacker.moves.Count > 0 
            ? attacker.moves[NextRandomInt(0, attacker.moves.Count)]
            : "Basic Attack";

        // Create turn data
        return new TurnData
        {
            turnNumber = turnNumber,
            attackerTokenId = attacker.tokenId,
            defenderTokenId = defender.tokenId,
            moveName = moveName,
            moveType = attacker.elementType,
            damage = damage,
            remainingHp = defenderHp,
            timestamp = DateTime.UtcNow
        };
    }

    /// <summary>
    /// Run battle sequence with animations
    /// </summary>
    private System.Collections.IEnumerator RunBattleSequence()
    {
        foreach (var turn in turns)
        {
            if (!battleActive) yield break;

            currentTurnIndex = turn.turnNumber;
            bool isPlayerAttack = turn.attackerTokenId == playerAgent.tokenId;

            // Get attacker and defender
            var attacker = isPlayerAttack ? playerCharacter : opponentCharacter;
            var defender = isPlayerAttack ? opponentCharacter : playerCharacter;

            // Play attack animation
            if (attacker != null)
                attacker.PlayAttackAnimation(turn.moveName);
            
            // Spawn particles if manager exists
            if (particleManager != null && defender != null)
            {
                Vector3 particlePos = defender.transform.position + Vector3.up * 1.5f;
                particleManager.SpawnParticle(turn.moveType, particlePos);
            }

            yield return new WaitForSeconds(animationDelay);

            // Play hit animation
            if (defender != null)
                defender.PlayHitAnimation();
            
            // Camera shake
            var cameraShake = Camera.main?.GetComponent<CameraShake>();
            if (cameraShake != null)
                cameraShake.Shake(0.12f, turn.damage * 0.008f);

            // Send turn event to Flutter
            flutterBridge.SendBattleEvent(new BattleEvent
            {
                eventType = "turn",
                data = new Dictionary<string, object>
                {
                    {"turn", turn.turnNumber},
                    {"actor", isPlayerAttack ? "player" : "opponent"},
                    {"move", turn.moveName},
                    {"damage", turn.damage},
                    {"hpLeft", turn.remainingHp},
                    {"element", turn.moveType}
                }
            });

            // Check for death
            if (turn.remainingHp <= 0)
            {
                if (defender != null)
                    defender.PlayDeathAnimation();
                yield return new WaitForSeconds(0.4f);
                break;
            }

            // Wait for next turn (reduced for faster gameplay)
            yield return new WaitForSeconds(turnDuration);
        }

        // Battle ended
        yield return new WaitForSeconds(0.25f);
        OnBattleEnd();
    }

    /// <summary>
    /// Handle battle end and send results
    /// </summary>
    private void OnBattleEnd()
    {
        battleActive = false;

        // Determine winner
        var lastTurn = turns.LastOrDefault();
        bool playerWon = lastTurn != null && lastTurn.attackerTokenId == playerAgent.tokenId;
        int winnerTokenId = playerWon ? playerAgent.tokenId : opponentAgent.tokenId;

        // Create battle result
        var result = new BattleResult
        {
            battleId = battleData.battleId,
            winnerTokenId = winnerTokenId,
            turns = turns,
            seed = seed,
            timestamp = DateTime.UtcNow
        };

        // Send to backend for signing
        StartCoroutine(SubmitBattleResult(result));

        // Send battle end event to Flutter
        flutterBridge.SendBattleEvent(new BattleEvent
        {
            eventType = "battleEnd",
            data = new Dictionary<string, object>
            {
                {"winnerTokenId", winnerTokenId},
                {"totalTurns", turns.Count},
                {"playerWon", playerWon}
            }
        });
    }

    /// <summary>
    /// Submit battle result to backend for signing
    /// </summary>
    private System.Collections.IEnumerator SubmitBattleResult(BattleResult result)
    {
        string backendUrl = "https://your-backend.vercel.app/api/battle/simulate";
        string jsonData = JsonConvert.SerializeObject(result);

        using (UnityEngine.Networking.UnityWebRequest www = UnityEngine.Networking.UnityWebRequest.Post(backendUrl, jsonData))
        {
            www.SetRequestHeader("Content-Type", "application/json");
            yield return www.SendWebRequest();

            if (www.result == UnityEngine.Networking.UnityWebRequest.Result.Success)
            {
                string response = www.downloadHandler.text;
                Debug.Log($"Backend response: {response}");
                
                // Send signed result to Flutter
                flutterBridge.SendMessageToFlutter(response);
            }
            else
            {
                Debug.LogError($"Error submitting battle result: {www.error}");
            }
        }
    }

    // Pause/Resume/End controls
    private void PauseBattle() => battleActive = false;
    private void ResumeBattle() => battleActive = true;
    private void EndBattle()
    {
        battleActive = false;
        StopAllCoroutines();
    }

    // Deterministic RNG helpers
    private double NextRandom() => rng.NextDouble();
    private int NextRandomInt(int min, int max) => rng.Next(min, max);
}

// Data Models
[Serializable]
public class BattleData
{
    public int battleId;
    public string seed;
    public AgentData playerAgent;
    public AgentData opponentAgent;
}

[Serializable]
public class AgentData
{
    public int tokenId;
    public string name;
    public int hp;
    public int attack;
    public int defense;
    public int speed;
    public string elementType;
    public List<string> moves;
    public string spriteUrl;
    public bool isPlayer;
}

[Serializable]
public class TurnData
{
    public int turnNumber;
    public int attackerTokenId;
    public int defenderTokenId;
    public string moveName;
    public string moveType;
    public int damage;
    public int remainingHp;
    public DateTime timestamp;
}

[Serializable]
public class BattleResult
{
    public int battleId;
    public int winnerTokenId;
    public List<TurnData> turns;
    public string seed;
    public DateTime timestamp;
}

[Serializable]
public class BattleEvent
{
    public string eventType;
    public Dictionary<string, object> data;
}
