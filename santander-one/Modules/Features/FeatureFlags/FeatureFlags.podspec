Pod::Spec.new do |spec|
  spec.name         = "FeatureFlags"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of FeatureFlags."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The FeatureFlags framework
                   DESC

  spec.homepage     = "http://EXAMPLE/FeatureFlags"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'jcarlosEstela' => 'jose.carlos.estela@experis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/FeatureFlags.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'

  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "FeatureFlags", "FeatureFlags/**/*.{swift}"
    subspec.exclude_files  = "FeatureFlags/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.resource_bundles = {
      'FeatureFlags' => ['FeatureFlags/**/*{xib,xcassets}']
    }
  end

  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "FeatureFlags", "FeatureFlags/**/*.{swift}"
    subspec.resource_bundles = {
      'FeatureFlags' => ['FeatureFlags/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "UIOneComponents"
end
