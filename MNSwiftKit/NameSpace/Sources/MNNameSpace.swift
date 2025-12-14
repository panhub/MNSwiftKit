//
//  MNNameSpace.swift
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
public class MNNameSpaceWrapper<Base> {
    /// 元对象
    public let base: Base
    
    /// 构建命名空间
    /// - Parameter base: 元对象
    public init(base: Base) {
        self.base = base
    }
}

/// 命名空间支持
public protocol MNNameSpaceSupported {
    
    associatedtype Base
    
    /// 实例构造MNSwiftKit命名空间入口
    var mn: MNNameSpaceWrapper<Base> { get }
    
    /// 非实例构造MNSwiftKit命名空间入口
    static var mn: MNNameSpaceWrapper<Base>.Type { get }
}

/// 为命名空间添加属性
extension MNNameSpaceSupported {
    
    /// 实例的MNSwiftKit命名空间
    public var mn: MNNameSpaceWrapper<Self> { MNNameSpaceWrapper<Self>(base: self) }
    
    /// 非实例的MNSwiftKit命名空间
    public static var mn: MNNameSpaceWrapper<Self>.Type { MNNameSpaceWrapper<Self>.self }
}

/// 为Int添加`MNSwiftKit`命名空间
extension Swift.Int: MNNameSpaceSupported {}

/// 为UInt添加`MNSwiftKit`命名空间
extension Swift.UInt: MNNameSpaceSupported {}

/// 为Int64添加`MNSwiftKit`命名空间
extension Swift.Int64: MNNameSpaceSupported {}

/// 为UInt64添加`MNSwiftKit`命名空间
extension Swift.UInt64: MNNameSpaceSupported {}

/// 为Int64添加`MNSwiftKit`命名空间
extension Swift.Int32: MNNameSpaceSupported {}

/// 为UInt64添加`MNSwiftKit`命名空间
extension Swift.UInt32: MNNameSpaceSupported {}

/// 为URL添加`MNSwiftKit`命名空间
extension Foundation.URL: MNNameSpaceSupported {}

/// 为Data添加`MNSwiftKit`命名空间
extension Foundation.Data: MNNameSpaceSupported {}

/// 为Date添加`MNSwiftKit`命名空间
extension Foundation.Date: MNNameSpaceSupported {}

/// 为Array添加`MNSwiftKit`命名空间
extension Swift.Array: MNNameSpaceSupported {}

/// 为String添加`MNSwiftKit`命名空间
extension Swift.String: MNNameSpaceSupported {}

/// 为CGSize添加`MNSwiftKit`命名空间
extension CoreFoundation.CGSize: MNNameSpaceSupported {}

/// 为CGRect添加`MNSwiftKit`命名空间
extension CoreFoundation.CGRect: MNNameSpaceSupported {}

/// 为Calendar添加`MNSwiftKit`命名空间
extension Foundation.Calendar: MNNameSpaceSupported {}

/// 为Objective-C对象添加`MNSwiftKit`命名空间
extension NSObject: MNNameSpaceSupported {}

/// 为UIView.ContentMode添加`MNSwiftKit`命名空间
extension UIKit.UIView.ContentMode: MNNameSpaceSupported {}

/// 为CALayerContentsGravity添加`MNSwiftKit`命名空间
extension QuartzCore.CALayerContentsGravity: MNNameSpaceSupported {}
