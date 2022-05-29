#
# Be sure to run `pod lib lint SanNotificationService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SanNotificationService'
  s.version          = '0.1.0'
  s.summary          = 'A short description of SanNotificationService.'

  s.description      = <<-DESC
  SanNotificationService is a module that belongs to OneApp project.
                       DESC

  s.homepage         = 'https://github.com/oneapp/SanNotificationService'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ricardo Champa' => 'ricardo.champa@gruposantander.es' }
  s.source           = { :git => 'https://github.com/oneapp/SanNotificationService.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'

  s.source_files = 'SanNotificationService/Classes/**/*'
  
  s.dependency "CoreFoundationLib"
  s.dependency "CoreDomain"
end
