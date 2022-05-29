Pod::Spec.new do |s|
  s.name             = 'SANSpainLibrary'
  s.version          = '1.0.0'
  s.summary          = 'A short description of SANSpainLibrary.'
  s.description      = <<-DESC
This Framework is intended to define the abstract interface for the managers and representables for the domain layer of Spain.
                       DESC
  s.homepage         = 'https://santander-one-app.ciber.es/ios/santander-one/-/tree/develop/Modules/Libraries/SANLegacyLibrary'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vcarrilero' => 'victor.carrilero@experis.es' }
  s.source           = { :git => 'https://santander-one-app.ciber.es/ios/santander-one.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.3'
  s.source_files = 'SANSpainLibrary/**/*{.swift}'
  
  s.dependency 'CoreDomain'
  s.dependency 'OpenCombine'
end
