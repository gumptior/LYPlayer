//
//  LYBrightnessView.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

import UIKit

class LYBrightnessView: LYShadeView {
    
    // 单例
    static let shard = LYBrightnessView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 亮度文本
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "亮度"
        titleLabel.textColor = UIColor.black
        titleLabel.alpha = 0.7
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    // 图标
    lazy var brightnessIcon: UIImageView = {
        let brightnessIcon = UIImageView()
        brightnessIcon.image = UIImage.init("LYPlayer_brightness")
        
        return brightnessIcon
    }()
    
    // 进度条
    // 进度条背景图片
    lazy var progressBgImgView: UIImageView = {
        let progressBgImgView = UIImageView()
        progressBgImgView.image = UIImage.init("LYPlayer_slider")
        
        return progressBgImgView
    }()
    
    // 进度条遮背景视图
    lazy var progressView: UIView = {
        let progressView = UIView()
        progressView.backgroundColor = UIColor(red: 30 / 255, green: 30 / 255, blue: 30 / 255, alpha: 1)
        
        return progressView
    }()
    
    // 设置UI样式
    override func setupUI() {
        super.setupUI()
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(12)
            make.left.right.equalTo(self)
            make.height.equalTo(16)
        }
        
        addSubview(brightnessIcon)
        brightnessIcon.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(70)
        }
        
        addSubview(progressBgImgView)
        progressBgImgView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-16)
            make.left.equalTo(self).offset(13)
            make.right.equalTo(-13)
        }
        
        progressBgImgView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.edges.equalTo(progressBgImgView)
        }
    }
    
    // MPVolumeView
    // 亮度调节的进度
    public var progress: CGFloat = 0 {
        willSet {
            self.alpha = 1
            // 计算遮罩视图的宽度
            var width = progressBgImgView.frame.width * (1 - newValue)
            
            if width < 0 {
                // 亮度最大
                width = 0
            } else if width > progressBgImgView.frame.width {
                // 亮度最小
                width = progressBgImgView.frame.width
            }
            
            progressView.frame.size.width = width
            progressView.frame.origin.x = progressBgImgView.frame.width - width
            
            // 消失动画
//            UIView.animate(withDuration: 1.0, delay: 1.7, options: .curveLinear, animations: {
//                self.alpha = 0.0
//            }) { (false) in }
            
            UIView.animate(withDuration: 1.0, delay: 1.7, options: .curveLinear, animations: {
                self.alpha = 0.0
            }) { (true) in
                print("动画完成了")
            }
        }
    }
    

}
