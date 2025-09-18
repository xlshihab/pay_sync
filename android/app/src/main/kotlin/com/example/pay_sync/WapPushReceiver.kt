package com.example.pay_sync

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class WapPushReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("WapPushReceiver", "WapPushReceiver invoked with action: ${intent.action}")

        when (intent.action) {
            "android.provider.Telephony.WAP_PUSH_RECEIVED" -> {
                Log.d("WapPushReceiver", "WAP Push received")
                // Handle incoming WAP Push messages
                val mimeType = intent.type
                Log.d("WapPushReceiver", "RECEIVED WAP Push with mimeType: $mimeType")
            }
            "android.provider.Telephony.WAP_PUSH_DELIVER" -> {
                Log.d("WapPushReceiver", "WAP Push deliver")
                // Handle WAP Push delivery (when app is default SMS app)
                val mimeType = intent.type
                Log.d("WapPushReceiver", "DELIVER WAP Push with mimeType: $mimeType")

                // Critical for passing default SMS app requirements
                if (mimeType == "application/vnd.wap.mms-message") {
                    Log.d("WapPushReceiver", "Properly handling WAP_PUSH_DELIVER for MMS messages")
                }
            }
            else -> {
                Log.d("WapPushReceiver", "Unknown action: ${intent.action}")
            }
        }

        // Extra logging for diagnostics
        Log.d("WapPushReceiver", "Intent details: data=${intent.data}, type=${intent.type}, extras=${intent.extras}")
    }
}
