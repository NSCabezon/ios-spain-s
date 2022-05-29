Pod::Spec.new do |spec|
  spec.name         = "WebViews"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of WebViews."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The WebViews framework
                   DESC

  spec.homepage     = "http://EXAMPLE/WebViews"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'José Carlos Estela' => 'josecarlosestela@gmail.com' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/WebViews.git", :tag => "#{spec.version}" }
  spec.source_files  = "WebViews", "WebViews/**/*.{swift}"
  spec.exclude_files  = "WebViews/Tests/**/*.{swift}"

  spec.resource_bundles = {
    'WebViews' => ['WebViews/**/*{xib,xcassets}']
  }
  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  
  spec.dependency "UI"
  spec.dependency "CoreFoundationLib"
end
