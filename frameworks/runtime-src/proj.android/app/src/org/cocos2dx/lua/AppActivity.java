/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2016 Chukong Technologies Inc.
Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import com.kongl.restaurant.NotificationService;

import org.cocos2dx.lib.Cocos2dxActivity;

public class AppActivity extends Cocos2dxActivity{
    public static AppActivity instance;
    public static String notify_channel = "notification_channel";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.setEnableVirtualButton(false);
        super.onCreate(savedInstanceState);
        // Workaround in https://stackoverflow.com/questions/16283079/re-launch-of-activity-on-home-button-but-only-the-first-time/16447508
        if (!isTaskRoot()) {
            // Android launched another instance of the root activity into an existing task
            //  so just quietly finish and go away, dropping the user back into the activity
            //  at the top of the stack (ie: the last state of this task)
            // Don't need to finish it again since it's finished in super.onCreate .
            return;
        }

        // DO OTHER INITIALIZATION BELOW
        instance = this;

        // SDK开屏广告
        Intent intent=new Intent(this,SplashActivity.class);
        this.startActivity(intent);

        // 创建通知渠道
        createNotificationChannels();

        // 注册服务用于离线推送
        startMyService();
    }

    public void startMyService()
    {
        Intent it = new Intent(this, NotificationService.class);
        startService(it);
    }

    // lua Java测试
    public static void test() {

        Log.d("测试Tag","33333333333");
        jniTest("******JNITEST");
    }

    // 创建通知渠道
    private void createNotificationChannels()
    {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        // 只有安卓8.0以上的版本才支持通知渠道
        // 当应用的API level 小于26时，则不用注册通知渠道
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // 通知渠道的重要性， 在安卓8.0以下版本，没有通知渠道的功能，使用通知的 setPriority()代替
            int importance = NotificationManager.IMPORTANCE_DEFAULT;

            // 创建通知渠道
            NotificationChannel channel = new NotificationChannel(AppActivity.notify_channel, "定时离线推送渠道", importance);

            // 设置渠道描述
            channel.setDescription("每日固定时间提醒用户上线领奖");

            // 创建通知渠道之后，将无法通过编程的方式改变通知渠道的属性，例如重要性。 只有用户可以更改
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    public static native void jniTest(java.lang.String string_args);

}
