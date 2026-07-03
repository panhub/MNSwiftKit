//
//  MNSegmentedPageCoordinator.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit
import Foundation
import CoreFoundation

/// 页面协调器数据源代理
public protocol MNSegmentedPageDataSource: NSObject {
    
    /// 当前选择的索引
    var pageIndex: Int { get }
    
    /// 子页面数量
    var numberOfPages: Int { get }
    
    /// 页头高度
    var pageHeaderHeight: CGFloat { get }
    
    /// 页头最大偏移量
    var pageHeaderGreatestFiniteOffset: CGFloat { get }
    
    /// 询问页面偏移量
    /// - Parameters:
    ///   - page: 页面
    ///   - direction: 滑动方向(纵向有效)
    /// - Returns: 页面偏移量
    func contentOffset(for page: MNSegmentedPageScrollSupported, direction: UIPageViewController.NavigationDirection) -> CGPoint
    
    /// 获取页面
    /// - Parameter index: 页面索引
    /// - Returns: 页面
    func page(at index: Int) -> UIViewController?
}

/// 页面协调器滑动代理
protocol MNSegmentedPageScrollDelegate: NSObject {
    
    /// 分页控制器即将滑动
    func pageViewControllerWillBeginDragging()
    
    /// 分页控制器滑动中
    /// - Parameter ratio: 滑动比率
    func pageViewControllerDidScroll(_ ratio: CGFloat)
    
    /// 分页控制器即将滑动到子页面
    /// - Parameter index: 子页面索引
    func pageViewControllerWillScrollToPage(_ index: Int)
}

/// 页面协调器事件代理
protocol MNSegmentedPageDelegate: MNSegmentedPageScrollDelegate {
    
    /// 分页控制器已切换当前页面
    /// - Parameter page: 当前页面
    func pageViewControllerDidScrollTo(_ page: UIViewController)
    
    /// 当前页面内容偏移量变化
    /// - Parameters:
    ///   - page: 页面
    ///   - contentOffset: 内容偏移量
    func pageViewController(_ page: MNSegmentedPageScrollSupported, didChangeContentOffset contentOffset: CGPoint)
}

/// 子页面协调器
class MNSegmentedPageCoordinator: NSObject {
    /// 分页控制器内部滑动视图
    private var scrollView: UIScrollView!
    /// 猜想将要滑动到的界面索引
    private var targetPageIndex: Int = 0
    /// 当前展示的子页面索引
    private var presentationIndex: Int = 0
    /// 子页面数量
    private var presentationCount: Int = 0
    /// 开始滑动时分页控制器内部滑动视图的偏移量
    private var startOffset: CGFloat = 0.0
    /// 响应滚动事件
    private var shouldRespondToScroll: Bool = false
    /// 配置信息
    private let configuration: MNSegmentedConfiguration
    /// 分页控制器
    private let pageViewController: UIPageViewController
    /// 子页面缓存
    private var pages: [Int : UIViewController] = [:]
    /// 事件代理
    weak var delegate: MNSegmentedPageDelegate?
    /// 数据源
    weak var dataSource: MNSegmentedPageDataSource?
    /// 是否在滑动(或衰减状态)
    var isScrolling: Bool {
        guard let scrollView = scrollView else { return false }
        if #available(iOS 17.4, *), scrollView.isScrollAnimating { return true }
        return scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating
    }
    /// 外界指定是否允许滑动
    var isScrollEnabled: Bool {
        get {
            guard let scrollView = scrollView else { return false }
            return scrollView.isScrollEnabled
        }
        set {
            guard let scrollView = scrollView else { return }
            scrollView.isScrollEnabled = newValue
        }
    }
    
    /// 构造页面协调器
    /// - Parameters:
    ///   - pageViewController: 分页控制器
    ///   - configuration: 配置信息
    init(pageViewController: UIPageViewController, configuration: MNSegmentedConfiguration) {
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
            scrollView.backgroundColor = .clear
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            self.scrollView = scrollView
            break
        }
    }
    
    deinit {
        // 删除监听
        invalidatePage()
    }
    
    /// 手动设置当前展示的页面
    /// - Parameters:
    ///   - index: 页面索引
    ///   - direction: 页面切换方向
    ///   - animated: 是否动态展示
    func setPage(at index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        guard let page = page(for: index, access: true) else { return }
        page.mn.pageTransitionState = .willAppear
        if page is MNSegmentedPageScrollSupported {
            updatePageOffset(page as! MNSegmentedPageScrollSupported, direction: direction)
        }
        var lastPresentationPage: UIViewController!
        if let viewControllers = pageViewController.viewControllers, let presentationPage = viewControllers.first, presentationPage.mn.pageIndex != page.mn.pageIndex {
            lastPresentationPage = presentationPage
            presentationPage.mn.pageTransitionState = .willDisappear
        }
        pageViewController.setViewControllers([page], direction: direction, animated: animated) { [weak self] _ in
            page.mn.pageTransitionState = .didAppear
            if let lastPresentationPage = lastPresentationPage {
                lastPresentationPage.mn.pageTransitionState = .didDisappear
            }
            guard let self = self else { return }
            // 确保可交互，避免滑动事件问题引起不可交互
            if let scrollView = self.scrollView {
                scrollView.isUserInteractionEnabled = true
            }
            // 告知界面切换
            if let delegate = self.delegate {
                delegate.pageViewControllerDidScrollTo(page)
            }
        }
    }
    
    /// 更新子页面偏移量
    /// - Parameters:
    ///   - page: 页面
    ///   - direction: 滑动方向(纵向有效)
    private func updatePageOffset(_ page: MNSegmentedPageScrollSupported, direction: UIPageViewController.NavigationDirection) {
        guard let dataSource = dataSource else { return }
        let scrollView = page.preferredPageScrollView
        let contentOffset = scrollView.contentOffset
        let targetOffset = dataSource.contentOffset(for: page, direction: direction)
        if targetOffset == contentOffset { return }
        scrollView.setContentOffset(targetOffset, animated: false)
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
            if scrollView.mn.pageTopInset == nil {
                // 未适配头视图高度
                var headerHeight = 0.0
                if let dataSource = dataSource {
                    headerHeight = dataSource.pageHeaderHeight
                }
                // 转换坐标系, 防止`scrollView`非原点布局
                var minY: CGFloat = 0.0
                if let superview = scrollView.superview, let page = page(for: pageIndex, access: false) {
                    minY = superview.convert(scrollView.frame, to: page.view).minY
                }
                // 需要添加的高度
                let adjustmentInset = max(0.0, headerHeight - minY)
                var contentInset = scrollView.contentInset
                if adjustmentInset > 0.0 {
                    contentInset.top += adjustmentInset
                    scrollView.contentInset = contentInset
                    scrollView.mn.pageTopInset = adjustmentInset
                    if let page = page(for: pageIndex, access: false) as? MNSegmentedPageScrollSupported {
                        page.pageScrollViewDidChangeAdjustedContentInset?(scrollView)
                    }
                } else {
                    scrollView.mn.pageTopInset = 0.0
                }
                // 为避免ScrollView未计算内容尺寸, 这里手动修改偏移
                var contentOffset = scrollView.contentOffset
                contentOffset.y = -scrollView.contentInset.top
                scrollView.setContentOffset(contentOffset, animated: false)
                // 计算最小内容尺寸
                var greatestFiniteOffset: CGFloat = 0.0
                if let dataSource = dataSource {
                    greatestFiniteOffset = dataSource.pageHeaderGreatestFiniteOffset
                }
                let offsetY = max(0.0, greatestFiniteOffset - minY)
                var size = scrollView.frame.size
                size.width = max(0.0, size.width - contentInset.left - contentInset.right)
                size.height = max(0.0, size.height - contentInset.top - contentInset.bottom + offsetY)
                scrollView.mn.minimumPageSize = size
                if let page = page(for: pageIndex, access: false) as? MNSegmentedPageScrollSupported {
                    page.pageScrollView?(scrollView, determinedMinimumContentSize: size)
                }
            }
            let minimumPageSize = scrollView.mn.minimumPageSize
            if contentSize.height >= minimumPageSize.height, scrollView.mn.isPageHeaderScrollEnabled == false {
                // 标记已满足最小内容尺寸
                scrollView.mn.isPageHeaderScrollEnabled = true
                // 修改当前偏移量以满足页头视图的位置
                guard let page = page(for: pageIndex, access: false) else { break }
                switch page.mn.pageTransitionState {
                case .willAppear, .didAppear, .willDisappear:
                    // 页面未完全消失
                    if page is MNSegmentedPageScrollSupported {
                        updatePageOffset(page as! MNSegmentedPageScrollSupported, direction: .forward)
                    }
                default: break
                }
            } else if contentSize.height < minimumPageSize.height {
                // 标记未满足最小内容尺寸
                scrollView.mn.isPageHeaderScrollEnabled = false
            }
        case #keyPath(UIScrollView.contentOffset):
            // 偏移量变化
            guard let contentOffset = change[.newKey] as? CGPoint  else { break }
            guard let delegate = delegate else { break }
            guard let page = page(for: pageIndex, access: false) else { break }
            guard page.mn.pageTransitionState == .didAppear else { break }
            guard page is MNSegmentedPageScrollSupported else { break }
            delegate.pageViewController(page as! MNSegmentedPageScrollSupported, didChangeContentOffset: contentOffset)
        default: break
        }
    }
}

// MARK: - Page
extension MNSegmentedPageCoordinator {
    
    /// 查找子页面缓存
    /// - Parameters:
    ///   - index: 页面索引
    ///   - access: 缓存不存在时，是否允许向外界获取页面
    /// - Returns: 子页面
    func page(for index: Int, access: Bool) -> UIViewController? {
        if let page = pages[index] { return page }
        guard access, let dataSource = dataSource, let page = dataSource.page(at: index) else { return nil }
        setPage(page, for: index)
        return page
    }
    
    /// 缓存子页面
    /// - Parameters:
    ///   - page: 子页面
    ///   - index: 页面索引
    func setPage(_ page: UIViewController, for index: Int) {
        // 缓存新页面
        pages[index] = page
        page.loadViewIfNeeded()
        page.mn.pageIndex = index
        guard let page = page as? MNSegmentedPageScrollSupported else { return }
        let scrollView = page.preferredPageScrollView
        scrollView.mn.pageIndex = index
        scrollView.mn.isPageHeaderScrollEnabled = false
        switch configuration.navigation.orientation {
        case .horizontal:
            // 横向
            guard scrollView.mn.isObservedPage == false else { break }
            scrollView.mn.isObservedPage = true
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        default:
            // 纵向
            scrollView.bounces = false
        }
    }
    
    /// 删除子页面
    /// - Parameter index: 子页面索引
    func invalidatePage(at index: Int? = nil) {
        if let index = index {
            guard let page = pages.removeValue(forKey: index) as? MNSegmentedPageScrollSupported else { return }
            invalidatePage(page)
        } else {
            pages.values.compactMap {
                $0 as? MNSegmentedPageScrollSupported
            }.forEach {
                invalidatePage($0)
            }
            pages.removeAll()
        }
    }
    
    /// 使界面无效(解除页面监听)，一般需要配合设置界面使用
    /// - Parameter page: 页面
    private func invalidatePage(_ page: MNSegmentedPageScrollSupported) {
        let scrollView = page.preferredPageScrollView
        if scrollView.mn.isObservedPage {
            scrollView.mn.isObservedPage = false
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
        if let pageTopInset = scrollView.mn.pageTopInset, pageTopInset > 0.0 {
            scrollView.mn.pageTopInset = nil
            var contentInset = scrollView.contentInset
            contentInset.top -= pageTopInset
            scrollView.contentInset = contentInset
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MNSegmentedPageCoordinator: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let startOffsetKey = configuration.navigation.orientation == .horizontal ? "startOffsetX" : "startOffsetY"
        if let value = scrollView.value(forKey: startOffsetKey) as? CGFloat {
            startOffset = value
        } else {
            startOffset = configuration.navigation.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        }
        if let delegate = delegate {
            delegate.pageViewControllerWillBeginDragging()
        }
        if let dataSource = dataSource {
            presentationIndex = dataSource.pageIndex
            presentationCount = dataSource.numberOfPages
        }
        shouldRespondToScroll = true
        targetPageIndex = presentationIndex
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard presentationCount > 1, shouldRespondToScroll else { return }
        var progress = 0.0
        let lastTargetIndex = targetPageIndex
        let currentOffset = configuration.navigation.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let pageDimension = configuration.navigation.orientation == .horizontal ? scrollView.frame.width : scrollView.frame.height
        if currentOffset > startOffset {
            let guessToIndex = presentationIndex + 1
            guard guessToIndex < presentationCount else { return }
            progress = (currentOffset - startOffset)/pageDimension + CGFloat(presentationIndex)
            targetPageIndex = guessToIndex
        } else if currentOffset < startOffset {
            let guessToIndex = presentationIndex - 1
            guard guessToIndex >= 0 else { return }
            progress = CGFloat(presentationIndex) - (startOffset - currentOffset)/pageDimension
            targetPageIndex = guessToIndex
        } else {
            // 两侧无效滑动
            progress = CGFloat(targetPageIndex)
        }
        if targetPageIndex != lastTargetIndex {
            // 页面切换, 这里要创建新界面, 修改页面状态
            if let targetPage = page(for: targetPageIndex, access: true) {
                targetPage.mn.pageTransitionState = .willAppear
                if targetPage is MNSegmentedPageScrollSupported {
                    updatePageOffset(targetPage as! MNSegmentedPageScrollSupported, direction: targetPageIndex > lastTargetIndex ? .forward : .reverse)
                }
            }
            if let lastTargetPage = page(for: lastTargetIndex, access: false) {
                lastTargetPage.mn.pageTransitionState = .willDisappear
            }
        }
        if let delegate = delegate {
            delegate.pageViewControllerDidScroll(progress)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard presentationCount > 1 else { return }
        shouldRespondToScroll = false
        let contentOffset = targetContentOffset.pointee
        let targetOffset = configuration.navigation.orientation == .horizontal ? contentOffset.x : contentOffset.y
        var targetToIndex = presentationIndex
        if targetOffset > startOffset {
            targetToIndex += 1
        } else if targetOffset < startOffset {
            targetToIndex -= 1
        }
        if let delegate = delegate {
            delegate.pageViewControllerWillScrollToPage(targetToIndex)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        // FIX: 界面在衰减状态就开始新的滑动，导致页码计算错误，引发一系列未知Bug
        scrollView.isUserInteractionEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = true
    }
}

// MARK: - UIPageViewControllerDataSource
extension MNSegmentedPageCoordinator: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageIndex = viewController.mn.pageIndex
        guard pageIndex > 0 else { return nil }
        return page(for: pageIndex - 1, access: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let dataSource = dataSource else { return nil }
        let numberOfPages = dataSource.numberOfPages
        let pageIndex = viewController.mn.pageIndex
        guard pageIndex < numberOfPages - 1 else { return nil }
        return page(for: pageIndex + 1, access: true)
    }
}

// MARK: - UIPageViewControllerDelegate
extension MNSegmentedPageCoordinator: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let viewController = viewControllers.first else { return }
        let currentPageIndex = viewController.mn.pageIndex
        // 排除两侧无效滑动后为当前页面修改状态
        if targetPageIndex != presentationIndex {
            viewController.mn.pageTransitionState = .didAppear
        }
        if currentPageIndex == presentationIndex {
            // 又滑动回来了
            if targetPageIndex != presentationIndex, let targetToPage = page(for: targetPageIndex, access: false) {
                targetToPage.mn.pageTransitionState = .didDisappear
            }
        } else {
            // 页面已切换
            if let lastPresentationPage = page(for: presentationIndex, access: false) {
                lastPresentationPage.mn.pageTransitionState = .didDisappear
            }
            if currentPageIndex != targetPageIndex, let targetToPage = page(for: targetPageIndex, access: false) {
                targetToPage.mn.pageTransitionState = .didDisappear
#if DEBUG
                print("⚠️分段控制器模块 \(#file) \(#function) 子界面切换有问题⚠️")
#endif
            }
            // 告知界面切换
            if let delegate = delegate, let currentPage = viewController as? MNSegmentedPageScrollSupported {
                delegate.pageViewControllerDidScrollTo(currentPage)
            }
        }
    }
}
