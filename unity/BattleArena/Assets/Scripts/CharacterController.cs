using UnityEngine;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// Character Controller for Battle Agents
/// Manages animations, health, and visual feedback
/// </summary>
public class CharacterController : MonoBehaviour
{
    [Header("Animation")]
    public Animator animator;
    public float animationSpeed = 1.5f;

    [Header("Visual Feedback")]
    public GameObject damageTextPrefab;
    public Transform healthBarTransform;
    public Renderer characterRenderer;

    [Header("Audio")]
    public AudioSource audioSource;
    public AudioClip attackSound;
    public AudioClip hitSound;
    public AudioClip deathSound;

    private AgentData agentData;
    private int currentHp;
    private Material characterMaterial;
    private Color originalColor;
    private bool prewarmed = false;

    // Animation states
    private const string IDLE = "Idle";
    private const string ATTACK = "Attack";
    private const string HIT = "Hit";
    private const string DEATH = "Death";
    private const string SPECIAL = "Special";

    void Awake()
    {
        if (animator == null)
            animator = GetComponent<Animator>();
        
        if (characterRenderer != null)
        {
            characterMaterial = characterRenderer.material;
            originalColor = characterMaterial.color;
        }
    }

    /// <summary>
    /// Initialize character with agent data
    /// </summary>
    public void Initialize(AgentData data)
    {
        agentData = data;
        currentHp = data.hp;
        
        // Set character color based on element type
        if (characterRenderer != null)
        {
            characterMaterial.color = GetElementColor(data.elementType);
        }

        // Play idle animation
        PlayAnimation(IDLE);
        
        Debug.Log($"✅ Character initialized: {data.name} (HP: {data.hp})");
    }

    /// <summary>
    /// Prewarm animations/materials to avoid first-frame hitches
    /// </summary>
    public void Prewarm()
    {
        if (prewarmed)
            return;

        if (!gameObject.activeSelf)
            gameObject.SetActive(true);

        if (animator == null)
            animator = GetComponent<Animator>();

        if (animator != null)
        {
            animator.speed = animationSpeed;
            animator.Play(IDLE, 0, 0f);
            animator.Update(0f);
        }

        if (characterRenderer != null && characterMaterial == null)
        {
            characterMaterial = characterRenderer.material;
            originalColor = characterMaterial.color;
        }

        prewarmed = true;
    }

    /// <summary>
    /// Play attack animation
    /// </summary>
    public void PlayAttackAnimation(string moveName)
    {
        // Determine if special attack based on move name
        bool isSpecial = moveName.ToLower().Contains("special") || 
                        moveName.ToLower().Contains("ultimate");
        
        PlayAnimation(isSpecial ? SPECIAL : ATTACK);
        PlaySound(attackSound);
        
        StartCoroutine(ReturnToIdleAfterDelay(isSpecial ? 0.8f : 0.5f));
    }

    /// <summary>
    /// Play hit animation and show damage
    /// </summary>
    public void PlayHitAnimation()
    {
        PlayAnimation(HIT);
        PlaySound(hitSound);
        FlashRed();
        
        StartCoroutine(ReturnToIdleAfterDelay(0.3f));
    }

    /// <summary>
    /// Play death animation
    /// </summary>
    public void PlayDeathAnimation()
    {
        PlayAnimation(DEATH);
        PlaySound(deathSound);
        StartCoroutine(FadeOut());
    }

    /// <summary>
    /// Take damage and update health
    /// </summary>
    public void TakeDamage(int damage)
    {
        currentHp = Mathf.Max(0, currentHp - damage);
        
        // Spawn damage text
        if (damageTextPrefab != null)
        {
            GameObject damageText = Instantiate(
                damageTextPrefab,
                transform.position + Vector3.up * 2f,
                Quaternion.identity
            );
            damageText.GetComponent<DamageText>()?.Initialize(damage);
        }

        // Update health bar
        UpdateHealthBar();

        // Play hit animation
        PlayHitAnimation();

        // Check for death
        if (currentHp <= 0)
        {
            PlayDeathAnimation();
        }
    }

    private void PlayAnimation(string stateName)
    {
        if (animator != null)
        {
            animator.speed = animationSpeed;
            animator.Play(stateName);
        }
    }

    private void PlaySound(AudioClip clip)
    {
        if (audioSource != null && clip != null)
        {
            audioSource.PlayOneShot(clip);
        }
    }

    private void FlashRed()
    {
        if (characterMaterial != null)
        {
            StartCoroutine(FlashColorRoutine());
        }
    }

    private IEnumerator FlashColorRoutine()
    {
        characterMaterial.color = Color.red;
        yield return new WaitForSeconds(0.1f);
        characterMaterial.color = originalColor;
    }

    private IEnumerator ReturnToIdleAfterDelay(float delay)
    {
        yield return new WaitForSeconds(delay);
        PlayAnimation(IDLE);
    }

    private IEnumerator FadeOut()
    {
        float duration = 0.6f;
        float elapsed = 0f;
        Color startColor = characterMaterial.color;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float alpha = Mathf.Lerp(1f, 0f, elapsed / duration);
            characterMaterial.color = new Color(
                startColor.r,
                startColor.g,
                startColor.b,
                alpha
            );
            yield return null;
        }

        gameObject.SetActive(false);
    }

    private void UpdateHealthBar()
    {
        if (healthBarTransform != null)
        {
            float healthPercent = (float)currentHp / agentData.hp;
            healthBarTransform.localScale = new Vector3(
                healthPercent,
                healthBarTransform.localScale.y,
                healthBarTransform.localScale.z
            );
        }
    }

    private Color GetElementColor(string elementType)
    {
        switch (elementType.ToLower())
        {
            case "fire":
                return new Color(1f, 0.3f, 0.1f); // Red-Orange
            case "water":
                return new Color(0.2f, 0.5f, 1f); // Blue
            case "grass":
                return new Color(0.3f, 0.8f, 0.2f); // Green
            case "electric":
                return new Color(1f, 0.9f, 0.1f); // Yellow
            case "psychic":
                return new Color(0.8f, 0.2f, 0.9f); // Purple
            case "ice":
                return new Color(0.5f, 0.9f, 1f); // Cyan
            default:
                return Color.white;
        }
    }
}

/// <summary>
/// Simple damage text component
/// </summary>
public class DamageText : MonoBehaviour
{
    public float moveSpeed = 3f;
    public float lifetime = 1.0f;
    private TextMesh textMesh;

    void Awake()
    {
        textMesh = GetComponent<TextMesh>();
    }

    public void Initialize(int damage)
    {
        if (textMesh != null)
        {
            textMesh.text = $"-{damage}";
            textMesh.color = Color.red;
        }

        StartCoroutine(FloatAndFade());
    }

    private IEnumerator FloatAndFade()
    {
        float elapsed = 0f;
        Vector3 startPos = transform.position;

        while (elapsed < lifetime)
        {
            elapsed += Time.deltaTime;
            
            // Move up
            transform.position = startPos + Vector3.up * moveSpeed * elapsed;
            
            // Fade out
            if (textMesh != null)
            {
                Color color = textMesh.color;
                color.a = 1f - (elapsed / lifetime);
                textMesh.color = color;
            }

            yield return null;
        }

        Destroy(gameObject);
    }
}
