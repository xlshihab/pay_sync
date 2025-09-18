package com.example.pay_sync

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class HeadlessIncomingSmsService : Service() {

    override fun onBind(intent: Intent?): IBinder? {
        Log.d("HeadlessIncomingSmsService", "onBind called with intent: $intent")
        return null
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("HeadlessIncomingSmsService", "Service created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("HeadlessIncomingSmsService", "HeadlessIncomingSmsService started with action: ${intent?.action}")

        // Handle headless SMS and respond via message functionality
        if (intent != null) {
            when (intent.action) {
                "android.intent.action.RESPOND_VIA_MESSAGE" -> {
                    Log.d("HeadlessIncomingSmsService", "Handling RESPOND_VIA_MESSAGE action!")
                    // Handle respond via message functionality
                    val recipientUri = intent.data
                    val message = intent.getStringExtra(Intent.EXTRA_TEXT)
                    Log.d("HeadlessIncomingSmsService", "Recipient: $recipientUri, Message: $message")

                    // This is critical for being eligible as default SMS app
                    Log.d("HeadlessIncomingSmsService", "Successfully processed RESPOND_VIA_MESSAGE")

                    // Extra logging for diagnostics
                    Log.d("HeadlessIncomingSmsService", "Intent details: data=${intent.data}, extras=${intent.extras}")

                    // For our read-only SMS app, we don't actually send messages
                    // But we need this service to be eligible as default SMS app
                }
                else -> {
                    Log.d("HeadlessIncomingSmsService", "Unknown action: ${intent.action}")
                }
            }
        } else {
            Log.d("HeadlessIncomingSmsService", "Intent is null")
        }

        stopSelf(startId)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        Log.d("HeadlessIncomingSmsService", "Service destroyed")
        super.onDestroy()
    }
}
