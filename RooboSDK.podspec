Pod::Spec.new do |s|
  s.name             = 'RooboSDK'
  s.version          = '1.0.0'
  s.summary          = 'A short summary of RooboSDK.'
  s.description      = 'A short description of RooboSDK.'
  s.homepage         = 'https://github.com/mcmengchen/RBSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mengchen' => '416922992@qq.com' }
  s.source           = { :git => 'https://github.com/mcmengchen/RBSDK.git', :tag => s.version.to_s }
  s.platform = :ios, '7.0'
  s.requires_arc = true
  s.vendored_framework   = 'RooboSDK/ios/RooboSDK.embeddedframework/RooboSDK.framework'
  s.frameworks = 'UIKit','WebKit','CoreTelephony','SystemConfiguration','MobileCoreServices','AVFoundation'
  s.libraries = 'c++'
  s.resource = 'RooboSDK/ios/RooboSDK.embeddedframework/Resources/**/*.bundle'
end
