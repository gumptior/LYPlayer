//
//  LYPlayButton.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

import UIKit

class LYPlayButton: UIControl {
    
    // 播放状态
    enum PlayStatus {
        case play       // 播放
        case pause      // 暂停
        case stop
    }

    lazy var playStatusIcon: UIImageView = {
        let playStatusIcon = UIImageView()
        playStatusIcon.contentMode = .scaleAspectFit
        playStatusIcon.image = UIImage(named: "LYPlayer.bundle/LYPlayer_pause")
        
        return playStatusIcon
    }()
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(playStatusIcon)
        
        playStatusIcon.snp.makeConstraints { (make) in
            make.size.equalTo(20)
            make.center.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playStatus: PlayStatus = .pause {
        willSet {
            switch newValue {
            case .play:
                playStatusIcon.image = UIImage(named: "LYPlayer.bundle/LYPlayer_play")
            case .pause:
                playStatusIcon.image = UIImage(named: "LYPlayer.bundle/LYPlayer_pause")
            default:
                break
            }
        }
    }
}
