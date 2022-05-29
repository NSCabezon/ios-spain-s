Pod::Spec.new do |spec|
  spec.name         = "RetailLegacy"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of RetailLegacy."
  spec.swift_version    = '5.0'
  spec.description  = <<-DESC
  The RetailLegacy framework
                   DESC

  spec.homepage     = "http://EXAMPLE/RetailLegacy"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Victor' => 'victor.carrilero@ciberexperis.es' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/RetailLegacy.git", :tag => "#{spec.version}" }
  spec.source_files  = "RetailLegacy", "RetailLegacy/**/*.{swift}"

  spec.resource_bundles = {
    'RetailLegacy' => ['RetailLegacy/**/*{xib,storyboard,xcassets,xml}']
  }

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

  spec.dependency "SANLegacyLibrary"
  spec.dependency "GlobalPosition"
  spec.dependency "LoginCommon"
  spec.dependency "Loans"
  spec.dependency "SavingProducts"
  spec.dependency "Cards"
  spec.dependency "Account"
  spec.dependency "PersonalArea"
  spec.dependency "PersonalManager"
  spec.dependency "Operative"
  spec.dependency "Transfer"
  spec.dependency "Inbox"
  spec.dependency "Menu"
  spec.dependency "Bills"
  spec.dependency "GlobalSearch"
  spec.dependency "UI"
  spec.dependency "Localization"
  spec.dependency "BranchLocator"
  spec.dependency "FinantialTimeline"
  spec.dependency "IQKeyboardManagerSwift", "6.5.6"
  spec.dependency "SwiftyBeaver", "~> 1.7.0"
  spec.dependency "lottie-ios", "3.2.3"
  spec.dependency "Alamofire-Synchronous", "~> 4.0"
  spec.dependency "TealiumIOS", "~> 5.6.6"
  spec.dependency "CommonAppExtensions"
  spec.dependency "PdfCommons"
  spec.dependency "WebViews"
  spec.dependency "OneAuthorizationProcessor"
  spec.dependency "CoreDomain"
  spec.dependency "CoreFoundationLib"
  spec.dependency "Funds"
  spec.dependency "Onboarding"
  spec.dependency "FeatureFlags"
  spec.dependency "PrivateMenu"
end
