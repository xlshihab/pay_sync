package com.example.pay_sync

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class MmsService : Service() {

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("MmsService", "MmsService started with action: ${intent?.action}")

        // Handle MMS delivery and WAP push (when app is default SMS app)
        when (intent?.action) {
            "android.provider.Telephony.WAP_PUSH_DELIVER" -> {
                Log.d("MmsService", "Handling WAP Push delivery")
                // Handle WAP Push delivery
            }
            "android.provider.Telephony.MMS_DELIVER" -> {
                Log.d("MmsService", "Handling MMS delivery")
                // Handle MMS delivery
            }
            else -> {
                Log.d("MmsService", "Unknown action: ${intent?.action}")
            }
        }

        stopSelf()
        return START_NOT_STICKY
    }
}
