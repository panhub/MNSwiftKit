//
//  UIScrollViewRefreshing.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/18.
//  UIScrollView处理

import UIKit
import ObjectiveC.runtime
#if SWIFT_PACKAGE
@_exported import MNNameSpace
#endif

extension UIScrollView {
    
    fileprivate struct MNRefreshAssociated {
        
        nonisolated(unsafe) static var footer: Void?
        
        nonisolated(unsafe) static var header: Void?
    }
}

extension MNNameSpaceWrapper where Base: UIScrollView {
    
    public var contentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return base.adjustedContentInset
        }
        return base.contentInset
    }
    
    public var contentHeight: CGFloat {
        base.contentSize.height
    }
    
    public var offsetY: CGFloat {
        get { base.contentOffset.y }
        set {
            var offset = base.contentOffset
            offset.y = newValue
            base.contentOffset = offset
        }
    }
    
    public var topInset: CGFloat {
        get { contentInset.top }
        set {
            var inset = base.contentInset
            inset.top = newValue
            if #available(iOS 11.0, *) {
                inset.top -= (base.adjustedContentInset.top - base.contentInset.top)
            }
            base.contentInset = inset
        }
    }
    
    public var bottomInset: CGFloat {
        get { contentInset.bottom }
        set {
            var inset = base.contentInset
            inset.bottom = newValue
            if #available(iOS 11.0, *) {
                inset.bottom -= (base.adjustedContentInset.bottom - base.contentInset.bottom)
            }
            base.contentInset = inset
        }
    }
}

extension MNNameSpaceWrapper where Base: UIScrollView {
    
    /// 头部刷新控件
    public var header: MNRefreshHeader? {
        get { objc_getAssociatedObject(base, &UIScrollView.MNRefreshAssociated.header) as? MNRefreshHeader }
        set {
            let header = header
            if newValue == nil, header == nil { return }
            if let newValue = newValue, let header = header, newValue == header { return }
            if let header = header {
                header.removeFromSuperview()
            }
            if let newValue = newValue {
                base.insertSubview(newValue, at: 0)
            }
            objc_setAssociatedObject(base, &UIScrollView.MNRefreshAssociated.header, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 底部加载更多控件
    public var footer: MNRefreshFooter? {
        get { objc_getAssociatedObject(base, &UIScrollView.MNRefreshAssociated.footer) as? MNRefreshFooter }
        set {
            let footer = footer
            if newValue == nil, footer == nil { return }
            if let newValue = newValue, let footer = footer, newValue == footer { return }
            if let footer = footer {
                footer.removeFromSuperview()
            }
            if let newValue = newValue {
                base.insertSubview(newValue, at: 0)
            }
            objc_setAssociatedObject(base, &UIScrollView.MNRefreshAssociated.footer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 结束刷新操作
    public func endRefreshing() {
        guard let header = header else { return }
        header.endRefreshing()
    }
    
    /// 结束加载更多
    public func endLoadMore() {
        guard let footer = footer else { return }
        footer.endRefreshing()
    }
    
    /// 是否在刷新数据
    public var isRefreshing: Bool {
        guard let header = header else { return false }
        return header.isRefreshing
    }
    
    /// 是否在加载更多
    public var isLoadMore: Bool {
        guard let footer = footer else { return false }
        return footer.isRefreshing
    }
    
    /// 是否在加载状态
    public var isLoading: Bool {
        isRefreshing || isLoadMore
    }
    
    /// 是否有刷新能力
    public var isRefreshEnabled: Bool {
        get {
            guard let header = header else { return false }
            return header.state != .noMoreData
        }
        set {
            guard let header = header else { return }
            if newValue {
                header.relieveNoMoreData()
            } else {
                header.endRefreshingAndNoMoreData()
            }
        }
    }
    
    /// 是否可以加载更多
    public var isLoadMoreEnabled: Bool {
        get {
            guard let footer = footer else { return false }
            return footer.state != .noMoreData
        }
        set {
            guard let footer = footer else { return }
            if newValue {
                footer.relieveNoMoreData()
            } else {
                footer.endRefreshingAndNoMoreData()
            }
        }
    }
}
