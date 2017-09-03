//
//  LYPlayerSlider.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

import UIKit

class LYPlayerSlider: UIControl {
    
    // 判断点击点是否在范围内
    private var isContains: Bool?
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        viewConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutPageSubviews()
    }

    // MARK: - private method
    func viewConfig() {
        self.addSubview(bufferedView)
        self.addSubview(noBufferView)
        self.addSubview(playProgressView)
        self.addSubview(dragImageView)
    }
    
    func layoutPageSubviews() {
        
        playProgressView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: playProgress * self.frame.size.width, height: 2))
        }

        bufferedView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 0, height: 2))
        }

        noBufferView.snp.makeConstraints { (make) in
            make.left.equalTo(bufferedView.snp.right)
            make.right.equalTo(self)
            make.centerY.equalTo(self)
            make.height.equalTo(2)
        }

        dragImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(playProgressView.snp.right).offset(-8)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
    
    // MARK: - setter and getter
    // 播放进度视图
    private lazy var playProgressView: UIView = {
        let playProgressView = UIView()
        return playProgressView
    }()
    
    // 缓冲进度视图
    private lazy var bufferedView: UIView = {
        let bufferedView = UIView()
        return bufferedView
    }()
    
    // 没有缓冲出来的部分
    private lazy var noBufferView: UIView = {
        let noBufferView = UIView()
        return noBufferView
    }()
    
    // 拖动的小圆点
    lazy var dragImageView: UIImageView = {
        let dragImageView = UIImageView()
        dragImageView.image = UIImage(named: "dot")
        dragImageView.isUserInteractionEnabled = true
        return dragImageView
    }()
    
    // 缓冲条的颜色
    var bufferedProgressColor: UIColor! {
        willSet {
            bufferedView.backgroundColor = newValue
        }
    }
    
    // 播放进度条的颜色
    var playProgressColor: UIColor! {
        willSet {
            playProgressView.backgroundColor = newValue
        }
    }
    
    // 未缓冲出来的颜色
    var noBufferProgressColor: UIColor! {
        willSet {
            noBufferView.backgroundColor = newValue
        }
    }
    
    // 视频缓冲进度
    var bufferedProgress: CGFloat = 0.0 {
        willSet {
            
//            let width = newValue * frame.size.width
//            bufferedView.frame.size.width = width
            
            bufferedView.snp.updateConstraints { (make) in
                make.width.equalTo(self).multipliedBy(newValue)
            }
        }
    }
    
    // 播放进度
    var playProgress: CGFloat = 0.0 {
        willSet {
            
            let width = newValue * frame.size.width
            playProgressView.frame.size.width = width
            
            // 不好使
//            playProgressView.snp.updateConstraints { (make) in
//                make.width.equalTo(self.snp.width)
//            }
        }
    }
    
    // MARK: - event response
    // 开始点击
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for touch in touches {
            
            let point = touch.location(in: self)
            isContains = dragImageView.frame.contains(point)
        }
    }
    // 手指在移动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            // 获取当前位置
            let point = touch.location(in: self)
            // 在小圆点内并且在self内时，设置当前进度
            if isContains! && point.x > 0 && point.x < frame.width {
                
                dragImageView.center.x = point.x
                playProgress = point.x / frame.width
                
            } else {
                
            }
        }
    }

}
