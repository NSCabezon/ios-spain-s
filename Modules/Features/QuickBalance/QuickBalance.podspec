
Pod::Spec.new do |spec|
  spec.name         = "QuickBalance"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of QuickBalance."
  spec.description  = <<-DESC
  The QuickBalance framework
                   DESC
  spec.homepage     = "http://EXAMPLE/QuickBalance"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "RubenMarquez" => "ruben.marquez@ciberexperis.es" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/QuickBalance.git", :tag => "#{spec.version}" }
  spec.source_files  = "QuickBalance", "QuickBalance/**/*.{swift}"

  spec.dependency "ESCommons"
  spec.dependency "CoreFoundationLib"
  spec.dependency "PersonalArea"
  spec.dependency "RetailLegacy"
end
