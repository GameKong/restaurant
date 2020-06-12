package org.cocos2dx.lua;

import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;

import com.dm.sdk.ads.splash.SplashAD;
import com.dm.sdk.ads.splash.SplashAdListener;
//import com.dm.sdk.ads.AdView;
import com.dm.sdk.common.util.AdError;


import com.kongl.restaurant.R;

public class SplashActivity extends Activity implements SplashAdListener {
    private SplashAD splashAD;
    private boolean canJump = false;
    private Handler handler = new Handler(Looper.getMainLooper());


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        hideSystemNavigationBar();

        ViewGroup contentView = this.findViewById(R.id.splash_container);
        //此为测试的appKey 和 代码位
        splashAD = new SplashAD(this, "96AgW5Ig0XN+MoOBpZ", "A0602571153", this, 50000);
        splashAD.fetchAndShowIn(contentView);
    }

    private void hideSystemNavigationBar() {
        if (Build.VERSION.SDK_INT > 11 && Build.VERSION.SDK_INT < 19) {
            View view = this.getWindow().getDecorView();
            view.setSystemUiVisibility(View.GONE);
        } else if (Build.VERSION.SDK_INT >= 19) {
            View decorView = getWindow().getDecorView();
            int uiOptions = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN;
            decorView.setSystemUiVisibility(uiOptions);
        }
    }

    @Override
    public void onAdDismissed() {
        Log.d("dp", "点击了跳转按钮");
        this.finish();
    }

    @Override
    public void onNoAd(AdError error) {
        //此方法主要是防止在拉取开屏广告时出错导致开屏一闪而过，开发者也可以根据自己的需求自己实现，不一定按照此方式实现
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                SplashActivity.this.finish();
            }
        }, 3000);
        Log.d("dp", error.getErrorMsg() + "  " + error.getErrorCode());//具体错误码参考在下方
    }

    @Override
    public void onAdPresent() {
        Log.d("dp", "展现了");
    }

    @Override
    public void onAdClicked() {
        Log.d("dp", "点击页面内容");
    }

    @Override
    public void onAdFilled() {
        Log.d("dp", "下发广告了");
    }

    @Override
    protected void onResume() {
        //􏲚􏱡􏱢􏴈􏲉􏰴􏴖􏱌􏲭􏲮􏱟􏱠􏴗􏱾􏰈􏴘􏴋􏰫􏰬􏰊􏱭􏱮􏲲此步骤主要是处理点击广告之后，退出当前的开屏页面，开发者可以根据自己的需求自己处理，不一定按照此方式处理􏱌
        super.onResume();
        if (canJump) {
            this.finish();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        canJump = true;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }

    /**
     * 开屏页一定要禁止用户对返回按钮的控制，否则将可能导致用户手动退出了App而广告无法正常曝光和计费
     */
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK || keyCode == KeyEvent.KEYCODE_HOME) {
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }
}
