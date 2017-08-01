//
//  LYPlayButton.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

import CoreGraphics
import QuartzCore
import UIKit

class LYPlayButton: UIControl {
    
    // 播放状态
    enum PlayStatus {
        case play       // 播放
        case pause      // 暂停
    }
    
    // MARK: - private property
    // 左右两条线
    private var top: CAShapeLayer! = CAShapeLayer()
    private var bottom: CAShapeLayer! = CAShapeLayer()
    private var rotate: CAShapeLayer! = CAShapeLayer()
    // 菜单的起点和终点
    private let menuStrokeStart: CGFloat = 0.325
    private let menuStrokeEnd: CGFloat = 0.9
    // 中线的起点和重点
    private let playStrokeStart: CGFloat = 0.028
    private let playStrokeEnd: CGFloat = 0.111
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 绘制左右两条线
        self.top.path = leftStroke
        self.bottom.path = rightStroke
        self.rotate.path = outline
        
        // 设置layer的相关属性
        for layer in [self.top, self.bottom, self.rotate] {
            // 填充颜色
            layer?.fillColor = nil
            // 线条的颜色
            layer?.strokeColor = UIColor.white.cgColor
            // 线条宽度
            layer?.lineWidth = 4
            // 两条线段相交时锐角斜面长度
            layer?.miterLimit = 4
            // 线条首尾的外观
            layer?.lineCap = kCALineCapRound

            // 设置layer的bounds
            let strokingPath = CGPath(__byStroking: (layer?.path!)!, transform: nil, lineWidth: 4, lineCap: .round, lineJoin: .miter, miterLimit: 4)
            layer?.bounds = (strokingPath?.boundingBoxOfPath)!
            // 设置行为
            layer?.actions = [
                "strokeStart": NSNull(),
                "strokeEnd": NSNull(),
                "transform": NSNull()
                
            ]
            
            self.layer.addSublayer(layer!)
        }
        
        // 设置左线的锚点和位置
        self.top.anchorPoint = CGPoint(x: 1, y: 1)
        self.top.position = CGPoint(x: 40, y: 19.25)
        // 设置右线的锚点和位置
        self.bottom.anchorPoint = CGPoint(x: 1, y: 0)
        self.bottom.position = CGPoint(x: 40, y: 18)
        // 设置中线的位置和起点和终点
        self.rotate.position = CGPoint(x: 29, y: 18)
        self.rotate.strokeStart = playStrokeStart
        self.rotate.strokeEnd = playStrokeEnd

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setter and getter
    
    // 画短直线 -> play
    let leftStroke: CGPath = {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 2, y: 2))
        path.addLine(to: CGPoint(x: 2, y: 15))
        return path
    }()
    private let rightStroke: CGPath = {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 2, y: 12))
        path.addLine(to: CGPoint(x: 2, y: 25))
        return path
    }()
    // 外边框圆 -> 中间
    private let outline: CGPath = {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 29, y: 0))
        // 添加曲线
        path.addCurve(to: CGPoint(x: 27, y: 53), control1: CGPoint(x: 27, y: 31), control2: CGPoint(x: 27, y: 43.75))
        path.addCurve(to: CGPoint(x: 41.5, y: 3), control1: CGPoint(x: 75.92, y: 24.75), control2: CGPoint(x: 62.97, y: 3))
        path.addCurve(to: CGPoint(x: 16.5, y: 27), control1: CGPoint(x: 28.66, y: 3), control2: CGPoint(x: 16.5, y: 13.16))
        path.addCurve(to: CGPoint(x: 41.5, y: 52), control1: CGPoint(x: 16.5, y: 40.84), control2: CGPoint(x: 27.66, y: 52))
        path.addCurve(to: CGPoint(x: 66.5, y: 27), control1: CGPoint(x: 55.34, y: 52), control2: CGPoint(x: 66.5, y: 40.84))
        path.addCurve(to: CGPoint(x: 41.5, y: 3), control1: CGPoint(x: 66.5, y: 13.16), control2: CGPoint(x: 56.89, y: 3))
        path.addCurve(to: CGPoint(x: 16.5, y: 27), control1: CGPoint(x: 27.66, y: 3), control2: CGPoint(x: 16.5, y: 13.16))

        return path
    }()
    
    var playStatus: PlayStatus = .pause {
        didSet {
            let strokeStart = CABasicAnimation(keyPath: "strokeStart")
            let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            
            // 动画
            if self.playStatus == .play {
                strokeStart.toValue = menuStrokeStart
                strokeStart.duration = 0.2
                strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
                
                strokeEnd.toValue = menuStrokeEnd
                strokeEnd.duration = 0.3
                strokeEnd.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, -0.4, 0.5, 1)
            } else {
                strokeStart.toValue = playStrokeStart
                strokeStart.duration = 0.2
                strokeStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0, 0.5, 1.2)
                strokeStart.beginTime = CACurrentMediaTime() + 0.1
                strokeStart.fillMode = kCAFillModeBackwards
                
                strokeEnd.toValue = playStrokeEnd
                strokeEnd.duration = 0.3
                strokeEnd.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.3, 0.5, 0.9)
            }
            
            self.rotate.ocb_applyAnimation(strokeStart)
            self.rotate.ocb_applyAnimation(strokeEnd)
        
            // 设置竖线的变化
            let topTransform = CABasicAnimation(keyPath: "transform")
            topTransform.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, -0.8, 0.5, 1.85)
            topTransform.duration = 0.2
            topTransform.fillMode = kCAFillModeBackwards
            
            let bottomTransform = topTransform.copy() as! CABasicAnimation
            
            if self.playStatus == .play {
                let translation = CATransform3DMakeTranslation(-2, 0, 0)
                
                topTransform.toValue = NSValue(caTransform3D: CATransform3DRotate(translation, -0.65, 0, 0, 1))
                topTransform.beginTime = CACurrentMediaTime() + 0.25
                
                bottomTransform.toValue = NSValue(caTransform3D: CATransform3DRotate(translation, 0.84, 0, 0, 1))
                bottomTransform.beginTime = CACurrentMediaTime() + 0.25
            } else {
                topTransform.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                topTransform.beginTime = CACurrentMediaTime() + 0.05
                
                bottomTransform.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                bottomTransform.beginTime = CACurrentMediaTime() + 0.05
            }
            
            self.top.ocb_applyAnimation(topTransform)
            self.bottom.ocb_applyAnimation(bottomTransform)
        }
        
    }
}
