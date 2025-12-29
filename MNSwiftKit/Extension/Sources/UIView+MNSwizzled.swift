//
//  UIView+MNSwizzled.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/9/20.
//  视图交换方法

import UIKit
import Foundation
import ObjectiveC.runtime

extension UIView {
    
    fileprivate struct MNTouchAssociated {
        
        nonisolated(unsafe) static var key: Void?
        
        nonisolated(unsafe) static var exchanged: Void?
    }
    
    @objc fileprivate func mn_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard alpha >= 0.01 else { return false }
        guard isHidden == false else { return false }
        guard isUserInteractionEnabled else { return false }
        return bounds.inset(by: mn.touchInset).contains(point)
    }
}

extension MNNameSpaceWrapper where Base: UIView {
    
    /// 设置触发区域
    @MainActor public var touchInset: UIEdgeInsets {
        get {
            guard let value = objc_getAssociatedObject(base, &UIView.MNTouchAssociated.key) as? NSValue else { return .zero }
            return value.uiEdgeInsetsValue
        }
        set {
            objc_setAssociatedObject(base, &UIView.MNTouchAssociated.key, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let isExchanged = objc_getAssociatedObject(self, &UIView.MNTouchAssociated.exchanged) as? Bool, isExchanged { return }
            let originalSelector = #selector(base.point(inside:with:))
            guard let originalMethod = class_getInstanceMethod(Base.self, originalSelector) else { return }
            let newSelector = #selector(base.mn_point(inside:with:))
            guard let replaceMethod = class_getInstanceMethod(Base.self, newSelector) else { return }
            if class_addMethod(Base.self, originalSelector, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod)) {
                class_replaceMethod(Base.self, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, replaceMethod)
            }
            objc_setAssociatedObject(base, &UIView.MNTouchAssociated.exchanged, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
