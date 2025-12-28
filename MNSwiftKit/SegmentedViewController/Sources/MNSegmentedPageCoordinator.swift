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
    
    /// 页头高度
    var subpageHeaderHeight: CGFloat { get }
    
    /// 页头最大偏移量
    var subpageHeaderGreatestFiniteOffset: CGFloat { get }
    
    /// 询问页面偏移合适
    /// - Parameter page: 子界面
    /// - Returns: 子页面偏移量
    func subpageContentOffset(_ page: MNSegmentedSubpageConvertible) -> CGPoint
    
    /// 获取子界面
    /// - Parameter index: 界面索引
    /// - Returns: 子界面
    func subpage(at index: Int) -> MNSegmentedSubpageConvertible?
}

protocol MNSegmentedPageCoordinatorDelegate: NSObject {
    
    /// 分页控制器已切换当前子页面
    /// - Parameters:
    ///   - viewController: 分页控制器
    ///   - subpage: 子页面
    func pageViewController(_ viewController: UIPageViewController, didScrollTo subpage: MNSegmentedSubpageConvertible)
    
    /// 子页面内容偏移量变化
    /// - Parameters:
    ///   - viewController: 分页控制器
    ///   - subpage: 子页面
    ///   - contentOffset: 内容偏移量
    func pageViewController(_ viewController: UIPageViewController, subpage: MNSegmentedSubpageConvertible, didChangeContentOffset contentOffset: CGPoint)
}


protocol MNSegmentedPageCoordinatorScrollDelegate: NSObject {
    
    /// 分页控制器即将滑动
    /// - Parameter pageViewController: 分页控制器
    func pageViewControllerWillBeginDragging(_ pageViewController: UIPageViewController)
    
    /// 分页控制器滑动中
    /// - Parameters:
    ///   - pageViewController: 分页控制器
    ///   - progress: 滑动进度
    func pageViewController(_ pageViewController: UIPageViewController, didScroll progress: CGFloat)
    
    /// 分页控制器即将滑动到子页面
    /// - Parameters:
    ///   - viewController: 分页控制器
    ///   - index: 子页面索引
    func pageViewController(_ viewController: UIPageViewController, willScrollToSubpageAt index: Int)
}

/// 分页协调器
class MNSegmentedPageCoordinator: NSObject {
    /// 当前展示的子页面索引
    private var presentationIndex: Int = 0
    /// 子页面数量
    private var presentationCount: Int = 0
    /// 猜想将要滑动到的界面索引
    private var guessToPageIndex: Int = 0
    /// 开始滑动时分页控制器内部滑动视图的偏移量
    private var startOffset: CGFloat = 0.0
    /// 配置信息
    private let configuration: MNSegmentedConfiguration
    /// 分页控制器
    private let pageViewController: UIPageViewController
    /// 子页面缓存
    private var subpages: [Int : MNSegmentedSubpageConvertible] = [:]
    /// 事件代理
    weak var delegate: MNSegmentedPageCoordinatorDelegate?
    /// 数据源
    weak var dataSource: MNSegmentedPageCoordinatorDataSource?
    /// 滑动事件代理
    weak var scrollDelegate: MNSegmentedPageCoordinatorScrollDelegate?
    
    /// 构造页面协调器
    /// - Parameters:
    ///   - configuration: 配置信息
    ///   - pageViewController: 分页控制器
    init(configuration: MNSegmentedConfiguration, pageViewController: UIPageViewController) {
        self.configuration = configuration
        self.pageViewController = pageViewController
        super.init()
        pageViewController.delegate = self
        pageViewController.dataSource = self
        //
        for subview in pageViewController.view.subviews {
            guard subview is UIScrollView else { continue }
            let scrollView = subview as! UIScrollView
            scrollView.delegate = self
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            break
        }
    }
    
    /// 设置当前展示的页面
    /// - Parameters:
    ///   - index: 页面索引
    ///   - direction: 页面切换方向
    ///   - animated: 是否动态展示
    func setPage(at index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        guard let subpage = subpage(for: index, allowAccess: true) else { return }
        pageViewController.setViewControllers([subpage], direction: direction, animated: animated)
    }
    
    /// 更新子页面偏移量
    /// - Parameter subpage: 子页面
    private func updateSubpageOffset(_ subpage: MNSegmentedSubpageConvertible) {
        guard let dataSource = dataSource else { return }
        let contentOffset = dataSource.subpageContentOffset(subpage)
        subpage.preferredSubpageScrollView.setContentOffset(contentOffset, animated: false)
    }
    
    // MARK: - Observe
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object = object, let scrollView = object as? UIScrollView else { return }
        guard let keyPath = keyPath, let change = change else { return }
        let pageIndex = scrollView.mn.pageIndex
        switch keyPath {
        case #keyPath(UIScrollView.contentSize):
            // 页面内容尺寸变化
            guard let contentSize = change[.newKey] as? CGSize  else { break }
            guard contentSize.width > 0.0, contentSize.height > 0.0 else { break }
            if scrollView.mn.adjustmentInset == nil {
                // 未适配过顶部
                // 转换坐标系, 防止`scrollView`非原点布局
                var minY: CGFloat = 0.0
                if let superview = scrollView.superview {
                    minY = superview.convert(scrollView.frame, to: pageViewController.view).minY
                }
                // 头视图高度
                var headerHeight = 0.0
                if let dataSource = dataSource {
                    headerHeight = dataSource.subpageHeaderHeight
                }
                // 需要添加的高度
                let addition = max(0.0, headerHeight - minY)
                var contentInset = scrollView.contentInset
                if addition > 0.0 {
                    contentInset.top += addition
                    scrollView.contentInset = contentInset
                    scrollView.mn.adjustmentInset = addition
                    if let subpage = subpage(for: pageIndex, allowAccess: false) {
                        subpage.scrollViewDidChangeAdjustedContentInset?(scrollView)
                    }
                } else {
                    scrollView.mn.adjustmentInset = 0.0
                }
                // 某些情况下ScrollView未正确计算内容尺寸, 这里手动修改偏移, 会触发重新计算
                var contentOffset = scrollView.contentOffset
                contentOffset.y = -scrollView.contentInset.top
                scrollView.setContentOffset(contentOffset, animated: false)
                // 计算最小内容尺寸
                var greatestFiniteOffset: CGFloat = 0.0
                if let dataSource = dataSource {
                    greatestFiniteOffset = dataSource.subpageHeaderGreatestFiniteOffset
                }
                let offsetY = max(0.0, greatestFiniteOffset - minY)
                var size = scrollView.frame.size
                size.width = max(0.0, size.width - contentInset.left - contentInset.right)
                size.height = max(0.0, size.height - contentInset.top - contentInset.bottom + offsetY)
                scrollView.mn.leastContentSize = size
                if let subpage = subpage(for: pageIndex, allowAccess: false) {
                    subpage.scrollView?(scrollView, determinedMinimumContentSize: size)
                }
            }
            let leastContentSize = scrollView.mn.leastContentSize
            if contentSize.height >= leastContentSize.height, scrollView.mn.isReachedLeastSize == false {
                // 标记已满足最小内容尺寸
                scrollView.mn.isReachedLeastSize = true
                // 修改当前偏移量以满足页头视图的位置
                switch scrollView.mn.transitionState {
                case .willAppear, .didAppear, .willDisappear:
                    // 页面仍在显示
                    if let subpage = subpage(for: pageIndex, allowAccess: false) {
                        updateSubpageOffset(subpage)
                    }
                default: break
                }
            } else if contentSize.height < leastContentSize.height {
                // 标记未满足最小内容尺寸
                scrollView.mn.isReachedLeastSize = false
            }
        case #keyPath(UIScrollView.contentOffset):
            // 偏移量变化
            guard scrollView.mn.transitionState == .didAppear else { break }
            guard let contentOffset = change[.newKey] as? CGPoint  else { break }
            guard let delegate = delegate else { break }
            guard let subpage = subpage(for: pageIndex, allowAccess: false) else { break }
            delegate.pageViewController(pageViewController, subpage: subpage, didChangeContentOffset: contentOffset)
        default: break
        }
    }
}

// MARK: - Page
extension MNSegmentedPageCoordinator {
    
    /// 查找子页面缓存
    /// - Parameters:
    ///   - index: 页面索引
    ///   - allowAccess: 缓存不存在时，是否允许向外界获取页面
    /// - Returns: 子页面
    private func subpage(for index: Int, allowAccess: Bool = false) -> MNSegmentedSubpageConvertible? {
        if let subpage = subpages[index] { return subpage }
        guard allowAccess, let dataSource = dataSource, let subpage = dataSource.subpage(at: index) else { return nil }
        set(subpage: subpage, for: index)
        return subpage
    }
    
    /// 缓存子页面
    /// - Parameters:
    ///   - subpage: 子页面
    ///   - index: 页面索引
    private func set(subpage: MNSegmentedSubpageConvertible, for index: Int) {
        subpages[index] = subpage
        // 手动触发创建视图
        subpage.view.backgroundColor = subpage.view.backgroundColor
        let scrollView = subpage.preferredSubpageScrollView
        scrollView.mn.pageIndex = index
        scrollView.mn.transitionState = .unknown
        scrollView.mn.isReachedLeastSize = false
        switch configuration.orientation {
        case .horizontal:
            // 横向
            guard scrollView.mn.isObserved == false else { break }
            scrollView.mn.isObserved = true
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        default:
            // 纵向
            scrollView.bounces = false
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
        if let dataSource = dataSource {
            presentationCount = dataSource.numberOfPages
            presentationIndex = dataSource.currentPageIndex
        }
        guessToPageIndex = presentationIndex
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard presentationCount > 1, scrollView.isDragging else { return }
        var progress = 0.0
        let lastGuessToPageIndex = guessToPageIndex
        let currentOffset = configuration.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let pageDimension = configuration.orientation == .horizontal ? scrollView.frame.width : scrollView.frame.height
        if currentOffset > startOffset {
            let guessToIndex = presentationIndex + 1
            guard guessToIndex < presentationCount else { return }
            progress = (currentOffset - startOffset)/pageDimension + CGFloat(presentationIndex)
            guessToPageIndex = guessToIndex
        } else if currentOffset < startOffset {
            let guessToIndex = presentationIndex - 1
            guard guessToIndex >= 0 else { return }
            progress = CGFloat(presentationIndex) - (startOffset - currentOffset)/pageDimension
            guessToPageIndex = guessToIndex
        }
        if guessToPageIndex != lastGuessToPageIndex {
            // 页面切换
            if let guessToPage = subpage(for: guessToPageIndex, allowAccess: false) {
                guessToPage.preferredSubpageScrollView.mn.transitionState = .willAppear
                updateSubpageOffset(guessToPage)
            }
            if let lastGuessToPage = subpage(for: lastGuessToPageIndex, allowAccess: false) {
                lastGuessToPage.preferredSubpageScrollView.mn.transitionState = .willDisappear
            }
        }
        if let delegate = scrollDelegate {
            delegate.pageViewController(pageViewController, didScroll: progress)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard presentationCount > 1 else { return }
        let contentOffset = targetContentOffset.pointee
        let targetOffset = configuration.orientation == .horizontal ? contentOffset.x : contentOffset.y
        var targetPageIndex = presentationIndex
        if targetOffset > startOffset {
            targetPageIndex += 1
        } else if targetOffset < startOffset {
            targetPageIndex -= 1
        }
        if let delegate = scrollDelegate {
            delegate.pageViewController(pageViewController, willScrollToSubpageAt: targetPageIndex)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard presentationCount > 1 else { return }
        scrollView.isUserInteractionEnabled = false
        guard decelerate == false else { return }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard presentationCount > 1 else { return }
        scrollView.isUserInteractionEnabled = true
        let currentOffset = configuration.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        var currentPageIndex = presentationIndex
        if currentOffset > startOffset {
            currentPageIndex += 1
        } else if currentOffset < startOffset {
            currentPageIndex -= 1
        }
        // 确定当前页面状态
        if let currentPage = subpage(for: currentPageIndex, allowAccess: false) {
            currentPage.preferredSubpageScrollView.mn.transitionState = .didAppear
        }
        if currentPageIndex == presentationIndex {
            // 又滑动回来了
            if let guessToPage = subpage(for: guessToPageIndex, allowAccess: false) {
                let scrollView = guessToPage.preferredSubpageScrollView
                if scrollView.mn.pageIndex != presentationIndex {
                    scrollView.mn.transitionState = .didDisappear
                }
            }
        } else {
            // 页面已切换
            if let lastPresentationPage = subpage(for: presentationIndex, allowAccess: false) {
                lastPresentationPage.preferredSubpageScrollView.mn.transitionState = .didDisappear
            }
            // 告知外界
            if let delegate = delegate, let subpage = subpage(for: currentPageIndex, allowAccess: false) {
                delegate.pageViewController(pageViewController, didScrollTo: subpage)
            }
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension MNSegmentedPageCoordinator: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let subpage = viewController as? MNSegmentedSubpageConvertible else { return nil }
        let pageIndex = subpage.preferredSubpageScrollView.mn.pageIndex
        guard pageIndex > 0 else { return nil }
        return self.subpage(for: pageIndex - 1, allowAccess: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let dataSource = dataSource else { return nil }
        let numberOfPages = dataSource.numberOfPages
        guard let subpage = viewController as? MNSegmentedSubpageConvertible else { return nil }
        let pageIndex = subpage.preferredSubpageScrollView.mn.pageIndex
        guard pageIndex < numberOfPages - 1 else { return nil }
        return self.subpage(for: pageIndex + 1, allowAccess: true)
    }
}

// MARK: - UIPageViewControllerDelegate
extension MNSegmentedPageCoordinator: UIPageViewControllerDelegate {
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        
        [.portrait]
    }
    
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        
        .portrait
    }
}
