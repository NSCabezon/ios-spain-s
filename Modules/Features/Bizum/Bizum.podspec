Pod::Spec.new do |spec|
  spec.name         = "Bizum"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Bizum."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Bizum framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Bizum"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'mobility-spain' => 'victor.carrilero@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Bizum.git", :tag => "#{spec.version}" }
  spec.source_files  = "Bizum", "Bizum/**/*.{swift}"
  spec.exclude_files  = "Example/**"
  spec.resource_bundles = {
    'Bizum' => ['Bizum/**/*{xib,xcassets}']
  }

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "Operative"
  spec.dependency "SANLibraryV3"
  spec.dependency "ESUI"
  spec.dependency "SANSpainLibrary"
  spec.dependency "BiometryValidator"
end
