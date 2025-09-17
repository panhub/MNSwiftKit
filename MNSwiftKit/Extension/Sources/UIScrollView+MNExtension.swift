//
//  UIScrollView+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/5.
//

import UIKit
import Foundation

// MARK: - 滑动至边缘
extension NameSpaceWrapper where Base: UIScrollView {
    
    /// 滑动到顶部
    public func scrollToTop(animated: Bool = true) {
        var offset = base.contentOffset
        offset.y = -base.contentInset.top
        base.setContentOffset(offset, animated: animated)
    }
    
    /// 滑动到底部
    public func scrollToBottom(animated: Bool = true) {
        var offset = base.contentOffset
        offset.y = base.contentSize.height - base.frame.height + base.contentInset.bottom
        base.setContentOffset(offset, animated: animated)
    }
    
    /// 滑动到左侧
    public func scrollToLeft(animated: Bool = true) {
        var offset = base.contentOffset
        offset.x = -base.contentInset.left
        base.setContentOffset(offset, animated: animated)
    }
    
    /// 滑动到右侧
    public func scrollToRight(animated: Bool = true) {
        var offset = base.contentOffset
        offset.x = base.contentSize.width - base.frame.width + base.contentInset.right
        base.setContentOffset(offset, animated: animated)
    }
}
