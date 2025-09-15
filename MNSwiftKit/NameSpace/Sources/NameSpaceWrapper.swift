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

/// 为Objective-C对象添加`MNSwiftKit`命名空间
extension NSObject: NameSpaceConvertible {}

/// 关联属性
public struct MNAssociatedKey {
    
    /// 关联用户自定义信息
    nonisolated(unsafe) fileprivate static var userInfo: String = "com.mn.object.user.info"
    
    /// 第一次关联
    nonisolated(unsafe) fileprivate static var firstAssociated: String = "com.mn.object.first.associated"
}

/// 关联对象包装器
public class MNAssociationLitted: NSObject {
    public let value: Any
    public init(value: Any) {
        self.value = value
    }
    public init(_ value: Any) {
        self.value = value
    }
}

extension NameSpaceWrapper where Base: NSObject {
    
    /// 关联用户保存的变量
    public var userInfo: Any? {
        set {
            if let newValue = newValue {
                let association = MNAssociationLitted(value: newValue)
                objc_setAssociatedObject(base, &MNAssociatedKey.userInfo, association, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &MNAssociatedKey.userInfo, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            guard let association = objc_getAssociatedObject(base, &MNAssociatedKey.userInfo) as? MNAssociationLitted else { return nil }
            return association.value
        }
    }
    
    /// 是否第一次关联
    public var isFirstAssociated: Bool {
        if let _ = objc_getAssociatedObject(base, &MNAssociatedKey.firstAssociated) { return false }
        objc_setAssociatedObject(base, &MNAssociatedKey.firstAssociated, true, .OBJC_ASSOCIATION_ASSIGN)
        return true
    }
}
