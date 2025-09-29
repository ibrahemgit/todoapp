package com.todoapp.smart.todoapp

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.content.SharedPreferences

class BackgroundNotificationService : Service() {
    private val CHANNEL_ID = "background_notification_service"
    private val NOTIFICATION_ID = 1001

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForegroundService()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Background Notification Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Service for handling persistent notifications"
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
                setSound(null, null)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun startForegroundService() {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Todo App Background Service")
            .setContentText("Handling persistent notifications")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // معالجة الإجراءات من الإشعارات
        intent?.let { handleNotificationAction(it) }
        
        // إعادة تشغيل الخدمة إذا تم إيقافها
        return START_STICKY
    }

    private fun handleNotificationAction(intent: Intent) {
        val action = intent.getStringExtra("action")
        val taskId = intent.getStringExtra("task_id")
        
        when (action) {
            "complete_task" -> {
                completeTask(taskId)
            }
            "snooze_task" -> {
                snoozeTask(taskId)
            }
            "tap_task" -> {
                openTask(taskId)
            }
        }
    }

    private fun completeTask(taskId: String?) {
        taskId?.let {
            // حفظ المهمة المكتملة في SharedPreferences
            val prefs = getSharedPreferences("todo_prefs", Context.MODE_PRIVATE)
            val completedTasks = prefs.getStringSet("completed_from_background", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
            completedTasks.add(it)
            prefs.edit().putStringSet("completed_from_background", completedTasks).apply()
            
            // إرسال إشعار تأكيد
            sendConfirmationNotification("تم إتمام المهمة", "تم إتمام المهمة بنجاح")
        }
    }

    private fun snoozeTask(taskId: String?) {
        taskId?.let {
            // حفظ المهمة المؤجلة في SharedPreferences
            val prefs = getSharedPreferences("todo_prefs", Context.MODE_PRIVATE)
            val snoozedTasks = prefs.getStringSet("snoozed_from_background", mutableSetOf())?.toMutableSet() ?: mutableSetOf()
            snoozedTasks.add(it)
            prefs.edit().putStringSet("snoozed_from_background", snoozedTasks).apply()
            
            // إرسال إشعار تأكيد
            sendConfirmationNotification("تم تأجيل المهمة", "تم تأجيل المهمة بنجاح")
        }
    }

    private fun openTask(taskId: String?) {
        taskId?.let {
            // حفظ المهمة للفتح لاحقاً في SharedPreferences
            val prefs = getSharedPreferences("todo_prefs", Context.MODE_PRIVATE)
            prefs.edit().putString("task_to_open_from_background", it).apply()
        }
    }

    private fun sendConfirmationNotification(title: String, message: String) {
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        val notificationId = (System.currentTimeMillis() % 100000).toInt()
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_HIGH) // أولوية عالية
            .setDefaults(NotificationCompat.DEFAULT_ALL) // صوت واهتزاز
            .setColor(0xFF4CAF50.toInt()) // لون أخضر
            .setLights(0xFF4CAF50.toInt(), 1000, 500) // LED أخضر
            .setTimeoutAfter(5000) // يختفي بعد 5 ثوان
            .build()

        notificationManager.notify(notificationId, notification)
        
        // إغلاق الإشعار تلقائياً بعد 5 ثوان
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            notificationManager.cancel(notificationId)
        }, 5000)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        // تنظيف الموارد
    }
}
