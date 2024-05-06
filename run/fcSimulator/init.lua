require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "layout"

activity.setTheme(android.R.style.Theme_Holo_Light)
activity.setContentView(loadlayout(layout))
activity.setRequestedOrientation(1)
-- 0横屏，1竖屏


activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
--取消全屏

--activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN)
--开启全屏

activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN) 
--隐藏状态栏
