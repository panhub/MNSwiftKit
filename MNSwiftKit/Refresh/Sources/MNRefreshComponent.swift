//
//  MNRefreshComponent.swift
//  MNKit
//
//  Created by 冯盼 on 2021/10/8.
//  资源管理

import UIKit
import Foundation
import CoreGraphics

@objc open class MNRefreshComponent: UIView {
    /// 刷新状态
    @objc public enum State: Int {
        case normal, pulling, preparing, refreshing, noMoreData
    }
    /// 记录父视图
    @objc public private(set) weak var scrollView: UIScrollView?
    /// 缓慢的动画时间
    @objc public static let SlowAnimationDuration: TimeInterval = 0.38
    /// 快速的动画时间
    @objc public static let FastAnimationDuration: TimeInterval = 0.25
    /// 定义颜色
    @objc open var color: UIColor = .black
    /// 是否在刷新
    @objc open var isRefreshing: Bool { state == .refreshing }
    /// 是否是无更多数据状态
    @objc open var isNoMoreData: Bool { state == .noMoreData }
    /// 开始刷新回调
    @objc open var beginRefreshHandler: (()->Void)?
    /// 结束刷新回调
    @objc open var endRefreshingHandler: (()->Void)?
    /// 记录内容约束
    @objc open var referenceInset: UIEdgeInsets = .zero
    /// 刷新方法
    private var action: Selector?
    /// 回调对象
    private weak var target: NSObjectProtocol?
    /// 记录修改inset的差值
    internal var deltaInset: CGFloat = 0.0
    /// 调整控件偏移
    @objc open var offset: UIOffset = .zero {
        didSet {
            didChangeOffset(offset)
        }
    }
    /// 调整控件内容偏移
    @objc open var contentInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }
    /// 当前状态
    @objc open var state: State = .normal {
        didSet {
            guard oldValue != state else { return }
            didChangeState(from: oldValue, to: state)
        }
    }
    
    @objc public override init(frame: CGRect) {
        super.init(frame: .init(x: 0.0, y: 0.0, width: 0.0, height: 55.0))
        commonInit()
    }
    
    @objc public init(target: NSObjectProtocol, action: Selector) {
        super.init(frame: .init(x: 0.0, y: 0.0, width: 0.0, height: 55.0))
        addTarget(target, action: action)
        commonInit()
    }
    
    @objc open func commonInit() {
        backgroundColor = .clear
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 添加刷新事件调用
    /// - Parameters:
    ///   - target: 调用对象
    ///   - action: 响应事件
    @objc func addTarget(_ target: NSObjectProtocol, action: Selector) {
        self.target = target
        self.action = action
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let scrollView = superview as? UIScrollView else { return }
        // 保持同宽度
        var rect = frame
        rect.size.width = scrollView.frame.width
        frame = frame
        autoresizingMask = .flexibleWidth
        // 记录UIScrollView最开始的contentInset
        referenceInset = scrollView.mn_refresh.contentInset
        // 设置永远支持垂直弹簧效果
        scrollView.alwaysBounceVertical = true
        // 开始监听
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.old, .new], context: nil)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
        // 记录UIScrollView
        self.scrollView = scrollView
        // 通知即将添加到scrollView
        didMove(toParent: scrollView)
        // 约束控件位置
        didChangeOffset(offset)
    }
    
    open override func removeFromSuperview() {
        if let scrollView = scrollView {
            // 删除监听
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
            // 通知即将从scrollView中移除
            self.scrollView = nil
            willRemove(fromParent: scrollView)
        }
        super.removeFromSuperview()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        // 避免还没有出现就已经是刷新状态
        if state == .preparing {
            state = .refreshing
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case #keyPath(UIScrollView.contentSize):
            scrollViewContentSizeDidChange(change)
        case #keyPath(UIScrollView.contentOffset):
            scrollViewContentOffsetDidChange(change)
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    /// 内容尺寸变化告知
    /// - Parameter change: 变化内容
    @objc open func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {}
    
    /// 偏移量变化告知
    /// - Parameter change: 变化内容
    @objc open func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {}
    
    /// 已经添加到父视图
    /// - Parameter scrollView: 滑动视图
    @objc open func didMove(toParent scrollView: UIScrollView) {}
    
    /// 即将从父视图上移除
    /// - Parameter scrollView: 滑动视图
    @objc open func willRemove(fromParent scrollView: UIScrollView) {}
    
    /// 已经改变状态
    /// - Parameters:
    ///   - oldState: 旧状态
    ///   - state: 新状态
    @objc open func didChangeState(from oldState: State, to state: State) {}
    
    /// 已经修改偏移
    /// - Parameter offset: 新的偏移量
    @objc open func didChangeOffset(_ offset: UIOffset) {}
}

// MARK: - 开始/停止刷新
extension MNRefreshComponent {
    
    /// 开始刷新
    @objc open func beginRefresh() {
        if let _ = window {
            // 在屏幕上
            state = .refreshing
        } else {
            // 未在屏幕上
            if state == .preparing || state == .refreshing { return }
            state = .preparing
            setNeedsDisplay()
        }
    }
    
    /// 结束刷新
    @objc open func endRefreshing() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = .normal
        }
    }
    
    /// 结束刷新而且无刷新能力
    @objc open func endRefreshingAndNoMoreData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = .noMoreData
        }
    }
    
    /// 结束限制恢复刷新能力
    @objc open func relieveNoMoreData() {
        guard state == .noMoreData else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.state = .normal
        }
    }
}

// MARK: - 回调事件
extension MNRefreshComponent {
    
    @objc open func executeBeginRefresh() {
        if let beginRefreshHandler = beginRefreshHandler {
            beginRefreshHandler()
        }
        if let target = target, let action = action {
            target.perform(action)
        }
    }
    
    @objc open func executeEndRefreshing() {
        if let endRefreshingHandler = endRefreshingHandler {
            endRefreshingHandler()
        }
    }
}
