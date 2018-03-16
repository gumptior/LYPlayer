//
//  LYShadeView.swift
//  LYPlayerExample
//
//  Created by LY_Coder on 2018/2/27.
//  Copyright © 2018年 LYCoder. All rights reserved.
//

import UIKit

class LYShadeView: UIView {

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 8.5
        self.layer.masksToBounds = true
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 获取window
    lazy var keyWindow: UIWindow = {
        let keyWindow = UIApplication.shared.keyWindow!
        
        return keyWindow
    }()
    
    // 高斯模糊
    lazy var visualEffectView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blur)
        
        return visualEffectView
    }()
    
    // 设置UI样式
    func setupUI() {
        
        // 将当前视图添加到windoiw上
        keyWindow.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.center.equalTo(keyWindow)
            make.size.equalTo(CGSize(width: 155, height: 155))
        }
        
        addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
}
