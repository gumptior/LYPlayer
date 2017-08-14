//
//  VideoViewController.swift
//  LYPlayerExample
//
//  Created by ly_coder on 2017/6/2.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(playerView)
        // 播放器
        playerView.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.right.equalTo(view)
            make.height.equalTo(playerView.snp.width).multipliedBy(9.0/16.0).priority(750)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // 播放器视图
    lazy var playerView: LYPlayerView = {
        let playerView = LYPlayerView(urlString: "http://flv2.bn.netease.com/tvmrepo/2017/3/K/I/ECF9KFDKI/SD/ECF9KFDKI-mobile.mp4")
        playerView.delegate = self as? LYPlayerViewDelegate
        
        return playerView
    }()
    
    deinit {
        
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        playerView.player.url = URL(string: "http://ongelo4u0.bkt.clouddn.com/15011427040376xWtn.mp4")
    }
}
