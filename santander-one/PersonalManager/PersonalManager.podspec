Pod::Spec.new do |spec|
  spec.name         = "PersonalManager"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of PersonalManager."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The PersonalManager framework
                   DESC

  spec.homepage     = "http://EXAMPLE/PersonalManager"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Victor' => 'victor.carrilero@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/PersonalManager.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "PersonalManager", "PersonalManager/**/*.{swift}"
    subspec.exclude_files  = "PersonalManager/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'PersonalManager' => ['PersonalManager/**/*{xib,xcassets}']
    }
  end
  
  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "PersonalManager", "PersonalManager/**/*.{swift}", "PersonalManager/CountryExampleAppSupportFiles/**/*.{swift}"
    
    subspec.resource_bundles = {
      'PersonalManager' => ['PersonalManager/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "Operative"
  spec.dependency "SANLegacyLibrary"

  spec.test_spec 'PersonalManagerTests' do |test_spec|
    test_spec.resources = 'Example/PersonalManager_ExampleTests/**/*.{json,xml}'
    test_spec.source_files = 'Example/PersonalManager_ExampleTests/**/*.{h,m,swift}'
    test_spec.dependency 'UnitTestCommons'
  end
end
