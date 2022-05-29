Pod::Spec.new do |spec|
  spec.name         = "Account"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Accounts."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Accounts framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Accounts"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'José Carlos Estela' => 'josecarlosestela@gmail.com' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Accounts.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "Accounts", "Accounts/**/*.{swift}"
    subspec.exclude_files  = "Accounts/Tests/**/*.{swift}", "Accounts/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'Account' => ['Accounts/**/*{xib,xcassets}']
    }
  end

  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "Accounts", "Accounts/**/*.{swift}", "Accounts/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "Accounts/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'Account' => ['Accounts/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreDomain"
  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "UIOneComponents"
  spec.dependency "SANLegacyLibrary"
  spec.dependency "OfferCarousel"

  spec.test_spec 'AccountsTests' do |test_spec|
    test_spec.resources = 'Accounts/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'Accounts/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'UnitTestCommons'
  end
end
