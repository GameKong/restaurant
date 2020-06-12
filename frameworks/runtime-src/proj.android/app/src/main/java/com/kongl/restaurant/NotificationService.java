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
    public NotificationService() {

    }

    @Override
    public void onCreate() {
        Log.d("onCreate", " NotificationService onCreate 运行了");
        registerReceiver();
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
        IntentFilter itf = new IntentFilter("com.example.notificationtest.broadcast");
        registerReceiver(nfr, itf);
    }

    public void setAlarm()
    {
        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(System.currentTimeMillis());
        int minute = calendar.get(Calendar.MINUTE) + 1;
        calendar.set(Calendar.MINUTE, minute);

        Intent intent = new Intent("com.example.notificationtest.broadcast");
        PendingIntent pi = PendingIntent.getBroadcast(this, 99, intent, PendingIntent.FLAG_UPDATE_CURRENT);

        AlarmManager alarmMgr = (AlarmManager) getSystemService(ALARM_SERVICE);
        alarmMgr.setRepeating(AlarmManager.RTC_WAKEUP,
                calendar.getTimeInMillis(),
                1 * 60 * 1000, pi);
    }
}

