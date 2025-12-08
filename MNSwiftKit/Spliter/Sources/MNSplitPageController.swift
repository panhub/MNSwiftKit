//
//  MNSplitPageController.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//  分页控制器内的滑动子控制器

import UIKit
import Foundation
//#if canImport(MNSwiftKitLayout)
//import MNSwiftKitLayout
//#endif

protocol MNSplitPageControllerDataSource: AnyObject {
    
    /// 页头视图高度
    var pageScrollProfileHeight: CGFloat { get }
    
    /// 页头视图最大偏移
    var pageHeaderGreatestFiniteOffset: CGFloat { get }
    
    /// 计算子页面偏移
    /// - Parameter page: 子界面
    /// - Returns: 子页面偏移量
    func contentOffset(for page: MNSplitPageConvertible) -> CGPoint
    
    /// 获取指定索引的页面
    /// - Parameter index: 页面索引
    /// - Returns: 子页面
    func contentPage(for index: Int) -> MNSplitPageConvertible?
}

protocol MNSplitPageControllerDelegate: MNPageContentAppearance {
    
    /// 页面偏移变化告知
    /// - Parameters:
    ///   - scrollView: 页面滚动视图
    ///   - contentOffset: 内容偏移量
    func scrollView(_ scrollView: UIScrollView, contentOffsetChanged contentOffset: CGPoint) -> Void
    
    /// 页面变化告知
    /// - Parameters:
    ///   - viewController: 分页控制器
    ///   - index: 页码
    func pageViewController(_ viewController: MNSplitPageController, didScrollToPageAt index: Int) -> Void
}

@objc protocol MNPageContentAppearance: AnyObject {
    
    /// 页面即将出现告知
    /// - Parameters:
    ///   - contentController: 页面控制器
    ///   - animated: 是否动态
    @objc optional func contentControllerWillAppear(_ contentController: MNSplitPageConvertible, animated: Bool) -> Void
    
    /// 页面已经出现告知
    /// - Parameters:
    ///   - contentController: 页面控制器
    ///   - animated: 是否动态
    @objc optional func contentControllerDidAppear(_ contentController: MNSplitPageConvertible, animated: Bool) -> Void
    
    /// 页面即将消失告知
    /// - Parameters:
    ///   - contentController: 页面控制器
    ///   - animated: 是否动态
    @objc optional func contentControllerWillDisappear(_ contentController: MNSplitPageConvertible, animated: Bool) -> Void
    
    /// 页面已经消失告知
    /// - Parameters:
    ///   - contentController: 页面控制器
    ///   - animated: 是否动态
    @objc optional func contentControllerDidDisappear(_ contentController: MNSplitPageConvertible, animated: Bool) -> Void
}

protocol MNSplitPageControllerScrollHandler: AnyObject {
    
    /// 开始拖拽告知
    /// - Parameter viewController: 分页控制器
    func pageViewControllerWillBeginDragging(_ viewController: MNSplitPageController) -> Void
    
    /// 拖拽进度告知
    /// - Parameters:
    ///   - viewController: 分页控制器
    ///   - ratio: 拖拽进度
    func pageViewController(_ viewController: MNSplitPageController, didScroll ratio: CGFloat) -> Void
    
    /// 结束拖拽页面告知
    /// - Parameter viewController: 分页控制器
    func pageViewControllerDidEndDragging(_ viewController: MNSplitPageController) -> Void
    
    /// 即将达到的页码告知
    /// - Parameters:
    ///   - viewController: 分页控制器
    ///   - pageIndex: 页码
    func pageViewController(_ viewController: MNSplitPageController, willScrollTo pageIndex: Int) -> Void
}

class MNSplitPageController: UIViewController {
    /// 配置信息
    private var options: MNSplitOptions!
    /// 标记位置
    private var frame: CGRect = UIScreen.main.bounds
    /// 上一次展示的页面索引
    internal var lastPageIndex: Int = 0
    /// 当前展示的页面索引
    internal var currentPageIndex: Int = 0
    /// 开始滑动时的偏移
    private var startOffset: CGFloat = 0.0
    /// 猜想滑动到的界面索引
    private var guessPageIndex: Int = 0
    /// 子界面事件代理
    internal weak var delegate: MNSplitPageControllerDelegate?
    /// 滑动事件代理
    internal weak var handler: MNSplitPageControllerScrollHandler?
    /// 数据源
    internal weak var dataSource: MNSplitPageControllerDataSource?
    /// 滑动视图
    private lazy var scrollView: MNPageScrollView = {
        let scrollView = MNPageScrollView(frame: .zero)
        scrollView.delegate = self
        scrollView.clipsToBounds = true
        return scrollView
    }()
    /// 是否可以滑动
    internal var isScrollEnabled: Bool {
        get { scrollView.isScrollEnabled }
        set { scrollView.isScrollEnabled = newValue }
    }
    /// 是否支持外界修改界面
    internal var isAllowsPaging: Bool { (scrollView.isUserInteractionEnabled && scrollView.isDragging == false && scrollView.isDecelerating == false) }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(frame: CGRect, options: MNSplitOptions) {
        super.init(nibName: nil, bundle: nil)
        self.frame = frame
        self.options = options
        // view的边缘允许额外布局的情况，默认为UIRectEdgeAll，意味着全屏布局(带穿透效果)
        edgesForExtendedLayout = .all
        // 额外布局是否包括不透明的Bar，默认为false
        extendedLayoutIncludesOpaqueBars = true
        // iOS11 后 additionalSafeAreaInsets 可抵消系统的安全区域
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            // 是否自动调整滚动视图的内边距,默认true 系统将会根据导航条和TabBar的情况自动增加上下内边距以防止被Bar遮挡
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        for viewController in children {
            guard let page = viewController as? MNSplitPageConvertible else { continue }
            removeObserver(with: page)
        }
    }
    
    override func loadView() {
        let view = UIView(frame: frame)
        view.backgroundColor = .clear
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let page = page(for: currentPageIndex, access: false) {
            page.beginAppearanceTransition(true, animated: animated)
            page.preferredPageScrollView.mn_split.transitionState = .willAppear
            updateOffset(with: page)
            delegate?.contentControllerWillAppear?(page, animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let page = page(for: currentPageIndex, access: false) {
            page.endAppearanceTransition()
            page.preferredPageScrollView.mn_split.transitionState = .didAppear
            delegate?.contentControllerDidAppear?(page, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let page = page(for: currentPageIndex, access: false) {
            page.beginAppearanceTransition(false, animated: animated)
            page.preferredPageScrollView.mn_split.transitionState = .willDisappear
            delegate?.contentControllerWillDisappear?(page, animated: animated)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let page = page(for: currentPageIndex, access: false) {
            page.endAppearanceTransition()
            page.preferredPageScrollView.mn_split.transitionState = .didDisappear
            delegate?.contentControllerDidDisappear?(page, animated: animated)
        }
    }
    
    /// 解决手势冲突
    /// - Parameter gestureRecognizer: 冲突手势
    func requireFailTo(_ gestureRecognizer: UIGestureRecognizer) {
        scrollView.panGestureRecognizer.require(toFail: gestureRecognizer)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let scrollView = object as? UIScrollView else { return }
        switch keyPath {
        case #keyPath(UIScrollView.contentOffset):
            // 偏移量变化 , scrollView.mn_split.isReachedLeastSize
            guard scrollView.mn_split.isAppear, scrollView.mn_split.pageIndex == currentPageIndex else { return }
            guard let contentOffset = change?[.newKey] as? CGPoint else { return }
            delegate?.scrollView(scrollView, contentOffsetChanged: contentOffset)
        case #keyPath(UIScrollView.contentSize):
            // 内容尺寸变化
            guard let contentSize = change?[.newKey] as? CGSize else { return }
            let leastContentSize = scrollView.mn_split.leastContentSize
            if contentSize.height >= leastContentSize.height, scrollView.mn_split.isReachedLeastSize == false {
                scrollView.mn_split.isReachedLeastSize = true
                switch scrollView.mn_split.transitionState {
                case .willAppear, .didAppear:
                    if let page = page(for: scrollView.mn_split.pageIndex, access: false) {
                        updateOffset(with: page)
                    }
                default: break
                }
            } else if contentSize.height < leastContentSize.height, scrollView.mn_split.isReachedLeastSize == true {
                scrollView.mn_split.isReachedLeastSize = false
            }
        default: break
        }
    }
}

// MARK: - 页面设置
extension MNSplitPageController {
    
    /// 布局方向
    var axis: NSLayoutConstraint.Axis {
        get { scrollView.axis }
        set {
            scrollView.axis = newValue
            currentPageIndex = scrollView.currentPageIndex
        }
    }
    
    /// 页数
    var numberOfPages: Int {
        get { scrollView.numberOfPages }
        set {
            scrollView.numberOfPages = newValue
            currentPageIndex = scrollView.currentPageIndex
        }
    }
    
    /// 所有已存在子界面
    /// - Parameter type: 类型
    /// - Returns: 所有子界面
    func pages<T>(as type: T.Type) -> [T] {
        children.compactMap { $0 as? T }
    }
    
    /// 获取指定页面
    /// - Parameters:
    ///   - index: 页码
    ///   - access: 是否允许向代理索要
    /// - Returns: 指定页面
    func page(for index: Int, access: Bool = true) -> MNSplitPageConvertible? {
        let page: UIViewController? = children.first { viewController in
            guard let page = viewController as? MNSplitPageConvertible else { return false }
            return page.pageIndex == index
        }
        if let page = page { return page as? MNSplitPageConvertible }
        if access, let dataSource = dataSource, let page = dataSource.contentPage(for: index) {
            setPage(page, at: index)
            return page
        }
        return nil
    }
    
    /// 添加并设置页面
    /// - Parameters:
    ///   - page: 页面
    ///   - index: 页码
    func setPage(_ page: MNSplitPageConvertible, at index: Int) {
        // 添加界面
        addChild(page)
        scrollView.addSubview(page.view)
        page.didMove(toParent: self)
        // 约束页面并触发布局
        layoutPageView(page.view, at: index)
        page.view.layoutIfNeeded()
        // 设置页面
        let scrollView = page.preferredPageScrollView
        scrollView.mn_split.pageIndex = index
        scrollView.mn_split.transitionState = .unknown
        scrollView.mn_split.isReachedLeastSize = false
        switch axis {
        case .horizontal:
            // 横向布局
            if scrollView.mn_split.isObserved == false {
                scrollView.mn_split.isObserved = true
                scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: .new, context: nil)
                scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
            }
            // 转换坐标系, 防止`scrollView`非原点布局
            let originY = scrollView.superview?.convert(scrollView.frame, to: view).minY ?? 0.0
            let profileHeight = dataSource?.pageScrollProfileHeight ?? 0.0
            let inset = max(0.0, profileHeight - originY)
            var contentInset = scrollView.contentInset
            let topInset = max(contentInset.top, inset)
            let headerInset = scrollView.mn_split.headerInset
            if abs(topInset - headerInset) >= 0.1 {
                if abs(contentInset.top - topInset) >= 0.1 {
                    contentInset.top = topInset
                    scrollView.contentInset = contentInset
                    page.scrollViewDidChangeContentInset?(scrollView)
                }
                scrollView.mn_split.headerInset = topInset
            }
            // 某些情况下ScrollView未正确计算内容尺寸, 这里手动修改偏移, 会触发重新计算
            var contentOffset = scrollView.contentOffset
            contentOffset.y = -scrollView.contentInset.top
            scrollView.setContentOffset(contentOffset, animated: false)
            // 计算最小内容尺寸
            let greatestFiniteOffset: CGFloat = dataSource?.pageHeaderGreatestFiniteOffset ?? 0.0
            let offsetY = max(0.0, greatestFiniteOffset - originY)
            var contentSize = scrollView.frame.size
            contentSize.width = max(0.0, contentSize.width - contentInset.left - contentInset.right)
            contentSize.height = max(0.0, contentSize.height - contentInset.top - contentInset.bottom + offsetY)
            scrollView.mn_split.leastContentSize = contentSize
            page.scrollView?(scrollView, guessLeastNormalContent: contentSize)
        default:
            scrollView.bounces = false
        }
    }
    
    /// 约束页面视图位置
    /// - Parameters:
    ///   - subview: 页面视图
    ///   - index: 页码
    private func layoutPageView(_ subview: UIView, at index: Int) {
        let contentOffset: CGPoint = scrollView.contentOffset(for: index)
        switch axis {
        case .horizontal:
            subview.frame = .init(origin: .init(x: contentOffset.x, y: 0.0), size: scrollView.frame.size)
        default:
            subview.frame = .init(origin: .init(x: 0.0, y: contentOffset.y), size: scrollView.frame.size)
        }
    }
    
    /// 更新页面偏移量
    /// - Parameter page: 页面
    private func updateOffset(with page: MNSplitPageConvertible) {
        guard let dataSource = dataSource else { return }
        let contentOffset = dataSource.contentOffset(for: page)
        page.preferredPageScrollView.setContentOffset(contentOffset, animated: false)
    }
    
    /// 插入空白页面
    /// - Parameters:
    ///   - count: 数量
    ///   - index: 指定页码
    func insertPage(count: Int, at index: Int) {
        for viewController in children {
            guard let page = viewController as? MNSplitPageConvertible else { continue }
            let scrollView = page.preferredPageScrollView
            let pageIndex = scrollView.mn_split.pageIndex
            guard pageIndex >= index else { continue }
            scrollView.mn_split.pageIndex = pageIndex + count
            layoutPageView(page.view, at: pageIndex + count)
        }
        let lastPageIndex = currentPageIndex
        if lastPageIndex >= index, scrollView.numberOfPages > 0 {
            currentPageIndex += count
        }
        scrollView.numberOfPages += count
        scrollView.currentPageIndex = currentPageIndex
        if currentPageIndex != lastPageIndex {
            // 页码变化
            delegate?.pageViewController(self, didScrollToPageAt: currentPageIndex)
        } else if lastPageIndex >= index {
            // 执行控制器生命周期
            if isViewLoaded, let page = page(for: currentPageIndex, access: true), let _ = view.window {
                page.beginAppearanceTransition(true, animated: false)
                page.preferredPageScrollView.mn_split.transitionState = .willAppear
                updateOffset(with: page)
                delegate?.contentControllerWillAppear?(page, animated: false)
                page.endAppearanceTransition()
                page.preferredPageScrollView.mn_split.transitionState = .didAppear
                delegate?.contentControllerDidAppear?(page, animated: false)
            }
        }
    }
    
    /// 替换页面
    /// - Parameters:
    ///   - page: 页面
    ///   - index: 指定开始的页码
    func replacePage(_ page: MNSplitPageConvertible, at index: Int) {
        // 删除旧页面
        if let oldPage = self.page(for: index, access: false) {
            removePageFromParent(oldPage)
        }
        // 设置新界面
        setPage(page, at: index)
        // 回调当前页面
        if currentPageIndex == index, isViewLoaded, let _ = view.window {
            page.beginAppearanceTransition(true, animated: false)
            page.preferredPageScrollView.mn_split.transitionState = .willAppear
            updateOffset(with: page)
            delegate?.contentControllerWillAppear?(page, animated: false)
            page.endAppearanceTransition()
            page.preferredPageScrollView.mn_split.transitionState = .didAppear
            delegate?.contentControllerDidAppear?(page, animated: false)
        }
    }
    
    /// 重载页面
    /// - Parameter index: 页码
    func reloadPage(at index: Int) {
        // 删除旧页面
        if let page = page(for: index, access: false) {
            removePageFromParent(page)
        }
        // 重载新界面
        if currentPageIndex == index, isViewLoaded, let page = page(for: index, access: true), let _ = view.window {
            page.beginAppearanceTransition(true, animated: false)
            page.preferredPageScrollView.mn_split.transitionState = .willAppear
            updateOffset(with: page)
            delegate?.contentControllerWillAppear?(page, animated: false)
            page.endAppearanceTransition()
            page.preferredPageScrollView.mn_split.transitionState = .didAppear
            delegate?.contentControllerDidAppear?(page, animated: false)
        }
    }
}

// MARK: - Remove
extension MNSplitPageController {
    
    /// 删除所有界面
    func removeAllPages() {
        lastPageIndex = 0
        guessPageIndex = 0
        currentPageIndex = 0
        for viewController in children {
            guard let page = viewController as? MNSplitPageConvertible else { continue }
            removePageFromParent(page)
        }
        scrollView.numberOfPages = 0
        scrollView.currentPageIndex = 0
        scrollView.isUserInteractionEnabled = true
    }
    
    /// 删除指定页面
    /// - Parameter page: 页面
    private func removePageFromParent(_ page: MNSplitPageConvertible) {
        removeObserver(with: page)
        if page.isAppear, isViewLoaded, let _ = view.window {
            page.beginAppearanceTransition(false, animated: false)
            page.endAppearanceTransition()
            page.preferredPageScrollView.mn_split.transitionState = .didDisappear
        }
        page.willMove(toParent: nil)
        page.view.removeFromSuperview()
        page.removeFromParent()
    }
    
    /// 移除对页面观察者
    /// - Parameter page: 页面
    private func removeObserver(with page: MNSplitPageConvertible) {
        let scrollView = page.preferredPageScrollView
        guard scrollView.mn_split.isObserved else { return }
        scrollView.mn_split.isObserved = false
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    /// 删除页面
    /// - Parameter index: 页码
    func removePage(at index: Int) {
        // 删除旧页面
        if let page = page(for: index, access: false) {
            removePageFromParent(page)
        }
        // 移动其它页面
        for viewController in children {
            guard let page = viewController as? MNSplitPageConvertible else { continue }
            let scrollView = page.preferredPageScrollView
            let pageIndex = scrollView.mn_split.pageIndex
            guard pageIndex > index else { continue }
            scrollView.mn_split.pageIndex = pageIndex - 1
            layoutPageView(page.view, at: pageIndex - 1)
        }
        // 修改页面
        let lastPageIndex = currentPageIndex
        let numberOfPages = scrollView.numberOfPages
        scrollView.numberOfPages = max(0, numberOfPages - 1)
        if lastPageIndex == index {
            currentPageIndex = max(0, min(currentPageIndex, scrollView.numberOfPages - 1))
        } else if lastPageIndex > index {
            currentPageIndex -= 1
        }
        scrollView.currentPageIndex = currentPageIndex
        guard scrollView.numberOfPages > 0 else { return }
        if lastPageIndex == index, isViewLoaded, let page = page(for: currentPageIndex, access: true), let _ = view.window {
            page.beginAppearanceTransition(true, animated: false)
            page.preferredPageScrollView.mn_split.transitionState = .willAppear
            updateOffset(with: page)
            delegate?.contentControllerWillAppear?(page, animated: false)
            page.endAppearanceTransition()
            page.preferredPageScrollView.mn_split.transitionState = .didAppear
            delegate?.contentControllerDidAppear?(page, animated: false)
        }
        if lastPageIndex != currentPageIndex  {
            delegate?.pageViewController(self, didScrollToPageAt: currentPageIndex)
        }
    }
}

// MARK: - 非交互转场
extension MNSplitPageController {
    
    /// 设置页码
    /// - Parameters:
    ///   - index: 指定页码
    ///   - animated: 是否动态显示过程
    func setCurrentPage(at index: Int, animated: Bool) {
        lastPageIndex = currentPageIndex
        currentPageIndex = index
        let toPage = page(for: index, access: true)
        let fromPage: MNSplitPageConvertible? = page(for: lastPageIndex, access: false)
        if animated, let fromView = fromPage?.view, let toView = toPage?.view, fromView != toView {
            let completionHandler: (Bool)->Void = { [weak self] _ in
                guard let self = self else { return }
                self.scrollView.isUserInteractionEnabled = true
                self.layoutPageView(fromView, at: self.lastPageIndex)
                self.layoutPageView(toView, at: self.currentPageIndex)
                self.scrollView.setCurrentPage(at: index, animated: false)
                self.endAppearanceTransition(animated: true)
                self.delegate?.pageViewController(self, didScrollToPageAt: index)
            }
            scrollView.isUserInteractionEnabled = false
            beginAppearanceTransition(animated: true)
            fromView.superview?.bringSubviewToFront(fromView)
            toView.superview?.bringSubviewToFront(toView)
            switch axis {
            case .horizontal:
                // 横向布局
                let fromViewStartX: CGFloat = fromView.frame.minX
                var toViewStartX: CGFloat = fromViewStartX
                let offsetX: CGFloat = currentPageIndex > lastPageIndex ? scrollView.frame.width : -scrollView.frame.width
                toViewStartX += offsetX
                let toViewEndX: CGFloat = toViewStartX - offsetX
                let fromViewEndX: CGFloat = fromViewStartX - offsetX
                toView.mn.minX = toViewStartX
                UIView.animate(withDuration: options.transitionDuration, delay: 0.0, options: .curveEaseInOut, animations: {
                    fromView.mn.minX = fromViewEndX
                    toView.mn.minX = toViewEndX
                }, completion: completionHandler)
            default:
                // 纵向布局
                let fromViewStartY: CGFloat = fromView.frame.minY
                var toViewStartY: CGFloat = fromViewStartY
                let offsetY: CGFloat = currentPageIndex > lastPageIndex ? scrollView.frame.height : -scrollView.frame.height
                toViewStartY += offsetY
                let toViewEndY: CGFloat = toViewStartY - offsetY
                let fromViewEndY: CGFloat = fromViewStartY - offsetY
                toView.mn.minY = toViewStartY
                UIView.animate(withDuration: options.transitionDuration, delay: 0.0, options: .curveEaseInOut, animations: {
                    fromView.mn.minY = fromViewEndY
                    toView.mn.minY = toViewEndY
                }, completion: completionHandler)
            }
        } else {
            beginAppearanceTransition(animated: false)
            scrollView.setCurrentPage(at: index, animated: false)
            endAppearanceTransition(animated: false)
            if index < numberOfPages, let delegate = delegate {
                delegate.pageViewController(self, didScrollToPageAt: index)
            }
        }
    }
    
    /// 开始转场
    /// - Parameter animated: 是否动态
    private func beginAppearanceTransition(animated: Bool) {
        let isAppear = (isViewLoaded && view.window != nil)
        guard isAppear else { return }
        if let fromPage = page(for: lastPageIndex, access: false) {
            var execute: Bool = true
            if let toPage = page(for: currentPageIndex, access: false), fromPage == toPage {
                execute = false
            }
            if execute {
                fromPage.beginAppearanceTransition(false, animated: true)
                fromPage.preferredPageScrollView.mn_split.transitionState = .willDisappear
                delegate?.contentControllerWillDisappear?(fromPage, animated: animated)
            }
        }
        if let toPage = page(for: currentPageIndex, access: false) {
            var execute: Bool = true
            if let fromPage = page(for: lastPageIndex, access: false), toPage == fromPage {
                execute = false
            }
            if execute {
                toPage.beginAppearanceTransition(true, animated: true)
                toPage.preferredPageScrollView.mn_split.transitionState = .willAppear
                updateOffset(with: toPage)
                delegate?.contentControllerWillAppear?(toPage, animated: animated)
            }
        }
    }
    
    /// 结束转场
    /// - Parameter animated: 是否动态
    private func endAppearanceTransition(animated: Bool) {
        let isAppear = (isViewLoaded && view.window != nil)
        guard isAppear else { return }
        if let fromPage = page(for: lastPageIndex, access: false) {
            var execute: Bool = true
            if let toPage = page(for: currentPageIndex, access: false), fromPage == toPage {
                execute = false
            }
            if execute {
                fromPage.endAppearanceTransition()
                fromPage.preferredPageScrollView.mn_split.transitionState = .didDisappear
                delegate?.contentControllerDidDisappear?(fromPage, animated: animated)
            }
        }
        if let toPage = page(for: currentPageIndex, access: false) {
            var execute: Bool = true
            if let fromPage = page(for: lastPageIndex, access: false), toPage == fromPage {
                execute = false
            }
            if execute {
                toPage.endAppearanceTransition()
                toPage.preferredPageScrollView.mn_split.transitionState = .didAppear
                delegate?.contentControllerDidAppear?(toPage, animated: animated)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate 交互过渡
extension MNSplitPageController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guessPageIndex = currentPageIndex
        let key = axis == .horizontal ? "startOffsetX" : "startOffsetY"
        if let value = scrollView.value(forKey: key) as? CGFloat {
            startOffset = value
        } else {
            startOffset = axis == .horizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        }
        // 告知交互开始
        handler?.pageViewControllerWillBeginDragging(self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging, scrollView.isDecelerating == false else { return }
        let numberOfPages = self.scrollView.numberOfPages
        guard numberOfPages > 1 else { return }
        let lastGuessIndex = guessPageIndex
        var ratio: CGFloat = 0.0
        switch axis {
        case .horizontal:
            let width: CGFloat = scrollView.frame.width
            let offsetX: CGFloat = scrollView.contentOffset.x
            ratio = offsetX/width
            if offsetX > startOffset {
                guessPageIndex = Int(ceil(ratio))
            } else {
                guessPageIndex = Int(floor(ratio))
            }
        default:
            let height: CGFloat = scrollView.frame.height
            let offsetY: CGFloat = scrollView.contentOffset.y
            ratio = offsetY/height
            if offsetY > startOffset {
                guessPageIndex = Int(ceil(ratio))
            } else {
                guessPageIndex = Int(floor(ratio))
            }
        }
        guessPageIndex = min(max(0, guessPageIndex), numberOfPages - 1)
        // 更新生命周期
        if guessPageIndex != lastGuessIndex {
            // 结束上次猜想页面
            if lastGuessIndex != currentPageIndex, let lastPage = page(for: lastGuessIndex, access: false) {
                lastPage.beginAppearanceTransition(false, animated: false)
                lastPage.preferredPageScrollView.mn_split.transitionState = .willDisappear
                delegate?.contentControllerWillDisappear?(lastPage, animated: false)
                lastPage.endAppearanceTransition()
                lastPage.preferredPageScrollView.mn_split.transitionState = .didDisappear
                delegate?.contentControllerDidDisappear?(lastPage, animated: false)
            }
            // 处理此次猜想页面
            if guessPageIndex != currentPageIndex, let guessPage = page(for: guessPageIndex, access: true) {
                guessPage.beginAppearanceTransition(true, animated: false)
                guessPage.preferredPageScrollView.mn_split.transitionState = .willAppear
                updateOffset(with: guessPage)
                delegate?.contentControllerWillAppear?(guessPage, animated: false)
                guessPage.endAppearanceTransition()
                guessPage.preferredPageScrollView.mn_split.transitionState = .didAppear
                delegate?.contentControllerDidAppear?(guessPage, animated: false)
            }
        }
        // 界面滑动告知
        handler?.pageViewController(self, didScroll: ratio)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let contentOffset = targetContentOffset.pointee
        let ratio: CGFloat = axis == .horizontal ? (contentOffset.x/scrollView.frame.width) : (contentOffset.y/scrollView.frame.height)
        handler?.pageViewController(self, willScrollTo: Int(round(ratio)))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        handler?.pageViewControllerDidEndDragging(self)
        if decelerate == false {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = true
        lastPageIndex = currentPageIndex
        currentPageIndex = self.scrollView.currentPageIndex
        if currentPageIndex == lastPageIndex {
            if guessPageIndex != currentPageIndex, let guessPage = page(for: guessPageIndex, access: false) {
                guessPage.beginAppearanceTransition(false, animated: false)
                guessPage.preferredPageScrollView.mn_split.transitionState = .willDisappear
                delegate?.contentControllerWillDisappear?(guessPage, animated: false)
                guessPage.endAppearanceTransition()
                guessPage.preferredPageScrollView.mn_split.transitionState = .didDisappear
                delegate?.contentControllerDidDisappear?(guessPage, animated: false)
            }
        } else {
            if let lastPage = page(for: lastPageIndex, access: false) {
                lastPage.beginAppearanceTransition(false, animated: false)
                lastPage.preferredPageScrollView.mn_split.transitionState = .willDisappear
                delegate?.contentControllerWillDisappear?(lastPage, animated: false)
                lastPage.endAppearanceTransition()
                lastPage.preferredPageScrollView.mn_split.transitionState = .didDisappear
                delegate?.contentControllerDidDisappear?(lastPage, animated: false)
            }
            if guessPageIndex != currentPageIndex {
                if guessPageIndex != lastPageIndex, let guessPage = page(for: guessPageIndex, access: false) {
                    guessPage.beginAppearanceTransition(false, animated: false)
                    guessPage.preferredPageScrollView.mn_split.transitionState = .willDisappear
                    delegate?.contentControllerWillDisappear?(guessPage, animated: false)
                    guessPage.endAppearanceTransition()
                    guessPage.preferredPageScrollView.mn_split.transitionState = .didDisappear
                    delegate?.contentControllerDidDisappear?(guessPage, animated: false)
                }
                if let currentPage = page(for: currentPageIndex, access: true) {
                    currentPage.beginAppearanceTransition(true, animated: false)
                    currentPage.preferredPageScrollView.mn_split.transitionState = .willAppear
                    updateOffset(with: currentPage)
                    delegate?.contentControllerWillAppear?(currentPage, animated: false)
                    currentPage.endAppearanceTransition()
                    currentPage.preferredPageScrollView.mn_split.transitionState = .didAppear
                    delegate?.contentControllerDidAppear?(currentPage, animated: false)
                }
#if DEBUG
                print("⚠️⚠️⚠️交互式过渡有问题⚠️⚠️⚠️")
#endif
            }
            // 告知页面变化
            delegate?.pageViewController(self, didScrollToPageAt: currentPageIndex)
        }
    }
}

// MARK: - 禁止生命周期转发
extension MNSplitPageController {
    
    /// 禁止生命周期转发到子控制器
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }
}
