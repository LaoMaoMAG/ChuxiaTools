require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "com.koushikdutta.async.*"
import "com.koushikdutta.async.callback.*"
import "com.koushikdutta.async.http.*"
import "java.net.*"
import "java.nio.*"

--用的socket 速度上不去 自己看

activity.setContentView(loadlayout("layout/main"))

--import "layout"
--activity.setTitle('AndroLua+')
--activity.setTheme(android.R.style.Theme_Holo_Light)
--[[
local server=AsyncServer()

local client=AsyncServer.getDefault()

server.post {
  run=function()
    require "import"
    import "com.koushikdutta.async.*"
    import "com.koushikdutta.async.callback.ListenCallback"
    import "java.net.*"
    server.listen(nil,8080,{
      onListening=function(socket,e) --已经在监听
        print("start lister")
      end,
      onAccepted=function(socket)
        print("a new socket is conntect")
        socket.write(ByteBuffer.wrap(String("test").getBytes()))
      end
    })

  end
}

--服务器端监听8080
client.postDelayed({run=function()
    socket=client.connectSocket("127.0.0.1", 8080, {
      onConnectCompleted=function(e,socket)
        if e then
          print("socket connect error "..tostring(e))
          return
        end
        socket.setDataCallback {
          onDataAvailable=function(emitter,bufferList)
            print("a String for server")
            print(String(bufferList.getAllByteArray()))
          end
        }
      end
    })(
  end
},1000)

function onDestroy()

  server.stop()
end

]]
--[[socket.setDataCallback(new DataCallback() {
@Override
  public void onDataAvailable(DataEmitter emitter, ByteBufferList bb) {
    Log.d("Socket", "接收到：" + new String(bb.getAllByteArray()));
  }
});

socket.setClosedCallback(new CompletedCallback() {
@Override
  public void onCompleted(Exception ex) {
    if (ex!=null) {
      Log.d("Socket", "setClosedCallback出错");
      return;
    }
    Log.d("Socket", "setClosedCallback");
  }
});
]]

--socket.connect(InetSocketAddress("127.0.0.1",8080))

--socket.connect()



function onDestroy()
  if server then

    server.stop()
  end
  --client.stop()
--(  
end