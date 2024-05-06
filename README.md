<div align="center">
    <img src="res/image/logo1.png" width="200" height="200"  alt="ChuxiaTools ">
    <h1 align="center">ChuxiaTools 初夏工具箱</h1>
</div>

<p align="center">初夏工具箱是一款使用 AndroLua+ 开发的一款综合运行时工具箱</p><br>



## 让我喵两句QAQ

> PS：这是一个非常垃圾且没用的项目，是我的一个朋友要的，然后我谁便做出来的，大佬轻点喷QAQ。

这个项目由于是使用AndroLua+开发的（朋友要求的），所以复杂一点涉及到原生的地方异常麻烦，不过AndroLua+开发一些简单的小软件还算方便。

项目里面的素材大部分都是在网络上找的，部分素材是我自己画的，如果有侵权请您联系我进行修正。

- 部分素材资源来自: [**icons8.com**](https://icons8.com)

- 部分素材资源搜索自: [**搜图神器**](https://space.bilibili.com/627079680)

- 猫猫的电子邮箱: **2901688350@qq.com**

- 猫猫的B站主页: **https://space.bilibili.com/622811302**



## 项目说明

> 这是一款 Android 端的综合运行时的工具箱，集成如 WebView Nginx PHP Node.js EmulatorJS 之类的项目（没开发完，就是说一下计划），是一个究极缝合怪项目。

> 这个似乎是一个没啥用的项目，唯一的作用应该就是让一些程序能在 Android 上跑起来，后续可能会添加单个工具打包成 APK 的功能。

### 开发进度

> 运行时
  - [x] AndroLua+
  - [x] WebView
  - [ ] Nginx
  - [ ] PHP
  - [ ] Node.js
  - [ ] EmulatorJS

> 用户交互
  - [x] 基础UI
  - [x] 工具表
  - [x] 分类
  - [ ] 弹窗模块
  - [ ] 收藏表
  - [ ] 音乐播放器

> 其他
  - [ ] 打包APK
  - [ ] 优化工具



## 部署项目

### 运行

- 本项目是使用一款基于 AndroLua+ 的编辑器 ManaLua ，这个编辑器可能内置了其他的库，直接放在AndroLua+可能跑不起来（没用试过）。 ManaLua 可以在官方QQ群：[**704194917**](https://jq.qq.com/?_wv=1027&k=QI0qGAZn) 下载最新版本。

- 将这个存储库用压缩包下载下来然，然后文件扩展名改成 .alp 就可以直接使用编辑器内的导入项目功能导入。当然，直接解压缩在项目工程路径也可以。

### 使用

- 添加配置工具可以在 script/toolsTable.lua 文件进行修改添加，这个文件是一个 Lua Table 由于项目还没完成就不说具体配置了，可以自己研究一下。

- 添加 AndroLua+ 工具可以将 AndroLua+ 项目直接放在 /tools 路径，然后在 script/toolsTable.lua 文件添加配置，具体可以看项目内的实例。

- 添加 HTML 工具可以将 HTML 项目直接放在 /tools 路径，然后在 script/toolsTable.lua 文件添加配置，具体可以看项目内的实例，暂时只支持原生 JavaScript 项目，暂未支持 PHP ， Node.js 项目。



## 使用的开源项目

> 这里写明的可能不全面，这个项目还没完成，后面再补。

> 项目内集成了 [**云游君**](https://github.com/YunYouJun) 的一些开源Web项目

- [**AndroLua+:**](https://github.com/nirenr/AndroLua_pro) 或者叫 AndroLua- 在卓平台上用 Lua 开安卓程序的项目。

- [**ManaLua**](https://space.bilibili.com/354191504) 一款基于 AndroLua+ 开发的编辑器，专注于游戏开发，游戏设计。

- [**LuaDB:**](https://github.com/limao996/LuaDB) 基于 Lua 的高性能本地 kv 数据库。

- [**EmulatorJS:**](https://github.com/EmulatorJS/EmulatorJS) 适用于各种系统的自托管 Javascript 仿真。



## 开源协议

> 本项目使用 MIT 开源协议。

>该协议允许自由地使用、复制、修改、合并、发布、分发、再授权和销售软件及其副本的任何部分。 

> MIT协议要求在软件的所有副本中包含版权声明和许可声明。

> 在您使用、复制、修改、合并、发布、分发等操作，麻烦请您保留猫猫的版权声明和许可声明QAQ。

- [**MIT开源协议**](LICENSE)