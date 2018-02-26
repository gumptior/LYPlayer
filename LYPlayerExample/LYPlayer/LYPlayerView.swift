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

public enum WindowStyle: Int {
    /** 正常 */
    case normal
    /** 全屏 */
    case full
    /** 小窗口 */
    case small
}

public enum Orientation: Int {
    /** 横屏 */
    case horizontal
    /** 竖屏 */
    case vertical
}

public protocol LYPlayerViewDelegate: class {
    /** 屏幕将要旋转方向 */
    func playerView(_ playerView: LYPlayerView, willRotate orientation: Orientation)
    
    /** 视频播放结束 */
    func playerView(_ playerView: LYPlayerView, willEndPlayAt item: AVPlayerItem)
}

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
        print("---LYPlayerView结束了---")
        player = nil
        removeNotificationCenter()
        // 清除应用通知
        removeAppNotification()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // 设置显示播放器
        setupPlayerLayer()
    }
    
    var player: LYPlayer?
    
    weak var delegate: LYPlayerViewDelegate?
    
    lazy var playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: self.player)
        return playerLayer
    }()
    
    // 手势控制视图
    lazy var gestureView: LYGestureView = {
        let gestureView = LYGestureView(frame: CGRect.zero)
        gestureView.backgroundColor = UIColor.clear
        gestureView.isUserInteractionEnabled = false
        gestureView.delegate = self
        
        return gestureView
    }()
    
    /** 自动播放 */
    open var isAutoPlay: Bool = false
    
    /** 是否恢复播放（继续上次播放位置） */
    open var isRecoveryPlay: Bool = false {
        didSet {
            if isRecoveryPlay {
                player?.playLastTime()
            } else {
                playerPlay()
            }
        }
    }
    
    /** 播放倍速 */
    open var rate: Float = 1.0
    
    /** 样式 */
    open var style: WindowStyle {
        return _style
    }
    
    public var _style: WindowStyle = .normal
    
    /** 视频播放当前时间 */
    open var currentTime: CMTime = CMTime()
    
    /** 视频缓存时间 */
    open var cacheTime: CMTime = CMTime()
    
    /** 视频总时间 */
    open var totalTime: CMTime!
    
//    /** 当前是否是全屏显示 */
//    public var isFullWindow = false
//
//    /** 当前是否是小窗口显示 */
//    public var isSmallWindow = false
    
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
    
    final var verticalFrame: CGRect!
}

// MARK: - Convenience
extension LYPlayerView {
    
    public convenience init(playerModel: LYPlayerModel) {
        self.init(frame: .zero)
        
        self.player = creatPlayer(with: playerModel)
    }
    
    /** 初始化对象 */
    internal func initialize() {
        backgroundColor = UIColor.black
        
        addSubview(gestureView)
        gestureView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }

        // 添加通知中心
        addNotificationCenter()

        addAppNotification()
        
        if isAutoPlay {
            // 视频自动播放
            playerPlay()
        } else {
            player?.pause()
        }

        verticalFrame = frame
        
        superview?.bringSubview(toFront: self)
    }
}

// MARK: - 播放器配置
extension LYPlayerView {
    
    internal func creatPlayerItem(with playerModel: LYPlayerModel) -> AVPlayerItem {
        
        let asset = AVAsset(url: playerModel.videoURL!)
        
        return AVPlayerItem(asset: asset)
    }
    
    fileprivate func creatPlayer(with playerModel: LYPlayerModel) -> LYPlayer {
        
        let item = creatPlayerItem(with: playerModel)
        
        let player = LYPlayer(playerItem: item)
        player.delegate = self
        
        // 监听播放时间
        setupDruation(for: player)
        
        return player
    }
    
    fileprivate func setupFrame(_ orientation: Orientation) {
        if orientation == .horizontal {
            // 横屏
            snp.remakeConstraints({ (make) in
                make.edges.equalTo(superview!)
            })
        } else {
            // 竖屏
            snp.remakeConstraints({ (make) in
                make.left.equalTo(verticalFrame.minX)
                make.top.equalTo(verticalFrame.minY)
                make.width.equalTo(verticalFrame.width)
                make.height.equalTo(verticalFrame.height)
            })
        }
    }
    
    /** 配置播放器视图层 */
    fileprivate func setupPlayerLayer() {
        layer.addSublayer(playerLayer)
        playerLayer.frame = bounds
        layer.insertSublayer(playerLayer, at: 0)
    }
    
    /** 监听播放时长 */
    fileprivate func setupDruation(for player: LYPlayer) {
        // 解决循环引用
        weak var weakSelf = self
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: DispatchQueue.main, using: { (time) in
            weakSelf?.currentTime = time
        })
        
        
//        let startTime = NSValue(time: CMTime(seconds: 1, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC)))
//        player.addBoundaryTimeObserver(forTimes: [startTime], queue: DispatchQueue.main) {
//            self.totalTime = player.currentItem?.duration
//        }
    }
}

// MARK: - Function
extension LYPlayerView {
    
    open func rotateToNormalWindow() {
        // 关闭拖拽收拾
        gestureView.isEnabledDragGesture = false
        // 通知代理
        delegate?.playerView(self, willRotate: .vertical)
        
        rotate(.portrait)
        
        _style = .normal
    }
    
    open func rotateToFullWindow() {
        // 开启拖拽收拾
        gestureView.isEnabledDragGesture = true
        // 通知代理
        delegate?.playerView(self, willRotate: .horizontal)
        
        rotate(.landscapeRight)
        
        _style = .full
    }
    
    open func rotateToSmallWindow() {
        // 关闭拖拽收拾
        gestureView.isEnabledDragGesture = false
        // 通知代理
        delegate?.playerView(self, willRotate: .vertical)
        
        rotate(.portrait)
        
        window?.addSubview(self)
        snp.remakeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(snp.width).multipliedBy(9.0/16.0).priority(750)
            make.bottom.right.equalTo(window!).offset(-100)
        }
        
        isLocking = true
        
        isShowShadeView = false
        
        _style = .small
    }
    
    open func replaceCurrentPlayerModel(with playerModel: LYPlayerModel?) {
        let item = creatPlayerItem(with: playerModel!)
        
        self.player?.replaceCurrentItem(with: item)
        
        if isAutoPlay {
            // 视频自动播放
            playerPlay()
        } else {
            player?.pause()
        }
    }
    
    /** 时间转分秒 */
    func timeToSeconds(time: CMTime?) -> String {
        // 计算分钟
        let minute = Int(time?.seconds ?? 0.0) / 60
        // 计算秒
        let seconds = Int(time?.seconds ?? 0.0) % 60
        
        return String(format: "%02d:%02d", arguments: [minute, seconds])
    }
    
    func playerPlay() {
//        player?.play()
        player?.rate = rate
    }
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
            playerPlay()
            sender.playStatus = .play
        }
    }
    
    // 返回按钮点击事件
    func backAction(sender: UIButton) {
        if style == .full {
            // 当前是全屏状态，变为正常窗口显示
            rotateToNormalWindow()
        } else if style == .small {
            // 当前是小窗口状态，关闭窗口
            player?.stop()
            removeFromSuperview()
        } else {
            if viewController?.navigationController == nil || viewController?.navigationController?.viewControllers.count == 1 {
                return
            }
            viewController?.navigationController?.popViewController(animated: true)
            // 关闭播放器
            player?.stop()
            removeFromSuperview()
        }
    }
    
    // 全屏按钮点击事件
    func fullScreenAction(sender: UIButton) {
        // 旋转屏幕
        if style == .full {
            // 当前是全屏状态，变为正常窗口显示
            rotateToNormalWindow()
        } else {
            // 当前是竖屏状态，变为全屏窗口显示
            rotateToFullWindow()
        }
    }
    
    // 锁屏按钮点击事件
    func lockScreenAction(sender: UIButton) {
        isLocking = !isLocking
    }
    
    // 进度条被按下时的事件
    func progressSliderTouchDownAction(slider: LYProgressSlider) {
        // 设置滑条正在被拖拽
        isSliderDragging = true
    }
    
    // 进度条手指抬起时的事件
    func progressSliderTouchUpInsideAction(slider: LYProgressSlider) {
        // 设置滑条没有被拖拽
        isSliderDragging = false
        // 计算进度
        guard let totalSeconds = player?.currentItem?.duration.seconds else {
            return
        }
        let seconds = Double(slider.playProgress) / 1.0 * totalSeconds
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC))
        player?.seek(to: time)
    }
}

// MARK: - 屏幕旋转
extension LYPlayerView {
    
    /// 屏幕方向旋转
    fileprivate func rotate(_ orientation: UIInterfaceOrientation) {
        // 判断是否允许屏幕旋转
        if isLocking == true {
            print("当前全屏按钮处于锁定状态")
            return
        }
        
        if orientation.isPortrait {
//            isFullWindow = false
        } else if orientation.isLandscape {
//            isFullWindow = true
        }
        
        let appDelegate = UIApplication.shared.delegate as! UIResponder
        appDelegate.interfaceOrientation = orientation
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
        if orientation.isLandscape {
            // 屏幕水平
            setupFrame(.horizontal)
        } else if orientation.isPortrait {
            // 屏幕竖直
            setupFrame(.vertical)
        }
    }
}

// MARK: - LYPlayerDelegate
extension LYPlayerView: LYPlayerDelegate {
    func player(_ player: LYPlayer, itemTotal time: CMTime) {
        
    }
    
    func player(_ player: LYPlayer, isPlaying: Bool) {
        
    }
    
    func player(_ player: AVPlayer, willEndPlayAt item: AVPlayerItem) {
        // 通知代理对象
        delegate?.playerView(self, willEndPlayAt: item)
    }
    
    func player(_ player: AVPlayer, loadedCacheDuration duration: CMTime) {
        cacheTime = duration
    }
}

// MARK: - LYPlayerGestureDelegate
extension LYPlayerView: LYGestureViewDelegate {
    
    /** 单击手势事件 */
    func singleTapGestureAction(view: UIImageView) {
        
    }
    
    /** 双击手势事件 */
    func doubleTapGestureAction(view: UIImageView) {
        guard let playing = player?.isPlaying else {
            return
        }
        if playing {
            player?.pause()
        } else {
            playerPlay()
        }
    }
    
    /** 跳转到指定时间 */
    func adjustVideoPlaySeconds(_ changeSeconds: Double) {
        guard let currentTime = player?.currentItem?.currentTime() else {
            return
        }
        let time = CMTime(seconds: currentTime.seconds + changeSeconds, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC))
        player?.seek(to: time)
    }
    
    /** 视频进度拖拽中 */
    func progressDragging(_ changeSeconds: Double) {
        guard let currentTime = player?.currentItem?.currentTime() else {
            return
        }
        let time = CMTime(seconds: currentTime.seconds + changeSeconds, preferredTimescale: CMTimeScale(1 * NSEC_PER_SEC))
        let seekView = LYSeekView.shared
        seekView.seek(to: time, with: currentTime, item: player!.currentItem!)
    }
}

// MARK: - APP Notification
extension LYPlayerView {
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
    
    // 程序将要进入后台
    @objc func willEnterBcakground_notification() {
        print("将要进入后台")
        player?.pause()
    }
    
    // 程序已经返回前台
    @objc func didEnterPlayGround_notification() {
        print("已经返回前台")
        if style == .full {
            rotate(.landscapeLeft)
        } else {
            rotate(.portrait)
        }
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

