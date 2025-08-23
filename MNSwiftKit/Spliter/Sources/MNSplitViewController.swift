//
//  MNSplitViewController.swift
//  anhe
//
//  Created by 冯盼 on 2022/5/27.
//  分页控制器

import UIKit
import Foundation

@objc public protocol MNSplitPageConvertible where Self: UIViewController {
    
    /// 首选的滑动视图
    var preferredPageScrollView: UIScrollView { get }
    
    /// 修改ScrollView.ContentInset告知
    /// - Parameter scrollView: 滑动视图
    @objc optional func scrollViewDidChangeContentInset(_ scrollView: UIScrollView)
    
    /// 计算页面至少需要达到的内容尺寸告知
    /// - Parameters:
    ///   - scrollView: 滑动视图
    ///   - size: 内容尺寸
    @objc optional func scrollView(_ scrollView: UIScrollView, guessLeastNormalContent size: CGSize)
}

@objc public protocol MNSplitViewControllerDataSource: MNSplitViewDataSource {
    
    /// 初始子界面索引
    @objc optional var preferredPageIndex: Int { get }
    
    /// 页头视图
    @objc optional var pageHeaderView: UIView? { get }
    
    /// 页面背景视图
    @objc optional var backgroundView: UIView? { get }
    
    /// 分割器背景视图
    @objc optional var splitterBackgroundView: UIView? { get }
    
    /// 获取子界面
    /// - Parameters:
    ///   - viewController: 分页控制器
    ///   - index: 页码
    /// - Returns: 子界面
    func splitViewController(_ viewController: MNSplitViewController, contentForPageAt index: Int) -> MNSplitPageConvertible
}

@objc public protocol MNSplitViewControllerDelegate: AnyObject {
    
    /// 界面变化告知
    /// - Parameters:
    ///   - splitController: 分页控制器
    ///   - index: 页码
    @objc optional func splitViewController(_ splitController: MNSplitViewController, didChangePageAt index: Int)
    
    /// 页头偏移变化告知
    /// - Parameters:
    ///   - splitController: 分页控制器
    ///   - change: 变化内容
    @objc optional func splitViewController(_ splitController: MNSplitViewController, headerOffsetChanged change: [NSKeyValueChangeKey:CGPoint])
    
    /// 页头偏移变化告知
    /// - Parameters:
    ///   - splitController: 分页控制器
    ///   - scrollView: 滑动视图
    ///   - contentOffset: 偏移
    @objc optional func splitViewController(_ splitController: MNSplitViewController, scrollView: UIScrollView, contentOffsetChanged contentOffset: CGPoint)
    
    /// 导航项即将显示
    /// - Parameters:
    ///   - splitController: 分页控制器
    ///   - cell: 导航项
    ///   - splitter: 导航项模型
    ///   - index: 索引
    @objc optional func splitViewController(_ splitController: MNSplitViewController, willDisplay cell: MNSplitCellConvertible, spliter: MNSpliter, forItemAt index: Int)
}

public extension MNSplitPageConvertible {
    
    /// 页码
    var pageIndex: Int { preferredPageScrollView.mn_split.pageIndex }
    
    /// 是否在显示
    var isAppear: Bool { preferredPageScrollView.mn_split.isAppear }
}

/// 分页控制器
public class MNSplitViewController: UIViewController {
    /// 标记位置
    private var frame: CGRect = UIScreen.main.bounds
    /// 公共页头视图保留高度
    public var reservedHeaderHeight: CGFloat = 0.0
    /// 配置信息
    public let options: MNSplitOptions = MNSplitOptions()
    /// 交互代理
    public weak var delegate: MNSplitViewControllerDelegate?
    /// 数据源代理
    public weak var dataSource: MNSplitViewControllerDataSource?
    /// 背景视图
    private var backgroundView: UIView?
    /// 加载分段视图与公共头视图
    private let profileView: UIView = UIView()
    /// 公共页头视图
    private lazy var headerView: UIView = UIView()
    /// 页面控制
    private lazy var splitView: MNSplitView = {
        let splitView = MNSplitView(frame: .zero, options: options)
        splitView.delegate = self
        splitView.dataSource = self
        return splitView
    }()
    /// 子控制器
    private lazy var pageViewController: MNSplitPageController = {
        let pageViewController = MNSplitPageController(frame: .zero, options: options)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.handler = splitView
        return pageViewController
    }()
    /// 布局方向
    public var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            if axis != oldValue {
                reloadSubpage()
            }
        }
    }
    
    /// 构造分页控制器
    /// - Parameters:
    ///   - frame: 位置
    ///   - axis: 布局方向
    public init(frame: CGRect, axis: NSLayoutConstraint.Axis = .horizontal) {
        super.init(nibName: nil, bundle: nil)
        self.axis = axis
        self.frame = frame
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        let view = UIView(frame: frame)
        view.backgroundColor = .clear
        view.isMultipleTouchEnabled = false
        self.view = view
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 添加子控制器滑动组件
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.frame = view.bounds
        
        // 添加配置视图
        view.addSubview(profileView)
        
        // 加载子视图
        reloadSubpage()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageViewController.beginAppearanceTransition(true, animated: animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageViewController.endAppearanceTransition()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pageViewController.beginAppearanceTransition(false, animated: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageViewController.endAppearanceTransition()
    }
}

// MARK: - 便捷入口
extension MNSplitViewController {
    
    /// 页面数量
    public var numberOfPages: Int { pageViewController.numberOfPages }
    
    /// 当前页码
    public var currentPageIndex: Int { pageViewController.currentPageIndex }
    
    /// 分割项之间分割线颜色
    public var dividerColor: UIColor? {
        get { splitView.dividerColor }
        set { splitView.dividerColor = newValue }
    }
    
    /// 分割项分割线约束
    public var dividerInset: UIEdgeInsets {
        get { splitView.dividerInset }
        set { splitView.dividerInset = newValue }
    }
    
    /// 是否允许滑动
    public var isScrollEnabled: Bool {
        get { pageViewController.isScrollEnabled }
        set { pageViewController.isScrollEnabled = newValue }
    }
    
    /// 是否允许选择
    public var isSelectionEnabled: Bool {
        get { splitView.isSelectionEnabled }
        set { splitView.isSelectionEnabled = newValue }
    }
    
    /// 分割线颜色
    public var separatorColor: UIColor! {
        get { splitView.separatorColor }
        set { splitView.separatorColor = newValue }
    }
    
    /// 分割线约束
    public var separatorInset: UIEdgeInsets {
        get { splitView.separatorInset }
        set { splitView.separatorInset = newValue }
    }
    
    /// 分割线样式
    public var separatorStyle: MNSplitOptions.SeparatorStyle {
        get { splitView.separatorStyle }
        set { splitView.separatorStyle = newValue }
    }
    
    /// 内容约束
    public var contentInset: UIEdgeInsets {
        guard isViewLoaded else { return .zero }
        return axis == .horizontal ? .zero : UIEdgeInsets(top: 0.0, left: profileView.frame.maxX, bottom: 0.0, right: 0.0)
    }
    
    /// 内容位置
    public var contentRect: CGRect { view.bounds.inset(by: contentInset) }
    
    /// 页头视图位置
    public var headerRect: CGRect { headerView.frame }
    
    /// 配置视图位置
    public var profileRect: CGRect { profileView.frame }
    
    /// 解决手势冲突
    /// - Parameter gestureRecognizer: 冲突手势
    public func requireFailTo(_ gestureRecognizer: UIGestureRecognizer) {
        pageViewController.requireFailTo(gestureRecognizer)
    }
    
    /// 注册页面控制单元表格
    /// - Parameters:
    ///   - cellClass: 表格类
    ///   - reuseIdentifier: 表格重用标识符
    public func register<T>(_ cellClass: T.Type, forSplitterWithReuseIdentifier reuseIdentifier: String) where T: MNSplitCellConvertible {
        splitView.register(cellClass, forSplitterWithReuseIdentifier: reuseIdentifier)
    }
    
    /// 注册页面控制单元表格
    /// - Parameters:
    ///   - nib: 从nib文件 <必须遵循'MNSplitCellConvertible'协议>
    ///   - reuseIdentifier: 表格重用标识符
    public func register(_ nib: UINib?, forSplitterWithReuseIdentifier reuseIdentifier: String) {
        splitView.register(nib, forSplitterWithReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - Page
extension MNSplitViewController {
    
    /// 所有已存在的子界面
    public var pages: [MNSplitPageConvertible] {
        pages(as: MNSplitPageConvertible.self)
    }
    
    /// 所有已存在子界面
    /// - Parameter type: 类型
    /// - Returns: 所有子界面
    public func pages<T>(as type: T.Type) -> [T] {
        pageViewController.pages(as: type)
    }
    
    /// 当前子页面
    public var currentPage: MNSplitPageConvertible? {
        page(for: pageViewController.currentPageIndex, access: false)
    }
    
    /// 获取页面
    /// - Parameters:
    ///   - index: 指定页码
    ///   - access: 若缓存没有, 是否允许向代理获取
    /// - Returns: 页面控制器
    public func page(for index: Int, access: Bool = false) -> MNSplitPageConvertible? {
        guard isViewLoaded else { return nil }
        return pageViewController.page(for: index, access: access)
    }
    
    /// 获取页面
    /// - Parameters:
    ///   - index: 指定页码
    ///   - type: 页面类型
    ///   - access: 若缓存没有, 是否允许向代理获取
    /// - Returns: 页面
    public func page<T: UIViewController>(for index: Int, as type: T.Type, access: Bool = false) -> T? {
        page(for: index, access: access) as? T
    }
    
    /// 设置当前页码
    /// - Parameters:
    ///   - index: 页码
    ///   - animated: 是否动态
    public func setCurrentPage(at index: Int, animated: Bool = false) {
        guard isViewLoaded else { return }
        if index == splitView.currentPageIndex { return }
        guard index < numberOfPages else { return }
        splitView.setCurrentPage(at: index, animated: animated)
        pageViewController.setCurrentPage(at: index, animated: animated)
    }
    
    /// 插入页面
    /// - Parameters:
    ///   - items: 标题集合
    ///   - index: 页码
    public func insertSplitters(with items: [String], at index: Int) {
        guard isViewLoaded else { return }
        guard items.count > 0 else { return }
        let pageIndex: Int = max(0, min(index, numberOfPages))
        splitView.insertSpliters(items, at: pageIndex)
        pageViewController.insertPage(count: items.count, at: pageIndex)
        splitView.setCurrentPage(at: pageViewController.currentPageIndex, animated: false)
    }
    
    /// 删除页面
    /// - Parameter index: 页码
    public func removeSplitter(at index: Int) {
        guard isViewLoaded else { return }
        let numberOfPages = splitView.numberOfPages
        guard index >= 0, index < numberOfPages else { return }
        splitView.removeSpliter(at: index)
        pageViewController.removePage(at: index)
        splitView.setCurrentPage(at: pageViewController.currentPageIndex, animated: false)
    }
    
    /// 替换页面
    /// - Parameters:
    ///   - page: 页面
    ///   - index: 指定开始的页码
    public func replacePage(_ page: MNSplitPageConvertible, at index: Int) {
        guard isViewLoaded else { return }
        guard index < numberOfPages else { return }
        pageViewController.replacePage(page, at: index)
    }
    
    /// 重载页面
    /// - Parameter index: 页码
    public func reloadPage(at index: Int) {
        guard isViewLoaded else { return }
        guard index < numberOfPages else { return }
        pageViewController.reloadPage(at: index)
    }
    
    /// 重载子页面
    public func reloadSubpage() {
        guard isViewLoaded else { return }
        let splitAxis = splitView.axis
        splitView.axis = axis
        splitView.removeAllSplitter()
        let currentOffset = CGPoint(x: headerView.frame.minX, y: profileView.frame.minY)
        if splitAxis != axis || profileView.frame == .zero {
            // 更新背景视图
            if let backgroundView = backgroundView {
                self.backgroundView = nil
                backgroundView.removeFromSuperview()
            }
            if let dataSource = dataSource, let backgroundView = dataSource.backgroundView, let backgroundView = backgroundView {
                self.backgroundView = backgroundView
                view.insertSubview(backgroundView, at: 0)
            }
            // 更新头视图
            profileView.subviews.forEach { $0.removeFromSuperview() }
            switch axis {
            case .horizontal:
                headerView = (dataSource?.pageHeaderView ?? nil) ?? UIView()
                splitView.frame = CGRect(x: 0.0, y: headerView.frame.maxY, width: view.frame.width, height: options.spliterSize.height)
                profileView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: splitView.frame.maxY)
                profileView.addSubview(headerView)
            default:
                headerView = UIView()
                splitView.frame = CGRect(x: 0.0, y: 0.0, width: options.spliterSize.width, height: view.frame.height)
                profileView.frame = CGRect(x: 0.0, y: 0.0, width: splitView.frame.width, height: view.frame.height)
            }
            splitView.reloadAccessoryView()
            if let dataSource = dataSource, let backgroundView = dataSource.splitterBackgroundView, let backgroundView = backgroundView {
                splitView.insertSubview(backgroundView, at: 0)
            }
            profileView.addSubview(splitView)
        }
        splitView.updateSubviews()
        pageViewController.removeAllPages()
        pageViewController.axis = axis
        pageViewController.numberOfPages = splitView.numberOfPages
        var currentPageIndex: Int = dataSource?.preferredPageIndex ?? 0
        currentPageIndex = max(0, min(currentPageIndex, numberOfPages - 1))
        splitView.setCurrentPage(at: currentPageIndex, animated: false)
        pageViewController.setCurrentPage(at: currentPageIndex, animated: false)
        guard let delegate = delegate else { return }
        let headerOffset = CGPoint(x: headerView.frame.minX, y: profileView.frame.minY)
        if headerOffset != currentOffset {
            delegate.splitViewController?(self, headerOffsetChanged: [.oldKey:currentOffset,.newKey:headerOffset])
        }
    }
}

// MARK: - Item
extension MNSplitViewController {
    
    /// 获取页面标题
    /// - Parameter index: 指定页码
    /// - Returns: 页面标题
    public func splitterTitle(at index: Int) -> String? {
        guard isViewLoaded else { return nil }
        return splitView.splitterTitle(at: index)
    }
    
    /// 替换页面标题
    /// - Parameters:
    ///   - index: 页码
    ///   - item: 标题
    public func replaceSplitter(at index: Int, with item: String) {
        guard isViewLoaded else { return }
        splitView.replaceSpliter(at: index, with: item)
    }
    
    /// 重载标题
    /// - Parameter items: 标题集合
    public func reloadSplitters(_ titles: [String]? = nil) {
        guard isViewLoaded else { return }
        splitView.reloadSplitter(using: titles)
        splitView.setCurrentPage(at: currentPageIndex, animated: false)
    }
}

// MARK: - Badge
extension MNSplitViewController {
    
    /// 获取角标
    /// - Parameter index: 页码
    /// - Returns: 角标
    public func badge(for index: Int) -> Any? {
        splitView.badge(for: index)
    }
    
    /// 设置角标
    /// - Parameters:
    ///   - badge: 角标
    ///   - index: 页码
    public func setBadge(_ badge: Any?, for index: Int) {
        splitView.setBadge(badge, for: index)
    }
    
    /// 删除所有角标
    public func removeAllBadges() {
        splitView.removeAllBadges()
    }
}

// MARK: - MNSplitViewDataSource
extension MNSplitViewController: MNSplitViewDataSource {
    
    public var preferredPageTitles: [String] {
        return dataSource?.preferredPageTitles ?? []
    }
    
    public var preferredHeadAccessoryView: UIView? {
        dataSource?.preferredHeadAccessoryView ?? nil
    }
    
    public var preferredTailAccessoryView: UIView? {
        dataSource?.preferredTailAccessoryView ?? nil
    }
    
    public func widthForSpliter(at index: Int) -> CGFloat {
        dataSource?.widthForSpliter?(at: index) ?? 0.0
    }
}

// MARK: - MNSplitViewDelegate
extension MNSplitViewController: MNSplitViewDelegate {
    
    func splitViewShouldSelectSpliter(at: Int) -> Bool {
        pageViewController.isAllowsPaging
    }
    
    func splitViewDidSelectSpliter(at pageIndex: Int) {
        pageViewController.setCurrentPage(at: pageIndex, animated: true)
    }
    
    func splitCell(_ cell: any MNSplitCellConvertible, willDisplay spliter: MNSpliter, forItemAt index: Int, axis: NSLayoutConstraint.Axis) {
        delegate?.splitViewController?(self, willDisplay: cell, spliter: spliter, forItemAt: index)
    }
}

// MARK: - MNSplitPageControllerDataSource
extension MNSplitViewController: MNSplitPageControllerDataSource {
    
    var pageScrollProfileHeight: CGFloat {
        profileView.frame.height
    }
    
    var pageHeaderGreatestFiniteOffset: CGFloat {
        let maxY = headerView.frame.maxY
        return max(0.0, maxY - reservedHeaderHeight)
    }
    
    func contentOffset(for page: MNSplitPageConvertible) -> CGPoint {
        let scrollView = page.preferredPageScrollView
        var contentOffset = scrollView.contentOffset
        switch axis {
        case .horizontal:
            guard scrollView.mn_split.isReachedLeastSize else { break }
            let greatestFiniteOffset = pageHeaderGreatestFiniteOffset
            let originY = scrollView.superview?.convert(scrollView.frame, to: view).minY ?? 0.0
            guard greatestFiniteOffset > originY else { break }
            let maxOffsetY = greatestFiniteOffset - originY
            let offsetY: CGFloat = -scrollView.contentInset.top - profileView.frame.minY
            if abs(abs(profileView.frame.minY) - maxOffsetY) <= 0.01 {
                // 表头已达到最大限度
                contentOffset.y = max(contentOffset.y, offsetY)
            } else {
                contentOffset.y = offsetY
            }
        default:
            contentOffset.y = -scrollView.contentInset.top
        }
        return contentOffset
    }
    
    func contentPage(for index: Int) -> MNSplitPageConvertible? {
        guard index < numberOfPages else { return nil }
        guard let dataSource = dataSource else { return nil }
        return dataSource.splitViewController(self, contentForPageAt: index)
    }
}

// MARK: - MNSplitPageControllerDelegate
extension MNSplitViewController: MNSplitPageControllerDelegate {
    
    func scrollView(_ scrollView: UIScrollView, contentOffsetChanged contentOffset: CGPoint) {
        delegate?.splitViewController?(self, scrollView: scrollView, contentOffsetChanged: contentOffset)
        guard scrollView.mn_split.isReachedLeastSize else { return }
        guard headerView.frame.maxY > 0.0 else { return }
        let greatestFiniteOffset = pageHeaderGreatestFiniteOffset
        let originY = scrollView.superview?.convert(scrollView.frame, to: view).minY ?? 0.0
        guard greatestFiniteOffset > originY else { return }
        let maxOffsetY = greatestFiniteOffset - originY
        let offsetY: CGFloat = contentOffset.y + scrollView.contentInset.top
        let minY: CGFloat = min(0.0, max(-maxOffsetY, -offsetY))
        let oldY: CGFloat = profileView.frame.minY
        if abs(oldY - minY) >= 0.01 {
            profileView.mn_layout.minY = minY
            // 告知页头变化
            let change: [NSKeyValueChangeKey:CGPoint] = [.oldKey:CGPoint(x: headerView.frame.minX, y: abs(oldY)),.newKey:CGPoint(x: headerView.frame.minX, y: abs(minY))]
            delegate?.splitViewController?(self, headerOffsetChanged: change)
        }
    }
    
    func pageViewController(_ pageViewController: MNSplitPageController, didScrollToPageAt index: Int) {
        guard let delegate = delegate else { return }
        delegate.splitViewController?(self, didChangePageAt: index)
        guard let page = pageViewController.page(for: index, access: false) else { return }
        let scrollView = page.preferredPageScrollView
        delegate.splitViewController?(self, scrollView: scrollView, contentOffsetChanged: scrollView.contentOffset)
    }
}

// MARK: - 禁止生命周期转发
extension MNSplitViewController {
    
    /// 禁止生命周期转发到子控制器
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }
}
