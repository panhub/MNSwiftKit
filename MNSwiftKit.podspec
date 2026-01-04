#
# Be sure to run `pod lib lint MNSwiftKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MNSwiftKit'
  s.version          = '0.1.3'
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
    b.frameworks = 'UIKit', 'WebKit', 'Foundation', 'CoreFoundation'
    b.source_files = 'MNSwiftKit/Base/Sources/**/*.swift'
    b.resource_bundles = {
        'MNSwiftKit_Base' => ['MNSwiftKit/Base/Resources/*']
    }
    b.dependency 'MNSwiftKit/Toast'
    b.dependency 'MNSwiftKit/Layout'
    b.dependency 'MNSwiftKit/Refresh'
    b.dependency 'MNSwiftKit/Request'
    b.dependency 'MNSwiftKit/Definition'
    b.dependency 'MNSwiftKit/Extension'
    b.dependency 'MNSwiftKit/EmptyView'
    b.dependency 'MNSwiftKit/Transitioning'
    b.dependency 'MNSwiftKit/CollectionLayout'
  end
  
  # Toast <加载指示图>
  s.subspec 'Toast' do |t|
    t.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    t.source_files = 'MNSwiftKit/Toast/Sources/**/*.swift'
    t.dependency 'MNSwiftKit/NameSpace'
    t.resource_bundles = {
        'MNSwiftKit_Toast' => ['MNSwiftKit/Toast/Resources/*.{png,jpg,jpeg}']
    }
  end
  
  # Utility <基础工具>
  s.subspec 'Utility' do |u|
    u.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'CoreFoundation', 'CoreImage', 'CoreGraphics', 'CoreMedia', 'Photos', 'AdSupport', 'AppTrackingTransparency', 'AuthenticationServices'
    u.source_files = 'MNSwiftKit/Utility/Sources/**/*.swift'
  end
  
  # Slider <自定义滑块>
  s.subspec 'Slider' do |s|
    s.frameworks = 'UIKit', 'Foundation', 'QuartzCore', 'CoreFoundation'
    s.source_files = 'MNSwiftKit/Slider/Sources/**/*.swift'
  end
  
  # Player <播放器>
  s.subspec 'Player' do |p|
    p.frameworks = 'UIKit', 'AVFAudio', 'Foundation', 'AudioToolbox', 'AVFoundation'
    p.source_files = 'MNSwiftKit/Player/Sources/**/*.swift'
  end
  
  # Layout <UI布局快速获取>
  s.subspec 'Layout' do |a|
    a.frameworks = 'UIKit', 'Foundation', 'QuartzCore', 'CoreFoundation'
    a.source_files = 'MNSwiftKit/Layout/Sources/**/*.swift'
    a.dependency 'MNSwiftKit/NameSpace'
  end
  
  # Refresh <刷新控件>
  s.subspec 'Refresh' do |r|
    r.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    r.source_files = 'MNSwiftKit/Refresh/Sources/**/*.swift'
    r.dependency 'MNSwiftKit/NameSpace'
  end
  
  # Request <网络请求封装>
  s.subspec 'Request' do |r|
    r.libraries = 'sqlite3'
    r.frameworks = 'UIKit', 'ImageIO', 'Foundation', 'CoreServices', 'CoreFoundation', 'UniformTypeIdentifiers'
    r.source_files = 'MNSwiftKit/Request/Sources/**/*.swift'
    r.dependency 'MNSwiftKit/Networking'
  end
  
  # MediaExport <媒体资源输出>
  s.subspec 'MediaExport' do |m|
    m.frameworks = 'CoreMedia', 'Foundation', 'AVFoundation', 'CoreFoundation'
    m.source_files = 'MNSwiftKit/MediaExport/Sources/**/*.swift'
    m.dependency 'MNSwiftKit/NameSpace'
  end
  
  # Purchase <内购支持>
  s.subspec 'Purchase' do |p|
    p.libraries = 'sqlite3'
    p.frameworks = 'UIKit', 'StoreKit', 'Foundation'
    p.source_files = 'MNSwiftKit/Purchase/Sources/**/*.swift'
  end
  
  # Database <数据库>
  s.subspec 'Database' do |d|
    d.libraries = 'sqlite3'
    d.frameworks = 'Foundation', 'AVFoundation', 'CoreFoundation'
    d.source_files = 'MNSwiftKit/Database/Sources/**/*.swift'
  end
  
  # Definition <基础定义>
  s.subspec 'Definition' do |d|
    d.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    d.source_files = 'MNSwiftKit/Definition/Sources/**/*.swift'
    d.dependency 'MNSwiftKit/NameSpace'
  end
  
  # Extension <基础扩展>
  s.subspec 'Extension' do |e|
    e.frameworks = 'UIKit', 'StoreKit', 'Foundation', 'QuartzCore', 'CoreGraphics', 'CoreFoundation'
    e.source_files = 'MNSwiftKit/Extension/Sources/**/*.swift'
    e.dependency 'MNSwiftKit/NameSpace'
    e.dependency 'MNSwiftKit/AnimatedImage'
  end
  
  # EmptyView <空数据视图>
  s.subspec 'EmptyView' do |e|
    e.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    e.source_files = 'MNSwiftKit/EmptyView/Sources/**/*.swift'
    e.dependency 'MNSwiftKit/NameSpace'
  end
  
  # Networking <网络请求>
  s.subspec 'Networking' do |n|
    n.frameworks = 'Security', 'CoreAudio', 'Foundation', 'CoreGraphics', 'CoreTelephony', 'CoreFoundation', 'SystemConfiguration'
    n.source_files = 'MNSwiftKit/Networking/Sources/**/*.swift'
    n.resource_bundles = {
        'MNSwiftKit_Networking' => ['MNSwiftKit/Networking/Resources/**/*.json']
    }
  end
  
  # AssetPicker <资源选择器>
  s.subspec 'AssetPicker' do |p|
    p.frameworks = 'UIKit', 'Photos', 'PhotosUI', 'Foundation', 'CoreGraphics', 'AVFoundation', 'CoreFoundation', 'UniformTypeIdentifiers'
    p.source_files = 'MNSwiftKit/AssetPicker/Sources/*'
    p.resource_bundles = {
        'MNSwiftKit_AssetPicker' => ['MNSwiftKit/AssetPicker/Resources/*']
    }
    p.dependency 'MNSwiftKit/Toast'
    p.dependency 'MNSwiftKit/Slider'
    p.dependency 'MNSwiftKit/Player'
    p.dependency 'MNSwiftKit/Layout'
    p.dependency 'MNSwiftKit/Refresh'
    p.dependency 'MNSwiftKit/Definition'
    p.dependency 'MNSwiftKit/Extension'
    p.dependency 'MNSwiftKit/EmptyView'
    p.dependency 'MNSwiftKit/NameSpace'
    p.dependency 'MNSwiftKit/MediaExport'
    p.dependency 'MNSwiftKit/AssetBrowser'
    p.dependency 'MNSwiftKit/AnimatedImage'
  end
  
  # AssetBrowser <资源浏览器>
  s.subspec 'AssetBrowser' do |a|
    a.frameworks = 'UIKit', 'Photos', 'Foundation', 'CoreGraphics', 'AVFoundation', 'CoreFoundation'
    a.source_files = 'MNSwiftKit/AssetBrowser/Sources/*'
    a.resource_bundles = {
        'MNSwiftKit_AssetBrowser' => ['MNSwiftKit/AssetBrowser/Resources/*']
    }
    a.dependency 'MNSwiftKit/Slider'
    a.dependency 'MNSwiftKit/Player'
    a.dependency 'MNSwiftKit/Layout'
    a.dependency 'MNSwiftKit/Definition'
    a.dependency 'MNSwiftKit/Extension'
    a.dependency 'MNSwiftKit/AnimatedImage'
  end
  
  # EditingView <表格编辑视图>
  s.subspec 'EditingView' do |e|
    e.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    e.source_files = 'MNSwiftKit/EditingView/Sources/**/*.swift'
    e.dependency 'MNSwiftKit/NameSpace'
  end
  
  # NameSpace <命名空间>
  s.subspec 'NameSpace' do |n|
    n.frameworks = 'UIKit', 'Foundation', 'QuartzCore', 'CoreFoundation'
    n.source_files = 'MNSwiftKit/NameSpace/Sources/**/*.swift'
  end
  
  # PageControl <简单的页码指示器>
  s.subspec 'PageControl' do |p|
    p.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    p.source_files = 'MNSwiftKit/PageControl/Sources/**/*.swift'
  end
  
  # Components <基础控件>
  s.subspec 'Components' do |c|
    c.frameworks = 'UIKit', 'ImageIO', 'Foundation', 'QuartzCore', 'CoreServices', 'CoreGraphics', 'AVFoundation', 'CoreFoundation', 'UniformTypeIdentifiers'
    c.source_files = 'MNSwiftKit/Components/Sources/**/*.swift'
    c.resource_bundles = {
        'MNSwiftKit_Components' => ['MNSwiftKit/Components/Resources/**/*.{png,jpg,jpeg}']
    }
    c.dependency 'MNSwiftKit/Layout'
    c.dependency 'MNSwiftKit/Extension'
    c.dependency 'MNSwiftKit/NameSpace'
  end
  
  # Transitioning <控制器转场支持>
  s.subspec 'Transitioning' do |t|
    t.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    t.source_files = 'MNSwiftKit/Transitioning/Sources/**/*.swift'
    t.dependency 'MNSwiftKit/NameSpace'
  end
  
  # EmoticonKeyboard <表情键盘>
  s.subspec 'EmoticonKeyboard' do |e|
    e.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    e.source_files = 'MNSwiftKit/EmoticonKeyboard/Sources/**/*.swift'
    e.resource_bundles = {
        'MNSwiftKit_EmoticonKeyboard' => ['MNSwiftKit/EmoticonKeyboard/Resources/*']
    }
    e.dependency 'MNSwiftKit/Definition'
    e.dependency 'MNSwiftKit/Extension'
    e.dependency 'MNSwiftKit/NameSpace'
    e.dependency 'MNSwiftKit/PageControl'
    e.dependency 'MNSwiftKit/AnimatedImage'
  end
  
  # AnimatedImage <动图支持>
  s.subspec 'AnimatedImage' do |a|
    a.frameworks = 'UIKit', 'ImageIO', 'Foundation', 'CoreServices', 'CoreFoundation', 'UniformTypeIdentifiers'
    a.source_files = 'MNSwiftKit/AnimatedImage/Sources/**/*.swift'
    a.dependency 'MNSwiftKit/NameSpace'
  end
  
  # CollectionLayout <UICollectionView布局对象>
  s.subspec 'CollectionLayout' do |c|
    c.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    c.source_files = 'MNSwiftKit/CollectionLayout/Sources/**/*.swift'
  end
  
  # SegmentedViewController <分页控制器>
  s.subspec 'SegmentedViewController' do |s|
    s.frameworks = 'UIKit', 'Foundation', 'CoreFoundation'
    s.source_files = 'MNSwiftKit/SegmentedViewController/Sources/**/*.swift'
    s.dependency 'MNSwiftKit/NameSpace'
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
    full.dependency 'MNSwiftKit/Layout'
    full.dependency 'MNSwiftKit/Refresh'
    full.dependency 'MNSwiftKit/Request'
    full.dependency 'MNSwiftKit/Purchase'
    full.dependency 'MNSwiftKit/Database'
    full.dependency 'MNSwiftKit/Definition'
    full.dependency 'MNSwiftKit/Extension'
    full.dependency 'MNSwiftKit/EmptyView'
    full.dependency 'MNSwiftKit/Networking'
    full.dependency 'MNSwiftKit/AssetPicker'
    full.dependency 'MNSwiftKit/EditingView'
    full.dependency 'MNSwiftKit/NameSpace'
    full.dependency 'MNSwiftKit/PageControl'
    full.dependency 'MNSwiftKit/Components'
    full.dependency 'MNSwiftKit/MediaExport'
    full.dependency 'MNSwiftKit/Transitioning'
    full.dependency 'MNSwiftKit/AssetBrowser'
    full.dependency 'MNSwiftKit/AnimatedImage'
    full.dependency 'MNSwiftKit/CollectionLayout'
    full.dependency 'MNSwiftKit/EmoticonKeyboard'
    full.dependency 'MNSwiftKit/SegmentedViewController'
  end
  
end
