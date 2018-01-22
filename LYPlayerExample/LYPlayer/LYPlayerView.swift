//
//  LYPlayerView.swift
//
//  Copyright © 2017年 ly_coder. All rights reserved.
//
//  GitHub地址：https://github.com/LY-Coder/LYPlayer
//

// 小窗口模式

import UIKit
import AVFoundation
import SnapKit

open class LYPlayerView: UIView {
    
    override init(frame: CGRect) { super.init(frame: frame) }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        /// 在player对象存在时才可以调用这个方法
        initialize()
    }
    
    deinit {
        print("---结束了---")
        removeNotificationCenter()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // 设置显示播放器
        setupPlayerLayer()
    }
    
    var player: LYPlayer?
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: self.player)
        return playerLayer
    }()
    
    // 手势控制视图
    lazy var gestureView: LYPlayerGesture = {
        let gestureView = LYPlayerGesture(frame: CGRect.zero)
        gestureView.backgroundColor = UIColor.clear
        gestureView.isUserInteractionEnabled = false
        gestureView.delegate = self
        
        return gestureView
    }()
    
    /** 自动播放 */
    open var isAutoPlay: Bool = false
    
    /** 播放倍速 */
    open var rate: Float = 1.0
    
    /** 视频播放当前时间 */
    open var currentTime: CMTime = CMTime()
    
    /** 视频总时间 */
    open var totalTime: CMTime?
    
    /** 当前是否是全屏显示 */
    open var isFullScreen = false
    
    /** 当前是否锁定屏幕方向 */
    public var isLocking = false {
        didSet {
            isShowShadeView = !isLocking
        }
    }
    
    /** 滑条是否正在被拖拽 */
    public var isSliderDragging = false
    
    /** 是否显示上下遮罩视图 */
    public var isShowShadeView: Bool = true {
        didSet {
            topShadeView?.isHidden = !isShowShadeView
            bottomShadeView?.isHidden = !isShowShadeView
        }
    }
    
    public var topShadeView: UIImageView? {
        didSet {
            topShadeView?.isHidden = true
        }
    }
    
    public var bottomShadeView: UIImageView? {
        didSet {
            bottomShadeView?.isHidden = true
        }
    }
    
}

// MARK: - Convenience
extension LYPlayerView {
    
    public convenience init(playerModel: LYPlayerModel) {
        self.init(frame: .zero)
        
        let asset = AVAsset(url: playerModel.videoURL!)
        
        let item = AVPlayerItem(asset: asset)
        
        let player = LYPlayer(playerItem: item)
        
        self.player = player
    }
    
    /** 初始化对象 */
    func initialize() {
        backgroundColor = UIColor.black
        
        addSubview(gestureView)
        gestureView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        player?.delegate = self
        
        // 监听播放时间
        setupDruation(for: player!)
        
        // 添加通知中心
        addNotificationCenter()
        
        if isAutoPlay {
            // 视频自动播放
            player?.play()
        }
        
        // 播放倍速
        player?.rate = rate
    }
}

// MARK: - 播放器配置
extension LYPlayerView {
    
    /** 配置播放器视图层 */
    fileprivate func setupPlayerLayer() {
        layer.addSublayer(playerLayer)
        playerLayer.frame = bounds
        layer.insertSublayer(playerLayer, at: 0)
    }
    
    /** 监听播放时长 */
    fileprivate func setupDruation(for player: LYPlayer) {
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: DispatchQueue.main, using: { (time) in
            self.currentTime = time
        })
        
        
//        let startTime = NSValue(time: CMTime(seconds: 1, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC)))
//        player.addBoundaryTimeObserver(forTimes: [startTime], queue: DispatchQueue.main) {
//            self.totalTime = player.currentItem?.duration
//        }
    }
}

// MARK: - Function
extension LYPlayerView {
    
    /** 时间转分秒 */
    func timeToSeconds(time: CMTime?) -> String {
        // 计算分钟
        let minute = Int(time?.seconds ?? 0.0) / 60
        // 计算秒
        let seconds = Int(time?.seconds ?? 0.0) % 60
        
        return String(format: "%02d:%02d", arguments: [minute, seconds])
    }
    
//    /** 显示控制遮罩视图 */
//    public func showControlShade() {
//        topShadeView?.isHidden = false
//        bottomShadeView?.isHidden = false
//    }
//
//    /** 隐藏控制遮罩视图 */
//    public func hiddenControlShade() {
//        topShadeView?.isHidden = true
//        bottomShadeView?.isHidden = true
//    }
}
    
// MARK: - IBAction
extension LYPlayerView {
    
    // 播放和暂停按钮点击事件
    func playAction(sender: LYPlayButton) {
        if player?.isPlaying == true {
            // 当前正在播放中
            player?.pause()
            sender.playStatus = .pause
        } else {
            player?.play()
            sender.playStatus = .play
        }
    }
    
    // 返回按钮点击事件
    func backAction(sender: UIButton) {
        if isFullScreen {
            // 当前是全屏状态
            orientationRotate()
        } else {
            if viewController?.navigationController == nil || viewController?.navigationController?.viewControllers.count == 1 {
                return
            }
            viewController?.navigationController?.popViewController(animated: true)
            // 关闭播放器
            player?.stop()
        }
    }
    
    // 全屏按钮点击事件
    func fullScreenAction(sender: UIButton) {
        // 旋转屏幕
        orientationRotate()
    }
    
    // 锁屏按钮点击事件
    func lockScreenAction(sender: UIButton) {
        isLocking = !isLocking
    }
    
    // 进度条被按下时的事件
    func progressSliderTouchDownAction(slider: UISlider) {
        // 设置滑条正在被拖拽
        isSliderDragging = true
    }
    
    // 进度条手指抬起时的事件
    func progressSliderTouchUpInsideAction(slider: UISlider) {
        // 设置滑条没有被拖拽
        isSliderDragging = false
        // 计算进度
        guard let totalSeconds = player?.currentItem?.duration.seconds else {
            return
        }
        let seconds = Double(slider.value) / 1.0 * totalSeconds
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC))
        player?.seek(to: time)
    }
}

// MARK: - 屏幕旋转
extension LYPlayerView {
    
    /// 屏幕方向旋转
    func orientationRotate() {
        // 判断是否允许屏幕旋转
        if isLocking == true {
            print("当前全屏按钮处于锁定状态")
            return
        }
        let appDelegate = UIApplication.shared.delegate as! UIResponder
        let value: Int
        
        if isFullScreen {
            // 切换到竖屏状态
            appDelegate.allowRotation = false   // 关闭横屏功能
            value = UIInterfaceOrientation.portrait.rawValue
            isFullScreen = false
            
        } else {
            // 切换到全屏状态
            appDelegate.allowRotation = true    // 打开横屏功能
            value = UIInterfaceOrientation.landscapeLeft.rawValue
            isFullScreen = true
        }
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    fileprivate func addNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientation), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    fileprivate func removeNotificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // 处理旋转过程中需要的操作
    func orientation(notification: NSNotification) {
        
        let orientation = UIDevice.current.orientation
        
        switch orientation {
        case .portrait:
            // 屏幕竖直
            break
        case .landscapeLeft:
            // 屏幕向左转
            break
        case .landscapeRight:
            // 屏幕向右转
            break
        default:
            break
        }
    }
}

// MARK: - LYPlayerDelegate
extension LYPlayerView: LYPlayerDelegate {
//    func player(_ player: AVPlayer, willEndPlayAt item: AVPlayerItem) {
//
//    }
    
    func player(_ player: AVPlayer, itemTotal time: CMTime) {
        totalTime = time
        
        gestureView.isUserInteractionEnabled = true
    }
}

// MARK: - LYPlayerGestureDelegate
extension LYPlayerView: LYPlayerGestureDelegate {
    /** 单击手势事件 */
    func tapGestureAction(view: UIImageView) {
//        if isLocking {
//            return
//        }
//        // 设置点击手势控制是否显示上下遮罩视图
//        isShowShadeView = !isShowShadeView
    }
    
    /** 跳转到指定时间 */
    func adjustVideoPlaySeconds(_ changeSeconds: Double) {
        
//        let seconds = player.playerItem.currentTime().seconds + changeSeconds
//        let time = CMTime(seconds: seconds, preferredTimescale: 60)
//        player.seek(to: time)
    }
}

extension LYPlayerView {
    
    /** 当前的视图对应的视图控制器 */
    var viewController: UIViewController? {
        for view in sequence(first: self, next: {$0?.superview}) {
            if let responder = view?.next {
                if responder.isKind(of: UIViewController.self) {
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
}
