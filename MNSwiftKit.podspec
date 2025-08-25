#
# Be sure to run `pod lib lint MNSwiftKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MNSwiftKit'
  s.version          = '0.1.1'
  s.summary          = 'A collection of Swift components.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A collection of Swift components, Any module can installed.
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
  
  # Base <控制器基类>
  s.subspec 'Base' do |b|
    b.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'WebKit'
    b.source_files = 'MNSwiftKit/Base/Sources/**/*.swift'
    b.resource_bundles = {
        'MNSwiftKit_Base' => ['MNSwiftKit/Base/Resources/*.{png,jpg,jpeg}']
    }
    b.dependency 'MNSwiftKit/Toast'
    b.dependency 'MNSwiftKit/Layout'
    b.dependency 'MNSwiftKit/Refresh'
    b.dependency 'MNSwiftKit/Request'
    b.dependency 'MNSwiftKit/Definition'
    b.dependency 'MNSwiftKit/EmptyView'
    b.dependency 'MNSwiftKit/Transitioning'
  end
  
  # Toast <加载指示图>
  s.subspec 'Toast' do |t|
    t.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    t.source_files = 'MNSwiftKit/Toast/Sources/**/*.swift'
    t.resource_bundles = {
        'MNSwiftKit_Toast' => ['MNSwiftKit/Toast/Resources/*.{png,jpg,jpeg}']
    }
  end
  
  # Utility <基础工具>
  s.subspec 'Utility' do |u|
    u.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'CoreFoundation', 'CoreGraphics', 'CoreMedia', 'Photos', 'AdSupport', 'AppTrackingTransparency', 'AuthenticationServices'
    u.source_files = 'MNSwiftKit/Utility/Sources/**/*.swift'
  end
  
  # Slider <自定义滑块>
  s.subspec 'Slider' do |sl|
    sl.frameworks = 'UIKit', 'Foundation', 'QuartzCore', 'CoreGraphics'
    sl.source_files = 'MNSwiftKit/Slider/Sources/**/*.swift'
  end
  
  # Player <播放器>
  s.subspec 'Player' do |p|
    p.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'AudioToolbox'
    p.source_files = 'MNSwiftKit/Player/Sources/**/*.swift'
  end
  
  # Spliter <分页控制器>
  s.subspec 'Spliter' do |sp|
    sp.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    sp.source_files = 'MNSwiftKit/Spliter/Sources/**/*.swift'
    sp.dependency 'MNSwiftKit/Layout'
  end
  
  # Layout <UI布局快速获取>
  s.subspec 'Layout' do |l|
    l.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    l.source_files = 'MNSwiftKit/Layout/Sources/**/*.swift'
  end
  
  # Refresh <刷新控件>
  s.subspec 'Refresh' do |r|
    r.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    r.source_files = 'MNSwiftKit/Refresh/Sources/**/*.swift'
  end
  
  # Request <网络请求封装>
  s.subspec 'Request' do |req|
    req.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    req.source_files = 'MNSwiftKit/Request/Sources/**/*.swift'
    req.dependency 'MNSwiftKit/Networking'
  end
  
  # Exporter <媒体资源输出>
  s.subspec 'Exporter' do |e|
    e.frameworks = 'Foundation', 'AVFoundation', 'QuartzCore'
    e.source_files = 'MNSwiftKit/Exporter/Sources/**/*.swift'
  end
  
  # Purchase <内购支持>
  s.subspec 'Purchase' do |pur|
    pur.frameworks = 'UIKit', 'Foundation', 'StoreKit'
    pur.source_files = 'MNSwiftKit/Purchase/Sources/**/*.swift'
  end
  
  # Database <数据库>
  s.subspec 'Database' do |d|
    d.libraries = 'sqlite3'
    d.frameworks = 'Foundation', 'AVFoundation', 'CoreGraphics'
    d.source_files = 'MNSwiftKit/Database/Sources/**/*.swift'
  end
  
  # Definition <基础定义>
  s.subspec 'Definition' do |de|
    de.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    de.source_files = 'MNSwiftKit/Definition/Sources/**/*.swift'
  end
  
  # Extension <基础扩展>
  s.subspec 'Extension' do |ext|
    ext.frameworks = 'Foundation', 'CoreFoundation', 'CoreGraphics'
    ext.source_files = 'MNSwiftKit/Extension/Sources/**/*.swift'
    ext.dependency 'MNSwiftKit/AnimatedImage'
  end
  
  # EmptyView <空数据视图>
  s.subspec 'EmptyView' do |em|
    em.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    em.source_files = 'MNSwiftKit/EmptyView/Sources/**/*.swift'
  end
  
  # Networking <网络请求>
  s.subspec 'Networking' do |n|
    n.frameworks = 'Foundation', 'SystemConfiguration', 'CoreTelephony', 'CoreAudio', 'Security', 'CoreFoundation', 'CoreGraphics'
    n.source_files = 'MNSwiftKit/Networking/Sources/**/*.swift'
    n.resource_bundles = {
        'MNSwiftKit_Networking' => ['MNSwiftKit/Networking/Resources/*.json']
    }
  end
  
  # AssetPicker <资源选择器>
  s.subspec 'AssetPicker' do |pk|
    pk.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'Photos', 'CoreFoundation', 'CoreGraphics'
    pk.source_files = 'MNSwiftKit/AssetPicker/Sources/**/*.swift'
    pk.resource_bundles = {
        'MNSwiftKit_AssetPicker' => ['MNSwiftKit/AssetPicker/Resources/**/*.{png,jpg,jpeg}']
    }
    pk.dependency 'MNSwiftKit/Toast'
    pk.dependency 'MNSwiftKit/Slider'
    pk.dependency 'MNSwiftKit/Player'
    pk.dependency 'MNSwiftKit/Layout'
    pk.dependency 'MNSwiftKit/Refresh'
    pk.dependency 'MNSwiftKit/Exporter'
    pk.dependency 'MNSwiftKit/Definition'
    pk.dependency 'MNSwiftKit/EmptyView'
    pk.dependency 'MNSwiftKit/AnimatedImage'
  end
  
  # Components <基础控件>
  s.subspec 'Components' do |c|
    c.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'CoreGraphics', 'QuartzCore', 'ImageIO', 'CoreServices', 'UniformTypeIdentifiers'
    c.source_files = 'MNSwiftKit/Components/Sources/**/*.swift'
    c.resource_bundles = {
        'MNSwiftKit_Components' => ['MNSwiftKit/Components/Resources/**/*.{png,jpg,jpeg}']
    }
    c.dependency 'MNSwiftKit/Layout'
    c.dependency 'MNSwiftKit/Extension'
  end
  
  # Transitioning <控制器转场支持>
  s.subspec 'Transitioning' do |tr|
    tr.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
    tr.source_files = 'MNSwiftKit/Transitioning/Sources/**/*.swift'
  end
  
  # AnimatedImage <动图支持>
  s.subspec 'AnimatedImage' do |ani|
    ani.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'ImageIO', 'CoreServices', 'UniformTypeIdentifiers'
    ani.source_files = 'MNSwiftKit/AnimatedImage/Sources/**/*.swift'
  end
  
  # Full
  s.subspec 'Full' do |full|
    # 'Full' 子模块本身不包含任何源代码
    # 它只是一个“元模块”，用来聚合所有其他子模块的依赖
    full.dependency 'MNSwiftKit/Base'
    full.dependency 'MNSwiftKit/Toast'
    full.dependency 'MNSwiftKit/Slider'
    full.dependency 'MNSwiftKit/Utility'
    full.dependency 'MNSwiftKit/Player'
    full.dependency 'MNSwiftKit/Spliter'
    full.dependency 'MNSwiftKit/Layout'
    full.dependency 'MNSwiftKit/Refresh'
    full.dependency 'MNSwiftKit/Request'
    full.dependency 'MNSwiftKit/Exporter'
    full.dependency 'MNSwiftKit/Purchase'
    full.dependency 'MNSwiftKit/Database'
    full.dependency 'MNSwiftKit/Definition'
    full.dependency 'MNSwiftKit/Extension'
    full.dependency 'MNSwiftKit/EmptyView'
    full.dependency 'MNSwiftKit/Networking'
    full.dependency 'MNSwiftKit/AssetPicker'
    full.dependency 'MNSwiftKit/Components'
    full.dependency 'MNSwiftKit/Transitioning'
    full.dependency 'MNSwiftKit/AnimatedImage'
  end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
