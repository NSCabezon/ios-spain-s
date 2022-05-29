Pod::Spec.new do |spec|
  spec.name         = "Localization"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Localization."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Localization framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Localization"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Francisco Del Real Escudero' => 'francisco.real@experis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Localization.git", :tag => "#{spec.version}" }
  spec.source_files  = "Localization", "Localization/**/*.{swift}"

  spec.resource_bundles = {
    'Localization' => ['Localization/**/*{xib,xcassets}']
  }

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency 'CoreFoundationLib'
end
