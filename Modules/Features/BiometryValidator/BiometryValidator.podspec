#
# Be sure to run `pod lib lint BiometryValidator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BiometryValidator'
  s.version          = '0.1.0'
  s.swift_version    = '5.0'
  s.summary          = 'Module for BiometryValidator.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Ruben Marquez/BiometryValidator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ruben Marquez' => 'ruben.marquez@experis.es' }
  s.platform      = :ios, "10.3"
  s.source           = { :git => 'https://github.com/Ruben Marquez/BiometryValidator.git', :tag => s.version.to_s }
  s.source_files     = 'BiometryValidator/**/*.{swift}'
  s.resource_bundles = { 'BiometryValidator' => ['BiometryValidator/**/*{xib,xcassets}'] }
  s.exclude_files    = "Example/**"
  s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "CoreFoundationLib"
  s.dependency "ESCommons"
  s.dependency "UI"
end
