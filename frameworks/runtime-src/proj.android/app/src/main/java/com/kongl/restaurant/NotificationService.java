package com.kongl.restaurant;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.IntentFilter;
import android.util.Log;

import java.util.Calendar;

public class NotificationService extends Service {
    private String receiverFilter = "com.example.notificationtest.broadcast";
    public NotificationService() {

    }

    // 第一次启动服务执行
    @Override
    public void onCreate() {
        Log.d("onCreate", " NotificationService onCreate 运行了");

        // 在服务中注册广播接受器
        registerReceiver();

        // 设置计时器
        setAlarm();
    }
    @Override
    public IBinder onBind(Intent intent) {
        // TODO: Return the communication channel to the service.
        throw new UnsupportedOperationException("Not yet implemented");
    }

    public void registerReceiver()
    {
        NotificationReceiver nfr = new NotificationReceiver();
        IntentFilter itf = new IntentFilter(receiverFilter);
        registerReceiver(nfr, itf);
    }

    public void setAlarm()
    {
        // 设置触发时间
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        calendar.set(Calendar.HOUR, 15);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);

        // 设置与广播接收器相同的action
        Intent intent = new Intent(receiverFilter);
        PendingIntent pi = PendingIntent.getBroadcast(this, 99, intent, PendingIntent.FLAG_UPDATE_CURRENT);

        AlarmManager alarmMgr = (AlarmManager) getSystemService(ALARM_SERVICE);

        /*  setRepeating:循环发送
            type:闹钟类型，唤醒设备以在指定的时间触发待定intent
            triggerAtMillis:触发时间
            intervalMillis：间隔时间
        */
        int type = AlarmManager.RTC_WAKEUP;
        long triggerAtMillis = calendar.getTimeInMillis();
        long intervalMillis = 24 * 60 * 60 * 1000;
        alarmMgr.setRepeating(type, triggerAtMillis, intervalMillis, pi);
    }
}

