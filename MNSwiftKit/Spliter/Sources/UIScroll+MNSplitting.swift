//
//  UIScroll+MNSplitting.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/6/3.
//

import UIKit
import ObjectiveC.runtime

extension UIScrollView {
    
    internal enum MNTransitionState: Int {
        case unknown, willAppear, didAppear, willDisappear, didDisappear
    }
    
    fileprivate struct MNSplitAssociated {
        
        nonisolated(unsafe) static var pageIndex: String = "com.mn.page.scroll.index"
        nonisolated(unsafe) static var headerInset: String = "com.mn.page.scroll.header.inset"
        nonisolated(unsafe) static var isObserved: String = "com.mn.page.scroll.observed"
        nonisolated(unsafe) static var transitionState: String = "com.mn.page.scroll.transition.state"
        nonisolated(unsafe) static var leastContentSize: String = "com.mn.page.scroll.least.content.size"
        nonisolated(unsafe) static var reachedContentSize: String = "com.mn.page.scroll.content.size.reached"
    }
    
    internal class MNSplitWrapper {
        
        fileprivate let scrollView: UIScrollView
        
        fileprivate init(scrollView: UIScrollView) {
            self.scrollView = scrollView
        }
    }
    
    /// 分割包装器
    internal var mn_split: MNSplitWrapper { MNSplitWrapper(scrollView: self) }
}


extension UIScrollView.MNSplitWrapper {
    
    /// 页面索引
    var pageIndex: Int {
        get { return objc_getAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.pageIndex) as? Int ?? 0 }
        set {
            objc_setAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.pageIndex, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 是否展示了页面
    internal var isAppear: Bool { transitionState == .didAppear }
    
    /// 页面是否在显示
    var transitionState: UIScrollView.MNTransitionState {
        get { return UIScrollView.MNTransitionState(rawValue: objc_getAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.transitionState) as? Int ?? 0) ?? .unknown }
        set {
            objc_setAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.transitionState, newValue.rawValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 最小内容尺寸
    var leastContentSize: CGSize {
        get {
            return (objc_getAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.leastContentSize) as? NSValue)?.cgSizeValue ?? .zero
        }
        set {
            objc_setAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.leastContentSize, NSValue(cgSize: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 已满足最小内容尺寸
    var isReachedLeastSize: Bool {
        get { return objc_getAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.reachedContentSize) as? Bool ?? false }
        set {
            objc_setAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.reachedContentSize, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 是否已监听偏移变化
    var isObserved: Bool {
        get { return objc_getAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.isObserved) as? Bool ?? false }
        set {
            objc_setAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.isObserved, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 页头的插入量
    var headerInset: CGFloat {
        get { return objc_getAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.headerInset) as? CGFloat ?? 0.0 }
        set {
            objc_setAssociatedObject(scrollView, &UIScrollView.MNSplitAssociated.headerInset, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
