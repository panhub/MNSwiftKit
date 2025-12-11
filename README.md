# MNSwiftKit

[![CI Status](https://img.shields.io/travis/panhub/MNSwiftKit.svg?style=flat)](https://travis-ci.org/mellow/MNSwiftKit)
[![Version](https://img.shields.io/cocoapods/v/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)
[![License](https://img.shields.io/cocoapods/l/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)
[![Platform](https://img.shields.io/cocoapods/p/MNSwiftKit.svg?style=flat)](https://cocoapods.org/pods/MNSwiftKit)

## 要求

- iOS 9.0+ | Swift 5.0
- Xcode 12

## 安装

### CocoaPods (iOS 9+, Swift 5+)

MNSwiftKit可以通过[CocoaPods](https://cocoapods.org)安装，只需添加以下行到您的Podfile:

```ruby
pod 'MNSwiftKit'
```
或按需添加以下一个或多个命令行到您的Podfile:

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

同时也可以通过在您的Package.swift文件中添加适当的描述使用[Swift软件包管理器](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/)来安装`MNSwiftKit`：

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

要在项目中手动使用此库，您可以将`MNSwiftKit`文件夹整个拖入项目。

## 示例

要运行示例项目，克隆repo，从Example目录运行`pod install`。

## 作者

panhub, fengpann@163.com

## 许可证

MNSwiftKit在MIT许可下可用，更多信息请参见LICENSE文件。
