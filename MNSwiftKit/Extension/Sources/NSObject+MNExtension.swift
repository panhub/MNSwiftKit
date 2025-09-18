//
//  NSObject+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/9/18.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import ObjectiveC.runtime

extension NSObject {
    
    /// 关联属性
    fileprivate struct MNAssociatedKey {
        
        /// 关联用户自定义信息
        nonisolated(unsafe) static var userInfo: String = "com.mn.object.user.info"
        
        /// 第一次关联
        nonisolated(unsafe) static var first: String = "com.mn.object.first.associated"
    }
    
    /// 包装器
    fileprivate class MNAssociationLitted: NSObject {
        
        let value: Any
        
        init(value: Any) {
            self.value = value
        }
        
        init(_ value: Any) {
            self.value = value
        }
    }
}

extension NameSpaceWrapper where Base: NSObject {
    
    /// 关联信息
    public var userInfo: Any? {
        set {
            if let newValue = newValue {
                let association = NSObject.MNAssociationLitted(value: newValue)
                objc_setAssociatedObject(base, &NSObject.MNAssociatedKey.userInfo, association, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &NSObject.MNAssociatedKey.userInfo, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            guard let association = objc_getAssociatedObject(base, &NSObject.MNAssociatedKey.userInfo) as? NSObject.MNAssociationLitted else { return nil }
            return association.value
        }
    }
    
    /// 是否第一次关联
    public var isFirstAssociated: Bool {
        if let _ = objc_getAssociatedObject(base, &NSObject.MNAssociatedKey.first) { return false }
        objc_setAssociatedObject(base, &NSObject.MNAssociatedKey.first, true, .OBJC_ASSOCIATION_ASSIGN)
        return true
    }
}

extension NameSpaceWrapper where Base: NSObject {
    
    /// 替换实例方法
    /// - Parameters:
    ///   - aSelector: 原方法
    ///   - newSelector: 替换的新方法
    @discardableResult
    public static func swizzleMethod(_ aSelector: Selector, with newSelector: Selector) -> Bool {
        guard let originalMethod = class_getInstanceMethod(Base.self, aSelector) else { return false }
        guard let replaceMethod = class_getInstanceMethod(Base.self, newSelector) else { return false }
        if class_addMethod(Base.self, aSelector, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod)) {
            class_replaceMethod(Base.self, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, replaceMethod)
        }
        return true
    }
    
    /// 替换类方法
    /// - Parameters:
    ///   - aSelector: 原方法
    ///   - newSelector: 替换方法
    @discardableResult
    public static func swizzleClassMethod(_ aSelector: Selector, with newSelector: Selector) -> Bool {
        // 类方法列表存放在元类里, 这里要获取元类
        guard let metaClass = objc_getMetaClass(object_getClassName(Base.self)) as? AnyClass else { return false }
        guard let originalMethod = class_getClassMethod(metaClass, aSelector) else { return false }
        guard let replaceMethod = class_getClassMethod(metaClass, newSelector) else { return false }
        if class_addMethod(metaClass, aSelector, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod)) {
            class_replaceMethod(metaClass, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, replaceMethod)
        }
        return true
    }
}
