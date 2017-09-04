//
//  VideoViewController.swift
//  LYPlayerExample
//
//  Created by ly_coder on 2017/6/2.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

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
    
    // 视频播放器
    lazy var playerView: LYPlayerView = {
        let playerView = LYPlayerView(url: self.url)
        playerView.delegate = self as? LYPlayerViewDelegate
        
        return playerView
    }()
    
    // 创建URL对象
    lazy var url: URL = {
        // 网络视频
        let netURL = URL(string: "http://flv2.bn.netease.com/tvmrepo/2017/3/K/I/ECF9KFDKI/SD/ECF9KFDKI-mobile.mp4")!
        
        // 沙盒（使用前要再沙盒中写入视频资源）
        let sandboxFilePath = "\(NSHomeDirectory())/Documents/video.mp4"
        let sandboxURL = URL(fileURLWithPath: sandboxFilePath)
        
        // 应用包
        let bundleFilePath = "\(Bundle.main.bundlePath)/video.mp4"
        let bundleURL = URL(fileURLWithPath: bundleFilePath)
        
        
        // return netURL
        // return sandboxURL
        return bundleURL
    }()
    
    // 下一个按钮点击事件
    @IBAction func nextAction(_ sender: UIButton) {
        playerView.player.url = URL(string: "http://ongelo4u0.bkt.clouddn.com/15011427040376xWtn.mp4")
    }
}
