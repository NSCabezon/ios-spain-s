Pod::Spec.new do |spec|
  spec.name         = "Funds"
  spec.version      = "0.0.1"
  spec.summary      = "Funds home, transactions and operations module"
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Funds framework
                   DESC

  spec.homepage     = "https://github.com/santander-group-europe"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Jose C. Yebes' => 'jose.yebes@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "https://github.com/santander-group-europe/ios-poland.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = '10.3'
  spec.default_subspec  = 'standard'

  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "Funds", "Funds/**/*.{swift}"
    subspec.exclude_files  = "Funds/Tests/**/*.{swift}", "Funds/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'Funds' => ['Funds/**/*{xib,xcassets}']
    }
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "UI"
  spec.dependency "LoginCommon"
  spec.dependency "CoreFoundationLib"
  spec.dependency 'Dynatrace'
  spec.dependency 'CoreFoundationLib'
  spec.dependency 'UIOneComponents'
end
