#
# Be sure to run `pod lib lint SelfSignedCertificate.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SelfSignedCertificate'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SelfSignedCertificate.'

  s.description      = <<-DESC
                      This pod is a copy of https://github.com/svdo/swift-SelfSignedCert with some modifications.
                      We could make a fork of it and make this modifications
                       DESC

  s.homepage         = 'https://github.com/Israel Marcos Álvarez Mesa/SelfSignedCertificate'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Israel Marcos Álvarez Mesa' => 'marcos.alvarez@experis.es' }
  s.source           = { :git => 'https://github.com/Israel Marcos Álvarez Mesa/SelfSignedCertificate.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'

  s.source_files = 'SelfSignedCertificate/**/*.swift'
  s.dependency "SecurityExtensions", "~> 4.0"
  s.dependency "IDZSwiftCommonCrypto", "~> 0.13"
  s.dependency "SwiftBytes", "~> 0.6"
end
