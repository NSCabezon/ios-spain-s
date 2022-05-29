Pod::Spec.new do |spec|
  spec.name         = "CoreFoundationLib"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of CoreFoundationLib."
  spec.swift_version  = "5.0"

  spec.description  = <<-DESC
  The CoreDomain framework
                   DESC

  spec.homepage     = "http://EXAMPLE/CoreFoundationLib"
  spec.author       = { 'alvaro' => 'alvaro.olave@ciberexperis.com' }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "http://gitlab/CoreFoundationLib.git", :tag => "#{spec.version}" }
  spec.default_subspec  = 'legacy'
  
  spec.subspec 'standard' do |subspec|
    subspec.source_files  = "CoreFoundationLib",
    "CoreFoundationLib/Standard/**/*.{swift}"
    subspec.exclude_files = "CoreFoundationLib/Legacy/**/*.{swift}"
  end

  spec.subspec 'legacy' do |subspec|
    subspec.source_files = "CoreFoundationLib",
    "CoreFoundationLib/Legacy/**/*.{swift}",
    "CoreFoundationLib/Standard/**/*.{swift}"
  end

  spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  
  spec.dependency "CoreDomain"
  spec.dependency 'CryptoSwift', '~> 1.0'
  spec.dependency 'SQLite.swift/SQLCipher'
  spec.dependency 'SQLCipher', '~> 4.4.2'
  spec.dependency 'SANLegacyLibrary'
  spec.dependency 'RxCombine'
  spec.dependency 'OpenCombine'
  spec.dependency 'OpenCombineDispatch'
  spec.dependency "Locker"
  
  spec.test_spec 'Tests' do |test_spec|
    test_spec.resources = 'CoreFoundationLib/Tests/TestsAssets/**/*.{json,xml}'
    test_spec.source_files = 'CoreFoundationLib/Tests/**/*.{h,m,swift}'
    test_spec.dependency 'UnitTestCommons'
    test_spec.dependency 'CoreTestData'
  end
  
end
