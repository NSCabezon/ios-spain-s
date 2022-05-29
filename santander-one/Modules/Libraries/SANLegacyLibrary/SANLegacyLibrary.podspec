Pod::Spec.new do |s|
  s.name             = 'SANLegacyLibrary'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SANLegacyLibrary.'
  s.description      = <<-DESC
This Framework is intended to define the abstract interface for the managers implemented in SANLegacyLibrary Layer and its related Data Objects.
                       DESC

  s.homepage         = 'https://santander-one-app.ciber.es/ios/santander-one/-/tree/develop/Modules/Libraries/SANLegacyLibrary'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'esepakuto' => 'francisco.lorenzo@talentomobile.com' }
  s.source           = { :git => 'https://santander-one-app.ciber.es/ios/santander-one.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '10.3'

  s.source_files = 'SANLegacyLibrary/**/*{.swift}'

  s.dependency 'Fuzi', '~> 3.0'
  s.dependency 'SwiftyJSON', '~> 5.0'
  s.dependency 'CoreDomain'

end
