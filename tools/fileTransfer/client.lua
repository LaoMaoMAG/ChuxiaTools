require "import"
import "android.widget.*"
import "android.view.*"
import "com.koushikdutta.async.*"
import "com.koushikdutta.async.callback.*"
import "com.koushikdutta.async.http.*"

local base={}
local client=AsyncServer.getDefault()

base.connect=function(ipPath)
  client.post{
    run=function()
      local function setText(t)
        activity.runOnUiThread {
          run=function()
            text.text=t
          end
        }
      end

      client.connectSocket(ipPath, 19000, {
        onConnectCompleted=function(e,socket)
          if e then
            setText("当前状态:连接发送端失败"..tostring(e))
            return
          end

          local function bytesToString(str)
            local buffer={}
            for i=1,#str do
              buffer[#buffer+1]=utf8.char(str[i])
            end
            return table.concat(buffer)
          end
          local isStart,info

          local dir="/sdcard/MyShare/"
          local file=""
          socket.setDataCallback {
            onDataAvailable=function(emitter,bufferList)

              import "java.io.File"
              import "java.io.FileOutputStream"
              import "java.lang.StringBuffer"

              if not isStart then
                --先读报头

                setText("当前状态:开始传输 正在获取基本信息")
                local strBuffer=StringBuffer()
                local nowChar=utf8.char(bufferList.getByteChar())

                while nowChar~="#" do
                  strBuffer.append(nowChar)
                  nowChar=utf8.char(bufferList.getByteChar())
                end

                info=require "cjson".decode(tostring(strBuffer))

                info.fileName=bytesToString(info.fileName)

                setText("当前状态:正在传输 ("..info.fileName..") 0/"..info.fileSize.." byte")

                isStart=true
                file=File(dir.."/".. info.fileName)
                file.parentFile.mkdirs()
                file.delete()
                file.createNewFile()
              end


              local buffer=byte[1024]
              local out=FileOutputStream(file,true)

              local channel = out.getChannel();

              while bufferList.remaining()~=0 do
                channel.write(bufferList.getAllArray())
                if file.length()==info.fileSize then
                  print("ok")
                  out.close()
                  socket.close()
                 
                  setText("当前状态:传输 ("..info.fileName..") 完成")
                  break
                end
                setText("当前状态:正在传输 ("..info.fileName..") "..file.length().."/"..info.fileSize.." byte")
              end

              out.close()
              channel.close()
              --socket.close()


            end
          }
        end
      })
  end}
end


return base