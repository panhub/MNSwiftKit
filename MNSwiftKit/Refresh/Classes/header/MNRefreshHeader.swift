//
//  MNRefreshHeader.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/18.
//  下拉刷新视图

import UIKit

open class MNRefreshHeader: MNRefreshComponent {
    
    /**初始化*/
    open override func initialized() {
        super.initialized()
        switch style {
        case .small:
            height = MNRefreshComponent.NormalHeight
        case .large:
            height = max(MN_STATUS_BAR_HEIGHT + MN_NAV_BAR_HEIGHT, MNRefreshComponent.NormalHeight)
        }
    }
    
    open override func didChangeOffset(_ offset: UIOffset) {
        guard let scrollView = scrollView else { return }
        minY = offset.vertical - height
        midX = scrollView.frame.width/2.0 - scrollView.mn.contentInset.left + offset.horizontal
    }
    
    open override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        // 如果是无数据状态不做操作
        if state == .noMoreData { return }
        
        guard let scrollView = scrollView else { return }
        
        if state == .refreshing {
            guard let _ = window else { return }
            // 解决停留问题
            let insetT = min(max(-scrollView.mn.offsetY, referenceInset.top), frame.height + referenceInset.top)
            scrollView.mn.topInset = insetT
            deltaInset = referenceInset.top - insetT
            return
        }
        
        // contentInset可能会随时变
        referenceInset = scrollView.mn.contentInset
        
        // 当前的偏移
        let offsetY = scrollView.mn.offsetY
        // 控件刚好出现(正常状态下)的offsetY
        let happenOffsetY = -referenceInset.top
        
        // 如果是向上滚动到看不见头部控件，直接返回
        guard offsetY <= happenOffsetY else { return }
        
        // 普通和即将刷新的临界点
        let pullingOffsetY = happenOffsetY - frame.height
        
        // 更新滑动比率
        if offsetY >= pullingOffsetY {
            headerViewDidDragging((happenOffsetY - offsetY)/frame.height)
        }
        
        // 更新状态
        if scrollView.isDragging {
            if state == .normal, offsetY < pullingOffsetY {
                // 置为即将刷新状态
                headerViewDidDragging(1.0)
                state = .pulling
            } else if state == .pulling, offsetY >= pullingOffsetY {
                // 置为普通状态
                state = .normal
            }
        } else if state == .pulling {
            // 松手就开始刷新
            beginRefresh()
        }
    }
    
    open override func didChangeState(from oldState: MNRefreshComponent.State, to state: MNRefreshComponent.State) {
        super.didChangeState(from: oldState, to: state)
        switch state {
        case .normal, .noMoreData:
            guard oldState == .refreshing else { break }
            // 结束刷新
            UIView.animate(withDuration: MNRefreshComponent.SlowAnimationDuration) { [weak self] in
                guard let self = self, let scrollView = self.scrollView else { return }
                scrollView.mn.topInset += self.deltaInset
            } completion: { [weak self] _ in
                // 回调结束刷新
                guard let self = self else { return }
                self.executeEndRefreshing()
            }
        case .refreshing:
            // 开始刷新
            UIView.animate(withDuration: MNRefreshComponent.FastAnimationDuration) { [weak self] in
                guard let self = self, let scrollView = self.scrollView else { return }
                let inset = self.referenceInset.top + self.height
                scrollView.mn.topInset = inset
                scrollView.mn.offsetY = -inset
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
    @objc open func headerViewDidDragging(_ percent: CGFloat) {}
}
