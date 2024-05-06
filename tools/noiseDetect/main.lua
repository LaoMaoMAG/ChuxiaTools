require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "layout"
import "java.io.File"
--activity.setTitle('AndroLua+')
--activity.setTheme(android.R.style.Theme_Holo_Light)
activity.setContentView(loadlayout(layout))

isRun=true
import "android.animation.ObjectAnimator"

--QQ2960586094，dingyi。
bst=function(b)
  local b=tointeger(b)
  mf.Text=tostring(tointeger(b).." dB")
  if b<=30 then
    mfq.Text="静谧之地，宜学习看书。"
   elseif b>30 and b<50 then
    mfq.Text="环境正常。"
   elseif b>=50 and b<=70 then
    mfq.Text="聒噪的环境。"
   elseif b>70 and b<100 then
    mfq.Text="喧嚣的环境，建议远离。"
   elseif b>=100 then
    mfq.Text="过度喧嚣的环境，建议马上远离。"
  end
end

function bsk()
  require "import"
  import "java.io.File"
  compile "libs/classes"
  import "me.daei.soundmeter.*"
  if not mRecorder then
    mRecorder=MyMediaRecorder()--创建录音对象
    file=FileUtil.createFile("temp.amr")--创建缓存录音
    file=File(tostring(file))
    mRecorder.setMyRecAudioFile(file);--设置缓存录音
   
    if not (mRecorder.startRecorder()) then--启动录音,返回布尔值
      print("启动失败 ")
    end

  end
  if activity.get("isRun")==false then
    mRecorder.delete()
    mRecorder=nil
    File("/storage/emulated/0/SoundMeter/temp.amr").delete()--删除缓存文件
  end
  while activity.get("isRun") do
    Thread.sleep(250)
    volume = mRecorder.getMaxAmplitude();--获取声压
    if(volume > 0 && volume < 1000000) then
      call("bst",World.setDbCount(20 * (Math.log10(volume)))); --//将声压值转为分贝值
    end
  end

end
thread(bsk)
function CircleButton(view,InsideColor,radiu)
  import "android.graphics.drawable.GradientDrawable"
  drawable = GradientDrawable()
  drawable.setShape(GradientDrawable.RECTANGLE)
  drawable.setColor(InsideColor)
  drawable.setCornerRadii({radiu,radiu,radiu,radiu,radiu,radiu,radiu,radiu});
  view.setBackgroundDrawable(drawable)
end
角度=500
控件id=background
控件颜色=0xFFAED8C0
CircleButton(控件id,控件颜色,角度)


function onKeyDown(code,event)
  if code==event.KEYCODE_BACK then
    isRun=false
    activity.finish()
    return true
  end
end






function onPause()
  isRun=false
  File("/storage/emulated/0/SoundMeter/temp.amr").delete()
end


function onDestroy()
  isRun=false
  File("/storage/emulated/0/SoundMeter/temp.amr").delete()
end
