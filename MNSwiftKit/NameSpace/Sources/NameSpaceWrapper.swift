//
//  NameSpace.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/11.
//  MNSwiftKit命名空间支持

import UIKit
import Foundation
import QuartzCore
import CoreFoundation
import ObjectiveC.runtime

/// MNSwiftKit命名空间
public class NameSpaceWrapper<Base> {
    /// 元对象
    public let base: Base
    
    /// 构建命名空间
    /// - Parameter base: 元对象
    public init(base: Base) {
        self.base = base
    }
}

/// 命名空间支持
public protocol NameSpaceSupported {
    
    associatedtype Base
    
    /// 实例构造MNSwiftKit命名空间入口
    var mn: NameSpaceWrapper<Base> { get }
    
    /// 非实例构造MNSwiftKit命名空间入口
    static var mn: NameSpaceWrapper<Base>.Type { get }
}

/// 为命名空间添加属性
extension NameSpaceSupported {
    
    /// 实例的MNSwiftKit命名空间
    public var mn: NameSpaceWrapper<Self> { NameSpaceWrapper<Self>(base: self) }
    
    /// 非实例的MNSwiftKit命名空间
    public static var mn: NameSpaceWrapper<Self>.Type { NameSpaceWrapper<Self>.self }
}

/// 为Int添加`MNSwiftKit`命名空间
extension Swift.Int: NameSpaceSupported {}

/// 为UInt添加`MNSwiftKit`命名空间
extension Swift.UInt: NameSpaceSupported {}

/// 为Int64添加`MNSwiftKit`命名空间
extension Swift.Int64: NameSpaceSupported {}

/// 为UInt64添加`MNSwiftKit`命名空间
extension Swift.UInt64: NameSpaceSupported {}

/// 为Int64添加`MNSwiftKit`命名空间
extension Swift.Int32: NameSpaceSupported {}

/// 为UInt64添加`MNSwiftKit`命名空间
extension Swift.UInt32: NameSpaceSupported {}

/// 为URL添加`MNSwiftKit`命名空间
extension Foundation.URL: NameSpaceSupported {}

/// 为Data添加`MNSwiftKit`命名空间
extension Foundation.Data: NameSpaceSupported {}

/// 为Date添加`MNSwiftKit`命名空间
extension Foundation.Date: NameSpaceSupported {}

/// 为Array添加`MNSwiftKit`命名空间
extension Swift.Array: NameSpaceSupported {}

/// 为String添加`MNSwiftKit`命名空间
extension Swift.String: NameSpaceSupported {}

/// 为CGSize添加`MNSwiftKit`命名空间
extension CoreFoundation.CGSize: NameSpaceSupported {}

/// 为CGRect添加`MNSwiftKit`命名空间
extension CoreFoundation.CGRect: NameSpaceSupported {}

/// 为Calendar添加`MNSwiftKit`命名空间
extension Foundation.Calendar: NameSpaceSupported {}

/// 为Objective-C对象添加`MNSwiftKit`命名空间
extension NSObject: NameSpaceSupported {}

/// 为UIView.ContentMode添加`MNSwiftKit`命名空间
extension UIKit.UIView.ContentMode: NameSpaceSupported {}

/// 为CALayerContentsGravity添加`MNSwiftKit`命名空间
extension QuartzCore.CALayerContentsGravity: NameSpaceSupported {}
