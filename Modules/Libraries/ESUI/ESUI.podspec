Pod::Spec.new do |s|
  s.name             = 'ESUI'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ESUI.'
  s.description      = <<-DESC
  The Spain UI framework
                       DESC

  s.homepage         = 'https://github.com/Carlos Monfort/ESUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Carlos Monfort' => 'carlos.monfort@ciberexperis.es' }
  s.source           = { :git => 'https://github.com/Carlos Monfort/ESUI.git', :tag => "#{s.version}" }

  s.ios.deployment_target = '9.0'
  
  s.source_files = 'ESUI/**/*.{swift}'
  s.resources = "ESUI/**/*.{xcassets}"
  s.resource_bundles = {
    'ESUI' => ['ESUI/**/*.{storyboard,ttf,json,strings,xib,m4a,caf}']
  }

  s.dependency "UI"
  s.dependency "CoreFoundationLib"
end
