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
public protocol MNSegmentedPageCoordinatorDataSource: NSObject {
    
    /// 当前选择的索引
    var currentPageIndex: Int { get }
    
    /// 子页面数量
    var numberOfPages: Int { get }
    
    /// 页头高度
    var subpageHeaderHeight: CGFloat { get }
    
    /// 页头最大偏移量
    var subpageHeaderGreatestFiniteOffset: CGFloat { get }
    
    /// 询问页面偏移合适
    /// - Parameter subpage: 子界面
    /// - Returns: 子页面偏移量
    func contentOffset(for subpage: MNSegmentedSubpageConvertible) -> CGPoint
    
    /// 获取子界面
    /// - Parameter index: 界面索引
    /// - Returns: 子界面
    func subpage(at index: Int) -> MNSegmentedSubpageConvertible?
}

/// 页面协调器事件代理
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

/// 页面协调器滑动代理
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
    /// 分页控制器内部滑动视图
    private var scrollView: UIScrollView!
    /// 当前展示的子页面索引
    private var presentationIndex: Int = 0
    /// 子页面数量
    private var presentationCount: Int = 0
    /// 猜想将要滑动到的界面索引
    private var guessToPageIndex: Int = 0
    /// 开始滑动时分页控制器内部滑动视图的偏移量
    private var startOffset: CGFloat = 0.0
    /// 响应滚动事件
    private var shouldRespondToScroll: Bool = false
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
    /// 是否在滑动
    var isScrolling: Bool {
        guard let scrollView = scrollView else { return false }
        return scrollView.isDragging || scrollView.isDecelerating
    }
    
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
        removeSubpage(at: nil)
    }
    
    /// 手动设置当前展示的页面
    /// - Parameters:
    ///   - index: 页面索引
    ///   - direction: 页面切换方向
    ///   - animated: 是否动态展示
    func setPage(at index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        guard let subpage = subpage(for: index, allowAccess: true) else { return }
        subpage.preferredSubpageScrollView.mn.transitionState = .willAppear
        var lastPresentationPage: MNSegmentedSubpageConvertible!
        if let viewControllers = pageViewController.viewControllers, let viewController = viewControllers.first, let presentationPage = viewController as? MNSegmentedSubpageConvertible, presentationPage.preferredSubpageScrollView.mn.pageIndex != subpage.preferredSubpageScrollView.mn.pageIndex {
            lastPresentationPage = presentationPage
            presentationPage.preferredSubpageScrollView.mn.transitionState = .willDisappear
        }
        pageViewController.setViewControllers([subpage], direction: direction, animated: animated) { _ in
            subpage.preferredSubpageScrollView.mn.transitionState = .didAppear
            if let lastPresentationPage = lastPresentationPage {
                lastPresentationPage.preferredSubpageScrollView.mn.transitionState = .didDisappear
            }
        }
    }
    
    /// 更新子页面偏移量
    /// - Parameter subpage: 子页面
    private func updateSubpageOffset(_ subpage: MNSegmentedSubpageConvertible) {
        guard let dataSource = dataSource else { return }
        let contentOffset = dataSource.contentOffset(for: subpage)
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
            //print(contentSize)
            if scrollView.mn.adjustmentInset == nil {
                // 未适配过顶部
                // 转换坐标系, 防止`scrollView`非原点布局
                var minY: CGFloat = 0.0
                if let superview = scrollView.superview, let subpage = subpage(for: pageIndex, allowAccess: false) {
                    minY = superview.convert(scrollView.frame, to: subpage.view).minY
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
    func subpage(for index: Int, allowAccess: Bool = false) -> MNSegmentedSubpageConvertible? {
        if let subpage = subpages[index] { return subpage }
        guard allowAccess, let dataSource = dataSource, let subpage = dataSource.subpage(at: index) else { return nil }
        setSubpage(subpage, for: index)
        return subpage
    }
    
    /// 缓存子页面
    /// - Parameters:
    ///   - subpage: 子页面
    ///   - index: 页面索引
    func setSubpage(_ subpage: MNSegmentedSubpageConvertible, for index: Int) {
        // 缓存新页面
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
    
    /// 删除子页面
    /// - Parameter index: 子页面索引
    func removeSubpage(at index: Int?) {
        if let index = index {
            guard let subpage = subpages[index] else { return }
            invalidSubpage(subpage)
            subpages[index] = nil
        } else {
            subpages.values.forEach { invalidSubpage($0) }
            subpages.removeAll()
        }
    }
    
    /// 解除子页面监听
    /// - Parameter subpage: 子页面
    private func invalidSubpage(_ subpage: MNSegmentedSubpageConvertible) {
        let scrollView = subpage.preferredSubpageScrollView
        if scrollView.mn.isObserved {
            scrollView.mn.isObserved = false
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
        if let adjustmentInset = scrollView.mn.adjustmentInset, adjustmentInset > 0.0 {
            scrollView.mn.adjustmentInset = nil
            var contentInset = scrollView.contentInset
            contentInset.top -= adjustmentInset
            scrollView.contentInset = contentInset
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
        shouldRespondToScroll = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard presentationCount > 1, shouldRespondToScroll else { return }
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
            if let guessToPage = subpage(for: guessToPageIndex, allowAccess: true) {
                let scrollView = guessToPage.preferredSubpageScrollView
                scrollView.mn.transitionState = .willAppear
                if scrollView.mn.isReachedLeastSize {
                    updateSubpageOffset(guessToPage)
                }
                print("=========\(guessToPage.preferredSubpageScrollView.mn.pageIndex) willAppear=========")
            }
            if let lastGuessToPage = subpage(for: lastGuessToPageIndex, allowAccess: false) {
                lastGuessToPage.preferredSubpageScrollView.mn.transitionState = .willDisappear
                print("=========\(lastGuessToPage.preferredSubpageScrollView.mn.pageIndex) willDisappear=========")
            }
        }
        if let delegate = scrollDelegate {
            delegate.pageViewController(pageViewController, didScroll: progress)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard presentationCount > 1 else { return }
        shouldRespondToScroll = false
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let viewController = viewControllers.first else { return }
        guard let currentPage = viewController as? MNSegmentedSubpageConvertible else { return }
        let currentPageIndex = currentPage.preferredSubpageScrollView.mn.pageIndex
        // 确定当前页面状态
        if guessToPageIndex != presentationIndex {
            // 这里排除无效滑动
            currentPage.preferredSubpageScrollView.mn.transitionState = .didAppear
            print("=========\(currentPage.preferredSubpageScrollView.mn.pageIndex) didAppear=========")
        }
        if currentPageIndex == presentationIndex {
            // 又滑动回来了
            if guessToPageIndex != presentationIndex, let guessToPage = subpage(for: guessToPageIndex, allowAccess: false) {
                guessToPage.preferredSubpageScrollView.mn.transitionState = .didDisappear
                print("=========\(guessToPage.preferredSubpageScrollView.mn.pageIndex) didDisappear=========")
            }
        } else {
            // 页面已切换
            if let lastPresentationPage = subpage(for: presentationIndex, allowAccess: false) {
                lastPresentationPage.preferredSubpageScrollView.mn.transitionState = .didDisappear
                print("=========\(lastPresentationPage.preferredSubpageScrollView.mn.pageIndex) didDisappear=========")
            }
            if currentPageIndex != guessToPageIndex, let guessToPage = subpage(for: guessToPageIndex, allowAccess: false) {
                guessToPage.preferredSubpageScrollView.mn.transitionState = .didDisappear
#if DEBUG
                print("⚠️⚠️⚠️⚠️⚠️PageViewController界面切换有问题⚠️⚠️⚠️⚠️⚠️")
#endif
            }
            // 告知界面切换
            if let delegate = delegate {
                delegate.pageViewController(pageViewController, didScrollTo: currentPage)
            }
        }
    }
    
    func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask {
        
        [.portrait]
    }
    
    func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation {
        
        .portrait
    }
}
