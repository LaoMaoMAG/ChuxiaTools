require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "com.nirenr.Color"
import "android.graphics.Color"
import "android.app.AlertDialog"
import "android.hardware.camera2.CameraManager"
import "android.hardware.SensorManager"
import "android.hardware.Sensor"
import "android.content.Context"
import "android.view.View"
import "android.widget.Switch"
import "android.hardware.SensorEventListener"
import "android.widget.FrameLayout"
import "android.widget.TextView"
import "android.widget.ScrollView"
import "android.widget.LinearLayout"
import "android.text.Html"
import "android.widget.ImageView"
import "android.view.*"

activity.setTheme(android.R.style.Theme_DeviceDefault_Light)--设置md主题
activity.ActionBar.hide()
--Copyright© Ayaka_Ago. All Rights Reserved.

import"android.hardware.SensorEventListener"
import"android.hardware.SensorManager"
import"android.hardware.Sensor"
import"android.hardware.camera2.CameraManager"
import"com.yuxuan.widget.WaveView"
--setOrientation(0)
local CameraManager=this.getSystemService(Context.CAMERA_SERVICE)--相机
local sensorManager=this.getSystemService(Context.SENSOR_SERVICE)--传感器
local lightSensor=sensorManager.getDefaultSensor(Sensor.TYPE_LIGHT)--光照
--DecorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
local isOn=false--手电筒是否打开
local maxStrength=0--记录最高亮度
local level=350--打开手电筒的最低亮度
local backTime=0--返回键计数
local finished=false--activity是否finish
local listenInBackground=true--后台是否仍然监听
--setTopBarIconColor(Color.WHITE)


this.setContentView(loadlayout({
  FrameLayout,
  layout_width="fill",
  layout_height="fill",
  {
    WaveView,
    layout_width="fill",
    layout_height="fill",
    id="light_bg",
    startColor=0xFF3B3B3B,
    closeColor=Color.DKGRAY,
    waveHeight="14dp",
    velocity=1.5,
  },
  {
    LinearLayout,
    layout_marginTop=状态栏高度,
    layout_height="52dp",
    {
      TextView,
      textSize="18dp",
      textColor=Color.WHITE,
      layout_height="fill",
      paddingLeft="16dp",
      paddingRight="8dp",
      text="光能手电筒",
      id="light_title",
      gravity="center|left",
    },
    {--标题旁边的问号
      ImageView,
      layout_width="52dp",
      layout_height="fill",
      padding="16dp",
      onClick=function()
        local d=AlertDialog.Builder(this)
        d.setView(loadlayout({
          ScrollView,
          layout_width="fill",
          layout_height=w,
          {
            LinearLayout,
            layout_width="fill",
            layout_height="fill",
            orientation="vertical",
            {
              TextView,
              text="光能手电筒",
              textSize="14dp",
              layout_width="fill",
              padding="24dp",
              textColor=次要文字色,
              gravity="left|center",
            },
            {
              TextView,
              text=Html.fromHtml("\t\t这是什么沙雕小程序？<br><br>\t\t使用方式：要开启手电筒，请<strong>将设备靠近光源</strong>（反之亦可）。若无光源或光线不足，则无法开启手电筒。此功能<strong>较为耗电</strong>。<br><br>\t\t注：光线传感器通常在<strong>设备正面</strong>。<br>\t\tps：靠近光源且手电筒亮起后，可使用镜子反光保持亮起。"),
              textSize="16dp",
              layout_width="fill",
              textColor=文字色,
              gravity="left|center",
              padding="24dp",
              paddingTop=0,
            },
            {
              FrameLayout,
              padding="24dp",
              layout_width="fill",
              paddingTop=0,
              {
                TextView,
                text="光线传感器数据",
                textSize="14dp",
                layout_width="fill",
                textColor=次要文字色,
                gravity="left|center",
              },
              {
                TextView,
                id="light_maxstr",
                textSize="14dp",
                text="最高记录亮度 "..maxStrength,
                layout_width="fill",
                textColor=次要文字色,
                gravity="right|center",
              },
            },
            {
              LinearLayout,
              layout_width="fill",
              {
                LinearLayout,
                layout_weight=1,
                gravity="center",
                orientation="vertical",
                {
                  TextView,
                  id="info_st",
                  textSize="16dp",
                  text="0",
                  textColor=文字色,
                },
                {
                  TextView,
                  text="亮度",
                  textSize="14dp",
                  textColor=次要文字色,
                },
              },
              {
                LinearLayout,
                layout_weight=1,
                gravity="center",
                orientation="vertical",
                {
                  TextView,
                  id="info_ac",
                  textSize="16dp",
                  textColor=文字色,
                  text="3",
                },
                {
                  TextView,
                  text="精度",
                  textSize="14dp",
                  textColor=次要文字色,
                },
              },
            },
            {
              TextView,
              text=Html.fromHtml("\t\t最低要求的亮度为<strong>"..level.."</strong>。"),
              textSize="16dp",
              padding="24dp",
              paddingBottom=0,
              textColor=文字色,
              layout_width="fill",
            },
          },
        }))
        d.setPositiveButton("知道了",nil)
        local s=d.show()
        local win=s.getWindow()
        --win.setWindowAnimations(R.BottomDialog_Animation)
        --win.setGravity(Gravity.BOTTOM)
        win.setDimAmount(0.5)
      --  win.setBackgroundDrawable(圆角(nil,背景遮挡色))
        --[[local lp=win.getAttributes()
lp.width=w
win.setAttributes(lp)]]
      end,
     -- foreground=波纹(0x40000000),
      src="drawable/help_circle.png",
      id="light_question",
      colorFilter=Color.WHITE,
    },
  },
  {--屏幕中央的lightbulb
    ImageView,
    id="light_btn",
    layout_width="96dp",
    layout_gravity="center",
    colorFilter=Color.WHITE,
    src="drawable/lightbulb_outline.png",
    layout_height="96dp",
    layout_marginBottom="24dp",
  },
  {
    LinearLayout,
    orientation="vertical",
    layout_marginBottom="52dp",
    layout_width="fill",
    gravity="center",
    layout_gravity="bottom|center",
    {
      FrameLayout,
      paddingLeft="24dp",
      layout_width="fill",
      paddingRight="24dp",
      {
        TextView,
        text="后台保持传感器监听",
        textSize="14dp",
        layout_gravity="left|center",
        textColor=Color.LTGRAY,
        id="light_backgroundkeep",
      },
      {
        Switch,
        onCheckedChangeListener={
          onCheckedChanged=function(v,c)
            listenInBackground=c
          end},
        layout_gravity="right|center",
        id="light_switch",
      },
    },
    {
      TextView,
      layout_marginTop="16dp",
      textSize="14dp",
      textColor=Color.LTGRAY,
      gravity="center",
      text="光线传感器已开启",
      id="service_state",
    },
  },
}))

light_switch.setChecked(true)--启用后台监听

if lightSensor then--有这个传感器

  function toggleLight(bool)
    pcall(function()CameraManager.setTorchMode("0",bool)end)
    if bool then--开启
      --setTopBarIconColor(Color.BLACK)
      DecorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN|View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR)
      light_bg.setStartColor(Color.WHITE).setCloseColor(Color.LTGRAY)
      light_title.setTextColor(Color.BLACK)
      light_question.setColorFilter(Color.BLACK)
      light_btn.setImageBitmap(loadbitmap("drawable/lightbulb.png")).setColorFilter(Color.BLACK)
      service_state.setTextColor(Color.DKGRAY)
      light_backgroundkeep.setTextColor(Color.DKGRAY)
     else
      setTopBarIconColor(Color.WHITE)
      DecorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN|View.SYSTEM_UI_FLAG_VISIBLE)
      light_bg.setStartColor(0xFF3B3B3B).setCloseColor(Color.DKGRAY)
      light_btn.setImageBitmap(loadbitmap("drawable/lightbulb_outline.png")).setColorFilter(Color.WHITE)
      light_question.setColorFilter(Color.WHITE)
      light_title.setTextColor(Color.WHITE)
      service_state.setTextColor(Color.LTGRAY)
      light_backgroundkeep.setTextColor(Color.LTGRAY)
    end
  end

  function onResume()
    if not listener then
      listener=SensorEventListener({
        onSensorChanged=function(event)
          infoChanged=true
          local ac=tostring(event.accuracy)--精度
          local st=tonumber(string.format("%.f",event.values[0]))--亮度
          pcall(function()
            info_ac.setText(ac)
            info_st.setText(tostring(st))
          end)
          if st>maxStrength then
            maxStrength=st
            pcall(function()light_maxstr.setText("最高记录亮度 "..maxStrength)end)
          end
          if st>level then
            if not isOn then
              isOn=true
              toggleLight(isOn)
            end
           else
            if isOn then
              isOn=false
              toggleLight(isOn)
            end
          end
        end})
      sensorManager.registerListener(listener,lightSensor,SensorManager.SENSOR_DELAY_FASTEST)
      service_state.setText("光线传感器已开启")
    end
    light_bg.start()
  end

  function onPause()
    if listener and not listenInBackground then
      sensorManager.unregisterListener(listener)
      --unregister的时候会销毁listener
      service_state.setText("光线传感器已关闭")
      listener=nil
     elseif not finished then
      --toast("光能手电筒持续运行中")
    end
    light_bg.stop()
  end

  function onDestroy()
    if listener then
      sensorManager.unregisterListener(listener)
      --unregister的时候会销毁listener
      service_state.setText("光线传感器已关闭")
      listener=nil
    end
  end

  task(1000,function()
    if not infoChnaged then
      onResume()
    end
  end)

 else--没这个传感器
  this.finish()
  toast("您的设备不支持此功能")
end

function onKeyDown(k)
  if k==4 then--返回键事件
    finished=true
    this.finish()
    --end
    return true
  end
end