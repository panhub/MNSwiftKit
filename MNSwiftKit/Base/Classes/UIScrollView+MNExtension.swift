//
//  UIScrollView+MNHelper.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/5.
//

import UIKit
import Foundation

// MARK: - 滑动至边缘
extension UIScrollView {
    
    /// 滑动到顶部
    @objc public func scrollToTop(animated: Bool = true) {
        var offset = contentOffset
        offset.y = -contentInset.top
        setContentOffset(offset, animated: animated)
    }
    
    /// 滑动到底部
    @objc public func scrollToBottom(animated: Bool = true) {
        var offset = contentOffset
        offset.y = contentSize.height - frame.height + contentInset.bottom
        setContentOffset(offset, animated: animated)
    }
    
    /// 滑动到左侧
    @objc public func scrollToLeft(animated: Bool = true) {
        var offset = contentOffset
        offset.x = -contentInset.left
        setContentOffset(offset, animated: animated)
    }
    
    /// 滑动到右侧
    @objc public func scrollToRight(animated: Bool = true) {
        var offset = contentOffset
        offset.x = contentSize.width - frame.width + contentInset.right
        setContentOffset(offset, animated: animated)
    }
}
