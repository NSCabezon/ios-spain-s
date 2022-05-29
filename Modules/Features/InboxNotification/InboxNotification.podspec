Pod::Spec.new do |spec|
spec.name         = "InboxNotification"
spec.version      = "0.0.1"
spec.summary      = "Salesforce related inbox notifications"
spec.swift_version    = '5.0'
spec.description  = <<-DESC
Description.
                 DESC

spec.homepage     = "http://EXAMPLE/InboxNotification"
spec.license      = { :type => 'MIT', :file => 'LICENSE' }
spec.author       = { 'mobility-spain' => 'boris.chirino@experis.es' }
spec.platform     = :ios, "10.3"
spec.source       = { :git => "http://gitlab/InboxNotification.git", :tag => "#{spec.version}" }
spec.source_files  = "InboxNotification", "InboxNotification/**/*.{swift}"

spec.resource_bundles = {
    'InboxNotification' => ['InboxNotification/**/*{xib,xcassets}']
}

spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

spec.dependency "CoreFoundationLib"
spec.dependency "UI"
spec.dependency "Inbox"
spec.dependency "ESCommons"

end
