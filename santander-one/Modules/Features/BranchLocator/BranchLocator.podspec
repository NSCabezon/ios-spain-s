#
# Be sure to run `pod lib lint BranchLocator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BranchLocator'
  s.version          = '2.2.4'
  s.summary          = 'BranchLocator component'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Branch locator'

  s.swift_version = '5.0'

  s.homepage         = 'https://gitlab.alm.gsnetcloud.corp/branchlocator/bl-ios-lib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nscabezon' => 'nscabezon@gmail.com' }
  s.source           = { :git => 'https://github.com/globile-software/BranchLocator-iOS', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'

  s.source_files = 'BranchLocator/**/*.{h,m,swift}'
  s.resource_bundles = { 'BranchLocator' => ['BranchLocator/**/*.{xcassets,ttf,strings,json,xib,gif,storyboard}'] }

  
  #s.static_framework = true
  s.frameworks = 'UIKit', 'MapKit', 'CoreLocation'
  s.dependency 'ObjectMapper', '3.4.2'
  s.dependency 'UI'
  
end
