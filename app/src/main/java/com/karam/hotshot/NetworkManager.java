package com.karam.hotshot;

import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;

public class NetworkManager {
    public static final int PORT=5055;
    private final boolean host; private final String address; private volatile boolean running;
    private ServerSocket server; private Socket socket; private final List<PrintWriter> clients=new CopyOnWriteArrayList<>();
    private final BlockingQueue<String> inbox=new LinkedBlockingQueue<>();
    public NetworkManager(boolean h,String a){host=h;address=a;}
    public void start(){running=true; if(host)new Thread(this::hostLoop,"hotshot-host").start(); else new Thread(this::clientLoop,"hotshot-client").start();}
    private void hostLoop(){try{server=new ServerSocket(PORT); while(running){Socket s=server.accept(); clients.add(new PrintWriter(new BufferedWriter(new OutputStreamWriter(s.getOutputStream())),true); listen(s);}}catch(IOException ignored){}}
    private void clientLoop(){try{socket=new Socket(); socket.connect(new InetSocketAddress(address,PORT),3000); listen(socket);}catch(Exception e){inbox.offer("ERROR|تعذر الاتصال بالمضيف");}}
    private void listen(Socket s){new Thread(()->{try{BufferedReader r=new BufferedReader(new InputStreamReader(s.getInputStream())); String line; while(running&&(line=r.readLine())!=null) inbox.offer(line);}catch(IOException ignored){}}).start();}
    public void send(String msg){if(!running)return; if(host){for(PrintWriter w:clients)w.println(msg);}else{try{if(socket!=null&&socket.isConnected()){PrintWriter w=new PrintWriter(new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())),true);w.println(msg);}}catch(IOException ignored){}}}
    public String poll(){return inbox.poll();}
    public int players(){return host?clients.size()+1:2;}
    public boolean isHost(){return host;}
    public void stop(){running=false;try{if(server!=null)server.close();}catch(IOException ignored){}try{if(socket!=null)socket.close();}catch(IOException ignored){}}
}
