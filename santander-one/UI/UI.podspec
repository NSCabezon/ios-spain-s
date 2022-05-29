
Pod::Spec.new do |spec|
  spec.name         = "UI"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of UI."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The UI framework
                   DESC

  spec.homepage     = "http://EXAMPLE/UI"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "JCEstela" => "jose.carlos.estela@ciberexperis.es" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/UI.git", :tag => "#{spec.version}" }
  spec.exclude_files = "Example/**", "UI/Tests/**/*.swift"
  spec.source_files  = "UI", "UI/**/*.{swift}"
  spec.resources = "UI/**/*.{xcassets}"
  spec.resource_bundles = {
    'UI' => ['UI/**/*.{storyboard,ttf,json,strings,xib,m4a,caf}']
  }
  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.dependency "CoreFoundationLib"
  spec.dependency "lottie-ios", "3.2.3"
  spec.dependency "youtube-ios-player-helper", '~> 1.0.3'
  spec.dependency "IQKeyboardManagerSwift", '6.5.6'
  spec.dependency "SwiftyGif", '~> 5.4'

  spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }
  spec.test_spec 'Tests' do |test_spec|
    test_spec.resources = 'UI/Tests/TestsAssets/**/*.{json,xml,gif}'
    test_spec.source_files = 'UI/Tests/Unit-Tests/**/*.{h,m,swift}'
    test_spec.dependency 'Operative'
    test_spec.dependency 'UnitTestCommons'
  end
  
end
