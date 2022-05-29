Pod::Spec.new do |spec|
  spec.name             = 'SantanderKeyAuthorization'
  spec.version          = '0.0.1'
  spec.summary          = 'SantanderKeyAuthorization Module'
  spec.description      = <<-DESC
A short description of SantanderKey
                       DESC

  spec.homepage         = 'https://github.com/santander-group-europe/ios-spain'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'ricardo-mantero' => 'ricardo.mantero@experis.es' }
  spec.source           = { :git => 'https://github.com/SantanderKeyAuthorization.git', :tag => spec.version.to_s }
  spec.platform     = :ios, "10.3"
  spec.default_subspec  = 'standard'

  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "SantanderKeyAuthorization", "SantanderKeyAuthorization/**/*.{swift}"
    subspec.exclude_files  = "SantanderKeyAuthorization/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'SantanderKeyAuthorization' => ['SantanderKeyAuthorization/**/*{xib,xcassets}']
    }
  end

   spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "SantanderKeyAuthorization", "SantanderKeyAuthorization/**/*.{swift}"
    subspec.exclude_files  = "SantanderKeyAuthorization/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'SantanderKeyAuthorization' => ['SantanderKeyAuthorization/**/*{xib,xcassets}']
    }
  end
   
   spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }
   spec.test_spec 'Tests' do |test_spec|
     test_spec.resources = 'SantanderKeyAuthorization/Tests/TestsAssets/**/*.{json,xml}'
     test_spec.source_files = 'SantanderKeyAuthorization/Tests/**/*.{h,m,swift}'
     test_spec.dependency 'CoreTestData'
     test_spec.dependency 'UnitTestCommons'
   end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "CoreFoundationLib"
  spec.dependency "UI"
  spec.dependency "ESUI"
  spec.dependency "ESCommons"
  spec.dependency "UIOneComponents"
  spec.dependency "Operative"
  spec.dependency "SwiftyRSA"
end
