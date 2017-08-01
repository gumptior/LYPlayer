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
        
        backgroundColor = UIColor.red
        
        // 获取window
//        print(window!)
        
        // 将当前视图添加到windoiw上
        self.snp.makeConstraints { (make) in
//            make.center.equalTo()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MPVolumeView
    // 亮度调节的进度
    public var progress: CGFloat = 0
    
    // 亮度文本
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "亮度"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 13)
        
        return label
    }()
    
    // 图标
    lazy var image: UIImageView = {
        let brightnessImage = UIImageView()
        brightnessImage.image = UIImage(named: "LYPlayer_brightness@2x")
        
        return brightnessImage
    }()
    
    // 进度条
    lazy var slider: UISlider = {
        let slider = UISlider()
        
        
        return slider
    }()
    
    
}
