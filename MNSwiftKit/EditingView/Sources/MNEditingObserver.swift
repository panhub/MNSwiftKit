//
//  UITableViewCellObserver.swift
//  MNTest
//
//  Created by 冯盼 on 2022/8/22.
//  针对偏移改变的监听以取消编辑状态

import UIKit

protocol MNEditingObserveDelegate: NSObjectProtocol {
    
    /// 内容尺寸变化
    /// - Parameters:
    ///   - scrollView: 滑动控件
    ///   - change: 尺寸变化
    func scrollView(_ scrollView: UIScrollView, didChangeContentSize change: [NSKeyValueChangeKey : Any]?)
    
    /// 内容偏移改变
    /// - Parameters:
    ///   - scrollView: 滑动控件
    ///   - change: 偏移变化
    func scrollView(_ scrollView: UIScrollView, didChangeContentOffset change: [NSKeyValueChangeKey : Any]?)
}

class MNEditingObserver: NSObject {
    
    /// 滚动视图
    weak var scrollView: UIScrollView?
    
    /// 事件通知代理
    weak var delegate: MNEditingObserveDelegate?
    
    /// 构造监听
    /// - Parameter scrollView: 滑动控件
    init(scrollView: UIScrollView) {
        super.init()
        self.scrollView = scrollView
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), context: nil)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
    }
    
    deinit {
        guard let scrollView = scrollView else { return }
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = scrollView else { return }
        guard let delegate = delegate else { return }
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case #keyPath(UIScrollView.contentSize):
            delegate.scrollView(scrollView, didChangeContentSize: change)
        case #keyPath(UIScrollView.contentOffset):
            delegate.scrollView(scrollView, didChangeContentOffset: change)
        default: break
        }
    }
}
