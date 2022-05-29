Pod::Spec.new do |spec|
  spec.name         = "CoreDomain"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of CoreDomain."
  spec.swift_version  = "5.0"

  spec.description  = <<-DESC
  The CoreDomain framework
                   DESC

  spec.homepage     = "http://EXAMPLE/CoreDomain"
  spec.author       = { 'alvaro' => 'alvaro.olave@ciberexperis.com' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/CoreDomain.git", :tag => "#{spec.version}" }
  
  spec.source_files  = "CoreDomain", "CoreDomain/Standard/**/*.{swift}"

  spec.dependency 'OpenCombine', '~> 0.12.0'

end
