package com.example.financetracker.finance_tracker

import android.app.Notification
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject

/**
 * Native Android service intercepting push notifications from authorized banking apps.
 * Implements strict instant drop for non-whitelisted packages to protect user privacy.
 */
class BankNotificationListenerService : NotificationListenerService() {

    companion object {
        const val PREFS_NAME = "finance_tracker_notification_prefs"
        const val KEY_MONITORED_PACKAGES = "monitored_packages"
        const val KEY_BUFFERED_NOTIFICATIONS = "buffered_notifications"
        val DEFAULT_PACKAGES = setOf("com.nu.production")

        var notificationCallback: ((JSONObject) -> Unit)? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return

        val packageName = sbn.packageName ?: return

        // 1. Strict Whitelist Check
        val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val monitored = prefs.getStringSet(KEY_MONITORED_PACKAGES, DEFAULT_PACKAGES) ?: DEFAULT_PACKAGES

        if (!monitored.contains(packageName)) {
            return // Dropped immediately in native memory (< 0.1ms)
        }

        // 2. Extract Notification Content
        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""

        val body = if (bigText.isNotBlank()) bigText else text
        if (body.isBlank() && title.isBlank()) {
            return
        }

        val postTime = sbn.postTime
        val notificationId = sbn.id
        val sanitizedKey = "${packageName}_${postTime}_${notificationId}"

        val notifJson = JSONObject().apply {
            put("packageName", packageName)
            put("notificationKey", sanitizedKey)
            put("title", title)
            put("body", body)
            put("postTime", postTime)
        }

        // 3. If Flutter is running in foreground, notify immediately
        notificationCallback?.invoke(notifJson)

        // 4. Save to persistent offline buffer
        synchronized(this) {
            val currentBufferStr = prefs.getString(KEY_BUFFERED_NOTIFICATIONS, "[]") ?: "[]"
            val jsonArray = try {
                JSONArray(currentBufferStr)
            } catch (_: Exception) {
                JSONArray()
            }

            // Deduplicate inside buffer
            var alreadyExists = false
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.optJSONObject(i)
                if (obj != null && obj.optString("notificationKey") == sanitizedKey) {
                    alreadyExists = true
                    break
                }
            }

            if (!alreadyExists) {
                jsonArray.put(notifJson)
                prefs.edit().putString(KEY_BUFFERED_NOTIFICATIONS, jsonArray.toString()).apply()
            }
        }
    }
}
