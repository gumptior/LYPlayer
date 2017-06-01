//
//  ViewController.swift
//  LYPlayerExample
//
//  Created by 你个LB on 2017/5/22.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    }
    
    // 播放器视图
    lazy var playerView: LYPlayerView = {
        let playerView = LYPlayerView(player: self.player)
        playerView.delegate = self
        
        return playerView
    }()
    
    // 播放器
    lazy var player: LYPlayer = {
        let player = LYPlayer(url: self.url)
        player.delegate = self
        
        return player
    }()
    
    // 视频地址
    lazy var url: URL = {
        let url = URL(string: "http://flv2.bn.netease.com/tvmrepo/2017/3/K/I/ECF9KFDKI/SD/ECF9KFDKI-mobile.mp4")
        
        return url!
    }()
}

extension ViewController: LYPlayerDelegate, LYPlayerViewDelegate {
    func playerView(playerView: LYPlayerView, didClickFillScreen button: UIButton) {
        
    }
}
