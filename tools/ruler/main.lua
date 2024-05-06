require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

import "com.androlua.*"
import "android.graphics.*"



--仿一个木函尺子功能，代码有点乱。
--想做个吸附功能
--Androlua开源社区 836718237
function 全屏()
  window = activity.getWindow();
  window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN|View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
  window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
  xpcall(function()
    lp = window.getAttributes();
    lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
    window.setAttributes(lp);
    --设置底部虚拟按键沉浸透明
    activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
  end,
  function(e)
  end)
end
--使用该代码可能需要隐藏ActionBar

--调用示例
全屏()


--各种单位之间转换函数
function dpTopx(sdp)
  import "android.util.TypedValue"
  dm=this.getResources().getDisplayMetrics()
  types={px=0,dp=1,sp=2,pt=3,["in"]=4,mm=5}
  n,ty=sdp:match("^(%-?[%.%d]+)(%a%a)$")
  return TypedValue.applyDimension(types[ty],tonumber(n),dm)
end



mm=dpTopx("1mm")


activity.setContentView(loadlayout("layout"))



--横屏模式
activity.setRequestedOrientation(0);







myLuaDrawable=LuaDrawable(function(mCanvas,mPaint,mDrawable)

  --画笔属性
  mPaint.setColor(0xFF9C9A9D)
  mPaint.setAntiAlias(true)
  mPaint.setStrokeWidth(2)
  mPaint.setStyle(Paint.Style.FILL)
  mPaint.setStrokeCap(Paint.Cap.ROUND)
  mPaint.setTextSize(28)


  MaxPx=mDrawable.getBounds().right-30

  MaxMm=math.ceil(MaxPx/100)



  --mCanvas.drawColor(0xffffeeaa)




  for i=0,MaxMm*10 do

    if i%10==0 then

      mCanvas.drawLine(mm*i+mm,0,mm*i+mm,80,mPaint)


      mCanvas.drawText(tostring(math.modf(i/10)),(mm*i+mm)-mm/2 ,120, mPaint)

     elseif i%5==0 then

      mCanvas.drawLine(mm*i+mm,0,mm*i+mm,60,mPaint)

     else

      mCanvas.drawLine(mm*i+mm,0,mm*i+mm,40,mPaint)

    end

  end




end)



--绘制的Drawble设置成控件背景
tv.background=myLuaDrawable





tv2.onTouch=function(v,e)

  a=e.getAction()&255

  switch a

   case MotionEvent.ACTION_DOWN


   case MotionEvent.ACTION_MOVE

    moveX=e.getX()

    tv3.setTranslationX(moveX)

    --print("≈"..math.floor(moveX/mw).."mm")

    a=math.floor((moveX/mm)/10)

    --向上取整
    tv4.Text=tostring(math.floor((moveX/mm)/10))

    --向上取整
    tv5.Text=tostring(math.floor(moveX/mm)-a*10)


   case MotionEvent.ACTION_UP

  end

  return true
end





myLuaDrawable2=LuaDrawable(function(mCanvas,mPaint,mDrawable)

  --画笔属性
  mPaint.setColor(0xFF636562)
  mPaint.setAntiAlias(true)
  mPaint.setStrokeWidth(20)
  mPaint.setStyle(Paint.Style.STROKE)

  --mCanvas.drawColor(0xffffeeaa)

  mCanvas.drawCircle(150, 150, 100, mPaint);

  mPaint.setColor(0xFF9C9A9D)
  mPaint.setStyle(Paint.Style.FILL)

  mCanvas.drawCircle(150, 150, 90, mPaint);

end)



--绘制的Drawble设置成控件背景
tv4.background=myLuaDrawable2


myLuaDrawable3=LuaDrawable(function(mCanvas,mPaint,mDrawable)

  --画笔属性
  mPaint.setColor(0xFF434542)
  mPaint.setAntiAlias(true)
  mPaint.setStrokeWidth(20)
  mPaint.setStyle(Paint.Style.FILL)

  mCanvas.drawCircle(225, 225, 50, mPaint);

end)

tv5.background=myLuaDrawable3
