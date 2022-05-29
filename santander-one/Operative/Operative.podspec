Pod::Spec.new do |spec|
  spec.name         = "Operative"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Operative."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Operative framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Operative"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Victor Carrilero García' => 'victor.carrilero@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Operative.git", :tag => "#{spec.version}" }
  spec.default_subspec = 'standard'
    
  spec.resource_bundles = {
    'Operative' => ['Operative/**/*{xib,xcassets}']
  }

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "IQKeyboardManagerSwift"
  spec.dependency "SANLegacyLibrary"
  spec.dependency "Localization"
  spec.dependency "CorePushNotificationsService"
  spec.dependency "UIOneComponents"

  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "Operative", "Operative/**/*.{swift}"
    subspec.exclude_files  = "Operative/Tests/**/*.{swift}", "Operative/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'Operative' => ['Operative/**/*{xib,xcassets}']
    }
  end
  
  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "Operative", "Operative/**/*.{swift}", "Operative/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "Operative/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'Operative' => ['Operative/**/*{xib,xcassets}']
    }
  end
  
  spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }
  spec.test_spec 'Tests' do |test_spec|
    test_spec.resources = 'Operative/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'Operative/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'CoreTestData'
    test_spec.dependency 'UnitTestCommons'
  end
end
