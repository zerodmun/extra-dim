package com.extradim.extra_dim

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.Shader
import android.os.Build
import android.os.IBinder
import android.view.View
import android.view.WindowManager

class OverlayService : Service() {

    companion object {
        const val CHANNEL_ID = "extra_dim_overlay"
        const val CHANNEL_NAME = "Screen Filter"
        const val NOTIFICATION_ID = 1001

        const val EXTRA_RED = "red"
        const val EXTRA_GREEN = "green"
        const val EXTRA_BLUE = "blue"
        const val EXTRA_ALPHA = "alpha"
        const val EXTRA_USE_PIXEL_FILTER = "usePixelFilter"
        const val EXTRA_PIXEL_FILTER_LEVEL = "pixelFilterLevel"

        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
        const val ACTION_UPDATE = "ACTION_UPDATE"

        /** Static reference so MainActivity can query running state and update color. */
        var instance: OverlayService? = null
            private set

        val isRunning: Boolean
            get() = instance != null
    }

    private var overlayView: View? = null
    private var windowManager: WindowManager? = null
    private val handler = android.os.Handler(android.os.Looper.getMainLooper())
    private val shiftRunnable = object : Runnable {
        override fun run() {
            (overlayView as? PixelFilterView)?.shiftPattern()
            handler.postDelayed(this, 5 * 60 * 1000) // Shift every 5 minutes
        }
    }

    // ──────────────────────────────────────────────
    // Service lifecycle
    // ──────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        instance = this
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopOverlay()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_UPDATE -> {
                val r = intent.getIntExtra(EXTRA_RED, 0)
                val g = intent.getIntExtra(EXTRA_GREEN, 0)
                val b = intent.getIntExtra(EXTRA_BLUE, 0)
                val a = intent.getIntExtra(EXTRA_ALPHA, 128)
                val usePixel = intent.getBooleanExtra(EXTRA_USE_PIXEL_FILTER, false)
                val level = intent.getIntExtra(EXTRA_PIXEL_FILTER_LEVEL, 0)
                updateColor(r, g, b, a, usePixel, level)
            }
            ACTION_START, null -> {
                val r = intent?.getIntExtra(EXTRA_RED, 0) ?: 0
                val g = intent?.getIntExtra(EXTRA_GREEN, 0) ?: 0
                val b = intent?.getIntExtra(EXTRA_BLUE, 0) ?: 0
                val a = intent?.getIntExtra(EXTRA_ALPHA, 128) ?: 128
                val usePixel = intent?.getBooleanExtra(EXTRA_USE_PIXEL_FILTER, false) ?: false
                val level = intent?.getIntExtra(EXTRA_PIXEL_FILTER_LEVEL, 0) ?: 0

                createNotificationChannel()
                startForeground(NOTIFICATION_ID, buildNotification())
                startOverlay(r, g, b, a, usePixel, level)
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        stopOverlay()
        instance = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ──────────────────────────────────────────────
    // Overlay management
    // ──────────────────────────────────────────────

    private fun startOverlay(red: Int, green: Int, blue: Int, alpha: Int, usePixelFilter: Boolean = false, pixelFilterLevel: Int = 0) {
        if (overlayView != null) {
            // Already showing – just update color/pattern
            updateColor(red, green, blue, alpha, usePixelFilter, pixelFilterLevel)
            return
        }

        val params = buildLayoutParams()
        overlayView = PixelFilterView(this).apply {
            updateParams(red, green, blue, alpha, usePixelFilter, pixelFilterLevel)
        }

        windowManager?.addView(overlayView, params)

        if (usePixelFilter && pixelFilterLevel > 0) {
            handler.postDelayed(shiftRunnable, 5 * 60 * 1000)
        }
    }

    fun stopOverlay() {
        handler.removeCallbacks(shiftRunnable)
        overlayView?.let { view ->
            try {
                windowManager?.removeView(view)
            } catch (_: Exception) {
                // View may already have been removed
            }
        }
        overlayView = null
    }

    fun updateColor(red: Int, green: Int, blue: Int, alpha: Int, usePixelFilter: Boolean = false, pixelFilterLevel: Int = 0) {
        handler.removeCallbacks(shiftRunnable)
        (overlayView as? PixelFilterView)?.updateParams(red, green, blue, alpha, usePixelFilter, pixelFilterLevel)
        
        if (usePixelFilter && pixelFilterLevel > 0) {
            handler.postDelayed(shiftRunnable, 5 * 60 * 1000)
        }
    }

    // ──────────────────────────────────────────────
    // WindowManager layout params
    // ──────────────────────────────────────────────

    private fun buildLayoutParams(): WindowManager.LayoutParams {
        val overlayType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_SYSTEM_OVERLAY
        }

        return WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            overlayType,
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                    or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                    or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
                    or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )
    }

    // ──────────────────────────────────────────────
    // Notification helpers
    // ──────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows when the screen dimming filter is active"
                setShowBadge(false)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent, pendingIntentFlags
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setContentTitle("Extra Dim")
            .setContentText("Screen filter is active")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }
}

// ──────────────────────────────────────────────
// Custom PixelFilterView
// ──────────────────────────────────────────────

class PixelFilterView(context: Context) : View(context) {
    private var red: Int = 0
    private var green: Int = 0
    private var blue: Int = 0
    private var alphaVal: Int = 0
    private var usePixelFilter: Boolean = false
    private var pixelFilterLevel: Int = 0

    private var shiftX = 0
    private var shiftY = 0

    private val filterPaint = Paint()

    fun updateParams(r: Int, g: Int, b: Int, a: Int, useFilter: Boolean, level: Int) {
        red = r
        green = g
        blue = b
        alphaVal = a
        usePixelFilter = useFilter
        pixelFilterLevel = level
        setupPaint()
        invalidate()
    }

    fun shiftPattern() {
        if (!usePixelFilter || pixelFilterLevel <= 0) return
        
        // Cycle shift X and Y to prevent burn-in (alternating off pixels)
        shiftX = (shiftX + 1) % 2
        if (shiftX == 0) {
            shiftY = (shiftY + 1) % 2
        }
        setupPaint()
        invalidate()
    }

    private fun setupPaint() {
        if (usePixelFilter && pixelFilterLevel > 0) {
            val size = 2
            val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            bmp.eraseColor(Color.TRANSPARENT)

            // Depending on pixel filter level:
            // 25%: 1 pixel is black, 3 are transparent
            // 50%: 2 pixels are black, 2 are transparent (checkerboard)
            // 75%: 3 pixels are black, 1 is transparent
            when (pixelFilterLevel) {
                25 -> {
                    bmp.setPixel(0, 0, Color.BLACK)
                }
                50 -> {
                    bmp.setPixel(0, 0, Color.BLACK)
                    bmp.setPixel(1, 1, Color.BLACK)
                }
                75 -> {
                    bmp.setPixel(0, 0, Color.BLACK)
                    bmp.setPixel(0, 1, Color.BLACK)
                    bmp.setPixel(1, 0, Color.BLACK)
                }
                else -> {
                    bmp.setPixel(0, 0, Color.BLACK)
                }
            }

            val shader = BitmapShader(bmp, Shader.TileMode.REPEAT, Shader.TileMode.REPEAT)
            val matrix = android.graphics.Matrix()
            matrix.postTranslate(shiftX.toFloat(), shiftY.toFloat())
            shader.setLocalMatrix(matrix)

            filterPaint.shader = shader
            filterPaint.color = Color.BLACK
        } else {
            filterPaint.shader = null
            filterPaint.color = Color.argb(alphaVal, red, green, blue)
        }
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), filterPaint)
    }
}
