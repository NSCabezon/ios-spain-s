Pod::Spec.new do |spec|
  spec.name         = "Ecommerce"
  spec.version      = "0.0.1"
  spec.summary      = "Module for Ecommerce."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Ecommerce framework
                   DESC
  spec.homepage     = 'https://santander-one-app.ciber.es/ios/santander-one'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Francisco del Real Escudero' => 'francisco.real@experis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Ecommerce.git", :tag => "#{spec.version}" }
  spec.source_files  = "Ecommerce", "Ecommerce/**/*.{swift}"

  spec.resource_bundles = {
    'Ecommerce' => ['Ecommerce/**/*{xib,xcassets}']
  }

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "ESCommons"
end
