
Pod::Spec.new do |spec|
  spec.name         = "ESCommons"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of ESCommons."
  spec.description  = <<-DESC
  The Commons framework
                   DESC
  spec.homepage     = "http://EXAMPLE/ESCommons"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "JCEstela" => "jose.carlos.estela@ciberexperis.es" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/ESCommons.git", :tag => "#{spec.version}" }
  spec.source_files  = "ESCommons", "ESCommons/**/*.{swift}"
  spec.resource_bundles = { 'ESCommons' => ['ESCommons/**/*{xib,xcassets}'] }

  spec.dependency "CoreFoundationLib"
  spec.dependency "SANLibraryV3"
  spec.dependency "SANLegacyLibrary"
  spec.dependency "UI"

end
