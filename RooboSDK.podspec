Pod::Spec.new do |s|
  s.name             = 'RooboSDK'
  s.version          = '1.0.2'
  s.summary          = 'A short description of RooboSDK.'
  s.description      = 'A short description of RooboSDK.'
  s.homepage         = 'https://git.365jiating.com/baxiang1/RooboSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'baxiang' => 'baxiang1989@163.com' }
  s.source           = { :git => 'git@git.365jiating.com:baxiang1/RooboSDK.git', :tag => s.version.to_s }
  s.platform = :ios, '7.0'
  s.requires_arc = true
  s.vendored_framework   = 'RooboSDK/ios/RooboSDK.embeddedframework/RooboSDK.framework'
  s.frameworks = 'UIKit','WebKit','CoreTelephony','SystemConfiguration','MobileCoreServices','AVFoundation'
  s.libraries = 'c++'
  s.resource = 'RooboSDK/ios/RooboSDK.embeddedframework/Resources/**/*.bundle'
end
