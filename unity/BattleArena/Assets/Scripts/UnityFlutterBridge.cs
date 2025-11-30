using UnityEngine;
using System;
using System.Collections.Generic;
using Newtonsoft.Json;

/// <summary>
/// Bridge for bidirectional communication between Unity and Flutter
/// Handles message passing via flutter_unity_widget
/// </summary>
public class UnityFlutterBridge : MonoBehaviour
{
    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
        Application.targetFrameRate = 60;
        QualitySettings.vSyncCount = 0;
    }

    private readonly Queue<string> _pendingMessages = new Queue<string>();
    private event Action<string> _messageReceived;

    public event Action<string> OnMessageReceived
    {
        add
        {
            _messageReceived += value;
            FlushQueuedMessages();
        }
        remove
        {
            _messageReceived -= value;
        }
    }

    private void Start()
    {
        Debug.Log("✅ UnityFlutterBridge initialized");
        SendMessageToFlutter(JsonConvert.SerializeObject(new
        {
            status = "ready",
            unityVersion = Application.unityVersion,
            platform = Application.platform.ToString()
        }));
    }

    /// <summary>
    /// Receive message from Flutter
    /// Called by flutter_unity_widget
    /// </summary>
    public void ReceiveMessageFromFlutter(string message)
    {
        Debug.Log($"📩 Message from Flutter: {message}");

        if (_messageReceived != null)
        {
            _messageReceived.Invoke(message);
        }
        else
        {
            _pendingMessages.Enqueue(message);
        }
    }

    /// <summary>
    /// Send message to Flutter
    /// Uses flutter_unity_widget's message channel
    /// </summary>
    public void SendMessageToFlutter(string message)
    {
        Debug.Log($"📤 Sending to Flutter: {message}");
        
        #if UNITY_ANDROID || UNITY_IOS
        // For flutter_unity_widget
        GetComponent<UnityMessageManager>()?.SendMessageToFlutter(message);
        #else
        // Debug mode
        Debug.Log($"[Debug Mode] Would send to Flutter: {message}");
        #endif
    }

    /// <summary>
    /// Send battle event to Flutter
    /// </summary>
    public void SendBattleEvent(BattleEvent battleEvent)
    {
        string json = JsonConvert.SerializeObject(new
        {
            type = "battleEvent",
            @event = battleEvent.eventType,
            data = battleEvent.data,
            timestamp = DateTime.UtcNow.ToString("o")
        });
        
        SendMessageToFlutter(json);
    }

    /// <summary>
    /// Send error to Flutter
    /// </summary>
    public void SendError(string error)
    {
        SendMessageToFlutter(JsonConvert.SerializeObject(new
        {
            type = "error",
            message = error,
            timestamp = DateTime.UtcNow.ToString("o")
        }));
    }

    private void FlushQueuedMessages()
    {
        if (_messageReceived == null || _pendingMessages.Count == 0)
        {
            return;
        }

        while (_pendingMessages.Count > 0)
        {
            _messageReceived.Invoke(_pendingMessages.Dequeue());
        }
    }
}
