{
  {
    id = "default";
    name = "默认分类";
    icon = nil;
    data =
    {
      {
        id = "fileTransfer";
        name = "局域网快传";
        icon = "res/image/icons8-network-file-system.png";
        text = "局域网内快速传输文件";
        func =
        {
          type = "newActivity";
          content = "tools/fileTransfer/main.lua";
        };
      };
      {
        id = "noiseDetect";
        name = "噪音检测";
        icon = "res/image/icons8-speaker.png";
        text = "检测当前环境的声音";
        func =
        {
          type = "newActivity";
          content = "tools/noiseDetect/main.lua";
        };
      };
      {
        id = "translation";
        name = "翻译助手";
        icon = "res/image/icons8-translation.png";
        text = "来源于有道翻译接口";
        func =
        {
          type = "newActivity";
          content = "tools/translation/main.lua";
        };
      };

      {
        id = "recipe";
        name = "食用手册";
        icon = "res/image/icons8-sandwich-with-fried-egg.png";
        text = "看看今天做什么吃的。";
        func =
        {
          type = "appBrowser";
          screen = "full";
          orientation = "follow";
          content = "https://cook.yunyoujun.cn/";
        };
      };
      {
        id = "chouxianghua";
        name = "抽象话生成";
        icon = "res/image/icons8-comments.png";
        text = "将普通话转为极其抽象的话(开发中)";
        func = nil;
      };
    };
  };
  {
    id = "count";
    name = "科学计算";
    icon = "res/image/icons8-game.png";
    data =
    {
      {
        id = "scientificCalculator";
        name = "科学计算器";
        icon = "res/image/icons8-calculator.png";
        text = "进行严谨的科学计算(开发中)";
        func = nil;
      };
      {
        id = "ruler";
        name = "尺子";
        icon = "res/image/icons8-school-supplies.png";
        text = "临时用用应该还是可以的...";
        func =
        {
          type = "newActivity";
          content = "tools/ruler/main.lua";
        };
      };
      {
        id = "relationship";
        name = "亲戚计算器";
        icon = "res/image/icons8-romance.png";
        text = "计算亲属关系的称呼";
        func =
        {
          type = "appBrowser";
          screen = "full";
          orientation = "follow";
          content = "file://" .. activity.getLuaDir() .."/web/relationship/index.html";
        };
      };
    };
  };
  {
    id = "useless";
    name = "小黑子是吧";
    icon = "res/image/icons8-basketball.png";
    data =
    {
      {
        id = "kunkunAudio";
        name = "坤坤语音包";
        icon = "tools/kunkunAudio/icon.png";
        text = "我会唱，跳，rup，打篮球，music！";
        func =
        {
          type = "newActivity";
          content = "tools/kunkunAudio/main.lua";
        };
      };
      {
        id = "kunkunBall";
        name = "坤坤打砖块";
        icon = "tools/kunkunAudio/icon.png";
        text = "厉不厉害你坤哥！";
        func =
        {
          type = "appBrowser";
          screen = "full";
          orientation = "follow";
          content = "file://" .. activity.getLuaDir() .."/web/kunkunBall/index.html";
        };
      };
    };
  };
  {
    id = "useless";
    name = "沙雕工具";
    icon = "res/image/icons8-freaky-horse.png";
    data =
    {
      {
        id = "handFlashlight";
        name = "动能手电筒";
        icon = "res/image/icons8-light-on.png";
        text = "需要手摇发电的手电筒";
        func =
        {
          type = "newActivity";
          content = "tools/handFlashlight/main.lua";
        };
      };
      {
        id = "lightFlashlight";
        name = "光能手电筒";
        icon = "res/image/icons8-light-on.png";
        text = "需要光照才能发光的手电筒";
        func =
        {
          type = "newActivity";
          content = "tools/lightFlashlight/main.lua";
        };
      };
      {
        id = "airConditioner";
        name = "便携小空调";
        icon = "res/image/icons8-fan-head.png";
        text = "赛博空调，哪里都好就是没有风。";
        func =
        {
          type = "appBrowser";
          screen = "full";
          orientation = "follow";
          content = "https://ac.yunyoujun.cn/";
        };
      };
    };
  };
  {
    id = "miniGime";
    name = "娱乐游戏";
    icon = "res/image/icons8-game1.png";
    data =
    {
      {
        id = "mikutap";
        name = "Mikutap";
        icon = "web/mikutap/icon.png";
        text = "一个会唱歌的游戏";
        func =
        {
          type = "appBrowser";
          screen = "full";
          orientation = "follow";
          content = "file://" .. activity.getLuaDir() .."/web/mikutap/index.html";
        };
      };
    };
  };
  {
    id = "mcTools";
    name = "我的世界工具";
    icon = "res/image/minecraf.png";
    data =
    {
      {
        id = nil;
        name = "敬请期待";
        icon = "res/image/icons8-under-construction.png";
        text = "该功能正在开发中...";
        func = nil;
      };
    };
  };
  {
    id = "mcTools";
    name = "FC怀旧游戏";
    icon = "res/image/icons8-game.png";
    data =
    {
      {
        id = nil;
        name = "敬请期待";
        icon = "res/image/icons8-under-construction.png";
        text = "该功能正在开发中...";
        func = nil;
      };
    };
  };
};
