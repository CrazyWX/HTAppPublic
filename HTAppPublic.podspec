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

  s.source_files = 'HTAppPublic/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HTAppPublic' => ['HTAppPublic/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
# s.dependency 'AFNetworking', '~> 2.3'
 s.dependency 'Alamofire'
 s.dependency 'SnapKit'
 s.dependency 'SwiftyJSON', '4.1.0'
 s.dependency 'MBProgressHUD', '~> 1.0.0'
 s.dependency 'SVProgressHUD'
 s.dependency 'RongCloudIM/IMLib', '~> 2.10.4'
 s.dependency 'RongCloudIM/IMKit', '~> 2.10.4'
 s.dependency 'Masonry', '1.1.0'

end
