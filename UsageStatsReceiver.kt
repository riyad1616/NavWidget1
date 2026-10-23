package com.navwidget.receiver

import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES

class UsageStatsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "com.navwidget.CHECK_GOOGLE_MAPS") {
            context?.let {
                val usageStatsManager = it.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                val endTime = System.currentTimeMillis()
                val startTime = endTime - 10000
                val stats = usageStatsManager.queryUsageStats(
                    UsageStatsManager.INTERVAL_DAILY,
                    startTime, endTime
                )
                val isGoogleMapsActive = stats?.any { it.packageName == "com.google.android.apps.maps" } == true
                if (isGoogleMapsActive) {
                    val updateIntent = Intent("com.navwidget.UPDATE_NAV")
                    it.sendBroadcast(updateIntent)
                }
            }
        }
    }
}
