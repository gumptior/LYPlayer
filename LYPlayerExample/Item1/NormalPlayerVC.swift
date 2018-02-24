//
//  VideoViewController.swift
//  LYPlayerExample
//
//  Created by ly_coder on 2017/6/2.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit
import AVFoundation

class NormalPlayerVC: BaseViewController {

    
    // 显示状态栏
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // 状态栏设置为白色样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 显示导航栏
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 隐藏导航栏
//        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // pop手势
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setupUI()

        setupUIFrame()
    }
    
    // 视频播放器视图
    lazy var playerView: LYNormalPlayerView = {
        let playerView = LYNormalPlayerView(playerModel: self.playerModel)
        //
        playerView.delegate = self
        // 自动播放
        playerView.isAutoPlay = true
        // 继续上次进度播放
        playerView.isRecoveryPlay = false
        // 播放倍速
        playerView.rate = 2.0
        
        // 隐藏返回按钮
        //playerView.isHiddenBackButton = true
        return playerView
    }()
    
    // 播放器数据model
    lazy var playerModel: LYPlayerModel = {
        let playerModel = LYPlayerModel()
        let netURL = URL(string: "http://120.25.226.186:32812/resources/videos/minion_01.mp4")!
        playerModel.videoURL = netURL
        // Thor
        playerModel.title = "视频1"
        playerModel.placeholderImage = UIImage(named: "loading_bgView")
        
        return playerModel
    }()
    
    lazy var pushBtn: UIButton = {
        let pushBtn = UIButton(type: .custom)
        pushBtn.backgroundColor = .red
        pushBtn.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
        return pushBtn
    }()
    
    /** 设置UI */
    func setupUI() {
        // 添加视频播放器
        view.addSubview(playerView)
        
        // 添加跳转下个页面按钮
        view.addSubview(pushBtn)
    }
    
    /** 设置UIFrame */
    func setupUIFrame() {
        // 设置视频播放器位置、大小
        playerView.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(100)
            make.left.right.equalTo(view)
            make.height.equalTo(playerView.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
        
        // 设置Push按钮位置、大小
        pushBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
    //
    func pushAction() {
        // 暂停播放器
        playerView.player?.pause()
        
        // 跳转
        let VC = ViewController()
        navigationController?.pushViewController(VC, animated: true)
    }
}

// MARK: - LYPlayerViewDelegate
extension NormalPlayerVC: LYPlayerViewDelegate {
    
    func playerView(_ playerView: LYPlayerView, willRotate orientation: Orientation) {
        if orientation == .horizontal {
            navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    // 播放结束
    func playerView(_ playerView: LYPlayerView, willEndPlayAt item: AVPlayerItem) {
        
        print("播放结束：willEndPlayAt")
        
        let playerModel = LYPlayerModel()
        let netURL = URL(string: "http://120.25.226.186:32812/resources/videos/minion_02.mp4")!
        playerModel.videoURL = netURL
        // Thor
        playerModel.title = "视频2"
        playerModel.placeholderImage = UIImage(named: "loading_bgView")
        
        playerView.replaceCurrentPlayerModel(with: playerModel)
    }
}

extension NormalPlayerVC: UIGestureRecognizerDelegate {
    
}
