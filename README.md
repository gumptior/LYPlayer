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

## CocoaPods安装
#### Podfile
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'LYPlayer', '~> 0.1'
end
```
运行下面的命令

```
$ pod install
```

## License
LYPlayer is released under the MIT license. See LICENSE for details. 

