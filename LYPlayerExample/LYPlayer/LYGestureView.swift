//
//  LYGestureView.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

import UIKit
import MediaPlayer

public enum Direction {
    case leftOrRight
    case upOrDown
    case none
}

@objc protocol LYGestureViewDelegate {
    
    /// 快进、快退
    ///
    /// - Parameter seconds: 移动的秒数
    func adjustVideoPlaySeconds(_ changeSeconds: Double)
    
    /// 点按手势代理事件
    ///
    /// - Parameter view: self
    func tapGestureAction(view: UIImageView)
    
    /// 双击手势代理事件
    ///
    /// - Parameter view: self
    func doubleTapGestureAction(view: UIImageView)
}

class LYGestureView: UIImageView {

    weak var delegate: LYGestureViewDelegate?
    
    private var direction: Direction?
    
    // 开始点击时的坐标
    private var startPoint: CGPoint?
    
    // 开始值
    private var startValue: Float?
    
    /** 是否允许拖拽手势 */
    var isEnabledDragGesture: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        
        // 添加点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)
        
        // 添加双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var volumeViewSlider: UISlider? = {
        let volumeView = MPVolumeView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        var volumeViewSlider: UISlider? = nil
        
        for view in volumeView.subviews {
            if (NSStringFromClass(view.classForCoder) == "MPVolumeSlider") {
                volumeViewSlider = view as? UISlider
                volumeViewSlider?.sendActions(for: .touchUpInside)
                break
            }
        }
        
        return volumeViewSlider
    }()
    
    func adjustVolume(volume: Float) {
        volumeViewSlider?.setValue(volume, animated: true)
    }
    
    // 触摸开始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // 开始触摸点的坐标
        startPoint = touches.first?.location(in: self)
        
        // 检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
        if (startPoint?.x)! <= frame.size.width / 2.0 {
            // 亮度
            startValue = Float(UIScreen.main.brightness)
        } else {
            // 音量
            startValue = volumeViewSlider?.value
        }
        // 方向为无
        direction = .none
    }
    
    // 触摸结束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        // 判断是否激活拖拽手势
        if isEnabledDragGesture == false {
            return
        }
        
        let point = touches.first?.location(in: self)
        
        // 计算手指移动的距离
        let panPoint = CGPoint(x: (point?.x)! - (startPoint?.x)!, y: (point?.y)! - (startPoint?.y)!)
        
        // 分析用户滑动的方向
        switch judgeGesture(point: point) {
        case .none:
            break
        case .leftOrRight:
            let seconds = panPoint.x / 10
            self.delegate?.adjustVideoPlaySeconds(Double(seconds))
            break
        case .upOrDown:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        // 判断是否激活拖拽手势
        if isEnabledDragGesture == false {
            return
        }
        
        var point: CGPoint?
        for touch in touches {
            point = touch.location(in: self)
        }
        // 计算手指移动的距离
        let panPoint = CGPoint(x: (point?.x)! - (startPoint?.x)!, y: (point?.y)! - (startPoint?.y)!)
        
        // 通过手指滑动的距离，计算音量或亮度需要调整的值
        let changeValue = calculateValue(point: panPoint)
        
        // 分析用户滑动的方向
        switch judgeGesture(point: point) {
        case .none:
            break
        case .leftOrRight:
            // 视频进度
            direction = .leftOrRight
        case .upOrDown:
            // 音量和亮度
            direction = .upOrDown
        }
        
        if direction == .none {
            return
        } else if direction == .upOrDown {
            // 音量和亮度
            if (startPoint?.x)! <= frame.size.width / 2.0 {
                // 调节亮度
                UIScreen.main.brightness = CGFloat(startValue!) + changeValue
                // 判断是增加还是减少
                if panPoint.y < 0 {
                    // 增加亮度
                } else {
                    // 减少亮度
                }
                let brightnessView = LYBrightnessView.shard
                brightnessView.progress = CGFloat(startValue!) + changeValue
            } else {
                // 音量
                volumeViewSlider?.setValue(startValue! + Float(changeValue), animated: true)
                if panPoint.y < 0 {
                    // 增加音量
                } else {
                    // 减少音量
                }
            }
        } else {
            
        }
    }
    
    /// 判断手势
    ///
    /// - Parameter point: 位移坐标
    /// - Returns: 手势方向
    func judgeGesture(point: CGPoint?) -> Direction {
        if point == nil {
            return .none
        }
        // 获取x、y轴滑动距离
        let lenghtY = fabs(point!.y) - fabs(startPoint!.y)
        let lenghtX = fabs(point!.x) - fabs(startPoint!.x)
        
        if fabs(lenghtY) > fabs(lenghtX) {
            // 音量和亮度
            return .upOrDown
        } else if fabs(lenghtY) < fabs(lenghtX) {
            // 视频进度
            return .leftOrRight
        } else {
            // 没有手势
            return .none
        }
    }

    //
    /// 通过手指滑动的距离，计算音量或亮度需要调整的值
    ///
    /// - Parameter point: 手指当前位置相对起始位置的坐标
    /// - Returns: 调整的值，区间的值是  0..1
    func calculateValue(point: CGPoint) -> CGFloat {
        // 由于手指离屏幕左上角越近（竖屏），值增加，所以加负号，使手指向右边划时，值增加
        // * 3  ：在滑动相等距离的情况下，乘的越大，滑动产生的效果越大（value变化快）
        let value = -point.y / screen_width * 3

        return value
    }
    
    /// 点击手势事件
    func tapAction() {
        self.delegate?.tapGestureAction(view: self)
    }
    
    /// 双击手势事件
    func doubleTapAction() {
        self.delegate?.doubleTapGestureAction(view: self)
    }
}
