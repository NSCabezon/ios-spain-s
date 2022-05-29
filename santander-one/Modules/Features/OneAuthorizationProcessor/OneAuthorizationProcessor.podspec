Pod::Spec.new do |spec|
  spec.name         = "OneAuthorizationProcessor"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of OneAuthorizationProcessor."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The OneAuthorizationProcessor framework
                   DESC

  spec.homepage     = "http://EXAMPLE/OneAuthorizationProcessor"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'jcarlosEstela' => 'jose.carlos.estela@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/OneAuthorizationProcessor.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'

  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "OneAuthorizationProcessor", "OneAuthorizationProcessor/**/*.{swift}"
    subspec.resource_bundles = {
      'OneAuthorizationProcessor' => ['OneAuthorizationProcessor/**/*{xib,xcassets}']
    }
  end

  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "OneAuthorizationProcessor", "OneAuthorizationProcessor/**/*.{swift}", "CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.resource_bundles = {
      'OneAuthorizationProcessor' => ['OneAuthorizationProcessor/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "OpenCombine"
  spec.dependency "Operative"
end
