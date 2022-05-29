Pod::Spec.new do |s|
  s.name             = 'SANServicesLibrary'
  s.version          = '1.0.0'
  s.summary          = 'A short description of CoreDomain.'
  s.description      = <<-DESC
This Framework is intended to implement the definitions of the managers and representables defined on CoreDomain and SANSpainLibrary for the data layer of Spain.
                       DESC
  s.homepage         = 'https://santander-one-app.ciber.es/ios/santander-one/-/tree/develop/Modules/Libraries/SANLegacyLibrary'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vcarrilero' => 'victor.carrilero@experis.es' }
  s.source           = { :git => 'https://santander-one-app.ciber.es/ios/santander-one.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.3'
  s.source_files = 'SANServicesLibrary/**/*{.swift}'
  s.dependency 'CoreFoundationLib'
end
