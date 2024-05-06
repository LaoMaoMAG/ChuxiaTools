require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

--隐藏状态栏
activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
--导航栏
activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)

layout={
  LinearLayout,
  orientation="vertical",
  layout_width="fill",
  layout_height="fill",
  {
    LinearLayout,
    orientation="horizontal",
    layout_width="fill",
    layout_height="56dp",
    {
      TextView,
      layout_width="fill",
      layout_height="56dp",
      background="#FF00BCD5",
      elevation="3dp",
      Gravity="center|left",
      paddingLeft="40",
      textColor="#ffffff",
      textSize="20sp",
      text="请选择源语言",
    },
  },
  {
    ListView,
    layout_width="fill",
    layout_height="fill",
    id="list",
    dividerHeight="1",
  },
}


items={
  TextView,
  layout_width="fill",
  layout_height="60dp",
  Gravity="center|left",
  paddingLeft="40",
  textColor="#808080",
  textSize="15",
  id="name"
}

activity.setContentView(loadlayout(layout))

--去滑条
list.setVerticalScrollBarEnabled(false)

maxText={"自动检测","中文","英文","日文","韩文","法文","俄文","西班牙文"}


数据={}

for i=1,#maxText do
  table.insert(数据,{name=maxText[i]})
end

adp=LuaAdapter(activity,数据,items)
list.setAdapter(adp)

list.setOnItemClickListener(AdapterView.OnItemClickListener{
  onItemClick=function(parent,v,pos,id)
    activity.result{maxText[pos+1]}
    activity.finish()
  end
})






