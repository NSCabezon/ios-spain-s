Pod::Spec.new do |spec|
  spec.name         = "Loans"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Loans."
  spec.description  = <<-DESC
  The Loans framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Loans"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "JCEstela" => "jose.carlos.estela@ciberexperis.es" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Loans.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "Loans", "Loans/**/*.{swift}"
    subspec.exclude_files  = "Loans/Tests/**/*.{swift}", "Loans/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'Loans' => ['Loans/**/*{xib,xcassets}']
    }
  end
  
  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "Loans", "Loans/**/*.{swift}", "Loans/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "Loans/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'Loans' => ['Loans/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreDomain"
  spec.dependency "UI"
  spec.dependency 'CoreFoundationLib'
  spec.dependency "SANLegacyLibrary"
  spec.dependency 'OpenCombine', '~> 0.12.0'
  spec.dependency 'OpenCombineDispatch', '~> 0.12.0'
  spec.dependency 'OpenCombineFoundation', '~> 0.12.0'
  spec.dependency "Operative"
  spec.dependency "UIOneComponents"
  
  spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }
  spec.test_spec 'Tests' do |test_spec|
    test_spec.resources = 'Loans/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'Loans/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'CoreTestData'
    test_spec.dependency 'UnitTestCommons'
  end
end
