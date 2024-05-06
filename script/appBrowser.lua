require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

local cjson = require "cjson"


local func = cjson.decode(...)


activity.setTheme(android.R.style.Theme_Material_Light_NoActionBar)
activity.setContentView(loadlayout("layout/appBrowser"))


-- 屏幕方向
if func.orientation == "vertical" then
  activity.setRequestedOrientation(1)
 elseif func.orientation == "horizontal" then
  activity.setRequestedOrientation(0)
end


--沉浸式状态栏(模拟版)
function immersive()
  import "android.content.Context"
  activity.getWindow().setStatusBarColor(0x00000000);
  activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
  local statusBarHeight = activity.getResources().getDimensionPixelSize(activity.getResources().getIdentifier("status_bar_height", "dimen", "android"))
  linearParams = statusBarLayout.getLayoutParams()
  linearParams.height =statusBarHeight
  statusBarLayout.setLayoutParams(linearParams)
end


-- 异形屏全屏
function fullScreen()
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
end


-- 屏幕模式
switch func.screen do
 case "full"
  fullScreen()
  statusBarLayout.setVisibility(View.GONE)
  titleBarLayout.setVisibility(View.GONE)
  bottomBarLayout.setVisibility(View.GONE)
end


-- 设置浏览器属性
local set = web.getSettings()
set.setJavaScriptEnabled(true)
set.setDomStorageEnabled(true)
set.setAllowFileAccess(true)
set.setAllowFileAccessFromFileURLs(true)
set.setAllowUniversalAccessFromFileURLs(true)


web.loadUrl(func.content)