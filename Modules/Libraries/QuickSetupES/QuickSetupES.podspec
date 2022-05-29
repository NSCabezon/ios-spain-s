Pod::Spec.new do |spec|
  spec.name         = "QuickSetupES"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of QuickSetupES."
  spec.swift_version  = "5.0"
  spec.description  = <<-DESC
  The QuickSetup framework
                   DESC

  spec.homepage     = "http://EXAMPLE/QuickSetupES"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "JCEstela" => "jose.carlos.estela@ciberexperis.es" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/QuickSetupES.git", :tag => "#{spec.version}" }
  spec.source_files  = "QuickSetupES", "QuickSetupES/**/*.{swift}"
  spec.resources = "QuickSetupES/Assets/**/*.{json,xml}"

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.dependency "QuickSetup"
  spec.dependency "CoreFoundationLib"
  spec.dependency "SANLibraryV3"
  spec.dependency "Localization"
end
