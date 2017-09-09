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

public protocol LYPlayerViewDelegate {
    
    func playerView(playerView: LYPlayerView, didClickFillScreen button: UIButton)
}

public class LYPlayerView: UIView {
    
    // 代理对象
    public var delegate: LYPlayerViewDelegate?
    
    // 播放器对象
    public var player: LYPlayer = {
        let player = LYPlayer.shard
        
        return player
    }()
    
    // 资源名字
    public var assetName: String = "" {
        didSet {
            assetNameLabel.text = assetName
        }
    }
    
    // 视频总秒数
    fileprivate var totalTime: CMTime = CMTime()
    
    // 视频当前播放秒数
    fileprivate var currentTime: CMTime = CMTime()
    
    // 滑条是否正在被拖拽
    private var isSliderDragging = false
    
    // 是否允许旋转屏幕
    private var isAllowRotateScreen = true {
        didSet {
            lockScreenBtn.isSelected = !isAllowRotateScreen
            if isAllowRotateScreen == false {
                // 锁屏
                hiddenControlShade()
            } else {
                // 非锁屏
                showControlShade()
            }
        }
    }
    
    // 是否显示上下遮罩视图
    fileprivate var isShowShadeView: Bool = true {
        willSet {
            if newValue == true {
                // 显示
                showControlShade()
            } else {
                // 隐藏
                hiddenControlShade()
            }
        }
    }
    
    // 是否全屏状态
    private var isFullScreen = false {
        willSet {
            fullScreenBtn.isSelected = newValue
            if newValue {
                // 是全屏状态
                lockScreenBtn.isHidden = false
                assetNameLabel.isHidden = false
                gestureView.isEnabledDragGesture = true
            } else {
                // 是竖屏状态
                lockScreenBtn.isHidden = true
                assetNameLabel.isHidden = true
                gestureView.isEnabledDragGesture = false
            }
        }
    }
    
    /// 通过 url 初始化
    ///
    /// - Parameter url: 视频的网络地址
    convenience public init(url: URL?) {
        self.init(frame: CGRect.zero)
        player.url = url
        initialize()
    }
    
    /// 通过 LYPlayer Object 初始化
    ///
    /// - Parameter player: 播放器对象
    convenience public init(player: LYPlayer) {
        self.init(frame: CGRect.zero)
        self.player = player
        initialize()
    }
    
    public override init(frame: CGRect) { super.init(frame: frame) }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.addSublayer(player.playerLayer)
        player.playerLayer.frame = bounds
        layer.insertSublayer(player.playerLayer, at: 0)
        
        setupUIFrame()

        // 视频信息
        LYPlayer.videoInfo { (duration) in
            
            // 修改总时间
            self.totalTimeLabel.text = ({
                // 总分钟
                let minute = Int(duration.seconds) / 60
                // 减去总分钟后的剩余秒数
                let seconds = Int(duration.seconds) % 60
                
                return String.init(format: "%02d:%02d", minute, seconds)
                }())
        }
        
        // 视频进度
        LYPlayer.videoProgress { (currentTime, cacheTime, state) in

            // 修改当前播放时间
            self.currentTimeLabel.text = ({
                // 当前播放分钟
                let minute = Int(currentTime.seconds) / 60
                // 当前播放秒
                let seconds = Int(currentTime.seconds) % 60
                
                return String.init(format: "%02d:%02d", minute, seconds)
                }())
            
            // 判断滑条是否正在被拖拽
            if self.isSliderDragging == false {
                // 如果滑条没有被拖拽
                self.progressSlider.value = Float(currentTime.seconds / self.player.playerItem.duration.seconds)
            }
        }
    }
    
    // 初始化对象
    private func initialize() {
        
        backgroundColor = UIColor.black
        
        // 设置UI样式
        setupUI()
        
        // 添加通知中心
        addNotificationCenter()
        
        // 控制控件层次
        bringSubview(toFront: bottomShadeView)
        
        // 设置竖屏状态
        isFullScreen = false
        
        // 是否显示上下遮罩视图
        isShowShadeView = true
        
        player.delegate = self
    }
    
    // 设置UI控件
    private func setupUI() {
        
        addSubview(gestureView)
        
        addSubview(lockScreenBtn)
        
        addSubview(bottomShadeView)
        
        addSubview(topShadeView)
        
        addSubview(indicator)
        
        topShadeView.addSubview(backBtn)
        
        topShadeView.addSubview(assetNameLabel)
        
        bottomShadeView.addSubview(playAndPauseBtn)
        
        bottomShadeView.addSubview(currentTimeLabel)
        
        bottomShadeView.addSubview(progressSlider)
        
        bottomShadeView.addSubview(totalTimeLabel)
        
        bottomShadeView.addSubview(fullScreenBtn)
    }
    
    // 设置UI控件Frame
    private func setupUIFrame() {
        gestureView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        
        topShadeView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(64)
        }
        
        bottomShadeView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(self)
            make.height.equalTo(40)
        }
        
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self).offset(0)
            make.size.equalTo(40)
        }
        
        assetNameLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(backBtn)
            make.left.equalTo(backBtn).offset(70)
            make.right.equalTo(topShadeView).offset(-20)
        }
        
        playAndPauseBtn.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(bottomShadeView)
            make.width.equalTo(40)
        }
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(playAndPauseBtn)
            make.left.equalTo(playAndPauseBtn.snp.right).offset(10)
            make.width.equalTo(40)
        }
        
        fullScreenBtn.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(bottomShadeView)
            make.width.equalTo(40)
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(fullScreenBtn)
            make.right.equalTo(fullScreenBtn.snp.left).offset(-10)
            make.width.equalTo(40)
        }
        
        progressSlider.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(bottomShadeView)
            make.left.equalTo(currentTimeLabel.snp.right).offset(10)
            make.right.equalTo(totalTimeLabel.snp.left).offset(-10)
        }
        
        lockScreenBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(10)
            make.size.equalTo(35)
        }
        
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    // 手势控制视图
    lazy var gestureView: LYPlayerGesture = {
        let gestureView = LYPlayerGesture(frame: CGRect.zero)
        gestureView.backgroundColor = UIColor.clear
        gestureView.delegate = self
        
        return gestureView
    }()
    
    // 上部遮罩视图
    lazy var topShadeView: UIImageView = {
        let topShadeView = UIImageView()
        topShadeView.isUserInteractionEnabled = true
        let image = UIImage.init("LYPlayer_top_shade")
        topShadeView.image = image.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0.5, 0, 1) , resizingMode: .stretch)
        
        return topShadeView
    }()
    
    // 下部遮罩视图
    lazy var bottomShadeView: UIImageView = {
        let bottomShadeView = UIImageView()
        bottomShadeView.isUserInteractionEnabled = true
        let image = UIImage.init("LYPlayer_bottom_shade")
        bottomShadeView.image = image.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0.5, 0, 1) , resizingMode: .stretch)
        
        return bottomShadeView
    }()
    
    // 资源名字标签
    lazy var assetNameLabel: UILabel = {
        let assetNameLabel = UILabel()
        assetNameLabel.textColor = UIColor.white
        assetNameLabel.font = UIFont.systemFont(ofSize: 17)
        
        return assetNameLabel
    }()
    
    // 开始暂停按钮
    lazy var playAndPauseBtn: LYPlayButton = {
        let playAndPauseBtn = LYPlayButton()
        playAndPauseBtn.playStatus = .pause
        playAndPauseBtn.addTarget(self, action: #selector(playAndPauseBtnAction), for: .touchUpInside)
        
        return playAndPauseBtn
    }()
    
    // 当前时间标签
    lazy var currentTimeLabel: UILabel = {
        let currentTimeLabel = UILabel()
        currentTimeLabel.textColor = UIColor.white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 14)
        currentTimeLabel.text = "00:00"
        currentTimeLabel.textAlignment = .center
        
        return currentTimeLabel
    }()
    
    // 播放进度条
    lazy var progressSlider: UISlider = {
        let progressSlider = UISlider()
        progressSlider.value = 0.0
        progressSlider.addTarget(self, action: #selector(progressSliderTouchDownAction), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(progressSliderTouchUpInsideAction), for: .touchUpInside)
        
        return progressSlider
    }()
    
    // 总时间标签
    lazy var totalTimeLabel: UILabel = {
        let totalTimeLabel = UILabel()
        totalTimeLabel.textColor = UIColor.white
        totalTimeLabel.font = UIFont.systemFont(ofSize: 14)
        totalTimeLabel.text = "00:00"
        totalTimeLabel.textAlignment = .center
        
        return totalTimeLabel
    }()
    
    // 全屏按钮
    lazy var fullScreenBtn: UIButton = {
        let fullScreenBtn = UIButton(type: .custom)
        fullScreenBtn.setImage(UIImage.init("LYPlayer_fullscreen"), for: .normal)
        fullScreenBtn.setImage(UIImage.init("LYPlayer_shrinkscreen"), for: .selected)
        fullScreenBtn.isSelected = false
        fullScreenBtn.addTarget(self, action: #selector(fullScreenBtnAction), for: .touchUpInside)
        
        return fullScreenBtn
    }()
    
    // 返回按钮
    lazy var backBtn: UIButton = {
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage.init("LYPlayer_back_full"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        
        return backBtn
    }()
    
    // 锁屏按钮
    lazy var lockScreenBtn: UIButton = {
        let lockScreenBtn = UIButton(type: .custom)
        lockScreenBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        lockScreenBtn.layer.cornerRadius = 17.5
        lockScreenBtn.setImage(UIImage.init("LYPlayer_lock_nor"), for: .selected)
        lockScreenBtn.setImage(UIImage.init("LYPlayer_unlock_nor"), for: .normal)
        lockScreenBtn.addTarget(self, action: #selector(lockScreenBtnAction), for: .touchUpInside)
        
        return lockScreenBtn
    }()
    
    // 加载缓冲中提示
    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    private func addNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientation), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func getImg(asset: AVAsset) -> UIImage {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, 30)
        var actualTime: CMTime = CMTime(value: 0, timescale: 0)
        let imgRef = try! generator.copyCGImage(at: time, actualTime: &actualTime)
        
        let frameImg: UIImage = UIImage(cgImage: imgRef)
        
        return frameImg
    }
    
    // MARK: - IBAction
    
    // 播放和暂停按钮点击事件
    func playAndPauseBtnAction(button: LYPlayButton) {
        if button.playStatus == .pause {
            player.play()
        } else {
            player.pause()
        }
    }
    
    // 全屏按钮点击事件
    func fullScreenBtnAction(button: UIButton) {
        // 旋转控制器
        // 判断是否允许屏幕旋转
        if isAllowRotateScreen == false {
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
            button.isSelected = false
        } else {
            // 切换到全屏状态
            appDelegate.allowRotation = true    // 打开横屏功能
            value = UIInterfaceOrientation.landscapeLeft.rawValue
            isFullScreen = true
        }
        UIDevice.current.setValue(value, forKey: "orientation")
        delegate?.playerView(playerView: self, didClickFillScreen: button)
    }
    
    // 返回按钮点击事件
    func backBtnAction(button: UIButton) {
        if isFullScreen {
            // 当前是全屏状态
            fullScreenBtnAction(button: fullScreenBtn)
        } else {
            if playerViewController?.navigationController == nil || playerViewController?.navigationController?.viewControllers.count == 1 {
                return
            }
            playerViewController?.navigationController?.popViewController(animated: true)
            // 关闭播放器
            player.stop()
        }
    }
    
    // 锁屏按钮点击事件
    func lockScreenBtnAction(button: UIButton) {
        isAllowRotateScreen = !isAllowRotateScreen
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
        let seconds = Double(slider.value) / 1.0 * player.playerItem.duration.seconds
        let time = CMTime(seconds: seconds, preferredTimescale: 60)
        player.seek(to: time)
    }
    
    // 显示控制遮罩视图
    private func showControlShade() {
        if isAllowRotateScreen == false {
            // 锁屏
            lockScreenBtn.isHidden = false
            return
        }
        
        topShadeView.isHidden = false
        bottomShadeView.isHidden = false
        
        if isFullScreen == true {
            // 横屏
            lockScreenBtn.isHidden = false
        }
    }
    
    // 隐藏控制遮罩视图
    private func hiddenControlShade() {
        topShadeView.isHidden = true
        bottomShadeView.isHidden = true
        
        if isAllowRotateScreen == false {
            // 锁屏
            lockScreenBtn.isHidden = false
            return
        }
        // 非锁屏
        lockScreenBtn.isHidden = true
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

extension LYPlayerView: LYPlayerDelegate {
    
    public func player(_ player: LYPlayer, willChange status: LYPlayerStatus) {
        
        switch status {
        case .playing:
            // 播放中
            playAndPauseBtn.playStatus = .play
            gestureView.image = nil
        case .pausing:
            // 暂停中
            playAndPauseBtn.playStatus = .pause
        case .stopped:
            // 停止播放
            break
        case .readyToPlay:
            // 准备播放
            indicator.stopAnimating()
            break
        case .failed:
            // 播放失败
            break
        case .unknown:
            // 未知错误
            break
        case .bufferEmpty:
            // 缓存区空
            indicator.startAnimating()
            let img = getImg(asset: player.asset)
            gestureView.image = img
            break
        }
    }
}

extension LYPlayerView: LYPlayerGestureDelegate {
    func tapGestureAction(view: UIImageView) {
        // 设置点击手势控制是否显示上下遮罩视图
        isShowShadeView = !isShowShadeView
    }
    
    func adjustVideoPlaySeconds(_ changeSeconds: Double) {
        let seconds = player.playerItem.currentTime().seconds + changeSeconds
        let time = CMTime(seconds: seconds, preferredTimescale: 60)
        player.seek(to: time)
    }
}

extension LYPlayerView {
    
    fileprivate struct AssociatedKeys {
        static var playerViewController: UIViewController = UIViewController()
    }
    
    open var playerViewController: UIViewController? {
        get {
            guard let playerViewController = objc_getAssociatedObject(self, &AssociatedKeys.playerViewController) as? UIViewController else {
                var next = self.next
                while next != nil {
                    if next!.isKind(of: UIViewController.self) {
                        return next as? UIViewController
                    }
                    next = next?.next
                }
                return nil
            }
            return playerViewController
        }
    }
}
