Pod::Spec.new do |s|
  s.name         = 'Locker'
  s.version      = '2.0.0'
  s.summary      = 'Locker'

  s.description  = 'Locker. Locker'

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

  s.source       = { :git => 'ssh://git@gitlab.ciber-es.com:7346/mobility/Ciber/Common/iOS/iOS-Locker.git', :tag => s.version.to_s }
  s.source_files  = 'Locker/*.swift'
end
