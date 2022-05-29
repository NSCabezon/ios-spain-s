Pod::Spec.new do |s|
  s.name             = 'LoginCommon'
  s.version          = '0.0.1'
  s.summary          = 'A short description of LoginCommon.'
  s.description      = <<-DESC
Decription.
                       DESC
  s.homepage         = 'https://gitlab.ciber-es.com/mobility/Ciber/Common/iOS/iOS-Domain-Common'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Juan Aparicio' => 'ricardo.lechuga@ciberexperis.es' }
  s.source           = { :git => 'ssh://git@gitlab.ciber-es.com:7346/mobility/Ciber/Common/iOS/iOS-Domain-Common.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.3'
  s.source_files = 'LoginCommon/**/*.swift'
  s.dependency 'CoreFoundationLib'
end
