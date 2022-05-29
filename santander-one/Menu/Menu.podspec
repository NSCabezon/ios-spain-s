Pod::Spec.new do |spec|
  spec.name         = "Menu"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Menu."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Menu framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Menu"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'José Carlos Estela' => 'josecarlosestela@gmail.com' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Menu.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "Menu", "Menu/**/*.{swift}"
    subspec.exclude_files  = "Menu/Tests/**/*.{swift}", "Menu/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'Menu' => ['Menu/**/*{xib,xcassets}']
    }
  end

  spec.subspec 'Example' do |subspec|
    subspec.source_files  = "Menu", "Menu/**/*.{swift}", "Menu/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "Menu/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'Menu' => ['Menu/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "SANLegacyLibrary"
  spec.dependency 'OpenCombine', '~> 0.12.0'
  spec.dependency 'OpenCombineDispatch', '~> 0.12.0'
  spec.dependency "UIOneComponents"
end
