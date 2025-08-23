//
//  MNNameSpace.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/11.
//  定义命名空间

import Foundation
import ObjectiveC.runtime

/// 命名空间 后续扩展即可
public class NameSpaceWrapper<Base> {
    internal let base: Base
    public init(base: Base) {
        self.base = base
    }
}

/// 支持命名空间的协议
public protocol NameSpaceConvertible {
    
    associatedtype NameSpaceBase
    
    var mn: NameSpaceWrapper<NameSpaceBase> { get }
    
    static var mn: NameSpaceWrapper<NameSpaceBase>.Type { get }
}

/// 为命名空间添加属性
extension NameSpaceConvertible {
    
    public var mn: NameSpaceWrapper<Self> { NameSpaceWrapper<Self>(base: self) }
    
    public static var mn: NameSpaceWrapper<Self>.Type { NameSpaceWrapper<Self>.self }
}

/// 为NSObject添加`mn`命名空间
extension NSObject: NameSpaceConvertible {}

/// 关联属性
public struct MNAssociatedKey {}

extension MNAssociatedKey {
    
    /// 关联用户自定义信息
    fileprivate static var userInfo: String = "com.mn.object.user.info"
    
    /// 第一次关联
    fileprivate static var firstAssociated: String = "com.mn.object.first.associated"
}

/// 关联对象包装器
public class MNAssociationLitted {
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
