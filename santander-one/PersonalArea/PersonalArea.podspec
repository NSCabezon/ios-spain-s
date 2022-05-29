Pod::Spec.new do |spec|
  spec.name         = "PersonalArea"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of PersonalArea."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The PersonalArea framework
                   DESC

  spec.homepage     = "http://EXAMPLE/PersonalArea"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'alvaro' => 'alvaro.olave@ciberexperis.com' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/PersonalArea.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'

  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "PersonalArea", "PersonalArea/**/*.{swift}"
    subspec.exclude_files  = "PersonalArea/Tests/**/*.{swift}", "Example/**", "PersonalArea/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'PersonalArea' => ['PersonalArea/**/*{xib,xcassets}']
    }
  end

  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "PersonalArea", "PersonalArea/**/*.{swift}", "PersonalArea/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "PersonalArea/Tests/**/*.{swift}", "Example/**"

    subspec.resource_bundles = {
      'PersonalArea' => ['PersonalArea/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "Operative"
  spec.dependency "SANLegacyLibrary"
  spec.dependency "CorePushNotificationsService"
  spec.dependency "CoreDomain"
  
  spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }
  spec.test_spec 'Tests' do |test_spec|
    test_spec.requires_app_host = true
    test_spec.resources = 'PersonalArea/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'PersonalArea/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'CoreTestData'
    test_spec.dependency 'UnitTestCommons'
  end
end
