#iOS-Logger Pod
Pod::Spec.new do |s|
  s.name         = 'Logger'
  s.version      = '2.0.0'
  s.summary      = 'Logger. Log debug help'

  s.description  = 'Helper that shows status running application'

  s.homepage     = 'http://www.ciberexperis.com'
  s.license      = 'MIT'
  # s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }

  s.author             = 'Ciber'
  s.platform     = :ios, '9.0'

  #  When using multiple platforms
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  # s.watchos.deployment_target = '2.0'
  # s.tvos.deployment_target = '9.0'

  s.source       = { :git => 'ssh://git@gitlab.ciber-es.com:7346/mobility/Ciber/Common/iOS/iOS-Logger.git', :tag => s.version.to_s }

  s.source_files  = 'Logger/*.swift'
end
