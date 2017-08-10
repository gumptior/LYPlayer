//
//  LYPlayer.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

// 可以试试  写成单例类

// NSTimeInterval类型

import UIKit
import AVFoundation

typealias LBVideoInfo = (String, Float) -> Void

typealias LBVideoProgress = (Float, Float, LBPlayerState) -> Void

// 视频图像填充模式
public enum LBPlayerContentMode {
    case resizeFit  // 比例缩放
    case resizeFitFill  // 填充视图
    case resize  // 默认
}

// 播放状态
public enum LBPlayerState {
    case failed  // 播放失败
    case buffering  // 缓冲中
    case playing  // 播放中
    case pausing  // 暂停中
    case stopped  // 停止播放
}

protocol LYPlayerDelegate {
    
//    // 视频将要播放
//    func player(_ LYPlayer: LYPlayer, willPlayItemAt item: AVPlayerItem)
//    
//    // 视频正在播放
//    func player(_ LYPlayer: LYPlayer, playingItemAt item: AVPlayerItem, playProgress: CGFloat)
//    
//    // 视频将要结束播放
//    func playerWillFinishPlay(_ player: LYPlayer, willEndPlayAt item: AVPlayerItem)
//    
//    // 视频暂停中
//    func playerPause(_ player: LYPlayer)
//    
//    // 视频播放失败
//    func playerFailure(_ player: LYPlayer, erroe: Error)
}

extension LYPlayerDelegate {
    
}

class LYPlayer: NSObject {
    
    // 播放状态
    public var state: LBPlayerState = .stopped {
        willSet {
            print(newValue)
        }
    }
    
    // 重新播放
    public func replay(url: URL) {

    }
    
    // URL地址
    public var url = URL(string: "") {
        willSet {
            if url == nil {
                // 第一次播放视频
            } else {
                // 重新播放新视频
                if state == .stopped {
                    
                } else {
                    stop()
                }
                asset = AVAsset(url: newValue!)
                playerItem = AVPlayerItem(asset: asset)
                player.replaceCurrentItem(with: playerItem)
            }
        }
        didSet {
            addObserve()
            addNotificationCenter()
        }
    }
    
    // 单例
    static let shard = LYPlayer()
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 初始化方法
    override init() { super.init() }
    
    // 视频信息
    static private var videoInfo: LBVideoInfo?
    
    // 视频进度
    static private var videoProgress: LBVideoProgress?
    
    // 是否正在播放
    public var isPlaying: Bool = false
    
    // 刷新进度 - 定时器
    private var displayLink: CADisplayLink?
    
    // 已经缓存时长
    private var cacheSeconds: Float = 0
    
    // 总时长
    private var totalSeconds: Float = 0.0 {
        willSet {
            LYPlayer.videoInfo!("视频标题", newValue)
        }
    }
    
    // 已经播放时长
    private var currentSeconds: Float = 0 {
        willSet {
            LYPlayer.videoProgress!(newValue, cacheSeconds, state)
        }
    }
    
    // MARK: - Public Methods
    
    // 播放
    public func play() {
        player.play()
        starRefreshProgress()
        state = .playing
    }
    
    // 暂停
    public func pause() {
        player.pause()
        stopRefreshProgress()
        state = .pausing
    }
    
    // 停止
    public func stop() {
        playerItem.seek(to: kCMTimeZero)
        pause()
        removeObserve()
        removeNotificationCenter()
        state = .stopped
    }
    
    deinit {
        print("---结束了---")
    }
    
    // 跳转到某个播放时间段
    public func seekToSeconds(seconds: Float) {
        print(seconds)
        
        let seekToSeconds = CMTime(seconds: Double(seconds), preferredTimescale: 60)
        playerItem.seek(to: seekToSeconds)
    }
    
    // 视频信息
    public class func videoInfo(complete: @escaping LBVideoInfo) {
        videoInfo = complete
    }
    
    // 视频进度
    public class func videoProgress(complete: @escaping LBVideoProgress) {
        videoProgress = complete
    }

    // MARK: - Private Methods
    
    // 开始刷新进度
    public func starRefreshProgress() {
        displayLink = CADisplayLink(target: self, selector: #selector(refreshProgressAction))
        displayLink?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }
    
    // 停止刷新进度
    public func stopRefreshProgress() {
        displayLink?.invalidate()
    }
    
    // 添加观察者
    fileprivate func addObserve() {
        // 观察播放状态
        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        // 观察加载完毕的时间范围
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        
        // seekToTime后，缓冲数据为空，而且有效时间内数据无法补充，播放失败
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        
        //seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
    }
    
    // 移除监听
    fileprivate func removeObserve() {
        playerItem.removeObserver(self, forKeyPath: "status", context: nil)
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
    }
    
    // 添加通知中心
    fileprivate func addNotificationCenter() {
        // 添加视频播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime_notification), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        // 添加视频异常中断通知
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled_notification), name: Notification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        
        // 添加程序将要进入后台通知
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBcakground_notification), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        // 添加程序已经返回前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterPlayGround_notification), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    // 移除通知中心
    fileprivate func removeNotificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    // 视频播放图层
    public lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: self.player)
        
        return playerLayer
    }()
    
    // 播放器对象
    fileprivate lazy var player: AVPlayer = {
        let player = AVPlayer(playerItem: self.playerItem)
        
        return player
    }()
    
    // 视频项
    fileprivate lazy var playerItem: AVPlayerItem = {
        let playerItem = AVPlayerItem(asset: self.asset)
        
        return playerItem
    }()
    
    // 资源
    fileprivate lazy var asset: AVAsset = {
        let asset = AVAsset(url: self.url!)
        
        return asset
    }()
    
//    // URL地址数组
//    lazy var urlArray: [URL] = {
//        let urlArray: [URL] = []
//        return urlArray
//    }()
    
    // MARK: - IBActions
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // 创建局部的PlayerItem
        let observePlayerItem = object as? AVPlayerItem
        
        switch keyPath! {
        case "status":
            // 三种播放状态  1.unknown  2.readyToPlay  3.failed
            if observePlayerItem?.status == .readyToPlay {
                totalSeconds = Float((observePlayerItem?.duration.value)!) / Float((observePlayerItem?.duration.timescale)!)
            } else if observePlayerItem?.status == .failed || observePlayerItem?.status == .unknown {
                replay(url: url!)
            }
        case "loadedTimeRanges":
            // 播放器的缓存进度
            let loadedTimeRanges = observePlayerItem?.loadedTimeRanges
            let timeRange = loadedTimeRanges?.first?.timeRangeValue  // 获取缓冲区域
            let startSeconds = CMTimeGetSeconds(timeRange!.start)
            let durationSeconds = CMTimeGetSeconds(timeRange!.duration)
            cacheSeconds = Float(startSeconds + durationSeconds)  // 计算缓存总进度
        case "playbackBufferEmpty":
            // 监听播放器在缓冲数据的状态
            print("缓冲不足")
            pause()
        case "playbackLikelyToKeepUp":
            // 由于 AVPlayer 缓存不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
            // 判断是否有缓冲数据
            if cacheSeconds == 0 {
                return
            }
            print("缓冲🐶了")
            play()
        default:
            break
        }
    }
    
    // 视频播放结束
    func didPlayToEndTime_notification() {
    }
    
    // 视频异常中断
    func playbackStalled_notification() {
    }
    
    // 程序将要进入后台
    func willEnterBcakground_notification() {
        pause()
    }
    
    // 程序已经返回前台
    func didEnterPlayGround_notification() {
        play()
    }
    
    // 刷新进度方法
    func refreshProgressAction() {
        currentSeconds = Float(CMTimeGetSeconds(playerItem.currentTime()))
    }
    
    // MARK: - Getter
    
    
    // MARK: - Setter
}
