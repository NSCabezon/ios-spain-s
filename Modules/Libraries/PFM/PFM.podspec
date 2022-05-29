Pod::Spec.new do |s|

  s.name         = 'PFM'
   s.version      = '1.0.12'
   s.summary      = 'PFM for Santander Retail'
  s.description  = 'PFM. Model data and SQL structure for PFM Santander retail internal database.'

  s.homepage     = 'http://www.ciberexperis.com'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author    = 'Ciber'
  s.platform     = :ios, '10.3'

  s.source       = { :git => 'ssh://git@gitlab.ciber-es.com:7346/mobility/San_ES/Retail/iOS/iOS-Santander-PFM.git', :tag => s.version.to_s }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source_files  = 'PFM/**/*.{swift,h,m}'

  s.dependency 'SQLite.swift/SQLCipher'
  s.dependency 'SQLCipher'
  s.dependency 'Logger'
  s.dependency 'CoreFoundationLib'

  s.pod_target_xcconfig = { 'OTHER_CFLAGS' => '-DSQLITE_HAS_CODEC' }
end
