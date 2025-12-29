//
//  UIScrollView+MNSubpageSupported.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/6/3.
//

import UIKit
import ObjectiveC.runtime

extension UIScrollView {
    
    /// 转场状态
    public enum MNTransitionState: Int {
        /// 未知(默认状态)
        case unknown
        /// 即将出现
        case willAppear
        /// 已经出现
        case didAppear
        /// 即将消失
        case willDisappear
        /// 已经消失
        case didDisappear
    }
    
    fileprivate struct MNSubpageAssociated {
        nonisolated(unsafe) static var observed: Void?
        nonisolated(unsafe) static var pageIndex: Void?
        nonisolated(unsafe) static var headerInset: Void?
        nonisolated(unsafe) static var transitionState: Void?
        nonisolated(unsafe) static var adjustmentInset: Void?
        nonisolated(unsafe) static var leastContentSize: Void?
        nonisolated(unsafe) static var reachedContentSize: Void?
    }
}


extension MNNameSpaceWrapper where Base: UIScrollView {
    
    /// 页面是否在显示
    public var isAppear: Bool { transitionState == .didAppear }
    
    /// 页面转场状态
    public var transitionState: UIScrollView.MNTransitionState {
        get {
            if let rawValue = objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.transitionState) as? Int {
                return .init(rawValue: rawValue) ?? .unknown
            }
            return .unknown
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.transitionState, newValue.rawValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
       
    /// 页面索引
    public var pageIndex: Int {
        get {
            objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.pageIndex) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.pageIndex, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 最小内容尺寸
    var leastContentSize: CGSize {
        get {
            if let sizeValue = objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.leastContentSize) as? NSValue {
                return sizeValue.cgSizeValue
            }
            return .zero
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.leastContentSize, NSValue(cgSize: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 已满足最小内容尺寸
    var isReachedLeastSize: Bool {
        get {
            objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.reachedContentSize) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.reachedContentSize, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否已监听偏移变化
    var isObserved: Bool {
        get {
            objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.observed) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.observed, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 页头的插入量
    var headerInset: CGFloat {
        get {
            objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.headerInset) as? CGFloat ?? 0.0
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.headerInset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 页头的插入量
    var adjustmentInset: CGFloat? {
        get {
            if let object = objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.adjustmentInset) {
                return object as? CGFloat ?? 0.0
            }
            return nil
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.adjustmentInset, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
