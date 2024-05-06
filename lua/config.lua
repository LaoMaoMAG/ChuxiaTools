require "import"
import "android.os.Environment"
import "java.io.File"

local init = require "init"


local config = {}
config.filePath = {}


-- 基础信息
config.appname = appname
config.appver = appver
config.debugmode = debugmode
config.packagename = packagename

-- Logo图片表
config.logoTable =
{
  "res/image/logo1.png";
  "res/image/logo2.png";
  "res/image/logo3.png";
  "res/image/logo4.png";
  "res/image/logo5.png";
}

-- 背景图片表
config.backTable =
{
  "res/image/background1.png";
  "res/image/background2.png";
  "res/image/background3.png";
  "res/image/background4.png";
  "res/image/background5.png";
  "res/image/background6.png";
}


-- 数据文件夹
if config.debugmode then
  config.filePath.dataFolder = activity.getLuaExtDir("data/" .. config.packagename)
 else
  config.filePath.dataFolder = Environment.getExternalStorageDirectory().toString() .. "/Android/data/" .. config.packagename
end
if not File(config.filePath.dataFolder).isDirectory() then File(config.filePath.dataFolder).mkdirs() end

-- 文件数据文件夹
config.filePath.fileFolder = config.filePath.dataFolder .. "/files"
if not File(config.filePath.fileFolder).isDirectory() then File(config.filePath.fileFolder).mkdirs() end

-- 数据库文件
config.filePath.dbFile = config.filePath.fileFolder .. "/data.db"


-- print(dump(config))


return config