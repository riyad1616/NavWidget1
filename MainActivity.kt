package com.navwidget.ui

import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.View
import android.widget.Button
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.materialswitch.MaterialSwitch
import com.navwidget.R
import com.navwidget.service.FloatingWidgetService

class MainActivity : AppCompatActivity() {

    private val prefs: SharedPreferences by lazy {
        getSharedPreferences("navwidget_prefs", MODE_PRIVATE)
    }

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        checkPermissions()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        setupUI()
        loadPreferences()
        checkPermissions()
    }

    override fun onResume() {
        super.onResume()
        checkPermissions()
    }

    private fun setupUI() {
        findViewById<Button>(R.id.btnStartWidget)?.setOnClickListener {
            startWidget()
        }
        findViewById<Button>(R.id.btnStopWidget)?.setOnClickListener {
            stopWidget()
        }
        findViewById<Button>(R.id.btnOpenNotifications)?.setOnClickListener {
            openNotificationSettings()
        }
        findViewById<Button>(R.id.btnOpenOverlay)?.setOnClickListener {
            openOverlaySettings()
        }
        findViewById<Button>(R.id.btnOpenUsageStats)?.setOnClickListener {
            openUsageStatsSettings()
        }
        findViewById<MaterialSwitch>(R.id.swShowCard)?.setOnCheckedChangeListener { _, isChecked ->
            prefs.edit().putBoolean("pref_show_card", isChecked).apply()
        }
        findViewById<MaterialSwitch>(R.id.swHideOnMaps)?.setOnCheckedChangeListener { _, isChecked ->
            prefs.edit().putBoolean("pref_hide_on_maps", isChecked).apply()
        }
    }

    private fun loadPreferences() {
        findViewById<MaterialSwitch>(R.id.swShowCard)?.isChecked =
            prefs.getBoolean("pref_show_card", true)
        findViewById<MaterialSwitch>(R.id.swHideOnMaps)?.isChecked =
            prefs.getBoolean("pref_hide_on_maps", true)
    }

    private fun checkPermissions() {
        val notifsEnabled = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_NOTIFICATION_LISTENERS
        )?.contains("com.navwidget") == true

        val overlayEnabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }

        findViewById<Button>(R.id.btnNotifStatus)?.apply {
            text = if (notifsEnabled) "✓ Notification Access" else "✗ Notification Access"
            setBackgroundColor(
                if (notifsEnabled) getColor(android.R.color.holo_green_light)
                else getColor(android.R.color.holo_red_light)
            )
        }
        findViewById<Button>(R.id.btnOverlayStatus)?.apply {
            text = if (overlayEnabled) "✓ Overlay" else "✗ Overlay"
            setBackgroundColor(
                if (overlayEnabled) getColor(android.R.color.holo_green_light)
                else getColor(android.R.color.holo_red_light)
            )
        }
    }

    private fun startWidget() {
        val serviceIntent = Intent(this, FloatingWidgetService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
        Toast.makeText(this, "Nav Widget Started", Toast.LENGTH_SHORT).show()
    }

    private fun stopWidget() {
        val serviceIntent = Intent(this, FloatingWidgetService::class.java)
        stopService(serviceIntent)
        Toast.makeText(this, "Nav Widget Stopped", Toast.LENGTH_SHORT).show()
    }

    private fun openNotificationSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        permissionLauncher.launch(intent)
    }

    private fun openOverlaySettings() {
        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
        permissionLauncher.launch(intent)
    }

    private fun openUsageStatsSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        permissionLauncher.launch(intent)
    }
}
