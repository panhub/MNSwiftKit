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
    
    fileprivate struct MNSubpageAssociated {
        nonisolated(unsafe) static var observed: Void?
        nonisolated(unsafe) static var adjustedInset: Void?
        nonisolated(unsafe) static var subpageIndex: Void?
        nonisolated(unsafe) static var minimumContentSize: Void?
        nonisolated(unsafe) static var reachedMinimumContentSize: Void?
    }
}

extension MNNameSpaceWrapper where Base: UIScrollView {
    
    /// 子页面索引
    var subpageIndex: Int {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.subpageIndex) as? NSNumber else { return 0 }
            return number.intValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.subpageIndex, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 最小内容尺寸
    var minimumContentSize: CGSize {
        get {
            guard let value = objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.minimumContentSize) as? NSValue else { return .zero }
            return value.cgSizeValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.minimumContentSize, NSValue(cgSize: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否已满足最小内容尺寸
    var isReachedMinimumSize: Bool {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.reachedMinimumContentSize) as? NSNumber else { return false }
            return number.boolValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.reachedMinimumContentSize, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否已监听
    var isObserved: Bool {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.observed) as? NSNumber else { return false }
            return number.boolValue
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.observed, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 页头调整后的插入量
    var adjustedInset: CGFloat? {
        get {
            guard let number = objc_getAssociatedObject(base, &UIScrollView.MNSubpageAssociated.adjustedInset) as? NSNumber else { return nil }
            return CGFloat(number.doubleValue)
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.adjustedInset, NSNumber(value: Double(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &UIScrollView.MNSubpageAssociated.adjustedInset, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension UIViewController {
    
    /// 转场状态
    public enum MNSubpageState: Int {
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
        /// 子页面索引
        nonisolated(unsafe) static var subpageIndex: Void?
        /// 子页面状态
        nonisolated(unsafe) static var subpageState: Void?
    }
}

extension MNNameSpaceWrapper where Base: UIViewController {
    
    /// 子页面索引
    public internal(set) var subpageIndex: Int {
        get {
            guard let number = objc_getAssociatedObject(base, &UIViewController.MNSubpageAssociated.subpageIndex) as? NSNumber else { return 0 }
            return number.intValue
        }
        set {
            objc_setAssociatedObject(base, &UIViewController.MNSubpageAssociated.subpageIndex, NSNumber(value: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 子页面转场状态
    public internal(set) var subpageState: UIViewController.MNSubpageState {
        get {
            guard let number = objc_getAssociatedObject(base, &UIViewController.MNSubpageAssociated.subpageState) as? NSNumber else { return .unknown }
            return .init(rawValue: number.intValue) ?? .unknown
        }
        set {
            objc_setAssociatedObject(base, &UIViewController.MNSubpageAssociated.subpageState, NSNumber(value: newValue.rawValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


extension MNSegmentedSubpageConvertible {
    
    /// 子页面索引
    public var subpageIndex: Int {
        get {
            (self as UIViewController).mn.subpageIndex
        }
        set {
            (self as UIViewController).mn.subpageIndex = newValue
        }
    }
    
    /// 子页面转场状态
    public var subpageState: UIViewController.MNSubpageState {
        get {
            (self as UIViewController).mn.subpageState
        }
        set {
            (self as UIViewController).mn.subpageState = newValue
        }
    }
}
