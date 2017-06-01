Pod::Spec.new do |s|
  s.name         = "LYPlayer"
  s.version      = “0.1”
  s.summary      = “高度自定义的视频播放器“
  s.description  = "高度自定义的视频播放器 addtion with cocoapod support."
  s.homepage     = "https://github.com/LY-Coder/LYPlayer"
  s.social_media_url   = "http://www.weibo.com/u/5267312788"
  s.license= { :type => "MIT", :file => "LICENSE" }
  s.author       = { "LY-Coder” => “ly_coder@163.com" }
  s.source       = { :git => "https://github.com/LY-Coder/LYPlayer.git", :tag => s.version }
  s.source_files = "XXImageLoopView/*.{h,m,swift}”
  s.ios.deployment_target = ‘8.0’
  s.frameworks   = 'UIKit'
  s.requires_arc = true

end