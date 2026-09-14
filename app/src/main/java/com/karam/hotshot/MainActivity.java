package com.karam.hotshot;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.view.Gravity;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MainActivity extends Activity {
    private LinearLayout root;
    private NetworkManager network;

    @Override public void onCreate(Bundle savedInstanceState) { super.onCreate(savedInstanceState); showMenu(); }
    private TextView label(String s,float z){ TextView t=new TextView(this); t.setText(s); t.setTextColor(Color.WHITE); t.setTextSize(z); t.setGravity(Gravity.CENTER); t.setPadding(12,16,12,16); return t; }
    private Button button(String s){ Button b=new Button(this); b.setText(s); b.setTextSize(16); b.setTextColor(Color.WHITE); b.setAllCaps(false); return b; }
    private void showMenu(){
        root=new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setGravity(Gravity.CENTER); root.setPadding(30,20,30,20); root.setBackgroundColor(Color.rgb(9,13,20));
        root.addView(label("HOTSHOT",46)); root.addView(label("لعبة تصويب محلية بدون إنترنت\n2–8 لاعبين عبر نقطة الاتصال",18));
        Button host=button("إنشاء غرفة"), join=button("الانضمام لغرفة"), solo=button("تجربة فردية"), settings=button("الإعدادات");
        root.addView(host); root.addView(join); root.addView(solo); root.addView(settings); root.addView(label("صنع بواسطة كرم - أبو إبراهيم",13)); setContentView(root);
        host.setOnClickListener(v->{ network=new NetworkManager(true,""); network.start(); startGame(true); });
        join.setOnClickListener(v->showJoin()); solo.setOnClickListener(v->startGame(false)); settings.setOnClickListener(v->showSettings());
    }
    private void showJoin(){
        root.removeAllViews(); root.addView(label("الانضمام إلى HOTSHOT",30));
        EditText ip=new EditText(this); ip.setHint("IP المضيف مثل 192.168.43.1"); ip.setTextColor(Color.WHITE); ip.setHintTextColor(Color.GRAY); root.addView(ip);
        Button connect=button("اتصال"), back=button("رجوع"); root.addView(connect); root.addView(back);
        connect.setOnClickListener(v->{ String a=ip.getText().toString().trim(); if(a.length()==0)a="192.168.43.1"; network=new NetworkManager(false,a); network.start(); startGame(false); }); back.setOnClickListener(v->showMenu());
    }
    private void startGame(boolean host){ GameView game=new GameView(this,host,network); setContentView(game); game.requestFocus(); }
    private void showSettings(){ root.removeAllViews(); root.addView(label("الإعدادات",30)); root.addView(label("شبكة محلية فقط\nلا حسابات • لا Firebase • لا خادم خارجي\nالمنفذ: 5055",17)); Button b=button("رجوع"); root.addView(b); b.setOnClickListener(v->showMenu()); }
    @Override public void onBackPressed(){ if(network!=null){network.stop();network=null;} showMenu(); }
}
