Pod::Spec.new do |s|
  s.name             = 'SANLibraryV3'
  s.version          = '7.1.90'
  s.summary          = 'This is SANLibraryV3.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This Framework is intended to implement Santander Apps SANLibraryV3 Layer and allow developers abstract from it.
                       DESC

  s.homepage         = 'https://gitlab.ciber-es.com/mobility/San_ES/Common/iOS/iOS-Santander-Library-V3'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Juan Aparicio' => 'ricardo.lechuga@ciberexperis.es' }
  s.source           = { :git => 'ssh://git@gitlab.ciber-es.com:7346/mobility/San_ES/Common/iOS/iOS-Santander-Library-V3.git', :tag => s.version.to_s }
  #s.source           = { :git => 'ssh://git@gitlab.ciber-es.com:7346/mobility/iOS-Santander-Library-V3.git', :branch => "feature/cocoapods" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.3'

  s.source_files = 'SANLibraryV3/**/*'
  s.exclude_files = 'SANLibraryV3/**/*.plist'

  # s.resource_bundles = {
  #   'JALib' => ['JALib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.dependency 'SANLegacyLibrary'
  s.dependency 'Fuzi', '~> 3.0'
  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'Alamofire-Synchronous', '~> 4.0'
  s.dependency 'SwiftyJSON', '~> 5.0'
  s.dependency 'CoreDomain'
  s.dependency 'SANServicesLibrary'
  s.dependency 'SANSpainLibrary'
  s.dependency 'CoreFoundationLib'
  s.library     = "xml2"
  s.requires_arc    = true
  s.xcconfig      = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

end
