require "import"
import "android.widget.*"
import "android.view.*"
import "android.content.*"
import "android.net.wifi.*"
import "java.net.NetworkInterface"
import "java.net.Inet4Address"
import "com.koushikdutta.async.*"
import "com.koushikdutta.async.callback.*"
import "com.koushikdutta.async.http.*"
import "java.nio.*"
local base={}

base.getNowIp=function()
  local info=NetworkInterface.getNetworkInterfaces()
  for v in enum(info) do
    for z in enum(v.getInetAddresses()) do
      local inetAddress = z
      if (!inetAddress.isLoopbackAddress() && luajava.instanceof(inetAddress,Inet4Address)) then
        return tostring(inetAddress.getHostAddress())
      end
    end
  end
end

base.connectPhoneNumber=0

base.sendOkNumber=0

base.start=function()
  local server=AsyncServer()
  base.server=server
  server.post { --监听19000窗口
    run=function()
      require "import"
      import "com.koushikdutta.async.*"
      import "com.koushikdutta.async.callback.ListenCallback"
      import "java.net.*"
      import "java.io.*"
      local function setText(t)
        activity.runOnUiThread {
          run=function()
            text.text=t
          end
        }
      end

      server.listen(InetAddress.getByName(base.getNowIp()),19000,{
        onListening=function(socket,e) --已经在监听
          setText("当前状态:等待接收端连接")
        end,
        onAccepted=function(socket)
          import "java.net.*"
          import "java.io.*"
          import "java.nio.*"
          
          base.connectPhoneNumber=base.connectPhoneNumber+1
          setText(("当前状态:已有%s台设备连接，已完成%s/%s"):format(base.connectPhoneNumber,base.sendOkNumber,base.connectPhoneNumber-base.sendOkNumber))
          --   print("a new socket is conntect")

          local file=File(base.filePath)

          local function getStringBytes(str)
            local buffer={}
            for i=1,utf8.len(str) do
              buffer[#buffer+1]=utf8.byte(utf8.sub(str,i,i))
            end
            return buffer
          end

          local head=require"cjson".encode({
            fileName=getStringBytes(file.name), --这里转数字是为了防止出现#
            fileSize=file.length()
          })

          socket.write(ByteBuffer.wrap(String(head.."#").getBytes())) --传输报头



          thread(function(socket,file)
            require "import"
            import "java.net.*"
            import "java.io.*"
            import "java.nio.*"

            local fileBuffer=byte[1024]

            local buffer=ByteBuffer.allocateDirect(1030)

            local input=FileInputStream(file).getChannel()
            local len=input.read(buffer)

            while len~=-1 do
              buffer.rewind()
              buffer.limit(len)
              socket.write(buffer)
              Thread.sleep(0.0001)
              buffer.clear()
              len=input.read(buffer)
            end
            socket.end() --发送结束
          
          end,socket,file)

          

          socket.setClosedCallback {
            onCompleted=function(e)
              base.sendOkNumber=base.sendOkNumber+1
              setText(("当前状态:已有%s台设备连接，已完成%s/%s"):format(base.connectPhoneNumber,base.sendOkNumber,base.connectPhoneNumber-(base.connectPhoneNumber-base.sendOkNumber)))
            end
          }

        end
      })

    end
  }
end

base.stop=function()
  if base.server then
    base.server.stop()
  end
end

return base