using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// Particle System Manager for Battle VFX
/// Handles element-based particle effects for attacks
/// </summary>
public class ParticleSystemManager : MonoBehaviour
{
    [Header("Particle Prefabs")]
    public GameObject fireParticlePrefab;
    public GameObject waterParticlePrefab;
    public GameObject grassParticlePrefab;
    public GameObject electricParticlePrefab;
    public GameObject psychicParticlePrefab;
    public GameObject iceParticlePrefab;
    public GameObject normalParticlePrefab;

    [Header("Configuration")]
    public float particleLifetime = 1.2f;
    public bool poolParticles = true;
    private Dictionary<string, Queue<GameObject>> particlePools = new Dictionary<string, Queue<GameObject>>();
    private const int POOL_SIZE = 10;
    private bool poolsInitialized = false;

    void Start()
    {
        EnsurePools();
    }

    private void EnsurePools()
    {
        if (!poolParticles || poolsInitialized)
            return;

        InitializePools();
        poolsInitialized = true;
    }

    /// <summary>
    /// Initialize object pools for each element type
    /// </summary>
    private void InitializePools()
    {
        InitializePool("fire", fireParticlePrefab);
        InitializePool("water", waterParticlePrefab);
        InitializePool("grass", grassParticlePrefab);
        InitializePool("electric", electricParticlePrefab);
        InitializePool("psychic", psychicParticlePrefab);
        InitializePool("ice", iceParticlePrefab);
        InitializePool("normal", normalParticlePrefab);
    }

    private void InitializePool(string elementType, GameObject prefab)
    {
        if (prefab == null) return;

        Queue<GameObject> pool = new Queue<GameObject>();
        
        for (int i = 0; i < POOL_SIZE; i++)
        {
            GameObject obj = Instantiate(prefab, transform);
            obj.SetActive(false);
            pool.Enqueue(obj);
        }

        particlePools[elementType] = pool;
    }

    /// <summary>
    /// Spawn particle effect at position
    /// </summary>
    public void SpawnParticle(string elementType, Vector3 position)
    {
        EnsurePools();

        GameObject prefab = GetPrefabForElement(elementType);
        if (prefab == null)
        {
            Debug.LogWarning($"No particle prefab for element: {elementType}");
            return;
        }

        GameObject particle;

        if (poolParticles && particlePools.ContainsKey(elementType))
        {
            particle = GetPooledParticle(elementType);
        }
        else
        {
            particle = Instantiate(prefab, position, Quaternion.identity);
        }

        particle.transform.position = position;
        particle.SetActive(true);

        // Play particle system
        ParticleSystem ps = particle.GetComponent<ParticleSystem>();
        if (ps != null)
        {
            ps.Play();
        }

        // Return to pool after lifetime
        if (poolParticles)
        {
            StartCoroutine(ReturnToPoolAfterDelay(particle, elementType, particleLifetime));
        }
        else
        {
            Destroy(particle, particleLifetime);
        }
    }

    public void Prewarm()
    {
        EnsurePools();

        if (!poolParticles)
            return;

        foreach (var kvp in particlePools)
        {
            int count = kvp.Value.Count;
            for (int i = 0; i < count; i++)
            {
                var particle = kvp.Value.Dequeue();
                if (particle == null) continue;

                particle.SetActive(true);
                var ps = particle.GetComponent<ParticleSystem>();
                if (ps != null)
                {
                    ps.Simulate(0f, true, true);
                    ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                }
                particle.SetActive(false);
                kvp.Value.Enqueue(particle);
            }
        }
    }

    private GameObject GetPooledParticle(string elementType)
    {
        if (particlePools[elementType].Count > 0)
        {
            return particlePools[elementType].Dequeue();
        }
        else
        {
            // Pool exhausted, create new instance
            GameObject prefab = GetPrefabForElement(elementType);
            return Instantiate(prefab, transform);
        }
    }

    private System.Collections.IEnumerator ReturnToPoolAfterDelay(GameObject particle, string elementType, float delay)
    {
        yield return new WaitForSeconds(delay);
        
        particle.SetActive(false);
        
        if (particlePools.ContainsKey(elementType))
        {
            particlePools[elementType].Enqueue(particle);
        }
    }

    private GameObject GetPrefabForElement(string elementType)
    {
        switch (elementType.ToLower())
        {
            case "fire":
                return fireParticlePrefab;
            case "water":
                return waterParticlePrefab;
            case "grass":
                return grassParticlePrefab;
            case "electric":
                return electricParticlePrefab;
            case "psychic":
                return psychicParticlePrefab;
            case "ice":
                return iceParticlePrefab;
            default:
                return normalParticlePrefab;
        }
    }

    /// <summary>
    /// Clear all active particles
    /// </summary>
    public void ClearAllParticles()
    {
        foreach (var pool in particlePools.Values)
        {
            foreach (var particle in pool)
            {
                if (particle != null && particle.activeSelf)
                {
                    particle.SetActive(false);
                }
            }
        }
    }
}
