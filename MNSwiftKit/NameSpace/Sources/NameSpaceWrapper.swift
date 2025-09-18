//
//  NameSpace.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/11.
//  MNSwiftKit命名空间

import Foundation
import ObjectiveC.runtime

/// 命名空间 后续扩展即可
public class NameSpaceWrapper<Base> {
    internal let base: Base
    public init(base: Base) {
        self.base = base
    }
}

/// 命名空间支持
public protocol NameSpaceConvertible {
    
    associatedtype NameSpaceBase
    
    /// 实例构造MNSwiftKit命名空间入口
    var mn: NameSpaceWrapper<NameSpaceBase> { get }
    
    /// 非实例构造MNSwiftKit命名空间入口
    static var mn: NameSpaceWrapper<NameSpaceBase>.Type { get }
}

/// 为命名空间添加属性
extension NameSpaceConvertible {
    
    /// 实例的MNSwiftKit命名空间
    public var mn: NameSpaceWrapper<Self> { NameSpaceWrapper<Self>(base: self) }
    
    /// 非实例的MNSwiftKit命名空间
    public static var mn: NameSpaceWrapper<Self>.Type { NameSpaceWrapper<Self>.self }
}

/// 为URL添加`MNSwiftKit`命名空间
extension URL: NameSpaceConvertible {}

/// 为Data添加`MNSwiftKit`命名空间
extension Data: NameSpaceConvertible {}

/// 为Date添加`MNSwiftKit`命名空间
extension Date: NameSpaceConvertible {}

/// 为Array添加`MNSwiftKit`命名空间
extension Array: NameSpaceConvertible {}

/// 为String添加`MNSwiftKit`命名空间
extension String: NameSpaceConvertible {}

/// 为CGRect添加`MNSwiftKit`命名空间
extension CGRect: NameSpaceConvertible {}

/// 为Calendar添加`MNSwiftKit`命名空间
extension Calendar: NameSpaceConvertible {}

/// 为UIView.ContentMode添加`MNSwiftKit`命名空间
extension UIView.ContentMode: NameSpaceConvertible {}

/// 为CALayerContentsGravity添加`MNSwiftKit`命名空间
extension CALayerContentsGravity: NameSpaceConvertible {}

/// 为Objective-C对象添加`MNSwiftKit`命名空间
extension NSObject: NameSpaceConvertible {}
