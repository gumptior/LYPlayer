//
//  LYGestureControl.swift
//  LBPlayerExample
//
//  Created by 你个LB on 2017/3/28.
//  Copyright © 2017年 NGeLB. All rights reserved.
//

import UIKit
import MediaPlayer

public enum Direction {
    case leftOrRight
    case upOrDown
    case none
}

protocol LYPlayerGestureDelegate {
    
    // 开始触摸
    func touchesBegan(point: CGPoint)
    
    // 结束触摸
    func touchesEnded(point: CGPoint)
    
    // 移动手指
    func touchesMoved(point: CGPoint)
}

class LYPlayerGesture: UIView {

    var delegate: LYPlayerGestureDelegate?
    
    private var direction: Direction?
    
    // 开始点击时的坐标
    private var startPoint: CGPoint?
    
    // 结束点击时的坐标
    private var endPoint: CGPoint?
    
    // 开始值
    private var startValue: Float?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    
    /*
     *         // retrieve system volume
     float systemVolume = volumeViewSlider.value;
     
     // change system volume, the value is between 0.0f and 1.0f
     [volumeViewSlider setValue:1.0f animated:NO];
     
     // send UI control event to make the change effect right now.
     [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
     *
     */
    
    // 触摸开始
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let point = touch.location(in: self)
            delegate?.touchesBegan(point: point)
            
            startPoint = point
        }
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            let point = touch.location(in: self)
            delegate?.touchesEnded(point: point)
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        var point: CGPoint?
        for touch in touches {
            point = touch.location(in: self)
            delegate?.touchesMoved(point: point!)
        }
        // 计算手指移动的距离
        let panPoint = CGPoint(x: (point?.x)! - (startPoint?.x)!, y: (point?.y)! - (startPoint?.y)!)
        // 分析用户滑动的方向
        if direction == .none {
            if panPoint.x >= 30 || panPoint.x <= -30 {
                // 视频进度
                direction = .leftOrRight
            } else {
                // 音量和亮度
                direction = .upOrDown
            }
        }
        
        if direction == .none {
            return
        } else if direction == .upOrDown {
            // 音量和亮度
            if (startPoint?.x)! <= frame.size.width / 2.0 {
                // 调节亮度
                if panPoint.y < 0 {
                    // 增加亮度
                    UIScreen.main.brightness = CGFloat(startValue!) + CGFloat(-panPoint.y) / 30.0 / 10.0
                } else {
                    // 减少亮度
                    UIScreen.main.brightness = CGFloat(startValue!) - CGFloat(-panPoint.y) / 30.0 / 10.0
                }
            } else {
                // 音量
                if panPoint.y < 0 {
                    // 增加音量
                    volumeViewSlider?.setValue(startValue! + Float(-panPoint.y) / 30 / 10, animated: true)
//                    if startValue + Float(-panPoint.y) / 30 / 10 - volumeViewSlider?.value >= 0.1 {
//                        
//                        
//                    }
                } else {
                    // 减少音量
                    volumeViewSlider?.setValue(startValue! - Float(-panPoint.y) / 30 / 10, animated: true)
                }
            }
            
        } else {
            // 视频进度
        }
        //
        print(panPoint)
    }


}
