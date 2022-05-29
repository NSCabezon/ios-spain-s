Pod::Spec.new do |spec|
spec.name         = "CorePushNotificationsService"
spec.version      = "0.0.1"
spec.summary      = "Services offered from Core to country app related to push notifications"
spec.swift_version    = '5.0'
spec.description  = <<-DESC
The CorePushNotificationsService framework. Services offered from Core to country app related to push notifications, like deep linking or OTP integration.
                 DESC

spec.homepage     = "http://EXAMPLE/CorePushNotificationsService"
spec.license      = { :type => 'MIT', :file => 'LICENSE' }
spec.author       = { 'mobility-spain' => 'victor.carrilero@ciberexperis.es' }
spec.platform     = :ios, "10.3"
spec.source       = { :git => "http://gitlab/CorePushNotificationsService.git", :tag => "#{spec.version}" }
spec.source_files  = "CorePushNotificationsService", "CorePushNotificationsService/**/*.{swift}"
spec.exclude_files  = "Example/**"
spec.resource_bundles = {
  'CorePushNotificationsService' => ['CorePushNotificationsService/**/*{xib,xcassets}']
}

spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

spec.dependency 'CoreFoundationLib'
end
