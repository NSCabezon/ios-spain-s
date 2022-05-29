Pod::Spec.new do |spec|
  spec.name         = "Bills"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of Bills."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The Bills framework
                   DESC

  spec.homepage     = "http://EXAMPLE/Bills"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Juan Carlos López Robles' => 'juancarlos.lopez@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/Bills.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'standard'

    spec.subspec 'standard' do |subspec|
      subspec.source_files  = "Bills", "Bills/**/*.{swift}"
      subspec.exclude_files  = "Bills/Tests/**/*.{swift}", "Example/**", "Bills/CountryExampleAppSupportFiles/**/*.{swift}"

      subspec.resource_bundles = {
        'Bills' => ['Bills/**/*{xib,xcassets}']
      }
    end

    spec.subspec 'ExampleApp' do |subspec|
      subspec.source_files  = "Bills", "Bills/**/*.{swift}", "Bills/CountryExampleAppSupportFiles/**/*.{swift}"
      subspec.exclude_files  = "Bills/Tests/**/*.{swift}", "Example/**"

      subspec.resource_bundles = {
        'Bills' => ['Bills/**/*{xib,xcassets}']
      }
      subspec.dependency "QuickSetup"
    end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "UI"
  spec.dependency "Operative"
  spec.dependency "SANLegacyLibrary"
  spec.dependency 'CoreFoundationLib'
  
  spec.test_spec 'BillsTests' do |test_spec|
    test_spec.resources = 'Bills/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'Bills/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'UnitTestCommons'
  end
end
