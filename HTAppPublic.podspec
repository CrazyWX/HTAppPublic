#
# Be sure to run `pod lib lint HTAppPublic.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HTAppPublic'
  s.version          = '0.1.0'
  s.summary          = 'A short description of HTAppPublic.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/CrazyWX/HTAppPublic'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CrazyWX' => 'wangxia03@huatu.com' }
  s.source           = { :git => 'https://github.com/CrazyWX/HTAppPublic.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'HTAppPublic/Classes/**/*.{h,m,swift}'
  
  s.resource_bundles = {
     'HTAppPublic' => ['HTAppPublic/Assets/*.png']
  }
  # s.public_header_files = 'Pod/Classes/**/*.h'
 s.dependency 'Alamofire'
 s.dependency 'SnapKit'
 s.dependency 'SwiftyJSON', '4.1.0'
 s.dependency 'MBProgressHUD', '~> 1.0.0'
# s.dependency 'SVProgressHUD'
 s.dependency 'RongCloudIM/IMLib', '~> 2.10.4'
 s.dependency 'RongCloudIM/IMKit', '~> 2.10.4'
 s.dependency 'Masonry', '1.1.0'
 s.dependency 'YYText'
 s.dependency 'YYWebImage'
# s.dependency 'Kingfisher', '~> 4.0'
s.dependency 'CryptoSwift'

 
 s.static_framework = true
 
# s.frameworks = 'QuartzCore', 'OpenGLES', 'CoreGraphics', 'CoreTelephony','AVFoundation','AVKit','AudioToolbox','CFNetwork','CoreFoundation','CoreMedia','CoreVideo','Foundation','MediaPlayer','Photos','Security','VideoToolbox','UIKit','AssetsLibrary','CoreAudio','ImageIO','SystemConfiguration','SafariServices'

 s.static_framework  =  true
 # 第三方用到的系统静态文件（前面的lib要去掉，否则会报错）
# s.libraries = 'c++','sqlite3','bz2','icucore','c++abi','stdc++','xml2','z','opencore-amrwb','opencore-amrnb'
# s.vendored_frameworks = 'HTAppPublic/Classes/*.framework'
# s.vendored_libraries = 'RongCloudIM/Classes/*.a'
 s.public_header_files = 'Pod/Classes/*.{h,swift}'

s.subspec 'HTAppPublicVendor' do |sss|
#  sss.source_files            = ''
#  sss.resource                = 'RongCloudIM/UMSocialSDKPromptResources.bundle'
  sss.ios.vendored_frameworks = 'RongCloudIM/RongCloudIM/RongIMKit.framework','RongCloudIM/RongCloudIM/RongIMLib.framework'
  sss.ios.vendored_library    = 'RongCloudIM/RongCloudIM/libopencore-amrnb.a','RongCloudIM/RongCloudIM/libopencore-amrwb.a','RongCloudIM/RongCloudIM/libvo-amrwbenc.a'
#  sss.ios.public_header_files   = 'SocialLibraries/**/*.{h}'
  sss.ios.library  = 'sqlite3'
end

end
