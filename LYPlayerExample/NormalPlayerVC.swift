//
//  VideoViewController.swift
//  LYPlayerExample
//
//  Created by ly_coder on 2017/6/2.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit

class NormalPlayerVC: UIViewController {

    // 显示状态栏
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // 状态栏设置为白色样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // 隐藏导航栏
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // 显示导航栏
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加视频播放器
        view.addSubview(playerView)
        // 设置视频播放器位置、大小
        playerView.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.right.equalTo(view)
            make.height.equalTo(playerView.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
    }
    
    // 创建URL对象
    lazy var url: URL = {
        // 网络视频
        let netURL = URL(string: "http://ow41vz64v.bkt.clouddn.com/%E8%B5%B5%E6%96%B9%E5%A9%A7%20-%20%E5%B0%BD%E5%A4%B4%20.mp4")!
        
        // 沙盒（使用前要再沙盒中写入视频资源）
        let sandboxFilePath = "\(NSHomeDirectory())/Documents/video.mp4"
        let sandboxURL = URL(fileURLWithPath: sandboxFilePath)
        
        // 应用包
        let bundleFilePath = "\(Bundle.main.bundlePath)/video.mp4"
        let bundleURL = URL(fileURLWithPath: bundleFilePath)
        
//         return netURL
//         return sandboxURL
         return bundleURL
    }()
    
    // 播放视图
    lazy var playerView: LYNormalPlayerView = {
        let playerView = LYNormalPlayerView(playerModel: self.playerModel)
        // 自动播放
        playerView.isAutoPlay = false
        // 播放倍速
        playerView.rate = 2.0
        return playerView
    }()
    
    lazy var playerModel: LYPlayerModel = {
        let playerModel = LYPlayerModel()
        let netURL = URL(string: "http://ow41vz64v.bkt.clouddn.com/%E8%B5%B5%E6%96%B9%E5%A9%A7%20-%20%E5%B0%BD%E5%A4%B4%20.mp4")!
        playerModel.videoURL = netURL
        playerModel.title = "哈哈哈"
        playerModel.placeholderImage = UIImage(named: "loading_bgView")
        
        return playerModel
    }()
}
