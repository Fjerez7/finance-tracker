package com.example.financetracker.finance_tracker

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterFragmentActivity() {
    private val securityChannelName = "com.example.financetracker/security"
    private val notificationChannelName = "com.example.financetracker/notifications"
    private var notificationChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)

        // Register real-time callback from BankNotificationListenerService
        BankNotificationListenerService.notificationCallback = { notifJson ->
            runOnUiThread {
                try {
                    val map = jsonObjectToMap(notifJson)
                    notificationChannel?.invokeMethod("onNotificationReceived", map)
                } catch (_: Exception) {}
            }
        }
    }

    override fun onDestroy() {
        BankNotificationListenerService.notificationCallback = null
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Security Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, securityChannelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "setScreenSecurity" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    if (enabled) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 2. Notification Ingestion Channel
        val notifChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, notificationChannelName)
        notificationChannel = notifChannel

        notifChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationAccessGranted" -> {
                    val pkg = packageName
                    val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                    val isGranted = flat != null && flat.contains(pkg)
                    result.success(isGranted)
                }
                "requestNotificationAccess" -> {
                    try {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INTENT_ERROR", e.message, null)
                    }
                }
                "syncMonitoredPackages" -> {
                    val packagesList = call.argument<List<String>>("packages") ?: listOf("com.nu.production")
                    val prefs = applicationContext.getSharedPreferences(BankNotificationListenerService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().putStringSet(BankNotificationListenerService.KEY_MONITORED_PACKAGES, packagesList.toSet()).apply()
                    result.success(true)
                }
                "getBufferedNotifications" -> {
                    val prefs = applicationContext.getSharedPreferences(BankNotificationListenerService.PREFS_NAME, Context.MODE_PRIVATE)
                    val bufferStr = prefs.getString(BankNotificationListenerService.KEY_BUFFERED_NOTIFICATIONS, "[]") ?: "[]"
                    val jsonArray = try { JSONArray(bufferStr) } catch (_: Exception) { JSONArray() }
                    val list = mutableListOf<Map<String, Any?>>()
                    for (i in 0 until jsonArray.length()) {
                        val obj = jsonArray.optJSONObject(i)
                        if (obj != null) {
                            list.add(jsonObjectToMap(obj))
                        }
                    }
                    // Clear buffer once retrieved by Flutter
                    prefs.edit().putString(BankNotificationListenerService.KEY_BUFFERED_NOTIFICATIONS, "[]").apply()
                    result.success(list)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun jsonObjectToMap(jsonObj: JSONObject): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        val keys = jsonObj.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            map[key] = jsonObj.get(key)
        }
        return map
    }
}
