Pod::Spec.new do |spec|
  spec.name         = "TransferOperatives"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of TransferOperatives."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The TransferOperatives framework
                   DESC

  spec.homepage     = "http://EXAMPLE/TransferOperatives"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Francisco Del Real Escudero' => 'francisco.real@experis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/TransferOperatives.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'

  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "TransferOperatives", "TransferOperatives/**/*.{swift}"
    subspec.exclude_files  = "TransferOperatives/CountryExampleAppSupportFiles/**/*.{swift}", 
        "TransferOperatives/Tests/**/*.{swift}"
    subspec.resource_bundles = {
      'TransferOperatives' => ['TransferOperatives/**/*{xib,xcassets}']
    }
  end

  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "TransferOperatives", "TransferOperatives/**/*.{swift}"
    subspec.exclude_files  = "TransferOperatives/Tests/**/*.{swift}"
    subspec.resource_bundles = {
      'TransferOperatives' => ['TransferOperatives/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.test_spec 'Tests' do |test_spec|
    test_spec.requires_app_host = true
    test_spec.resources = 'TransferOperatives/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'TransferOperatives/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'UnitTestCommons'
    test_spec.dependency 'CoreTestData'
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }

  spec.dependency "OneAuthorizationProcessor"
  spec.dependency "CoreFoundationLib"
  spec.dependency "UIOneComponents"
  spec.dependency "Operative"
  spec.dependency "UI"
  spec.dependency "PdfCommons"
end
