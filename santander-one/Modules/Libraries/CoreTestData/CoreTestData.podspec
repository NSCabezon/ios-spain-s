Pod::Spec.new do |spec|
  spec.name         = "CoreTestData"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of CoreTestData."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The CoreTestData framework
                   DESC

  spec.homepage     = "http://EXAMPLE/CoreTestData"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Francisco Del Real Escudero' => 'francisco.real@experis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/CoreTestData.git", :tag => "#{spec.version}" }
  spec.source_files = "CoreTestData", "CoreTestData/**/*.{swift}"
  spec.resources    = "CoreTestData/Demo/**/*.{json}"
  spec.resource_bundles = {
    "CoreTestData" => ['CoreTestData/Localized/*.strings']
  }
  
  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreDomain"
  spec.dependency "CoreFoundationLib"
  spec.dependency "SANLegacyLibrary"

end
