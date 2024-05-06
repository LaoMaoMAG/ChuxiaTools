local require = require
local luajava = luajava
local type=type
local table = require "table"
local loaded = {}
local imported = {}
luajava.loaded = loaded
luajava.imported = imported
local _G = _G
local insert = table.insert
local new = luajava.new
local bindClass = luajava.bindClass
local dexes = {}
local _M = {}
local luacontext = activity or service
dexes = luajava.astable(luacontext.getClassLoaders())
local libs = luacontext.getLibrarys()


--添加新路径
local newPath = ";/" .. activity.getLuaDir() .."lua/?.lua;" .. activity.getLuaDir() .. "/lua/?/init.lua"
package.path = package.path .. newPath


local function libsloader(path)
  local p = libs[path:match("^%a+")]
  if p then
    return assert(package.loadlib(p, "luaopen_" .. (path:gsub("%.", "_")))), p
   else
    return "\n\tno file ./libs/lib" .. path .. ".so"
  end
end

table.insert(package.searchers, libsloader)

local function massage_classname(classname)
  if classname:find('_') then
    classname = classname:gsub('_', '$')
  end
  return classname
end

local function bind_class(packagename)
  local res, class = pcall(bindClass, packagename)
  if res then
    loaded[packagename] = class
    return class
  end
end

local function import_class(packagename)
  packagename = massage_classname(packagename)
  local class = loaded[packagename] or bind_class(packagename)
  return class
end

local function bind_dex_class(packagename)
  packagename = massage_classname(packagename)
  for _, dex in ipairs(dexes) do
    local res, class = pcall(dex.loadClass, packagename)
    if res then
      loaded[packagename] = class
      return class
    end
  end
end

local function import_dex_class(packagename)
  packagename = massage_classname(packagename)
  local class = loaded[packagename] or bind_dex_class(packagename)
  return class
end

local pkgMT = {
  __index = function(T, classname)
    local ret, class = pcall(luajava.bindClass, rawget(T, "__name") .. classname)
    if ret then
      rawset(T, classname, class)
      return class
     else
      error(classname .. " is not in " .. rawget(T, "__name"), 2)
    end
  end
}

local function import_pacckage(packagename)
  local pkg = { __name = packagename }
  setmetatable(pkg, pkgMT)
  return pkg
end


--setmetatable(_G, globalMT)
local function import_require(name)
  local s, r = pcall(require, name)
  if not s and not r:find("no file") then
    error(r, 0)
  end
  return s and r
end

local function append(t, v)
  for _, _v in ipairs(t) do
    if _v == v then
      return
    end
  end
  insert(t, v)
end



local function local_import(_env, packages, package)

  local o = package:find('^./')
  if o then
    local ro=string.gsub(package,"%./","/")
    return dofile(activity.getLuaDir()..ro)
  end

  local j = package:find(':')
  if j then
    local dexname = package:sub(1, j - 1)
    local classname = package:sub(j + 1, -1)
    local class = luacontext.loadDex(dexname).loadClass(classname)
    local classname = package:match('([^%.$]+)$')
    _env[classname] = class
    append(imported, package)
    return class
  end
  local i = package:find('%*$')
  if i then -- a wildcard; put into the package list, including the final '.'
    append(packages, package:sub(1, -2))
    append(imported, package)
    return import_pacckage(package:sub(1, -2))
   else
    local classname = package:match('([^%.$]+)$')
    local class = import_require(package) or import_class(package) or import_dex_class(package)
    if class then
      if class ~= true then
        --findtable(package)=class
        if type(class) ~= "table" then
          append(imported, package)
        end
        _env[classname] = class
      end
      return class
     else
      if pcall(function()
          if activity.Import(package)=="Cannot find class" then
            error("cannot find " .. package, 2)
          end
        end)
       else
        error("cannot find " .. package, 2)
      end
    end
  end
end




local function env_import(env)
  local _env = env or {}
  local packages = {}
  local loaders = {}
  append(packages, '')
  append(packages, 'java.lang.')
  append(packages, 'java.util.')
  append(packages, 'com.androlua.')

  pcall(function()
    append(packages, 'com.x5.WebView.')
    append(packages, 'com.myren.wave.')
  end)
  --检查完毕

  local function import_1(classname)
    for i, p in ipairs(packages) do
      local class = import_class(p .. classname)
      if class then
        return class
      end
    end
  end

  local function import_2(classname)
    for _, p in ipairs(packages) do
      local class = import_dex_class(p .. classname)
      if class then
        return class
      end
    end
  end

  append(loaders, import_1)
  append(loaders, import_2)

  local globalMT = {
    __index = function(T, classname)
      for i, p in ipairs(loaders) do
        local class = loaded[classname] or p(classname)
        if class then
          T[classname] = class
          return class
        end
      end
      return nil
    end
  }

  if type(_env)=="string" then
    return globalMT.__index({},_env)
  end

  setmetatable(_env, globalMT)
  for k, v in pairs(_M) do
    _env[k] = v
  end

  local import = function(package, env)
    env = env or _env
    if type(package) == "string" then
      return local_import(env, packages, package)
     elseif type(package) == "table" then
      local ret = {}
      for k, v in ipairs(package) do
        ret[k] = local_import(env, packages, v)
      end
      return ret
    end
  end

  _env.import = import
  import("loadlayout", _env)
  import("loadbitmap", _env)
  import("loadmenu", _env)
  return _env
end



function _M.compile(name)
  append(dexes, luacontext.loadDex(name))
end


function _M.enum(e)
  return function()
    if e.hasMoreElements() then
      return e.nextElement()
    end
  end
end

function _M.each(o)
  local iter = o.iterator()
  return function()
    if iter.hasNext() then
      return iter.next()
    end
  end
end

local NIL = {}
setmetatable(NIL, { __tostring = function() return "nil" end })

function _M.dump(o)
  local t = {}
  local _t = {}
  local _n = {}
  local space, deep = string.rep(' ', 2), 0
  local function _ToString(o, _k)
    if type(o) == ('number') then
      table.insert(t, o)
     elseif type(o) == ('string') then
      table.insert(t, string.format('%q', o))
     elseif type(o) == ('table') then
      local mt = getmetatable(o)
      if mt and mt.__tostring then
        table.insert(t, tostring(o))
       else
        deep = deep + 2
        table.insert(t, '{')
        for k, v in pairs(o) do
          if v == _G then
            table.insert(t, string.format('\r\n%s%s\t=%s ;', string.rep(space, deep - 1), k, "_G"))
           elseif v ~= package.loaded then
            if tonumber(k) then
              k = string.format('[%s]', k)
             else
              k = string.format('[\"%s\"]', k)
            end
            table.insert(t, string.format('\r\n%s%s\t= ', string.rep(space, deep - 1), k))
            if v == NIL then
              table.insert(t, string.format('%s ;',"nil"))
             elseif type(v) == ('table') then
              if _t[tostring(v)] == nil then
                _t[tostring(v)] = v
                local _k = _k .. k
                _t[tostring(v)] = _k
                _ToString(v, _k)
               else
                table.insert(t, tostring(_t[tostring(v)]))
                table.insert(t, ';')
              end
             else
              _ToString(v, _k)
            end
          end
        end
        table.insert(t, string.format('\r\n%s}', string.rep(space, deep - 1)))
        deep = deep - 2
      end
     else
      table.insert(t, tostring(o))
    end
    table.insert(t, " ;")
    return t
  end

  t = _ToString(o, '')
  return table.concat(t)
end


function _M.printstack()
  local stacks = {}
  for m = 2, 16 do
    local dbs = {}
    local info = debug.getinfo(m)
    if info == nil then
      break
    end
    table.insert(stacks, dbs)
    dbs.info = info
    local func = info.func
    local nups = info.nups
    local ups = {}
    dbs.upvalues = ups
    for n = 1, nups do
      local n, v = debug.getupvalue(func, n)
      if v == nil then
        v = NIL
      end
      if string.byte(n) == 40 then
        if ups[n] == nil then
          ups[n] = {}
        end
        table.insert(ups[n], v)
       else
        ups[n] = v
      end
    end

    local lps = {}
    dbs.localvalues = lps
    lps.vararg = {}
    --lps.temporary={}
    for n = -1, -255, -1 do
      local k, v = debug.getlocal(m, n)
      if k == nil then
        break
      end
      if v == nil then
        v = NIL
      end
      table.insert(lps.vararg, v)
    end
    for n = 1, 255 do
      local n, v = debug.getlocal(m, n)
      if n == nil then
        break
      end
      if v == nil then
        v = NIL
      end
      if string.byte(n) == 40 then
        if lps[n] == nil then
          lps[n] = {}
        end
        table.insert(lps[n], v)
       else
        lps[n] = v
      end
      --table.insert(lps,string.format("%s=%s",n,v))
    end
  end
  print(dump(stacks))
  -- print("info="..dump(dbs))
  -- print("_ENV="..dump(ups._ENV or lps._ENV))
end


if activity then
  function _M.print(...)
    local buf = {}
    for n = 1, select("#", ...) do
      table.insert(buf, tostring(select(n, ...)))
    end
    local msg = table.concat(buf, "\t\t")
    activity.sendMsg(msg)
  end
end


function _M.getids()
  return luajava.ids
end

local LuaAsyncTask = luajava.bindClass("com.androlua.LuaAsyncTask")
local LuaThread = luajava.bindClass("com.androlua.LuaThread")
local LuaTimer = luajava.bindClass("com.androlua.LuaTimer")
local Object = luajava.bindClass("java.lang.Object")


local function setmetamethod(t, k, v)
  getmetatable(t)[k] = v
end

local function getmetamethod(t, k, v)
  return getmetatable(t)[k]
end


local getjavamethod = getmetamethod(LuaThread, "__index")
local function __call(t, k)
  return function(...)
    if ... then
      t.call(k, Object { ... })
     else
      t.call(k)
    end
  end
end

local function __index(t, k)
  local s, r = pcall(getjavamethod, t, k)
  if s then
    return r
  end
  local r = __call(t, k)
  setmetamethod(t, k, r)
  return r
end

local function __newindex(t, k, v)
  t.set(k, v)
end

local function checkPath(path)
  if path:find("^[^/][%w%./_%-]+$") then
    if not path:find("%.lua$") then
      path = string.format("%s/%s.lua", activity.luaDir, path)
     else
      path = string.format("%s/%s", activity.luaDir, path)
    end
  end
  return path
end

function _M.thread(src, ...)
  if type(src) == "string" then
    src = checkPath(src)
  end
  local luaThread
  if ... then
    luaThread = LuaThread(activity or service, src, true, Object { ... })
   else
    luaThread = LuaThread(activity or service, src, true)
  end
  luaThread.start()
  --setmetamethod(luaThread,"__index",__index)\
  --setmetamethod(luaThread,"__newindex",__newindex)
  return luaThread
end

function _M.task(src, ...)
  local args = { ... }
  local callback = args[select("#", ...)]
  args[select("#", ...)] = nil
  local luaAsyncTask = LuaAsyncTask(activity or service, src, callback)
  luaAsyncTask.executeOnExecutor(LuaAsyncTask.THREAD_POOL_EXECUTOR, args)
  return luaAsyncTask
end

function _M.timer(f, d, p, ...)
  local luaTimer = LuaTimer(activity or service, f, Object { ... })
  if p == 0 then
    luaTimer.start(d)
   else
    luaTimer.start(d, p)
  end
  return luaTimer
end

function _M.dp2px(dp)
  local TypedValue= import "android.util.TypedValue"
  local a,b=dp:match("^(%-?[%.%d]+)(%a%a)$")
  return TypedValue.applyDimension(1,tonumber(a),activity.getResources().getDisplayMetrics())
end
function _M.table2json(t)
  local json = import "json"
  return json.encode(t)
end
function _M.json2table(s)
  local json = import "json"
  return json.decode(s)
end






--支持库，解析init.lua
pcall(function()
  local ColorFilter=luajava.bindClass("android.graphics.ColorFilter")
  local ColorStateList=luajava.bindClass("android.content.res.ColorStateList")
  local l=io.open(activity.getLuaDir().."/init.lua"):read("*a")
  local a=l:match('loper="(.-)"')
  local b=l:match('ption="(.-)"')
  if a=="true" then nxn=0 else nxn=1 end
  activity.setRequestedOrientation(nxn);
  if b=="nil" then task(300,function()activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN);
    end)
  end
  function mainHeight()
    import 'android.os.Build'
    if Build.VERSION.SDK_INT >= 19 then
      resourceId = activity.getResources().getIdentifier('status_bar_height','dimen','android')
      height = activity.getResources().getDimensionPixelSize(resourceId)
      return height
     else
      return 0
    end
  end
  function getLayouti(a,c)
    linearParams = a.getLayoutParams()
    linearParams.height =c
    a.setLayoutParams(linearParams)
  end
  function BaseColl(id,color)
    local attrsArray = {android.R.attr.selectableItemBackgroundBorderless}
    local typedArray =activity.obtainStyledAttributes(attrsArray)
    ripple=typedArray.getResourceId(0,0)
    Pretend=activity.Resources.getDrawable(ripple)
    Pretend.setColor(ColorStateList(int[0].class{int{}},int{color}))
    id.setBackground(Pretend.setColor(ColorStateList(int[0].class{int{}},int{color})))
  end
end)
--第三方属性检查完毕


local os_mt = {}
os_mt.__index = function(t, k)
  local _t = {}
  _t.__cmd = (rawget(t, "__cmd") or "") .. k .. " "
  setmetatable(_t, os_mt)
  return _t
end
os_mt.__call = function(t, ...)
  local cmd = t.__cmd .. table.concat({ ... }, " ")
  local p = io.popen(cmd)
  local s = p:read("a")
  p:close()
  return s
end
setmetatable(os, os_mt)

env_import(_G)

local luajava_mt = {}
luajava_mt.__index = function(t, k)
  local b, ret = xpcall(function()
    return luajava.bindClass((rawget(t, "__name") or "") .. k)
  end,
  function()
    local p = {}
    p.__name = (rawget(t, "__name") or "") .. k .. "."
    setmetatable(p, luajava_mt)
    return p
  end)
  rawset(t, k, ret)
  return ret
end
setmetatable(luajava, luajava_mt)















pcall(function()


require 'init'
if this!=activity or !debugmode then
_G.safe_error=print
_G.explain=print
_G.info=print
_G.warning=print
else




_G.View=luajava.bindClass "android.view.View"
local LinearLayout=luajava.bindClass "android.widget.LinearLayout"
local Spannable=luajava.bindClass "android.text.Spannable"
local Toast=luajava.bindClass "android.widget.Toast"
local EditText=luajava.bindClass "android.widget.EditText"
local InputMethodManager=luajava.bindClass "android.view.inputmethod.InputMethodManager"
local Color=luajava.bindClass "android.graphics.Color"
local WindowManager=luajava.bindClass "android.view.WindowManager"
local TextView=luajava.bindClass "android.widget.TextView"
local LuaAdapter=luajava.bindClass "com.androlua.LuaAdapter"
local Gravity=luajava.bindClass "android.view.Gravity"
local FrameLayout=luajava.bindClass "android.widget.FrameLayout"
local Build=luajava.bindClass "android.os.Build"
local Ticker=luajava.bindClass "com.androlua.Ticker"
local System=luajava.bindClass "java.lang.System"
local Context=luajava.bindClass "android.content.Context"
local HapticFeedbackConstants=luajava.bindClass "android.view.HapticFeedbackConstants"
local ListView=luajava.bindClass "android.widget.ListView"
local ColorStateList=luajava.bindClass "android.content.res.ColorStateList"
local ForegroundColorSpan=luajava.bindClass "android.text.style.ForegroundColorSpan"
local PageView=luajava.bindClass "android.widget.PageView"
local Window=luajava.bindClass "android.view.Window"
local SimpleDateFormat=luajava.bindClass "java.text.SimpleDateFormat"
local Configuration=luajava.bindClass "android.content.res.Configuration"
local Dialog=luajava.bindClass "android.app.Dialog"
local ScrollView=luajava.bindClass "android.widget.ScrollView"
local SpannableStringBuilder=luajava.bindClass "android.text.SpannableStringBuilder"
local typedValue = luajava.newInstance('android.util.TypedValue')
luajava.getContext().getTheme().resolveAttribute(android.R.attr.colorAccent, typedValue, true);
local dark=luajava.getContext().getResources().getConfiguration().uiMode& Configuration.UI_MODE_NIGHT_YES!=0


--local tcolor=typedValue.data
--local bcolor=0xfff2f1f6
local tcolor=0xFF00B002
local bcolor=0xFF059600
if dark then
  local hsv=float[3]
  Color.colorToHSV(tcolor,hsv)
  hsv[1]=0.7
  hsv[2]=1
  tcolor=Color.HSVToColor(hsv)
  bcolor=0xFF404041
  --bcolor=0x00
end
local ids={}
local wm=activity.getSystemService(Context.WINDOW_SERVICE)
local wp=WindowManager.LayoutParams()
wp.width=-2
wp.y = 50
wp.height=WindowManager.LayoutParams.WRAP_CONTENT
wp.gravity=Gravity.RIGHT | Gravity.CENTER
wp.flags=WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE


ids.btn={}
local btn=loadlayout({
  LinearLayout;
  padding="1dp";
  paddingRight="2";
  backgroundColor=tcolor;
  id='root';
  {
    TextView;
    paddingLeft="6dp";
    paddingBottom="2dp";
    paddingTop="2dp";
    id="title";
    textSize="11dp";
    textColor="0xFFF6F6F6";
    gravity="center";
    text="调试";
    paddingRight="6dp";
  };
},ids.btn)

ids.btn.title.getPaint().setFakeBoldText(true)
wm.addView(btn,wp)



--移动
local lastY=0
local vy=0
local vw=0
local vh=0

ids.btn.root.setOnTouchListener(View.OnTouchListener{onTouch=function(v,e)
    ry=e.getRawY()--获取触摸绝对Y位置
    if e.getAction() == 0 then
      vh=v.getHeight()
      wp=v.getLayoutParams()
      vy=wp.y --当前Y
      lastY=ry --起始Y
     elseif e.getAction() == 2 then--移动
      wp.y=(vy+(ry-lastY))
      wm.updateViewLayout(btn,wp)
     elseif e.getAction() == 1 then --抬起
    end
  end
})



local function readlog(s)
  local p=io.popen("logcat -d -v long "..s)
  local s=p:read("*a")
  p:close()
  s=s:gsub("%-+ beginning of[^\n]*\n","")
  if #s==0 then
    s="<run the app to see its log output>"
  end
  return s
end

local function clearlog()
  local p=io.popen("logcat -c")
  local s=p:read("*a")
  p:close()
  return s
end

task(clearlog)
control_hide=false


local ti=Ticker()
ti.Period=1500
ti.onTick=function()
  if control_hide then
    collectgarbage("restart")
    if dia then dia.show() end
    wm.removeView(btn)
    ti.stop()
  end
  local s=readlog('lua:* *:S')
  if s:find('Runtime%s-error')
    safe_error((s:gsub('^%[.+%]\n','')))
    ids.btn.title.setText('异常')
    ids.btn.root.setBackgroundColor(0xFFe90000)
    ids.btn.title.setTextColor(0xFFe0e0e0)
    ti.stop()
  end
  s = nil
  if this.isFinishing() or this.isDestroyed()
    ti.stop()
  end
end
ti.start()






ids.dia={}
local dia=Dialog(this)
dia.requestWindowFeature(Window.FEATURE_NO_TITLE)
dia.setContentView(loadlayout({
  LinearLayout;
  orientation="vertical";
  layout_width="fill";
  layout_height="fill";
  backgroundColor="#323232";
  {
    LinearLayout;
    layout_height="35dp";
    layout_width="match_parent";
    {
      TextView;
      textSize="12dp";
      layout_weight="1";
      layout_height="match_parent";
      backgroundColor="#AFC1CC";
      text="程序输出";
      gravity="center";
      textColor="#CACACA";
      id="prints";
    };
    {
      View;
      layout_width="2";
      backgroundColor="#484848";
    };
    {
      TextView;
      textSize="12dp";
      layout_height="match_parent";
      layout_weight="1";
      text="当前节点";
      gravity="center";
      textColor="#CACACA";
      id="variable";
    };
    {
      View;
      layout_width="2";
      backgroundColor="#484848";
    };
    {
      TextView;
      textSize="12dp";
      layout_height="match_parent";
      layout_weight="1";
      text="调试日志";
      gravity="center";
      textColor="#CACACA";
      id="logcat";
    };
    {
      View;
      layout_width="2";
      backgroundColor="#484848";
    };
    {
      TextView;
      textSize="12dp";
      layout_height="match_parent";
      layout_weight="1";
      text="查看内容";
      gravity="center";
      textColor="#CACACA";
      id="text";
    };
    {
      View;
      layout_width="2";
      backgroundColor="#484848";
    };
    {
      TextView;
      textSize="12dp";
      layout_height="match_parent";
      layout_weight="1";
      text="控制终端";
      gravity="center";
      textColor="#CACACA";
      id="control";
    };
  };
  {
    View;
    layout_height="2";
    backgroundColor="#484848";
  };
  {
    PageView;
    backgroundColor="#242424";
    layout_weight="1";
    id="page";
    overScrollMode="2";
    pages={
      {
        FrameLayout;
        layout_width="fill";
        layout_height="fill";
        {
          LinearLayout;
          layout_width="fill";
          id="print_empty";
          orientation="vertical";
          {
            TextView;
            textSize="12dp";
            paddingLeft="6dp";
            padding="5dp";
            layout_width="fill";
            text="<run the app to see its log output>";
            paddingRight="6dp";
            textColor="#A9A9A9";
          };
          {
            View;
            backgroundColor="#484848";
            layout_height="2";
          };
        };
        {
          ListView;
          overScrollMode="2";
          fastScrollEnabled=true;
          layout_width="match_parent";
          id="print_list";
          dividerHeight="2";
          layout_height="match_parent";
        };
      };
      {
        LinearLayout;
        orientation="vertical";
        layout_width="fill";
        layout_height="fill";
        {
          LinearLayout;
          orientation="vertical";
          layout_width="fill";
          {
            LinearLayout;
            focusable=true;
            layout_width="fill";
            focusableInTouchMode=true;
            {
              TextView;
              padding="5dp";
              paddingRight="0";
              textColor="#2FE364";
              textSize="12dp";
              text="当前节点: /";
              id="variable_path";
              paddingLeft="10dp";
              id="variable_path";
            };
            {
              EditText;
              padding="5dp";
              paddingLeft="0";
              textColor="#2FE364";
              textSize="12dp";
              backgroundColor="0";
              singleLine="true";
              paddingRight="6dp";
              id="variable_search";
              layout_width="fill";
              imeOptions="actionSearch";
            };
          };
          {
            View;
            backgroundColor="#484848";
            layout_height="2";
          };
        };
        {
          ListView;
          fastScrollEnabled=true;
          dividerHeight="2";
          overScrollMode="2";
          id="variable_list";
          layout_width="match_parent";
          layout_height="match_parent";
        };
      };
      {
        LinearLayout;
        layout_height="fill";
        orientation="vertical";
        layout_width="fill";
        {
          LinearLayout;
          layout_height="20dp";
          id="logcat_bar";
          gravity="center";
          layout_width="match_parent";
          {
            TextView;
            textSize="10dp";
            text="全部";
            textColor="#9e9e9e";
            gravity="center";
            layout_weight="1";
          };
          {
            View;
            layout_width="2";
            backgroundColor="#484848";
          };
          {
            TextView;
            textSize="10dp";
            text="Lua";
            textColor="#9e9e9e";
            gravity="center";
            layout_weight="1";
          };
          {
            View;
            layout_width="2";
            backgroundColor="#484848";
          };
          {
            TextView;
            textSize="10dp";
            text="测验";
            textColor="#9e9e9e";
            gravity="center";
            layout_weight="1";
          };
          {
            View;
            layout_width="2";
            backgroundColor="#484848";
          };
          {
            TextView;
            textSize="10dp";
            text="错误";
            textColor="#9e9e9e";
            gravity="center";
            layout_weight="1";
          };
          {
            View;
            layout_width="2";
            backgroundColor="#484848";
          };
          {
            TextView;
            textSize="10dp";
            text="警告";
            textColor="#9e9e9e";
            gravity="center";
            layout_weight="1";
          };
          {
            View;
            layout_width="2";
            backgroundColor="#484848";
          };
          {
            TextView;
            textSize="10dp";
            text="信息";
            textColor="#9e9e9e";
            gravity="center";
            layout_weight="1";
          };
          {
            View;
            layout_width="2";
            backgroundColor="#484848";
          };
          {
            TextView;
            textSize="10dp";
            text="调试";
            textColor="#9e9e9e";
            gravity="center";
            layout_weight="1";
          };
          {
            View;
            layout_width="2";
            backgroundColor="#484848";
          };
          {
            TextView;
            textSize="10dp";
            text="详细";
            textColor="#9e9e9e";
            gravity="center";
            layout_weight="1";
          };
        };
        {
          View;
          layout_height="2";
          backgroundColor="#48484848";
        };
        {
          ListView;
          overScrollMode="2";
          fastScrollEnabled=true;
          layout_width="match_parent";
          id="logcat_list";
          dividerHeight="2";
          layout_height="match_parent";
        };
      };

      {
        LinearLayout;
        layout_height="fill";
        layout_width="fill";
        focusable=true,
        focusableInTouchMode=true,
        {
          ScrollView;
          layout_width="fill";
          overScrollMode="2";
          {
            EditText;
            id="text_edit";
            textIsSelectable=true;
            hint="暂无内容！";
            textColor="#00B002";
            hintTextColor="#FFB900";
            layout_height="match_parent";
            layout_width="match_parent";
            textSize="12dp";
            backgroundColor="0";
            padding="8dp";
            gravity="start";
          };
        };
      };

      {
        LinearLayout;
        orientation="vertical";
        layout_width="fill";
        layout_height="fill";
        {
          LinearLayout;
          orientation="vertical";
          padding="10dp";
          layout_width="fill";
          {
            TextView;
            id="state_text";
            textSize="12dp";
            textColor="#02ED00";
            text="内存占用：";
            layout_marginTop="5dp";
            layout_marginBottom="5dp";
          };
          {
            LinearLayout;
            layout_width="fill";
            {
              TextView;
              gravity="center";
              id="control_btn1";
              layout_height="30dp";
              layout_marginRight="3dp";
              backgroundColor="#484848";
              textColor="#ededed";
              textSize="11dp";
              layout_weight="1";
              text="关闭当前界面";
              elevation="2";
            };
            {
              TextView;
              gravity="center";
              id="control_btn2";
              layout_height="30dp";
              elevation="2";
              textSize="11dp";
              textColor="#ededed";
              backgroundColor="#484848";
              layout_weight="1";
              text="重构当前界面";
              layout_marginLeft="3dp";
            };
          };
          {
            LinearLayout;
            layout_width="fill";
            layout_marginTop="6dp";
            {
              TextView;
              gravity="center";
              id="control_btn3";
              elevation="2";
              layout_marginRight="3dp";
              backgroundColor="#484848";
              textColor="#ededed";
              textSize="11dp";
              layout_weight="1";
              text="重启当前界面";
              layout_height="30dp";
            };
            {
              TextView;
              gravity="center";
              id="control_btn4";
              layout_height="30dp";
              elevation="2";
              textSize="11dp";
              textColor="#ededed";
              backgroundColor="#484848";
              layout_weight="1";
              text="结束当前进程";
              layout_marginLeft="3dp";
            };
          };
        };
        {
          LinearLayout;
          gravity="center|bottom";
          orientation="vertical";
          layout_width="match_parent";
          layout_height="match_parent";
          {
            View;
            layout_width="match_parent";
            layout_height="match_parent";
            layout_weight="1";
          };
          {
            LinearLayout;
            layout_width="match_parent";
            layout_height="wrap";
            orientation="vertical";
            padding="10dp";
            focusable=true,
            focusableInTouchMode=true,
            {
              EditText;
              backgroundColor="#22000000";
              gravity="left";
              textColor="#ededed";
              hintTextColor="#9e9e9e";
              layout_weight="1";
              layout_width="match_parent";
              layout_height="wrap";
              textSize="11dp";
              hint="Lua脚本：";
              id="control_code";
              layout_marginBottom="5dp";
            };
            {
              TextView;
              textSize="12dp";
              text="执行脚本";
              gravity="center";
              textColor="#ffffff";
              backgroundColor="#43733B";
              id="control_run";
              layout_width="match_parent";
              layout_height="35dp";
            };
          };
        };
      };

    };
  };

  {
    TextView;
    id="file_text";
    textSize="10dp";
    textColor="#B3B3B3";
    text="文件状态：";
    layout_width="match_parent";
    paddingLeft="10dp";
    paddingRight="10dp";
    paddingTop="5dp";
    paddingBottom="10dp";
    backgroundColor="0xff242424";
  };

  {
    View;
    layout_height="2";
    backgroundColor="#484848";
  };
  {
    LinearLayout;
    id='bar';
    layout_height="35dp";
    layout_width="match_parent";
  };
},ids.dia))

local dw=dia.getWindow()
local ab=dw.getAttributes()
ab.width=-1
ab.height=activity.getHeight()*0.6
dw.gravity=Gravity.BOTTOM





--Prints
local print_text={}
local print_data={}
local print_adp=LuaAdapter(this,print_data,{
  TextView;
  layout_width='fill';
  textSize='12dp';
  padding="5dp";
  paddingLeft='10dp';
  paddingRight='10dp';
  --backgroundColor="#ffffff";
  id='txt';
})

ids.dia.print_list.setAdapter(print_adp)

ids.dia.print_list.onItemClick=function(a,b,c,d)
  ids.dia.text_edit.setText(print_text[d])
  ids.dia.page.setCurrentItem(3,false)
end

local date=SimpleDateFormat("HH:mm:ss.SSS: ")
function log(color,is,...)
  local str={}
  local arg={...}

  ids.dia.print_empty.setVisibility(8)

  for k,v ipairs(arg)
    str[#str+1]=tostring(v)
    if k!=#arg
      str[#str+1]='   '
    end
  end

  local s=table.concat(str)
  local tag=s
  if utf8.len(s)>400
    s=string.sub(s,1,400)..'...'
  end

  if is
    s=date.format(System.currentTimeMillis())..s
  end

  print_adp.add{
    txt={
      text=s,
      textColor=color,
    }
  }
  print_text[#print_data]=tag
  return ...
end

function print(...)
  return log(0xFFF4B63F,1,...)
end

function safe_error(...)
  return log(0xFFFF4B4B,1,...)
end

function explain(...)
  return log(0xFFD0E700,1,...)
end

function info(...)
  return log(0xFF00D700,1,...)
end

function warning(...)
  return log(0xFFFFB000,1,...)
end

local _err=error
function error(a,b)
  _err(log(0xFFFF4343,1,a),b)
end

local _ass=assert
function assert(a,...)
  if !a
    log(0xFFFF3E3E,1,...)
  end
  return _ass(a,...)
end



--variable
local variable_path={}
local flags=Spannable.SPAN_INCLUSIVE_INCLUSIVE
local variable_kv={}
local variable_span={}
local variable_node={}
local variable_data={}
local variable_adp=LuaAdapter(this,variable_data,{
  TextView;
  layout_width='fill';
  textSize='12dp';
  padding="5dp";
  paddingLeft='10dp';
  paddingRight='16dp';
  singleLine='true';
  ellipsize="end";
  id='kv';
})

ids.dia.variable_list.setAdapter(variable_adp)


local function add(tab,str)
  variable_data[#variable_data+1]={
    kv={
      text=str,
      textColor=0xFFD7D7D7
    }
  }
  variable_kv[#variable_data]=tab
end

local color_span1=ForegroundColorSpan(0xFF00CBC4) --箭头
local color_span2=ForegroundColorSpan(0xFFF4B63F) --变量名
local color_span3=ForegroundColorSpan(0xFF0FDC00) --table
local color_span4=ForegroundColorSpan(0xFF5A985A) --子级箭头
local color_span5=ForegroundColorSpan(0xFFFF7CE8) --参数

local function tree()
local tab=_ENV

table.clear(variable_path)
table.clear(variable_data)

for k,v ipairs(variable_node)
  if type(tab[v])=='table'
    tab=tab[v]
   else
    variable_node[k]=nil
  end
end

local t={}
for k,v ipairs(variable_node)
  t[k]=tostring(v)
end

local s=table.concat(t,'/')

if #s>0
  s=s.."/"
end

ids.dia.variable_path.setText("当前节点: /"..s)


table.clear(variable_data)
if #variable_node!=0
  add(1,'返回父节点')
end

add(2,'序列化节点')

for k,v pairs(tab)
  local _k,_v=k,v
  v=tostring(v)
  if utf8.len(v)>80
    v=utf8.sub(v,1,80)..'...'
  end
  when type(k)!='string' k=string.format('[%s]',tostring(k))
    when type(_v)=='string' v=string.format('"%s"',v)
      when type(_v)=='table' v=string.format('%s => {...}',v)


        local s=string.format('%s => %s',k,tostring(v))


        local span
        if variable_span[#variable_data+1]
          span=variable_span[#variable_data+1]
         else
          span=SpannableStringBuilder()
        end

        span.clearSpans()
        span.clear()
        span.append(s)

        local s1,e1=utf8.find(s,'=>')

        span.setSpan(color_span2, 0, utf8.len(k), flags)
        span.setSpan(color_span1, s1-1, e1, flags)

        if type(_v)=='table'
          if s:find('table')
            local s0,e0=utf8.find(s,'table:%s-0x%x+%s')
            span.setSpan(color_span3, s0-1, e0, flags)
            local s1,e1=utf8.find(s,'=>',e0)
            span.setSpan(color_span4, s1-1, e1, flags)
            local s2,e2=utf8.find(s,'{%.%.%.}',e1)
            span.setSpan(color_span5, s2-1, e2, flags)
            variable_path[tostring(_k)]=_k
          end
        end
        add({_k,_v},span)
      end
      variable_adp.notifyDataSetChanged()
      ids.dia.variable_list.setStackFromBottom(true)
      ids.dia.variable_list.setStackFromBottom(false)
    end


    ids.dia.variable_list.onItemClick=function(a,b,c,d)
      local t=variable_kv[d]
      if t==1
        variable_node[#variable_node]=nil
        tree()
       elseif t==2
        local tab=_ENV
        for k,v ipairs(variable_node)
          tab=tab[v]
        end
        ids.dia.text_edit.setText(dump(tab))
        ids.dia.page.setCurrentItem(3,false)
       else
        if type(t[2])=="table"
          variable_node[#variable_node+1]=t[1]
          tree()
         else
          ids.dia.text_edit.setText(tostring(t[2]))
          ids.dia.page.setCurrentItem(3,false)
        end
      end
    end

    ids.dia.variable_list.onItemLongClick=function(a,b,c,d)
      activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(b.Text)
      return true
    end

    ids.dia.variable_search.onEditorAction=function(v,actionId,event)
      if actionId==0
        variable_node[#variable_node+1]=variable_path[v.text]
        v.setText('')
        activity.getSystemService(Context.INPUT_METHOD_SERVICE).toggleSoftInput(0,InputMethodManager.HIDE_NOT_ALWAYS)
        tree()
      end
      return false
    end


    --logcat
    local logcat_pos,show=1

    local items={"All","Lua","Tcc","Error","Warning","Info","Debug","Verbose"}
    local types={'', "lua:* *:S", "tcc:* *:S", "*:E", "*:W", "*:I", "*:D", "*:V"}

    local logcat_text={}
    local logcat_data={}
    local logcat_adp=LuaAdapter(this,logcat_data,{
      TextView;
      layout_width='fill';
      textSize='12dp';
      padding="5dp";
      paddingLeft='10dp';
      paddingRight='10dp';
      textColor=0xFF00B002;
      id='txt';
    })
    ids.dia.logcat_list.setAdapter(logcat_adp)
    ids.dia.logcat_list.onItemClick=function(a,b,c,d)
      ids.dia.text_edit.setText(logcat_text[d])
      ids.dia.page.setCurrentItem(3,false)
    end

    local function read()
      task(readlog,types[logcat_pos],function(str)
        table.clear(logcat_data)
        local t,n={},0
        str:gsub('[^\n\n]+',function(w)
          if n%2==0
            if !w:find('^%[')
              t[#t]=string.format('%s\n%s',t[#t],w)
             else
              t[#t+1]=w
              n=n+1
            end
           else
            t[#t]=string.format('%s\n%s',t[#t],w)
            n=n+1
          end
        end)
        for k,v ipairs(t)
          logcat_data[k]={
            txt={
              text= v ,
            }
          }
          logcat_text[k]=v
        end
        logcat_adp.notifyDataSetChanged()
      end)
    end

    for i=0,7
      local v=ids.dia.logcat_bar.getChildAt(i*2)
      local i=i
      v.onClick=function(v0)
        logcat_pos=i+1
        for i=0,14,2
          local _v=ids.dia.logcat_bar.getChildAt(i)
          _v.setTextColor(0xff909090)
          _v.getPaint().setFakeBoldText(false)
        end
        v0.setTextColor(tcolor)
        v0.getPaint().setFakeBoldText(true)
        read()
      end
    end

    local v=ids.dia.logcat_bar.getChildAt(0)
    v.setTextColor(tcolor)
    v.getPaint().setFakeBoldText(true)

    ----
    ids.btn.root.onClick=function(v)
      dia.show()
    end

    --底栏
    local bar={'prints', 'variable', 'logcat', 'text', 'control' }

    local btn_list={
      {
        '清空',function(v)
          print_adp.clear()
          table.clear(print_text)
          ids.dia.print_empty.setVisibility(0)
        end,
        '隐藏',function(v)
          dia.dismiss()
        end
      },
      {
        '刷新',function(v)
          tree()
        end,
        '隐藏',function(v)
          dia.dismiss()
        end
      },
      {
        '清空',function(v)
          task(clearlog,read)
        end,
        '隐藏',function(v)
          dia.dismiss()
        end
      },
      {
        '复制',function(v)
          activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(ids.dia.text_edit.getText())
          Toast.makeText(activity, "复制成功",Toast.LENGTH_SHORT).show()
        end,
        '粘贴',function(v)
          ids.dia.text_edit.setText(activity.getSystemService(Context.CLIPBOARD_SERVICE).getText())
        end,
        '清空',function(v)
          ids.dia.text_edit.setText(nil)
        end,
        '隐藏',function(v)
          dia.dismiss()
        end
      },
      {
        '隐藏',function(v)
          dia.dismiss()
        end
      }
    }

    local btn_cache={}

    local attrsArray = {android.R.attr.selectableItemBackgroundBorderless}
    local typedArray =activity.obtainStyledAttributes(attrsArray)
    local ripple=typedArray.getResourceId(0,0)
    local function 波纹(id,color)
      local Pretend=activity.Resources.getDrawable(ripple)
      pcall(function()
        Pretend.setColor(ColorStateList(int[0].class{int{}},int{color or 0xFF404041}))
      end)
      if id
        return id.setBackground(Pretend)
       else
        return Pretend
      end
    end

    local p=-1
    ids.dia.page.addOnPageChangeListener{
      onPageScrolled=function(pos)
        if pos!=p
          p=pos
          if pos==1
            tree()
           elseif pos==2
            read()
          end
          for k,v ipairs(bar)
            if k==pos+1
              --顶部选中按钮
              ids.dia[v].setBackgroundColor(0xFF484848)
              continue
            end
            ids.dia[v].setBackgroundColor(0)
          end
          ids.dia.bar.removeAllViews()
          ids.dia.bar.post(function()
            local tab=btn_list[pos+1]
            local n=0
            local width=ids.dia.bar.getWidth()/(#tab/2)
            for i=1,#tab,2
              n=n+1
              local lay
              if btn_cache[n]
                lay=btn_cache[n]
               else
                lay=loadlayout({
                  TextView;
                  gravity="center";
                  layout_height="match_parent";
                  textSize="12dp";
                  text=tab[i];
                  textColor="#C4C4C4";
                })
                波纹(lay)
                btn_cache[n]=lay
              end
              lay.setWidth(width)
              lay.setText(tab[i])
              lay.onClick=tab[i+1]
              ids.dia.bar.addView(lay)
              if n!=#tab/2
                ids.dia.bar.addView(loadlayout{
                  View;
                  layout_width="2";
                  backgroundColor="#484848";
                })
              end
            end
          end)
        end
    end}

    for k,v ipairs(bar)
      ids.dia[v].onClick=function(v)
        ids.dia.page.setCurrentItem(k-1,false)
        if v.text == "控制终端" then
          ids.dia.state_text.text = "内存占用：" .. string.format("%0.2f", collectgarbage("count")) .. " KB"
        end
      end
    end


    --Control
    ids.dia.control_btn1.onClick=function(v)
      dia.dismiss()
      activity.finish()
    end

    ids.dia.control_btn2.onClick=function(v)
      dia.dismiss()
      activity.recreate()
    end

    ids.dia.control_btn3.onClick=function(v)
      dia.dismiss()
      activity.finish()
      this.startActivity(this.getIntent())
    end

    ids.dia.control_btn4.onClick=function(v)
      dia.dismiss()
      os.exit()
    end

    ids.dia.control_run.onClick=function(v)
      local f,e=load(ids.dia.control_code.text)
      if f
        local v,e=pcall(f)
        if v
          ids.dia.control_code.setText('')
         else
          safe_error(e)
          ids.dia.control_code.setError('程序出错')
        end
       else
        safe_error(e)
        ids.dia.control_code.setError('语法错误')
      end
    end
    -----
    local pkg=this.getPackageManager().getPackageInfo(this.getPackageName(),0)
    log(0xFF36E579,nil, "当前程序：" .. tostring(appname) .. " (v." .. appver .. ")")
    ids.dia.file_text.text = string.format('System: %s, Android %s (SDK%s), %s %s',
    Build.MODEL,Build.VERSION.RELEASE,Build.VERSION.SDK,pkg.applicationInfo.loadLabel(this.getPackageManager())
    ,pkg.versionName) .. '\nFile: '..this.getLuaPath()
  end
  appname=nil
  appver=nil
  appcode=nil
  appsdk=nil
  packagename=nil
  debugmode=nil
  user_permission=nil
  skip_compilation=nil
  package.loaded.init=nil
end)


return env_import