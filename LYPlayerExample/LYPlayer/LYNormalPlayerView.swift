//
//  LYNormalPlayerView.swift
//  LYPlayer
//
//  Created by LY_Coder on 2018/1/12.
//

import UIKit
import AVKit

open class LYNormalPlayerView: LYPlayerView {
    
    deinit {
        print("---LYNormalPlayerView结束了---")
        
    }
    
    /** 初始化 */
    override func initialize() {
        super.initialize()
        
        setupUI()

        setupUIFrame()
        
        topShadeView = topShadeImgView

        bottomShadeView = bottomShadeImgView
        
//        showLoading()
        
        // 设置为竖屏状态，调整锁屏按钮状态
        isFullScreen = false
        // 默认隐藏锁屏按钮
        lockScreenBtn.isHidden = true
    }
    
    override open var currentTime: CMTime {
        didSet {
            // 判断滑条是否正在被拖拽  
            if self.isSliderDragging == false {
                // 如果滑条没有被拖拽
                guard let totalSeconds = player?.currentItem?.duration.seconds else {
                    return
                }
                self.progressSlider.value = Float(currentTime.seconds / totalSeconds)
                currentTimeLabel.text = timeToSeconds(time: currentTime)
            }
        }
    }
    
    override open var totalTime: CMTime? {
        didSet {
            print(timeToSeconds(time: totalTime))
            totalTimeLabel.text = timeToSeconds(time: totalTime)
        }
    }
    
    /// 是否全屏状态
    open override var isFullScreen: Bool {
        didSet {
            fullScreenBtn.isSelected = isFullScreen
            lockScreenBtn.isHidden = !isFullScreen
        }
    }
    
    open override var isLocking: Bool {
        didSet {
            lockScreenBtn.isSelected = isLocking
        }
    }
    
    public override var isShowShadeView: Bool {
        didSet {
        }
    }
    
    /** 显示视频第一次加载样式 */
    fileprivate func showLoading() {
//        indicator.startAnimating()
        gestureView.image = UIImage(named: "loading_bgView")
        gestureView.isUserInteractionEnabled = false
    }
    
    /** 隐藏视频加载样式 */
    fileprivate func hiddenLoading() {
        indicator.stopAnimating()
        gestureView.image = nil
        isShowShadeView = true
        gestureView.isUserInteractionEnabled = true
    }
    
    // 上部遮罩视图
    lazy var topShadeImgView: UIImageView = {
        let topShadeImgView = UIImageView()
        topShadeImgView.isUserInteractionEnabled = true
        let image = UIImage.init("LYPlayer_top_shade")
        topShadeImgView.image = image.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0.5, 0, 1) , resizingMode: .stretch)
        
        return topShadeImgView
    }()
    
    // 下部遮罩视图
    lazy var bottomShadeImgView: UIImageView = {
        let bottomShadeImgView = UIImageView()
        bottomShadeImgView.isUserInteractionEnabled = true
        let image = UIImage.init("LYPlayer_bottom_shade")
        bottomShadeImgView.image = image.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0.5, 0, 1) , resizingMode: .stretch)

        return bottomShadeImgView
    }()
    
    // 资源名字标签
    lazy var assetNameLabel: UILabel = {
        let assetNameLabel = UILabel()
        assetNameLabel.textColor = UIColor.white
        assetNameLabel.font = UIFont.systemFont(ofSize: 17)
        
        return assetNameLabel
    }()
    
    // 开始暂停按钮
    lazy var playBtn: LYPlayButton = {
        let playBtn = LYPlayButton()
        playBtn.playStatus = .pause
        playBtn.addTarget(self, action: #selector(playAction(sender:)), for: .touchUpInside)
        
        return playBtn
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
        progressSlider.addTarget(self, action: #selector(progressSliderTouchDownAction(slider:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(progressSliderTouchUpInsideAction(slider:)), for: .touchUpInside)
        
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
        fullScreenBtn.addTarget(self, action: #selector(fullScreenAction(sender:)), for: .touchUpInside)
        
        return fullScreenBtn
    }()
    
    // 返回按钮
    lazy var backBtn: UIButton = {
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage.init("LYPlayer_back_full"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        
        return backBtn
    }()
    
    // 锁屏按钮
    lazy var lockScreenBtn: UIButton = {
        let lockScreenBtn = UIButton(type: .custom)
        lockScreenBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        lockScreenBtn.layer.cornerRadius = 17.5
        lockScreenBtn.setImage(UIImage.init("LYPlayer_lock_nor"), for: .selected)
        lockScreenBtn.setImage(UIImage.init("LYPlayer_unlock_nor"), for: .normal)
        lockScreenBtn.addTarget(self, action: #selector(lockScreenAction(sender:)), for: .touchUpInside)
        
        return lockScreenBtn
    }()
    
    // 加载缓冲中提示
    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    // 设置UI控件
    private func setupUI() {
        
        addSubview(lockScreenBtn)
        
        addSubview(bottomShadeImgView)
        
        addSubview(topShadeImgView)
        
        addSubview(indicator)
        
        topShadeImgView.addSubview(backBtn)
        
        topShadeImgView.addSubview(assetNameLabel)
        
        bottomShadeImgView.addSubview(playBtn)
        
        bottomShadeImgView.addSubview(currentTimeLabel)
        
        bottomShadeImgView.addSubview(progressSlider)
        
        bottomShadeImgView.addSubview(totalTimeLabel)
        
        bottomShadeImgView.addSubview(fullScreenBtn)
    }
    
    // 设置UI控件Frame
    private func setupUIFrame() {
        
        topShadeImgView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self)
            make.height.equalTo(64)
        }
        
        bottomShadeImgView.snp.makeConstraints { (make) in
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
            make.right.equalTo(topShadeImgView).offset(-20)
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(bottomShadeImgView)
            make.width.equalTo(40)
        }
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(playBtn)
            make.left.equalTo(playBtn.snp.right).offset(10)
            make.width.equalTo(40)
        }
        
        fullScreenBtn.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(bottomShadeImgView)
            make.width.equalTo(40)
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(fullScreenBtn)
            make.right.equalTo(fullScreenBtn.snp.left).offset(-10)
            make.width.equalTo(40)
        }
        
        progressSlider.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(bottomShadeImgView)
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
    
    /// 播放和暂停按钮点击事件
    override func playAction(sender: LYPlayButton) {
        super.playAction(sender: sender)
        
    }
    
    /// 全屏按钮点击事件
    override func fullScreenAction(sender: UIButton) {
        super.fullScreenAction(sender: sender)
        
    }

    /// 返回按钮点击事件
    override func backAction(sender: UIButton) {
        super.backAction(sender: sender)
        
    }
    
    /// 锁屏按钮点击事件
    override func lockScreenAction(sender: UIButton) {
        super.lockScreenAction(sender: sender)
        
    }
    
    override func tapGestureAction(view: UIImageView) {
        if isLocking {
            lockScreenBtn.isHidden = !lockScreenBtn.isHidden
            return
        }
        // 设置点击手势控制是否显示上下遮罩视图
        isShowShadeView = !isShowShadeView
    }
    
    
}

extension LYNormalPlayerView {
    
    override func player(_ player: AVPlayer, itemTotal time: CMTime) {
        
        hiddenLoading()
    }
    
    override func player(_ player: LYPlayer, isPlaying: Bool) {
        
        if isPlaying {
            playBtn.playStatus = .play
        } else {
            playBtn.playStatus = .pause
        }
    }
}
