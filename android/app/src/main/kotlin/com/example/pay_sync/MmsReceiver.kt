package com.example.pay_sync

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class MmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("MmsReceiver", "MMS received with action: ${intent.action}")

        when (intent.action) {
            "android.provider.Telephony.MMS_RECEIVED" -> {
                Log.d("MmsReceiver", "MMS_RECEIVED action")
                // For a regular app, we'd extract MMS here
            }
            "android.provider.Telephony.MMS_DELIVER" -> {
                Log.d("MmsReceiver", "MMS_DELIVER action - processing as default SMS app")
                // As the default SMS app, we receive MMS content here
            }
            else -> {
                Log.d("MmsReceiver", "Unknown action: ${intent.action}")
            }
        }
    }
}
