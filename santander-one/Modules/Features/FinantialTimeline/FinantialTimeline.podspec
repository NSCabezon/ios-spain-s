#
# Be sure to run `pod lib lint IB-FinantialTimeline-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FinantialTimeline'
  s.version          = '1.1.41'
s.summary          = 'Intelligent Banking: Finantial Timeline'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Finantial Timeline component developed as component for Intelligent Baking
                       DESC

  s.homepage         = 'https://github.com/globile-software/IB-FinantialTimeline-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Francisco Lorenzo' => 'francisco.lorenzo@talentomobile.com' }
  s.source           = { :git => 'ssh://git@gitlab.ciber-es.com:7346/mobility/San_ES/Globile/ios/ios-timeline.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.3'
  #s.static_framework = true
  s.source_files = 'FinantialTimeline/Classes/**/*.swift'

  s.resource_bundles = {
    'FinantialTimeline' => ['FinantialTimeline/Assets/**/*.{xcassets,storyboard,ttf,strings,xib,m4a,caf}']
  }

  s.dependency 'UI'
  s.dependency 'CoreFoundationLib'

  s.test_spec 'TimeLineTests' do |test_spec|
    test_spec.resources = 'FinantialTimeline/Test/TestsAssets/**/*.{json}'
    test_spec.source_files = 'FinantialTimeline/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'Quick', '~> 2.1'
    test_spec.dependency 'Nimble', '~> 8.0'
    test_spec.dependency 'OHHTTPStubs', '~> 8.0'
    test_spec.dependency 'OHHTTPStubs/Swift', '~> 8.0'
  end
end
