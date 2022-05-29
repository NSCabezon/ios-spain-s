#
# Be sure to run `pod lib lint CommonAppExtensions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CommonAppExtensions'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CommonAppExtensions.'

  s.description      = <<-DESC
This module belongs to OneApp.
                       DESC

  s.homepage         = 'https://github.com/OneApp/CommonAppExtensions'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ricardo Champa' => 'ricardo.champa@gruposantander.es' }
  s.source           = { :git => 'https://github.com/OneApp/CommonAppExtensions.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'

  s.source_files = 'CommonAppExtensions/Classes/**/*'
  s.dependency "CoreDomain"
  s.dependency "CoreFoundationLib"
  s.dependency 'SANLegacyLibrary'
end
