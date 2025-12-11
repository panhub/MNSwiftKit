# MNSwiftKit

[![CI Status](https://img.shields.io/travis/panhub/MNSwiftKit.svg?style=flat)](https://travis-ci.org/mellow/MNSwiftKit)
[![Version](https://img.shields.io/cocoapods/v/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)
[![License](https://img.shields.io/cocoapods/l/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)
[![Platform](https://img.shields.io/cocoapods/p/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)

一个Swift组件集合，可以安装任一模块。

1. [要求](#要求)
2. [安装](#安装)
3. [使用](#使用)
    - [MNToast](#MNToast)
    - [MediaExport](#MediaExport)
    - [AssetBrowser](#AssetBrowser)
    - [AssetPicker](#AssetPicker)
    - [Database](#Database)
    - [EmptyView](#EmptyView)
    - [Request](#Request)
    - [Refresh](#Refresh)
4. [示例](#示例)
5. [作者](#作者)
6. [许可](#许可)

## 要求

- iOS 9.0+ | Swift 5.0
- Xcode 12

## 安装

### CocoaPods (iOS 9+, Swift 5+)

`MNSwiftKit` 可以通过[CocoaPods](https://cocoapods.org)安装，只需添加以下行到您的Podfile:

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

`MNSwiftKit` 也可以通过在您的`Package.swift`文件中添加适当的描述使用[Swift软件包管理器](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/)来安装：

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

要在项目中手动安装 `MNSwiftKit`，您可以：

1. 将 `MNSwiftKit` 文件夹整个拖入项目。
2. 导航至项目target下，切换至 `Build Phases` 选项卡，在 `Link Binary With Libraries` 下添加依赖库。

依赖系统库/框架包括：
`UIKit`，`Photos`，`PhotosUI`，`ImageIO`，`Security`，`StoreKit`，`Foundation`，`CoreFoundation`，`AVFoundation`, `AudioToolbox`，`CoreFoundation`，`CoreServices`，`CoreGraphics`，`CoreMedia`，`CoreAudio`，`CoreImage`，`CoreTelephony`，`QuartzCore`，`AdSupport`，`AppTrackingTransparency`，`AuthenticationServices`，`UniformTypeIdentifiers`，`SystemConfiguration`，`sqlite3`。

## 使用

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

```swift
// Cocoapods 安装：
import MNSwiftKit

// SPM 安装可独立导入：
import MNToast
```

显示带系统加载指示器的 Toast（支持大号和小号两种样式）：

```swift
MNToast.showActivity("加载中...")

view.mn.showActivityToast("加载中...")
```

显示成功的 Toast（带对勾动画的指示器）：

```swift
MNToast.showSuccess("操作成功")

view.mn.showSuccessToast("操作成功")
```

显示错误的 Toast（带 X 动画的指示器）：

```swift
MNToast.showError("操作失败")

view.mn.showErrorToast("操作失败")
```

显示纯文本提示的 Toast（自动关闭）

```swift
MNToast.showMsg("这是自动消失提示")

view.mn.showMsgToast("这是自动消失提示")
```

显示带图标提示的 Toast（不自动关闭）

```swift
MNToast.showInfo("温馨提示")

view.mn.showInfoToast("这是自动消失提示")
````

显示旋转动画的 Toast（支持三种样式：纯色线条、双线条、渐变线条）：

```swift
// 默认渐变线条
MNToast.showRotation("加载中...", style: .gradient)

view.mn.showRotationToast("加载中...", style: .gradient)
```

显示带进度的 Toast（支持两种样式：线条、填充）：

```swift
// 默认线条样式, 更新进度时，重新调用即可
MNToast.showProgress("正在下载", style: .line, value: 0.0)

view.mn.showProgressToast("正在下载", style: .line, value: 0.0)
```

关闭当前 Toast

```swift
MNToast.close(delay: 3.0, completion: nil)

view.mn.closeToast(delay: 3.0, completion: nil)
```

检查窗口是否有 Toast 显示

```swift
if MNToast.isAppearing {
    print("当前有 Toast 正在显示")
}

if view.mn.isToastAppearing {
    print("该视图上有 Toast 显示")
}
```

如果同类型的 Toast 正在显示，新的 Toast 会更新现有内容而不是创建新的：

````swift
// 第一次显示
MNToast.showActivity("加载中...")

// 再次调用相同类型，会更新文字而不是新建
MNToast.showActivity("加载完成")
````

你可以通过实现 `MNToastBuilder` 协议来创建自定义的 Toast 样式：

```swift
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

```swift
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

```swift
extension CustomToast: MNToastProgressSupported {

    func toastShouldUpdateProgress(_ value: CGFloat) {
        // 更新进度，value 范围 0.0 - 1.0
    }
}
```

#### 📝 注意事项

- **线程安全**：类方法加载时，Toast 相关方法都会自动在主线程执行，无需手动处理
- **键盘避让**：Toast 会自动检测键盘位置并调整显示位置，避免被键盘遮挡
- **内存管理**：Toast 会在关闭后自动从视图层级中移除，无需手动管理
- **自动关闭**：`MNMsgToast` 会根据文字长度自动计算合适的显示时长

### MediaExport

用于媒体资源导出和处理的模块，它提供了强大的音视频导出功能，支持多种格式转换、裁剪、质量调整等操作。该模块基于 AVFoundation 框架构建，提供了两种导出方式：底层精细控制的 `MNMediaExportSession` 和简单易用的 `MNAssetExportSession`。

#### ✨ 特性

-  **多格式支持**：支持 MP4、MOV、M4V、WAV、M4A、CAF、AIFF 等多种音视频格式
-  **视频处理**：支持视频裁剪、尺寸调整、时间范围调整
-  **音频处理**：支持音频提取、格式转换、质量调整
-  **质量控制**：提供低、中、高三种质量预设
-  **进度监控**：实时导出进度回调
-  **元数据支持**：获取媒体时长、尺寸、截图等元数据信息输出
-  **错误处理**：完善的错误类型

#### 🚀 快速开始

```swift
// Cocoapods 安装：
import MNSwiftKit

// SPM 安装可独立导入：
import MNMediaExport
```

**MNAssetExportSession**

使用 `AVAssetExportSession` 进行导出，增加了画面裁剪，时间片段裁剪，是否导出音视频控制等。

```swift
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

**MNMediaExportSession**

使用 `AVAssetReader` 和 `AVAssetWriter` 进行底层导出，提供画面裁剪，时间片段裁剪，是否导出音视频控制等。

```swift
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

**元数据操作**

获取媒体文件时长

```swift
// 从文件路径获取
let duration = MNMediaExportSession.seconds(fileAtPath: "媒体文件路径")
// 从本地 URL 获取
let duration = MNMediaExportSession.seconds(mediaOfURL: videoURL)
```

获取视频尺寸

```swift
// 从文件路径获取
let size = MNMediaExportSession.naturalSize(videoAtPath: "视频文件路径")
// 从本地 URL 获取
let size = MNMediaExportSession.naturalSize(videoOfURL: videoURL)
```

获取视频截图

```swift
// 生成第5秒处的截图，若文件是音频则忽略时间，检查文件内封面输出
let image = MNMediaExportSession.generateImage(fileAtPath: "视频路径", at: 5.0, maximum: CGSize(width: 300, height: 300))
let image = MNMediaExportSession.generateImage(mediaOfURL: videoURL, at: 5.0, maximum: CGSize(width: 300, height: 300))
```

**视频格式**

- `.mp4` - MPEG-4 视频（最常用）
- `.m4v` - Apple 受保护的 MPEG-4 视频
- `.mov` - QuickTime 电影
- `.mobile3GPP` - 3GPP 视频

**音频格式**

- `.m4a` - Apple 音频（最常用）
- `.wav` - WAV 音频
- `.caf` - Core Audio 格式
- `.aiff` - AIFF 音频
- `.aifc` - AIFC 音频

**质量枚举**

```swift
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

**错误信息**

导出过程中可能出现的错误构造为`MNExportError`输出，使用`asExportError`转换后，调用`msg`属性输出错误提示信息。

```swift
public enum MNExportError: Swift.Error {
    // 未知错误
    case unknown
    // 已取消
    case cancelled
    // 繁忙
    case exporting
    // 资源不可用
    case unexportable
    // 资源不可读
    case unreadable
    // 无法输出文件
    case cannotExportFile(URL, fileType: AVFileType)
    // 未知文件类型
    case unknownFileType(String)
    // 无法创建输出目录
    case cannotCreateDirectory(Error)
    // 文件已存在
    case fileDoesExist(URL)
    // 无法添加资源轨道
    case cannotAppendTrack(AVMediaType)
    // 无法读取资源
    case cannotReadAsset(Error)
    // 无法读写入文件
    case cannotWritToFile(URL, fileType: AVFileType, error: Error)
    // 无法添加Output
    case cannotAddOutput(AVMediaType)
    // 未知输出设置
    case unknownExportSetting(AVMediaType, fileType: AVFileType)
    // 无法添加Input
    case cannotAddInput(AVMediaType)
    // 无法开始读取
    case cannotStartReading(Error)
    // 无法开始写入
    case cannotStartWriting(Error)
    // 底层错误
    case underlyingError(Swift.Error)
}
```

#### 📝 注意事项

- **文件路径**：模块会自动创建目录，但需要确保有写入权限
- **文件覆盖**：如果输出文件已存在，模块会自动删除旧文件
- **线程安全**：进度和完成回调都在主队列执行，可以直接更新 UI
- **格式兼容性**：某些格式可能在不同 iOS 版本上有差异，建议使用 MP4（视频）和 M4A（音频）以获得最佳兼容性

### AssetBrowser

提供图片 / GIF / Live Photo / 视频的全屏浏览与交互体验，包含手势缩放、下拉退出、进度加载、播放器控制栏等完整功能。常用于相册资源预览、聊天/动态图片预览等场景。

#### ✨ 特性

- **支持类型**：静态图、GIF、Live Photo、视频（含进度控制与播放）
- **UI/交互**：双击缩放、下拉/点击退出、转场动画（缩略图到全屏）
- **资源获取**：封面、内容的异步加载与进度回调
- **播放控制**：播放/暂停、拖动进度、时间显示、自动播放开关
- **自定义事件**：返回/完成/保存/分享按钮；状态回调；滚动回调
- **清理策略**：退出时可选择清理临时资源

**核心类型与协议**

- MNAssetBrowser：浏览器视图，负责转场、手势、分页、状态管理。
- MNAssetBrowserCell：单页展示单元，负责图片/视频/LivePhoto 展示与播放控制。
- MNAssetScrollView：缩放容器，支持图片/视频/LivePhoto 的缩放与居中布局。
- MNAssetBrowseSupported：资源模型协议（类型、封面、内容、进度、容器视图）。
- MNAssetBrowseDelegate：浏览器事件代理（滚动、状态、导航按钮、封面/内容获取）。
- MNAssetBrowseResourceHandler：用于向上层请求封面与内容。

#### 🚀 快速开始

```swift
// Cocoapods 安装：
import MNSwiftKit

// SPM 安装可独立导入：
import MNAssetBrowser
```

**准备资源模型**

实现 MNAssetBrowseSupported 协议，或直接使用内置的 MNAssetBrowser.Item：

```swift
let item = MNAssetBrowser.Item()
item.identifier = "unique-id"
item.type = .photo  // .photo / .gif / .livePhoto / .video
item.cover = coverImage // 缩略图
item.contents = nil // 真实内容稍后异步填充
item.container = thumbView // 缩略图所在视图，用于转场动画
item.progress = 0.0 // 初始加载进度
```

**创建浏览器**

```swift
let browser = MNAssetBrowser(assets: [item1, item2, ...])
browser.leftBarEvent = .back // 左按钮：返回
browser.rightBarEvent = .save // 右按钮：保存/分享/完成等
browser.autoPlaying = true // 自动播放视频/LivePhoto
browser.exitWhenPulled = true // 下拉退出
browser.exitWhenTouched = false // 单击退出
browser.maximumZoomScale = 3.0 // 双击放大倍率
browser.delegate = self // 处理封面/内容获取与事件
```

**展示**

```swift
browser.present(in: view, from: startIndex, animated: true) { state in
    // willAppear / didAppear / willDisappear / didDisappear
}
```
或浏览单张图：

```swift
MNAssetBrowser.present(container: thumbView, in: view, using: image, animated: true)
```

**实现代理，提供封面/内容**

```swift
extension YourVC: MNAssetBrowseDelegate {

    func assetBrowser(_ browser: MNAssetBrowser,
                      fetchCover asset: any MNAssetBrowseSupported,
                      completion completionHandler: @escaping MNAssetBrowserCell.CoverUpdateHandler) {
        // 如果封面已就绪，直接 completionHandler(asset)
        // 否则异步下载封面，设置 asset.cover 后回调
    }

    func assetBrowser(_ browser: MNAssetBrowser,
                      fetchContents asset: any MNAssetBrowseSupported,
                      progress progressHandler: @escaping MNAssetBrowserCell.ProgressUpdateHandler,
                      completion completionHandler: @escaping MNAssetBrowserCell.ContentsUpdateHandler) {
        // 根据类型获取真实内容：
        // photo/gif: UIImage 或 GIF UIImage
        // livePhoto: PHLivePhoto
        // video: 本地文件路径 String
        // 下载/解码中调用 progressHandler(asset, progress, error)
        // 完成后设置 asset.contents，并 completionHandler(asset)
    }
}
```

**事件回调**

```swift
func assetBrowser(_ browser: MNAssetBrowser, didScrollToItemAt index: Int) {
    // 告知已浏览的资源索引
}

func assetBrowser(_ browser: MNAssetBrowser, didChange state: MNAssetBrowser.State) {
    // 状态变化 willAppear / didAppear / willDisappear / didDisappear
}

func assetBrowser(_ browser: MNAssetBrowser, navigationItemTouchUpInside event: MNAssetBrowser.Event) {
    switch event {
    case .back:  browser.dismiss()
    case .done:  // 完成
    case .save:  // 保存
    case .share: // 分享
    }
}
```

**UI/交互说明**

- 手势：
  - 双击：放大/还原
  - 单击（可选）：退出并带转场
  - 下拉（可选）：退出并带转场
- 视频控制：播放/暂停按钮、进度滑条、当前时长与总时长显示。
- Live Photo：显示 Live badge，自动播放可选。

#### 📝 注意事项

- `asset.contents`类型：
  - `.photo/.gif`：`UIImage` 对象
  - `.livePhoto`：`PHLivePhoto` 对象
  - `.video`：`String` 类型本地视频文件路径（建议先落地）
- `asset.container`（缩略图所在视图）必须赋值，用于转场动画。
- 导航按钮事件通过 MNAssetBrowser.Event（back/done/save/share/none）区分。
- 资源较大时，请务必做好异步加载与进度回调，避免阻塞 UI。

### AssetPicker

一套基于 Photos 框架的多媒体选择器，支持图片/GIF/LivePhoto/视频的选择、预览、裁剪与导出，提供丰富的选项控制、交互体验和结果回调。内置依赖多个子模块，完成选取、预览、播放、导出的一站式流程。

#### ✨ 特性

- 📸 **多资源类型支持**：支持静态图片、GIF 动图、Live Photo、视频四种资源类型
- 🎯 **灵活选择控制**：支持单选/多选、混合选择、类型限制、数量限制等丰富的选择策略
- 🎨 **主题样式**：支持亮色/暗黑两种主题模式，可自定义主题颜色和辅助颜色
- 👆 **滑动选择**：支持手势滑动快速选择多个资源，提升选择效率
- 🎬 **视频裁剪**：内置视频裁剪功能，支持设置最小时长和最大时长限制
- 🔍 **资源预览**：支持全屏预览已选资源，可在预览中调整选择状态
- 📱 **相册切换**：支持切换不同相册，查看所有相册资源
- 📄 **分页加载**：采用分页加载机制，支持升序/降序排列，优化性能
- ☁️ **iCloud 支持**：自动处理 iCloud 资源下载，显示下载进度
- 🎞️ **格式导出**：支持 HEIF/HEIC 格式导出，支持视频导出为 MP4 格式
- 📊 **文件信息**：可选显示文件大小、视频时长等元数据信息
- 🔄 **Live Photo 处理**：支持 Live Photo 资源导出，可选择导出资源文件

#### 🚀 快速开始

```swift
// Cocoapods 安装：
import MNSwiftKit

// SPM 安装可独立导入：
import MNAssetPicker
```

**单选配置**

```swift
let options = MNAssetPickerOptions()
options.maxPickingCount = 1
options.allowsPickingPhoto = true
options.allowsPickingVideo = false

let picker = MNAssetPicker(options: options)
picker.present(pickingHandler: { picker, assets in
    guard let asset = assets.first else { return }
    if let image = asset.contents as? UIImage {
        // 使用图片
        print("选择了图片：\(image)")
    }
}, cancelHandler: { picker in
    print("用户取消了选择")
})
```

**多选配置**

```swift
let options = MNAssetPickerOptions()
options.maxPickingCount = 9  // 最多选择9张
options.minPickingCount = 1  // 至少选择1张
options.allowsPickingPhoto = true
options.allowsPickingVideo = true
options.allowsPickingGif = true
options.allowsPickingLivePhoto = true
options.allowsMixedPicking = true  // 允许混合选择
```

**自定义主题样式**

```swift
let options = MNAssetPickerOptions()
options.mode = .dark  // 暗黑模式
options.themeColor = UIColor(red: 72.0/255.0, green: 122.0/255.0, blue: 245.0/255.0, alpha: 1.0)
options.tintColor = .white
options.numberOfColumns = 4  // 每行显示4列
options.minimumLineSpacing = 4.0
options.minimumInteritemSpacing = 4.0
```

**视频裁剪配置**

```swift
let options = MNAssetPickerOptions()
options.maxPickingCount = 1
options.allowsPickingVideo = true
options.allowsPickingPhoto = false
options.minExportDuration = 3.0  // 最小时长3秒
options.maxExportDuration = 60.0  // 最大时长60秒
options.allowsExportVideo = true  // 允许导出视频为MP4
```

**使用代理**

```swift
class ViewController: UIViewController, MNAssetPickerDelegate {
    
    func assetPicker(_ picker: MNAssetPicker, didFinishPicking assets: [MNAsset]) {
        // 处理选择的资源
        for asset in assets {
            // 处理每个资源
        }
    }
    
    func assetPickerDidCancel(_ picker: MNAssetPicker) {
        // 用户取消选择
    }
}
```

**配置选项说明**

`MNAssetPickerOptions` 提供了丰富的配置选项：

- **选择控制**：
  - `maxPickingCount`: 最多选择数量（默认：1）
  - `minPickingCount`: 至少选择数量（默认：0）
  - `allowsPickingPhoto`: 是否允许选择图片（默认：true）
  - `allowsPickingVideo`: 是否允许选择视频（默认：true）
  - `allowsPickingGif`: 是否允许选择 GIF（默认：true）
  - `allowsPickingLivePhoto`: 是否允许选择 Live Photo（默认：true）
  - `allowsMultiplePickingPhoto`: 是否允许多选图片（默认：true）
  - `allowsMultiplePickingVideo`: 是否允许多选视频（默认：true）
  - `allowsMixedPicking`: 是否允许混合选择（默认：true）

- **UI 配置**：
  - `mode`: 主题模式（.light / .dark，默认：.dark）
  - `themeColor`: 主题颜色
  - `tintColor`: 辅助颜色
  - `numberOfColumns`: 每行显示列数（默认：4）
  - `minimumLineSpacing`: 行间距（默认：4.0）
  - `minimumInteritemSpacing`: 列间距（默认：4.0）
  
- **功能配置**：
  - `allowsPreview`: 是否允许预览（默认：false）
  - `allowsSlidePicking`: 是否允许滑动选择（默认：false）
  - `allowsPickingAlbum`: 是否允许切换相册（默认：true）
  - `showFileSize`: 是否显示文件大小（默认：false）
  - `allowsExportHeifc`: 是否允许导出 HEIF/HEIC 格式（默认：false）
  - `allowsExportVideo`: 是否允许导出视频为 MP4（默认：false）
  
- **视频配置**：
  - `minExportDuration`: 视频最小时长（默认：0.0）
  - `maxExportDuration`: 视频最大时长（默认：0.0）
  - `videoExportURL`: 视频导出路径
  - `videoExportPreset`: 视频导出质量预设
  
- **其他配置**：
  - `compressionQuality`: 图片压缩质量（0.0-1.0，默认：1.0）
  - `renderSize`: 预览图渲染大小（默认：250x250）
  - `pageCount`: 分页数量（默认：140）
  - `sortAscending`: 是否升序排列（默认：false，降序）
  
**资源模型**
  
  选择完成后，返回的是 `MNAsset` 对象数组，对象包含：
  
- `type`: 资源类型（.photo / .gif / .livePhoto / .video）
- `contents`: 资源内容
  - 图片/GIF: UIImage 对象
  - Live Photo: PHLivePhoto 对象（iOS 9.1+）
  - 视频: String 类型本地文件路径
- `cover`: 缩略图 UIImage
- `duration`: 视频时长（仅视频有效）
- `fileSize`: 文件大小（字节）
- `isSelected`: 是否已选中
- `index`: 选择序号（从1开始）
  
#### 📝 注意事项
  
- **权限要求**：需要在 `Info.plist` 中添加相册访问权限说明
```swift
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择图片</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要访问相册以保存图片</string>
```
- **资源类型**：
  - `.photo`: 静态图片，`contents` 为 UIImage
  - `.gif`: GIF 动图，`contents` 为 UIImage（包含多帧）
  - `.livePhoto`: Live Photo，`contents` 为 PHLivePhoto（iOS 9.1+）
  - `.video`: 视频，`contents` 为 `String` 类型本地文件路径
- **iCloud 资源**：如果资源存储在 iCloud，模块会自动下载，请确保网络连接正常。
- **视频导出**：如果设置了 maxExportDuration 且视频时长超过限制，会自动进入视频裁剪界面。
- **内存管理**：大量资源选择时，建议及时处理 contents 并释放内存。
- **线程安全**：所有回调都在主线程执行，可以直接更新 UI。

### Database

一套基于 `SQLite3` 的轻量级数据库解决方案，提供简洁的 API 和强大的功能，支持模型自动映射、事务处理、异步操作等特性。无需编写 SQL 语句即可完成大部分数据库操作，让数据库操作变得简单高效。

#### ✨ 特性

- 🗄️ **SQLite3 基础**：基于 SQLite3，轻量级、高性能、零配置
- 🔒 **线程安全**：使用信号量机制保证多线程环境下的数据安全
- 🚀 **异步支持**：所有操作都支持同步和异步两种方式
- 🎯 **自动映射**：自动将 `Swift` 模型映射到数据库表结构，无需手动编写 SQL
- 📝 **协议支持**：支持 `TableColumnSupported` 协议自定义表字段
- 🔍 **灵活查询**：支持条件查询、模糊查询（前缀/后缀/包含）、排序、分页
- 📊 **聚合函数**：支持 SUM、AVG、MIN、MAX 等聚合函数
- 💾 **事务支持**：支持事务操作，保证数据一致性
- 🔐 **加密支持**：可选支持 SQLCipher 数据库加密
- 🎨 **类型丰富**：支持 integer、float、text、blob 四种数据类型
- 🔄 **自动处理**：自动处理枚举类型、可选类型等

#### 🚀 快速开始

```swift
// Cocoapods 安装：
import MNSwiftKit

// SPM 安装可独立导入：
import MNDatabase
```

**初始化数据库**

```swift
// 使用默认路径（/Documents/database.sqlite）
let database = MNDatabase.default

// 或指定自定义路径
let database = MNDatabase(path: "/path/to/your/database.sqlite")
```

**定义数据模型**

```swift
// 方式1：使用自动映射（推荐）
class User: Initializable {
    var name: String = ""
    var age: Int = 0
    var email: String = ""
    var score: Double = 0.0
    var avatar: Data = Data()
}

// 方式2：使用协议自定义字段
class User: Initializable, TableColumnSupported {
    var name: String = ""
    var age: Int = 0
    
    static var supportedTableColumns: [String: MNTableColumn.FieldType] {
        [
            "name": .text,
            "age": .integer
        ]
    }
}
```

**创建表**

```swift
// 同步创建表
if database.create(table: "users", using: User.self) {
    print("表创建成功")
}

// 异步创建表
database.create(table: "users", using: User.self) { success in
    if success {
        print("表创建成功")
    }
}

// 使用字段字典创建表
let columns: [String: MNTableColumn.FieldType] = [
    "name": .text,
    "age": .integer,
    "score": .float
]
database.create(table: "users", using: columns)
```

**插入数据**

```swift
// 方式1：插入模型对象
let user = User()
user.name = "张三"
user.age = 25
user.email = "zhangsan@example.com"
user.score = 95.5

if database.insert(into: "users", using: user) {
    print("插入成功")
}

// 方式2：插入字典
let fields: [String: Any] = [
    "name": "李四",
    "age": 30,
    "email": "lisi@example.com",
    "score": 88.0
]
database.insert(into: "users", using: fields)

// 批量插入
let users = [user1, user2, user3]
database.insert(into: "users", using: users)

// 异步插入
database.insert(into: "users", using: user) { success in
    print("插入结果：\(success)")
}
```

**查询数据**

```swift
// 查询所有数据
if let users = database.selectRows(from: "users", type: User.self) {
    for user in users {
        print("姓名：\(user.name)，年龄：\(user.age)")
    }
}

// 条件查询（使用字典）
let condition: [String: Any] = ["age": 25]
if let users = database.selectRows(from: "users", where: condition.sql, type: User.self) {
    // 处理查询结果
}

// 条件查询（使用字符串）
if let users = database.selectRows(from: "users", where: "age > 20", type: User.self) {
    // 处理查询结果
}

// 模糊查询
let match = MNTableColumn.MatchType.contains("name", "张")
if let users = database.selectRows(from: "users", regular: match, type: User.self) {
    // 查询姓名包含"张"的用户
}

// 排序查询
let ordered = MNTableColumn.ComparisonResult.descending("age")
if let users = database.selectRows(from: "users", ordered: ordered, type: User.self) {
    // 按年龄降序排列
}

// 分页查询
let range = NSRange(location: 0, length: 10)
if let users = database.selectRows(from: "users", limit: range, type: User.self) {
    // 查询前10条数据
}

// 组合查询
if let users = database.selectRows(
    from: "users",
    where: "age > 20",
    regular: MNTableColumn.MatchType.prefix("name", "张"),
    ordered: MNTableColumn.ComparisonResult.descending("age"),
    limit: NSRange(location: 0, length: 10),
    type: User.self
) {
    // 查询年龄大于20、姓名以"张"开头、按年龄降序、前10条
}

// 异步查询
database.selectRows(from: "users", type: User.self) { users in
    guard let users = users else { return }
    // 处理查询结果
}

// 查询数量
if let count = database.selectCount(from: "users") {
    print("共有 \(count) 条记录")
}

// 查询数量（带条件）
if let count = database.selectCount(from: "users", where: "age > 20") {
    print("年龄大于20的用户有 \(count) 个")
}
```

**更新数据**

```swift
// 更新模型对象
let user = User()
user.name = "王五"
user.age = 28

if database.update("users", where: "name = '张三'", using: user) {
    print("更新成功")
}

// 更新字典
let fields: [String: Any] = [
    "age": 26,
    "score": 96.0
]
database.update("users", where: "name = '张三'", using: fields)

// 更新所有记录
database.update("users", where: nil, using: ["score": 100.0])

// 异步更新
database.update("users", where: "name = '张三'", using: fields) { success in
    print("更新结果：\(success)")
}
```

**删除数据**

```swift
// 删除指定条件的数据
if database.delete(from: "users", where: "age < 18") {
    print("删除成功")
}

// 删除所有数据
database.delete(from: "users", where: nil)

// 删除表
if database.delete(table: "users") {
    print("表删除成功")
}

// 异步删除
database.delete(from: "users", where: "age < 18") { success in
    print("删除结果：\(success)")
}
```

**聚合函数**

```swift
// 求和
if let sum = database.selectFinite(
    from: "users",
    field: "score",
    operation: .SUM,
    default: 0.0
) {
    print("总分：\(sum)")
}

// 平均值
if let avg = database.selectFinite(
    from: "users",
    field: "score",
    operation: .AVG,
    default: 0.0
) {
    print("平均分：\(avg)")
}

// 最大值
if let max = database.selectFinite(
    from: "users",
    field: "age",
    operation: .MAX,
    default: 0
) {
    print("最大年龄：\(max)")
}

// 最小值
if let min = database.selectFinite(
    from: "users",
    field: "age",
    operation: .MIN,
    default: 0
) {
    print("最小年龄：\(min)")
}
```

**表管理**

```swift
// 检查表是否存在
if database.exists(table: "users") {
    print("表存在")
}

// 获取表字段信息
let columns = database.columns(in: "users")
for column in columns {
    print("字段：\(column.name)，类型：\(column.type)")
}

// 更新表字段（根据模型类）
if database.update("users", using: User.self) {
    print("表字段更新成功")
}

// 重命名表
if database.update("users", name: "new_users") {
    print("表重命名成功")
}
```

**字典转 SQL 条件**

```swift
// 将字典自动转换为 SQL WHERE 条件
let condition: [String: Any] = [
    "name": "张三",
    "age": 25,
    "score": 95.5
]
let sql = condition.sql  // "name = '张三' AND age = 25 AND score = 95.5"

// 使用转换后的 SQL
if let users = database.selectRows(from: "users", where: sql, type: User.self) {
    // 查询结果
}
```

**模糊查询类型**

```swift
// 前缀匹配（姓名以"张"开头）
let prefix = MNTableColumn.MatchType.prefix("name", "张")
// 可指定后续字符数限制
let prefixLimited = MNTableColumn.MatchType.prefix("name", "张", count: 2)

// 后缀匹配（姓名以"三"结尾）
let suffix = MNTableColumn.MatchType.suffix("name", "三")

// 包含匹配（姓名包含"张"）
let contains = MNTableColumn.MatchType.contains("name", "张")

// 自定义转义符
let customEscape = MNTableColumn.MatchType.contains("name", "张%", escape: "\\")
```

**数据类型**

`MNTableColumn.FieldType` 支持四种数据类型：
  - `.integer`: 整数类型（Int、Int64、Bool 等）
  - `.float`: 浮点数类型（Double、Float、CGFloat 等）
  - `.text`: 字符串类型（String、NSString）
  - `.blob`: 二进制数据类型（Data、NSData）

**协议支持**

```swift
// TableColumnAssignment：自定义赋值逻辑
class CustomUser: Initializable, TableColumnAssignment {
    var name: String = ""
    var age: Int = 0
    
    func setValue(_ value: Any, for property: String) {
        switch property {
        case "name":
            if let name = value as? String {
                self.name = name
            }
        case "age":
            if let age = value as? Int {
                self.age = age
            }
        default:
            break
        }
    }
}
```

#### 📝 注意事项

- **线程安全**：所有数据库操作都是线程安全的，可以在任意线程调用。
- **模型要求**：数据模型必须实现 `Initializable` 协议（提供 init() 方法）。
- **自动映射规则**：
  - `Int`、`Int64`、`Bool` → `.integer`
  - `Double`、`Float`、`CGFloat` → `.float`
  - `String`、`NSString` → `.text`
  - `Data`、`NSData` → `.blob`
  - 枚举类型会自动使用 `rawValue`
- **主键**：每个表自动包含一个名为 `id` 的自增主键，无需在模型中定义。
- **可选类型**：可选类型会被正确处理，`nil` 值会使用字段的默认值。
- **日期类型**：`Date` 类型会自动转换为时间戳（`Int64` 或 `Double`）存储。
- **性能优化**：
  - 批量插入时使用事务，性能更好
  - 查询结果会缓存表结构信息
  - 使用预编译语句缓存提升性能
- **错误处理**：在 DEBUG 模式下，所有 SQL 错误都会打印到控制台，便于调试。
- **数据库路径**：默认数据库路径为 `Documents/database.sqlite`，可通过初始化方法自定义。

### EmptyView

一个功能强大的空数据占位视图组件，用于在列表为空、数据加载失败等场景下展示友好的提示界面。支持图片、文字、按钮、自定义视图等多种元素，提供灵活的配置选项和自动显示/隐藏机制，让空状态展示变得简单优雅。

#### ✨ 特性

- 🎨 **多元素支持**：支持图片、文字、按钮、自定义视图四种元素，可自由组合
- 🔄 **自动检测**：自动检测 `UITableView` 和 `UICollectionView` 的数据数量，无需手动控制
- 📱 **滚动控制**：支持控制 `UIScrollView` 的滚动状态，空数据时可禁用滚动
- 🎭 **灵活配置**：通过协议提供丰富的配置选项，支持自定义样式、布局、动画等
- 🎬 **动画支持**：支持自定义动画和渐现动画，提升用户体验
- 🔍 **智能显示**：根据数据源自动判断是否显示空视图，支持手动控制
- 📐 **布局灵活**：支持垂直和水平布局，可自定义间距、对齐方式、偏移量
- 🎯 **事件处理**：支持图片、文字、按钮的点击事件，提供完整的交互能力
- 🔗 **协议驱动**：采用数据源和代理模式，代码结构清晰，易于扩展

#### 🚀 快速开始

```swift
// Cocoapods 安装：
import MNSwiftKit

// SPM 安装可独立导入：
import MNEmptyView
```

**基础使用**

```swift
class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置数据源
        tableView.mn.emptySource = self
        tableView.mn.emptyDelegate = self
    }
}

extension ViewController: MNDataEmptySource {
    // 是否显示空视图
    func dataEmptyViewShouldDisplay(_ superview: UIView) -> Bool {
        // 返回 true 表示显示空视图
        return dataArray.isEmpty
    }
    
    // 空视图图片
    func imageForDataEmptyView(_ superview: UIView) -> UIImage? {
        return UIImage(named: "empty_icon")
    }
    
    // 空视图描述文字
    func descriptionForDataEmptyView(_ superview: UIView) -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.gray
        ]
        return NSAttributedString(string: "暂无数据", attributes: attributes)
    }
    
    // 按钮标题
    func buttonAttributedTitleForDataEmptyView(_ superview: UIView, with state: UIControl.State) -> NSAttributedString? {
        if state == .normal {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.blue
            ]
            return NSAttributedString(string: "重新加载", attributes: attributes)
        }
        return nil
    }
    
    // 按钮大小
    func buttonSizeForDataEmptyView(_ superview: UIView) -> CGSize {
        return CGSize(width: 120, height: 40)
    }
}

extension ViewController: MNDataEmptyDelegate {
    // 按钮点击事件
    func dataEmptyViewButtonTouchUpInside() {
        // 重新加载数据
        loadData()
    }
}
```

**自定义视图**

```swift
extension ViewController: MNDataEmptySource {

    func dataEmptyViewShouldDisplay(_ superview: UIView) -> Bool {
        return dataArray.isEmpty
    }
    
    // 使用自定义视图
    func customViewForDataEmptyView(_ superview: UIView) -> UIView? {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        customView.backgroundColor = .lightGray
        
        let label = UILabel()
        label.text = "自定义空视图"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: customView.centerYAnchor)
        ])
        
        return customView
    }
}
```

**配置元素组合**

```swift
// 只显示图片和文字，不显示按钮
tableView.mn.emptyComponents = [.image, .text]

// 只显示自定义视图
tableView.mn.emptyComponents = [.custom]

// 显示所有元素（默认）
tableView.mn.emptyComponents = [.image, .text, .button]
```

**自定义布局**

```swift
extension ViewController: MNDataEmptySource {

    // 布局方向（垂直或水平）
    func axisForDataEmptyView(_ superview: UIView) -> NSLayoutConstraint.Axis {
        return .horizontal  // 水平布局
    }
    
    // 元素间距
    func spacingForDataEmptyView(_ superview: UIView) -> CGFloat {
        return 30.0
    }
    
    // 对齐方式
    func alignmentForDataEmptyView(_ superview: UIView) -> UIStackView.Alignment {
        return .center
    }
    
    // 内容偏移
    func offsetForDataEmptyView(_ superview: UIView) -> UIOffset {
        return UIOffset(horizontal: 0, vertical: -50)  // 向上偏移50点
    }
    
    // 边距
    func edgeInsetForDataEmptyView(_ superview: UIView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}
```

**自定义样式**

```swift
extension ViewController: MNDataEmptySource {

    // 背景颜色
    func backgroundColorForDataEmptyView(_ superview: UIView) -> UIColor? {
        return UIColor(white: 0.95, alpha: 1.0)
    }
    
    // 图片尺寸
    func imageSizeForDataEmptyView(_ superview: UIView) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    // 图片圆角
    func imageRadiusForDataEmptyView(_ superview: UIView) -> CGFloat {
        return 10.0
    }
    
    // 图片填充模式
    func imageModeForDataEmptyView(_ superview: UIView) -> UIView.ContentMode {
        return .scaleAspectFit
    }
    
    // 文字最大宽度
    func descriptionFiniteMagnitudeForDataEmptyView(_ superview: UIView) -> CGFloat {
        return 250.0
    }
    
    // 按钮圆角
    func buttonRadiusForDataEmptyView(_ superview: UIView) -> CGFloat {
        return 5.0
    }
    
    // 按钮边框
    func buttonBorderWidthForDataEmptyView(_ superview: UIView) -> CGFloat {
        return 1.0
    }
    
    func buttonBorderColorForDataEmptyView(_ superview: UIView) -> UIColor? {
        return .blue
    }
    
    // 按钮背景颜色
    func buttonBackgroundColorForDataEmptyView(_ superview: UIView) -> UIColor? {
        return .white
    }
}
```

**动画效果**

```swift
extension ViewController: MNDataEmptySource {

    // 自定义动画
    func displayAnimationForDataEmptyView(_ superview: UIView) -> CAAnimation? {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return animation
    }
    
    // 或使用渐现动画
    func fadeInDurationForDataEmptyView(_ superview: UIView) -> TimeInterval {
        return 0.25  // 0.0 表示不使用渐现动画
    }
}
```

**滚动控制**

```swift
extension ViewController: MNDataEmptySource {

    // 空数据时是否允许滚动
    func dataEmptyViewShouldScroll(_ superview: UIView) -> Bool {
        return false  // 空数据时禁用滚动
    }
}
```

**交互事件**

```swift
extension ViewController: MNDataEmptySource {

    // 图片是否可点击
    func dataEmptyViewShouldTouchImage(_ superview: UIView) -> Bool {
        return true
    }
    
    // 文字是否可点击
    func dataEmptyViewShouldTouchDescription(_ superview: UIView) -> Bool {
        return true
    }
}

extension ViewController: MNDataEmptyDelegate {

    // 图片点击事件
    func dataEmptyViewImageTouchUpInside(_ image: UIImage?) {
        print("图片被点击")
    }
    
    // 文字点击事件
    func dataEmptyViewDescriptionTouchUpInside(_ description: String?) {
        print("文字被点击：\(description ?? "")")
    }
    
    // 按钮点击事件
    func dataEmptyViewButtonTouchUpInside() {
        print("按钮被点击")
        loadData()
    }
    
    // 空视图出现
    func dataEmptyViewDidAppear() {
        print("空视图已显示")
    }
    
    // 空视图消失
    func dataEmptyViewDidDisappear() {
        print("空视图已隐藏")
    }
}
```

**手动控制显示/隐藏**

```swift
// 手动显示空视图
tableView.mn.emptyView?.show()

// 手动隐藏空视图
tableView.mn.emptyView?.dismiss()

// 根据条件显示/隐藏
tableView.mn.emptyView?.showIfNeeded()
```

**自动显示控制**

```swift
// 启用自动显示（默认开启）
tableView.mn.autoDisplayEmpty = true

// 禁用自动显示
tableView.mn.autoDisplayEmpty = false
```

**协议方法说明**

`MNDataEmptySource` 协议提供了丰富的配置方法，所有方法都是可选的：

- **显示控制**：
  - `dataEmptyViewShouldDisplay`: 是否显示空视图
  - `dataEmptyViewShouldScroll`: 是否允许滚动（`UIScrollView` 有效）
- **布局配置**：
  - `edgeInsetForDataEmptyView`: 边距
  - `offsetForDataEmptyView`: 内容偏移
  - `axisForDataEmptyView`: 布局方向（`.vertical` / `.horizontal`）
  - `spacingForDataEmptyView`: 元素间距
  - `alignmentForDataEmptyView`: 对齐方式
- **图片配置**：
  - `imageForDataEmptyView`: 图片
  - `imageSizeForDataEmptyView`: 图片尺寸
  - `imageModeForDataEmptyView`: 图片填充模式
  - `imageRadiusForDataEmptyView`: 图片圆角
  - `dataEmptyViewShouldTouchImage`: 图片是否可点击
- **文字配置**：
  - `descriptionForDataEmptyView`: 描述文字（富文本）
  - `descriptionFiniteMagnitudeForDataEmptyView`: 文字最大宽度
  - `dataEmptyViewShouldTouchDescription`: 文字是否可点击
- **按钮配置**：
  - `buttonSizeForDataEmptyView`: 按钮尺寸
  - `buttonRadiusForDataEmptyView`: 按钮圆角
  - `buttonBorderWidthForDataEmptyView`: 按钮边框宽度
  - `buttonBorderColorForDataEmptyView`: 按钮边框颜色
  - `buttonBackgroundColorForDataEmptyView`: 按钮背景颜色
  - `buttonBackgroundImageForDataEmptyView`: 按钮背景图片
  - `buttonAttributedTitleForDataEmptyView`: 按钮标题（富文本）
- **其他配置**：
  - `customViewForDataEmptyView`: 自定义视图
  - `backgroundColorForDataEmptyView`: 背景颜色
  - `userInfoForDataEmptyView`: 用户信息
  - `displayAnimationForDataEmptyView`: 自定义动画
  - `fadeInDurationForDataEmptyView`: 渐现动画时长

### 📝 注意事项

- **自动检测**：对于 `UITableView` 和 `UICollectionView`，模块会自动检测数据源的数量，无需手动实现 `dataEmptyViewShouldDisplay`。
- **滚动视图**：对于 `UIScrollView`，模块会监听 `contentSize` 的变化，自动判断是否显示空视图。
- **线程安全**：所有显示/隐藏操作都应在主线程执行，模块已使用 `@MainActor` 标记。
- **内存管理**：空视图使用弱引用关联到父视图，无需担心循环引用。
- **元素顺序**：通过 `emptyComponents` 可以控制元素的显示顺序，例如 [.text, .image, .button]。
- **自定义视图**：使用自定义视图时，需要设置正确的 frame 或使用 Auto Layout。
- **动画优先级**：如果同时实现了 `displayAnimationForDataEmptyView` 和 `fadeInDurationForDataEmptyView`，优先使用自定义动画。
- **滚动控制**：当空视图显示时，如果设置了 `dataEmptyViewShouldScroll` 为 `false`，会自动禁用滚动视图的滚动，隐藏时会恢复。
- **生命周期**：空视图的显示和隐藏会触发代理方法，可以在这些方法中执行相关操作。
- **数据源更新**：当数据源发生变化时，如果启用了 `autoDisplayEmpty`，空视图会自动更新显示状态。

### Request

一套基于 `URLSession` 的网络请求解决方案，提供简洁的 API 和强大的功能。`Request` 模块构建在 `Networking` 模块之上，支持数据请求、文件上传、文件下载、断点续传、请求缓存、自动重试等特性，让网络请求变得简单高效。

#### ✨ 特性

- 🌐 **多种请求类型**：支持 GET、POST、PUT、DELETE、HEAD 等 HTTP 方法
- 📤 **文件上传**：支持单文件上传，表单数据上传
- 📥 **文件下载**：支持普通下载和断点续传
- 💾 **智能缓存**：支持请求缓存策略，可设置缓存有效期
- 🔄 **自动重试**：支持失败自动重试，可配置重试次数和间隔
- 🎯 **灵活解析**：支持 JSON、纯文本等多种数据格式解析
- 🔒 **安全策略**：支持 HTTPS 证书验证、域名验证等安全策略
- 📊 **进度监控**：支持上传和下载进度实时回调
- 🎨 **参数编码**：自动处理参数编码，支持 URL 编码和表单编码
- 🛡️ **错误处理**：完善的错误类型定义，便于错误处理和调试
- 🔌 **网络检测**：支持网络可达性检测
- 🚀 **高性能**：基于 `URLSession`，性能优异，支持并发请求

#### 🚀 快速开始

```swift
// Cocoapods 安装：
import MNSwiftKit

// SPM 安装可独立导入：
import MNRequest
import MNNetworking
```

**GET 请求**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/users")
request.method = .get
request.start { 
    print("请求开始")
} completion: { result in
    if result.isSuccess {
        if let data = result.data as? [String: Any] {
            print("请求成功：\(data)")
        }
    } else {
        print("请求失败：\(result.msg)")
    }
}
```

**POST 请求**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/login")
request.method = .post
request.param = [
    "username": "user123",
    "password": "password123"
]
request.contentType = .json

request.start(completion: { result in
    if result.isSuccess {
        print("登录成功")
    } else {
        print("登录失败：\(result.msg)")
    }
})
```

**带 Header 的请求**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/data")
request.headerFields = [
    "Authorization": "Bearer token123",
    "Content-Type": "application/json"
]
request.start(completion: { result in
    // 处理结果
})
```

**请求缓存**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/data")
request.method = .get
request.cachePolicy = .returnCacheElseLoad  // 优先使用缓存，失败后请求网络
request.cacheValidInterval = 3600  // 缓存有效期1小时

request.start(completion: { result in
    if result.isSuccess {
        if request.source == .cache {
            print("使用缓存数据")
        } else {
            print("使用网络数据")
        }
    }
})
```

**请求重试**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/data")
request.retyCount = 3  // 最多重试3次
request.retryInterval = 1.0  // 重试间隔1秒

request.start(completion: { result in
    // 处理结果
})
```

**自定义解析**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/data")
request.contentType = .json
request.analyticHandler = { data, contentType in
    // 自定义解析逻辑
    if contentType == .json {
        // 自定义 JSON 解析
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }
    return nil
}

request.start(completion: { result in
    // 处理结果
})
```

**文件上传**

```swift
let request = HTTPUploadRequest(url: "https://api.example.com/upload")
request.start(body: {
    // 返回要上传的文件路径、URL 或 Data
    return "/path/to/file.jpg"
}, progress: { progress in
    print("上传进度：\(progress.fractionCompleted)")
}) { result in
    if result.isSuccess {
        print("上传成功")
    } else {
        print("上传失败：\(result.msg)")
    }
}
```

**多文件上传（使用 HTTPUploadAssistant）**

```swift
let assistant = HTTPUploadAssistant(boundary: "Boundary-\(UUID().uuidString)")
assistant.append(name: "username", value: "user123")
assistant.append(image: image1, name: "avatar", filename: "avatar.jpg")
assistant.append(image: image2, name: "cover", filename: "cover.jpg")

let request = HTTPUploadRequest(url: "https://api.example.com/upload")
request.boundary = assistant.boundary
request.start(body: {
    return assistant.data
}, progress: { progress in
    print("上传进度：\(progress.fractionCompleted)")
}) { result in
    // 处理结果
}
```

**文件下载**

```swift
let request = HTTPDownloadRequest(url: "https://example.com/file.zip")
request.downloadOptions = [.createIntermediateDirectories, .removeExistsFile]

request.start(location: { response, url in
    // 返回文件保存路径
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let fileName = response?.suggestedFilename ?? "download.zip"
    return URL(fileURLWithPath: "\(documentsPath)/\(fileName)")
}, progress: { progress in
    print("下载进度：\(progress.fractionCompleted)")
}) { result in
    if result.isSuccess {
        if let filePath = result.data as? String {
            print("下载成功，文件路径：\(filePath)")
        }
    } else {
        print("下载失败：\(result.msg)")
    }
}
```

**暂停和继续下载**

```swift
let request = HTTPDownloadRequest(url: "https://example.com/file.zip")

// 开始下载
request.start(location: { _, _ in
    return URL(fileURLWithPath: "/path/to/file.zip")
}, progress: { progress in
    print("下载进度：\(progress.fractionCompleted)")
}) { result in
    // 处理结果
}

// 暂停下载
request.suspend { resumeData in
    if let resumeData = resumeData {
        print("已暂停，可以继续下载")
    }
}

// 继续下载
request.resume { success in
    if success {
        print("继续下载成功")
    }
}
```

**文件下载（使用 HTTPFileRequest）**

```swift
let request = HTTPFileRequest(url: "https://example.com/file.zip")
request.downloadOptions = [.createIntermediateDirectories]

request.start(location: {
    // 返回文件保存路径
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    return URL(fileURLWithPath: "\(documentsPath)/file.zip")
}, progress: { progress in
    print("下载进度：\(progress.fractionCompleted)")
}) { result in
    if result.isSuccess {
        print("下载成功")
    }
}
```

**自定义回调队列**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/data")
request.queue = DispatchQueue.global(qos: .userInitiated)  // 自定义回调队列

request.start(completion: { result in
    // 在指定队列中回调
})
```

**错误处理**

```swift
request.start(completion: { result in
    if result.isSuccess {
        // 处理成功数据
    } else {
        // 处理错误
        switch result.code {
        case .badUrl:
            print("请求🔗不合法")
        case .cancelled:
            print("请求取消")
        // ....
        default: break
        }
    }
})
```

**取消请求**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/data")
request.start(completion: { result in
    // 处理结果
})

// 取消请求
request.cancel()
```

**忽略特定错误码**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/data")
request.ignoringErrorCodes = [HTTPErrorCancelled]  // 忽略取消错误

request.start(completion: { result in
    // 取消错误不会触发回调
})
```

**接受的状态码和内容类型**

```swift
let request = HTTPDataRequest(url: "https://api.example.com/data")
request.acceptableStatusCodes = IndexSet(integersIn: 200..<300)  // 只接受 200-299
request.acceptableContentTypes = [.json, .plainText]  // 只接受 JSON 和纯文本

request.start(completion: { result in
    // 处理结果
})
```

**网络缓存管理**

```swift
// 写入缓存
HTTPDatabase.default.setCache(data, forKey: "cache_key") { success in
    print("缓存写入：\(success)")
}

// 读取缓存
if let cache = HTTPDatabase.default.cache(forKey: "cache_key", timeInterval: 3600) {
    print("读取缓存：\(cache)")
}

// 删除缓存
HTTPDatabase.default.removeCache(forKey: "cache_key") { success in
    print("缓存删除：\(success)")
}

// 删除所有缓存
HTTPDatabase.default.removeAll { success in
    print("清空缓存：\(success)")
}
```

**继承 HTTPRequest 自定义请求**

```swift
class CustomRequest: HTTPDataRequest {

    override func didSuccess(responseData: Any) {
        super.didSuccess(responseData: responseData)
        // 自定义成功处理逻辑
    }
    
    override func didFail(_ result: HTTPResult) {
        super.didFail(result)
        // 自定义失败处理逻辑
    }
}
```

**分页请求支持**

```swift
class PagingRequest: HTTPDataRequest, HTTPPagingSupported {

    var page: Int = 1
    var hasMore: Bool = true
    var isPagingEnabled: Bool = true
    
    var isDataEmpty: Bool {
        
        return // 是否有缓存数据
    }
    
    func clearCache() {
        // 清除缓存数据
    }
    
    override func prepareLoadData() {
        if page == 1 {
            clearCache()
        }
        param = ["page": page]
    }
}
```

**请求方法**

`HTTPMethod` 枚举支持以下方法：
- `.get`: GET 请求
- `.post`: POST 请求
- `.put`: PUT 请求
- `.delete`: DELETE 请求
- `.head`: HEAD 请求

**缓存策略**

`CachePolicy` 枚举支持以下策略：
- `.never`: 不使用缓存
- `.returnCacheElseLoad`: 优先使用缓存，失败后请求网络
- `.returnCacheDontLoad`: 优先使用缓存，没有缓存或缓存过期则不加载

**内容类型**

`HTTPContentType` 枚举支持以下类型：
- `.none`: 不做处理
- `.json`: JSON 数据
- `.plainText`: 纯文本
- `.xml`: XML 数据
- `.html`: HTML 数据
- `.plist`: Plist 数据
- `.formData`: 文件上传
- `.formURLEncoded`: URL 编码数据
- `.binary`: 二进制数据

**下载选项**

`HTTPDownloadOptions` 支持以下选项：
- `.createIntermediateDirectories`: 自动创建中间目录
- `.removeExistsFile`: 删除已存在的文件

**错误类型**

`HTTPError` 提供了完善的错误类型：
- `requestSerializationFailure`: 请求序列化错误
- `responseParseFailure`: 响应解析错误
- `dataParseFailure`: 数据解析错误
- `uploadFailure`: 上传失败
- `downloadFailure`: 下载失败
- `httpsChallengeFailure`: HTTPS 挑战失败
- `custom`: 自定义错误

### 📝 注意事项

- **线程安全**：所有回调都在主线程执行（除非指定了自定义队列），可以直接更新 UI。
- **内存管理**：请求对象会被强引用直到请求完成，无需担心提前释放。
- **缓存机制**：缓存基于 `SQLite` 数据库，默认路径为 `Documents/http_caches.sqlite`。
- **重试机制**：重试只对网络错误有效，不会对序列化错误、解析错误、取消操作进行重试。
- **断点续传**：`HTTPDownloadRequest` 支持断点续传，暂停后可以继续下载。
- **文件下载**：`HTTPFileRequest` 使用 DataTask 下载，适合小文件；`HTTPDownloadRequest` 使用 DownloadTask，支持断点续传，适合大文件。
- **参数编码**：参数会自动进行 URL 编码，支持字典、字符串等多种格式。
- **错误处理**：建议检查 `result.isSuccess` 判断请求是否成功，失败时查看 `result.msg` 获取错误信息。
- **网络检测**：可以使用 `NetworkReachability` 检测网络状态，但请求本身会自动处理网络错误。
- **并发请求**：模块支持多个请求并发执行，由 `URLSession` 统一管理。
- **请求取消**：取消请求会触发错误回调，错误码为 `HTTPErrorCancelled`。

### Refresh

一个易于使用的下拉刷新和上拉加载更多组件，支持 UITableView、UICollectionView 等所有 UIScrollView 子类。提供默认实现和自定义扩展能力，让列表刷新变得简单优雅。

#### ✨ 特性

- 🔄 **下拉刷新**：支持下拉刷新数据，自动处理滚动视图的 `contentInset`
- 📥 **上拉加载**：支持上拉加载更多数据，智能检测滚动位置
- 🎨 **自定义组件**：支持自定义刷新头部和底部组件，灵活扩展
- 🎯 **状态管理**：完善的状态管理（normal、pulling、preparing、refreshing、noMoreData）
- 🔔 **多种回调**：支持 Block 回调和 Target-Action 两种方式
- 📊 **进度反馈**：支持拖拽进度回调，可实现丰富的动画效果
- 🎭 **默认实现**：提供开箱即用的默认刷新组件
- 🔧 **灵活配置**：支持自定义偏移、内容边距、颜色等
- 🚀 **自动布局**：自动处理组件位置和滚动视图的 `contentInset` 调整
- 💪 **线程安全**：所有操作都在主线程执行，安全可靠

#### 🚀 快速开始

```swift
// Cocoapods 安装：
import MNSwiftKit

// SPM 安装可独立导入：
import MNRefresh
```

**下拉刷新**

```swift
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建默认下拉刷新组件
        let header = MNRefreshStateHeader()
        header.beginRefreshHandler = { [weak self] in
            // 开始刷新数据
            self?.loadData()
        }
        
        // 设置下拉刷新
        tableView.mn.header = header
    }
    
    func loadData() {
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            // 刷新完成，结束刷新
            self?.tableView.mn.endRefreshing()
        }
    }
}
```

**上拉加载更多**

```swift
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建默认上拉加载组件
        let footer = MNRefreshStateFooter()
        footer.beginRefreshHandler = { [weak self] in
            // 开始加载更多数据
            self?.loadMoreData()
        }
        
        // 设置上拉加载
        tableView.mn.footer = footer
    }
    
    func loadMoreData() {
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            // 加载完成，结束加载
            self?.tableView.mn.endLoadMore()
        }
    }
}
```

**同时使用下拉刷新和上拉加载**

```swift
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 下拉刷新
        let header = MNRefreshStateHeader()
        header.beginRefreshHandler = { [weak self] in
            self?.refreshData()
        }
        tableView.mn.header = header
        
        // 上拉加载更多
        let footer = MNRefreshStateFooter()
        footer.beginRefreshHandler = { [weak self] in
            self?.loadMoreData()
        }
        tableView.mn.footer = footer
    }
    
    func refreshData() {
        // 刷新数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.tableView.mn.endRefreshing()
        }
    }
    
    func loadMoreData() {
        // 加载更多数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.tableView.mn.endLoadMore()
        }
    }
}
```

**使用 Target-Action 方式**

```swift
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 使用 Target-Action
        let header = MNRefreshStateHeader(target: self, action: #selector(headerRefresh))
        tableView.mn.header = header
    }
    
    @objc func headerRefresh() {
        // 刷新数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.tableView.mn.endRefreshing()
        }
    }
}
```

**自定义颜色**

```swift
let header = MNRefreshStateHeader()
header.color = .systemBlue  // 设置指示器颜色
tableView.mn.header = header

let footer = MNRefreshStateFooter()
footer.color = .systemBlue  // 设置指示器和文字颜色
tableView.mn.footer = footer
```

**自定义偏移和边距**

```swift
let header = MNRefreshStateHeader()
header.offset = UIOffset(horizontal: 0, vertical: 10)  // 设置偏移
header.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)  // 设置内容边距
tableView.mn.header = header
```

**无更多数据状态**

```swift
// 设置无更多数据
tableView.mn.footer?.endRefreshingAndNoMoreData()

// 恢复加载能力
tableView.mn.footer?.relieveNoMoreData()

// 或使用便捷属性
tableView.mn.isLoadMoreEnabled = false  // 禁用加载更多
tableView.mn.isLoadMoreEnabled = true   // 启用加载更多
```

**手动控制刷新**

```swift
// 手动开始刷新
tableView.mn.header?.beginRefresh()

// 手动结束刷新
tableView.mn.endRefreshing()

// 手动结束加载更多
tableView.mn.endLoadMore()

// 检查刷新状态
if tableView.mn.isRefreshing {
    print("正在刷新")
}

if tableView.mn.isLoadMore {
    print("正在加载更多")
}

if tableView.mn.isLoading {
    print("正在加载中（刷新或加载更多）")
}
```

**自定义刷新组件 - 头部**

```swift
class CustomRefreshHeader: MNRefreshHeader {

    private lazy var customView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    override func commonInit() {
        super.commonInit()
        addSubview(customView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = bounds.inset(by: contentInset)
        customView.frame = rect
    }
    
    override func headerViewDidDragging(_ percent: CGFloat) {
        // 根据拖拽进度更新 UI
        customView.alpha = percent
        customView.transform = CGAffineTransform(scaleX: percent, y: percent)
    }
    
    override func didChangeState(from oldState: State, to state: State) {
        super.didChangeState(from: oldState, to: state)
        switch state {
        case .refreshing:
            // 开始刷新动画
            startAnimating()
        case .normal:
            // 停止动画
            stopAnimating()
        default:
            break
        }
    }
    
    func startAnimating() {
        // 自定义动画
    }
    
    func stopAnimating() {
        // 停止动画
    }
}

// 使用自定义头部
let customHeader = CustomRefreshHeader()
customHeader.beginRefreshHandler = {
    // 刷新数据
}
tableView.mn.header = customHeader
```

**自定义刷新组件 - 底部**

```swift
class CustomRefreshFooter: MNRefreshFooter {

    private lazy var customLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "上拉加载更多"
        return label
    }()
    
    override func commonInit() {
        super.commonInit()
        addSubview(customLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = bounds.inset(by: contentInset)
        customLabel.frame = rect
    }
    
    override func footerViewDidDragging(_ percent: CGFloat) {
        // 根据拖拽进度更新文字
        if percent >= 1.0 {
            customLabel.text = "松开加载更多"
        } else {
            customLabel.text = "上拉加载更多"
        }
    }
    
    override func didChangeState(from oldState: State, to state: State) {
        super.didChangeState(from: oldState, to: state)
        switch state {
        case .refreshing:
            customLabel.text = "正在加载..."
        case .noMoreData:
            customLabel.text = "没有更多数据了"
        case .normal:
            customLabel.text = "上拉加载更多"
        default:
            break
        }
    }
}

// 使用自定义底部
let customFooter = CustomRefreshFooter()
customFooter.beginRefreshHandler = {
    // 加载更多数据
}
tableView.mn.footer = customFooter
```

**刷新状态说明**

`MNRefreshComponent.State` 枚举定义了以下状态：
- `.normal`: 普通状态，未触发刷新
- `.pulling`: 拖拽中，即将触发刷新
- `.preparing`: 准备刷新（视图未显示时）
- `.refreshing`: 正在刷新
- `.noMoreData`: 无更多数据（仅用于底部组件）

**生命周期回调**

```swift
let header = MNRefreshStateHeader()
header.beginRefreshHandler = {
    print("开始刷新")
}
header.endRefreshingHandler = {
    print("结束刷新")
}
tableView.mn.header = header
```

**移除刷新组件**

```swift
// 移除下拉刷新
tableView.mn.header = nil

// 移除上拉加载
tableView.mn.footer = nil
```

**刷新组件属性**

`MNRefreshComponent` 提供以下可配置属性：
- `color`: 组件颜色（影响组件的指示器和文字颜色）
- `offset`: 组件偏移量
- `contentInset`: 组件内容边距
- `beginRefreshHandler`: 开始刷新回调
- `endRefreshingHandler`: 结束刷新回调
- `isRefreshing`: 是否正在刷新
- `isNoMoreData`: 是否无更多数据状态

### 📝 注意事项

- **自动布局**：刷新组件会自动添加到滚动视图并处理布局，无需手动设置约束。
- **contentInset 调整**：组件会自动调整滚动视图的 `contentInset`，刷新结束后会自动恢复。
- **线程安全**：所有刷新操作都应在主线程执行，组件内部已做线程安全处理。
- **状态管理**：刷新状态由组件内部管理，外部只需调用 `beginRefresh()` 和 `endRefreshing()` 方法。
- **无更多数据**：当数据加载完毕时，调用 `endRefreshingAndNoMoreData()` 设置无更多数据状态，用户将无法继续上拉加载。
- **恢复加载能力**：当需要重新启用加载更多时，调用 `relieveNoMoreData()` 恢复加载能力。
- **自定义组件**：继承 `MNRefreshHeader` 或 `MNRefreshFooter` 时，需要重写相关方法来处理状态变化和拖拽进度。
- **拖拽进度**：通过 `headerViewDidDragging(_:)` 和 `footerViewDidDragging(_:)` 方法可以获取拖拽进度（0.0-1.0），用于实现丰富的动画效果。
- **视图生命周期**：组件会自动监听滚动视图的 `contentOffset` 和 `contentSize` 变化，无需手动处理。
- **内存管理**：刷新组件使用弱引用关联到滚动视图，滚动视图销毁时组件会自动清理。
- **默认组件**：`MNRefreshStateHeader` 和 `MNRefreshStateFooter` 提供了开箱即用的默认实现，适合大多数场景。
- **iOS 11+ 适配**：组件已适配 iOS 11+ 的 `adjustedContentInset`，确保在各种情况下都能正常工作。


## 示例

要运行示例项目，克隆repo，从 `Example` 目录运行 `pod install`。

## 作者

panhub, fengpann@163.com

## 许可

`MNSwiftKit` 在MIT许可下可用，更多信息请参见`LICENSE`文件。
