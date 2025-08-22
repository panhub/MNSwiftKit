//
//  MNRefreshFooter.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/18.
//  加载更多

import UIKit

open class MNRefreshFooter: MNRefreshComponent {
    
    /**记录刷新前内容高度*/
    private var contentHeight: CGFloat = 0.0
    
    /**初始化*/
    open override func initialized() {
        super.initialized()
        switch style {
        case .small:
            height = MNRefreshComponent.NormalHeight
        case .large:
            height = max(MN_BOTTOM_BAR_HEIGHT + MN_BOTTOM_SAFE_HEIGHT, MNRefreshComponent.NormalHeight)
        }
    }
    
    open override func didChangeOffset(_ offset: UIOffset) {
        guard let scrollView = scrollView else { return }
        midX = scrollView.frame.width/2.0 - scrollView.mn.contentInset.left + offset.horizontal
        minY = max(scrollView.mn.contentHeight, scrollView.frame.height - referenceInset.top - referenceInset.bottom) + offset.vertical
    }
    
    open override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        // 如果是无数据状态不做操作
        if state == .noMoreData || state == .refreshing { return }
        
        // 处于刷新状态不做操作
        guard let scrollView = scrollView else { return }
        
        // 刷新四周约束
        referenceInset = scrollView.mn.contentInset
        
        // 当前偏移
        let offsetY = scrollView.mn.offsetY
        // 刚好看到控件的偏移
        let happenOffsetY = offsetWhenAppear
        
        // 如果是向下滚动到看不见尾部控件 直接返回
        guard offsetY >= happenOffsetY else { return }
        
        // 普通和即将加载的临界点
        let pullingOffsetY = happenOffsetY + frame.height
        
        // 更新滑动比率
        if offsetY <= pullingOffsetY {
            footerViewDidDragging((offsetY - happenOffsetY)/frame.height)
        }
        
        // 更新状态
        if scrollView.isDragging {
            if state == .normal, offsetY > pullingOffsetY {
                // 置为即将刷新状态
                footerViewDidDragging(1.0)
                state = .pulling
            } else if state == .pulling, offsetY <= pullingOffsetY {
                // 置为普通状态
                state = .normal
            }
        } else if state == .pulling {
            // 开始加载
            beginRefresh()
        }
    }
    
    open override func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        didChangeOffset(offset)
    }
    
    open override func didChangeState(from oldState: MNRefreshComponent.State, to state: MNRefreshComponent.State) {
        super.didChangeState(from: oldState, to: state)
        switch state {
        case .normal, .noMoreData:
            guard oldState == .refreshing else { break }
            // 刷新结束
            UIView.animate(withDuration: MNRefreshComponent.SlowAnimationDuration) { [weak self] in
                guard let self = self, let scrollView = self.scrollView else { return }
                scrollView.mn.bottomInset -= self.deltaInset
            } completion: { [weak self] _ in
                // 回调结束刷新
                guard let self = self else { return }
                self.executeEndRefreshing()
            }
            // 判断是否需要回滚
            if let scrollView = scrollView, heightForContentMoreThanBackView > 0.1, abs(scrollView.mn.contentHeight - contentHeight) > 0.1 {
                scrollView.mn.offsetY = scrollView.mn.offsetY
            }
        case .refreshing:
            // 开始刷新
            if let scrollView = scrollView {
                contentHeight = scrollView.mn.contentHeight
            }
            UIView.animate(withDuration: MNRefreshComponent.FastAnimationDuration) { [weak self] in
                guard let self = self, let scrollView = self.scrollView else { return }
                var bottom = self.height + self.referenceInset.bottom
                let deltaHeight = self.heightForContentMoreThanBackView
                if deltaHeight < 0.0 {
                    bottom -= deltaHeight
                }
                self.deltaInset = bottom - scrollView.mn.bottomInset
                scrollView.mn.bottomInset = bottom
                scrollView.mn.offsetY = self.offsetWhenAppear + self.height
            } completion: { [weak self] _ in
                // 回调开始刷新
                guard let self = self else { return }
                self.executeBeginRefresh()
            }
        default: break
        }
    }
    
    /// 滑动比率改变告知
    /// - Parameter percent: 比率
    @objc open func footerViewDidDragging(_ percent: CGFloat) {}
}

// MARK: - 辅助方法
private extension MNRefreshFooter {
    
    // scrollView的内容超出view的高度
    var heightForContentMoreThanBackView: CGFloat {
        return scrollView!.contentSize.height - scrollView!.bounds.inset(by: referenceInset).height
    }
    
    // 刚好看到控件时的内容偏移量
    var offsetWhenAppear: CGFloat {
        let height = heightForContentMoreThanBackView
        if height > 0.0 {
            return height - referenceInset.top
        }
        return -referenceInset.top
    }
}
