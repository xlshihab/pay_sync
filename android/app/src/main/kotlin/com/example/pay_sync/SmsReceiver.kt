package com.example.pay_sync

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("SmsReceiver", "SMS received with action: ${intent.action}")

        when (intent.action) {
            Telephony.Sms.Intents.SMS_RECEIVED_ACTION -> {
                Log.d("SmsReceiver", "SMS_RECEIVED action")
                // For a regular app, we'd extract SMS here
                // But as the default SMS app, we'll receive via SMS_DELIVER
            }
            "android.provider.Telephony.SMS_DELIVER" -> {
                Log.d("SmsReceiver", "SMS_DELIVER action - processing as default SMS app")
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                messages?.forEach { message ->
                    val sender = message.displayOriginatingAddress
                    val body = message.displayMessageBody
                    Log.d("SmsReceiver", "SMS from: $sender, body: $body")
                }
            }
            else -> {
                Log.d("SmsReceiver", "Unknown action: ${intent.action}")
            }
        }
    }
}
