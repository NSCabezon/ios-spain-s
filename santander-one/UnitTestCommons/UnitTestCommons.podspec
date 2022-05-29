Pod::Spec.new do |s|
  s.name             = 'UnitTestCommons'
  s.version          = '0.1.0'
  s.summary          = 'A short description of UnitTestCommons.'
  s.swift_version    = '5.0'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://EXAMPLE/Accounts'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'César González' => 'cesar.gonzalez@ciberexperis.es' }
  s.source           = { :git => 'https://gitlab/UnitTestCommons.git', :tag => s.version.to_s }
  s.platform     = :ios, "10.3"

  s.source_files = "UnitTestCommons", "UnitTestCommons/**/*.{swift}"
  s.default_subspec  = 'legacy'
  
  s.subspec 'standard' do |subspec|
    subspec.source_files  = "UnitTestCommons", "UnitTestCommons/**/*.{swift}"
    subspec.exclude_files = "UnitTestCommons/Helpers/StubResponse.swift", "UnitTestCommons/Helpers/XmlDemoExecutor.swift"
  end

  s.subspec 'legacy' do |subspec|
    subspec.source_files = "UnitTestCommons", "UnitTestCommons/**/*.{swift}"
    
  end
  
  s.dependency "CoreFoundationLib"
  s.weak_framework = "XCTest"
  s.requires_arc = true
  s.pod_target_xcconfig = {
      'ENABLE_TESTING_SEARCH_PATHS' => 'YES',
      'OTHER_LDFLAGS' => '$(inherited) -weak-lXCTestSwiftSupport -Xlinker -no_application_extension',
    }
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
end
