package com.karam.hotshot;

import android.graphics.*; import android.view.*; import android.content.*; import java.util.*;

public class GameView extends View {
    private final Paint p=new Paint(3); private final NetworkManager net; private final boolean host; private float px,py,aimX,aimY; private int hp=100,score=0; private long lastShot=0; private final ArrayList<Enemy> enemies=new ArrayList<>(); private final ArrayList<Bullet> bullets=new ArrayList<>(); private final Random rnd=new Random(); private boolean firing;
    private static class Enemy{float x,y;int hp=30;Enemy(float a,float b){x=a;y=b;}}
    private static class Bullet{float x,y,vx,vy;Bullet(float a,float b,float c,float d){x=a;y=b;vx=c;vy=d;}}
    public GameView(Context c,boolean h,NetworkManager n){super(c);host=h;net=n;setFocusable(true);}
    protected void onDraw(Canvas c){super.onDraw(c); float w=getWidth(),h=getHeight(); c.drawColor(Color.rgb(13,18,27));
        p.setColor(Color.rgb(25,33,46)); for(int x=0;x<w;x+=80)c.drawLine(x,0,x,h,p); for(int y=0;y<h;y+=80)c.drawLine(0,y,w,y,p);
        if(px==0){px=w/2;py=h/2;aimX=px+1;aimY=py;}
        long now=System.currentTimeMillis(); if(host&&now%700<25&&enemies.size()<7) enemies.add(new Enemy(40+rnd.nextFloat()*(w-80),100+rnd.nextFloat()*Math.max(1,h-180)));
        update(now,w,h);
        p.setColor(Color.CYAN);c.drawCircle(px,py,22,p);p.setColor(Color.WHITE);c.drawCircle(px,py,8,p);
        p.setColor(Color.RED);for(Enemy e:enemies){c.drawCircle(e.x,e.y,22,p);p.setColor(Color.BLACK);c.drawRect(e.x-18,e.y-32,e.x+18,e.y-27,p);p.setColor(Color.GREEN);c.drawRect(e.x-18,e.y-32,e.x-18+36*e.hp/30f,e.y-27,p);p.setColor(Color.RED);}
        p.setColor(Color.YELLOW);for(Bullet b:bullets)c.drawCircle(b.x,b.y,5,p);
        p.setColor(Color.WHITE);p.setTextSize(26);c.drawText("HP "+hp+"   SCORE "+score,20,42,p);c.drawText(host?"HOST • "+net.players()+" players":"CLIENT",20,75,p);
        p.setTextSize(15);p.setColor(Color.LTGRAY);c.drawText("اسحب للتحرك والتصويب • اضغط للإطلاق",20,h-24,p);invalidate();
    }
    private void update(long now,float w,float h){for(Enemy e:enemies){float dx=px-e.x,dy=py-e.y,d=(float)Math.hypot(dx,dy);if(d>45){e.x+=dx/d*0.7f;e.y+=dy/d*0.7f;}else if(now%180<18)hp=Math.max(0,hp-2);}
        Iterator<Bullet> it=bullets.iterator();while(it.hasNext()){Bullet b=it.next();b.x+=b.vx;b.y+=b.vy;boolean hit=false;for(Enemy e:enemies){if(Math.hypot(b.x-e.x,b.y-e.y)<25){e.hp-=10;hit=true;if(e.hp<=0){score+=10;enemies.remove(e);}break;}}if(hit||b.x<0||b.y<0||b.x>w||b.y>h)it.remove();}
        if(firing&&now-lastShot>180){shoot();lastShot=now;}
        if(net!=null){String s;while((s=net.poll())!=null){if(s.startsWith("SHOT|")){String[] a=s.split("\\|");if(a.length>=5){} }}}
        if(hp<=0){hp=100;score=Math.max(0,score-25);}
    }
    private void shoot(){float dx=aimX-px,dy=aimY-py,d=(float)Math.hypot(dx,dy);if(d<1)d=1;bullets.add(new Bullet(px,py,dx/d*14,dy/d*14));if(net!=null)net.send("SHOT|"+px+"|"+py+"|"+aimX+"|"+aimY);}
    public boolean onTouchEvent(MotionEvent e){float x=e.getX(),y=e.getY();if(e.getAction()==MotionEvent.ACTION_DOWN||e.getAction()==MotionEvent.ACTION_MOVE){aimX=x;aimY=y;if(e.getX()<getWidth()/2){px=x;py=y;}else firing=true;return true;}if(e.getAction()==MotionEvent.ACTION_UP){firing=false;return true;}return true;}
}
