require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.graphics.Typeface"
import "java.io.File"
import "android.graphics.BitmapFactory"
import "android.view.animation.DecelerateInterpolator"
import "android.view.animation.Animation"
import "android.animation.ObjectAnimator"

local luajava = require("luajava")

compile "libs/kuanAnimation"
import "com.wuyr.rippleanimation.*"

local db = require "db"
local config = require "config"


activity.setTheme(android.R.style.Theme_Material_Light_NoActionBar)
activity.setContentView(loadlayout("layout/logo"))


--沉浸式状态栏
import "android.content.Context"
activity.getWindow().setStatusBarColor(0x00000000);
activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)


--异形屏全屏
window = activity.getWindow();
window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN|View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
xpcall(function()
  lp = window.getAttributes();
  lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
  window.setAttributes(lp);
end,
function(e)
end)


-- 设置控件不可见
panel1.setVisibility(View.INVISIBLE)
panel2.setVisibility(View.INVISIBLE)
panel3.setVisibility(View.INVISIBLE)


-- 加载字体
local typeface1 = Typeface.createFromFile(File(activity.getLuaDir().."/res/font/alibaba-pu-hui-ti.ttf"))
local typeface2 = Typeface.createFromFile(File(activity.getLuaDir().."/res/font/harmony-os-sans.ttf"))


--设置粗体
nameText.getPaint().setTypeface(typeface1)
versionText.getPaint().setTypeface(typeface1)


versionText.setText(config.appver)


-- 显示轮播Logo图片
local datadb = db.open(config.filePath.dbFile)
if not datadb:has("logo") then datadb:set("logo", 0) end
if config.logoTable[datadb:get("logo") + 1] == nil then
  datadb:set("logo", 1)
 else
  datadb:set("logo", datadb:get("logo") + 1)
end
image.setImageBitmap(loadbitmap(config.logoTable[datadb:get("logo")]))
datadb:close()


--波纹动画
task(1,function()
  RippleAnimation.create(rippleLayout).setDuration(1000).start();
  bottomLayout.setBackgroundColor(0xFFFFFFFF)
end)


--延时进入
task(4500,function()
  --第2个参数是淡入动画
  activity.newActivity("script/home.lua", android.R.anim.fade_in,android.R.anim.fade_out)
  activity.finish()
end)


-- 动画
task(1000,function()
  -- 设置控件可见
  panel1.setVisibility(View.VISIBLE)
  panel2.setVisibility(View.VISIBLE)
  panel3.setVisibility(View.VISIBLE)

  local location = luajava.newArray(int, 2)

  -- 顶部1Y轴
  waveTopImage1.getLocationInWindow(location)
  local top1Y = location[1]

  -- 顶部2Y轴
  waveTopImage2.getLocationInWindow(location)
  local top2Y = location[1]

  -- 底部1Y轴
  waveBottomImage1.getLocationInWindow(location)
  local bottom1Y = location[1]

  -- 底部2Y轴
  waveBottomImage2.getLocationInWindow(location)
  local bottom2Y = location[1]

  --名称文本y轴
  nameText.getLocationInWindow(location)
  local nameTextY = location[1]

  --版本文本y轴
  versionText.getLocationInWindow(location)
  local versionTextY = location[1]

  local animator1 = ObjectAnimator.ofFloat(waveTopImage1, "Y",{top1Y - 300, top1Y})
  animator1.setInterpolator(DecelerateInterpolator())--动画插值器,具体取值看下方
  animator1.setDuration(4000)--动画时间
  animator1.start()--动画开始

  local animator2 = ObjectAnimator.ofFloat(waveTopImage2, "Y",{top2Y - 300, top2Y})
  animator2.setInterpolator(DecelerateInterpolator())--动画插值器,具体取值看下方
  animator2.setDuration(3000)--动画时间
  animator2.start()--动画开始


  local animator3 = ObjectAnimator.ofFloat(waveBottomImage1, "Y",{bottom1Y + 300, bottom1Y})
  animator3.setInterpolator(DecelerateInterpolator())--动画插值器,具体取值看下方
  animator3.setDuration(4000)--动画时间
  animator3.start()--动画开始

  local animator4 = ObjectAnimator.ofFloat(waveBottomImage2, "Y",{bottom2Y + 300, bottom2Y})
  animator4.setInterpolator(DecelerateInterpolator())--动画插值器,具体取值看下方
  animator4.setDuration(3000)--动画时间
  animator4.start()--动画开始

  local animator5 = ObjectAnimator.ofFloat(imageCard, "scaleX", {0, 1})
  animator5.setDuration(2500)--设置动画时间
  animator5.setInterpolator(DecelerateInterpolator());--设置动画插值器
  animator5.start();--开始动画

  local animator6 = ObjectAnimator.ofFloat(imageCard, "scaleY", {0, 1})
  animator6.setDuration(2500)--设置动画时间
  animator6.setInterpolator(DecelerateInterpolator());--设置动画插值器
  animator6.start();--开始动画

  local animator7 = ObjectAnimator.ofFloat(nameText, "alpha", {0, 1})
  animator7.setDuration(4000)--设置动画时间
  animator7.start()--启动动画。

  local animator8 = ObjectAnimator.ofFloat(versionText, "alpha", {0, 1})
  animator8.setDuration(4000)--设置动画时间
  animator8.start()--启动动画。

  local animator9 = ObjectAnimator.ofFloat(nameText, "Y",{nameTextY + 300, nameTextY})
  animator9.setInterpolator(DecelerateInterpolator())--动画插值器,具体取值看下方
  animator9.setDuration(3000)--动画时间
  animator9.start()--动画开始

  local animator10 = ObjectAnimator.ofFloat(versionText, "Y",{versionTextY + 300, versionTextY})
  animator10.setInterpolator(DecelerateInterpolator())--动画插值器,具体取值看下方
  animator10.setDuration(3500)--动画时间
  animator10.start()--动画开始
end)

