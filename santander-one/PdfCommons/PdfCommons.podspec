#
# Be sure to run `pod lib lint PdfCommons.podspec" to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PdfCommons"
  s.version          = "0.0.1"
  s.summary          = "Module to manage PDFs."
  s.swift_version    = "5.0"
  s.description      = <<-DESC
  Module to manage PDFs
  DESC
  
  s.homepage         = "https://github.com/Jose Javier Montes/PdfCommons"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Jose Javier Montes" => "jjmontes@vectoritcgroup.com" }
  s.platform         = :ios, "10.3"
  s.source           = { :git => "http://gitlab/PdfCommons.git", :tag => "#{s.version}" }
  s.source_files     = "PdfCommons", "PdfCommons/**/*.{swift}"
  
  s.resource_bundles = {
    "PdfCommons" => ["PdfCommons/**/*{xib,xcassets}"]
  }
  
  s.dependency "UI"
  s.dependency "CoreFoundationLib"
end
