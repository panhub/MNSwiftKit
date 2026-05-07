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
        nonisolated(unsafe) static var pageInset: Void?
        nonisolated(unsafe) static var pageIndex: Void?
        nonisolated(unsafe) static var pageObserved: Void?
        nonisolated(unsafe) static var minimumPageSize: Void?
        nonisolated(unsafe) static var reachedMinimumPageSize: Void?
    }
}

extension MNNameSpaceWrapper where Base: UIScrollView {
    
    /// 子页面索引
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
    var isReachedMinimumSize: Bool {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNPageAssociated.reachedMinimumPageSize) as? NSNumber else { return false }
            return number.boolValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.reachedMinimumPageSize, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否已监听
    var isPageObserved: Bool {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNPageAssociated.pageObserved) as? NSNumber else { return false }
            return number.boolValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.pageObserved, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 页头调整后的插入量
    var pageInset: CGFloat? {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNPageAssociated.pageInset) as? NSNumber else { return nil }
            return CGFloat(number.doubleValue)
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.pageInset, NSNumber(value: Double(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &UIScrollView.MNPageAssociated.pageInset, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension UIViewController {
    
    /// 转场状态
    public enum MNPageState: Int {
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
        nonisolated(unsafe) static var pageState: Void?
    }
}

extension MNNameSpaceWrapper where Base: UIViewController {
    
    /// 子页面索引
    public internal(set) var pageIndex: Int {
        get {
            guard let number = objc_getAssociatedObject(base, &UIViewController.MNPageAssociated.pageIndex) as? NSNumber else { return 0 }
            return number.intValue
        }
        set {
            objc_setAssociatedObject(base, &UIViewController.MNPageAssociated.pageIndex, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 子页面转场状态
    public internal(set) var pageState: UIViewController.MNPageState {
        get {
            guard let number = objc_getAssociatedObject(base, &UIViewController.MNPageAssociated.pageState) as? NSNumber else { return .unknown }
            return .init(rawValue: number.intValue) ?? .unknown
        }
        set {
            objc_setAssociatedObject(base, &UIViewController.MNPageAssociated.pageState, NSNumber(value: newValue.rawValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


extension MNSegmentedPageConvertible {
    
    /// 子页面索引
    public var pageIndex: Int {
        get {
            (self as UIViewController).mn.pageIndex
        }
        set {
            (self as UIViewController).mn.pageIndex = newValue
        }
    }
    
    /// 子页面转场状态
    public var pageState: UIViewController.MNPageState {
        get {
            (self as UIViewController).mn.pageState
        }
        set {
            (self as UIViewController).mn.pageState = newValue
        }
    }
}
