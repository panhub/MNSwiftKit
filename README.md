# MNSwiftKit

[![CI Status](https://img.shields.io/travis/panhub/MNSwiftKit.svg?style=flat)](https://travis-ci.org/mellow/MNSwiftKit)
[![Version](https://img.shields.io/cocoapods/v/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)
[![License](https://img.shields.io/cocoapods/l/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)
[![Platform](https://img.shields.io/cocoapods/p/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)

一个Swift组件集合，可以安装任一模块。

- [要求](#要求)
- [安装](#安装)
- [使用](#使用)
    - [NameSpace](#NameSpace)
    - [Definition](#Definition)
    - [Base](#Base)
    - [Toast](#Toast)
    - [AssetBrowser](#AssetBrowser)
    - [AssetPicker](#AssetPicker)
    - [SplitController](#SplitController)
    - [EmoticonKeyboard](#EmoticonKeyboard)
    - [Slider](#Slider)
    - [Refresh](#Refresh)
    - [EmptyView](#EmptyView)
    - [EditingView](#EditingView)
    - [PageControl](#PageControl)
    - [Transitioning](#Transitioning)
    - [CollectionLayout](#CollectionLayout)
    - [Networking](#Networking)
    - [Request](#Request)
    - [Database](#Database)
    - [Player](#Player)
    - [MediaExport](#MediaExport)
    - [Purchase](#Purchase)
    - [Utility](#Utility)
    - [Components](#Components)
    - [Extension](#Extension)
- [示例](#示例)
- [作者](#作者)
- [许可](#许可)

## 要求

- iOS 12.0+ | Swift 5.0
- Xcode 10.2+

## 安装

### CocoaPods (iOS 12+, Swift 5+)

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
pod 'MNSwiftKit/EditingView'
pod 'MNSwiftKit/PageControl'
pod 'MNSwiftKit/Components'
pod 'MNSwiftKit/MediaExport'
pod 'MNSwiftKit/Transitioning'
pod 'MNSwiftKit/AssetBrowser'
pod 'MNSwiftKit/AnimatedImage'
pod 'MNSwiftKit/CollectionLayout'
pod 'MNSwiftKit/EmoticonKeyboard'
pod 'MNSwiftKit/SegmentedViewController'
```
### Swift软件包管理器 (iOS 12+, Swift 5+)

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
### 手动导入 (iOS 12+, Swift 5+)

要在项目中手动安装 `MNSwiftKit`，您可以：

1. 将 `MNSwiftKit` 文件夹整个拖入项目。
2. 导航至项目target下，切换至 `Build Phases` 选项卡，在 `Link Binary With Libraries` 下添加依赖库。

依赖系统库/框架包括：
`UIKit`，`Photos`，`PhotosUI`，`ImageIO`，`Security`，`StoreKit`，`Foundation`，`CoreFoundation`，`AVFoundation`, `AudioToolbox`，`CoreFoundation`，`CoreServices`，`CoreGraphics`，`CoreMedia`，`CoreAudio`，`CoreImage`，`CoreTelephony`，`QuartzCore`，`AdSupport`，`AppTrackingTransparency`，`AuthenticationServices`，`UniformTypeIdentifiers`，`SystemConfiguration`，`sqlite3`。

## 使用

### NameSpace

命名空间模块，为各种类型提供统一的命名空间支持。通过 `.mn` 命名空间，可以访问 `MNSwiftKit` 为各种类型添加的扩展功能，避免方法名冲突，让代码更加清晰和模块化。

#### ✨ 特性

- 🎯 **统一命名空间**：为所有类型提供 `.mn` 命名空间入口
- 🔧 **类型支持**：支持基础类型、UIKit 类型、Foundation 类型等多种类型
- 🚀 **易于扩展**：其他模块可以通过扩展 `MNNameSpaceWrapper` 来添加功能
- 💪 **避免冲突**：通过命名空间避免与系统方法或其他库的方法名冲突
- 🎨 **代码清晰**：使用命名空间让代码意图更加明确

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/NameSpace'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNNameSpace",
        dependencies: [
            .product(name: "MNNameSpace", package: "MNSwiftKit")
        ]
    )
]
```

**基础使用**

`NameSpace` 模块为各种类型提供了 `.mn` 命名空间入口，其他模块通过扩展 `MNNameSpaceWrapper` 来添加功能：

**自定义扩展**

其他模块可以通过扩展 MNNameSpaceWrapper 来为类型添加功能：

```swift
// 为 UIView 添加自定义功能
extension MNNameSpaceWrapper where Base: UIView {
    
    /// 自定义方法
    public func customMethod() {
        // 实现自定义逻辑
        print("调用自定义方法")
    }
    
    /// 自定义属性
    public var customProperty: String {
        return "自定义属性"
    }
}

// 使用自定义扩展
let view = UIView()
view.mn.customMethod()
let value = view.mn.customProperty
```

为特定类型添加扩展

```swift
// 为 String 类型添加扩展
extension MNNameSpaceWrapper where Base == String {
    
    /// 字符串长度（字符数）
    public var characterCount: Int {
        return base.count
    }
    
    /// 是否为空或只包含空白字符
    public var isBlank: Bool {
        return base.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// 使用
let text = "Hello World"
let count = text.mn.characterCount
let isEmpty = text.mn.isBlank
```

**命名空间的优势**

避免方法名冲突

```swift
// 使用命名空间可以避免与其他库的方法名冲突
view.mn.removeAllSubviews()  // MNSwiftKit 的方法
// 不会与系统或其他库的 removeAllSubviews 方法冲突
```

代码意图更明确

```swift
// 使用命名空间让代码意图更加明确
view.mn.minX = 10.0  // 明确表示这是 MNSwiftKit 提供的布局方法
view.frame.origin.x = 10.0  // 系统方法
```

#### 📝 注意事项

- **命名空间入口**：所有支持的类型都可以通过 `.mn` 访问扩展功能。
- **模块依赖**：`NameSpace` 模块是基础模块，其他模块依赖它来提供扩展功能。
- **扩展方式**：其他模块通过 `extension MNNameSpaceWrapper where Base: Type` 来添加功能。
- **类型安全**：命名空间扩展使用泛型约束，保证类型安全。
- **性能**：命名空间包装器是轻量级的，不会影响性能。
- **兼容性**：命名空间机制不会影响原有系统 API 的使用。
- **扩展顺序**：多个模块可以为同一类型添加扩展，不会冲突。

### Definition

一个基础定义模块，提供了常用的 UI 尺寸常量、屏幕信息、系统组件高度等定义。这些常量和方法封装了系统 API，提供了简洁易用的接口，让开发变得更加高效。

#### ✨ 特性

- 📐 **屏幕尺寸常量**：提供屏幕宽度、高度、最小值、最大值等常量
- 📱 **系统组件高度**：提供状态栏、导航栏、标签栏等系统组件的高度常量
- 🛡️ **安全区域**：提供底部安全区域高度常量
- 🔍 **响应者链查找**：提供响应者链查找方法，方便查找特定类型的响应者
- 🎯 **环境判断**：提供调试模式和模拟器判断常量
- 💪 **性能优化**：使用缓存机制，避免重复计算
- 🚀 **易于使用**：全局常量，直接使用，无需实例化

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Definition'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNDefinition",
        dependencies: [
            .product(name: "MNDefinition", package: "MNSwiftKit")
        ]
    )
]
```

屏幕尺寸常量

```swift
// 屏幕宽度
let screenWidth = MN_SCREEN_WIDTH

// 屏幕高度
let screenHeight = MN_SCREEN_HEIGHT

// 屏幕尺寸最小值（宽度和高度中的较小值）
let screenMin = MN_SCREEN_MIN

// 屏幕尺寸最大值（宽度和高度中的较大值）
let screenMax = MN_SCREEN_MAX

// 使用示例
let view = UIView(frame: CGRect(x: 0, y: 0, width: MN_SCREEN_WIDTH, height: MN_SCREEN_HEIGHT))
```

系统组件高度常量

```swift
// 状态栏高度
let statusBarHeight = MN_STATUS_BAR_HEIGHT

// 导航栏高度
let navBarHeight = MN_NAV_BAR_HEIGHT

// 顶部栏总高度（状态栏 + 导航栏）
let topBarHeight = MN_TOP_BAR_HEIGHT

// 标签栏高度
let tabBarHeight = MN_TAB_BAR_HEIGHT

// 底部安全区域高度
let bottomSafeHeight = MN_BOTTOM_SAFE_HEIGHT

// 底部栏总高度（标签栏 + 安全区域）
let bottomBarHeight = MN_BOTTOM_BAR_HEIGHT

// 使用示例
let contentView = UIView(frame: CGRect(
    x: 0,
    y: MN_TOP_BAR_HEIGHT,
    width: MN_SCREEN_WIDTH,
    height: MN_SCREEN_HEIGHT - MN_TOP_BAR_HEIGHT - MN_BOTTOM_BAR_HEIGHT
))
```

环境判断常量

```swift
// 是否是调试模式
if MN_IS_DEBUG {
    print("当前是调试模式")
    // 可以在这里添加调试代码
}

// 是否是模拟器
if MN_IS_SIMULATOR {
    print("当前运行在模拟器上")
    // 可以在这里添加模拟器特定代码
}
```

**常量说明**

屏幕尺寸常量

- `MN_SCREEN_WIDTH`: 屏幕宽度（动态获取，支持横竖屏切换）
- `MN_SCREEN_HEIGHT`: 屏幕高度（动态获取，支持横竖屏切换）
- `MN_SCREEN_MIN`: 屏幕尺寸最小值（min(width, height)）
- `MN_SCREEN_MAX`: 屏幕尺寸最大值（max(width, height)）

系统组件高度常量

- `MN_STATUS_BAR_HEIGHT`: 状态栏高度（缓存值，首次获取后缓存）
- `MN_NAV_BAR_HEIGHT`: 导航栏高度（缓存值，首次获取后缓存）
- `MN_TOP_BAR_HEIGHT`: 顶部栏总高度（状态栏 + 导航栏）
- `MN_TAB_BAR_HEIGHT`: 标签栏高度（缓存值，首次获取后缓存）
- `MN_BOTTOM_SAFE_HEIGHT`: 底部安全区域高度（iOS 11+）
- `MN_BOTTOM_BAR_HEIGHT`: 底部栏总高度（标签栏 + 安全区域）

环境常量

- `MN_IS_DEBUG`: 是否是调试模式（编译时确定）
- `MN_IS_SIMULATOR`: 是否是模拟器（编译时确定）

#### 📝 注意事项

- **屏幕尺寸**：`MN_SCREEN_WIDTH` 和 `MN_SCREEN_HEIGHT` 是计算属性，每次访问都会重新获取，支持横竖屏切换。
- **高度缓存**：状态栏、导航栏、标签栏高度使用缓存机制，首次获取后缓存，提高性能。
- **安全区域**：底部安全区域高度在 iOS 11+ 才有效，低版本返回 0。
- **iOS 13+ 适配**：屏幕尺寸和状态栏高度的获取已适配 iOS 13+ 的 Scene 架构。
- **性能优化**：高度相关的常量使用缓存机制，避免重复创建 UI 组件。
- **环境判断**：`MN_IS_DEBUG` 和 `MN_IS_SIMULATOR` 是编译时常量，编译器会优化未使用的分支。

### Base

应用基础架构模块，提供了视图控制器基类、导航控制器、标签栏控制器、网页控制器等核心组件。这些组件封装了常用的开发模式，提供了统一的接口和丰富的功能，让应用开发变得更加高效。

#### ✨ 特性

- 🎯 **基础控制器**：提供 `MNBaseViewController` 基础视图控制器，支持内容视图、数据加载、状态栏管理
- 📱 **导航控制器**：提供 `MNNavigationController`，集成转场动画，隐藏系统导航栏
- 🏷️ **标签栏控制器**：提供 `MNTabBarController`，支持自定义标签栏和角标
- 📋 **列表控制器**：提供 `MNListViewController`，支持 UITableView 和 UICollectionView，集成刷新和加载更多
- 🌐 **网页控制器**：提供 `MNWebViewController`，基于 WKWebView，支持进度条、脚本交互
- 💳 **支付控制器**：提供 `MNWebPayController`，支持网页支付（微信、支付宝）
- 🎨 **自定义导航栏**：提供 `MNNavigationBar`，支持自定义样式和按钮
- 🎨 **自定义标签栏**：提供 `MNTabBar`，支持自定义样式和角标
- 🔔 **事件回调**：提供丰富的代理和回调机制
- 💪 **易于使用**：简单的 API 设计，快速集成

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Base'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNBase",
        dependencies: [
            .product(name: "MNBase", package: "MNSwiftKit")
        ]
    )
]
```

基础视图控制器

```swift
class ViewController: MNBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // contentView 已自动创建，可以直接使用
        let label = UILabel(frame: contentView.bounds)
        label.text = "Hello World"
        label.textAlignment = .center
        contentView.addSubview(label)
    }
    
    // 加载数据
    override func loadData() {
        // 设置请求对象
        httpRequest = MNDataRequest(url: "https://api.example.com/data")
        super.loadData()
    }
    
    // 准备加载数据
    override func prepareLoadData(_ request: MNDataRequest) {
        // 自定义加载提示
        contentView.mn.showActivityToast("加载中...")
    }
    
    // 完成加载数据
    override func completeLoadData(_ result: MNRequestResult) {
        if result.isSuccess {
            // 处理数据
        } else {
            // 处理错误
        }
    }
    
    // 控制状态栏
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle(.lightContent, animation: .fade)
    }
}
```

内容视图约束

```swift
class ViewController: MNBaseViewController {
    
    // 定制内容约束（是否预留顶部/底部空间）
    override var preferredContentRectEdge: UIViewController.Edge {
        var edges: UIViewController.Edge = []
        // 预留顶部空间（状态栏+导航栏）
        edges.insert(.top)
        // 预留底部空间（标签栏+安全区域）
        edges.insert(.bottom)
        return edges
    }
}
```

扩展视图控制器（带导航栏）

```swift
class DetailViewController: MNExtendViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigationBar 已自动创建
        title = "详情"
        navigationBar.titleColor = .black
        navigationBar.backColor = .black
        
        // 添加自定义右按钮
        let rightButton = UIButton(type: .custom)
        rightButton.setTitle("完成", for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        // 通过代理方法返回
    }
    
    // 创建导航右按钮
    override func navigationBarShouldCreateRightBarItem() -> UIView? {
        let button = UIButton(type: .custom)
        button.setTitle("完成", for: .normal)
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return button
    }
    
    @objc func rightButtonTapped() {
        // 处理完成按钮点击
    }
}
```

列表控制器

```swift
class ListViewController: MNListViewController {
    
    var dataArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 列表视图已自动创建（tableView 或 collectionView）
        // 支持刷新和加载更多
    }
    
    // 设置列表类型
    override var preferredListType: MNListViewController.ListType {
        return .table  // 或 .collection
    }
    
    // 启用下拉刷新
    override var supportedRefreshEnabled: Bool {
        return true
    }
    
    // 启用上拉加载更多
    override var supportedLoadMoreEnabled: Bool {
        return true
    }
    
    // 开始刷新
    override func beginRefresh() {
        // 重新加载数据
        reloadData()
    }
    
    // 开始加载更多
    override func beginLoadMore() {
        // 加载更多数据
        loadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataArray[indexPath.row]
        return cell
    }
}
```

导航控制器

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let rootVC = ViewController()
        let navController = MNNavigationController(rootViewController: rootVC)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
}
```

自定义导航栏

```swift
class ViewController: MNExtendViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 自定义导航栏样式
        navigationBar.title = "标题"
        navigationBar.titleColor = .black
        navigationBar.titleFont = .systemFont(ofSize: 18, weight: .medium)
        navigationBar.backColor = .black
        navigationBar.separatorColor = .lightGray
        navigationBar.translucent = true  // 毛玻璃效果
    }
    
    // 创建自定义左按钮
    override var navigationBarLeftButtonItem: UIView? {
        let button = UIButton(type: .custom)
        button.setTitle("返回", for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }
    
    // 创建自定义右按钮
    override var navigationBarRightButtonItem: UIView? {
        let button = UIButton(type: .custom)
        button.setTitle("完成", for: .normal)
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }
    
    // 是否绘制返回按钮
    override func navigationBarShouldRenderBackItem() -> Bool {
        return false
    }
}
```

自定义标签栏

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = MNTabBarController()
        
        // 自定义标签栏样式
        tabBarController.bottomBar.translucent = true  // 毛玻璃效果
        tabBarController.bottomBar.separatorColor = .lightGray
        tabBarController.bottomBar.itemOffset = UIOffset(horizontal: 0, vertical: -5)  // 按钮偏移
        
        return true
    }
}
```

标签栏控制器

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 创建标签栏控制器
        let tabBarController = MNTabBarController()
        
        // 方式1：使用控制器数组
        let vc1 = HomeViewController()
        let vc2 = DiscoverViewController()
        let vc3 = ProfileViewController()
        tabBarController.viewControllers = [vc1, vc2, vc3]
        
        // 方式2：使用控制器名称数组（会自动创建导航控制器）
        tabBarController.controllers = ["HomeViewController", "DiscoverViewController", "ProfileViewController"]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
}

// 在子控制器中配置标签栏项
class HomeViewController: UIViewController {
    
    override var bottomBarItemTitle: String? {
        return "首页"
    }
    
    override var bottomBarItemImage: UIImage? {
        return UIImage(named: "home_normal")
    }
    
    override var bottomBarItemSelectedImage: UIImage? {
        return UIImage(named: "home_selected")
    }
    
    override var bottomBarItemTitleColor: UIColor {
        return .gray
    }
    
    override var bottomBarItemSelectedTitleColor: UIColor {
        return .systemBlue
    }
}
```

设置标签栏角标

```swift
// 设置数字角标
viewController.badge = 5

// 设置文字角标
viewController.badge = "New"

// 设置布尔角标（红点）
viewController.badge = true

// 删除角标
viewController.badge = nil

// 或通过标签栏控制器设置
tabBarController.bottomBar.setBadge(5, for: 0)
```

标签栏重复选择

```swift
class HomeViewController: UIViewController, MNTabBarItemRepeatedSelection {
    
    func tabBarController(_ tabBarController: MNTabBarController, repeatedSelectionItemAt index: Int) {
        // 处理标签栏重复选择（点击已选中的标签）
        // 例如：滚动到顶部
        tableView.setContentOffset(.zero, animated: true)
    }
}
```

网页控制器

```swift
class WebViewController: MNWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 方式1：使用 URL
        url = URL(string: "https://example.com")
        
        // 方式2：使用 HTML 字符串
        html = "<html><body>Hello World</body></html>"
        
        // 方式3：使用 URLRequest
        request = URLRequest(url: URL(string: "https://example.com")!)
        
        // 自定义配置
        configuration = WKWebViewConfiguration()
    }
    
    // 添加脚本响应器
    override func initialized() {
        super.initialized()
        addScript(responder: CustomWebResponder())
    }
}

// 自定义脚本响应器
class CustomWebResponder: MNWebScriptBridge {
    
    var cmds: [String] {
        return ["customCommand"]
    }
    
    func call(cmd: String, body: Any) {
        if cmd == "customCommand" {
            print("收到自定义命令：\(body)")
        }
    }
}
```

网页进度条

```swift
class WebViewController: MNWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 自定义进度条样式
        progressView.tintColor = .systemBlue
        progressView.fadeAnimationDelay = 0.5
        progressView.fadeAnimationDuration = 0.25
        progressView.progressAnimationDuration = 0.25
    }
}
```

网页支付控制器

```swift
// 配置支付参数
MNWebPayment.shared.scheme = "yourapp://"
MNWebPayment.shared.wxScheme = "weixin://wap/pay"
MNWebPayment.shared.aliScheme = "alipay://"
MNWebPayment.shared.wxH5Identifier = "https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb?"
MNWebPayment.shared.wxRedirect = "&redirect_url="
MNWebPayment.shared.wxAuthDomain = "yourapp.com://"
MNWebPayment.shared.aliSchemeKey = "fromAppUrlScheme"
MNWebPayment.shared.aliUrlKey = "safepay"

// 创建支付控制器
let payController = MNWebPayController(url: URL(string: "https://pay.example.com")!)
payController.eventHandler = self
payController.completionHandler = { controller in
    print("支付完成")
}
navigationController?.pushViewController(payController, animated: true)

// 在 AppDelegate 中处理支付回调
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return MNWebPayController.handOpen(url: url) == false
}
```

数据加载流程

```swift
class ViewController: MNBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 在 viewDidLayoutSubviews 后自动调用 loadData()
    }
    
    // 是否执行加载数据
    override func prepareExecuteLoadData() -> Bool {
        // 返回 false 则不自动加载
        return true
    }
    
    // 加载数据
    override func loadData() {
        httpRequest = MNDataRequest(url: "https://api.example.com/data")
        super.loadData()
    }
    
    // 重载数据
    override func reloadData() {
        // 取消当前请求并重新加载
        super.reloadData()
    }
    
    // 标记需要重载数据
    func markNeedsReload() {
        setNeedsReloadData()
        // 在 viewDidAppear 时会自动调用 reloadDataIfNeeded()
    }
}
```

#### 📝 注意事项

- **内容视图**：`MNBaseViewController` 会自动创建 `contentView`，已处理安全区域和标签栏高度。
- **导航栏**：`MNExtendViewController` 会自动创建 `navigationBar`，隐藏系统导航栏。
- **标签栏**：`MNTabBarController` 会自动创建自定义标签栏，隐藏系统标签栏。
- **数据加载**：`loadData()` 会在 `viewDidLayoutSubviews` 后自动调用，确保视图已布局完成。
- **状态栏管理**：状态栏样式由当前显示的控制器决定，导航控制器会自动转发。
- **转场动画**：`MNNavigationController` 已集成转场动画，无需额外配置。
- **网页脚本**：网页控制器支持添加多个脚本响应器，通过 `addScript(responder:)` 添加。
- **支付回调**：网页支付需要在 `AppDelegate` 中处理 URL Scheme 回调。
- **内存管理**：所有代理都使用弱引用，无需担心循环引用。

### Toast

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

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Toast'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNToast",
        dependencies: [
            .product(name: "MNToast", package: "MNSwiftKit")
        ]
    )
]
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
MNToast.showProgress("正在下载", style: .circular, value: 0.0)

view.mn.showProgressToast("正在下载", style: .circular, value: 0.0)
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

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/AssetBrowser'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNAssetBrowser",
        dependencies: [
            .product(name: "MNAssetBrowser", package: "MNSwiftKit")
        ]
    )
]
```

准备资源模型

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

创建浏览器

```swift
let browser = MNAssetBrowser(assets: [item1, item2, ...])
browser.leftBarItemEvent = .back // 左按钮：返回
browser.rightBarItemEvent = .save // 右按钮：保存/分享/完成等
browser.autoPlay = true // 自动播放视频/LivePhoto
browser.tapToDismiss = false // 单击退出
browser.dragToDismiss = true // 下拉退出
browser.maximumZoomScale = 3.0 // 双击放大倍率
browser.delegate = self // 处理封面/内容获取与事件
```

展示

```swift
browser.present(in: view, from: startIndex, animated: true) { state in
    // willAppear / didAppear / willDisappear / didDisappear
}

// 单个资源浏览
MNAssetBrowser.present(container: thumbView, in: view, using: image, animated: true)
```

实现代理，提供封面/内容

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

事件回调

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

UI/交互说明

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

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/AssetPicker'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNAssetPicker",
        dependencies: [
            .product(name: "MNAssetPicker", package: "MNSwiftKit")
        ]
    )
]
```

单选配置

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

多选配置

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

自定义主题样式

```swift
let options = MNAssetPickerOptions()
options.mode = .dark  // 暗黑模式
options.themeColor = UIColor(red: 72.0/255.0, green: 122.0/255.0, blue: 245.0/255.0, alpha: 1.0)
options.numberOfColumns = 4  // 每行显示4列
options.minimumLineSpacing = 4.0
options.minimumInteritemSpacing = 4.0
```

视频裁剪配置

```swift
let options = MNAssetPickerOptions()
options.maxPickingCount = 1
options.allowsPickingVideo = true
options.allowsPickingPhoto = false
options.minExportDuration = 3.0  // 最小时长3秒
options.maxExportDuration = 60.0  // 最大时长60秒
options.allowsExportVideo = true  // 允许导出视频为MP4
```

使用代理

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

配置选项说明

`MNAssetPickerOptions` 提供了丰富的配置选项：

- 选择控制：
  - `maxPickingCount`: 最多选择数量（默认：1）
  - `minPickingCount`: 至少选择数量（默认：0）
  - `allowsPickingPhoto`: 是否允许选择图片（默认：true）
  - `allowsPickingVideo`: 是否允许选择视频（默认：true）
  - `allowsPickingGif`: 是否允许选择 GIF（默认：true）
  - `allowsPickingLivePhoto`: 是否允许选择 Live Photo（默认：true）
  - `allowsMultiplePickingPhoto`: 是否允许多选图片（默认：true）
  - `allowsMultiplePickingVideo`: 是否允许多选视频（默认：true）
  - `allowsMixedPicking`: 是否允许混合选择（默认：true）

- UI 配置：
  - `mode`: 主题模式（.light / .dark，默认：.dark）
  - `themeColor`: 主题颜色
  - `numberOfColumns`: 每行显示列数（默认：4）
  - `minimumLineSpacing`: 行间距（默认：4.0）
  - `minimumInteritemSpacing`: 列间距（默认：4.0）
  
- 功能配置：
  - `allowsPreview`: 是否允许预览（默认：false）
  - `allowsSlidePicking`: 是否允许滑动选择（默认：false）
  - `allowsPickingAlbum`: 是否允许切换相册（默认：true）
  - `showFileSize`: 是否显示文件大小（默认：false）
  - `allowsExportHeifc`: 是否允许导出 HEIF/HEIC 格式（默认：false）
  - `allowsExportVideo`: 是否允许导出视频为 MP4（默认：false）
  
- 视频配置：
  - `minExportDuration`: 视频最小时长（默认：0.0）
  - `maxExportDuration`: 视频最大时长（默认：0.0）
  - `videoExportURL`: 视频导出路径
  - `videoExportPreset`: 视频导出质量预设
  
- 其他配置：
  - `compressionQuality`: 图片压缩质量（0.0-1.0，默认：1.0）
  - `renderSize`: 预览图渲染大小（默认：250x250）
  - `pageCount`: 分页数量（默认：140）
  - `sortAscending`: 是否升序排列（默认：false，降序）
  
资源模型
  
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

### SplitController

一个功能强大的分页控制器组件，支持顶部公共视图和内容页面的联动滑动，支持自定义导航项，提供丰富的自定义选项和流畅的交互体验。

#### ✨ 特性

- 📑 **分页展示**：支持多个子页面横向或纵向滑动切换
- 🎨 **丰富配置**：提供丰富的配置选项，支持自定义导航项样式、标记线动画、角标等
- 🔄 **布局方向**：支持横向和纵向两种布局方向
- 📊 **头部视图**：支持公共头部视图，支持头部视图与内容页面联动滚动
- 🎭 **标记线动画**：支持多种标记线动画效果（正常移动、吸附动画）
- 🏷️ **角标支持**：支持在导航项上显示角标（数字、文字、布尔值）
- 🔧 **动态管理**：支持动态插入、删除、替换页面
- 🎬 **生命周期**：完善的子页面生命周期管理
- 💪 **手势处理**：智能处理手势冲突，支持自定义手势优先级
- 🚀 **高性能**：基于 UICollectionView 和 UIScrollView，性能优异

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/SplitController'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNSplitController",
        dependencies: [
            .product(name: "MNSplitController", package: "MNSwiftKit")
        ]
    )
]
```

基础使用

```swift
class ViewController: UIViewController {
    
    var splitController: MNSplitViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建分页控制器
        splitController = MNSplitViewController(frame: view.bounds, axis: .horizontal)
        splitController.dataSource = self
        splitController.delegate = self
        
        // 添加到视图
        addChild(splitController)
        view.addSubview(splitController.view)
        splitController.didMove(toParent: self)
    }
}

extension ViewController: MNSplitViewControllerDataSource {

    // 页面标题
    var preferredPageTitles: [String] {
        return ["推荐", "关注", "热门", "最新"]
    }
    
    // 初始页面索引
    var preferredPageIndex: Int {
        return 0
    }
    
    // 获取子页面
    func splitViewController(_ viewController: MNSplitViewController, contentForPageAt index: Int) -> MNSplitPageConvertible {
        let pageVC = PageViewController()
        pageVC.title = preferredPageTitles[index]
        return pageVC
    }
}

extension ViewController: MNSplitViewControllerDelegate {
    // 页面切换回调
    func splitViewController(_ splitController: MNSplitViewController, didChangePageAt index: Int) {
        print("切换到页面：\(index)")
    }
}

// 子页面需要遵循 MNSplitPageConvertible 协议
class PageViewController: UIViewController, MNSplitPageConvertible {

    @IBOutlet weak var tableView: UITableView!
    
    var preferredPageScrollView: UIScrollView {
        return tableView
    }
}
```

自定义配置

```swift
// 配置导航栏样式
splitController.options.titleColor = .gray
splitController.options.highlightedTitleColor = .black
splitController.options.titleFont = .systemFont(ofSize: 16, weight: .medium)

// 配置标记线
splitController.options.shadowColor = .systemBlue
splitController.options.shadowSize = CGSize(width: 20, height: 3)
splitController.options.shadowAnimation = .adsorb  // 吸附动画

// 配置选中缩放
splitController.options.highlightedScale = 1.2

// 配置分割线
splitController.options.separatorStyle = .all
splitController.options.separatorColor = .lightGray
```

添加头部视图

```swift
extension ViewController: MNSplitViewControllerDataSource {
    // 页头视图
    var pageHeaderView: UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        headerView.backgroundColor = .systemBlue
        
        let label = UILabel()
        label.text = "这是头部视图"
        label.textAlignment = .center
        label.frame = headerView.bounds
        headerView.addSubview(label)
        
        return headerView
    }
}
```

设置角标

```swift
// 设置数字角标
splitController.setBadge(5, for: 0)

// 设置文字角标
splitController.setBadge("New", for: 1)

// 设置布尔角标（红点）
splitController.setBadge(true, for: 2)

// 删除角标
splitController.setBadge(nil, for: 0)

// 删除所有角标
splitController.removeAllBadges()
```

动态管理页面

```swift
// 插入页面
splitController.insertSplitters(with: ["新页面1", "新页面2"], at: 1)

// 删除页面
splitController.removeSplitter(at: 2)

// 替换页面标题
splitController.replaceSplitter(at: 0, with: "新标题")

// 替换页面内容
let newPage = NewPageViewController()
splitController.replacePage(newPage, at: 0)

// 重载页面
splitController.reloadPage(at: 0)

// 重载所有页面
splitController.reloadSubpage()
```

切换页面

```swift
// 切换到指定页面（带动画）
splitController.setCurrentPage(at: 2, animated: true)

// 切换到指定页面（无动画）
splitController.setCurrentPage(at: 2, animated: false)

// 获取当前页面索引
let currentIndex = splitController.currentPageIndex

// 获取当前页面
let currentPage = splitController.currentPage

// 获取指定页面
if let page = splitController.page(for: 1) {
    // 使用页面
}
```

纵向布局

```swift
// 创建纵向布局的分页控制器
let splitController = MNSplitViewController(frame: view.bounds, axis: .vertical)
splitController.dataSource = self
splitController.delegate = self
```

自定义导航项

```swift
// 注册自定义导航项 Cell
splitController.register(CustomSplitCell.self, forSplitterWithReuseIdentifier: "CustomCell")

// 或从 Nib 注册
let nib = UINib(nibName: "CustomSplitCell", bundle: nil)
splitController.register(nib, forSplitterWithReuseIdentifier: "CustomCell")

// 自定义 Cell 需要遵循 MNSplitCellConvertible 协议
class CustomSplitCell: UICollectionViewCell, MNSplitCellConvertible {

    func update(spliter: MNSpliter, at index: Int, axis: NSLayoutConstraint.Axis) {
        // 更新 Cell 内容
    }
    
    func updateTitleColor(_ color: UIColor?) {
        // 更新标题颜色
    }
    
    func updateTitleScale(_ scale: CGFloat) {
        // 更新标题缩放
    }
    
    // 实现其他可选方法...
}
```

配置选项说明

`MNSplitOptions` 提供了丰富的配置选项：

- 基础配置：
  - `spliterSize`: 导航项尺寸（横向：追加宽度和高度；纵向：宽度和每一项高度）
  - `contentMode`: 内容补全方案（`.normal`、`.fit` 居中、`.fill`充满）
  - `interSpliterSpacing`: 导航项间隔
  - `splitInset`: 导航栏边距
- 标记线配置：
  - `shadowMask`: 标记线补充方案（.fit 与标题同宽、.fill 与项同宽、.constant 使用指定宽度）
  - `shadowSize`: 标记线尺寸
  - `shadowColor`: 标记线颜色
  - `shadowImage`: 标记线图片
  - `shadowOffset`: 标记线偏移
  - `shadowRadius`: 标记线圆角
  - `shadowAlignment`: 标记线对齐方式（`.head`、`.center`、`.tail`）
  - `shadowAnimation`: 标记线动画类型（`.normal` 正常移动、`.adsorb` 吸附动画）
  - `sendShadowToBack`: 是否将标记线放到背景视图
- 标题配置：
  - `titleColor`: 标题颜色
  - `titleFont`: 标题字体
  - `highlightedTitleColor`: 选中标题颜色
  - `highlightedScale`: 选中时缩放因数
导航项样式：
  - `spliterBackgroundColor`: 导航项背景颜色
  - `spliterHighlightedBackgroundColor`: 选中时背景颜色
  - `spliterBackgroundImage`: 导航项背景图片
  - `spliterHighlightedBackgroundImage`: 选中时背景图片
  - `spliterBorderWidth`: 边框宽度
  - `spliterBorderRadius`: 边框圆角
  - `spliterBorderColor`: 边框颜色
  - `spliterHighlightedBorderColor`: 选中时边框颜色
- 分割线配置：
  - `separatorStyle`: 分割线样式（`.none`、`.head`、`.tail`、`.all`）
  - `separatorColor`: 分割线颜色
  - `separatorInset`: 分割线约束
  - `dividerColor`: 导航项之间分割线颜色
  - `dividerInset`: 导航项分割线约束
- 角标配置：
  - `badgeFont`: 角标字体
  - `badgeColor`: 角标背景颜色
  - `badgeTextColor`: 角标文字颜色
  - `badgeImage`: 角标背景图片
  - `badgeInset`: 角标内边距
  - `badgeOffset`: 角标偏移
- 其他配置：
  - `scrollPosition`: 导航滑动时选中位置（`.none`、`.head`、`.center`、`.tail`）
  - `transitionDuration`: 转场动画时长
  - `backgroundColor`: 背景颜色
  - `splitColor`: 导航视图颜色

#### 📝 注意事项

- **子页面协议**：子页面必须遵循 `MNSplitPageConvertible` 协议，并提供 `preferredPageScrollView` 属性。
- **头部视图联动**：当子页面的 `preferredPageScrollView` 内容高度达到最小要求时，头部视图会与内容页面联动滚动。
- **生命周期管理**：分页控制器会自动管理子页面的生命周期，子页面无需手动处理 `viewWillAppear` 等方法。
- **页面缓存**：分页控制器会缓存已创建的页面，避免重复创建。
- **布局方向**：支持横向（`.horizontal`）和纵向（`.vertical`）两种布局方向，创建时指定。
- **标记线动画**：支持 `.normal`（正常移动）和 `.adsorb`（吸附动画）两种动画效果。
- **角标类型**：角标支持 `String`、`Int`、`Bool` 三种类型，`Bool` 类型显示为红点。
- **动态管理**：支持动态插入、删除、替换页面，操作后会自动更新导航栏和内容页面。
- **手势冲突**：如果与其他手势冲突，可以使用 `requireFailTo(_:)` 方法设置手势优先级。
- **自定义导航项**：可以通过注册自定义 Cell 来完全自定义导航项的外观和行为。
- **头部视图保留高度**：通过 `reservedHeaderHeight` 属性可以设置头部视图的保留高度，超过此高度后头部视图会完全隐藏。
- **内容尺寸要求**：子页面的滚动视图需要达到最小内容尺寸要求，才能触发头部视图联动滚动。

### EmoticonKeyboard

一个功能强大的表情键盘组件，支持多种表情类型（图片表情、Unicode 表情、自定义表情），提供完整的表情输入、显示、管理功能。支持表情包管理、收藏夹、表情预览等特性，让表情功能变得简单易用。

#### ✨ 特性

- 🎨 **多种表情类型**：支持图片表情、Unicode 表情、自定义表情
- 📦 **表情包管理**：支持多个表情包，可动态添加、删除、编辑表情包
- ⭐ **收藏夹功能**：内置收藏夹，支持收藏和删除表情
- 🎯 **两种样式**：支持紧凑样式（纵向滑动）和分页样式（横向分页）
- 🔍 **表情预览**：长按表情可预览，提升用户体验
- 📝 **富文本支持**：自动将表情描述转换为富文本，支持在 UITextView 和 UILabel 中显示
- 🔄 **自动匹配**：自动匹配字符串中的表情描述并转换为图片
- 🎭 **表情包切换**：支持在多个表情包之间切换
- 🗑️ **删除功能**：支持删除按钮，方便删除输入的内容
- ⌨️ **Return 键**：支持自定义 Return 键类型和样式
- 🔊 **音效反馈**：支持输入时的音效反馈
- 🚀 **高性能**：使用缓存机制，优化表情加载和显示性能

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/EmoticonKeyboard'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNEmoticonKeyboard",
        dependencies: [
            .product(name: "MNEmoticonKeyboard", package: "MNSwiftKit")
        ]
    )
]
```

基础使用 - 紧凑样式

```swift
class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var emoticonKeyboard: MNEmoticonKeyboard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建表情键盘
        let options = MNEmoticonKeyboard.Options()
        options.packets = ["wechat", "收藏夹"]  // 表情包列表
        
        emoticonKeyboard = MNEmoticonKeyboard(
            frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300),
            style: .compact,  // 紧凑样式
            options: options
        )
        emoticonKeyboard.delegate = self
        // 设置 plainText 会自动匹配表情
        textView.mn.plainText = "今天很开心[微笑]"
        
        // 设置为输入视图
        textView.inputView = emoticonKeyboard
    }
}

extension ViewController: MNEmoticonKeyboardDelegate {
    // 表情点击事件
    func emoticonKeyboardShouldInput(emoticon: MNEmoticon) {
        // 输入表情到 UITextView
        textView.mn.input(emoticon: emoticon)
    }
    
    // Return 键点击事件
    func emoticonKeyboardReturnButtonTouchUpInside(_ keyboard: MNEmoticonKeyboard) {
        // 处理 Return 键点击
        textView.resignFirstResponder()
    }
    
    // 删除按钮点击事件
    func emoticonKeyboardDeleteButtonTouchUpInside(_ keyboard: MNEmoticonKeyboard) {
        // ...
    }
}
```

分页样式

```swift
let options = MNEmoticonKeyboard.Options()
options.packets = ["wechat", "收藏夹", "animal", "emotion"]

let = emoticonKeyboard = MNEmoticonKeyboard(
    frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300),
    style: .paging,  // 分页样式
    options: options
)
emoticonKeyboard.delegate = self
```

自定义配置

```swift
let options = MNEmoticonKeyboard.Options()

// 表情包列表
options.packets = [.wechat, .animal]

// Return 键类型
options.returnKeyType = .send

// 只有一个表情包时是否隐藏表情包栏
options.hidesForSingle = true

// 表情包栏高度
options.packetBarHeight = 50.0

// 表情包相邻间隔
options.packetInteritemSpacing = 12.0

// 表情包视图边距
options.packetSectionInset = UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)

// 表情包选择背景颜色
options.packetHighlightedColor = .systemBlue

// 表情包栏背景颜色
options.packetBarColor = UIColor(white: 0.96, alpha: 1.0)

// Return 键宽度（仅分页样式有效）
options.returnKeyWidth = 78.0

// Return 键颜色
options.returnKeyColor = .white

// Return 键标题颜色
options.returnKeyTitleColor = .black

// 分割线颜色
options.separatorColor = .lightGray

// 背景颜色
options.backgroundColor = UIColor(white: 0.95, alpha: 1.0)

// 页码指示器配置（仅分页样式有效）
options.pageControlHeight = 20.0
options.pageIndicatorSize = CGSize(width: 7, height: 7)
options.pageIndicatorColor = .gray
options.currentPageIndicatorColor = .darkGray
options.pageIndicatorSpacing = 11.0

// 是否允许播放音效
options.enableFeedbackWhenInputClicks = true

emoticonKeyboard = MNEmoticonKeyboard(frame: frame, style: .compact, options: options)
```

在 UILabel 中显示表情

```swift
let label = UILabel()

// 设置文本，自动匹配表情
label.mn.plainText = "今天很开心[微笑][呲牙][偷笑]"

// 或追加表情
label.mn.append(emoticon.image, desc: "[开心]")
```

富文本中匹配表情

```swift
let attributedString = NSMutableAttributedString(string: "今天很开心[微笑][呲牙]")

// 匹配表情并转换为图片
attributedString.mn.matchsEmoticon(with: UIFont.systemFont(ofSize: 17))

// 获取纯文本
let plainText = attributedString.mn.plainString  // "今天很开心[微笑][呲牙]"
```

表情包管理

```swift
// 获取表情包
MNEmoticonManager.fetchEmoticonPacket(["wechat", "收藏夹"]) { packets in
    print("获取到 \(packets.count) 个表情包")
}

// 创建表情包
MNEmoticonManager.shared.createEmoticonPacket(name: "我的表情包") { success in
    if success {
        print("创建成功")
    }
}

// 删除表情包
MNEmoticonManager.shared.removeEmoticonPacket(name: "我的表情包") { success in
    if success {
        print("删除成功")
    }
}

// 添加表情到表情包
let image = UIImage(named: "emoticon")!
MNEmoticonManager.addEmoticon(image: image, desc: "[自定义表情]", to: "我的表情包") { success in
    if success {
        print("添加成功")
    }
}

// 从表情包删除表情
MNEmoticonManager.removeEmoticon(desc: "[自定义表情]", from: "我的表情包") { success in
    if success {
        print("删除成功")
    }
}

// 更新表情包封面
MNEmoticonManager.shared.updateCover(image: coverImage, to: "我的表情包") { success in
    if success {
        print("更新成功")
    }
}
```

收藏夹功能

```swift
// 收藏表情到收藏夹
let image = UIImage(named: "emoticon")!
MNEmoticonManager.addEmoticonToFavorites(image: image, desc: "[收藏的表情]") { success in
    if success {
        print("收藏成功")
    }
}

// 从收藏夹删除表情
MNEmoticonManager.removeEmoticonFromFavorites(desc: "[收藏的表情]") { success in
    if success {
        print("删除成功")
    }
}

// 收藏夹会自动出现在表情包列表中（如果配置了 "收藏夹"）
```

获取表情图片

```swift
// 通过描述获取表情图片
if let image = MNEmoticonManager.shared["[微笑]"] {
    print("找到表情图片")
}

// 从指定表情包获取
if let image = MNEmoticonManager.shared.emoticonImage(for: "[微笑]", in: "wechat") {
    print("找到表情图片")
}

// 匹配字符串中的表情
let attachments = MNEmoticonManager.shared.matchsEmoticon(in: "今天很开心[微笑][呲牙]")
for attachment in attachments {
    print("表情：\(attachment.desc), 范围：\(attachment.range)")
}
```

切换表情包

```swift
// 切换到指定表情包
emoticonKeyboard.setCurrentEmoticonPacket("收藏夹", animated: true)

// 切换到指定索引的表情包
emoticonKeyboard.setEmoticonPacket(at: 1, animated: true)
```

添加收藏功能

```swift
extension ViewController: MNEmoticonKeyboardDelegate {
    // 收藏夹添加事件
    func emoticonKeyboardShouldAddToFavorites(_ keyboard: MNEmoticonKeyboard) {
        // 获取当前选中的表情（需要自己实现）
        // 然后添加到收藏夹
        MNEmoticonManager.addEmoticonToFavorites(image: currentEmoticon.image, desc: currentEmoticon.desc) { success in
            if success {
                print("收藏成功")
            }
        }
    }
}
```

表情类型说明

`MNEmoticon.Style` 枚举定义了以下类型：

- `.emoticon`: 图片表情（类似于微信表情）
- `.unicode`: Unicode 表情（Emoji）
- `.image`: 自定义图片表情

内置表情包

模块提供了以下内置表情包：

- `wechat`: 微信表情包
- `favorites`: 用户收藏夹（可编辑）
- `animal`: Unicode 动物和自然表情
- `face`: Unicode 笑脸和情感表情
- `food`: Unicode 食物和饮料表情
- `object`: Unicode 物品和符号表情
- `travel`: Unicode 旅游和地点表情
- `exercise`: Unicode 活动和运动表情

配置选项说明

`MNEmoticonKeyboard.Options` 提供以下配置选项：

- `packets`: 表情包列表（`MNEmoticon.Packet`类型）
- `returnKeyType`: Return 键类型（`.default`、`.send`、`.done` 等）
- `hidesForSingle`: 只有一个表情包时是否隐藏表情包栏（紧凑样式）或页码指示器（分页样式）
- `packetBarHeight`: 表情包栏高度
- `packetInteritemSpacing`: 表情包相邻间隔
- `packetSectionInset`: 表情包视图边距
- `packetItemInset`: 表情包图片边距
- `packetHighlightedColor`: 表情包选择背景颜色
- `packetBarColor`: 表情包栏背景颜色
- `returnKeyWidth`: Return 键宽度（仅分页样式有效）
- `returnKeyColor`: Return 键背景颜色
- `returnKeyTitleColor`: Return 键标题颜色
- `returnKeyTitleFont`: Return 键标题字体
- `separatorColor`: 分割线颜色
- `backgroundColor`: 键盘背景颜色
- `pageControlHeight`: 页码指示器高度（仅分页样式有效）
- `pageIndicatorSize`: 页码指示器尺寸
- `pageIndicatorColor`: 页码指示器颜色
- `pageIndicatorSpacing`: 页码指示器间隔
- `currentPageIndicatorColor`: 当前页码指示器颜色
- `pageIndicatorVerticalAlignment`: 页码指示器纵向对齐方式
- `pageIndicatorHorizontalAlignment`: 页码指示器横向对齐方式
- `enableFeedbackWhenInputClicks`: 是否允许播放音效

代理方法说明

`MNEmoticonKeyboardDelegate` 提供以下代理方法：

- `emoticonKeyboardShouldInput(emoticon:)`: 表情点击事件（必需）
- `emoticonKeyboardReturnButtonTouchUpInside(_:)`: Return 键点击事件（必需）
- `emoticonKeyboardDeleteButtonTouchUpInside(_:)`: 删除按钮点击事件（必需）
- `emoticonKeyboardShouldAddToFavorites(_:)`: 收藏夹添加事件（可选）

通知

模块提供了以下通知，可以监听表情包的变化：

```swift
// 添加表情包通知
NotificationCenter.default.addObserver(
    self,
    selector: #selector(emoticonPacketAdded(_:)),
    name: MNEmoticonPacketAddedNotification,
    object: nil
)

// 删除表情包通知
NotificationCenter.default.addObserver(
    self,
    selector: #selector(emoticonPacketRemoved(_:)),
    name: MNEmoticonPacketRemovedNotification,
    object: nil
)

// 表情包变化通知（添加/删除表情）
NotificationCenter.default.addObserver(
    self,
    selector: #selector(emoticonPacketChanged(_:)),
    name: MNEmoticonPacketChangedNotification,
    object: nil
)

@objc func emoticonPacketAdded(_ notification: Notification) {
    if let name = notification.userInfo?[MNEmoticonPacketNameUserInfoKey] as? String {
        print("表情包已添加：\(name)")
    }
}
```

表情包 JSON 格式

表情包使用 JSON 格式存储，结构如下：

```swift
{
  "style": 0,
  "name": "wechat",
  "cover": "cover.png",
  "emoticons": [
    {
      "img": "weixiao.png",
      "desc": "[微笑]"
    },
    {
      "img": "touxiao.png",
      "desc": "[偷笑]"
    }
  ]
}
```
- `style`: 表情类型（0: emoticon, 1: unicode, 2: image）
- `name`: 表情包名称
- `cover`: 封面图片文件名
- `emoticons`: 表情数组，每个表情包含 `img`（图片文件名）和 `desc`（描述）

用户表情包目录

用户自定义的表情包存储在：

```swift
Caches/MNSwiftKit/emoticons/
```
每个表情包使用 MD5 后的名称作为文件夹名，JSON 配置文件与文件夹同名。

#### 📝 注意事项

- **表情包加载**：表情包在键盘显示到窗口时才会加载，使用异步加载机制。
- **表情包编辑**：只有"收藏夹"表情包可以编辑，其他内置表情包不可编辑。
- **表情描述格式**：表情描述使用 `[描述]` 格式，例如 `[微笑]`、`[呲牙]`。
- **富文本显示**：表情在 `UITextView` 和 `UILabel` 中显示为 `NSTextAttachment`，需要设置 `attributedText`。
- **纯文本获取**：使用 `plainText` 属性可以获取去除表情后的纯文本，表情会被转换为描述字符串。
- **表情匹配**：模块使用正则表达式 `\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]` 匹配表情描述。
- **表情包切换**：切换表情包时会自动更新表情视图，无需手动刷新。
- **收藏夹自动创建**：如果收藏夹不存在，模块会自动创建。
- **通知机制**：表情包的添加、删除、变化都会发送通知，可以监听这些通知来更新 UI。
- **线程安全**：表情包管理操作支持异步执行，回调在主线程执行。
- **内存管理**：表情图片使用文件路径加载，不会占用过多内存。
- **样式选择**：`.compact` 样式适合纵向滑动查看，`.paging` 样式适合横向分页查看。
- **Return 键**：Return 键的标题会根据 `returnKeyType` 自动设置，支持中文标题。
- **表情预览**：长按表情会显示预览视图，松开后隐藏。
- **删除功能**：删除按钮会删除光标前的一个字符或表情，需要自己实现删除逻辑。

### Slider

一个功能丰富的自定义滑块组件，支持拖拽和点击两种交互方式。提供了丰富的样式配置选项，包括轨迹、进度条、滑块的颜色、图片、圆角、阴影等，让滑块组件变得灵活易用。

#### ✨ 特性

- 🎚️ **双交互方式**：支持拖拽和点击两种交互方式
- 📊 **灵活数值**：支持自定义最小值、最大值，自动计算当前值
- 🎨 **丰富样式**：支持自定义轨迹、进度条、滑块的样式（颜色、图片、圆角、阴影等）
- 🎯 **两种模式**：支持轨迹与两侧齐平或保留间距两种模式
- 🔔 **事件回调**：提供代理回调和闭包回调两种方式
- 🎬 **动画支持**：支持动画更新值
- 💪 **易于使用**：简单的 API 设计，快速集成

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Slider'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNSlider",
        dependencies: [
            .product(name: "MNSlider", package: "MNSwiftKit")
        ]
    )
]
```

基础使用

```swift
class ViewController: UIViewController {
    
    @IBOutlet weak var slider: MNSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建滑块
        let slider = MNSlider(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        slider.minimumValue = 0.0
        slider.maximumValue = 100.0
        slider.setValue(50.0, animated: false)
        
        // 设置值变化回调
        slider.setValueChange { slider in
            print("当前值：\(slider.value)")
        }
        
        view.addSubview(slider)
    }
}
```

自定义样式 - 轨迹

```swift
// 轨迹高度
slider.trackHeight = 4.0

// 轨迹颜色
slider.trackColor = .lightGray

// 轨迹圆角
slider.trackRadius = 2.0

// 轨迹图片
slider.trackImage = UIImage(named: "track_bg")

// 轨迹边框颜色
slider.trackBorderColor = .gray

// 轨迹边框宽度
slider.trackBorderWidth = 1.0
```

自定义样式 - 进度条

```swift
// 进度条颜色
slider.progressColor = .systemBlue

// 进度条图片
slider.progressImage = UIImage(named: "progress_bg")
```

自定义样式 - 滑块

```swift
// 滑块颜色
slider.thumbColor = .white

// 滑块圆角
slider.thumbRadius = 7.5

// 滑块大小
slider.thumbSize = CGSize(width: 20, height: 20)

// 滑块阴影颜色
slider.thumbShadowColor = .black.withAlphaComponent(0.3)

// 滑块阴影范围
slider.thumbShadowRadius = 2.5

// 滑块图片
slider.thumbImage = UIImage(named: "thumb_icon")

// 滑块图片颜色
slider.thumbImageColor = .clear

// 滑块图片圆角
slider.thumbImageRadius = 7.5

// 滑块图片四周约束
slider.thumbImageInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
```

轨迹模式

```swift
// 轨迹与两侧齐平（默认）
slider.trackOnSides = true
// 滑块可以滑动到最左和最右，轨迹与滑块边缘齐平

// 轨迹保留间距
slider.trackOnSides = false
// 轨迹左右各保留半个滑块宽度的间距，滑块不能滑动到最边缘
```

设置值和进度

```swift
// 设置当前值（根据最小值和最大值计算）
slider.minimumValue = 0.0
slider.maximumValue = 100.0
slider.setValue(50.0, animated: true)  // 设置值为 50，带动画

// 设置进度值（0.0-1.0）
slider.setProgress(0.5, animated: true)  // 设置进度为 50%

// 获取当前值
let currentValue = slider.value  // 根据进度计算的值

// 获取当前进度（0.0-1.0）
let progress = slider.progress

// 检查是否正在拖拽
if slider.isDragging {
    print("正在拖拽中")
}
```

**代理方法说明**

`MNSliderDelegate` 提供以下代理方法（所有方法都是可选的）：

- 拖拽相关

  - `sliderShouldBeginDragging(_:)`: 询问是否允许开始拖拽（返回 false 禁止拖拽）
  - `sliderWillBeginDragging(_:)`: 即将开始拖拽
  - `sliderDidDragging(_:)`: 拖拽中（持续调用）
  - `sliderDidEndDragging(_:)`: 拖拽结束

- 点击相关

  - `sliderShouldBeginTouching(_:)`: 询问是否允许点击（返回 false 禁止点击）
  - `sliderWillBeginTouching(_:)`: 即将点击
  - `sliderDidEndTouching(_:)`: 点击结束
  
**属性说明**

- 数值相关

  - `value`: 当前值（只读，根据 progress 和 min/max 计算）
  - `progress`: 当前进度（0.0-1.0，只读）
  - `minimumValue`: 最小值（默认：0.0）
  - `maximumValue`: 最大值（默认：1.0）
  - `isDragging`: 是否正在拖拽（只读）

- 样式相关

  - `trackHeight`: 轨迹高度
  - `trackColor`: 轨迹颜色
  - `trackRadius`: 轨迹圆角
  - `trackImage`: 轨迹图片
  - `trackBorderColor`: 轨迹边框颜色
  - `trackBorderWidth`: 轨迹边框宽度
  - `progressColor`: 进度条颜色
  - `progressImage`: 进度条图片
  - `thumbColor`: 滑块颜色
  - `thumbRadius`: 滑块圆角
  - `thumbSize`: 滑块大小
  - `thumbShadowColor`: 滑块阴影颜色
  - `thumbShadowRadius`: 滑块阴影范围
  - `thumbImage`: 滑块图片
  - `thumbImageColor`: 滑块图片颜色
  - `thumbImageRadius`: 滑块图片圆角
  - `thumbImageInset`: 滑块图片四周约束

- 其他

  - `trackOnSides`: 轨迹是否与两侧齐平（默认：true）
  
#### 📝 注意事项

- **数值范围**：minimumValue 必须小于 maximumValue，否则 value 会返回 minimumValue。
- **进度值**：progress 范围是 0.0-1.0，setProgress(_:animated:) 会自动限制在这个范围内。
- **拖拽状态**：在拖拽过程中调用 setProgress(_:animated:) 会被忽略，需要等待拖拽结束。
- **轨迹模式**：trackOnSides 为 true 时，轨迹与滑块边缘齐平；为 false 时，轨迹左右各保留半个滑块宽度的间距。
- **手势冲突**：点击手势会在拖拽手势失败后才触发，避免冲突。
- **动画更新**：使用 setValue(_:animated:) 或 setProgress(_:animated:) 时，设置 animated 为 true 会有动画效果。
- **约束布局**：滑块使用 Auto Layout 约束布局，支持自动适配不同屏幕尺寸。

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

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Refresh'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNRefresh",
        dependencies: [
            .product(name: "MNRefresh", package: "MNSwiftKit")
        ]
    )
]
```

下拉刷新

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

上拉加载更多

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

同时使用下拉刷新和上拉加载

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

使用 Target-Action 方式

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

自定义颜色

```swift
let header = MNRefreshStateHeader()
header.color = .systemBlue  // 设置指示器颜色
tableView.mn.header = header

let footer = MNRefreshStateFooter()
footer.color = .systemBlue  // 设置指示器和文字颜色
tableView.mn.footer = footer
```

自定义偏移和边距

```swift
let header = MNRefreshStateHeader()
header.offset = UIOffset(horizontal: 0, vertical: 10)  // 设置偏移
header.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)  // 设置内容边距
tableView.mn.header = header
```

无更多数据状态

```swift
// 设置无更多数据
tableView.mn.footer?.endRefreshingAndNoMoreData()

// 恢复加载能力
tableView.mn.footer?.relieveNoMoreData()

// 或使用便捷属性
tableView.mn.isLoadMoreEnabled = false  // 禁用加载更多
tableView.mn.isLoadMoreEnabled = true   // 启用加载更多
```

手动控制刷新

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

自定义刷新组件 - 头部

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

自定义刷新组件 - 底部

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

刷新状态说明

`MNRefreshComponent.State` 枚举定义了以下状态：
- `.normal`: 普通状态，未触发刷新
- `.pulling`: 拖拽中，即将触发刷新
- `.preparing`: 准备刷新（视图未显示时）
- `.refreshing`: 正在刷新
- `.noMoreData`: 无更多数据（仅用于底部组件）

生命周期回调

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

移除刷新组件

```swift
// 移除下拉刷新
tableView.mn.header = nil

// 移除上拉加载
tableView.mn.footer = nil
```

刷新组件属性

`MNRefreshComponent` 提供以下可配置属性：
- `color`: 组件颜色（影响组件的指示器和文字颜色）
- `offset`: 组件偏移量
- `contentInset`: 组件内容边距
- `beginRefreshHandler`: 开始刷新回调
- `endRefreshingHandler`: 结束刷新回调
- `isRefreshing`: 是否正在刷新
- `isNoMoreData`: 是否无更多数据状态

#### 📝 注意事项

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

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/EmptyView'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNEmptyView",
        dependencies: [
            .product(name: "MNEmptyView", package: "MNSwiftKit")
        ]
    )
]
```

基础使用

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
    func dataEmptyViewShouldAppear(_ superview: UIView) -> Bool {
        // 返回 true 表示显示空视图
        return dataArray.isEmpty
    }
    
    // 空视图图片
    func imageForDataEmptyView(_ superview: UIView) -> UIImage? {
        return UIImage(named: "empty_icon")
    }
    
    // 空视图描述文字
    func attributedHintForDataEmptyView(_ superview: UIView) -> NSAttributedString? {
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

自定义视图

```swift
extension ViewController: MNDataEmptySource {

    func dataEmptyViewShouldAppear(_ superview: UIView) -> Bool {
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

配置元素组合

```swift
// 只显示图片和文字，不显示按钮
tableView.mn.emptyComponents = [.image, .text]

// 只显示自定义视图
tableView.mn.emptyComponents = [.custom]

// 显示所有元素（默认）
tableView.mn.emptyComponents = [.image, .text, .button]
```

自定义布局

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

自定义样式

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
    func hintConstrainedMagnitudeForDataEmptyView(_ superview: UIView) -> CGFloat {
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

动画效果

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
    func fadeAnimationDurationForDataEmptyView(_ superview: UIView) -> TimeInterval {
        return 0.25  // 0.0 表示不使用渐现动画
    }
}
```

滚动控制

```swift
extension ViewController: MNDataEmptySource {

    // 空数据时是否允许滚动
    func dataEmptyViewShouldScroll(_ superview: UIView) -> Bool {
        return false  // 空数据时禁用滚动
    }
}
```

交互事件

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

手动控制显示/隐藏

```swift
// 手动显示空视图
tableView.mn.emptyView?.show()

// 手动隐藏空视图
tableView.mn.emptyView?.dismiss()

// 根据条件显示/隐藏
tableView.mn.emptyView?.showIfNeeded()
```

自动显示控制

```swift
// 启用自动显示（默认开启）
tableView.mn.autoDisplayEmpty = true

// 禁用自动显示
tableView.mn.autoDisplayEmpty = false
```

协议方法说明

`MNDataEmptySource` 协议提供了丰富的配置方法，所有方法都是可选的：

- 显示控制：
  - `dataEmptyViewShouldAppear`: 是否显示空视图
  - `dataEmptyViewShouldScroll`: 是否允许滚动（`UIScrollView` 有效）
- 布局配置：
  - `edgeInsetForDataEmptyView`: 边距
  - `offsetForDataEmptyView`: 内容偏移
  - `axisForDataEmptyView`: 布局方向（`.vertical` / `.horizontal`）
  - `spacingForDataEmptyView`: 元素间距
  - `alignmentForDataEmptyView`: 对齐方式
- 图片配置：
  - `imageForDataEmptyView`: 图片
  - `imageSizeForDataEmptyView`: 图片尺寸
  - `imageModeForDataEmptyView`: 图片填充模式
  - `imageRadiusForDataEmptyView`: 图片圆角
  - `dataEmptyViewShouldTouchImage`: 图片是否可点击
- 文字配置：
  - `attributedHintForDataEmptyView`: 描述文字（富文本）
  - `hintConstrainedMagnitudeForDataEmptyView`: 文字最大宽度
  - `dataEmptyViewShouldTouchDescription`: 文字是否可点击
- 按钮配置：
  - `buttonSizeForDataEmptyView`: 按钮尺寸
  - `buttonRadiusForDataEmptyView`: 按钮圆角
  - `buttonBorderWidthForDataEmptyView`: 按钮边框宽度
  - `buttonBorderColorForDataEmptyView`: 按钮边框颜色
  - `buttonBackgroundColorForDataEmptyView`: 按钮背景颜色
  - `buttonBackgroundImageForDataEmptyView`: 按钮背景图片
  - `buttonAttributedTitleForDataEmptyView`: 按钮标题（富文本）
- 其他配置：
  - `customViewForDataEmptyView`: 自定义视图
  - `backgroundColorForDataEmptyView`: 背景颜色
  - `userInfoForDataEmptyView`: 用户信息
  - `displayAnimationForDataEmptyView`: 自定义动画
  - `fadeAnimationDurationForDataEmptyView`: 渐现动画时长

#### 📝 注意事项

- **自动检测**：对于 `UITableView` 和 `UICollectionView`，模块会自动检测数据源的数量，无需手动实现 `dataEmptyViewShouldAppear`。
- **滚动视图**：对于 `UIScrollView`，模块会监听 `contentSize` 的变化，自动判断是否显示空视图。
- **线程安全**：所有显示/隐藏操作都应在主线程执行，模块已使用 `@MainActor` 标记。
- **内存管理**：空视图使用弱引用关联到父视图，无需担心循环引用。
- **元素顺序**：通过 `emptyComponents` 可以控制元素的显示顺序，例如 [.text, .image, .button]。
- **自定义视图**：使用自定义视图时，需要设置正确的 frame 或使用 Auto Layout。
- **动画优先级**：如果同时实现了 `displayAnimationForDataEmptyView` 和 `fadeAnimationDurationForDataEmptyView`，优先使用自定义动画。
- **滚动控制**：当空视图显示时，如果设置了 `dataEmptyViewShouldScroll` 为 `false`，会自动禁用滚动视图的滚动，隐藏时会恢复。
- **生命周期**：空视图的显示和隐藏会触发代理方法，可以在这些方法中执行相关操作。
- **数据源更新**：当数据源发生变化时，如果启用了 `autoDisplayEmpty`，空视图会自动更新显示状态。

### EditingView

滑动编辑模块，为 `UITableView` 和 `UICollectionView` 提供了类似系统原生滑动删除的功能，但功能更加丰富。支持左右双向滑动、自定义编辑按钮、二次编辑视图、自动状态管理等特性，让列表编辑变得简单易用。

#### ✨ 特性

- 👈👉 **双向滑动**：支持向左或向右滑动触发编辑
- 🎨 **自定义按钮**：支持完全自定义编辑按钮视图
- 🔄 **二次编辑**：点击按钮后可以替换为新的编辑视图
- 🎬 **流畅动画**：提供流畅的弹簧动画效果
- 🔄 **自动管理**：自动管理编辑状态，滚动时自动关闭
- 📱 **双列表支持**：同时支持 `UITableView` 和 `UICollectionView`
- 🎯 **智能手势**：智能识别横向滑动，避免与纵向滚动冲突
- ⚙️ **灵活配置**：支持圆角、背景色、内容边距等配置

#### 🚀 快速开始

```ruby
// Podfile 文件
pod 'MNSwiftKit/EditingView'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNEditingView",
        dependencies: [
            .product(name: "MNEditingView", package: "MNSwiftKit")
        ]
    )
]
```

UITableView 使用

```swift
class ViewController: UIViewController, UITableViewDataSource, UITableViewEditingDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置编辑选项
        tableView.mn.editingOptions.cornerRadius = 10.0
        tableView.mn.editingOptions.backgroundColor = .systemBackground
        tableView.mn.editingOptions.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
        
        tableView.dataSource = self
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"
        
        // 启用编辑功能
        cell.mn.allowsEditing = true
        
        return cell
    }
    
    // MARK: - UITableViewEditingDelegate
    
    // 返回支持的编辑方向
    func tableView(_ tableView: UITableView, editingDirectionsForRowAt indexPath: IndexPath) -> [MNEditingDirection] {
        return [.left, .right]  // 支持左右双向
    }
    
    // 返回编辑按钮视图
    func tableView(_ tableView: UITableView, editingActionsForRowAt indexPath: IndexPath, direction: MNEditingDirection) -> [UIView] {
        switch direction {
        case .left:
            // 向左滑动显示删除和更多按钮
            let deleteButton = createButton(title: "删除", color: .systemRed, width: 80)
            let moreButton = createButton(title: "更多", color: .systemBlue, width: 80)
            return [deleteButton, moreButton]
        case .right:
            // 向右滑动显示标记按钮
            let markButton = createButton(title: "标记", color: .systemOrange, width: 80)
            return [markButton]
        }
    }
    
    // 点击按钮后的二次编辑视图（可选）
    func tableView(_ tableView: UITableView, commitEditing action: UIView, forRowAt indexPath: IndexPath, direction: MNEditingDirection) -> UIView? {
        // 如果点击的是删除按钮，返回确认视图
        if let button = action as? UIButton, button.title(for: .normal) == "删除" {
            let confirmButton = createButton(title: "确认删除", color: .systemRed, width: 100)
            return confirmButton
        }
        return nil  // 返回 nil 表示不替换
    }
    
    // 创建按钮
    private func createButton(title: String, color: UIColor, width: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.frame = CGRect(x: 0, y: 0, width: width, height: 60)
        button.layer.cornerRadius = 8.0
        return button
    }
}
```

UICollectionView 使用

```swift
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewEditingDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置编辑选项
        collectionView.mn.editingOptions.cornerRadius = 10.0
        collectionView.mn.editingOptions.backgroundColor = .systemBackground
        collectionView.mn.editingOptions.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        collectionView.dataSource = self
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.titleLabel.text = "Item \(indexPath.item)"
        
        // 启用编辑功能
        cell.mn.allowsEditing = true
        
        return cell
    }
    
    // MARK: - UICollectionViewEditingDelegate
    
    func collectionView(_ collectionView: UICollectionView, editingDirectionsForItemAt indexPath: IndexPath) -> [MNEditingDirection] {
        return [.left]
    }
    
    func collectionView(_ collectionView: UICollectionView, editingActionsForItemAt indexPath: IndexPath, direction: MNEditingDirection) -> [UIView] {
        let deleteButton = createButton(title: "删除", color: .systemRed, width: 80)
        let shareButton = createButton(title: "分享", color: .systemBlue, width: 80)
        return [deleteButton, shareButton]
    }
    
    func collectionView(_ collectionView: UICollectionView, commitEditing action: UIView, forItemAt indexPath: IndexPath, direction: MNEditingDirection) -> UIView? {
        return nil
    }
    
    private func createButton(title: String, color: UIColor, width: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.frame = CGRect(x: 0, y: 0, width: width, height: 60)
        return button
    }
}
```

自定义编辑按钮视图

```swift
// 创建自定义视图作为编辑按钮
func tableView(_ tableView: UITableView, editingActionsForRowAt indexPath: IndexPath, direction: MNEditingDirection) -> [UIView] {
    // 方式1：使用按钮
    let button = UIButton(type: .system)
    button.setTitle("删除", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .systemRed
    button.frame = CGRect(x: 0, y: 0, width: 80, height: 60)
    
    // 方式2：使用自定义视图
    let customView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
    customView.backgroundColor = .systemBlue
    
    let label = UILabel(frame: customView.bounds)
    label.text = "自定义"
    label.textAlignment = .center
    label.textColor = .white
    customView.addSubview(label)
    
    return [button, customView]
}
```

编辑状态管理

```swift
// 手动结束编辑
tableView.mn.endEditing(animated: true)
collectionView.mn.endEditing(animated: true)

// 在 Cell 中结束编辑
cell.mn.endEditing(animated: true)

// 监听编辑状态变化（在 Cell 子类中重写）
class CustomCell: UITableViewCell {
    
    override func willBeginUpdateEditing(_ editing: Bool, animated: Bool) {
        super.willBeginUpdateEditing(editing, animated: animated)
        // 编辑状态即将改变
    }
    
    override func didEndUpdateEditing(_ editing: Bool, animated: Bool) {
        super.didEndUpdateEditing(editing, animated: animated)
        // 编辑状态改变完成
    }
}
```

配置选项

```swift
let options = tableView.mn.editingOptions
// 圆角
options.cornerRadius = 10.0
// 背景颜色
options.backgroundColor = .systemBackground
// 内容边距
// left: direction = .right 时有效
// right: direction = .left 时有效
options.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 8)
```

编辑方向说明

```swift
public enum MNEditingDirection: Int {
    case left   // 向左滑动触发编辑（按钮在右侧）
    case right  // 向右滑动触发编辑（按钮在左侧）
}

// 示例：只支持向左滑动
func tableView(_ tableView: UITableView, editingDirectionsForRowAt indexPath: IndexPath) -> [MNEditingDirection] {
    return [.left]
}

// 示例：只支持向右滑动
func tableView(_ tableView: UITableView, editingDirectionsForRowAt indexPath: IndexPath) -> [MNEditingDirection] {
    return [.right]
}

// 示例：支持双向滑动
func tableView(_ tableView: UITableView, editingDirectionsForRowAt indexPath: IndexPath) -> [MNEditingDirection] {
    return [.left, .right]
}
```

#### 📝 注意事项

- **数据源协议**：`UITableViewEditingDelegate` 和 `UICollectionViewEditingDelegate` 需要由 `dataSource` 实现，不是 `delegate`。
- **编辑方向**：根据滑动方向自动判断，需要在代理方法中返回支持的方向数组。
- **按钮宽度**：编辑按钮的宽度由视图的 `frame.width` 决定，确保设置正确的宽度。
- **自动关闭**：当列表滚动或内容尺寸改变时，会自动关闭编辑状态。
- **手势冲突**：模块会自动处理横向滑动和纵向滚动的冲突，只响应横向滑动。
- **二次编辑**：点击按钮后可以返回新的视图替换原按钮，实现二次确认等功能。
- **内存管理**：编辑视图使用关联对象存储，无需手动管理内存。
- **动画效果**：使用弹簧动画，提供流畅的交互体验。
- **阻尼效果**：当拖拽超过最优距离时，会自动添加阻尼效果，减缓拖拽。

### PageControl

一个功能丰富的页码指示器组件，类似于系统 `UIPageControl`，但提供了更多的自定义选项。支持横向和纵向布局、自定义指示器视图、点击切换、丰富的样式配置等功能，让页码指示器变得灵活易用。

#### ✨ 特性

- 📊 **双方向布局**：支持横向和纵向两种布局方向
- 🎨 **自定义指示器**：支持通过数据源自定义每个指示器的视图
- 👆 **点击切换**：支持点击指示器切换页面
- 🎯 **丰富样式**：支持自定义颜色、大小、边框、间距等样式
- 🔄 **指示器复用**：支持指示器视图缓存和复用
- 📐 **对齐方式**：支持多种对齐方式（左、中、右、上、下）
- 👁️ **单页隐藏**：支持单页时自动隐藏
- 🔔 **事件回调**：提供代理回调和 Target-Action 两种方式

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/PageControl'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNPageControl",
        dependencies: [
            .product(name: "MNPageControl", package: "MNSwiftKit")
        ]
    )
]
```

基础使用

```swift
class ViewController: UIViewController {
    
    @IBOutlet weak var pageControl: MNPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建页码指示器
        let pageControl = MNPageControl(frame: CGRect(x: 0, y: 100, width: 200, height: 20))
        pageControl.numberOfPages = 5
        pageControl.currentPageIndex = 0
        
        // 设置样式
        pageControl.pageIndicatorSize = CGSize(width: 8, height: 8)
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.spacing = 8.0
        
        // 添加事件
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        
        view.addSubview(pageControl)
    }
    
    @objc func pageControlChanged() {
        print("当前页码：\(pageControl.currentPageIndex)")
    }
}
```

使用代理

```swift
class ViewController: UIViewController, MNPageControlDelegate {
    
    @IBOutlet weak var pageControl: MNPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.delegate = self
        pageControl.numberOfPages = 5
        pageControl.currentPageIndex = 0
    }
    
    // MARK: - MNPageControlDelegate
    
    func pageControl(_ pageControl: MNPageControl, didSelectPageAt index: Int) {
        print("选择了第 \(index) 页")
        // 切换页面内容
    }
}
```

自定义指示器视图

```swift
class ViewController: UIViewController, MNPageControlDataSource {
    
    @IBOutlet weak var pageControl: MNPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.dataSource = self
        pageControl.numberOfPages = 5
        pageControl.currentPageIndex = 0
    }
    
    // MARK: - MNPageControlDataSource
    
    func numberOfPageIndicator(in pageControl: MNPageControl) -> Int {
        return 5
    }
    
    func pageControl(_ pageControl: MNPageControl, viewForPageIndicator index: Int) -> UIView {
        // 自定义指示器视图
        let view = UIView()
        view.backgroundColor = index == pageControl.currentPageIndex ? .systemBlue : .lightGray
        view.layer.cornerRadius = 4.0
        return view
    }
}
```

指示器复用

```swift
// 获取可复用的指示器视图
if let reusableIndicator = pageControl.dequeueReusableIndicator() {
    // 使用缓存的指示器视图
    // 可以重新配置后使用
}

// 刷新指示器（会自动复用缓存的视图）
pageControl.reloadPageIndicators()
```

自定义样式

```swift
let pageControl = MNPageControl(frame: CGRect(x: 0, y: 100, width: 200, height: 20))

// 指示器大小
pageControl.pageIndicatorSize = CGSize(width: 10, height: 10)

// 指示器颜色
pageControl.pageIndicatorTintColor = .lightGray
pageControl.currentPageIndicatorTintColor = .systemBlue

// 指示器边框
pageControl.pageIndicatorBorderWidth = 1.0
pageControl.pageIndicatorBorderColor = .gray
pageControl.currentPageIndicatorBorderWidth = 2.0
pageControl.currentPageIndicatorBorderColor = .systemBlue

// 指示器间距
pageControl.spacing = 8.0

// 触摸区域扩展
pageControl.pageIndicatorTouchInset = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)
```

对齐方式

```swift
// 水平对齐
pageControl.contentHorizontalAlignment = .left   // 左对齐
pageControl.contentHorizontalAlignment = .center // 居中（默认）
pageControl.contentHorizontalAlignment = .right  // 右对齐

// 垂直对齐
pageControl.contentVerticalAlignment = .top     // 顶部对齐
pageControl.contentVerticalAlignment = .center   // 居中（默认）
pageControl.contentVerticalAlignment = .bottom   // 底部对齐
```

单页隐藏

```swift
// 当只有一页时自动隐藏
pageControl.hidesForSinglePage = true
pageControl.numberOfPages = 1  // 会自动隐藏
```

**代理方法说明**

- `MNPageControlDataSource` 提供以下数据源方法（所有方法都是可选的）：

  - `numberOfPageIndicator(in:)`: 返回页码总数（如果不实现，使用 `numberOfPages` 属性）
  - `pageControl(_:viewForPageIndicator:)`: 返回自定义指示器视图（如果不实现，使用默认圆形视图）

- `MNPageControlDelegate` 提供以下代理方法（所有方法都是可选的）：

  - `pageControl(_:didSelectPageAt:)`: 指示器被点击时调用
  - `pageControl(_:willDisplay:forPageAt:)`: 指示器即将显示时调用
  
**属性说明**
  
- 基础属性

  - `numberOfPages`: 页码总数
  - `currentPageIndex`: 当前选中的页码索引
  - `axis`: 布局方向（`.horizontal` / `.vertical`）
  - `spacing`: 指示器间距
  - `hidesForSinglePage`: 单页时是否隐藏

- 样式属性

  - `pageIndicatorSize`: 指示器大小
  - `pageIndicatorTintColor`: 指示器颜色
  - `currentPageIndicatorTintColor`: 当前指示器颜色
  - `pageIndicatorBorderWidth`: 指示器边框宽度
  - `currentPageIndicatorBorderWidth`: 当前指示器边框宽度
  - `pageIndicatorBorderColor`: 指示器边框颜色
  - `currentPageIndicatorBorderColor`: 当前指示器边框颜色

- 其他属性

  - `pageIndicatorTouchInset`: 指示器触摸区域扩展
  - `contentHorizontalAlignment`: 水平对齐方式
  - `contentVerticalAlignment`: 垂直对齐方式
  
#### 📝 注意事项

- **数据源优先级**：如果实现了 `numberOfPageIndicator(in:)` 方法，会优先使用数据源返回的数量。
- **指示器复用**：通过数据源返回的自定义视图会被缓存，刷新时会自动复用。
- **布局方向**：横向布局时圆角半径使用高度，纵向布局时使用宽度。
- **触摸区域**：可以通过 `pageIndicatorTouchInset` 扩展触摸区域，方便点击。
- **单页隐藏**：设置 `hidesForSinglePage` 为 `true` 时，只有一页会自动隐藏。
- **对齐方式**：对齐方式会影响指示器在控件中的位置。
- **自动布局**：控件使用 Auto Layout 约束布局，支持自动适配。
- **内存管理**：所有代理都使用弱引用，无需担心循环引用。

### Transitioning

一个功能强大的导航转场动画模块，提供了多种转场样式和交互式转场支持。支持自定义转场动画、标签栏转场动画、转场背景色等丰富的配置选项，让导航转场变得流畅优雅。

#### ✨ 特性

- 🎬 **多种转场样式**：支持普通转场、抽屉式转场、模态转场、翻转转场四种样式
- 👆 **交互式转场**：支持手势驱动的交互式返回转场
- 📱 **标签栏动画**：支持标签栏的吸附、移动、无动画三种转场效果
- 🎨 **自定义动画**：支持为每个控制器自定义进栈和出栈转场动画
- 🌈 **背景色配置**：支持自定义转场背景色
- 🎭 **阴影效果**：自动添加转场阴影，提升视觉层次
- 🔧 **灵活配置**：通过协议提供丰富的配置选项
- 💪 **易于使用**：简单的 API 设计，快速集成

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Transitioning'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNTransitioning",
        dependencies: [
            .product(name: "MNTransitioning", package: "MNSwiftKit")
        ]
    )
]
```

基础使用

```swift
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建转场代理
        let delegate = MNTransitioningDelegate()
        delegate.transitionAnimation = .normal  // 转场样式
        delegate.bottomBarAnimation = .adsorb    // 标签栏动画
        
        // 设置导航控制器的转场代理
        navigationController?.mn.transitioningDelegate = delegate
    }
}
```

转场样式

```swift
let delegate = MNTransitioningDelegate()

// 普通转场（仿系统转场，带半透明黑色背景）
delegate.transitionAnimation = .normal

// 抽屉式转场（远近切换效果）
delegate.transitionAnimation = .drawer

// 模态转场（从底部滑入，背景缩放）
delegate.transitionAnimation = .modal

// 翻转转场（3D 翻转效果）
delegate.transitionAnimation = .flip

navigationController?.mn.transitioningDelegate = delegate
```

标签栏转场动画

```swift
let delegate = MNTransitioningDelegate()

// 无动画
delegate.bottomBarAnimation = .none

// 吸附效果（标签栏吸附在底部，跟随转场）
delegate.bottomBarAnimation = .adsorb

// 移动效果（标签栏跟随转场移动）
delegate.bottomBarAnimation = .move

// 设置标签栏视图
delegate.bottomBar = tabBarController?.tabBar

navigationController?.mn.transitioningDelegate = delegate
```

自定义转场动画

```swift
class CustomAnimator: MNTransitionAnimator {
    
    override var duration: TimeInterval { 0.5 }
    
    override func enterTransitionAnimation() {
        // 自定义进栈动画
        toView.frame = context.finalFrame(for: toController)
        toView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: duration) {
            self.toView.transform = .identity
        } completion: { _ in
            self.completeTransitionAnimation()
        }
    }
    
    override func leaveTransitionAnimation() {
        // 自定义出栈动画
        toView.frame = context.finalFrame(for: toController)
        containerView.insertSubview(toView, belowSubview: fromView)
        
        UIView.animate(withDuration: duration) {
            self.fromView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        } completion: { _ in
            self.completeTransitionAnimation()
        }
    }
}

// 在控制器中使用
class DetailViewController: UIViewController {
    
    override var preferredEnterTransitionAnimator: MNTransitionAnimator? {
        return CustomAnimator()
    }
    
    override var preferredLeaveTransitionAnimator: MNTransitionAnimator? {
        return CustomAnimator()
    }
}
```

控制器配置

```swift
class ViewController: UIViewController {
    
    // 是否允许交互式返回（默认 true）
    override var preferredInteractiveTransitioning: Bool {
        return true
    }
    
    // 指定转场标签栏
    override var preferredTransitioningBottomBar: UIView? {
        return tabBarController?.tabBar
    }
    
    // 指定转场背景色
    override var preferredTransitionBackgroundColor: UIColor? {
        return .white
    }
    
    // 定制进栈转场动画
    override var preferredEnterTransitionAnimator: MNTransitionAnimator? {
        return MNTransitionAnimator.animator(animation: .drawer)
    }
    
    // 定制出栈转场动画
    override var preferredLeaveTransitionAnimator: MNTransitionAnimator? {
        return MNTransitionAnimator.animator(animation: .drawer)
    }
    
    // 询问标签栏是否应该进入（显示）
    override func bottomBarShouldEnterTransitioning() -> Bool {
        return true
    }
    
    // 询问标签栏是否应该离开（隐藏）
    override func bottomBarShouldLeaveTransitioning() -> Bool {
        return true
    }
}
```

**转场样式说明**

普通转场（.normal）

- 仿系统转场动画
- 进栈：新视图从右侧滑入，旧视图向左移动并添加半透明黑色背景
- 出栈：当前视图向右滑出，旧视图从左侧滑入并移除半透明背景
- 适合大多数场景

抽屉式转场（.drawer）

- 远近切换效果
- 进栈：新视图从右侧滑入，旧视图缩放至 93%
- 出栈：当前视图向右滑出，旧视图从缩放状态恢复
- 适合需要突出层次感的场景

模态转场（.modal）

- 从底部滑入的模态样式
- 进栈：新视图从底部滑入，旧视图缩放至 93%
- 出栈：当前视图滑出到底部，旧视图从缩放状态恢复
- 适合需要模态感的场景

翻转转场（.flip）

- 3D 翻转效果
- 进栈：从右侧翻转
- 出栈：从左侧翻转
- 适合需要视觉冲击的场景

**标签栏动画说明**

无动画（.none）

- 标签栏不参与转场动画
- 适合不需要标签栏动画的场景

吸附效果（.adsorb）

- 标签栏吸附在底部
- 进栈时：标签栏截图添加到旧视图底部
- 出栈时：标签栏截图跟随旧视图恢复
- 适合大多数场景

移动效果（.move）

- 标签栏跟随转场移动
- 进栈时：标签栏截图从底部向上移动
- 出栈时：标签栏截图跟随旧视图向下移动
- 适合需要流畅移动效果的场景

**交互式转场**

模块自动支持交互式转场（手势返回），无需额外配置：

```swift
// 在控制器中控制是否允许交互式返回
class ViewController: UIViewController {
    
    override var preferredInteractiveTransitioning: Bool {
        // 返回 false 禁用交互式返回
        return true
    }
}
```

#### 📝 注意事项

- **转场代理**：转场代理会自动管理导航控制器的 delegate，无需手动设置。
- **交互式转场**：交互式转场使用系统的手势识别器，会自动处理手势冲突。
- **标签栏动画**：标签栏动画只在根控制器时生效，非根控制器不会触发标签栏动画。
- **自定义动画**：自定义动画需要继承 MNTransitionAnimator 并实现相应方法。
- **转场时长**：不同转场样式的默认时长不同，可以通过重写 duration 属性自定义。
- **内存管理**：转场代理使用关联对象存储，导航控制器释放时会自动清理。
- **转场背景色**：转场背景色可以通过 preferredTransitionBackgroundColor 自定义，默认为白色。
- **转场阴影**：转场阴影会自动添加和移除，无需手动管理。

### CollectionLayout

一套 `UICollectionView` 自定义布局解决方案，提供瀑布流布局和文字标签布局。支持纵向和横向两种方向，支持多列/多行布局，支持区头区尾视图，让复杂的集合视图布局变得简单高效。

#### ✨ 特性

- 🌊 **瀑布流布局**：支持纵向和横向两种方向的瀑布流布局，自动计算最短列/行
- 📐 **多列/多行**：支持自定义列数（纵向）或行数（横向），每个区可以设置不同的列数
- 🎨 **灵活配置**：支持自定义每个 item 的尺寸、间距、边距等
- 📊 **区头区尾**：支持区头视图和区尾视图，可自定义尺寸和边距
- 🏷️ **标签布局**：提供文字标签布局，支持自动换行和对齐方式
- 🔧 **代理定制**：通过代理方法可以精细控制每个区的布局参数
- 💪 **高性能**：使用缓存机制优化布局计算，支持大量数据
- 🚀 **易于使用**：简单的 API 设计，快速上手

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/CollectionLayout'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNCollectionLayout",
        dependencies: [
            .product(name: "MNCollectionLayout", package: "MNSwiftKit")
        ]
    )
]
```

纵向瀑布流

```swift
class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建瀑布流布局
        let layout = MNCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.numberOfColumns = 2  // 2列
        layout.minimumLineSpacing = 10  // 行间距
        layout.minimumInteritemSpacing = 10  // 列间距
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 100, height: 100)  // 默认 item 尺寸
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
}
```

横向瀑布流

```swift
let layout = MNCollectionViewFlowLayout()
layout.scrollDirection = .horizontal
layout.numberOfColumns = 3  // 3行（横向时表示行数）
layout.minimumLineSpacing = 10
layout.minimumInteritemSpacing = 10
layout.itemSize = CGSize(width: 100, height: 100)

collectionView.collectionViewLayout = layout
```

使用代理方法自定义布局

```swift
extension ViewController: MNCollectionViewDelegateFlowLayout {

    // 自定义每个 item 的尺寸
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 根据数据返回不同的尺寸
        if indexPath.item % 3 == 0 {
            return CGSize(width: 100, height: 150)
        } else {
            return CGSize(width: 100, height: 100)
        }
    }
    
    // 自定义每个区的列数
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: MNCollectionViewLayout, numberOfColumnsInSection section: Int) -> Int {
        if section == 0 {
            return 2  // 第一区2列
        } else {
            return 3  // 其他区3列
        }
    }
    
    // 自定义每个区的间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    // 自定义每个区的边距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
    }
}
```

添加区头区尾视图

```swift
// 设置区头区尾尺寸
layout.headerReferenceSize = CGSize(width: 0, height: 50)
layout.footerReferenceSize = CGSize(width: 0, height: 50)

// 或通过代理方法自定义
extension ViewController: UICollectionViewLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: section == 0 ? 60 : 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 40)
    }
}

// 注册区头区尾视图
collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
collectionView.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")

// 实现数据源方法
func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

    if kind == UICollectionView.elementKindSectionHeader {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        return header
    } else {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
        return footer
    }
}
```

**布局属性说明**

`MNCollectionViewLayout` 提供以下可配置属性：

- `itemSize`: 默认 item 尺寸（当代理方法未实现时使用）
- `minimumLineSpacing`: 滑动方向相邻表格间隔（纵向为行间距，横向为列间距）
- `minimumInteritemSpacing`: 滑动相反方向相邻表格间隔（纵向为列间距，横向为行间距）
- `headerReferenceSize`: 区头尺寸（纵向取高度，横向取宽度）
- `footerReferenceSize`: 区尾尺寸（纵向取高度，横向取宽度）
- `sectionInset`: 区边距
- `numberOfColumns`: 列数（纵向）或行数（横向），默认 3
- `preferredContentSize`: 预设内容内容尺寸（即最小的内容尺寸）

**代理方法说明**

`MNCollectionViewDelegateFlowLayout` 继承 `UICollectionViewDelegateFlowLayout` ，根据 `collectionView` 的 `dataSource` 转化。提供以下代理方法：

- `collectionView(_:layout:numberOfColumnsInSection:)`: 定制区列数/行数

**布局缓存**

布局对象提供了缓存机制，可以访问以下属性：

- `caches`: 区内每一列/行的高/宽缓存（`[[CGFloat]]`）
- `attributes`: 所有布局对象缓存（包括区头区尾）
- `headerAttributes`: 区头布局对象缓存（`[Int: UICollectionViewLayoutAttributes]`）
- `footerAttributes`: 区尾布局对象缓存（`[Int: UICollectionViewLayoutAttributes]`）
- `sectionAttributes`: 区布局对象缓存（`[[UICollectionViewLayoutAttributes]]`）

**文字标签布局**

`MNCollectionViewWordLayout` 是专门用于文字标签的布局，支持自动换行和对齐方式。

**性能优化**

布局对象使用缓存机制优化性能：

- **区块缓存**：将布局属性分组缓存，提高查找效率
- **列/行高度缓存**：缓存每列/行的高度，快速找到最短列/行
- **布局属性缓存**：缓存所有布局属性，避免重复计算

#### 📝 注意事项

- **代理设置**：如果 `delegate` 未设置，布局会自动尝试从 `collectionView.dataSource` 获取代理。
- **item 尺寸**：如果通过代理方法返回了 item 尺寸，布局会根据尺寸比例自动计算实际显示尺寸。如果尺寸为正方形，会使用计算出的宽度作为高度。
- **列数/行数**：`numberOfColumns` 在纵向布局时表示列数，在横向布局时表示行数。
- **最短列/行算法**：布局使用最短列/行算法来放置新的 item，确保布局均匀。
- **区头区尾**：区头区尾的尺寸在纵向布局时取高度，在横向布局时取宽度。
- **布局方向**：`MNCollectionViewFlowLayout` 支持 `.vertical`（纵向）和 `.horizontal`（横向）两种方向。
- **内容尺寸**：布局会自动计算内容尺寸，也可以通过 `preferredContentSize` 指定最小内容尺寸。
- **布局更新**：修改布局属性后会自动调用 `invalidateLayout()`，无需手动调用。
- **代理优先级**：代理方法的返回值优先级高于布局对象的属性值。
- **性能考虑**：对于大量数据，布局使用缓存机制优化性能，但首次布局计算仍需要遍历所有 item。
- **边界检查**：布局会自动处理边界情况，确保所有 item 都在可见区域内。
- **iOS 11+ 适配**：布局已适配 iOS 11+ 的 `contentInsetAdjustmentBehavior`。

### Networking

一个功能完整、易于使用的 Swift 网络请求库，基于 `URLSession` 封装，提供了简洁的 API 和强大的功能。

#### ✨ 特性

- **简洁的 API 设计**：提供 `get`、`post`、`head`、`delete` 等便捷方法
- **多种数据格式支持**：自动解析 JSON、XML、纯文本等多种响应格式
- **断点续传**：支持文件下载的断点续传功能（Range 请求）
- **上传/下载进度**：实时监控上传和下载进度
- **HTTPS 安全策略**：支持证书验证、公钥验证等多种安全策略
- **网络状态监测**：实时监测网络连接状态（WiFi、WWAN）和类型（2G/3G/4G/5G）
- **完善的错误处理**：详细的错误分类和错误信息
- **线程安全**：使用信号量保证多线程环境下的安全性

#### 📦 模块组成

- **MNNetworkSession**：核心会话管理类，提供所有网络请求功能
- **MNNetworkSerializer**：请求序列化器，处理参数编码和请求头设置
- **MNNetworkParser**：响应解析器，支持多种数据格式的自动解析
- **MNNetworkProxy**：请求代理，处理 URLSession 回调
- **MNNetworkError**：详细的错误定义和处理
- **MNNetworkSecurityPolicy**：HTTPS 安全策略配置
- **MNNetworkReachability**：网络可达性检测
- **MNNetworkParam**：参数编码工具
- **MNNetworkContentType**：内容类型枚举
- **MNNetworkDownloadOptions**：下载选项配置

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Networking'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNNetworking",
        dependencies: [
            .product(name: "MNNetworking", package: "MNSwiftKit")
        ]
    )
]
```

基本请求

```swift
// 创建会话实例
let session = MNNetworkSession()

// GET 请求
session.get(url: "https://api.example.com/data") { result in
    switch result {
    case .success(let data):
        print("请求成功: \(data)")
    case .failure(let error):
        print("请求失败: \(error.errMsg)")
    }
}

// POST 请求
session.post(url: "https://api.example.com/submit", completion: { result in
    // 处理结果
})
```

带参数的请求

```swift
let serializer = MNNetworkSerializer()
// URL 参数
serializer.param = ["page": 1, "limit": 20]
// 请求体
serializer.body = ["username": "user", "password": "pass"]
// 请求头
serializer.headerFields = ["Authorization": "Bearer token"]

let task = session.dataTask(
    url: "https://api.example.com/users",
    method: "POST",
    serializer: serializer
) { result in
    // 处理结果
}
task?.resume()
```

文件下载

```swift
let task = session.downloadTask(
    url: "https://example.com/file.zip",
    location: { response, url in
        // 返回文件保存路径
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("file.zip")
    },
    progress: { progress in
        print("下载进度: \(progress.fractionCompleted)")
    },
    completion: { result in
        switch result {
        case .success(let filePath):
            print("下载完成: \(filePath)")
        case .failure(let error):
            print("下载失败: \(error.errMsg)")
        }
    }
)
task?.resume()
```

文件上传

```swift
let task = session.uploadTask(
    url: "https://api.example.com/upload",
    method: "POST",
    body: {
        // 返回文件路径、URL 或 Data
        return "/path/to/file.jpg"
    },
    progress: { progress in
        print("上传进度: \(progress.fractionCompleted)")
    },
    completion: { result in
        switch result {
        case .success(let response):
            print("上传成功: \(response)")
        case .failure(let error):
            print("上传失败: \(error.errMsg)")
        }
    }
)
task?.resume()
```

任务管理

```swift
// 创建任务
let task = session.dataTask(url: "https://api.example.com/data", method: "GET") { result in
    // 处理结果
}

// 开始任务
task?.resume()

// 暂停任务
task?.suspend()

// 取消任务
task?.cancel()

// 继续下载任务（断点续传）
if let resumeData = // 获取 resumeData {
    let resumeTask = session.downloadTask(resumeData: resumeData, location: { _, _ in
        return fileURL
    }) { result in
        // 处理结果
    }
    resumeTask?.resume()
}
```

网络状态监测

```swift
let reachability = MNNetworkReachability.reachability
// 开始监测
reachability.start()
// 设置状态变化回调
reachability.updateHandler = { status in
    switch status {
    case .unreachable:
        print("网络不可达")
    case .wifi:
        print("WiFi 连接")
    case .wwan:
        print("移动网络: \(reachability.type.rawString)")
    }
}

// 监听通知
NotificationCenter.default.addObserver(
    forName: .networkReachabilityNotificationName,
    object: nil,
    queue: .main
) { notification in
    if let reachability = notification.object as? MNNetworkReachability {
        print("网络状态: \(reachability.statusString)")
        print("网络类型: \(reachability.typeString)")
    }
}

// 检查当前状态
if reachability.isReachable {
    if reachability.isWifiReachable {
        print("当前使用 WiFi")
    } else if reachability.isCellularReachable {
        print("当前使用移动网络: \(reachability.type.rawString)")
    }
}

// 停止监测
reachability.stop(
```

**编码类型支持**

模块支持以下内容编码：

```swift
- `.none`: 不做处理
- `.json`: JSON 数据
- `.plainText`: 纯文本
- `.plist`: Plist 数据
- `.xml`: XML 数据
- `.html`: HTML 数据
- `.formData`: 文件上传（multipart/form-data）
- `.binary`: 二进制数据
- `.formURLEncoded`: URL 编码数据
```

**错误码定义**

模块定义了详细的错误码常量，包括：

- `MNNetworkErrorUnknown`: 未知错误
- `MNNetworkErrorCancelled`: 请求取消
- `MNNetworkErrorNotConnectedToInternet`: 无网络连接
- `MNNetworkErrorBadUrl`: 链接无效
- `MNNetworkErrorCannotEncodeUrl`: 链接编码失败
- `MNNetworkErrorCannotEncodeBody`: 请求体编码失败
- `MNNetworkErrorBadServerResponse`: 无法解析服务端响应
- `MNNetworkErrorUnsupportedContentType`: 不支持的内容类型
- `MNNetworkErrorUnsupportedStatusCode`: 不支持的状态码
- `MNNetworkErrorZeroByteData`: 空数据
- `MNNetworkErrorCannotParseData`: 数据解析失败
- 更多错误码...

**线程安全**

模块内部使用信号量（`DispatchSemaphore`）保证线程安全，可以在多线程环境下安全使用。

#### 📝 注意事项

- **断点续传**：使用 `dataTask` 进行文件下载时，会自动支持断点续传。如果文件已存在且大小大于 0，会从断点处继续下载。
- **下载选项**：
   - `.createIntermediateDirectories`：自动创建中间目录
   - `.removeExistsFile`：删除已存在的文件，否则使用旧文件
- **网络监测**：网络可达性检测并不保证数据包一定会被主机接收到，仅表示网络路径是否可达。
- **HTTPS 验证**：建议在生产环境中使用证书或公钥验证模式，确保通信安全。
- **回调队列**：默认回调在主队列执行，可以通过 `completionQueue` 属性自定义回调队列。

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

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Request'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNRequest",
        dependencies: [
            .product(name: "MNRequest", package: "MNSwiftKit")
        ]
    )
]
```

GET 请求

```swift
let request = MNDataRequest(url: "https://api.example.com/users")
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

POST 请求

```swift
let request = MNDataRequest(url: "https://api.example.com/login")
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

带 Header 的请求

```swift
let request = MNDataRequest(url: "https://api.example.com/data")
request.headerFields = [
    "Authorization": "Bearer token123",
    "Content-Type": "application/json"
]
request.start(completion: { result in
    // 处理结果
})
```

请求缓存

```swift
let request = MNDataRequest(url: "https://api.example.com/data")
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

请求重试

```swift
let request = MNDataRequest(url: "https://api.example.com/data")
request.retyCount = 3  // 最多重试3次
request.retryInterval = 1.0  // 重试间隔1秒

request.start(completion: { result in
    // 处理结果
})
```

自定义解析

```swift
let request = MNDataRequest(url: "https://api.example.com/data")
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

文件上传

```swift
let request = MNUploadRequest(url: "https://api.example.com/upload")
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

多文件上传（使用 MNUploadAssistant）

```swift
let assistant = MNUploadAssistant(boundary: "Boundary-\(UUID().uuidString)")
assistant.append(name: "username", value: "user123")
assistant.append(image: image1, name: "avatar", filename: "avatar.jpg")
assistant.append(image: image2, name: "cover", filename: "cover.jpg")

let request = MNUploadRequest(url: "https://api.example.com/upload")
request.boundary = assistant.boundary
request.start(body: {
    return assistant.data
}, progress: { progress in
    print("上传进度：\(progress.fractionCompleted)")
}) { result in
    // 处理结果
}
```

文件下载

```swift
let request = MNDownloadRequest(url: "https://example.com/file.zip")
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

暂停和继续下载

```swift
let request = MNDownloadRequest(url: "https://example.com/file.zip")

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

文件下载（使用 MNFileDataRequest）

```swift
let request = MNFileDataRequest(url: "https://example.com/file.zip")
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

自定义回调队列

```swift
let request = MNDataRequest(url: "https://api.example.com/data")
request.queue = DispatchQueue.global(qos: .userInitiated)  // 自定义回调队列

request.start(completion: { result in
    // 在指定队列中回调
})
```

错误处理

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

取消请求

```swift
let request = MNDataRequest(url: "https://api.example.com/data")
request.start(completion: { result in
    // 处理结果
})

// 取消请求
request.cancel()
```

忽略特定错误码

```swift
let request = MNDataRequest(url: "https://api.example.com/data")
request.ignoringErrorCodes = [MNNetworkErrorCancelled]  // 忽略取消错误

request.start(completion: { result in
    // 取消错误不会触发回调
})
```

接受的状态码和内容类型

```swift
let request = MNDataRequest(url: "https://api.example.com/data")
request.acceptableStatusCodes = IndexSet(integersIn: 200..<300)  // 只接受 200-299
request.acceptableContentTypes = [.json, .plainText]  // 只接受 JSON 和纯文本

request.start(completion: { result in
    // 处理结果
})
```

网络缓存管理

```swift
// 写入缓存
MNRequestDatabase.default.setCache(data, forKey: "cache_key") { success in
    print("缓存写入：\(success)")
}

// 读取缓存
if let cache = MNRequestDatabase.default.cache(forKey: "cache_key", timeInterval: 3600) {
    print("读取缓存：\(cache)")
}

// 删除缓存
MNRequestDatabase.default.removeCache(forKey: "cache_key") { success in
    print("缓存删除：\(success)")
}

// 删除所有缓存
MNRequestDatabase.default.removeAll { success in
    print("清空缓存：\(success)")
}
```

继承 MNRequest 自定义请求

```swift
class CustomRequest: MNDataRequest {

    override func didSuccess(responseData: Any) {
        super.didSuccess(responseData: responseData)
        // 自定义成功处理逻辑
    }
    
    override func didFail(_ result: MNRequestResult) {
        super.didFail(result)
        // 自定义失败处理逻辑
    }
}
```

分页请求支持

```swift
class PagingRequest: MNDataRequest, MNPagingRequestSupported {

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

请求方法

`HTTPMethod` 枚举支持以下方法：
- `.get`: GET 请求
- `.post`: POST 请求
- `.put`: PUT 请求
- `.delete`: DELETE 请求
- `.head`: HEAD 请求

缓存策略

`CachePolicy` 枚举支持以下策略：
- `.never`: 不使用缓存
- `.returnCacheElseLoad`: 优先使用缓存，失败后请求网络
- `.returnCacheDontLoad`: 优先使用缓存，没有缓存或缓存过期则不加载

内容类型

`MNNetworkContentType` 枚举支持以下类型：
- `.none`: 不做处理
- `.json`: JSON 数据
- `.plainText`: 纯文本
- `.xml`: XML 数据
- `.html`: HTML 数据
- `.plist`: Plist 数据
- `.formData`: 文件上传
- `.formURLEncoded`: URL 编码数据
- `.binary`: 二进制数据

下载选项

`MNNetworkDownloadOptions` 支持以下选项：
- `.createIntermediateDirectories`: 自动创建中间目录
- `.removeExistsFile`: 删除已存在的文件

错误类型

`MNNetworkError` 提供了完善的错误类型：
- `requestSerializationFailure`: 请求序列化错误
- `responseParseFailure`: 响应解析错误
- `dataParseFailure`: 数据解析错误
- `uploadFailure`: 上传失败
- `downloadFailure`: 下载失败
- `httpsChallengeFailure`: HTTPS 挑战失败
- `custom`: 自定义错误

#### 📝 注意事项

- **线程安全**：所有回调都在主线程执行（除非指定了自定义队列），可以直接更新 UI。
- **内存管理**：请求对象会被强引用直到请求完成，无需担心提前释放。
- **缓存机制**：缓存基于 `SQLite` 数据库，默认路径为 `Documents/http_caches.sqlite`。
- **重试机制**：重试只对网络错误有效，不会对序列化错误、解析错误、取消操作进行重试。
- **断点续传**：`MNDownloadRequest` 支持断点续传，暂停后可以继续下载。
- **文件下载**：`MNFileDataRequest` 使用 DataTask 下载，适合小文件；`MNDownloadRequest` 使用 DownloadTask，支持断点续传，适合大文件。
- **参数编码**：参数会自动进行 URL 编码，支持字典、字符串等多种格式。
- **错误处理**：建议检查 `result.isSuccess` 判断请求是否成功，失败时查看 `result.msg` 获取错误信息。
- **网络检测**：可以使用 `MNNetworkReachability` 检测网络状态，但请求本身会自动处理网络错误。
- **并发请求**：模块支持多个请求并发执行，由 `URLSession` 统一管理。
- **请求取消**：取消请求会触发错误回调，错误码为 `MNNetworkErrorCancelled`。

### Database

一套基于 `SQLite3` 的轻量级数据库解决方案，提供简洁的 API 和强大的功能，支持模型自动映射、事务处理、异步操作等特性。无需编写 SQL 语句即可完成大部分数据库操作，让数据库操作变得简单高效。

#### ✨ 特性

- 🗄️ **SQLite3 基础**：基于 SQLite3，轻量级、高性能、零配置
- 🔒 **线程安全**：使用信号量机制保证多线程环境下的数据安全
- 🚀 **异步支持**：所有操作都支持同步和异步两种方式
- 🎯 **自动映射**：自动将 `Swift` 模型映射到数据库表结构，无需手动编写 SQL
- 📝 **协议支持**：支持 `MNTableColumnSupported` 协议自定义表字段
- 🔍 **灵活查询**：支持条件查询、模糊查询（前缀/后缀/包含）、排序、分页
- 📊 **聚合函数**：支持 SUM、AVG、MIN、MAX 等聚合函数
- 💾 **事务支持**：支持事务操作，保证数据一致性
- 🔐 **加密支持**：可选支持 SQLCipher 数据库加密
- 🎨 **类型丰富**：支持 integer、float、text、blob 四种数据类型
- 🔄 **自动处理**：自动处理枚举类型、可选类型等

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Database'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNDatabase",
        dependencies: [
            .product(name: "MNDatabase", package: "MNSwiftKit")
        ]
    )
]
```

初始化数据库

```swift
// 使用默认路径（/Documents/database.sqlite）
let database = MNDatabase.default

// 或指定自定义路径
let database = MNDatabase(path: "/path/to/your/database.sqlite")
```

定义数据模型

```swift
// 方式1：使用自动映射（推荐）
class User: MNTableRowInitializable {
    var name: String = ""
    var age: Int = 0
    var email: String = ""
    var score: Double = 0.0
    var avatar: Data = Data()
}

// 方式2：使用协议自定义字段
class User: MNTableRowInitializable, MNTableColumnSupported {
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

创建表

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

插入数据

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

查询数据

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

更新数据

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

删除数据

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

聚合函数

```swift
// 求和
if let sum = database.calculate(
    from: "users",
    field: "score",
    math: .sum,
    default: 0.0
) {
    print("总分：\(sum)")
}

// 平均值
if let avg = database.calculate(
    from: "users",
    field: "score",
    math: .avg,
    default: 0.0
) {
    print("平均分：\(avg)")
}

// 最大值
if let max = database.calculate(
    from: "users",
    field: "age",
    math: .max,
    default: 0
) {
    print("最大年龄：\(max)")
}

// 最小值
if let min = database.calculate(
    from: "users",
    field: "age",
    math: .min,
    default: 0
) {
    print("最小年龄：\(min)")
}
```

表管理

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

字典转 SQL 条件

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

模糊查询类型

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

数据类型

`MNTableColumn.FieldType` 支持四种数据类型：
  - `.integer`: 整数类型（Int、Int64、Bool 等）
  - `.float`: 浮点数类型（Double、Float、CGFloat 等）
  - `.text`: 字符串类型（String、NSString）
  - `.blob`: 二进制数据类型（Data、NSData）

协议支持

```swift
// MNTableColumnAssignment：自定义赋值逻辑
class CustomUser: MNTableRowInitializable, MNTableColumnAssignment {
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
- **模型要求**：数据模型必须实现 `MNTableRowInitializable` 协议（提供 init() 方法）。
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

### Player

一个音视频播放器组件，基于 AVPlayer 构建，支持本地文件播放。提供完整的播放控制、进度管理、缓冲监控、播放列表等功能。

#### ✨ 特性

- 🎵 **音视频播放**：支持音频和视频文件的播放
- 📁 **本地文件**：针对本地文件播放优化
- 📋 **播放列表**：支持多个文件的播放列表，可切换、前进、后退
- ⏯️ **播放控制**：支持播放、暂停、跳转、重播等操作
- 📊 **进度监控**：实时获取播放进度和缓冲进度
- 🔄 **自动播放**：支持播放结束后自动播放下一首
- 🎚️ **音量控制**：支持音量调节和播放速率控制
- 🎬 **视频渲染**：提供 `MNPlayView` 用于视频画面渲染
- 🔔 **状态回调**：完善的状态变化和事件回调
- 🎧 **音频会话**：自动管理音频会话，支持多种音频类别
- 🚨 **中断处理**：自动处理音频中断、耳机拔出等事件
- 🔊 **音效支持**：支持播放系统音效和震动
- 💪 **高性能**：使用缓存机制优化播放器实例管理

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Player'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNPlayer",
        dependencies: [
            .product(name: "MNPlayer", package: "MNSwiftKit")
        ]
    )
]
```

基础使用

```swift
class ViewController: UIViewController {

    @IBOutlet weak var playView: MNPlayView!
    var player: MNPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 创建播放器
        let videoURL = URL(fileURLWithPath: "/path/to/video.mp4")
        player = MNPlayer(urls: [videoURL])
        player.delegate = self
        
        // 设置播放视图
        playView.player = player.player
        
        // 设置视频渲染方式
        playView.videoGravity = .resizeAspect  // 或 .resizeAspectFill, .resize
        
        // 设置封面
        playView.coverView.image = UIImage(named: "video_cover")
        
        // 开始播放
        player.play()
    }
}

extension ViewController: MNPlayerDelegate {
    func playerDidPlayTimeInterval(_ player: MNPlayer) {
        // 更新进度条
        progressView.progress = player.progress
    }
    
    func playerDidPlayToEndTime(_ player: MNPlayer) {
        // 播放结束，隐藏封面
        playView.coverView.isHidden = true
    }
}
```

播放列表

```swift
// 创建播放列表
let urls = [
    URL(fileURLWithPath: "/path/to/audio1.mp3"),
    URL(fileURLWithPath: "/path/to/audio2.mp3"),
    URL(fileURLWithPath: "/path/to/audio3.mp3")
]
player = MNPlayer(urls: urls)
player.delegate = self

// 播放指定索引
player.play(index: 1)

// 播放下一首
player.playNext()

// 播放上一首
player.forward()

// 获取当前播放索引
let currentIndex = player.playIndex
```

播放列表管理

```swift
// 添加文件到播放列表
let newURL = URL(fileURLWithPath: "/path/to/new.mp3")
player.append(urls: [newURL])

// 插入文件到指定位置
player.insert(newURL, at: 1)

// 更新指定位置的播放地址
player.update(url: newURL, at: 0)

// 检查是否包含某个地址
if player.contains(newURL) {
    print("已包含该文件")
}

// 删除所有播放内容
player.removeAll()
```

自动播放下一首

```swift
extension ViewController: MNPlayerDelegate {
    // 询问是否播放下一项
    func playerShouldPlayNextItem(_ player: MNPlayer) -> Bool {
        // 返回 true 表示自动播放下一首
        return true
    }
}
```

自定义开始播放时间

```swift
extension ViewController: MNPlayerDelegate {
    // 询问从哪里开始播放
    func playerShouldPlayToBeginTime(_ player: MNPlayer) -> TimeInterval {
        // 从30秒开始播放
        return 30.0
    }
}
```

播放控制

```swift
// 播放
player.play()

// 暂停
player.pause()

// 重新播放
player.replay()

// 跳转到指定进度（0.0-1.0）
player.seek(progress: 0.5) { success in
    if success {
        print("跳转成功")
    }
}

// 跳转到指定秒数
player.seek(seconds: 30.0) { success in
    if success {
        print("跳转到30秒")
    }
}

// 设置播放速率（1.0 正常速度，2.0 两倍速）
player.rate = 1.5

// 设置音量（0.0-1.0）
player.volume = 0.8
```

播放信息

```swift
// 获取播放时长
let duration = player.duration

// 获取当前播放时间
let currentTime = player.timeInterval

// 获取播放进度（0.0-1.0）
let progress = player.progress

// 获取缓冲进度（0.0-1.0）
let buffer = player.buffer

// 是否正在播放
if player.isPlaying {
    print("正在播放")
}

// 当前播放状态
switch player.status {
case .idle: print("空闲")
case .playing: print("播放中")
case .pause: print("暂停")
case .finished: print("结束")
case .failed: print("失败")
}

// 当前播放地址
if let url = player.url {
    print("播放地址：\(url)")
}

// 播放列表数量
let count = player.count
```

点击事件

```swift
// 启用点击事件
playView.isTouchEnabled = true
playView.delegate = self

extension ViewController: MNPlayViewDelegate {
    // 点击事件
    func playViewTouchUpInside(_ playView: MNPlayView) {
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    // 询问是否响应点击
    func playView(_ playView: MNPlayView, shouldReceiveTouchAt location: CGPoint) -> Bool {
        // 可以根据点击位置决定是否响应
        return true
    }
}
```

错误处理

```swift
extension ViewController: MNPlayerDelegate {
    // 播放失败回调
    func player(_ player: MNPlayer, didPlayFail error: Error) {
        if let playError = error.asPlayError {
            switch playError {
            case .playFailed:
                print("播放失败")
            case .seekFailed(let desc):
                print("跳转失败：\(desc)")
            case .setCategoryFailed(let category):
                print("设置音频类别失败：\(category)")
            case .underlyingError(let error):
                print("底层错误：\(error)")
            }
        }
    }
}
```

**播放状态说明**

`MNPlayer.Status` 枚举定义了以下状态：

- `.idle`: 空闲状态，未开始播放
- `.playing`: 正在播放
- `.pause`: 暂停状态
- `.finished`: 播放结束
- `.failed`: 播放失败

**中断处理**

播放器会自动处理以下中断事件：

- 音频中断：其他应用播放音频时自动暂停，中断结束后可选择恢复
- 耳机拔出：耳机拔出时自动暂停
- 系统挂起：应用被系统挂起时自动暂停

**代理方法说明**

`MNPlayerDelegate` 提供以下代理方法（所有方法都是可选的）：

- `playerDidEndDecode(_:)`: 解码结束回调
- `playerDidPlayTimeInterval(_:)`: 播放时间回调（需要设置 periodicFrequency）
- `playerDidChangeStatus(_:)`: 播放状态改变回调
- `playerDidPlayToEndTime(_:)`: 播放结束回调
- `playerDidLoadTimeRanges(_:)`: 已加载时间范围回调
- `playerLikelyBufferEmpty(_:)`: 无缓冲内容回调
- `playerLikelyToKeepUp(_:)`: 已缓冲可以播放回调
- `playerPreparePlayItem(_:)`: 准备播放回调
- `playerShouldPlayNextItem(_:)`: 询问是否播放下一项（返回 true 自动播放下一首）
- `playerShouldStartPlaying(_:)`: 询问是否可以播放（返回 false 不自动播放）
- `playerShouldPlayToBeginTime(_:)`: 询问从哪里开始播放（返回开始播放的秒数）
- `player(_:didPlayFail:)`: 播放失败回调

#### 📝 注意事项

- **本地文件**：播放器专门针对本地文件优化，只支持 `file://` 协议的 URL。
- **文件存在性**：添加文件到播放列表时会自动检查文件是否存在，不存在的文件会被忽略。
- **音频会话**：播放器会自动管理音频会话，设置正确的音频类别。默认使用 `.playAndRecord` 类别。
- **后台播放**：如需支持后台播放，需要设置 `sessionCategory` 为 `.playback`，并在 `Info.plist` 中配置后台模式。
- **播放频率**：`periodicFrequency` 设置为 0 时不会触发时间回调，设置为 1 表示每秒回调一次。
- **播放器缓存**：启用 `isAllowsUsingCache` 可以缓存播放器实例，提高切换性能，但会占用更多内存。
- **状态管理**：播放器状态由内部管理，外部不应直接修改 status 属性。
- **跳转操作**：跳转操作是异步的，通过 `completion` 回调获取结果。
- **播放列表**：播放列表索引从 0 开始，播放结束后可以通过 `playerShouldPlayNextItem` 控制是否自动播放下一首。
- **中断处理**：播放器会自动处理音频中断、耳机拔出等事件，无需手动处理。
- **视频渲染**：`MNPlayView` 使用 `AVPlayerLayer` 作为底层图层，会自动适配视频尺寸。
- **封面视图**：封面视图默认显示在播放视图上方，播放时可以通过代码控制显示/隐藏。
- **内存管理**：播放器使用弱引用关联代理，无需担心循环引用。
- **线程安全**：所有播放操作都应在主线程执行，回调也在主线程执行。
- **错误处理**：播放失败时会通过 `player(_:didPlayFail:)` 回调通知，建议实现此方法处理错误。

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

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/MediaExport'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNMediaExport",
        dependencies: [
            .product(name: "MNMediaExport", package: "MNSwiftKit")
        ]
    )
]
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
let duration = MNMediaExportSession.seconds(for: "媒体文件路径")

// 从本地 URL 获取
let duration = MNMediaExportSession.seconds(for: videoURL)
```

获取视频尺寸

```swift
// 从文件路径获取
let size = MNMediaExportSession.naturalSize(for: "视频文件路径")

// 从本地 URL 获取
let size = MNMediaExportSession.naturalSize(for: videoURL)
```

获取视频截图

```swift
// 生成第5秒处的截图，若文件是音频则忽略时间，检查文件内封面输出
let image = MNMediaExportSession.generateImage(for: "视频路径", at: 5.0, maximum: CGSize(width: 300, height: 300))

let image = MNMediaExportSession.generateImage(for: videoURL, at: 5.0, maximum: CGSize(width: 300, height: 300))
```

**格式**

- 视频格式

  - `.mp4` - MPEG-4 视频（最常用）
  - `.m4v` - Apple 受保护的 MPEG-4 视频
  - `.mov` - QuickTime 电影
  - `.mobile3GPP` - 3GPP 视频

- 音频格式

  - `.m4a` - Apple 音频（最常用）
  - `.wav` - WAV 音频
  - `.caf` - Core Audio 格式
  - `.aiff` - AIFF 音频
  - `.aifc` - AIFC 音频

**输出质量**

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

### Purchase

用于处理 iOS 应用内购买（In-App Purchase）的模块。它基于 StoreKit 框架构建，提供了完整的购买流程管理、凭据校验、恢复购买等功能。模块采用单例模式，支持本地凭据缓存和自动重试机制，确保购买流程的可靠性和用户体验。

#### ✨ 特性

-  **购买流程**：完整的应用内购买流程管理
-  **恢复购买**：支持恢复已购买的项目
-  **凭据校验**：本地凭据缓存和服务器校验支持
-  **自动重试**：失败的凭据自动重试，可配置最大重试次数
-  **状态回调**：实时购买状态更新（加载中、支付中、校验中等）
-  **本地存储**：使用 `SQLite` 数据库缓存未校验的凭据
-  **错误处理**：完善的错误码和错误描述
-  **通知机制**：支持代理回调和通知中心两种方式获取结果
-  **事务管理**：自动管理交易事务的完成和清理

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Purchase'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNPurchase",
        dependencies: [
            .product(name: "MNPurchase", package: "MNSwiftKit")
        ]
    )
]
```

**设置代理（必需）**

实现 MNPurchaseDelegate 协议，用于校验凭据：

```swift
class ViewController: UIViewController, MNPurchaseDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置代理
        MNPurchaseManager.default.delegate = self
        
        // 开启内购监听（建议在 AppDelegate 中调用）
        MNPurchaseManager.default.becomeTransactionObserver()
    }
    
    // MARK: - MNPurchaseDelegate
    
    /// 校验内购凭据（必需实现）
    func purchaseManagerShouldCheckoutReceipt(_ receipt: MNPurchaseReceipt, resultHandler: @escaping (MNPurchaseResult.Code) -> Void) {
        // 将凭据发送到您的服务器进行校验
        // receipt.content 是 Base64 编码的凭据数据
        // receipt.product 是产品标识
        // receipt.transactionIdentifier 是交易标识
        
        // 示例：发送到服务器校验
        sendReceiptToServer(receipt.content) { success in
            if success {
                resultHandler(.succeed)  // 校验成功
            } else {
                resultHandler(.receiptInvalid)  // 校验失败
            }
        }
    }
    
    /// 内购结束回调（可选）
    func purchaseManagerDidFinishPurchasing(_ result: MNPurchaseResult) {
        print("内购结果: \(result.msg)")
    }
}
```

**发起购买**

```swift
// 购买产品
MNPurchaseManager.default.startPurchasing(
    "com.yourapp.productid",  // 产品 ID
    userInfo: "user123",       // 可选的用户信息
    status: { status, description in
        // 状态回调
        print("状态: \(description)")
        // status: .idle, .loading, .purchasing, .checking, .completed
    },
    completion: { result in
        // 完成回调
        if result.code == .succeed {
            print("购买成功！")
            if let receipt = result.receipt {
                print("产品: \(receipt.product)")
                print("价格: \(receipt.price)")
            }
        } else {
            print("购买失败: \(result.msg)")
        }
    }
)
```

**恢复购买**

```swift
MNPurchaseManager.default.startRestore(
    status: { status, description in
        print("恢复状态: \(description)")
    },
    completion: { result in
        if result.code == .succeed {
            print("恢复购买成功")
        } else {
            print("恢复失败: \(result.msg)")
        }
    }
)
```

**校验本地凭据**

```swift
// 校验所有本地未校验的凭据
MNPurchaseManager.default.startCheckout(
    status: { status, description in
        print("校验状态: \(description)")
    },
    completion: { result in
        print("校验结果: \(result.msg)")
    }
)

// 校验指定凭据
let receipt = MNPurchaseReceipt(receiptData: receiptData)
MNPurchaseManager.default.startCheckout(
    receipt,
    status: nil,
    completion: { result in
        // 处理结果
    }
)
```

**主要方法**

```swift
// 开启内购监听（必需，建议在 AppDelegate 中调用）
manager.becomeTransactionObserver()

// 发起购买
manager.startPurchasing(_ productId: String, 
                       userInfo: String?, 
                       status: MNPurchaseStatusHandler?, 
                       completion: @escaping MNPurchaseCompletionHandler)

// 恢复购买
manager.startRestore(status: MNPurchaseStatusHandler?, 
                    completion: @escaping MNPurchaseCompletionHandler)

// 校验本地凭据
manager.startCheckout(status: MNPurchaseStatusHandler?, 
                     completion: @escaping MNPurchaseCompletionHandler)

// 校验指定凭据
manager.startCheckout(_ receipt: MNPurchaseReceipt, 
                     status: MNPurchaseStatusHandler?, 
                     completion: @escaping MNPurchaseCompletionHandler)

// 恢复购买操作（用于恢复中断的购买流程）
manager.resumePurchasing(status: MNPurchaseStatusHandler?, 
                        completion: @escaping MNPurchaseCompletionHandler)
```

**MNPurchaseResult**

内购结果类。

```swift
public enum Code: Int {
    case succeed = 1                    // 成功
    case failed = 0                     // 失败
    case unknown = -1                   // 未知错误
    case none = -2                      // 无结果
    case busying = -3                   // 正在处理中
    case notAllowed = -4                // 不允许购买
    case notAvailable = -5              // 产品不可用
    case receiptInvalid = -6            // 凭据无效
    case priceInvalid = -7              // 价格无效
    case paymentInvalid = -8            // 支付无效
    case timedOut = -9                  // 超时
    case cloudDenied = -10              // 云服务拒绝
    case cancelled = -999               // 已取消
    case notConnectedToInternet = -1009  // 无网络连接
}
```

**MNPurchaseReceipt**

内购凭据模型。

```swift
var identifier: String                    // 凭据标识（时间戳）
var product: String                       // 产品标识
var price: Double                         // 价格
var userInfo: String?                     // 用户信息
var content: String                       // Base64 编码的凭据内容
var transactionIdentifier: String?        // 交易标识
var originalTransactionIdentifier: String? // 原始交易标识
var transactionDate: TimeInterval        // 交易时间
var originalTransactionDate: TimeInterval // 原始交易时间
var failCount: Int                        // 失败次数
var isLocal: Bool                         // 是否是本地凭据
var isRestore: Bool                       // 是否是恢复购买
```

**MNPurchaseRequest**

内购请求类。

```swift
// 请求类型
public enum Action {
    case purchase   // 购买
    case restore    // 恢复购买
    case checkout   // 校验凭据
}

// 状态
public enum Status {
    case idle       // 空闲
    case loading    // 加载中
    case purchasing // 支付中
    case checking   // 校验中
    case completed  // 已完成
}
```

**通知机制**

除了代理回调，模块还支持通过通知中心获取结果：

```swift
// 监听内购完成通知
NotificationCenter.default.addObserver(
    forName: MNPurchaseDidFinishNotification,
    object: nil,
    queue: .main
) { notification in
    if let result = notification.userInfo?[MNPurchaseResultNotificationKey] as? MNPurchaseResult {
        print("内购结果: \(result.msg)")
    }
}
```

**凭据校验流程**

- **购买完成**：系统返回交易凭据
- **本地缓存**：凭据保存到 SQLite 数据库
- **服务器校验**：调用 `purchaseManagerShouldCheckoutReceipt` 方法
- **校验结果**：
  - 成功：删除本地凭据，完成交易
  - 失败：更新失败次数，如果超过最大次数则删除
  - 网络错误：保留凭据，等待下次校验
  
**常见错误码**

| 错误码                            | 说明             | 建议                                              |
| :-------------------  | :---------  | :---------------------------- |
| `.succeed`                       | 成功             | 正常处理                                        |
| `.cancelled`                      | 用户取消      | 提示用户已取消                                |
| `.notAllowed`                   | 不允许购买    | 检查设备是否支持内购，是否在模拟器  |
| `.notConnectedToInternet` | 无网络          | 提示用户检查网络连接                       |
| `.receiptInvalid`                | 凭据无效       | 检查服务器校验逻辑                          |
| `.busying`                        | 正在处理       | 避免重复发起购买                             |
| `.none`                           | 无结果           | 检查产品 ID 是否正确                        |

#### 📝 注意事项

- **必需设置代理**：`purchaseManagerShouldCheckoutReceipt` 方法必须实现，否则凭据无法校验
- **开启监听**：在应用启动时调用 `becomeTransactionObserver()`，建议在 `AppDelegate` 中调用
- **服务器校验**：凭据必须在您的服务器端进行校验，不能仅依赖客户端
- **模拟器限制**：模拟器不支持应用内购买，会在回调中返回 `.notAllowed`
- **网络环境**：购买和校验需要网络连接，无网络时会返回相应错误码
- **凭据存储**：未校验的凭据会保存在本地 SQLite 数据库，路径为 `Documents/receipts.sqlite`
- **重试机制**：失败的凭据会自动重试，超过 `maxCheckoutCount` 次后会删除
- **事务管理**：模块会自动管理交易事务的完成，无需手动调用 `finishTransaction`

### Utility

一个功能丰富的工具类集合模块，提供了触觉反馈、通知中心、Apple 登录、二维码生成、权限请求、扫码、身份验证、弱引用代理、Web Clip 配置等常用工具功能。这些工具类封装了系统 API，提供了简洁易用的接口，让开发变得更加高效。

#### ✨ 特性

- 🔔 **触觉反馈**：支持通知反馈、冲击反馈、选择反馈和音频服务反馈
- 📢 **通知中心**：基于 `CFNotificationCenter` 的通知中心，支持本地和 Darwin 层通知
- 🍎 **Apple 登录**：封装 `ASAuthorizationController`，简化 Apple 登录流程
- 📱 **二维码生成**：支持自定义纠错等级、尺寸和颜色的二维码生成
- 💾 **数据存储**：`UserDefaults` 属性包装器，简化数据存储操作
- 🔐 **权限请求**：支持相册、相机、麦克风、IDFA 等权限请求
- 📷 **扫码功能**：支持实时扫描和图片识别二维码/条形码
- 🔒 **身份验证**：支持 TouchID/FaceID 本地身份验证
- 🔗 **弱引用代理**：避免循环引用的弱引用代理工具
- 📋 **Web Clip**：生成 Web Clip 配置文件，支持桌面快捷方式

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Utility'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNUtility",
        dependencies: [
            .product(name: "MNUtility", package: "MNSwiftKit")
        ]
    )
]
```

触觉反馈

```swift
// 通知反馈（成功/警告/错误）
HapticFeedback.Notification.success()
HapticFeedback.Notification.warning()
HapticFeedback.Notification.error()

// 冲击反馈（轻度/中度/重度）
HapticFeedback.Impact.light()
HapticFeedback.Impact.medium()
HapticFeedback.Impact.heavy()

// 选择反馈
HapticFeedback.Selection.changed()

// 音频服务反馈
HapticFeedback.AudioService.peek()      // peek 反馈
HapticFeedback.AudioService.pop()        // pop 反馈
HapticFeedback.AudioService.error()      // 错误反馈
HapticFeedback.AudioService.vibration()  // 震动反馈

// 通用震动反馈
HapticFeedback.vibration()
```

通知中心

```swift
// 获取本地通知中心
let localCenter = NotificationCenter.local

// 获取 Darwin 层通知中心（可跨 target 通知）
let darwinCenter = NotificationCenter.darwin

// 注册通知
localCenter.addObserver(self, selector: #selector(handleNotification(_:)), name: Notification.Name("CustomNotification"))

// 发送通知
localCenter.post(name: Notification.Name("CustomNotification"), object: nil, userInfo: ["key": "value"])

// 删除通知
localCenter.removeObserver(self, name: Notification.Name("CustomNotification"))
```

Apple 登录

```swift
let helper = AppleLoginHelper(window: view.window)
helper.login(in: view.window, success: { user, token, email in
    print("登录成功")
    print("用户ID: \(user)")
    print("Token: \(token)")
    print("邮箱: \(email)")
}) { error in
    print("登录失败: \(error.msg)")
}
```

二维码生成

```swift
// 生成二维码（默认尺寸 300x300，白色背景，黑色前景）
if let qrImage = MNQRCode.generate(with: "https://example.com", level: .medium) {
    imageView.image = qrImage
}

// 自定义尺寸和颜色
if let qrImage = MNQRCode.generate(
    with: "https://example.com",
    level: .high,  // 纠错等级：.low, .medium, .quartile, .higt
    size: CGSize(width: 200, height: 200),
    background: .white,
    foreground: .blue
) {
    imageView.image = qrImage
}
```

UserDefaults 属性包装器

```swift
class Settings {
    @MNUserDefaultsWrapper(key: "username", default: nil)
    var username: String?
    
    @MNUserDefaultsWrapper(key: "isFirstLaunch", default: true)
    var isFirstLaunch: Bool
    
    @MNUserDefaultsWrapper(suite: "group.com.yourapp", key: "sharedData", default: nil)
    var sharedData: String?
}

let settings = Settings()
settings.username = "John"
print(settings.username)  // "John"

// 使用 App Group
settings.sharedData = "Shared value"
```

权限请求

```swift
// 请求相册权限
MNPermission.requestAlbum { granted in
    if granted {
        print("相册权限已授予")
    }
}

// 请求相机权限
MNPermission.requestCamera { granted in
    if granted {
        print("相机权限已授予")
    }
}

// 请求麦克风权限（AVCaptureDevice）
MNPermission.requestMicrophone { granted in
    if granted {
        print("麦克风权限已授予")
    }
}

// 请求麦克风权限（AVAudioSession）
MNPermission.requestMicrophonePermission { granted in
    if granted {
        print("麦克风权限已授予")
    }
}

// 请求 IDFA 权限（iOS 14+）
MNPermission.requestTracking { granted in
    if granted {
        print("IDFA 权限已授予")
    }
}
```

扫码功能

```swift
class ViewController: UIViewController, MNScannerDelegate {
    
    var scanner: MNScanner!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner = MNScanner()
        scanner.delegate = self
        scanner.view = previewView  // 设置预览视图
        
        // 设置扫描区域（可选）
        scanner.rect = CGRect(x: 50, y: 100, width: 200, height: 200)
        
        // 准备扫描
        scanner.prepareRunning()
    }
    
    // 开始扫描
    func startScanning() {
        scanner.startRunning()
    }
    
    // 停止扫描
    func stopScanning() {
        scanner.stopRunning()
    }
    
    // 打开手电筒
    func openTorch() {
        scanner.openTorch()
    }
    
    // 关闭手电筒
    func closeTorch() {
        scanner.closeTorch()
    }
    
    // MARK: - MNScannerDelegate
    
    func scanner(_ scanner: MNScanner, didReadMetadata result: String) {
        print("扫描结果: \(result)")
        scanner.stopRunning()
    }
    
    func scanner(_ scanner: MNScanner, didUpdateBrightness value: Float) {
        // 根据亮度调整 UI
        if value < 0.1 {
            // 环境较暗，显示手电筒按钮
        }
    }
    
    func scanner(_ scanner: MNScanner, didFail error: Error) {
        print("扫描失败: \(error.localizedDescription)")
    }
}

// 识别图片中的二维码
MNScanner.readImageMetadata(image) { result in
    if let code = result {
        print("识别结果: \(code)")
    }
}
```

本地身份验证

```swift
// 检查是否支持生物验证
if MNLocalAuthentication.isSupportedAuthentication {
    print("支持 TouchID/FaceID")
}

// 检查是否支持 FaceID
if MNLocalAuthentication.isSupportedFaceAuthentication {
    print("支持 FaceID")
}

// 检查是否支持 TouchID
if MNLocalAuthentication.isSupportedTouchAuthentication {
    print("支持 TouchID")
}

// 开始验证
MNLocalAuthentication.evaluate(
    reason: "请验证身份以继续",
    cancelTitle: "取消",
    fallbackTitle: "使用密码",
    fallback: {
        // 回退到密码验证
        print("使用密码验证")
    }
) { success, message in
    if success {
        print("验证成功")
    } else {
        print("验证失败: \(message)")
    }
}
```

弱引用代理

```swift
class TimerTarget {
    func timerFired() {
        print("Timer fired")
    }
}

let target = TimerTarget()
let weakProxy = MNWeakProxy(target: target)

// 使用弱引用代理，避免循环引用
Timer.scheduledTimer(timeInterval: 1.0, target: weakProxy, selector: #selector(timerFired), userInfo: nil, repeats: true)
```

Web Clip 配置

```swift
// 创建 Web Clip 配置
let webClip = MNWebClip(
    name: "我的应用",
    icon: base64IconString,  // 图标 Base64 字符串
    uuid: UUID().uuidString,
    scheme: "myapp://",
    bundle: "com.yourapp.bundleid",
    allowsRemoveFromDestop: true
)

// 写入配置文件
let path = "/path/to/webclip.mobileconfig"
if webClip.write(toFile: path, uuid: UUID().uuidString, display: "WebClip描述文件", desc: "这是快捷启动方式") {
    print("配置文件创建成功")
}

// 或使用类方法直接创建
MNWebClip.createFile(
    atPath: path,
    name: "我的应用",
    icon: base64IconString,
    uuid: UUID().uuidString,
    scheme: "myapp://",
    bundle: "com.yourapp.bundleid",
    identifier: UUID().uuidString,
    title: "WebClip描述文件",
    desc: "这是快捷启动方式"
)
```

#### 📝 注意事项

- **触觉反馈**：触觉反馈功能需要 iPhone 7 及以上机型支持，低版本设备会自动降级为震动反馈。
- **通知中心**：Darwin 层通知中心可以跨 target 发送通知，适用于 App Extension 场景。
- **Apple 登录**：需要 iOS 13.0+ 系统支持，低版本系统会返回 .unavailable 错误。
- **二维码生成**：纠错等级越高，二维码越复杂，但容错能力越强。建议根据使用场景选择合适的等级。
- **权限请求**：权限请求需要在 Info.plist 中添加相应的权限说明，否则会被系统拒绝。
- **扫码功能**：扫码功能需要相机权限，会自动请求权限。扫描区域使用相对于预览视图的坐标。
- **身份验证**：身份验证失败时会自动处理锁定情况，可以再次触发以输入密码。
- **弱引用代理**：弱引用代理会自动转发消息到目标对象，目标对象释放后代理会失效。
- **Web Clip**：Web Clip 配置文件需要用户手动安装，安装后会在桌面创建快捷方式。

### Components

一个 UI 组件集合模块，提供了活动指示器、弹窗、按钮、日期选择器、菜单、数字键盘、扫描视图、密码视图、分段控制视图、开关、文本视图等常用 UI 组件。这些组件封装了常用的交互模式，提供了统一的接口和丰富的配置选项，让 UI 开发变得更加高效。

#### ✨ 特性

- 🎨 **活动指示器**：支持暗色和亮色两种样式，可自定义颜色、线条宽度、动画时长
- 💬 **弹窗视图**：支持 Alert 和 ActionSheet 两种样式，支持输入框、多按钮、键盘避让
- 🔘 **自定义按钮**：支持图片和文字多种布局方式，支持多状态样式
- 📅 **日期选择器**：支持年、月、日、时、分、秒多种组件，支持多语言、12/24 小时制
- 📋 **菜单弹窗**：支持箭头指向、多种动画、自定义样式
- 🔢 **数字键盘**：支持数字输入、小数点、删除、清空、完成等功能
- 📷 **扫描视图**：提供扫描框 UI，支持扫描线动画
- 🔐 **密码视图**：支持多种边框样式、明文/密文显示、自定义内容
- 📊 **分段控制**：支持滑块动画、多状态样式
- 🔄 **开关组件**：支持自定义颜色、动画效果
- 📝 **输入框**：支持占位符对齐、左/右视图、智能布局
- 📄 **文本视图**：支持占位符、自动高度调整

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Components'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNComponents",
        dependencies: [
            .product(name: "MNComponents", package: "MNSwiftKit")
        ]
    )
]
```

活动指示器

```swift
// 创建活动指示器
let indicator = MNActivityIndicatorView(style: .dark)
indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
indicator.color = .systemBlue
indicator.lineWidth = 2.0
indicator.duration = 1.0
indicator.hidesWhenStopped = true

// 开始动画
indicator.startAnimating()

// 停止动画
indicator.stopAnimating()

// 检查是否在动画
if indicator.isAnimating {
    print("正在动画中")
}
```

弹窗视图

```swift
// Alert 样式
let alert = MNAlertView(title: "提示", message: "确定要删除吗？", preferredStyle: .alert)
alert.addAction(title: "取消", style: .cancel) { action in
    print("取消")
}
alert.addAction(title: "删除", style: .destructive) { action in
    print("删除")
}
alert.show()

// ActionSheet 样式
let actionSheet = MNAlertView(title: "选择操作", message: nil, preferredStyle: .actionSheet)
actionSheet.addAction(title: "拍照", style: .default) { action in
    print("拍照")
}
actionSheet.addAction(title: "从相册选择", style: .default) { action in
    print("从相册选择")
}
actionSheet.addAction(title: "取消", style: .cancel) { action in
    print("取消")
}
actionSheet.show()

// 带输入框的弹窗
let alert = MNAlertView(title: "输入", message: "请输入您的姓名", preferredStyle: .alert)
alert.addTextField { textField in
    textField.placeholder = "姓名"
    textField.font = .systemFont(ofSize: 16)
}
alert.addAction(title: "确定", style: .default) { action in
    if let textField = alert.textField(at: 0) {
        print("输入的内容：\(textField.text ?? "")")
    }
}
alert.show()

// 关闭弹窗
alert.dismiss()

// 发送关闭通知
NotificationCenter.default.post(name: MNAlertCloseNotification, object: nil)
```

自定义按钮

```swift
// 创建按钮
let button = MNButton(frame: CGRect(x: 0, y: 0, width: 200, height: 44))

// 设置标题
button.setTitle("确定", for: .normal)
button.setTitle("已选中", for: .selected)

// 设置标题颜色
button.setTitleColor(.black, for: .normal)
button.setTitleColor(.white, for: .selected)

// 设置标题字体
button.setTitleFont(.systemFont(ofSize: 16, weight: .medium), for: .normal)

// 设置图片
button.setImage(UIImage(named: "icon"), for: .normal)
button.setImage(UIImage(named: "icon_selected"), for: .selected)

// 设置背景图片
button.setBackgroundImage(UIImage(named: "bg"), for: .normal)

// 设置图片位置
button.imageDistribution = .left  // 图片在左侧
// .right, .top, .bottom, .only, .none

// 设置图片与标题间距
button.spacing = 8.0

// 设置内容边距
button.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)

// 添加点击事件
button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
```

日期选择器

```swift
// 创建日期选择器
let datePicker = MNDatePicker(frame: CGRect(x: 0, y: 0, width: 300, height: 200))

// 设置日期格式
datePicker.dateFormat = MNDatePicker.Formater.chinese
    .year().separator("-")
    .month().separator("-")
    .day().separator(" ")
    .hour().separator(":")
    .minute()

// 或使用链式调用
datePicker.dateFormat = MNDatePicker.Formater.iso24
    .year().separator("-").abbr(false)
    .month().separator("-").lang(.chinese)
    .day().separator(" ")
    .hour().separator(":").clock(.iso12)
    .minute()

// 设置日期范围
datePicker.minimumDate = Date(timeIntervalSince1970: 0)
datePicker.maximumDate = Date()

// 设置当前日期
datePicker.setDate(Date(), animated: false)

// 获取选择的日期
let selectedDate = datePicker.date

// 自定义样式
datePicker.font = .systemFont(ofSize: 18, weight: .medium)
datePicker.textColor = .black
datePicker.rowHeight = 40.0
datePicker.spacing = 10.0
```

菜单弹窗

```swift
// 使用标题数组创建
let menu = MNPopoverView(titles: "分享", "收藏", "删除", options: MNPopoverConfiguration())
menu.show(in: view, target: button) { sender in
    print("点击了第 \(sender.tag) 个按钮")
}

// 使用自定义视图创建
let button1 = UIButton(type: .custom)
button1.setTitle("选项1", for: .normal)
let button2 = UIButton(type: .custom)
button2.setTitle("选项2", for: .normal)
let menu = MNPopoverView(arrangedViews: [button1, button2], options: MNPopoverConfiguration())

// 自定义配置
let options = MNPopoverConfiguration()
options.arrowDirection = .top  // 箭头方向
options.animationType = .zoom  // 动画类型
options.visibleColor = .darkGray
options.borderColor = .lightGray
options.borderWidth = 1.0
options.cornerRadius = 8.0
options.titleColor = .white
options.titleFont = .systemFont(ofSize: 16, weight: .medium)
options.arrowSize = CGSize(width: 12, height: 10)
options.arrowOffset = UIOffset(horizontal: 0, vertical: 0)
options.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
options.axis = .horizontal  // 布局方向
options.widthLayout = .longest(apped: 20)  // 宽度约束
options.heightLayout = .equal(40)  // 高度约束

let menu = MNPopoverView(titles: "选项1", "选项2", "选项3", options: options)
menu.show(in: view, target: button) { sender in
    print("点击了选项")
}

// 关闭菜单
menu.dismiss(animated: true) {
    print("菜单已关闭")
}

// 或通过视图扩展关闭
view.dismissMenu(animated: true)
```

数字键盘

```swift
// 创建数字键盘
let keyboard = MNNumberKeyboard()

// 自定义配置
var options = MNNumberKeyboard.Options()
options.decimalCapable = true  // 允许小数点
options.isScramble = false  // 是否乱序
options.leftKey = .clear  // 左下角按键
options.rightKey = .done  // 右下角按键
options.keyButtonHeight = 55.0
options.spacing = 1.5
options.textFont = .systemFont(ofSize: 20, weight: .medium)
options.textColor = .black
options.keyBackgroundColor = .white
options.keyHighlightedColor = .lightGray

let keyboard = MNNumberKeyboard(options: options)
keyboard.delegate = self

// 设置为输入视图
textField.inputView = keyboard

// 实现代理
extension ViewController: MNNumberKeyboardDelegate {
    func numberKeyboard(_ keyboard: MNNumberKeyboard, didInput key: MNNumberKeyboard.Key) {
        // 更新输入框文本
        textField.text = keyboard.text
    }
    
    func numberKeyboard(_ keyboard: MNNumberKeyboard, didClick key: MNNumberKeyboard.Key) {
        if key == .done {
            textField.resignFirstResponder()
        }
    }
}
```

扫描视图

```swift
// 创建扫描视图
let scanView = MNScanView(frame: view.bounds)
scanView.scanRect = CGRect(x: 50, y: 100, width: 250, height: 250)
scanView.image = UIImage(named: "scan_line")  // 扫描线图片
scanView.cornerSize = CGSize(width: 2, height: 15)
scanView.cornerColor = .white
scanView.borderWidth = 1.0
scanView.borderColor = .white
view.addSubview(scanView)

// 准备扫描
scanView.prepareScanning()

// 开始扫描动画
scanView.startScanning()

// 停止扫描动画
scanView.stopScanning()
```

密码视图

```swift
// 创建密码视图
let secureView = MNSecureView(frame: CGRect(x: 20, y: 100, width: 300, height: 50))
secureView.capacity = 6  // 6位密码
secureView.spacing = 10.0
secureView.axis = .horizontal

// 配置选项
secureView.options.borderStyle = .square  // 边框样式
secureView.options.textMode = .normal  // 文本模式
secureView.options.isSecureEntry = true  // 密文显示
secureView.options.textColor = .black
secureView.options.font = .systemFont(ofSize: 20, weight: .medium)
secureView.options.backgroundColor = .white
secureView.options.borderColor = .gray
secureView.options.highlightBorderColor = .systemBlue
secureView.options.borderWidth = 1.0
secureView.options.cornerRadius = 5.0

secureView.delegate = self
view.addSubview(secureView)

// 追加字符
secureView.append("1")
secureView.append("2")

// 删除一位
secureView.deleteBackward()

// 清空
secureView.removeAll()

// 获取密码
let password = secureView.text

// 实现代理
extension ViewController: MNSecureViewDelegate {
    func secureViewTouchUpInside(_ secureView: MNSecureView) {
        // 密码位被点击，可以弹出键盘输入
    }
}
```

分段控制器

```swift
// 创建分段控制器
let segmentedControl = MNSegmentedControl(items: ["选项1", "选项2", "选项3"])
segmentedControl.frame = CGRect(x: 20, y: 100, width: 200, height: 40)

// 设置样式
segmentedControl.segmentColor = .systemBlue
segmentedControl.segmentRadius = 5.0
segmentedControl.segmentHeight = 35.0
segmentedControl.contentInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
segmentedControl.itemSpacing = 18.0

// 设置文字属性
segmentedControl.setTitleTextAttributes([
    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
    .foregroundColor: UIColor.gray
], for: .normal)

segmentedControl.setTitleTextAttributes([
    .font: UIFont.systemFont(ofSize: 15, weight: .bold),
    .foregroundColor: UIColor.black
], for: .selected)

// 设置选中索引
segmentedControl.setSegmentIndex(1, animated: true)

// 添加事件
segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)

@objc func segmentedControlChanged() {
    print("选中索引：\(segmentedControl.selectedSegmentIndex)")
}
```

开关组件

```swift
// 创建开关
let switchControl = MNSwitch(frame: CGRect(x: 20, y: 100, width: 45, height: 26))
switchControl.onTintColor = .systemBlue
switchControl.thumbTintColor = .white
switchControl.tintColor = .lightGray

// 设置状态
switchControl.setOn(true, animated: true)

// 获取状态
if switchControl.isOn {
    print("开关已打开")
}

// 设置代理
switchControl.delegate = self

// 实现代理
extension ViewController: MNSwitchDelegate {
    func switchShouldChangeValue(_ switch: MNSwitch) -> Bool {
        // 是否允许改变值
        return true
    }
    
    func switchValueChanged(_ switch: MNSwitch) {
        print("开关状态：\(switch.isOn)")
    }
}
```

输入框

```swift
// 创建输入框
let textField = MNTextField(frame: CGRect(x: 20, y: 100, width: 300, height: 44))
textField.placeholder = "请输入内容"
textField.placeColor = .gray
textField.placeFont = .systemFont(ofSize: 16)
textField.placeAlignment = .left  // 占位符对齐方式

// 设置左视图
let leftView = UIImageView(image: UIImage(named: "icon"))
leftView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
textField.leftView = leftView
textField.leftViewMode = .always

// 设置右视图
let rightView = UIButton(type: .custom)
rightView.setTitle("清除", for: .normal)
rightView.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
textField.rightView = rightView
textField.rightViewMode = .whileEditing
```

#### 📝 注意事项

- **活动指示器**：指示器使用 `CAShapeLayer` 和遮罩实现，支持暂停和继续动画。
- **弹窗视图**：弹窗会自动处理键盘避让，支持多个弹窗堆叠显示。
- **自定义按钮**：按钮支持 `normal`、`highlighted`、`selected`、`disabled` 四种状态。
- **日期选择器**：日期选择器会根据年月自动调整天数，支持 12/24 小时制切换。
- **菜单弹窗**：菜单弹窗支持四种箭头方向，三种动画类型，自动计算位置。
- **数字键盘**：数字键盘支持乱序排列，可以自定义左右下角按键类型。
- **扫描视图**：扫描视图需要提供扫描线图片，支持开始和停止动画。
- **密码视图**：密码视图支持多种边框样式，支持明文和密文显示。
- **分段控制器**：分段控制器支持滑块动画，自动计算尺寸。
- **开关组件**：开关组件支持自定义颜色，动画效果流畅。
- **输入框**：输入框支持占位符对齐，智能处理左/右视图显示。
- **内存管理**：所有代理都使用弱引用，无需担心循环引用。

### Extension

一个功能丰富的扩展模块，为 iOS 开发中常用的系统类型提供了大量便捷的扩展方法。通过 `.mn` 命名空间，为 `String`、`Array`、`Date`、`UIColor`、`UIImage`、`UIView`、`UIViewController`、`FileManager`、`UIDevice` 等类型提供了实用的工具方法，让日常开发更加高效便捷。

#### ✨ 特性

- 🔤 **字符串扩展**：类型转换、文本尺寸计算、MD5 加密、路径操作、下标访问、字符串反转等
- 📦 **数组扩展**：元素遍历、按容量分组等
- 📅 **日期扩展**：时间戳（秒/毫秒）、格式化字符串、播放时间格式化等
- 🎨 **颜色扩展**：十六进制颜色、RGB 颜色、随机颜色、反色、颜色转十六进制等
- 🖼️ **图片扩展**：纯色图片、灰度图、方向调整、颜色渲染、裁剪、尺寸调整、压缩、文件写入等
- 👁️ **视图扩展**：锚点设置、截图、移除子视图、内容图片等
- 🎮 **控制器扩展**：智能弹出、添加/移除子控制器、获取当前控制器等
- 📁 **文件管理扩展**：磁盘容量、文件大小计算、创建/复制/移动/删除文件等
- 📱 **设备扩展**：系统版本、越狱检测、设备型号识别、设备旋转等
- 📲 **应用扩展**：打开链接、打开 QQ/QQ 群、打开评分、状态栏信息获取等
- 🎬 **图层扩展**：动画控制（暂停/继续/重置）、截图、圆角设置、摆动/摇动动画等
- 🔧 **其他扩展**：按钮/标签尺寸适配、对象关联属性、方法交换、Nib 加载、数值格式化等

#### 🚀 快速开始

Cocoapods 安装：

```ruby
// Podfile 文件
pod 'MNSwiftKit/Extension'
```

SPM 安装：

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/panhub/MNSwiftKit.git", from: "版本号")
],
targets: [
    .target(
        name: "MNExtension",
        dependencies: [
            .product(name: "MNExtension", package: "MNSwiftKit")
        ]
    )
]
```

#### 📝 注意事项

- **命名空间**：所有扩展都通过 `.mn` 命名空间访问，避免与系统方法冲突。
- **内存管理**：图片压缩、文件操作等可能涉及大量内存，注意内存管理。
- **路径处理**：文件路径操作支持相对路径和绝对路径，注意路径的正确性。
- **设备信息**：设备型号识别可能无法覆盖所有新设备，需要定期更新。
- **越狱检测**：越狱检测方法可能被绕过，仅作为参考。
- **方法交换**：方法交换（Swizzle）需要谨慎使用，避免影响系统行为。
- **关联属性**：关联属性使用 `OBJC_ASSOCIATION_RETAIN_NONATOMIC` 策略，注意循环引用。
- **图片压缩**：图片压缩算法参考微信朋友圈，实际效果可能因图片而异。
- **一次性执行**：`DispatchQueue.once` 使用文件、函数、行号生成唯一 token，确保只执行一次。

## 示例

要运行示例项目，克隆repo，从 `Example` 目录运行 `pod install`。

## 作者

panhub, fengpann@163.com

## 许可

`MNSwiftKit` 在MIT许可下可用，更多信息请参见`LICENSE`文件。
