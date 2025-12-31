//
//  MNSegmentedViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//  分段视图控制器

import UIKit
import Foundation
import CoreFoundation
#if SWIFT_PACKAGE
@_exported import MNNameSpace
#endif

/// 分段视图控制器数据源
@objc public protocol MNSegmentedViewControllerDataSource: MNSegmentedNavigationDataSource {
    
    /// 获取子界面
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - index: 页码索引
    /// - Returns: 子界面控制器
    func segmentedViewController(_ viewController: MNSegmentedViewController, subpageAt index: Int) -> MNSegmentedSubpageConvertible
}

/// 分段视图控制器事件代理
@objc public protocol MNSegmentedViewControllerDelegate: AnyObject {
    
    /// 子页面变化
    /// - Parameters:
    ///   - splitController: 分段视图控制器
    ///   - index: 子页面索引
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, subpageDidChangeAt index: Int)
    
    /// 头视图偏移变化
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - offset: 当前视图偏移
    ///   - from: 变化前视图偏移
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, headerViewDidChangeOffset offset: CGPoint, from: CGPoint)
    
    /// 子页面内容偏移变化
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - contentOffset: 内容偏移量
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, subpageDidChangeContentOffset contentOffset: CGPoint)
    
    /// 即将显示分段Cell
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - cell: 分段Cell
    ///   - item: 数据模型
    ///   - index: 索引
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, willDisplay cell: MNSegmentedNavigationCellConvertible, item: MNSegmentedNavigationItem, at index: Int)
}

/// 分段视图控制器子页面规范
@objc public protocol MNSegmentedSubpageConvertible where Self: UIViewController {
    
    /// 滑动视图
    var preferredSubpageScrollView: UIScrollView? { get }
    
    /// 告知已修改ContentInset
    /// - Parameter scrollView: 滑动视图
    @objc optional func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView)
    
    /// 告知`scrollView`最小内容尺寸
    /// - Parameters:
    ///   - scrollView: 滑动视图
    ///   - contentSize: 内容尺寸
    @objc optional func scrollView(_ scrollView: UIScrollView, determinedMinimumContentSize contentSize: CGSize)
}

/// 分段视图控制器
public class MNSegmentedViewController: UIViewController {
    
    /// 位置
    private lazy var frame: CGRect = .zero
    
    /// 配置信息
    private lazy var configuration = MNSegmentedConfiguration()
    
    /// 事件代理
    public weak var delegate: MNSegmentedViewControllerDelegate?
    
    /// 数据源
    public weak var dataSource: MNSegmentedViewControllerDataSource?
    
    /// 页面协调器
    private lazy var subpageCoordinator = MNSegmentedSubpageCoordinator(pageViewController: pageViewController, configuration: configuration)
    
    /// 分页控制器
    private lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: configuration.orientation, options: [.interPageSpacing:0.0])
    
    /// 导航视图
    private lazy var navigationView = MNSegmentedNavigationView(configuration: configuration, headerView: dataSource?.preferredSegmentedNavigationHeaderView ?? nil)
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    /// 构造分段视图控制器
    /// - Parameters:
    ///   - frame: 视图位置
    ///   - configuration: 配置信息
    public convenience init(frame: CGRect = .zero, configuration: MNSegmentedConfiguration) {
        self.init(nibName: nil, bundle: nil)
        self.frame = frame
        self.configuration = configuration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if frame.isNull == false, frame.isEmpty == false {
            view.frame = frame
        }
        
        view.clipsToBounds = true
        view.backgroundColor = configuration.backgroundColor
        
        pageViewController.edgesForExtendedLayout = .all
        pageViewController.extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            pageViewController.additionalSafeAreaInsets = .zero
        } else {
            pageViewController.automaticallyAdjustsScrollViewInsets = false
        }
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        navigationView.delegate = self
        navigationView.dataSource = self
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        
        switch configuration.orientation {
        case .horizontal:
            // 横向
            var navigationHeight: CGFloat = configuration.navigation.dimension
            if configuration.separator.style.contains(.leading) {
                navigationHeight += configuration.separator.constraint.dimension
            }
            if configuration.separator.style.contains(.trailing) {
                navigationHeight += configuration.separator.constraint.dimension
            }
            NSLayoutConstraint.activate([
                pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationHeight),
                pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
            view.addSubview(navigationView)
            NSLayoutConstraint.activate([
                navigationView.leftAnchor.constraint(equalTo: view.leftAnchor),
                navigationView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        default:
            // 纵向
            view.insertSubview(navigationView, belowSubview: pageViewController.view)
            NSLayoutConstraint.activate([
                navigationView.topAnchor.constraint(equalTo: view.topAnchor),
                navigationView.leftAnchor.constraint(equalTo: view.leftAnchor),
                navigationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            NSLayoutConstraint.activate([
                pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
                pageViewController.view.leftAnchor.constraint(equalTo: navigationView.rightAnchor)
            ])
        }
        
        // 页面协调器
        subpageCoordinator.delegate = self
        subpageCoordinator.dataSource = self
        subpageCoordinator.scrolling = navigationView
    }
}

// MARK: - Enabled
extension MNSegmentedViewController {
    
    /// 是否可以点击
    public var isSeletionEnabled: Bool {
        get {
            guard isViewLoaded else { return false }
            return navigationView.isSeletionEnabled
        }
        set {
            guard isViewLoaded else { return }
            navigationView.isSeletionEnabled = newValue
        }
    }
    
    /// 是否可以滑动切换界面
    public var isScrollEnabled: Bool {
        get {
            guard isViewLoaded else { return false }
            return subpageCoordinator.isScrollEnabled
        }
        set {
            guard isViewLoaded else { return }
            subpageCoordinator.isScrollEnabled = newValue
        }
    }
}

// MARK: - Segmented Cell
extension MNSegmentedViewController {
    
    /// 注册表格
    /// - Parameters:
    ///   - cellClass: 表格类
    ///   - reuseIdentifier: 表格重用标识符
    public func register<T>(_ cellClass: T.Type, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) where T: MNSegmentedNavigationCellConvertible {
        navigationView.register(cellClass, forSegmentedCellWithReuseIdentifier: reuseIdentifier)
    }
    
    /// 注册表格
    /// - Parameters:
    ///   - nib: xib
    ///   - reuseIdentifier: 表格重用标识符
    public func register(_ nib: UINib?, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) {
        navigationView.register(nib, forSegmentedCellWithReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - Subpage
extension MNSegmentedViewController {
    
    /// 重载子界面
    public func reloadSubpage() {
        guard isViewLoaded else { return }
        guard navigationView.isItemLoaded else { return }
        var oldY: CGFloat?
        if configuration.orientation == .horizontal, navigationView.frame.minY != 0.0 {
            oldY = navigationView.frame.minY
            navigationView.frame.origin.y = 0.0
        }
        subpageCoordinator.invalidateSubpage()
        navigationView.reloadSubview()
        if let oldY = oldY, let delegate = delegate {
            delegate.segmentedViewController?(self, headerViewDidChangeOffset: .init(x: 0.0, y: navigationView.frame.minY), from: .init(x: 0.0, y: oldY))
        }
    }
    
    /// 获取子页面
    /// - Parameters:
    ///   - index: 子页面索引
    ///   - access: 若缓存没有, 是否允许向数据源代理获取
    /// - Returns: 子页面控制器
    public func subpage(for index: Int, access: Bool = false) -> MNSegmentedSubpageConvertible? {
        guard isViewLoaded else { return nil }
        guard navigationView.isItemLoaded else { return nil }
        return subpageCoordinator.subpage(for: index, allowAccess: access)
    }
    
    /// 获取子页面
    /// - Parameters:
    ///   - index: 子页面索引
    ///   - type: 转换子页面类型
    ///   - access: 若缓存没有, 是否允许向数据源代理获取
    /// - Returns: 页面
    public func subpage<T: UIViewController>(for index: Int, as type: T.Type, access: Bool = false) -> T? {
        subpage(for: index, access: access) as? T
    }
    
    /// 替换子页面
    /// - Parameters:
    ///   - subpage: 子页面meisha
    ///   - index: 页面索引
    public func replaceSubpage(_ subpage: MNSegmentedSubpageConvertible, at index: Int) {
        if isViewLoaded, navigationView.isItemLoaded {
            guard index < numberOfSubpages else { return }
            // 删除旧页面缓存
            subpageCoordinator.invalidateSubpage(at: index)
            // 缓存新页面
            subpageCoordinator.setSubpage(subpage, for: index)
            if index == subpageIndex {
                // 替换当前页面
                subpageCoordinator.setSubpage(at: index, direction: .forward, animated: false)
            }
        } else {
            // 未有子页面
            subpageCoordinator.setSubpage(subpage, for: index)
        }
    }
    
    /// 设置当前页面索引
    /// - Parameters:
    ///   - index: 子页面索引
    ///   - animated: 是否动态
    public func setSubpage(at index: Int, animated: Bool = false) {
        guard isViewLoaded else { return }
        guard navigationView.isItemLoaded else { return }
        guard index < numberOfSubpages else { return }
        let currentSubpageIndex = subpageIndex
        if index == currentSubpageIndex { return }
        let direction: UIPageViewController.NavigationDirection = index >= currentSubpageIndex ? .forward : .reverse
        navigationView.setSelectedItem(at: index, animated: animated)
        subpageCoordinator.setSubpage(at: index, direction: direction, animated: animated)
        guard let delegate = delegate else { return }
        delegate.segmentedViewController?(self, subpageDidChangeAt: index)
    }
}

// MARK: - Title
extension MNSegmentedViewController {
    
    /// 替换标题
    /// - Parameters:
    ///   - title: 新的标题
    ///   - index: 子页面索引
    public func replaceTitle(_ title: String, at index: Int) {
        guard isViewLoaded else { return }
        navigationView.replaceTitle(title, at: index)
    }
    
    /// 获取分割项标题
    /// - Parameter index: 子页面索引
    /// - Returns: 获取到的标题
    public func title(for index: Int) -> String? {
        guard isViewLoaded else { return nil }
        return navigationView.title(for: index)
    }
}

// MARK: - Badge
extension MNSegmentedViewController {
    
    /// 获取角标
    /// - Parameter index: 页码
    /// - Returns: 角标
    public func badge(for index: Int) -> Any? {
        guard isViewLoaded else { return nil }
        return navigationView.badge(for: index)
    }
    
    /// 设置角标
    /// - Parameters:
    ///   - badge: 角标
    ///   - index: 页码
    public func setBadge(_ badge: Any?, for index: Int) {
        guard isViewLoaded else { return }
        navigationView.setBadge(badge, for: index)
    }
    
    /// 删除所有角标
    public func removeAllBadge() {
        guard isViewLoaded else { return }
        navigationView.removeAllBadge()
    }
}

// MARK: - Divider
extension MNSegmentedViewController {
    
    /// 替换分割线约束
    /// - Parameters:
    ///   - constraint: 分割线约束
    ///   - index: 子页面索引
    public func replaceDividerConstraint(_ constraint: MNSegmentedConfiguration.Constraint, at index: Int) {
        guard isViewLoaded else { return }
        navigationView.replaceDividerConstraint(constraint, at: index)
    }
}

// MARK: - MNSegmentedNavigationDataSource
extension MNSegmentedViewController: MNSegmentedNavigationDataSource {
    
    public var preferredSegmentedNavigationTitles: [String] {
        
        guard let dataSource = dataSource else { return [] }
        return dataSource.preferredSegmentedNavigationTitles
    }
    
    public var preferredSegmentedNavigationPresentationIndex: Int {
        
        guard let dataSource = dataSource, let presentationIndex = dataSource.preferredSegmentedNavigationPresentationIndex else { return 0 }
        return presentationIndex
    }
    
    public var preferredSegmentedNavigationLeadingAccessoryView: UIView? {
        
        guard let dataSource = dataSource, let accessoryView = dataSource.preferredSegmentedNavigationLeadingAccessoryView else { return nil }
        return accessoryView
    }
    
    public var preferredSegmentedNavigationTrailingAccessoryView: UIView? {
        
        guard let dataSource = dataSource, let accessoryView = dataSource.preferredSegmentedNavigationTrailingAccessoryView else { return nil }
        return accessoryView
    }
    
    public func dimensionForSegmentedNavigationItemAt(_ index: Int) -> CGFloat {
        
        guard let dataSource = dataSource, let dimension = dataSource.dimensionForSegmentedNavigationItemAt?(index) else { return 0.0 }
        return dimension
    }
}

// MARK: - MNSegmentedNavigationDelegate
extension MNSegmentedViewController: MNSegmentedNavigationDelegate {
    
    func navigationViewDidReloadItem(_ navigationView: MNSegmentedNavigationView) {
        
        subpageCoordinator.setSubpage(at: navigationView.selectedIndex, direction: .forward, animated: false)
    }
    
    func navigationView(_ navigationView: MNSegmentedNavigationView, shouldSelectItemAt index: Int) -> Bool {
        
        subpageCoordinator.isScrolling == false
    }
    
    func navigationView(_ navigationView: MNSegmentedNavigationView, didSelectItemAt index: Int, direction: UIPageViewController.NavigationDirection) {
        
        subpageCoordinator.setSubpage(at: index, direction: direction, animated: true)
    }
    
    func navigationView(_ navigationView: MNSegmentedNavigationView, willDisplay cell: any MNSegmentedNavigationCellConvertible, item: MNSegmentedNavigationItem, at index: Int) {
        
        guard let delegate = delegate else { return }
        delegate.segmentedViewController?(self, willDisplay: cell, item: item, at: index)
    }
}

// MARK: - MNSegmentedSubpageDataSource
extension MNSegmentedViewController: MNSegmentedSubpageDataSource {
    
    public var subpageIndex: Int {
        
        navigationView.selectedIndex
    }
    
    public var numberOfSubpages: Int {
        
        navigationView.items.count
    }
    
    public var subpageHeaderHeight: CGFloat {
        
        // 顶部已预留导航栏高度
        navigationView.leadingSeparator.frame.minY
    }
    
    public var subpageHeaderGreatestFiniteOffset: CGFloat {
        
        max(0.0, subpageHeaderHeight - configuration.headerMinimumVisibleHeight)
    }
    
    public func subpage(at index: Int) -> (any MNSegmentedSubpageConvertible)? {
        
        guard let dataSource = dataSource else { return nil }
        return dataSource.segmentedViewController(self, subpageAt: index)
    }
    
    public func contentOffset(for subpage: any MNSegmentedSubpageConvertible, direction: UIPageViewController.NavigationDirection) -> CGPoint {
        guard let scrollView = subpage.preferredSubpageScrollView else { return .zero }
        var contentOffset = scrollView.contentOffset
        switch configuration.orientation {
        case .horizontal:
            guard scrollView.mn.isReachedMinimumSize else { break }
            let greatestFiniteOffset = subpageHeaderGreatestFiniteOffset
            var minY = 0.0
            if let superview = scrollView.superview {
                minY = superview.convert(scrollView.frame, to: subpage.view).minY
            }
            guard greatestFiniteOffset > minY else { break }
            // 头视图最大可向上偏移的高度
            let maxOffsetY = greatestFiniteOffset - minY
            // 依据当前头视图的位置，ScrollView需要的偏移
            let offsetY: CGFloat = -scrollView.contentInset.top - navigationView.frame.minY
            if abs(abs(navigationView.frame.minY) - maxOffsetY) <= 0.01 {
                // 头视图已偏移到最大限度
                contentOffset.y = max(contentOffset.y, offsetY)
            } else {
                contentOffset.y = offsetY
            }
        default:
            switch direction {
            case .forward:
                //
                contentOffset.y = -scrollView.contentInset.top
            default:
                contentOffset.y = max(scrollView.contentSize.height - scrollView.frame.height + scrollView.contentInset.bottom, -scrollView.contentInset.top)
            }
        }
        return contentOffset
    }
}

// MARK: - MNSegmentedSubpageDelegate
extension MNSegmentedViewController: MNSegmentedSubpageDelegate {
    
    func pageViewController(_ viewController: UIPageViewController, didScrollTo subpage: any MNSegmentedSubpageConvertible) {
        guard let delegate = delegate else { return }
        delegate.segmentedViewController?(self, subpageDidChangeAt: subpage.subpageIndex)
        guard let scrollView = subpage.preferredSubpageScrollView else { return }
        delegate.segmentedViewController?(self, subpageDidChangeContentOffset: scrollView.contentOffset)
    }
    
    func pageViewController(_ viewController: UIPageViewController, subpage: any MNSegmentedSubpageConvertible, didChangeContentOffset contentOffset: CGPoint) {
        guard let scrollView = subpage.preferredSubpageScrollView else { return }
        let greatestFiniteOffset = subpageHeaderGreatestFiniteOffset
        if greatestFiniteOffset > 0.0, scrollView.mn.isReachedMinimumSize {
            var minY = 0.0
            if let superview = scrollView.superview {
                minY = superview.convert(scrollView.frame, to: subpage.view).minY
            }
            if greatestFiniteOffset > minY {
                // SegmentView 最大可向上滑动的高度
                let maxOffsetY = greatestFiniteOffset - minY
                // ScrollView 向上滑出的高度
                let offsetY: CGFloat = contentOffset.y + scrollView.contentInset.top
                // 依据 ScrollView 的偏移，头视图应该向上滑出的高度
                let newY: CGFloat = min(0.0, max(-maxOffsetY, -offsetY))
                let oldY: CGFloat = navigationView.frame.minY
                if abs(oldY - newY) >= 0.01 {
                    navigationView.frame.origin.y = newY
                    if let delegate = delegate {
                        delegate.segmentedViewController?(self, headerViewDidChangeOffset: .init(x: 0.0, y: newY), from: .init(x: 0.0, y: oldY))
                    }
                }
            }
        }
        if let delegate = delegate {
            delegate.segmentedViewController?(self, subpageDidChangeContentOffset: contentOffset)
        }
    }
}
