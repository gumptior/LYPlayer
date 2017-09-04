# LYPlayer

## 介绍
基于swift3.0，支持高度自定义UI样式，有问题欢迎Issues。
## 特点
* 手势控制音量、亮度、播放进度
* 横屏状态锁屏
* 横竖屏旋转
* 自动播放
* 功能（代码）和视图（代码）分离

## 分离功能和视图的优劣
1. 逻辑清晰，代码可读性提高
2. 如果页面无法满足需求，完全自定义UI

## 效果图
![](http://ov49u3l5m.bkt.clouddn.com/%E6%95%88%E6%9E%9C%E5%9B%BE1.PNG)
![](http://ov49u3l5m.bkt.clouddn.com/%E6%95%88%E6%9E%9C%E5%9B%BE2.PNG)
![](http://ov49u3l5m.bkt.clouddn.com/%E6%95%88%E6%9E%9C%E5%9B%BE3.PNG)
![](http://ov49u3l5m.bkt.clouddn.com/%E6%95%88%E6%9E%9C%E5%9B%BE4.PNG)

## CocoaPods安装
#### Podfile
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
  # your other pod
  # ...
  pod 'LYPlayer', '~> 0.4.1'
end
```
运行下面的命令

```
$ pod install
```

## License
LYPlayer is released under the MIT license. See LICENSE for details. 

