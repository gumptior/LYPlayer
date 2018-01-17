//
//  LYPlayer.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//


import UIKit
import AVFoundation
import MobileCoreServices

// 视频图像填充模式
enum LYPlayerContentMode {
    case resizeFit  // 比例缩放
    case resizeFitFill  // 填充视图
    case resize  // 默认
}


protocol LYPlayerDelegate {
    /** 获取视频总时长 */
    func player(_ player: AVPlayer, itemTotal time: CMTime)
    
    //func player(_ player: AVPlayer, willEndPlayAt item: AVPlayerItem)
}

open class LYPlayer: AVPlayer {
    
    var delegate: LYPlayerDelegate?
    
    deinit {
        
        // 清除应用通知
        removeAppNotification()
    }
    public override init() {
        super.init()
    }
    public override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
        addObserverItem(with: item)
    }
    
    // 是否正在播放
    var isPlaying: Bool = false
}

extension LYPlayer {
    
    // 播放
    open override func play() {
        super.play()
        
        isPlaying = true
        addAppNotification()
    }
    
    // 暂停
    open override func pause() {
        super.pause()
        
        isPlaying = false
    }
    
    // 停止
    open func stop() {
        currentItem?.seek(to: kCMTimeZero)
        pause()
//        removeObserverItem(with: currentItem)
    }
    
    // 重新播放新的item
    open override func replaceCurrentItem(with item: AVPlayerItem?) {
        // currentItem
        // item
        super.replaceCurrentItem(with: item)
        addObserverItem(with: item)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath! {
        case "status":
            // 状态改变时调用
            switch currentItem!.status {
            case .unknown:
                // 未知错误
                print("未知错误")
                break
            case .failed:
                // 失败
                print("失败")
                break
            case .readyToPlay:
                // 准备播放
                print("准备播放")
                delegate?.player(self, itemTotal: currentItem!.duration)
                break
            }
            break
        case "loadedTimeRanges":
            // 缓存进度的改变时调用
            // 获取缓冲区域
            let timeRange = currentItem?.loadedTimeRanges.first?.timeRangeValue
            
            print(timeRange?.duration as Any)
        case "playbackBufferEmpty":
            // 播放区域缓存为空时调用
            print("播放区域缓存为空时调用")
        case "playbackLikelyToKeepUp":
            // 缓存可以播放的时候调用
            print("缓存可以播放的时候调用")
        default:
            break
        }
    }
}

// MARK: - AVPlayerItem Observer
extension LYPlayer {
    // 添加观察者
    fileprivate func addObserverItem(with item: AVPlayerItem?) {
        print(currentItem!)
        // 观察播放状态
        item?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        // 观察已经加载完的时间范围
        item?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        // seekToTime后，缓冲数据为空，而且有效时间内数据无法补充，播放失败
        item?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        
        //seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
        item?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    }
    
    // 移除监听
    fileprivate func removeObserverItem(with item: AVPlayerItem?) {
        item?.removeObserver(self, forKeyPath: "status", context: nil)
        item?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        item?.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        item?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
    }
}

// MARK: - AVPlayerItem Notification
extension LYPlayer {
    // 添加播放项目通知
    fileprivate func addNotificationItem(with item: AVPlayerItem?) {
        // 添加视频播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime_notification), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        // 添加视频异常中断通知
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled_notification), name: Notification.Name.AVPlayerItemPlaybackStalled, object: item)
    }
    
    // 移除播放项目通知
    fileprivate func removeNotificationItem(with item: AVPlayerItem?) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemPlaybackStalled, object: item)
    }
}

extension LYPlayer {
    
    // 视频播放结束
    @objc func didPlayToEndTime_notification() {
        print("播放结束")
    }
    
    // 视频异常中断
    @objc func playbackStalled_notification() {
        print("异常中断")
    }
    
    // 程序将要进入后台
    @objc func willEnterBcakground_notification() {
        print("将要进入后台")
        pause()
    }
    
    // 程序已经返回前台
    @objc func didEnterPlayGround_notification() {
        print("已经返回前台")
    }
}

// MARK: - APP Notification
extension LYPlayer {
    /** 添加应用进入前后台通知 */
    fileprivate func addAppNotification() {
        // 添加程序将要进入后台通知
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBcakground_notification), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        // 添加程序已经返回前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterPlayGround_notification), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    /** 移除应用进入前后台通知 */
    fileprivate func removeAppNotification() {
        // 移除程序将要进入后台通知
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
        // 移除程序已经返回前台通知
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
}

