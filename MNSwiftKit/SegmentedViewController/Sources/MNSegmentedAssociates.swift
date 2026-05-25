//
//  MNSegmentedSubpageAssociates.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/6/3.
//

import UIKit
import CoreFoundation
import ObjectiveC.runtime

extension UIScrollView {
    
    fileprivate struct MNPageAssociated {
        nonisolated(unsafe) static var topInset: Void?
        nonisolated(unsafe) static var pageIndex: Void?
        nonisolated(unsafe) static var observedPage: Void?
        nonisolated(unsafe) static var minimumPageSize: Void?
        nonisolated(unsafe) static var headerScrollEnabled: Void?
    }
}

extension MNNameSpaceWrapper where Base: UIScrollView {
    
    /// 页面索引
    var pageIndex: Int {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNPageAssociated.pageIndex) as? NSNumber else { return 0 }
            return number.intValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.pageIndex, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 最小内容尺寸
    var minimumPageSize: CGSize {
        get {
            guard let value = objc_getAssociatedObject(base, &UIScrollView.MNPageAssociated.minimumPageSize) as? NSValue else { return .zero }
            return value.cgSizeValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.minimumPageSize, NSValue(cgSize: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否已满足最小内容尺寸
    var isPageHeaderScrollEnabled: Bool {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNPageAssociated.headerScrollEnabled) as? NSNumber else { return false }
            return number.boolValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.headerScrollEnabled, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否已监听
    var isObservedPage: Bool {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNPageAssociated.observedPage) as? NSNumber else { return false }
            return number.boolValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.observedPage, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 页头调整后的插入量
    var pageTopInset: CGFloat? {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNPageAssociated.topInset) as? NSNumber else { return nil }
            return CGFloat(number.doubleValue)
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.topInset, NSNumber(value: Double(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.topInset, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension UIViewController {
    
    /// 转场状态
    public enum MNPageTransitionState: Int {
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
    
    fileprivate struct MNPageAssociated {
        /// 子页面索引
        nonisolated(unsafe) static var pageIndex: Void?
        /// 子页面状态
        nonisolated(unsafe) static var transitionState: Void?
    }
}

extension MNNameSpaceWrapper where Base: UIViewController {
    
    /// 页面索引
    public internal(set) var pageIndex: Int {
        get {
            guard let number = objc_getAssociatedObject(base, &UIViewController.MNPageAssociated.pageIndex) as? NSNumber else { return 0 }
            return number.intValue
        }
        set {
            objc_setAssociatedObject(base, &UIViewController.MNPageAssociated.pageIndex, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 页面转场状态
    public internal(set) var pageTransitionState: UIViewController.MNPageTransitionState {
        get {
            guard let number = objc_getAssociatedObject(base, &UIViewController.MNPageAssociated.transitionState) as? NSNumber else { return .unknown }
            return .init(rawValue: number.intValue) ?? .unknown
        }
        set {
            objc_setAssociatedObject(base, &UIViewController.MNPageAssociated.transitionState, NSNumber(value: newValue.rawValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
