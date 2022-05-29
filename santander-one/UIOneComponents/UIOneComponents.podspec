#
# Be sure to run `pod lib lint UIOneComponents.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UIOneComponents'
  s.version          = '0.1.0'
  s.summary          = 'A short description of UIOneComponents.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ADRIAN ARCALA OCON/UIOneComponents'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ADRIAN ARCALA OCON' => 'x488631@gruposantander.es' }
  s.source           = { :git => 'https://github.com/ADRIAN ARCALA OCON/UIOneComponents.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '10.3'

  s.source_files = 'UIOneComponents/Classes/**/*'

  s.resource_bundles = {
    'UIOneComponents' => ['UIOneComponents/**/*{xib,xcassets}']
  }

  s.dependency "UI"
  s.dependency "CoreFoundationLib"
end
