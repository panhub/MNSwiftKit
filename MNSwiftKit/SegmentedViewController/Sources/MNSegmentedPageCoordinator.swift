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
    var currentPageIndex: Int { get }
    
    /// 子页面数量
    var numberOfPages: Int { get }
    
    func subpage(at index: Int) -> MNSegmentedSubpageConvertible?
}

protocol MNSegmentedPageCoordinatorDelegate: NSObject {
    
    
    func pageViewController(_ viewController: UIPageViewController, subpage: MNSegmentedSubpageConvertible, didChangeContentOffset contentOffset: CGPoint)
}


protocol MNSegmentedPageCoordinatorScrollDelegate: NSObject {
    
    //
    
    func pageViewControllerWillBeginDragging(_ pageViewController: UIPageViewController)
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didScroll ratio: CGFloat)
    
    
    func pageViewController(_ viewController: UIPageViewController, willScrollToPageAt index: Int)
    
    
    func pageViewController(_ viewController: UIPageViewController, didScrollToPageAt index: Int)
}




/// 分页协调器
class MNSegmentedPageCoordinator: NSObject {
    
    ///
    private weak var scrollView: UIScrollView!
    
    weak var delegate: MNSegmentedPageCoordinatorDelegate?
    
    weak var dataSource: MNSegmentedPageCoordinatorDataSource?
    
    weak var scrollDelegate: MNSegmentedPageCoordinatorScrollDelegate?
    
    private var presentationCount: Int = 0
    
    private var presentationIndex: Int = 0
    
    
    private var subpages: [Int : MNSegmentedSubpageConvertible] = [:]
    
    
    
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
    
    func setPage(at index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        guard let page = fetchPage(at: index, allowAccess: true) else { return }
        pageViewController.setViewControllers([page], direction: direction, animated: animated)
    }
    
    func fetchPage(at index: Int, allowAccess: Bool = false) -> MNSegmentedSubpageConvertible? {
        if let subpage = subpages[index] { return subpage }
        guard allowAccess else { return nil }
        guard let dataSource = dataSource, let subpage = dataSource.subpage(at: index) else { return nil }
        subpage.preferredSubpageScrollView.mn.pageIndex = index
        subpages[index] = subpage
        return subpage
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
        if let dataSource = dataSource {
            presentationCount = dataSource.numberOfPages
            presentationIndex = dataSource.currentPageIndex
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard presentationCount > 1 else { return }
        let contentOffset = scrollView.contentOffset
        let currentOffset = configuration.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let pageDimension = configuration.orientation == .horizontal ? scrollView.frame.width : scrollView.frame.height
        if currentOffset > startOffset {
            let guessToIndex = presentationIndex + 1
            guard guessToIndex < presentationCount else { return }
            let progress = (currentOffset - startOffset)/pageDimension
            if let delegate = scrollDelegate {
                delegate.pageViewController(pageViewController, didScroll: CGFloat(presentationIndex) + progress)
            }
        } else if currentOffset < startOffset {
            let guessToIndex = presentationIndex - 1
            guard guessToIndex >= 0 else { return }
            let progress = (startOffset - currentOffset)/pageDimension
            if let delegate = scrollDelegate {
                delegate.pageViewController(pageViewController, didScroll: CGFloat(presentationIndex) - progress)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let contentOffset = targetContentOffset.pointee
        let targetOffset = configuration.orientation == .horizontal ? contentOffset.x : contentOffset.y
        var targetPageIndex = presentationIndex
        if targetOffset > startOffset {
            targetPageIndex += 1
        } else if targetOffset < startOffset {
            targetPageIndex -= 1
        }
        if let delegate = scrollDelegate {
            delegate.pageViewController(pageViewController, willScrollToPageAt: targetPageIndex)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = configuration.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        var currentPageIndex = presentationIndex
        if currentOffset > startOffset {
            currentPageIndex += 1
        } else if currentOffset < startOffset {
            currentPageIndex -= 1
        }
        if let delegate = scrollDelegate {
            delegate.pageViewController(pageViewController, didScrollToPageAt: currentPageIndex)
        }
    }
}
