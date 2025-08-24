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
  
  # UI <UIKit 基础控件>
  s.subspec 'UI' do |ui|
    ui.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'CoreGraphics', 'QuartzCore', 'ImageIO', 'CoreServices', 'UniformTypeIdentifiers'
    ui.source_files = 'MNSwiftKit/UI/Sources/**/*.swift'
    ui.dependency 'MNSwiftKit/Layout'
    ui.dependency 'MNSwiftKit/Extension'
    # 可以依赖一些基础库，比如 SnapKit
    # ui.dependency 'SnapKit', '~> 5.6.0'
  end
  
  # Utility <基础工具>
  s.subspec 'Utility' do |utility|
    utility.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'CoreFoundation', 'CoreGraphics', 'CoreMedia', 'Photos', 'AdSupport', 'AppTrackingTransparency'
    utility.source_files = 'MNSwiftKit/Utility/Sources/**/*.swift'
  end
  
  # Toast <加载指示图>
  s.subspec 'Toast' do |toast|
    toast.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    toast.source_files = 'MNSwiftKit/Toast/Sources/**/*.swift'
    toast.resource_bundles = {
        # 'MNSwiftKit_Toast' 是生成的 bundle 名称
        'MNSwiftKit_Toast' => ['MNSwiftKit/Toast/Resources/*.{png,jpg,jpeg}']
    }
  end
  
  # Player <播放器>
  s.subspec 'Player' do |player|
    player.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'AudioToolbox'
    player.source_files = 'MNSwiftKit/Player/Sources/**/*.swift'
  end
  
  # Spliter <分页控制器>
  s.subspec 'Spliter' do |spliter|
    spliter.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    spliter.source_files = 'MNSwiftKit/Spliter/Sources/**/*.swift'
    spliter.dependency 'MNSwiftKit/Layout'
  end
  
  # Layout <UI布局快速获取>
  s.subspec 'Layout' do |layout|
    layout.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    layout.source_files = 'MNSwiftKit/Layout/Sources/**/*.swift'
  end
  
  # Activity <自定义指示器>
  s.subspec 'Activity' do |activity|
    activity.frameworks = 'UIKit', 'Foundation', 'QuartzCore', 'CoreGraphics'
    activity.source_files = 'MNSwiftKit/Activity/Sources/**/*.swift'
    activity.resource_bundles = {
        # 'MNSwiftKit_Activity' 是生成的 bundle 名称
        'MNSwiftKit_Activity' => ['MNSwiftKit/Activity/Resources/**/*.{png,jpg,jpeg}']
    }
  end
  
  # Refresh <刷新控件>
  s.subspec 'Refresh' do |refresh|
    refresh.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    refresh.source_files = 'MNSwiftKit/Refresh/Sources/**/*.swift'
  end
  
  # Exporter <媒体资源输出>
  s.subspec 'Exporter' do |exporter|
    exporter.frameworks = 'Foundation', 'AVFoundation', 'QuartzCore'
    exporter.source_files = 'MNSwiftKit/Exporter/Sources/**/*.swift'
  end
  
  # Purchase <内购支持>
  s.subspec 'Purchase' do |purchase|
    purchase.frameworks = 'UIKit', 'Foundation', 'StoreKit'
    purchase.source_files = 'MNSwiftKit/Purchase/Sources/**/*.swift'
  end
  
  # Database <数据库>
  s.subspec 'Database' do |database|
    database.frameworks = 'Foundation', 'AVFoundation', 'CoreGraphics'
    database.source_files = 'MNSwiftKit/Database/Sources/**/*.swift'
  end
  
  # Definition <基础定义>
  s.subspec 'Definition' do |definition|
    definition.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    definition.source_files = 'MNSwiftKit/Definition/Sources/**/*.swift'
  end
  
  # Extension <基础扩展>
  s.subspec 'Extension' do |ext|
    ext.frameworks = 'Foundation', 'CoreFoundation', 'CoreGraphics'
    ext.source_files = 'MNSwiftKit/Extension/Sources/**/*.swift'
  end
  
  # Controller <控制器基类>
  s.subspec 'Controller' do |controller|
    controller.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'WebKit'
    controller.source_files = 'MNSwiftKit/Controller/Sources/**/*.swift'
    controller.resource_bundles = {
        # 'MNSwiftKit_Controller' 是生成的 bundle 名称
        'MNSwiftKit_Controller' => ['MNSwiftKit/Controller/Resources/*.{png,jpg,jpeg}']
    }
    controller.dependency 'MNSwiftKit/Toast'
    controller.dependency 'MNSwiftKit/Layout'
    controller.dependency 'MNSwiftKit/Refresh'
    controller.dependency 'MNSwiftKit/Definition'
    controller.dependency 'MNSwiftKit/EmptyView'
    controller.dependency 'MNSwiftKit/Transitioning'
    controller.dependency 'MNSwiftKit/HTTPRequest'
  end
  
  # EmptyView <空数据视图>
  s.subspec 'EmptyView' do |empty|
    empty.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    empty.source_files = 'MNSwiftKit/EmptyView/Sources/**/*.swift'
  end
  
  # Networking <网络请求>
  s.subspec 'Networking' do |network|
    network.frameworks = 'Foundation', 'SystemConfiguration', 'CoreTelephony', 'CoreAudio', 'Security', 'CoreFoundation', 'CoreGraphics'
    network.source_files = 'MNSwiftKit/Networking/Sources/**/*.swift'
    network.resource_bundles = {
        # 'MNSwiftKit_Networking' 是生成的 bundle 名称
        'MNSwiftKit_Networking' => ['MNSwiftKit/Networking/Resources/*.json']
    }
  end
  
  # AssetPicker <资源选择器>
  s.subspec 'AssetPicker' do |picker|
    picker.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'Photos', 'CoreFoundation', 'CoreGraphics'
    picker.source_files = 'MNSwiftKit/AssetPicker/Sources/**/*.swift'
    picker.resource_bundles = {
        # 'MNSwiftKit_AssetPicker' 是生成的 bundle 名称
        'MNSwiftKit_AssetPicker' => ['MNSwiftKit/AssetPicker/Resources/**/*.{png,jpg,jpeg}']
    }
    picker.dependency 'MNSwiftKit/UI'
    picker.dependency 'MNSwiftKit/Toast'
    picker.dependency 'MNSwiftKit/Player'
    picker.dependency 'MNSwiftKit/Layout'
    picker.dependency 'MNSwiftKit/Refresh'
    picker.dependency 'MNSwiftKit/Exporter'
    picker.dependency 'MNSwiftKit/Definition'
    picker.dependency 'MNSwiftKit/EmptyView'
  end
  
  # Transitioning <控制器转场支持>
  s.subspec 'Transitioning' do |transition|
    transition.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    transition.source_files = 'MNSwiftKit/Transitioning/Sources/**/*.swift'
  end
  
  # HTTPRequest <网络请求封装>
  s.subspec 'HTTPRequest' do |request|
    request.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    request.source_files = 'MNSwiftKit/HTTPRequest/Sources/**/*.swift'
    request.dependency 'MNSwiftKit/Networking'
  end
  
  # Full
  s.subspec 'Full' do |full|
    # 'Full' 子模块本身不包含任何源代码
    # 它只是一个“元模块”，用来聚合所有其他子模块的依赖
    full.dependency 'MNSwiftKit/UI'
    full.dependency 'MNSwiftKit/Toast'
    full.dependency 'MNSwiftKit/Utility'
    full.dependency 'MNSwiftKit/Player'
    full.dependency 'MNSwiftKit/Spliter'
    full.dependency 'MNSwiftKit/Layout'
    full.dependency 'MNSwiftKit/Activity'
    full.dependency 'MNSwiftKit/Refresh'
    full.dependency 'MNSwiftKit/Exporter'
    full.dependency 'MNSwiftKit/Purchase'
    full.dependency 'MNSwiftKit/Database'
    full.dependency 'MNSwiftKit/Definition'
    full.dependency 'MNSwiftKit/Extension'
    full.dependency 'MNSwiftKit/Controller'
    full.dependency 'MNSwiftKit/EmptyView'
    full.dependency 'MNSwiftKit/Networking'
    full.dependency 'MNSwiftKit/AssetPicker'
    full.dependency 'MNSwiftKit/Transitioning'
    full.dependency 'MNSwiftKit/HTTPRequest'
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
