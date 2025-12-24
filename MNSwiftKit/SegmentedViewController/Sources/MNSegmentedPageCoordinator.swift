//
//  MNSegmentedPageCoordinator.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit
import Foundation
import CoreFoundation

protocol MNSegmentedPageCoordinatorDataSource: NSObject {
    
    /// 当前选择的索引
    var currentSubpageIndex: Int { get }
    
    
    
}

protocol MNSegmentedPageCoordinatorDelegate: NSObject {
    
    //
    
    func pageViewControllerWillBeginDragging(_ pageViewController: UIPageViewController)
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didScroll ratio: CGFloat)
    
    
    func pageViewControllerDidEndDragging(_ pageViewController: UIPageViewController)
    
    
    func pageViewController(_ viewController: UIPageViewController, willScrollToPageAt index: Int)
    
    
    func pageViewController(_ viewController: UIPageViewController, didScrollToPageAt index: Int)
    
    
    func pageViewController(_ viewController: UIPageViewController, subpage: MNSegmentedSubpageConvertible, didChangeContentOffset contentOffset: CGPoint)
}





/// 分页协调器
class MNSegmentedPageCoordinator: NSObject {
    
    ///
    weak var scrollView: UIScrollView!
    
    /// 开始滑动时的偏移
    private var startOffset: CGFloat = 0.0
    
    /// 配置信息
    private let configuration: MNSegmentedConfiguration
    
    /// 分页控制器
    private let pageViewController: UIPageViewController
    
    
    init(configuration: MNSegmentedConfiguration, pageViewController: UIPageViewController) {
        self.configuration = configuration
        self.pageViewController = pageViewController
        super.init()
        //
        for subview in pageViewController.view.subviews {
            guard subview is UIScrollView else { continue }
            let scrollView = subview as! UIScrollView
            scrollView.delegate = self
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            self.scrollView = scrollView
            break
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MNSegmentedPageCoordinator: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let key = configuration.orientation == .horizontal ? "startOffsetX" : "startOffsetY"
        if let value = scrollView.value(forKey: key) as? CGFloat {
            startOffset = value
        } else {
            startOffset = configuration.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
