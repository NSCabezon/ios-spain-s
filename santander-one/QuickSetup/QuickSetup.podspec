
Pod::Spec.new do |spec|
  spec.name         = "QuickSetup"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of QuickSetup."
  spec.swift_version  = "5.0"

  spec.description  = <<-DESC
  The QuickSetup framework
                   DESC

  spec.homepage     = "http://EXAMPLE/QuickSetup"
  spec.author       = { "JCEstela" => "jose.carlos.estela@ciberexperis.es" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/QuickSetup.git", :tag => "#{spec.version}" }
  spec.source_files = "QuickSetup", "QuickSetup/**/*.{swift}"
  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  spec.dependency "CoreFoundationLib"
  spec.dependency "CoreTestData"
  spec.dependency "Localization"
  spec.dependency "CoreDomain"
end