Pod::Spec.new do |spec|
  spec.name         = "GlobalPosition"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of GlobalPosition."
  spec.description  = <<-DESC
  The GlobalPosition framework
                   DESC

  spec.homepage     = "http://EXAMPLE/GlobalPosition"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author             = { "JCEstela" => "jose.carlos.estela@ciberexperis.es" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/GlobalPosition.git", :tag => "#{spec.version}" }
  spec.source_files  = "GlobalPosition", "GlobalPosition/**/*.{swift,xib}"
  spec.exclude_files  = "Example/**"

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "UI"
  spec.dependency "UIOneComponents"
  spec.dependency "Cards"
  spec.dependency "CoreDomain"
  spec.dependency "CoreFoundationLib"
  spec.dependency "Operative"
  spec.dependency "SANLegacyLibrary"
  spec.dependency "OfferCarousel"
end
