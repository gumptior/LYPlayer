//
//  LYPlayerModel.swift
//  Alamofire
//
//  Created by LY_Coder on 2018/1/12.
//

import UIKit
import AVKit

open class LYPlayerModel: NSObject {
    
    /// 视频标题
    open var title: String = ""
    
    /// 视频URL
    open var videoURL: URL?
    
    /// 视频封面本地图片
    open var placeholderImage: UIImage?

    /// 视频封面网络图片url
    /// 如果和本地图片同时设置，则忽略本地图片，显示网络图片
    open var placeholderImageURLString: String?
    
    /// 从xx秒开始播放视频(默认0)
    open var seekTime: CMTime?
}
