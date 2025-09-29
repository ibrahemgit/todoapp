package com.todoapp.smart.todoapp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.getStringExtra("action")
        val taskId = intent.getStringExtra("task_id")
        
        // إرسال الإجراء إلى الخدمة الخلفية
        val serviceIntent = Intent(context, BackgroundNotificationService::class.java).apply {
            putExtra("action", action)
            putExtra("task_id", taskId)
        }
        
        // بدء الخدمة الخلفية
        context.startForegroundService(serviceIntent)
    }
}
