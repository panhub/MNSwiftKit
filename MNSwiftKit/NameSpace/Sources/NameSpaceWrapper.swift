//
//  NameSpace.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/11.
//  MNSwiftKit命名空间支持

import UIKit
import Foundation
import CoreGraphics
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
extension Int: NameSpaceSupported {}

/// 为UInt添加`MNSwiftKit`命名空间
extension UInt: NameSpaceSupported {}

/// 为Int64添加`MNSwiftKit`命名空间
extension Int64: NameSpaceSupported {}

/// 为UInt64添加`MNSwiftKit`命名空间
extension UInt64: NameSpaceSupported {}

/// 为Int64添加`MNSwiftKit`命名空间
extension Int32: NameSpaceSupported {}

/// 为UInt64添加`MNSwiftKit`命名空间
extension UInt32: NameSpaceSupported {}

/// 为URL添加`MNSwiftKit`命名空间
extension URL: NameSpaceSupported {}

/// 为Data添加`MNSwiftKit`命名空间
extension Data: NameSpaceSupported {}

/// 为Date添加`MNSwiftKit`命名空间
extension Date: NameSpaceSupported {}

/// 为Array添加`MNSwiftKit`命名空间
extension Array: NameSpaceSupported {}

/// 为String添加`MNSwiftKit`命名空间
extension String: NameSpaceSupported {}

/// 为CGSize添加`MNSwiftKit`命名空间
extension CGSize: NameSpaceSupported {}

/// 为CGRect添加`MNSwiftKit`命名空间
extension CGRect: NameSpaceSupported {}

/// 为Calendar添加`MNSwiftKit`命名空间
extension Calendar: NameSpaceSupported {}

/// 为Objective-C对象添加`MNSwiftKit`命名空间
extension NSObject: NameSpaceSupported {}

/// 为UIView.ContentMode添加`MNSwiftKit`命名空间
extension UIView.ContentMode: NameSpaceSupported {}

/// 为CALayerContentsGravity添加`MNSwiftKit`命名空间
extension CALayerContentsGravity: NameSpaceSupported {}
