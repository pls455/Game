package com.karam.hotshot;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.view.Gravity;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER);
        root.setBackgroundColor(Color.rgb(10, 14, 20));

        TextView title = new TextView(this);
        title.setText("HOTSHOT");
        title.setTextColor(Color.WHITE);
        title.setTextSize(42);
        title.setGravity(Gravity.CENTER);

        TextView status = new TextView(this);
        status.setText("OFFLINE • LOCAL MULTIPLAYER\nجاهز للمرحلة الأولى");
        status.setTextColor(Color.LTGRAY);
        status.setTextSize(18);
        status.setGravity(Gravity.CENTER);

        root.addView(title, new LinearLayout.LayoutParams(-1, -2));
        root.addView(status, new LinearLayout.LayoutParams(-1, -2));
        setContentView(root);
    }
}
