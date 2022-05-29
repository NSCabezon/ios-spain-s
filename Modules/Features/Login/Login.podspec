Pod::Spec.new do |spec|
  spec.name         = "Login"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Login."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Login framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Login"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'ManuelMartinezCiber' => 'manuel.martinez@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Login.git", :tag => "#{spec.version}" }
  spec.source_files  = "Login", "Login/**/*.{swift}"
  spec.exclude_files  = "Example/**"

  spec.resource_bundles = {
    'Login' => ['Login/**/*{xib,xcassets}']
  }

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "UI"
  spec.dependency "CoreDomain"
  spec.dependency "CoreFoundationLib"
  spec.dependency "ESCommons"
  spec.dependency "SANLibraryV3"
  spec.dependency "LoginCommon"
  spec.dependency "Ecommerce"
  spec.dependency "SANServicesLibrary"
  spec.dependency "CorePushNotificationsService"
  spec.dependency "Dynatrace"
end
