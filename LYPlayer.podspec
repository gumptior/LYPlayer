Pod::Spec.new do |s|
  s.name = 'LYPlayer'
  s.version = ‘0.2’
  s.license = 'MIT'
  s.summary = '高度自定义的视频播放器.'
  s.homepage = 'https://github.com/LY-Coder/LYPlayer'
  s.authors = { 'LY-Coder' => 'ly_coder@163.com' }
  s.social_media_url = 'https://github.com/LY-Coder/LYPlayer'
  s.source = { :git => 'https://github.com/LY-Coder/LYPlayer.git', :tag => '0.2' }

  s.ios.deployment_target = '8.0'
  # s.osx.deployment_target = '10.11'
  # s.tvos.deployment_target = '9.0'

  s.source_files = 'Source/*.swift'
  s.dependency 'SnapKit'

  s.requires_arc = true

end
