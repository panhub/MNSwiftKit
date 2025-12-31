//
//  MNSegmentedSubpageCoordinator.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit
import Foundation
import CoreFoundation

/// 页面协调器数据源代理
public protocol MNSegmentedSubpageDataSource: NSObject {
    
    /// 当前选择的索引
    var subpageIndex: Int { get }
    
    /// 子页面数量
    var numberOfSubpages: Int { get }
    
    /// 页头高度
    var subpageHeaderHeight: CGFloat { get }
    
    /// 页头最大偏移量
    var subpageHeaderGreatestFiniteOffset: CGFloat { get }
    
    /// 询问页面偏移量
    /// - Parameters:
    ///   - subpage: 子界面
    ///   - direction: 滑动方向(纵向有效)
    /// - Returns: 子页面偏移量
    func contentOffset(for subpage: MNSegmentedSubpageConvertible, direction: UIPageViewController.NavigationDirection) -> CGPoint
    
    /// 获取子界面
    /// - Parameter index: 界面索引
    /// - Returns: 子界面
    func subpage(at index: Int) -> MNSegmentedSubpageConvertible?
}

/// 页面协调器事件代理
protocol MNSegmentedSubpageDelegate: NSObject {
    
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
protocol MNSegmentedSubpageScrolling: NSObject {
    
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

/// 子页面协调器
class MNSegmentedSubpageCoordinator: NSObject {
    /// 分页控制器内部滑动视图
    private var scrollView: UIScrollView!
    /// 猜想将要滑动到的界面索引
    private var targetIndex: Int = 0
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
    private var subpages: [Int : MNSegmentedSubpageConvertible] = [:]
    /// 滑动代理
    weak var scrolling: MNSegmentedSubpageScrolling?
    /// 事件代理
    weak var delegate: MNSegmentedSubpageDelegate?
    /// 数据源
    weak var dataSource: MNSegmentedSubpageDataSource?
    /// 是否在滑动
    var isScrolling: Bool {
        guard let scrollView = scrollView else { return false }
        if #available(iOS 17.4, *), scrollView.isScrollAnimating { return true }
        return scrollView.isDragging || scrollView.isDecelerating
    }
    /// 是否允许滑动
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
        invalidateSubpage()
    }
    
    /// 手动设置当前展示的页面
    /// - Parameters:
    ///   - index: 页面索引
    ///   - direction: 页面切换方向
    ///   - animated: 是否动态展示
    func setSubpage(at index: Int, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        guard let subpage = subpage(for: index, allowAccess: true) else { return }
        subpage.subpageState = .willAppear
        var lastPresentationPage: MNSegmentedSubpageConvertible!
        if let viewControllers = pageViewController.viewControllers, let viewController = viewControllers.first, let presentationPage = viewController as? MNSegmentedSubpageConvertible, presentationPage.subpageIndex != subpage.subpageIndex {
            lastPresentationPage = presentationPage
            presentationPage.subpageState = .willDisappear
        }
        pageViewController.setViewControllers([subpage], direction: direction, animated: animated) { _ in
            subpage.subpageState = .didAppear
            if let lastPresentationPage = lastPresentationPage {
                lastPresentationPage.subpageState = .didDisappear
            }
        }
    }
    
    /// 更新子页面偏移量
    /// - Parameters:
    ///   - subpage: 子页面
    ///   - direction: 滑动方向(纵向有效)
    private func updateSubpageOffset(_ subpage: MNSegmentedSubpageConvertible, direction: UIPageViewController.NavigationDirection) {
        guard let dataSource = dataSource else { return }
        guard let scrollView = subpage.preferredSubpageScrollView else { return }
        let contentOffset = scrollView.contentOffset
        let targetOffset = dataSource.contentOffset(for: subpage, direction: direction)
        if targetOffset == contentOffset { return }
        scrollView.setContentOffset(targetOffset, animated: false)
    }
    
    // MARK: - Observe
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object = object, let scrollView = object as? UIScrollView else { return }
        guard let keyPath = keyPath, let change = change else { return }
        let pageIndex = scrollView.mn.subpageIndex
        switch keyPath {
        case #keyPath(UIScrollView.contentSize):
            // 页面内容尺寸变化
            guard let contentSize = change[.newKey] as? CGSize  else { break }
            guard contentSize.width > 0.0, contentSize.height > 0.0 else { break }
            //print(contentSize)
            if scrollView.mn.adjustedInset == nil {
                // 未适配过顶部
                // 头视图高度
                var headerHeight = 0.0
                if let dataSource = dataSource {
                    headerHeight = dataSource.subpageHeaderHeight
                }
                // 转换坐标系, 防止`scrollView`非原点布局
                var minY: CGFloat = 0.0
                if let superview = scrollView.superview, let subpage = subpage(for: pageIndex, allowAccess: false) {
                    minY = superview.convert(scrollView.frame, to: subpage.view).minY
                }
                // 需要添加的高度
                let adjustmentInset = max(0.0, headerHeight - minY)
                var contentInset = scrollView.contentInset
                if adjustmentInset > 0.0 {
                    contentInset.top += adjustmentInset
                    scrollView.contentInset = contentInset
                    scrollView.mn.adjustedInset = adjustmentInset
                    if let subpage = subpage(for: pageIndex, allowAccess: false) {
                        subpage.scrollViewDidChangeAdjustedContentInset?(scrollView)
                    }
                } else {
                    scrollView.mn.adjustedInset = 0.0
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
                scrollView.mn.minimumContentSize = size
                if let subpage = subpage(for: pageIndex, allowAccess: false) {
                    subpage.scrollView?(scrollView, determinedMinimumContentSize: size)
                }
            }
            let minimumContentSize = scrollView.mn.minimumContentSize
            if contentSize.height >= minimumContentSize.height, scrollView.mn.isReachedMinimumSize == false {
                // 标记已满足最小内容尺寸
                scrollView.mn.isReachedMinimumSize = true
                // 修改当前偏移量以满足页头视图的位置
                guard let subpage = subpage(for: pageIndex, allowAccess: false) else { break }
                switch subpage.subpageState {
                case .willAppear, .didAppear, .willDisappear:
                    // 页面未完全消失
                    updateSubpageOffset(subpage, direction: .forward)
                default: break
                }
            } else if contentSize.height < minimumContentSize.height {
                // 标记未满足最小内容尺寸
                scrollView.mn.isReachedMinimumSize = false
            }
        case #keyPath(UIScrollView.contentOffset):
            // 偏移量变化
            guard let contentOffset = change[.newKey] as? CGPoint  else { break }
            guard let delegate = delegate else { break }
            guard let subpage = subpage(for: pageIndex, allowAccess: false) else { break }
            guard subpage.subpageState == .didAppear else { break }
            delegate.pageViewController(pageViewController, subpage: subpage, didChangeContentOffset: contentOffset)
        default: break
        }
    }
}

// MARK: - Page
extension MNSegmentedSubpageCoordinator {
    
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
        subpage.subpageIndex = index
        subpage.view.backgroundColor = subpage.view.backgroundColor
        guard let scrollView = subpage.preferredSubpageScrollView else { return }
        scrollView.mn.subpageIndex = index
        scrollView.mn.isReachedMinimumSize = false
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
    func invalidateSubpage(at index: Int? = nil) {
        if let index = index {
            guard let subpage = subpages[index] else { return }
            invalidateSubpage(subpage)
            subpages[index] = nil
        } else {
            subpages.values.forEach { invalidateSubpage($0) }
            subpages.removeAll()
        }
    }
    
    /// 使子界面无效(解除子页面监听)，一般需要配合设置界面使用
    /// - Parameter subpage: 子页面
    private func invalidateSubpage(_ subpage: MNSegmentedSubpageConvertible) {
        guard let scrollView = subpage.preferredSubpageScrollView else { return }
        if scrollView.mn.isObserved {
            scrollView.mn.isObserved = false
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
        if let adjustedInset = scrollView.mn.adjustedInset, adjustedInset > 0.0 {
            scrollView.mn.adjustedInset = nil
            var contentInset = scrollView.contentInset
            contentInset.top -= adjustedInset
            scrollView.contentInset = contentInset
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MNSegmentedSubpageCoordinator: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let key = configuration.orientation == .horizontal ? "startOffsetX" : "startOffsetY"
        if let value = scrollView.value(forKey: key) as? CGFloat {
            startOffset = value
        } else {
            startOffset = configuration.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        }
        if let dataSource = dataSource {
            presentationIndex = dataSource.subpageIndex
            presentationCount = dataSource.numberOfSubpages
        }
        targetIndex = presentationIndex
        shouldRespondToScroll = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard presentationCount > 1, shouldRespondToScroll else { return }
        var progress = 0.0
        let lastTargetIndex = targetIndex
        let currentOffset = configuration.orientation == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let pageDimension = configuration.orientation == .horizontal ? scrollView.frame.width : scrollView.frame.height
        if currentOffset > startOffset {
            let guessToIndex = presentationIndex + 1
            guard guessToIndex < presentationCount else { return }
            progress = (currentOffset - startOffset)/pageDimension + CGFloat(presentationIndex)
            targetIndex = guessToIndex
        } else if currentOffset < startOffset {
            let guessToIndex = presentationIndex - 1
            guard guessToIndex >= 0 else { return }
            progress = CGFloat(presentationIndex) - (startOffset - currentOffset)/pageDimension
            targetIndex = guessToIndex
        } else {
            // 两侧无效滑动
            progress = CGFloat(targetIndex)
        }
        if targetIndex != lastTargetIndex {
            // 页面切换, 这里要创建新界面, 修改页面状态
            if let targetSubpage = subpage(for: targetIndex, allowAccess: true) {
                targetSubpage.subpageState = .willAppear
                updateSubpageOffset(targetSubpage, direction: targetIndex > lastTargetIndex ? .forward : .reverse)
            }
            if let lastTargetSubpage = subpage(for: lastTargetIndex, allowAccess: false) {
                lastTargetSubpage.subpageState = .willDisappear
            }
        }
        if let scrolling = scrolling {
            scrolling.pageViewController(pageViewController, didScroll: progress)
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
        if let scrolling = scrolling {
            scrolling.pageViewController(pageViewController, willScrollToSubpageAt: targetPageIndex)
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension MNSegmentedSubpageCoordinator: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageIndex = viewController.mn.subpageIndex
        guard pageIndex > 0 else { return nil }
        return subpage(for: pageIndex - 1, allowAccess: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let dataSource = dataSource else { return nil }
        let numberOfSubpages = dataSource.numberOfSubpages
        let pageIndex = viewController.mn.subpageIndex
        guard pageIndex < numberOfSubpages - 1 else { return nil }
        return subpage(for: pageIndex + 1, allowAccess: true)
    }
}

// MARK: - UIPageViewControllerDelegate
extension MNSegmentedSubpageCoordinator: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let viewController = viewControllers.first else { return }
        let currentSubpageIndex = viewController.mn.subpageIndex
        // 排除两侧无效滑动后为当前页面修改状态
        if targetIndex != presentationIndex {
            viewController.mn.subpageState = .didAppear
        }
        if currentSubpageIndex == presentationIndex {
            // 又滑动回来了
            if targetIndex != presentationIndex, let targetToSubpage = subpage(for: targetIndex, allowAccess: false) {
                targetToSubpage.subpageState = .didDisappear
            }
        } else {
            // 页面已切换
            if let lastPresentationSubpage = subpage(for: presentationIndex, allowAccess: false) {
                lastPresentationSubpage.subpageState = .didDisappear
            }
            if currentSubpageIndex != targetIndex, let targetToSubpage = subpage(for: targetIndex, allowAccess: false) {
                targetToSubpage.subpageState = .didDisappear
#if DEBUG
                print("⚠️⚠️⚠️⚠️⚠️PageViewController界面切换有问题⚠️⚠️⚠️⚠️⚠️")
#endif
            }
            // 告知界面切换
            if let delegate = delegate, let currentPage = viewController as? MNSegmentedSubpageConvertible {
                delegate.pageViewController(pageViewController, didScrollTo: currentPage)
            }
        }
    }
}
