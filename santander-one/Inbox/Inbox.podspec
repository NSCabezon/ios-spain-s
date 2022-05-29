Pod::Spec.new do |spec|
  spec.name         = "Inbox"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Inbox."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Inbox framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Inbox"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'ManuelMartinezCiber' => 'manuel.martinez@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Inbox.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "Inbox", "Inbox/**/*.{swift}"
    subspec.exclude_files  = "Inbox/Tests/**/*.{swift}", "Inbox/CountryExampleAppSupportFiles/**/*.{swift}"

    subspec.resource_bundles = {
      'Inbox' => ['Inbox/**/*{xib,xcassets}']
    }
  end

  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "Inbox", "Inbox/**/*.{swift}", "Inbox/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.exclude_files  = "Inbox/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'Inbox' => ['Inbox/**/*{xib,xcassets}']
    }
    subspec.dependency "QuickSetup"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "SANLegacyLibrary"
  spec.dependency 'CoreFoundationLib'
  spec.dependency "UI"

end
