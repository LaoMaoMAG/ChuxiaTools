require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.graphics.Typeface"
import "java.io.File"
import "android.view.animation.DecelerateInterpolator"
import "android.view.animation.Animation"
import "android.animation.ObjectAnimator"
import "android.view.animation.Animation$AnimationListener"

local cjson = require "cjson"
local config = require "config"
local db = require "db"


activity.setTheme(android.R.style.Theme_Material_Light_NoActionBar)
activity.setContentView(loadlayout("layout/home"))


--沉浸式状态栏(模拟版)
import "android.content.Context"
activity.getWindow().setStatusBarColor(0x00000000);
activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
local statusBarHeight = activity.getResources().getDimensionPixelSize(activity.getResources().getIdentifier("status_bar_height", "dimen", "android"))
linearParams = statusBarLayout.getLayoutParams()
linearParams.height =statusBarHeight
statusBarLayout.setLayoutParams(linearParams)


-- 加载字体
local typeface1 = Typeface.createFromFile(File(activity.getLuaDir().."/res/font/alibaba-pu-hui-ti.ttf"))
local typeface2 = Typeface.createFromFile(File(activity.getLuaDir().."/res/font/harmony-os-sans.ttf"))


--滑动窗体适配器
local adp=ArrayPageAdapter()
page.setAdapter(adp)
adp.add(loadlayout("layout/tools"))
adp.add(loadlayout("layout/collection"))
adp.add(loadlayout("layout/about"))


--设置粗体
titleText.getPaint().setTypeface(typeface1)
title2Text.getPaint().setTypeface(typeface2)
toolsButtonText.getPaint().setTypeface(typeface1)
collectionButtonText.getPaint().setTypeface(typeface1)
aboutButtonText.getPaint().setTypeface(typeface1)
nameText.getPaint().setTypeface(typeface1)
versionText.getPaint().setTypeface(typeface1)
introductionText.getPaint().setTypeface(typeface2)
aboutBottomTipText.getPaint().setTypeface(typeface2)
developerText.getPaint().setTypeface(typeface1)
developerNameText1.getPaint().setTypeface(typeface1)
developerNameText2.getPaint().setTypeface(typeface1)
developerEnNameText1.getPaint().setTypeface(typeface2)
developerEnNameText2.getPaint().setTypeface(typeface2)
developerLabelText1.getPaint().setTypeface(typeface2)
developerLabelText2.getPaint().setTypeface(typeface2)
chatButtonText.getPaint().setTypeface(typeface2)
rewardButtonText.getPaint().setTypeface(typeface2)
shareButtonText.getPaint().setTypeface(typeface2)
toolsBottomTipText.getPaint().setTypeface(typeface2)
collectionTipText.getPaint().setTypeface(typeface2)


versionText.setText(config.appver)


local pageInit = false
local pageIndex = 0
local setPageButton = function (index)
  if index == pageIndex and pageInit then return end
  pageInit = true
  local color1 = 0xFFFFFFFF;
  local color2 = 0xFFA0A0A0;
  local location = luajava.newArray(int, 2)
  local x1, x2

  local getView = function (indexs)
    if indexs == 0 then
      return toolsButton
     elseif indexs == 1 then
      return collectionButton
     elseif indexs == 2 then
      return aboutButton
    end
    return nil
  end

  toolsButtonText.setTextColor(color2)
  collectionButtonText.setTextColor(color2)
  aboutButtonText.setTextColor(color2)

  toolsButtonImage.setImageBitmap(loadbitmap("res/image/icons8-tools0.png"))
  collectionButtonImage.setImageBitmap(loadbitmap("res/image/icons8-collection0.png"))
  aboutButtonImage.setImageBitmap(loadbitmap("res/image/icons8-about0.png"))

  if index == 0 then
    titleText.setText("工具 Tools.")
    toolsButtonText.setTextColor(color1)
    toolsButtonImage.setImageBitmap(loadbitmap("res/image/icons8-tools1.png"))
   elseif index == 1 then
    titleText.setText("收藏 Collection.")
    collectionButtonText.setTextColor(color1)
    collectionButtonImage.setImageBitmap(loadbitmap("res/image/icons8-collection1.png"))
   elseif index == 2 then
    titleText.setText("关于 About.")
    aboutButtonText.setTextColor(color1)
    aboutButtonImage.setImageBitmap(loadbitmap("res/image/icons8-about1.png"))
  end

  task(1,function()
    getView(pageIndex).getLocationInWindow(location)
    x1 = location[0]
    getView(index).getLocationInWindow(location)
    x2 = location[0]

    local animator = ObjectAnimator.ofFloat(pageButtonCard, "X",{x1, x2})
    animator.setDuration(300)--动画时间
    animator.start()--动画开始

    pageIndex = index
  end)
end


-- 设置logo图像
local datadb = db.open(config.filePath.dbFile)
if not datadb:has("logo") then datadb:set("logo", 1) end
logoImage.setImageBitmap(loadbitmap(config.logoTable[datadb:get("logo")]))
datadb:close()


-- 单击logo图像事件
logoImage.onClick = function(v)
  local datadb = db.open(config.filePath.dbFile)
  if not datadb:has("logo") then datadb:set("logo", 1) end
  if config.logoTable[datadb:get("logo") + 1] == nil then
    datadb:set("logo", 1)
   else
    datadb:set("logo", datadb:get("logo") + 1)
  end
  logoImage.setImageBitmap(loadbitmap(config.logoTable[datadb:get("logo")]))
  datadb:close()
end


--单击工具按钮事件
toolsButton.onClick = function ()
  page.setCurrentItem(0,true)
end


--单击收藏按钮事件
collectionButton.onClick = function ()
  page.setCurrentItem(1,true)
end


--单击关于按事件
aboutButton.onClick = function ()
  page.setCurrentItem(2,true)
end


--窗体滑动事件，手册里的是错的
page.setOnPageChangeListener(PageView.OnPageChangeListener{
  onPageScrolled = function(position, positionOffset, positionOffsetPixels)
    -- 页面滑动时调用，如果需要的话
  end,
  onPageSelected = function(position)
    -- 页面被选中时调用
    setPageButton(position)
  end
})


-- 自适应列表高度
-- list:列表ID adp:适配器对象 totalHeight: 分隔线高度 numColumns:单行数量
-- totalHeight:默认0 numColumns:默认1
local function adaptiveListHeight(list, adp, totalHeight, numColumns)
  import "android.content.Context"

  if totalHeight == nil then totalHeight = 0 end
  if numColumns == nil then numColumns = 1 end

  function get_size(view)
    view.measure(View.MeasureSpec.makeMeasureSpec(0,View.MeasureSpec.UNSPECIFIED),View.MeasureSpec.makeMeasureSpec(0,View.MeasureSpec.UNSPECIFIED));
    local height =view.getMeasuredHeight();
    local width =view.getMeasuredWidth();
    return width,height
  end

  local listItem
  local listW,listH
  local iNumColumns = numColumns
  for i = 1,adp.getCount() do
    if iNumColumns ~= numColumns then
      if iNumColumns == 0 then
        iNumColumns = numColumns
       else
        iNumColumns = iNumColumns - 1
        continue
      end
    end
    iNumColumns = iNumColumns - 1
    listItem = adp.getView(i,nil,list)
    listW,listH = get_size(listItem)
    totalHeight = totalHeight + listH
  end

  local linearParams = list.getLayoutParams()
  linearParams.height =totalHeight
  list.setLayoutParams(linearParams)
end


--网格布局
local gridLayout=
{
  LinearLayout;
  layout_height="fill";
  orientation="vertical";
  layout_width="fill";
  {
    LinearLayout;
    id="typeLayout";
    layout_marginRight="5dp";
    layout_marginTop="5dp";
    layout_marginLeft="5dp";
    layout_marginBottom="5dp";
    layout_width="match_parent";
    orientation="horizontal";
    layout_height="35dp";
    gravity="left|center";
    {
      ImageView;
      layout_height="30dp";
      src="res/image/function.png";
      id="typeImage";
      layout_width="30dp";
    };
    {
      TextView;
      text="分类名称";
      id="typeNameText";
      layout_marginLeft="2dp";
      textColor="0xFF000000";
      Typeface = typeface1;
      textSize="18";
    };
  };
  {
    CardView;
    layout_marginRight="5dp";
    elevation="5";
    id="toolsLayout";
    radius="6dp";
    layout_gravity="center";
    layout_height="100dp";
    CardBackgroundColor="0xFFFFFFFF";
    layout_width="match_parent";
    layout_marginLeft="5dp";
    layout_marginTop="5dp";
    layout_marginBottom="5dp";
    {
      LinearLayout;
      layout_marginRight="10dp";
      layout_marginTop="10dp";
      layout_marginLeft="10dp";
      layout_marginBottom="10dp";
      layout_width="match_parent";
      orientation="vertical";
      layout_height="match_parent";
      {
        LinearLayout;
        gravity="left|center";
        orientation="horizontal";
        layout_width="match_parent";
        {
          ImageView;
          layout_height="45dp";
          src="res/image/function.png";
          id="toolsImage";
          layout_width="45dp";
        };
        {
          TextView;
          text="工具名称";
          id="toolsNameText";
          layout_marginLeft="5dp";
          textColor="0xFF000000";
          Typeface = typeface2;
          textSize="18";
        };
      };
      {
        TextView;
        text="工具的介绍...";
        layout_marginTop="2dp";
        id="toolsContText";
        layout_width="match_parent";
        layout_height="match_parent";
        Typeface = typeface2;
        textSize="14";
      };
    };
  };
};

--网格布局项目
local gridItem= require("script/toolsTable")

--网格布局适配器
gridData={}--数据
gridAdp=LuaAdapter(activity,gridData,gridLayout)
grid.Adapter=gridAdp

for key, value in pairs(gridItem) do
  if value.id ~= "default" then
    gridAdp.add
    {
      typeLayout = { visibility=0 };
      toolsLayout = { visibility=8 };
      typeNameText = value.name;
      typeImage = value.icon;
    }
    gridAdp.add
    {
      typeLayout = { visibility=4 };
      toolsLayout = { visibility=8 };
    }
  end
  local i = 0
  for keys, values in pairs(value.data) do
    i = i + 1
    gridAdp.add
    {
      typeLayout = { visibility=8 };
      toolsLayout =
      {
        visibility=0;
        onClick = function ()
          if values.func == nil then return end
          switch (values.func.type)
           case "newActivity"
            activity.newActivity(values.func.content)
           case "appBrowser"
            activity.newActivity("script/appBrowser", {cjson.encode(values.func)})
          end
        end;
        onLongClick = function ()

        end;
      };
      toolsNameText = values.name;
      toolsImage = values.icon;
      toolsContText = values.text;
    }
  end
  if i % 2 ~= 0 then
    gridAdp.add
    {
      typeLayout = { visibility=8 };
      toolsLayout = { visibility=4 };
    }
  end
end

adaptiveListHeight(grid, gridAdp, 0, 2)
task(1,function()
  toolsScroll.fullScroll(ScrollView.FOCUS_UP)
end)

local toolsTypeListLayout =
{
  LinearLayout;
  layout_height="match_parent";
  orientation="vertical";
  layout_width="match_parent";
  gravity="center";
  {
    CardView;
    layout_height="30dp";
    radius="20dp";
    layout_marginRight="5dp";
    CardBackgroundColor="#A5D6A7";
    layout_width="wrap_content";
    layout_marginLeft="5dp";
    {
      LinearLayout;
      layout_height="match_parent";
      gravity="center";
      {
        TextView;
        id = "text";
        layout_marginLeft="10dp";
        textColor="0xFFFFFFFF";
        textSize="15";
        layout_marginRight="10dp";
        text="分类文本";
        Typeface = typeface2;
      };
    };
  };
};


local toolsTypeListData={}--数据
toolsTypeListAdp=LuaAdapter(activity,toolsTypeListData,toolsTypeListLayout)
toolsTypeList.Adapter=toolsTypeListAdp

for key, value in pairs(gridItem) do
  toolsTypeListAdp.add
  {
    text = value.name;
  }
end


-- 设置背景图像
local datadb = db.open(config.filePath.dbFile)
if not datadb:has("back") then datadb:set("back", 0) end
if config.logoTable[datadb:get("back") + 1] == nil then
  datadb:set("back", 1)
 else
  datadb:set("back", datadb:get("back") + 1)
end
backImage.setImageBitmap(loadbitmap(config.backTable[datadb:get("back")]))
datadb:close()


-- 下拉刷新背景
imagePulling.onRefresh=function(v)
  local datadb = db.open(config.filePath.dbFile)
  if not datadb:has("back") then datadb:set("back", 1) end
  if config.backTable[datadb:get("back") + 1] == nil then
    datadb:set("back", 1)
   else
    datadb:set("back", datadb:get("back") + 1)
  end
  backImage.setImageBitmap(loadbitmap(config.backTable[datadb:get("back")]))
  datadb:close()
  v.refreshFinish(0)
end


-- 打开数据库
local datadb = db.open({
  path = config.filePath.dbFile,
  can_each = true -- 开启遍历支持
})


-- 更新收藏表
updateCollectionTable = function ()
  -- 判断是否隐藏收藏空提示
  if datadb:has("collectionTable") == nil then
    collectionLayout.setVisibility(View.VISIBLE)
   else
    collectionLayout.setVisibility(View.GONE)
  end

  if datadb:has("collectionTable") then datadb:close() return end

  for key, value in collectionTable do
    print(key, value)
  end

  -- 关闭数据库
  datadb:close()
end

