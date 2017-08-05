//
//  LYBrightnessView.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

import UIKit

class LYBrightnessView: UIView {
    
    // 单例
    static let shard = LYBrightnessView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 8.5
        self.layer.masksToBounds = true
        
        setupUI()
        
    }
    
    // 获取window
    lazy var keyWindow: UIWindow = {
        let keyWindow = UIApplication.shared.keyWindow!
        
        return keyWindow
    }()
    
    // 设置UI样式
    func setupUI() {
        keyWindow.addSubview(self)
        
        // 将当前视图添加到windoiw上
        self.snp.makeConstraints { (make) in
            make.center.equalTo(keyWindow)
            make.size.equalTo(CGSize(width: 155, height: 155))
        }
        
        let blur = UIBlurEffect(style: .light)
        let visual = UIVisualEffectView(effect: blur)
        
        addSubview(visual)
        visual.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(12)
            make.left.right.equalTo(self)
            make.height.equalTo(16)
        }
        
        addSubview(image)
        image.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(70)
        }
        
        addSubview(progressBgImgView)
        progressBgImgView.addSubview(progressView)
        
        progressBgImgView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-16)
            make.left.equalTo(self).offset(13)
            make.right.equalTo(-13)
        }
        
        progressView.snp.makeConstraints { (make) in
            make.edges.equalTo(progressBgImgView)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            UIView.animate(withDuration: 1.0, delay: 1.7, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
                self.alpha = 0.0
            }) { (false) in
            }
        }
    }
    
    // 亮度文本
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "亮度"
        label.textColor = UIColor.black
        label.alpha = 0.7
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        
        
        return label
    }()
    
    // 图标
    lazy var image: UIImageView = {
        let brightnessImage = UIImageView()
        brightnessImage.image = UIImage(named: "LYPlayer.bundle/LYPlayer_brightness")
        
        return brightnessImage
    }()
    
    
    // 进度条
    // 进度条背景图片
    lazy var progressBgImgView: UIImageView = {
        let progressBgImgView = UIImageView()
        progressBgImgView.image = UIImage(named: "LYPlayer.bundle/LYPlayer_slider")
        
        return progressBgImgView
    }()
    
    // 进度条遮背景视图
    lazy var progressView: UIView = {
        let progressView = UIView()
        progressView.backgroundColor = UIColor(red: 30 / 255, green: 30 / 255, blue: 30 / 255, alpha: 1)
        
        return progressView
    }()
}
