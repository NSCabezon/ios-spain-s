#
# Be sure to run `pod lib lint PrivateMenu.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'PrivateMenu'
  spec.version          = '0.1.0'
  spec.summary          = 'A short description of PrivateMenu.'

  spec.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  spec.homepage         = 'https://github.com/Daniel Gómez Barroso/PrivateMenu'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { 'Daniel Gómez Barroso' => 'daniel.gomez.barroso@experis.es' }
  spec.source           = { :git => 'https://github.com/Daniel Gómez Barroso/PrivateMenu.git', :tag => spec.version.to_s }
  spec.default_subspec  = 'standard'

  spec.ios.deployment_target = '10.3'

  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "PrivateMenu", "PrivateMenu/**/*.{swift}"
    subspec.exclude_files  = "PrivateMenu/Tests/**/*.{swift}", "PrivateMenu/CountryExampleAppSupportFiles/**/*.{swift}"
    subspec.resource_bundles = {
      'PrivateMenu' => ['PrivateMenu/**/*{xib,xcassets,storyboard,ttf,json,strings}']
    }
  end
  
  spec.subspec 'ExampleApp' do |subspec|
    subspec.source_files  = "PrivateMenu", "PrivateMenu/**/*.{swift}"
    subspec.exclude_files  = "PrivateMenu/Tests/**/*.{swift}"

    subspec.resource_bundles = {
      'PrivateMenu' => ['PrivateMenu/**/*{xib,xcassets,storyboard,ttf,json,strings}']
    }
    subspec.dependency "QuickSetup/standard"
  end
  
  spec.dependency "UI"
  spec.dependency "SANLegacyLibrary"
  spec.dependency "CoreDomain"
  spec.dependency "OpenCombineFoundation"
  
  spec.pod_target_xcconfig = { 'ENABLED_TESTABILITY' => 'YES' }
  
  spec.test_spec 'Tests' do |test_spec|
    test_spec.resources = 'PrivateMenu/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'PrivateMenu/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'CoreTestData'
    test_spec.dependency 'UnitTestCommons'
  end
end
