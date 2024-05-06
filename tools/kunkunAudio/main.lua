require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.media.*"
import "layout"

activity.setTheme(android.R.style.Theme_Material)
activity.setContentView(loadlayout(layout))

local list={{{'j','鸡'},{'n','你'},{'t','太'},{'m','美'},{'c','唱'},{'t0','跳'},{'rp','rap'},{'lq','篮球'},{'mck','music'},{'xs','笑死'},{'whh','哇呵呵'},{'xh','喜欢'},{'qm','制作人'},{'djh','大家好'},{'ws','我是'},{'kk','鲲鲲'},{'ngm','你干嘛~'},{'hh','哈哈'},{'ay','哎哟'},{'nhf','你好烦~'},{'jntm','开始吟唱'},{'ngmhhy','你干嘛哈哈哟'},{'yhhmgn','哟哈哈嘛干你'}},{{'esj','二手鸡'},{'rup','rap鸡'},{'djj','DJ鸡'},{'xxj','谢谢鸡'},{'jhj','惊魂鸡'},{'xjj','仙剑鸡'},{'xnj','新年鸡'},{'zdj','战斗鸡'},{'thj','桃花鸡'},{'mrj','某人鸡'},{'jnj','江南鸡'},{'jjj','尖叫鸡'},{'bbj','baby鸡'},{'hxj','欢喜鸡'},{'yyj','耶耶鸡'},{'jtm','鸡太美'}}}

local sp=SoundPool(8,AudioManager.STREAM_MUSIC,0)

for k,v ipairs(list[1])
  v[3]=sp.load(luajava.luadir..'/res/'..v[1]..'.mp3',k)
end

local data={}

local item={
  Button;
  id="btn";
}

--sp.play(list[8][3],1,1,1,0,1)

local adp=LuaAdapter(this,data,item)

grid.setAdapter(adp)


for k,v ipairs(list[1])
  adp.add{
    btn={
      text=v[2],
      onClick=function()
        sp.play(v[3],1,1,1,0,1)
      end
    }
  }
end

local mp=MediaPlayer()

mp.setOnPreparedListener{
  onPrepared=function(mp)
    mp.start()
end}

for k,v ipairs(list[2])
  adp.add{
    btn={
      text=v[2],
      onClick=function()
        mp.reset()
        mp.setDataSource(luajava.luadir..'/res/'..v[1]..'.mp3')
        mp.prepare()
      end
    }
  }
end

function stop.onClick()
  for k,v ipairs(list[1])
    sp.stop(v[3])
  end
  mp.stop()
end