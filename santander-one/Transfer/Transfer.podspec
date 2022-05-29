Pod::Spec.new do |spec|
  spec.name         = "Transfer"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Transfer."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Transfer framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Transfer"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Juan Carlos López Robles' => 'juan.carlos.lopez@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Transfer.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "Transfer", "Transfer/**/*.{swift}"
    subspec.exclude_files  = "Transfer/Transfer_ExampleTest/**/*.{swift}", "Transfer/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.resource_bundles = {
      'Transfer' => ['Transfer/**/*{xib,xcassets}']
    }
  end
  
  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "Transfer", "Transfer/**/*.{swift}", "Transfer/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "Transfer/Transfer_ExampleTest/**/*.{swift}"
    subspec.resource_bundles = {
      'Transfer' => ['Transfer/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "Operative"
  spec.dependency "SANLegacyLibrary"
  spec.dependency "PdfCommons"
  spec.dependency "TransferOperatives"
  spec.dependency "UIOneComponents"
  
  spec.test_spec 'TransferTests' do |test_spec|
    test_spec.resources = 'Transfer/Transfer_ExampleTest/**/*.{json,xml}'
    test_spec.source_files = 'Transfer/Transfer_ExampleTest/**/*.{h,m,swift}'
    test_spec.dependency 'UnitTestCommons'
  end
end
