#
# Be sure to run `pod lib lint MNSwiftKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MNSwiftKit'
  s.version          = '0.1.0'
  s.summary          = 'Swift开发基础组件。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Swift开发基础组件，模块化。
                       DESC

  s.homepage         = 'https://github.com/panhub/MNSwiftKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'panhub' => 'fengpann@163.com' }
  s.source           = { :git => 'https://github.com/panhub/MNSwiftKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  # Swift版本号
  s.swift_version    = '5.0'
  # ios平台的最低部署目标
  s.ios.deployment_target = '9.0'
  # 默认模块
  s.default_subspec = 'Full'
  
  # Core <Foundation 基础工具>
  s.subspec 'Core' do |core|
    core.frameworks = 'Foundation', 'CoreFoundation', 'CoreGraphics'
    core.source_files = 'MNSwiftKit/Core/Classes/*.swift'
    # 可以依赖一些基础库，比如 SnapKit
    # core.dependency 'SnapKit', '~> 5.6.0'
  end
  
  # Base <UIKit 基础工具>
  s.subspec 'Base' do |base|
    base.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'QuartzCore', 'ImageIO', 'CoreServices', 'UniformTypeIdentifiers'
    base.source_files = 'MNSwiftKit/Base/Classes/*.swift'
  end
  
  # Layout <UI布局快速获取>
  s.subspec 'Layout' do |layout|
    layout.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    layout.source_files = 'MNSwiftKit/Layout/Classes/*.swift'
  end
  
  # Database <数据库>
  s.subspec 'Database' do |database|
    database.frameworks = 'Foundation', 'AVFoundation', 'CoreGraphics'
    database.source_files = 'MNSwiftKit/Database/Classes/*.swift'
  end
  
  # EmptyView <空数据默认视图支持>
  s.subspec 'EmptyView' do |empty|
    empty.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    empty.source_files = 'MNSwiftKit/EmptyView/Classes/*.swift'
  end
  
  # Refresh <刷新控件>
  s.subspec 'Refresh' do |refresh|
    refresh.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    refresh.source_files = [
       'MNSwiftKit/Refresh/Classes/*.swift',
       'MNSwiftKit/Refresh/Classes/**/*.swift'
    ]
  end
  
  # Purchase <内购支持>
  s.subspec 'Purchase' do |purchase|
    purchase.frameworks = 'UIKit', 'Foundation', 'StoreKit'
    purchase.source_files = 'MNSwiftKit/Purchase/Classes/*.swift'
  end
  
  # Full
  s.subspec 'Full' do |full|
    # 'Full' 子模块本身不包含任何源代码
    # 它只是一个“元模块”，用来聚合所有其他子模块的依赖
    full.dependency 'MNSwiftKit/Core'
    full.dependency 'MNSwiftKit/Base'
    full.dependency 'MNSwiftKit/Layout'
    full.dependency 'MNSwiftKit/Refresh'
    full.dependency 'MNSwiftKit/Purchase'
    full.dependency 'MNSwiftKit/Database'
    full.dependency 'MNSwiftKit/EmptyView'
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
