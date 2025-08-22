//
//  UIView+MNSwizzled.swift
//  becamera
//
//  Created by 元气绘画 on 2023/9/20.
//  视图交换方法

import UIKit
import Foundation
import ObjectiveC.runtime

extension UIView {
    
    /// 是否交换过方法
    fileprivate static var isExchangeTouchMethod: Bool = false
    
    fileprivate static var mn_key_touchInset: String = "com.mn.key.view.touch.inset"
    
    /// 设置触发区域
    @MainActor public var mn_touchInset: UIEdgeInsets {
        get {
            guard let value = objc_getAssociatedObject(self, &UIView.mn_key_touchInset) as? NSValue else { return .zero }
            return value.uiEdgeInsetsValue
        }
        set {
            objc_setAssociatedObject(self, &UIView.mn_key_touchInset, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            guard UIView.isExchangeTouchMethod == false else { return }
            let originalSelector = #selector(self.point(inside:with:))
            guard let originalMethod = class_getInstanceMethod(UIView.self, originalSelector) else { return }
            let newSelector = #selector(self.mn_view_point(inside:with:))
            guard let replaceMethod = class_getInstanceMethod(UIView.self, newSelector) else { return }
            if class_addMethod(UIView.self, originalSelector, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod)) {
                class_replaceMethod(UIView.self, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, replaceMethod)
            }
            UIView.isExchangeTouchMethod = true
        }
    }
    
    @objc fileprivate func mn_view_point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard alpha >= 0.01 else { return false }
        guard isHidden == false else { return false }
        guard isUserInteractionEnabled else { return false }
        return bounds.inset(by: mn_touchInset).contains(point)
    }
}
