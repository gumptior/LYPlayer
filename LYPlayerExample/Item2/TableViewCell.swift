//
//  TableViewCell.swift
//  LYPlayerExample
//
//  Created by LY_Coder on 2017/11/28.
//  Copyright © 2017年 LYCoder. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    var urlString: String = ""
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        // 添加视频播放器
//        contentView.addSubview(playerView)
//        // 设置视频播放器位置、大小
//        playerView.snp.makeConstraints { (make) in
//            make.top.equalTo(contentView)
//            make.left.right.equalTo(contentView)
//        make.height.equalTo(playerView.snp.width).multipliedBy(9.0/16.0).priority(750)
//        }
//
//        let url = URL(string: urlString)
//        player.replaceCurrentUrl(with: url)
    }
    
    // 播放视图
//    lazy var playerView: LYHeadlineView = {
//        let playerView = LYHeadlineView(player: self.player)
//
//        return playerView
//    }()
    
    // 播放器
//    lazy var player: LYPlayer = {
//        let player = LYPlayer()
//
//        return player
//    }()
}
