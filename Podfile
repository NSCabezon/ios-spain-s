source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'

inhibit_all_warnings!

install! 'cocoapods',
:deterministic_uuids => false

def features
  pod 'GlobalPosition', :path => 'santander-one/GlobalPosition'
  pod 'Login', :path => 'Modules/Features/Login'
  pod 'LoginCommon', :path => 'santander-one/Modules/Features/LoginCommon'
  pod 'Loans', :path => 'santander-one/Loans', :testspecs => ['Tests']
  pod 'Cards', :path => 'santander-one/Cards', :testspecs => ['Tests']
  pod 'Account', :path => 'santander-one/Accounts'
  pod 'PersonalArea', :path => 'santander-one/PersonalArea', :testspecs => ['Tests']
  pod 'PersonalManager', :path => 'santander-one/PersonalManager'
  pod 'Operative', :path => 'santander-one/Operative', :testspecs => ['Tests']
  pod 'Transfer', :path => 'santander-one/Transfer'
  pod 'Localization', :path => 'santander-one/Localization'
  pod 'Inbox', :path => 'santander-one/Inbox'
  pod 'Menu', :path => 'santander-one/Menu'
  pod 'Bills', :path => 'santander-one/Bills'
  pod 'GlobalSearch', :path => 'santander-one/GlobalSearch'
  pod 'Bizum', :path => 'Modules/Features/Bizum'
  pod 'OfferCarousel', :path => 'santander-one/OfferCarousel'
  pod 'UI', :path => 'santander-one/UI', :testspecs => ['Tests']
  pod 'BranchLocator', :path => 'santander-one/Modules/Features/BranchLocator'
  pod 'FinantialTimeline', :path => 'santander-one/Modules/Features/FinantialTimeline'
  pod 'CommonAppExtensions', :path => 'santander-one/Modules/AppExtensions/CommonAppExtensions'
  pod 'Ecommerce', :path => 'Modules/Features/Ecommerce'
  pod 'QuickBalance', :path => 'Modules/Features/QuickBalance'
  pod 'PdfCommons', :path => 'santander-one/PdfCommons'
  pod 'ESUI', :path => 'Modules/Libraries/ESUI'
  pod 'InboxNotification', :path => 'Modules/Features/InboxNotification'
  pod 'BiometryValidator', :path => 'Modules/Features/BiometryValidator'
  pod 'UIOneComponents', :path => 'santander-one/UIOneComponents'
  pod 'TransferOperatives', :path => 'santander-one/Modules/Features/TransferOperatives'
  pod 'OneAuthorizationProcessor', :path => 'santander-one/Modules/Features/OneAuthorizationProcessor'
  pod 'Onboarding', :path => 'santander-one/Modules/Features/Onboarding'
  pod 'FeatureFlags', :path => 'santander-one/Modules/Features/FeatureFlags'
  pod 'PrivateMenu', :path => 'santander-one/PrivateMenu'
  pod 'SavingProducts', :path => 'santander-one/Modules/Features/SavingProducts'
  pod 'Funds', :path => 'santander-one/Funds'
  pod 'SantanderKey', :path => 'Modules/Features/SantanderKey', :testspecs => ['Tests']
  pod 'SantanderKeyAuthorization', :path => 'Modules/Features/SantanderKeyAuthorization', :testspecs => ['Tests']
end

def legacy_libraries
  pod 'Locker', :path => 'santander-one/Modules/Libraries/Locker'
  pod 'Logger', :path => 'santander-one/Modules/Libraries/Logger'
  pod 'SANLegacyLibrary', :path => 'santander-one/Modules/Libraries/SANLegacyLibrary'
  pod 'RetailLegacy', :path => 'santander-one/RetailLegacy'
end

def libraries
  pod 'CoreFoundationLib', :path => 'santander-one/Modules/Libraries/CoreFoundationLib', :testspecs => ['Tests']
  pod 'PFM', :path => 'Modules/Libraries/PFM'
  pod 'SQLite.swift/SQLCipher', :path => 'santander-one/Modules/Libraries/SQLite.swift'
  pod 'SQLCipher', '4.4.2', :inhibit_warnings => true
  pod 'CryptoSwift', '1.4.0', :inhibit_warnings => true
  pod 'SwiftyRSA', '1.7.0', :inhibit_warnings => true
  pod 'WebViews', :path => 'santander-one/Modules/Libraries/WebViews'
  pod 'CoreDomain', :path => 'santander-one/Modules/Libraries/CoreDomain'
  pod 'SANSpainLibrary', :path => 'Modules/Libraries/SANSpainLibrary'
  pod 'SANServicesLibrary', :path => 'santander-one/Modules/Libraries/SANServicesLibrary'
  pod 'RxCombine', :path => 'santander-one/Modules/Libraries/RxCombine'
  pod 'Dynatrace', '~> 8.217', :inhibit_warnings => true
end

def project_pods
  pod 'IQKeyboardManagerSwift', '6.5.6', :inhibit_warnings => true
  pod 'Kingfisher', '5.15.8', :inhibit_warnings => true
  pod 'SwiftLint', '0.44.0'
  pod 'MarketingCloudSDK', '6.3.4', :inhibit_warnings => true
  pod 'TwinPushSDK', '3.10.0', :inhibit_warnings => true
  pod 'lottie-ios', :inhibit_warnings => true
  features
  legacy_libraries
  libraries
end

def widget_shared_pods
  pod 'ESCommons', :path => 'Modules/Libraries/ESCommons'
  pod 'SANLibraryV3', :path => 'Modules/Libraries/SANLibraryV3'
  pod 'CoreFoundationLib', :path => 'santander-one/Modules/Libraries/CoreFoundationLib'
  pod 'Alamofire-Synchronous', '4.0', :inhibit_warnings => true
  pod 'TealiumIOS', '5.6.6', :inhibit_warnings => true
  pod 'CommonAppExtensions', :path => 'santander-one/Modules/AppExtensions/CommonAppExtensions'
  pod 'RetailLegacy', :path => 'santander-one/RetailLegacy'
end

def notifications_shared_pods
  pod 'ESCommons', :path => 'Modules/Libraries/ESCommons'
  pod 'RetailLegacy', :path => 'santander-one/RetailLegacy'
  pod 'SanNotificationService', :path => 'santander-one/Modules/AppExtensions/SanNotificationService'
  pod 'CorePushNotificationsService', :path => 'santander-one/CorePushNotificationsService'
end

def siri_shared_pods
  widget_shared_pods
end

def core_test
  pod 'UnitTestCommons', :path => 'santander-one/UnitTestCommons'
  pod 'CoreTestData', :path => 'santander-one/Modules/Libraries/CoreTestData'
end

target 'Santander' do |target|
  use_frameworks!
  project_pods
  widget_shared_pods
  pod 'CocoaDebug', :configuration => ["Intern-Release"]
  pod 'AppCenter', '3.1.0', :configuration => ["Intern-Release", "Dev-Release", "Pre-Release"]
  
  target 'SantanderTests' do
    inherit! :search_paths
    core_test
  end
end

target 'PushNotificationService' do
  use_frameworks!
  notifications_shared_pods
end

target 'Widget' do
  use_frameworks!
  siri_shared_pods
end

target 'Siri' do
  use_frameworks!
  siri_shared_pods
end

target 'SiriUI' do
  use_frameworks!
  siri_shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.3'
      if ["Intern-Debug", "Pre-Debug", "Dev-Debug", "Pro-Debug", "Test"].include? config.name
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
        config.build_settings['SWIFT_WHOLE_MODULE_OPTIMIZATION'] = 'YES'
        config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
        config.build_settings['SWIFT_VERSION'] = '5.0'
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        config.build_settings['ENABLE_TESTABILITY'] = 'YES'
      end
      if config.name == "Pro-Release"
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Osize'
      end
      if ["Dev-Release", "Pre-Release"].include? config.name
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)', '-DAPPCENTER', '-D INSECURE_WEBVIEWS']
      end
      if config.name == "Intern-Release"
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)', '-DAPPCENTER', '-DCOCOADEBUG', '-D INSECURE_WEBVIEWS']
      end
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end
  system "mkdir -p Pods/Headers/Private && ln -s ../../SQLCipher/sqlite3.h Pods/Headers/Private"
end
