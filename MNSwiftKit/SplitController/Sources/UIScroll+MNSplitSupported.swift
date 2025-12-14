//
//  UIScroll+MNSplitSupported.swift
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
    
    fileprivate struct MNSplitAssociated {
        
        nonisolated(unsafe) static var pageIndex: String = "com.mn.page.scroll.index"
        nonisolated(unsafe) static var headerInset: String = "com.mn.page.scroll.header.inset"
        nonisolated(unsafe) static var isObserved: String = "com.mn.page.scroll.observed"
        nonisolated(unsafe) static var transitionState: String = "com.mn.page.scroll.transition.state"
        nonisolated(unsafe) static var leastContentSize: String = "com.mn.page.scroll.least.content.size"
        nonisolated(unsafe) static var reachedContentSize: String = "com.mn.page.scroll.content.size.reached"
    }
}


extension MNNameSpaceWrapper where Base: UIScrollView {
    
    /// 是否展示了页面
    public var isAppear: Bool { transitionState == .didAppear }
    
    /// 页面索引
    public var pageIndex: Int {
        get { return objc_getAssociatedObject(base, &UIScrollView.MNSplitAssociated.pageIndex) as? Int ?? 0 }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSplitAssociated.pageIndex, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 页面是否在显示
    public var transitionState: UIScrollView.MNTransitionState {
        get { return UIScrollView.MNTransitionState(rawValue: objc_getAssociatedObject(base, &UIScrollView.MNSplitAssociated.transitionState) as? Int ?? 0) ?? .unknown }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSplitAssociated.transitionState, newValue.rawValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 最小内容尺寸
    var leastContentSize: CGSize {
        get {
            return (objc_getAssociatedObject(base, &UIScrollView.MNSplitAssociated.leastContentSize) as? NSValue)?.cgSizeValue ?? .zero
        }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSplitAssociated.leastContentSize, NSValue(cgSize: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 已满足最小内容尺寸
    var isReachedLeastSize: Bool {
        get { return objc_getAssociatedObject(base, &UIScrollView.MNSplitAssociated.reachedContentSize) as? Bool ?? false }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSplitAssociated.reachedContentSize, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 是否已监听偏移变化
    var isObserved: Bool {
        get { return objc_getAssociatedObject(base, &UIScrollView.MNSplitAssociated.isObserved) as? Bool ?? false }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSplitAssociated.isObserved, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 页头的插入量
    var headerInset: CGFloat {
        get { return objc_getAssociatedObject(base, &UIScrollView.MNSplitAssociated.headerInset) as? CGFloat ?? 0.0 }
        set {
            objc_setAssociatedObject(base, &UIScrollView.MNSplitAssociated.headerInset, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
