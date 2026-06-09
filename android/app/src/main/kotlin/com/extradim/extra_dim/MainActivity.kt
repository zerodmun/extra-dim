package com.extradim.extra_dim

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.extradim.app/overlay"
        private const val REQUEST_OVERLAY_PERMISSION = 5469
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startOverlay" -> handleStartOverlay(call.arguments as? Map<*, *>, result)
                    "stopOverlay" -> handleStopOverlay(result)
                    "updateFilter" -> handleUpdateFilter(call.arguments as? Map<*, *>, result)
                    "checkPermission" -> handleCheckPermission(result)
                    "requestPermission" -> handleRequestPermission(result)
                    "isRunning" -> result.success(OverlayService.isRunning)
                    else -> result.notImplemented()
                }
            }
    }

    // ──────────────────────────────────────────────
    // startOverlay
    // ──────────────────────────────────────────────

    private fun handleStartOverlay(args: Map<*, *>?, result: MethodChannel.Result) {
        if (!hasOverlayPermission()) {
            result.error("PERMISSION_DENIED", "Overlay permission not granted", null)
            return
        }

        val red = (args?.get("red") as? Int) ?: 0
        val green = (args?.get("green") as? Int) ?: 0
        val blue = (args?.get("blue") as? Int) ?: 0
        val alpha = (args?.get("alpha") as? Int) ?: 128
        val usePixelFilter = (args?.get("usePixelFilter") as? Boolean) ?: false
        val pixelFilterLevel = (args?.get("pixelFilterLevel") as? Int) ?: 0

        val intent = Intent(this, OverlayService::class.java).apply {
            action = OverlayService.ACTION_START
            putExtra(OverlayService.EXTRA_RED, red)
            putExtra(OverlayService.EXTRA_GREEN, green)
            putExtra(OverlayService.EXTRA_BLUE, blue)
            putExtra(OverlayService.EXTRA_ALPHA, alpha)
            putExtra(OverlayService.EXTRA_USE_PIXEL_FILTER, usePixelFilter)
            putExtra(OverlayService.EXTRA_PIXEL_FILTER_LEVEL, pixelFilterLevel)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }

        result.success(true)
    }

    // ──────────────────────────────────────────────
    // stopOverlay
    // ──────────────────────────────────────────────

    private fun handleStopOverlay(result: MethodChannel.Result) {
        val intent = Intent(this, OverlayService::class.java).apply {
            action = OverlayService.ACTION_STOP
        }
        startService(intent)
        result.success(true)
    }

    // ──────────────────────────────────────────────
    // updateFilter
    // ──────────────────────────────────────────────

    private fun handleUpdateFilter(args: Map<*, *>?, result: MethodChannel.Result) {
        val serviceInstance = OverlayService.instance
        if (serviceInstance == null) {
            result.error("SERVICE_NOT_RUNNING", "Overlay service is not running", null)
            return
        }

        val red = (args?.get("red") as? Int) ?: 0
        val green = (args?.get("green") as? Int) ?: 0
        val blue = (args?.get("blue") as? Int) ?: 0
        val alpha = (args?.get("alpha") as? Int) ?: 128
        val usePixelFilter = (args?.get("usePixelFilter") as? Boolean) ?: false
        val pixelFilterLevel = (args?.get("pixelFilterLevel") as? Int) ?: 0

        serviceInstance.updateColor(red, green, blue, alpha, usePixelFilter, pixelFilterLevel)
        result.success(true)
    }

    // ──────────────────────────────────────────────
    // Permission handling
    // ──────────────────────────────────────────────

    private fun handleCheckPermission(result: MethodChannel.Result) {
        result.success(hasOverlayPermission())
    }

    private fun handleRequestPermission(result: MethodChannel.Result) {
        if (hasOverlayPermission()) {
            result.success(true)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            pendingPermissionResult = result
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            @Suppress("DEPRECATION")
            startActivityForResult(intent, REQUEST_OVERLAY_PERMISSION)
        } else {
            // Pre-M: permission granted at install time
            result.success(true)
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true // Pre-M doesn't require runtime overlay permission
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_OVERLAY_PERMISSION) {
            val granted = hasOverlayPermission()
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }
}
