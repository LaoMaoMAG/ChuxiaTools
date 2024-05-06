require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

activity.setContentView(loadlayout("layout"))



--灵感来自酷安傻屌应用:动能手电筒




import "android.content.Context"
import "android.hardware.Sensor"
import "android.hardware.SensorManager"
import "android.hardware.SensorEventListener"


--第三方闪光灯库
import "com.cx.flashlight.*"
flashLight = FlashLight.init(activity);

--SensorManager传感器管理类
mSensorManager = activity.getSystemService(Context.SENSOR_SERVICE)

--获取加速度传感器
mAccelerometerSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);


AccelerListener=SensorEventListener({
  onSensorChanged=function(event)

    type = event.sensor.getType();

    switch type
     case Sensor.TYPE_ACCELEROMETER

      values = event.values;

      x=values[0]
      y=values[1]
      z=values[2]

      if ((math.abs(x) > 17 || math.abs(y) > 17 || math.abs(z) > 17) && !isShake) then


        mVibrator = activity.getSystemService(Context.VIBRATOR_SERVICE);

        mVibrator.vibrate(long{ 0, 100 },-1);

        --打开闪光灯
        flashLight.open();


        --关闭闪光灯
        task(100,function()
          flashLight.close();
        end)


        isShake = false;

      end


    end
  end,


  --传感器精度发生变化
  onAccuracyChanged=function( sensor, accuracy)


  end

})



--[[
SENSOR_DELAY_FASTEST：最快，延迟最小。
SENSOR_DELAY_GAME：适合游戏的频率。
SENSOR_DELAY_NORMAL：正常频率
SENSOR_DELAY_UI：适合普通用户界面的频率。
]]


--传感器监听
mSensorManager.registerListener(AccelerListener,mAccelerometerSensor,SensorManager.SENSOR_DELAY_UI);


--活动暂停
function onPause()
  mSensorManager.unregisterListener(AccelerListener);
  flashLight.release()
end





