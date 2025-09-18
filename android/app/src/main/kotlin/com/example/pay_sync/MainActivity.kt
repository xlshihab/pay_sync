package com.example.pay_sync

import android.Manifest
import android.app.Activity
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Telephony
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.pay_sync/sms"
    private val SMS_PERMISSION_REQUEST_CODE = 100
    private val DEFAULT_SMS_REQUEST_CODE = 101

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkSmsPermissions" -> {
                    result.success(checkSmsPermissions())
                }
                "requestSmsPermissions" -> {
                    requestSmsPermissions()
                    result.success(true)
                }
                "isDefaultSmsApp" -> {
                    result.success(isDefaultSmsApp())
                }
                "requestDefaultSmsApp" -> {
                    requestDefaultSmsApp()
                    result.success(true)
                }
                "diagnoseSmsApp" -> {
                    diagnoseSmsAppIssues()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkSmsPermissions(): Boolean {
        val permissions = arrayOf(
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS,
            Manifest.permission.SEND_SMS,
            Manifest.permission.READ_PHONE_STATE
        )

        val result = permissions.all { permission ->
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        }

        Log.d("MainActivity", "SMS permissions check result: $result")
        return result
    }

    private fun requestSmsPermissions() {
        val permissions = arrayOf(
            Manifest.permission.RECEIVE_SMS,
            Manifest.permission.READ_SMS,
            Manifest.permission.SEND_SMS,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.RECEIVE_MMS,
            Manifest.permission.RECEIVE_WAP_PUSH
        )

        Log.d("MainActivity", "Requesting SMS permissions...")
        ActivityCompat.requestPermissions(this, permissions, SMS_PERMISSION_REQUEST_CODE)
    }

    private fun isDefaultSmsApp(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            val defaultSmsPackage = Telephony.Sms.getDefaultSmsPackage(this)
            val isDefault = packageName == defaultSmsPackage
            Log.d("MainActivity", "Default SMS package: $defaultSmsPackage")
            Log.d("MainActivity", "Our package: $packageName")
            Log.d("MainActivity", "Is default SMS app: $isDefault")
            isDefault
        } else {
            Log.d("MainActivity", "Android version too old for default SMS app")
            false
        }
    }

    private fun requestDefaultSmsApp() {
        Log.d("MainActivity", "Requesting default SMS app status...")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // For Android 10+ use RoleManager
            try {
                val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
                if (roleManager.isRoleAvailable(RoleManager.ROLE_SMS)) {
                    if (!roleManager.isRoleHeld(RoleManager.ROLE_SMS)) {
                        val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_SMS)
                        Log.d("MainActivity", "Launching RoleManager intent for Android 10+")
                        startActivityForResult(intent, DEFAULT_SMS_REQUEST_CODE)
                    } else {
                        Log.d("MainActivity", "Already holding SMS role")
                    }
                } else {
                    Log.d("MainActivity", "SMS role not available")
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Error with RoleManager: ${e.message}")
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            // For Android 4.4+ use traditional method
            try {
                val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
                intent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, packageName)
                Log.d("MainActivity", "Launching traditional SMS default intent")
                startActivityForResult(intent, DEFAULT_SMS_REQUEST_CODE)
            } catch (e: Exception) {
                Log.e("MainActivity", "Error launching default SMS intent: ${e.message}")
            }
        } else {
            Log.d("MainActivity", "Android version too old for default SMS app")
        }
    }

    private fun diagnoseSmsAppIssues() {
        Log.d("MainActivity", "=== SMS APP DIAGNOSIS START ===")

        val packageManager = packageManager
        val packageName = packageName

        // 1. Check if we can handle SEND intent
        val sendIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
        }
        val sendActivities = packageManager.queryIntentActivities(sendIntent, PackageManager.MATCH_DEFAULT_ONLY)
        val hasSendActivity = sendActivities.any { it.activityInfo.packageName == packageName }
        Log.d("MainActivity", "✓ Can handle SEND intent: $hasSendActivity")

        // 2. Check if we can handle SENDTO intent
        val sendToIntent = Intent(Intent.ACTION_SENDTO).apply {
            data = android.net.Uri.parse("sms:")
        }
        val sendToActivities = packageManager.queryIntentActivities(sendToIntent, 0)
        val hasSendToActivity = sendToActivities.any { it.activityInfo.packageName == packageName }
        Log.d("MainActivity", "✓ Can handle SENDTO intent: $hasSendToActivity")

        // 3. Check SMS_DELIVER
        val smsDeliverIntent = Intent("android.provider.Telephony.SMS_DELIVER")
        val deliverActivities = packageManager.queryIntentActivities(smsDeliverIntent, 0)
        val hasDeliverActivity = deliverActivities.any { it.activityInfo.packageName == packageName }
        Log.d("MainActivity", "✓ Can handle SMS_DELIVER: $hasDeliverActivity")

        // 4. Check WAP_PUSH_DELIVER
        val wapPushIntent = Intent("android.provider.Telephony.WAP_PUSH_DELIVER")
        val wapPushActivities = packageManager.queryIntentActivities(wapPushIntent, 0)
        val hasWapPushActivity = wapPushActivities.any { it.activityInfo.packageName == packageName }
        Log.d("MainActivity", "✓ Can handle WAP_PUSH_DELIVER: $hasWapPushActivity")

        // 5. Check RESPOND_VIA_MESSAGE service
        val respondIntent = Intent("android.intent.action.RESPOND_VIA_MESSAGE")
        val respondServices = packageManager.queryIntentServices(respondIntent, 0)
        val hasRespondService = respondServices.any { it.serviceInfo.packageName == packageName }
        Log.d("MainActivity", "✓ Has RESPOND_VIA_MESSAGE service: $hasRespondService")

        // 6. Check permissions
        val hasReceiveSms = ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED
        val hasReadSms = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
        val hasSendSms = ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED
        Log.d("MainActivity", "✓ Has RECEIVE_SMS: $hasReceiveSms")
        Log.d("MainActivity", "✓ Has READ_SMS: $hasReadSms")
        Log.d("MainActivity", "✓ Has SEND_SMS: $hasSendSms")

        // Summary
        val allRequirementsMet = hasSendActivity && hasSendToActivity && hasDeliverActivity && hasWapPushActivity && hasRespondService && hasReceiveSms && hasReadSms && hasSendSms
        Log.d("MainActivity", "=== FINAL RESULT: Can be default SMS app = $allRequirementsMet ===")

        if (!allRequirementsMet) {
            Log.e("MainActivity", "❌ MISSING REQUIREMENTS - Cannot be default SMS app!")
        } else {
            Log.d("MainActivity", "✅ ALL REQUIREMENTS MET - Should be able to be default SMS app!")
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            DEFAULT_SMS_REQUEST_CODE -> {
                Log.d("MainActivity", "Default SMS request result: $resultCode")
                if (resultCode == Activity.RESULT_OK) {
                    Log.d("MainActivity", "User accepted default SMS app request")
                } else {
                    Log.d("MainActivity", "User rejected default SMS app request")
                }
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            SMS_PERMISSION_REQUEST_CODE -> {
                val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
                Log.d("MainActivity", "SMS permissions result: All granted = $allGranted")
            }
        }
    }
}
