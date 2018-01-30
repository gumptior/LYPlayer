//
//  LYSeekView.swift
//  LYPlayerExample
//
//  Created by LY_Coder on 2018/1/30.
//  Copyright © 2018年 LYCoder. All rights reserved.
//

import UIKit
import AVFoundation

class LYSeekView: UIView {
    
    static var shared = LYSeekView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 8.5
        self.layer.masksToBounds = true
        
        setupUI()
        
        setupUIFrame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** 时间转分秒 */
    func timeToSeconds(time: CMTime?) -> String {
        // 计算分钟
        let minute = Int(time?.seconds ?? 0.0) / 60
        // 计算秒
        let seconds = Int(time?.seconds ?? 0.0) % 60
        
        return String(format: "%02d:%02d", arguments: [minute, seconds])
    }
    
    /** 调整播放进度 */
    func seek(to time: CMTime, with currentTime: CMTime, item: AVPlayerItem) {
        self.alpha = 1
        
        // 修改后的时间字符串
        let toTimeString = timeToSeconds(time: time)
        // 当前的时间字符串
        let totalTimeString = timeToSeconds(time: item.duration)
        timeLabel.text = "\(toTimeString)/\(totalTimeString)"
        
        let attributeString = NSMutableAttributedString(string: "\(toTimeString)/\(totalTimeString)")
        attributeString.addAttributes([NSForegroundColorAttributeName: UIColor.white], range: NSRange(location: 0, length: 5))
        timeLabel.attributedText = attributeString
        
        // 设置图标
        if time.seconds > currentTime.seconds {
            // 快进
            iconView.image = UIImage("LYPlayer_forward")
        } else {
            // 快退
            iconView.image = UIImage("LYPlayer_backward")
        }
        
        // 获取图片
        let generator = AVAssetImageGenerator(asset: item.asset)
        
        // 取消快速滑动时 尚未提供的图像
        generator.cancelAllCGImageGeneration()
        
        weak var weakSelf = self
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)], completionHandler: { (requestedTime, img, actualTime, result, error) in
            
            if result == AVAssetImageGeneratorResult.succeeded {
                // 回主线程
                DispatchQueue.main.async(execute: {
                    weakSelf?.videoImgView.image = UIImage(cgImage: img!)
                })
            }
            
            if result == AVAssetImageGeneratorResult.failed {
                print("Failed with error:\(String(describing: error?.localizedDescription))")
            }
            
            if result == AVAssetImageGeneratorResult.cancelled {
                print("AVAssetImageGeneratorCancelled")
            }
        })
        
        // 消失动画
        UIView.animate(withDuration: 1.0, delay: 1.7, options: .curveLinear, animations: {
            self.alpha = 0.0
        }) { (false) in }
    }
    
    
    // 获取window
    lazy var keyWindow: UIWindow = {
        let keyWindow = UIApplication.shared.keyWindow!
        
        return keyWindow
    }()
    
    lazy var visual: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .light)
        let visual = UIVisualEffectView(effect: blur)
        
        return visual
    }()
    
    lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        
        return iconView
    }()
    
    lazy var timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textAlignment = .right
        
        return timeLabel
    }()
    
    lazy var videoImgView: UIImageView = {
        let videoImgView = UIImageView()
        videoImgView.backgroundColor = UIColor.black
        videoImgView.layer.cornerRadius = 8.5
        videoImgView.layer.masksToBounds = true
        
        return videoImgView
    }()
    
    func setupUI() {
        addSubview(visual)
        
        keyWindow.addSubview(self)
        
        addSubview(iconView)
        
        addSubview(timeLabel)
        
        addSubview(videoImgView)
    }
    
    func setupUIFrame() {
        // 将当前视图添加到windoiw上
        self.snp.makeConstraints { (make) in
            make.center.equalTo(keyWindow)
            make.size.equalTo(CGSize(width: 180, height: 155))
        }
        
        visual.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        iconView.snp.makeConstraints { (make) in
            make.top.left.equalTo(self).offset(10)
            make.size.equalTo(CGSize(width: 30, height: 25))
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(15)
            make.size.equalTo(CGSize(width: 100, height: 15))
        }
        
        videoImgView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(50, 10, 10, 10))
        }
    }
}
