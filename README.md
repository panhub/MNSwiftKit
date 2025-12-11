# MNSwiftKit

[![CI Status](https://img.shields.io/travis/panhub/MNSwiftKit.svg?style=flat)](https://travis-ci.org/mellow/MNSwiftKit)
[![Version](https://img.shields.io/cocoapods/v/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)
[![License](https://img.shields.io/cocoapods/l/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)
[![Platform](https://img.shields.io/cocoapods/p/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)

一个Swift组件集合，可以安装任一模块。

## 要求

- iOS 9.0+ | Swift 5.0
- Xcode 12

## 安装

### CocoaPods (iOS 9+, Swift 5+)

`MNSwiftKit`可以通过[CocoaPods](https://cocoapods.org)安装，只需添加以下行到您的Podfile:

```ruby
pod 'MNSwiftKit'
```
或按需添加一个或多个行到您的Podfile:

```ruby
pod 'MNSwiftKit/Base'
pod 'MNSwiftKit/Utility'
pod 'MNSwiftKit/Slider'
pod 'MNSwiftKit/Toast'
pod 'MNSwiftKit/Player'
pod 'MNSwiftKit/Layout'
pod 'MNSwiftKit/Refresh'
pod 'MNSwiftKit/Request'
pod 'MNSwiftKit/Purchase'
pod 'MNSwiftKit/Database'
pod 'MNSwiftKit/Definition'
pod 'MNSwiftKit/Extension'
pod 'MNSwiftKit/EmptyView'
pod 'MNSwiftKit/Networking'
pod 'MNSwiftKit/AssetPicker'
pod 'MNSwiftKit/NameSpace'
pod 'MNSwiftKit/PageControl'
pod 'MNSwiftKit/Components'
pod 'MNSwiftKit/MediaExport'
pod 'MNSwiftKit/Transitioning'
pod 'MNSwiftKit/AssetBrowser'
pod 'MNSwiftKit/SplitController'
pod 'MNSwiftKit/AnimatedImage'
pod 'MNSwiftKit/CollectionLayout'
pod 'MNSwiftKit/EmoticonKeyboard'
```
### Swift软件包管理器 (iOS 9+, Swift 5+)

`MNSwiftKit`也可以通过在您的`Package.swift`文件中添加适当的描述使用[Swift软件包管理器](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/)来安装：

```swift
// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "您的项目名称",
    dependencies: [
        .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
    ]
)
```
### 手动导入 (iOS 9+, Swift 5+)

要在项目中手动安装`MNSwiftKit`，您可以：

1. 将`MNSwiftKit`文件夹整个拖入项目。
2. 导航至项目target下，切换至`Build Phases`选项卡，在`Link Binary With Libraries`下添加依赖库。

依赖系统库/框架包括：
`UIKit`，`Photos`，`PhotosUI`，`ImageIO`，`Security`，`StoreKit`，`Foundation`，`CoreFoundation`，`AVFoundation`, `AudioToolbox`，`CoreFoundation`，`CoreServices`，`CoreGraphics`，`CoreMedia`，`CoreAudio`，`CoreImage`，`CoreTelephony`，`QuartzCore`，`AdSupport`，`AppTrackingTransparency`，`AuthenticationServices`，`UniformTypeIdentifiers`，`SystemConfiguration`，`sqlite3`。

## 模块

### MNToast

一个功能丰富、易于使用的 Swift 提示组件，适用于 iOS 应用。

#### ✨ 特性

- 🎨 **多种样式**：支持活动、成功、错误、提示、进度等多种指示器类型
- 📍 **灵活定位**：支持顶部、中间、底部三种位置显示，可自定义距离
- 🎭 **视觉效果**：支持暗色、亮色、无效果三种模糊背景
- 🔄 **智能更新**：相同类型的 Toast 会自动更新内容，避免重复创建
- ⌨️ **键盘避让**：监听键盘位置并调整 Toast 显示位置
- 🔧 **高度配置**：通过 `Configuration` 统一配置颜色、位置、字体等
- 🎯 **线程安全**：类调用时自动在主线程执行，无需手动处理线程问题
- 🔘 **手动取消**：可选择显示关闭按钮，允许用户手动关闭
- ⏱️ **自动关闭**：支持自定义显示时长，也可根据文字长度智能计算

#### 🚀 快速开始

```
// Cocoapods 安装：
import MNSwiftKit
// SPM 安装可独立导入：
import MNToast
```
显示带系统加载指示器的 Toast（支持大号和小号两种样式）：
```
MNToast.showActivity("加载中...")
view.mn.showActivityToast("加载中...")
```
显示成功的 Toast（带对勾动画的指示器）：
```
MNToast.showSuccess("操作成功")
view.mn.showSuccessToast("操作成功")
```
显示错误的 Toast（带 X 动画的指示器）：
```
MNToast.showError("操作失败")
view.mn.showErrorToast("操作失败")
```
显示纯文本提示的 Toast（自动关闭）
```
MNToast.showMsg("这是自动消失提示")
view.mn.showMsgToast("这是自动消失提示")
```
显示带图标提示的 Toast（不自动关闭）
```
MNToast.showInfo("温馨提示")
view.mn.showInfoToast("这是自动消失提示")
````
显示旋转动画的 Toast（支持三种样式：纯色线条、双线条、渐变线条）：
```
// 默认渐变线条
MNToast.showRotation("加载中...", style: .gradient)
view.mn.showRotationToast("加载中...", style: .gradient)
```
显示带进度的 Toast（支持两种样式：线条、填充）：
```
// 默认线条样式, 更新进度时，重新调用即可
MNToast.showProgress("正在下载", style: .line, value: 0.0)
view.mn.showProgressToast("正在下载", style: .line, value: 0.0)
```
关闭当前 Toast
```
MNToast.close(delay: 3.0, completion: nil)
view.mn.closeToast(delay: 3.0, completion: nil)
```
检查窗口是否有 Toast 显示
```
if MNToast.isAppearing {
    print("当前有 Toast 正在显示")
}
if view.mn.isToastAppearing {
    print("该视图上有 Toast 显示")
}
```

如果同类型的 Toast 正在显示，新的 Toast 会更新现有内容而不是创建新的：
````
// 第一次显示
MNToast.showActivity("加载中...")
// 再次调用相同类型，会更新文字而不是新建
MNToast.showActivity("加载完成")
````

你可以通过实现 `MNToastBuilder` 协议来创建自定义的 Toast 样式：
```
class CustomToast: MNToastBuilder {

    // 视图与文字的布局方向（横向或纵向排版）
    var axisForToast: MNToast.Axis { .vertical(spacing: 8.0) }
    
    // 视觉效果（支持暗色、亮色、无效果三种）
    var effectForToast: MNToast.Effect { .dark }
    
    // 内容四周约束
    var contentInsetForToast: UIEdgeInsets { UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13) }
    
    // 自定义活动视图
    var activityViewForToast: UIView? { /* 你的自定义视图 */ }
    
    // 提示信息的富文本属性
    var attributesForToastStatus: [NSAttributedString.Key : Any] { /* 文字属性 */ }
    
    // 显示时是否渐入效果
    var fadeInForToast: Bool { true }
    
    // 关闭时是否渐出效果
    var fadeOutForToast: Bool { true }
    
    // Toast 显示后是否允许交互事件
    var allowUserInteraction: Bool { false }
}
```
如果需要支持动画，可以实现 `MNToastAnimationSupported` 协议：
```
extension CustomToast: MNToastAnimationSupported {

    func startAnimating() {
        // 开始动画
    }
    
    func stopAnimating() {
        // 停止动画
    }
}
```
如果需要支持进度更新，可以实现 `MNToastProgressSupported` 协议：
```
extension CustomToast: MNToastProgressSupported {

    func toastShouldUpdateProgress(_ value: CGFloat) {
        // 更新进度，value 范围 0.0 - 1.0
    }
}
```

#### 📝 注意事项

1. 线程安全：类方法加载时，Toast 相关方法都会自动在主线程执行，无需手动处理
2. 键盘避让：Toast 会自动检测键盘位置并调整显示位置，避免被键盘遮挡
3. 内存管理：Toast 会在关闭后自动从视图层级中移除，无需手动管理
4. 自动关闭：`MNMsgToast` 会根据文字长度自动计算合适的显示时长

### MediaExport

用于媒体资源导出和处理的模块，它提供了强大的音视频导出功能，支持多种格式转换、裁剪、质量调整等操作。该模块基于 AVFoundation 框架构建，提供了两种导出方式：底层精细控制的 `MNMediaExportSession` 和简单易用的 `MNAssetExportSession`。

#### ✨ 特性

- ✅ **多格式支持**：支持 MP4、MOV、M4V、WAV、M4A、CAF、AIFF 等多种音视频格式
- ✅ **视频处理**：支持视频裁剪、尺寸调整、时间范围调整
- ✅ **音频处理**：支持音频提取、格式转换、质量调整
- ✅ **质量控制**：提供低、中、高三种质量预设
- ✅ **进度监控**：实时导出进度回调
- ✅ **元数据支持**：获取媒体时长、尺寸、截图等元数据信息输出
- ✅ **错误处理**：完善的错误类型

#### 🚀 快速开始

```
// Cocoapods 安装：
import MNSwiftKit
// SPM 安装可独立导入：
import MNMediaExport
```
** MNAssetExportSession **

使用 `AVAssetExportSession` 进行导出，增加了画面裁剪，时间片段裁剪，是否导出音视频控制等。
```
let session = MNAssetExportSession(asset: videoAsset, outputURL: outputURL)
// 质量预设
session.presetName = AVAssetExportPresetHighestQuality
// 是否导出音频/视频
session.exportAudioTrack = true
session.exportVideoTrack = true
// 裁剪区域
session.cropRect = CGRect(x: 0.0, y: 0.0, width: 500.0, height: 500.0)
// 渲染尺寸（输出的视频画面尺寸）
session.renderSize = CGSize(width: 1080.0, height: 1080.0)
// 裁剪的时间范围
session.timeRange = CMTimeRange(start: CMTime(seconds: 10, preferredTimescale: 600), duration: CMTime(seconds: 30, preferredTimescale: 600))
// 异步输出，进度和结果在主队列回调
session.exportAsynchronously { progressValue in
    print(progressValue)
} completionHandler: { status, error in
    if status == .completed {
        print("导出成功")
    } else {
        print("导出失败：\(error!)")
    }
}
```

** MNMediaExportSession **

使用 `AVAssetReader` 和 `AVAssetWriter` 进行底层导出，提供画面裁剪，时间片段裁剪，是否导出音视频控制等。
```
let session = MNMediaExportSession(asset: videoAsset, outputURL: outputURL)
session.quality = .high // 输出质量
session.exportAudioTrack = true
session.exportVideoTrack = true
session.cropRect = CGRect(x: 0.0, y: 0.0, width: 500.0, height: 500.0)
session.renderSize = CGSize(width: 1080.0, height: 1080.0)
session.timeRange = CMTimeRange(start: CMTime(seconds: 10, preferredTimescale: 600), duration: CMTime(seconds: 30, preferredTimescale: 600))
session.exportAsynchronously { progressValue in
    print(progressValue)
} completionHandler: { status, error in
    if status == .completed {
        print("导出成功")
    } else {
        print("导出失败：\(error!)")
    }
}
```

** 元数据操作 **

获取媒体文件时长
```
// 从文件路径获取
let duration = MNMediaExportSession.seconds(fileAtPath: "媒体文件路径")
// 从本地 URL 获取
let duration = MNMediaExportSession.seconds(mediaOfURL: videoURL)
```
获取视频尺寸
```
// 从文件路径获取
let size = MNMediaExportSession.naturalSize(videoAtPath: "视频文件路径")
// 从本地 URL 获取
let size = MNMediaExportSession.naturalSize(videoOfURL: videoURL)
```
获取视频截图
```
// 生成第5秒处的截图，若文件是音频则忽略时间，检查文件内封面输出
let image = MNMediaExportSession.generateImage(fileAtPath: "视频路径", at: 5.0, maximum: CGSize(width: 300, height: 300))
let image = MNMediaExportSession.generateImage(mediaOfURL: videoURL, at: 5.0, maximum: CGSize(width: 300, height: 300))
```

** 视频格式 **

- `.mp4` - MPEG-4 视频（最常用）
- `.m4v` - Apple 受保护的 MPEG-4 视频
- `.mov` - QuickTime 电影
- `.mobile3GPP` - 3GPP 视频

** 音频格式 **

- `.m4a` - Apple 音频（最常用）
- `.wav` - WAV 音频
- `.caf` - Core Audio 格式
- `.aiff` - AIFF 音频
- `.aifc` - AIFC 音频

** 质量枚举 **

```
public enum Quality {
    // 低质量
    case low      
    // 中等质量
    case medium   
    // 高质量
    case high
}
```

质量对视频的影响

- 低质量：适合快速预览，文件小
- 中等质量：平衡质量和文件大小（默认）
- 高质量：最佳画质，文件较大

质量对音频的影响

- 采样率：22050 Hz（低）→ 44100 Hz（中）→ 48000 Hz（高）
- 比特率：64 kbps（低）→ 128 kbps（中）→ 192 kbps（高）
- 声道数：单声道（低）→ 立体声（中/高）

** 错误信息 **

导出过程中可能出现的错误构造为`MNExportError`输出，使用`asExportError`转换后，调用`msg`属性输出错误提示信息。

```
public enum MNExportError: Swift.Error {
    /// 未知错误
    case unknown
    /// 已取消
    case cancelled
    /// 繁忙
    case exporting
    /// 资源不可用
    case unexportable
    /// 资源不可读
    case unreadable
    /// 无法输出文件
    case cannotExportFile(URL, fileType: AVFileType)
    /// 未知文件类型
    case unknownFileType(String)
    /// 无法创建输出目录
    case cannotCreateDirectory(Error)
    /// 文件已存在
    case fileDoesExist(URL)
    /// 无法添加资源轨道
    case cannotAppendTrack(AVMediaType)
    /// 无法读取资源
    case cannotReadAsset(Error)
    /// 无法读写入文件
    case cannotWritToFile(URL, fileType: AVFileType, error: Error)
    /// 无法添加Output
    case cannotAddOutput(AVMediaType)
    /// 未知输出设置
    case unknownExportSetting(AVMediaType, fileType: AVFileType)
    /// 无法添加Input
    case cannotAddInput(AVMediaType)
    /// 无法开始读取
    case cannotStartReading(Error)
    /// 无法开始写入
    case cannotStartWriting(Error)
    /// 底层错误
    case underlyingError(Swift.Error)
}
```

#### 📝 注意事项

1. 文件路径：模块会自动创建目录，但需要确保有写入权限
2. 文件覆盖：如果输出文件已存在，模块会自动删除旧文件
3. 线程安全：进度和完成回调都在主队列执行，可以直接更新 UI
4. 格式兼容性：某些格式可能在不同 iOS 版本上有差异，建议使用 MP4（视频）和 M4A（音频）以获得最佳兼容性

## 示例

要运行示例项目，克隆repo，从`Example`目录运行`pod install`。

## 作者

panhub, fengpann@163.com

## 许可证

`MNSwiftKit`在MIT许可下可用，更多信息请参见`LICENSE`文件。
