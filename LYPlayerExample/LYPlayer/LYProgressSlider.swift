//
//  LYProgressSlider.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

import UIKit

class LYProgressSlider: UIControl {
    
    // 判断点击点是否在范围内
    private var isContains: Bool?
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        setupUIFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** 缓冲条的颜色 */
    public var bufferedProgressColor: UIColor! {
        willSet {
            bufferedView.backgroundColor = newValue
        }
    }
    
    /** 播放进度条的颜色 */
    public var playProgressColor: UIColor! {
        willSet {
            playProgressView.backgroundColor = newValue
        }
    }
    
    /** 未缓冲出来的颜色 */
    public var noBufferProgressColor: UIColor! {
        willSet {
            noBufferView.backgroundColor = newValue
        }
    }
    
    /** 视频缓冲进度 */
    public var bufferedProgress: CGFloat = 0.0 {
        willSet {
            // 在拖动时停止赋值
            if isTracking {
                return
            }
            bufferedView.snp.updateConstraints { (make) in
                make.width.equalTo(newValue * frame.size.width)
            }
        }
    }
    
    /** 播放进度 */
    public var playProgress: CGFloat = 0.0 {
        didSet {
            // 在拖动时停止赋值
            if playProgress.isNaN || playProgress > 1.0
            || isTracking {
                return
            }
            dragImageView.snp.updateConstraints({ (make) in
                make.centerX.equalTo(playProgress * frame.size.width)
            })
        }
    }
    
    // MARK: - setter and getter
    // 播放进度视图
    private lazy var playProgressView: UIView = {
        let playProgressView = UIView()
        playProgressView.backgroundColor = UIColor.red
        
        return playProgressView
    }()
    
    // 缓冲进度视图
    private lazy var bufferedView: UIView = {
        let bufferedView = UIView()
        bufferedView.backgroundColor = UIColor.blue
        
        return bufferedView
    }()
    
    // 没有缓冲出来的部分
    private lazy var noBufferView: UIView = {
        let noBufferView = UIView()
        noBufferView.backgroundColor = UIColor.white
        
        return noBufferView
    }()
    
    // 拖动的小圆点
    lazy var dragImageView: UIImageView = {
        let dragImageView = UIImageView()
        dragImageView.image = UIImage(named: "dot")
        dragImageView.isUserInteractionEnabled = true
        dragImageView.backgroundColor = UIColor.cyan
        
        return dragImageView
    }()
    
    // MARK: - event response
    // 开始点击
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for touch in touches {
            
            let point = touch.location(in: self)
            isContains = dragImageView.frame.contains(point)
        }
    }

    // MARK: - private method
    fileprivate func setupUI() {
        addSubview(bufferedView)
        addSubview(noBufferView)
        addSubview(playProgressView)
        addSubview(dragImageView)
    }
    
    fileprivate func setupUIFrame() {
        dragImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.centerX.equalTo(0)
            make.size.equalTo(CGSize(width: 14, height: 14))
        }
        
        playProgressView.snp.makeConstraints { (make) in
            make.left.centerY.equalTo(self)
            make.right.equalTo(dragImageView.snp.centerX)
            make.height.equalTo(2)
        }

        bufferedView.snp.makeConstraints { (make) in
            make.left.centerY.equalTo(self)
            make.height.equalTo(2)
            make.width.equalTo(0)
        }

        noBufferView.snp.makeConstraints { (make) in
            make.centerY.right.equalTo(self)
            make.left.equalTo(dragImageView.snp.centerX)
            make.height.equalTo(2)
        }
    }
    
    // 手指在移动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesMoved(touches, with: event)
        for touch in touches {
            // 获取当前位置
            let point = touch.location(in: self)
            // 在小圆点内并且在self内时，设置当前进度
            if point.x > 0 && point.x < frame.width {
                dragImageView.center.x = point.x
                playProgress = point.x / frame.width
            }
//                else {
//
//            }
        }
    }
}
