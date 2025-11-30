using UnityEngine;
using System.Collections;

/// <summary>
/// Camera Shake Effect for Battle Impact
/// Triggered on attacks and special moves
/// </summary>
public class CameraShake : MonoBehaviour
{
    [Header("Shake Settings")]
    public float defaultDuration = 0.15f;
    public float defaultIntensity = 0.08f;
    public AnimationCurve shakeCurve = AnimationCurve.EaseInOut(0, 1, 1, 0);

    private Vector3 originalPosition;
    private bool isShaking = false;

    void Start()
    {
        originalPosition = transform.localPosition;
    }

    /// <summary>
    /// Trigger camera shake
    /// </summary>
    public void Shake()
    {
        Shake(defaultDuration, defaultIntensity);
    }

    /// <summary>
    /// Trigger camera shake with custom parameters
    /// </summary>
    public void Shake(float duration, float intensity)
    {
        if (!isShaking)
        {
            StartCoroutine(ShakeCoroutine(duration, intensity));
        }
    }

    private IEnumerator ShakeCoroutine(float duration, float intensity)
    {
        isShaking = true;
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float progress = elapsed / duration;
            float currentIntensity = intensity * shakeCurve.Evaluate(progress);

            // Random shake offset
            Vector3 offset = new Vector3(
                Random.Range(-1f, 1f) * currentIntensity,
                Random.Range(-1f, 1f) * currentIntensity,
                0f
            );

            transform.localPosition = originalPosition + offset;

            yield return null;
        }

        // Return to original position
        transform.localPosition = originalPosition;
        isShaking = false;
    }

    /// <summary>
    /// Reset camera to original position
    /// </summary>
    public void ResetPosition()
    {
        StopAllCoroutines();
        transform.localPosition = originalPosition;
        isShaking = false;
    }
}
