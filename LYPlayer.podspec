Pod::Spec.new do |s|
  s.name = 'LYPlayer'
  s.version = '0.4.2'
  s.license = 'MIT'
  s.summary = '高度自定义的视频播放器.'
  s.homepage = 'https://github.com/LY-Coder/LYPlayer'
  s.authors = { 'LY-Coder' => 'ly_coder@163.com' }
  s.social_media_url = 'https://github.com/LY-Coder/LYPlayer'


  s.ios.deployment_target = '8.0'
  # s.osx.deployment_target = '10.11'
  # s.tvos.deployment_target = '9.0'

  s.source = { :git => 'https://github.com/LY-Coder/LYPlayer.git', :tag => s.version }
  s.source_files = 'LYPlayerExample/LYPlayer/*.swift'
  s.resources = 'LYPlayerExample/LYPlayer/*.xcassets'
  s.dependency 'SnapKit'

  s.requires_arc = true



end


