#
# Be sure to run `pod lib lint OfferCarousel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OfferCarousel'
  s.version          = '1.0.0'
  s.swift_version    = '5.0'
  s.summary          = 'Module for OfferCarousel'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/Ruben Marquez/OfferCarousel'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.platform         = :ios, "10.3"
  s.author           = { 'Ruben Marquez' => 'ruben.marquez@experis.es' }
  s.source           = { :git => 'https://github.com/Ruben Marquez/OfferCarousel.git', :tag => s.version.to_s }
  s.source_files     = 'OfferCarousel/**/*.{swift}'
  s.resource_bundles = { 'OfferCarousel' => ['OfferCarousel/**/*{xib,xcassets}'] }
  s.exclude_files    = "Example/**"
  s.xcconfig         = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  
  s.dependency "UI"
  s.dependency 'CoreFoundationLib'
end
