Pod::Spec.new do |spec|
  spec.name         = "SavingProducts"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Saving Products."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Saving Products framework
                   DESC

  spec.homepage     = "http://EXAMPLE/SavingProducts"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Adrián Escriche Martín' => 'aescriche@ext.vectoritcgroup.com' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/SavingProducts.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "SavingProducts", "SavingProducts/**/*.{swift}"
    subspec.exclude_files  = "SavingProducts/Tests/**/*.{swift}", "SavingProducts/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'SavingProducts' => ['SavingProducts/**/*{xib,xcassets}']
    }
  end

  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "SavingProducts", "SavingProducts/**/*.{swift}", "SavingProducts/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "SavingProducts/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'SavingProducts' => ['SavingProducts/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreDomain"
  spec.dependency "CoreFoundationLib"
  spec.dependency "Commons"
  spec.dependency "UI"
  spec.dependency "UIOneComponents"
  spec.dependency "SANLegacyLibrary"
  spec.dependency "OfferCarousel"
  spec.dependency "UIOneComponents"
  spec.dependency "PdfCommons"

  spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }
  spec.test_spec 'Tests' do |test_spec|
    test_spec.resources = 'SavingProducts/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'SavingProducts/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'CoreTestData'
    test_spec.dependency 'UnitTestCommons'
  end
end
