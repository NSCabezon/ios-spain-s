Pod::Spec.new do |spec|
  spec.name         = "GlobalSearch"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of GlobalSearch."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The GlobalSearch framework
                   DESC

  spec.homepage     = "http://EXAMPLE/GlobalSearch"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'alvaro' => 'alvaro.olave@ciberexperis.com' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/GlobalSearch.git", :tag => "#{spec.version}" }
  spec.source_files  = "GlobalSearch", "GlobalSearch/**/*.{swift}"
  spec.exclude_files  = "Example/**"

  spec.resource_bundles = {
    'GlobalSearch' => ['GlobalSearch/**/*{xib,xcassets}']
  }

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "SANLegacyLibrary"
  spec.dependency 'CoreFoundationLib'
  spec.dependency "UI"
  spec.dependency "IQKeyboardManagerSwift"
end
