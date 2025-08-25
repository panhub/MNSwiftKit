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
    
    private struct MNTouchInsetAssociated {
        
        nonisolated(unsafe) static var key = "com.mn.view.touch.inset.key"
        
        nonisolated(unsafe) static var exchanged = "com.mn.view.touch.inset.exchanged"
    }
    
    /// 设置触发区域
    @MainActor public var mn_touchInset: UIEdgeInsets {
        get {
            guard let value = objc_getAssociatedObject(self, &UIView.MNTouchInsetAssociated.key) as? NSValue else { return .zero }
            return value.uiEdgeInsetsValue
        }
        set {
            objc_setAssociatedObject(self, &UIView.MNTouchInsetAssociated.key, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let isExchanged = objc_getAssociatedObject(self, &UIView.MNTouchInsetAssociated.exchanged) as? Bool, isExchanged { return }
            let originalSelector = #selector(self.point(inside:with:))
            guard let originalMethod = class_getInstanceMethod(UIView.self, originalSelector) else { return }
            let newSelector = #selector(self.mn_view_point(inside:with:))
            guard let replaceMethod = class_getInstanceMethod(UIView.self, newSelector) else { return }
            if class_addMethod(UIView.self, originalSelector, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod)) {
                class_replaceMethod(UIView.self, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, replaceMethod)
            }
            objc_setAssociatedObject(self, &UIView.MNTouchInsetAssociated.exchanged, true, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    @objc fileprivate func mn_view_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard alpha >= 0.01 else { return false }
        guard isHidden == false else { return false }
        guard isUserInteractionEnabled else { return false }
        return bounds.inset(by: mn_touchInset).contains(point)
    }
}
