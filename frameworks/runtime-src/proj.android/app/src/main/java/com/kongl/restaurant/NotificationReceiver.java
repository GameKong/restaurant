package com.kongl.restaurant;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;

import org.cocos2dx.lua.AppActivity;

import java.util.Calendar;

public class NotificationReceiver extends BroadcastReceiver {
    static public long time_stamp = 0;

    @Override
    public void onReceive(Context context, Intent intent) {
        // TODO: This method is called when the BroadcastReceiver is receiving
        createNotification(context, intent);

        // an Intent broadcast.
//        throw new UnsupportedOperationException("Not yet implemented");
    }

    // 创建一个简单的通知
    private void createNotification(Context context, Intent intent)
    {
        // Create an explicit intent for an Activity in your app
        Intent m_intent = new Intent(context, AppActivity.class);
        String text = intent.getExtras().getString("text");
        intent.putExtra("text", text);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, m_intent, PendingIntent.FLAG_UPDATE_CURRENT);

        Calendar calendar = Calendar.getInstance();
        int h = calendar.get(Calendar.HOUR);
        int m = calendar.get(Calendar.MINUTE);
        int s = calendar.get(Calendar.SECOND);

        int last = (int)NotificationReceiver.time_stamp;
        int now = (int)(System.currentTimeMillis() / 1000);
        int st = now - last;
        long lh = st / 3600;
        long lm = st % 60;
        long ls = st % 3600;
        NotificationReceiver.time_stamp = System.currentTimeMillis() / 1000;

        String big_text = String.format("%d时%d分%d秒, 距离上次%d时%d分%d秒。\n last:%d \n now:%d", h, m, s, lh ,lm, ls, last, now);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, AppActivity.notify_channel)
                // @必需设置的内容
                // 设置通知图标
                .setSmallIcon(R.mipmap.ic_launcher)

                // @不是必需设置的内容
                // 设置通知标题
                .setContentTitle("午间奖励")

                // 设置通知内容详情
                .setContentText("登陆游戏领取午间奖励")

//                .setStyle(new NotificationCompat.BigTextStyle().bigText(big_text))

                // pendingIntent描述了点击通知时所触发的行为，通常为跳转到一个页面，也可以是启动一个服务或发送一个广播
                .setContentIntent(pendingIntent)

                // 设置展开式通知的风格为长文本内容风格，并且设置要显示的长文本
                .setAutoCancel(true)

                // 设置优先级，兼容低版本，仅在Android 8.0以下有效，Android 8.0以上使用NotificationChannel的importance字段
                .setPriority(NotificationCompat.PRIORITY_DEFAULT);

        NotificationManagerCompat nm = NotificationManagerCompat.from(context);
        nm.notify(1, builder.build());
    }
}

