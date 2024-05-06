require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "http"

import "layout"
activity.setContentView(loadlayout(layout))


--隐藏状态栏
activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
--导航栏
activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)


--最好是单词翻译，句子翻译会不准确
--结果跟有道翻译官完全准确
--翻译类型tran_type
--[[
自动检       AUTO
中译英       ZH_CN2EN
中译日       ZH_CN2JA
中译韩       ZH_CN2KR
中译法       ZH_CN2FR
中译俄       ZH_CN2RU
中译西       ZH_CN2SP
]]

--这是本人(@yuxuan)独立做的翻译软件,用于自用
--接下来会继续完善其他翻译(百度翻译,搜狗翻译,谷歌翻译,文言文翻译,等其他翻译接口)
--代码仅作参考,如有bug，请自行修改


function 有道翻译(content,tran_type)
  edText = edit.Text:match"^%s*(.-)%s*$"
  if edText ~= "" then
    url="http://m.youdao.com/translate"
    data="inputtext="..content.."&type="..tran_type
    body,cookie,code,headers=http.post(url,data)
    for v in body:gmatch('<ul id="translateResult">(.-)</ul>') do
      v=v:match('<li>(.-)</li>')
      v=v:match"^%s*(.-)%s*$"
      return v
    end
   else
    result.Text = ""
    设置hint(result,12,"输入内容为空,请重新输入...")
  end
end


function 设置hint(id,size,str)
  import "android.text.Spanned"
  import "android.text.SpannableString"
  import "android.text.style.AbsoluteSizeSpan"
  s = SpannableString(str);
  textSize = AbsoluteSizeSpan(size,true);
  s.setSpan(textSize,0,s.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
  id.setHint(s);
end


function 提示(内容)
  ToastLayout={
    CardView;
    layout_height="50dp";
    cardElevation="0dp",
    {
      TextView;
      background="#FFFF005B";
      padding="8dp";
      textSize="15sp";
      TextColor="#ffffffff";
      gravity="center";
      text="提示出错";
      id="text";
    };
  };
  toast=Toast.makeText(activity,"内容",Toast.LENGTH_SHORT).setView(loadlayout(ToastLayout))
  text.Text=tostring(内容)
  toast.show()
end


function 检测内容是否为空(str,tran_type)
  conText = edit.Text:match"^%s*(.-)%s*$"
  if conText ~= "" then
    result.Text = 有道翻译(str,tran_type)
   else
    result.Text = ""
    设置hint(result,12,"输入内容为空,请重新输入...")
  end
end


function 复制文本(str)
  import "android.content.*"
  activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(str)
  提示("翻译内容已复制")
end


function 分享文本(str)
  import "android.content.Intent"
  intent = Intent(Intent.ACTION_SEND);
  intent.setType("text/plain");
  intent.putExtra(Intent.EXTRA_TEXT,str);
  activity.startActivityForResult(intent, 0)
end


function 翻译()
  a = source.getText()
  b = target.getText()

  if a=="自动检测" or b=="自动检测" then
    翻译类型="AUTO"
    检测内容是否为空(edit.Text,翻译类型)

   elseif a=="中文" and b=="英文" then
    翻译类型="ZH_CN2EN"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="中文" and b=="日文" then
    翻译类型="ZH_CN2JA"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="中文" and b=="韩文" then
    翻译类型="ZH_CN2KR"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="中文" and b=="法文" then
    翻译类型="ZH_CN2FR"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="中文" and b=="俄文" then
    翻译类型="ZH_CN2RU"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="中文" and b=="西班牙文" then
    翻译类型="ZH_CN2SP"
    检测内容是否为空(edit.Text,翻译类型)


   elseif a=="英文" and b=="中文" then
    翻译类型="EN2ZH_CN"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="日文" and b=="中文" then
    翻译类型="JA2ZH_CN"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="韩文" and b=="中文" then
    翻译类型="KR2ZH_CN"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="法文" and b=="中文" then
    翻译类型="FR2ZH_CN"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="俄文" and b=="中文" then
    翻译类型="RU2ZH_CN"
    检测内容是否为空(edit.Text,翻译类型)
   elseif a=="西班牙文" and b=="中文" then
    翻译类型="SP2ZH_CN"
    检测内容是否为空(edit.Text,翻译类型)

   elseif a=="日文" and b=="英文" then
    rel = 有道翻译(edit.Text,"JA2ZH_CN")
    翻译类型="ZH_CN2EN"
    检测内容是否为空(rel,翻译类型)
   elseif a=="日文" and b=="日文" then
    rel = 有道翻译(edit.Text,"JA2ZH_CN")
    翻译类型="ZH_CN2JA"
    检测内容是否为空(rel,翻译类型)
   elseif a=="日文" and b=="韩文" then
    rel = 有道翻译(edit.Text,"JA2ZH_CN")
    翻译类型="ZH_CN2KR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="日文" and b=="法文" then
    rel = 有道翻译(edit.Text,"JA2ZH_CN")
    翻译类型="ZH_CN2FR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="日文" and b=="俄文" then
    rel = 有道翻译(edit.Text,"JA2ZH_CN")
    翻译类型="ZH_CN2RU"
    检测内容是否为空(rel,翻译类型)
   elseif a=="日文" and b=="西班牙文" then
    rel = 有道翻译(edit.Text,"JA2ZH_CN")
    翻译类型="ZH_CN2SP"
    检测内容是否为空(rel,翻译类型)

   elseif a=="韩文" and b=="英文" then
    rel = 有道翻译(edit.Text,"KR2ZH_CN")
    翻译类型="ZH_CN2EN"
    检测内容是否为空(rel,翻译类型)
   elseif a=="韩文" and b=="日文" then
    rel = 有道翻译(edit.Text,"KR2ZH_CN")
    翻译类型="ZH_CN2JA"
    检测内容是否为空(rel,翻译类型)
   elseif a=="韩文" and b=="韩文" then
    rel = 有道翻译(edit.Text,"KR2ZH_CN")
    翻译类型="ZH_CN2KR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="韩文" and b=="法文" then
    rel = 有道翻译(edit.Text,"KR2ZH_CN")
    翻译类型="ZH_CN2FR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="韩文" and b=="俄文" then
    rel = 有道翻译(edit.Text,"KR2ZH_CN")
    翻译类型="ZH_CN2RU"
    检测内容是否为空(rel,翻译类型)
   elseif a=="韩文" and b=="西班牙文" then
    rel = 有道翻译(edit.Text,"KR2ZH_CN")
    翻译类型="ZH_CN2SP"
    检测内容是否为空(rel,翻译类型)


   elseif a=="法文" and b=="英文" then
    rel = 有道翻译(edit.Text,"FR2ZH_CN")
    翻译类型="ZH_CN2EN"
    检测内容是否为空(rel,翻译类型)
   elseif a=="法文" and b=="日文" then
    rel = 有道翻译(edit.Text,"FR2ZH_CN")
    翻译类型="ZH_CN2JA"
    检测内容是否为空(rel,翻译类型)
   elseif a=="法文" and b=="韩文" then
    rel = 有道翻译(edit.Text,"FR2ZH_CN")
    翻译类型="ZH_CN2KR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="法文" and b=="法文" then
    rel = 有道翻译(edit.Text,"FR2ZH_CN")
    翻译类型="ZH_CN2FR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="法文" and b=="俄文" then
    rel = 有道翻译(edit.Text,"FR2ZH_CN")
    翻译类型="ZH_CN2RU"
    检测内容是否为空(rel,翻译类型)
   elseif a=="法文" and b=="西班牙文" then
    rel = 有道翻译(edit.Text,"FR2ZH_CN")
    翻译类型="ZH_CN2SP"
    检测内容是否为空(rel,翻译类型)


   elseif a=="俄文" and b=="英文" then
    rel = 有道翻译(edit.Text,"RU2ZH_CN")
    翻译类型="ZH_CN2EN"
    检测内容是否为空(rel,翻译类型)
   elseif a=="俄文" and b=="日文" then
    rel = 有道翻译(edit.Text,"RU2ZH_CN")
    翻译类型="ZH_CN2JA"
    检测内容是否为空(rel,翻译类型)
   elseif a=="俄文" and b=="韩文" then
    rel = 有道翻译(edit.Text,"RU2ZH_CN")
    翻译类型="ZH_CN2KR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="俄文" and b=="法文" then
    rel = 有道翻译(edit.Text,"RU2ZH_CN")
    翻译类型="ZH_CN2FR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="俄文" and b=="俄文" then
    rel = 有道翻译(edit.Text,"RU2ZH_CN")
    翻译类型="ZH_CN2RU"
    检测内容是否为空(rel,翻译类型)
   elseif a=="俄文" and b=="西班牙文" then
    rel = 有道翻译(edit.Text,"RU2ZH_CN")
    翻译类型="ZH_CN2SP"
    检测内容是否为空(rel,翻译类型)

   elseif a=="西班牙文" and b=="英文" then
    rel = 有道翻译(edit.Text,"SP2ZH_CN")
    翻译类型="ZH_CN2EN"
    检测内容是否为空(rel,翻译类型)
   elseif a=="西班牙文" and b=="日文" then
    rel = 有道翻译(edit.Text,"SP2ZH_CN")
    翻译类型="ZH_CN2JA"
    检测内容是否为空(rel,翻译类型)
   elseif a=="西班牙文" and b=="韩文" then
    rel = 有道翻译(edit.Text,"SP2ZH_CN")
    翻译类型="ZH_CN2KR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="西班牙文" and b=="法文" then
    rel = 有道翻译(edit.Text,"SP2ZH_CN")
    翻译类型="ZH_CN2FR"
    检测内容是否为空(rel,翻译类型)
   elseif a=="西班牙文" and b=="俄文" then
    rel = 有道翻译(edit.Text,"SP2ZH_CN")
    翻译类型="ZH_CN2RU"
    检测内容是否为空(rel,翻译类型)
   elseif a=="西班牙文" and b=="西班牙文" then
    rel = 有道翻译(edit.Text,"SP2ZH_CN")
    翻译类型="ZH_CN2SP"
    检测内容是否为空(rel,翻译类型)
  end
end


设置hint(edit,12,"在此输入要翻译的文本...")

edit.addTextChangedListener{
  onTextChanged=function(s)
    翻译()
  end
}


copy.onClick=function()
  复制文本(result.Text)
end


conversion.onClick=function()
  c=target.getText()
  d=source.getText()

  source.setText(c)
  target.setText(d)
  翻译()
end


share.onClick=function()
  分享文本(result.Text)
end


FullScreen.onClick=function()
  activity.newActivity("FullScreen",{result.Text})
end


source.onClick=function()
  activity.newActivity("Source")
end


target.onClick=function()
  activity.newActivity("Target")
end


function onResult(name,...)
  返回参数=...
  if name=="Source" then
    source.setText(返回参数)
    翻译()
   elseif name=="Target" then
    target.setText(返回参数)
    翻译()
  end
end

