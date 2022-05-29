Pod::Spec.new do |spec|
  spec.name         = "Onboarding"
  spec.version      = "0.1.0"
  spec.summary      = "A short description of Onboarding."
  spec.description  = <<-DESC
  The Onboarding framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Onboarding"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "José Ignacio" => "jose.ignacio.juan@ciberexperis.es" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Onboarding.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "Onboarding/**/*.{swift}"
    subspec.exclude_files  = "Onboarding/Tests/**/*.{swift}", "Onboarding/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'Onboarding' => ['Onboarding/**/*{xib,xcassets}']
    }
  end
  
  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "Onboarding/**/*.{swift}"

    subspec.resource_bundles = {
      'Onboarding' => ['Onboarding/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "PersonalArea"  
  spec.dependency "Localization"
end
