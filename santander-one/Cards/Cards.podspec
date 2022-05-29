Pod::Spec.new do |spec|
  spec.name             = 'Cards'
  spec.version          = '0.1.0'
  spec.summary          = 'A short description of Cards.'
  spec.swift_version    = '5.0'
  spec.description      = <<-DESC
  This is the card home framework
                       DESC

  spec.homepage         = 'https://Example/Cards'
  spec.platform         = :ios, "10.3"
  spec.license          = { :type => 'MIT', :file => 'FILE_LICENSE' }
  spec.author           = { 'Juan Carlos López Robles' => 'juan.carlos.lopez@ciberexperis.es' }
  spec.source           = { :git => 'http://gitlab/Cards.git', :tag => "#{spec.version}" }
  spec.default_subspec  = 'Standard'
  
  spec.subspec 'Standard' do |subspec|
    subspec.source_files  = "Cards", "Cards/**/*.{swift}"
    subspec.exclude_files  = "Cards/Tests/**/*.{swift}",
    "Cards/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.resource_bundles = {
      'Cards' => ['Cards/**/*{strings,xib,xcassets}']
    }
  end
  
  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "Cards", "Cards/**/*.{swift}",
    "Cards/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "Cards/Tests/**/*.{swift}"
    subspec.resource_bundles = {
      'Cards' => ['Cards/**/*{strings,xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end
  
  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "UI"
  spec.dependency "UIOneComponents"
  spec.dependency "CoreFoundationLib"
  spec.dependency "Operative"
  spec.dependency "SANLegacyLibrary"

  spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }
  
  spec.test_spec 'Tests' do |test_spec|
    test_spec.resources = 'Cards/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'Cards/Tests/**/*.{h,m,swift}',
    "Cards/CountryExampleAppSupportFiles/**/*.{swift}"
    test_spec.dependency 'UnitTestCommons'
    test_spec.dependency 'CoreTestData'
  end
  
end
