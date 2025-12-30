//
//  MNSegmentedViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//  分段视图控制器

import UIKit
import Foundation
import CoreFoundation

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

@objc public protocol MNSegmentedViewControllerDataSource: MNSegmentedNavigationDataSource {
    
    /// 公共背景视图
    @objc optional var preferredSubpageBackgroundView: UIView? { get }
    
    /// 获取分段item尺寸
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - index: 索引
    /// - Returns: item尺寸
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, dimensionForSegmentedNavigationItemAt index: Int) -> CGFloat
    
    /// 获取子界面
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - index: 页码索引
    /// - Returns: 子界面控制器
    func segmentedViewController(_ viewController: MNSegmentedViewController, subpageAt index: Int) -> MNSegmentedSubpageConvertible
}

@objc public protocol MNSegmentedViewControllerDelegate: AnyObject {
    
    /// 子页面变化
    /// - Parameters:
    ///   - splitController: 分段视图控制器
    ///   - index: 子页面索引
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, subpageDidChangeAt index: Int)
    
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

public class MNSegmentedViewController: UIViewController {
    
    /// 公共头视图需要在屏幕上显示的高度
    public var headerVisibleHeight: CGFloat = 0.0
    
    /// 位置
    private lazy var frame: CGRect = .zero
    
    /// 配置信息
    private lazy var configuration = MNSegmentedConfiguration()
    
    /// 事件代理
    public weak var delegate: MNSegmentedViewControllerDelegate?
    
    /// 数据源
    public weak var dataSource: MNSegmentedViewControllerDataSource?
    
    /// 导航视图
    private lazy var navigationView = MNSegmentedNavigationView(configuration: configuration)
    
    /// 页面协调器
    private lazy var pageCoordinator = MNSegmentedSubpageCoordinator(pageViewController: pageViewController, configuration: configuration)
    
    /// 分页控制器
    private lazy var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: configuration.orientation, options: [.interPageSpacing:0.0])
    
    
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
        
        if let dataSource = dataSource, let backgroundView = dataSource.preferredSubpageBackgroundView, let backgroundView = backgroundView {
            
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(backgroundView)
            NSLayoutConstraint.activate([
                backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        }
        
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
            // 放置公共视图与分段视图
            navigationView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(navigationView)
            NSLayoutConstraint.activate([
                navigationView.leftAnchor.constraint(equalTo: view.leftAnchor),
                navigationView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        default:
            // 纵向
            navigationView.translatesAutoresizingMaskIntoConstraints = false
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
        pageCoordinator.delegate = self
        pageCoordinator.dataSource = self
        pageCoordinator.scrolling = navigationView
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
        pageCoordinator.removeSubpage(at: nil)
        navigationView.frame.origin.y = 0.0
        navigationView.reloadSubview()
    }
    
    /// 获取子页面
    /// - Parameters:
    ///   - index: 子页面索引
    ///   - access: 若缓存没有, 是否允许向数据源代理获取
    /// - Returns: 子页面控制器
    public func subpage(for index: Int, access: Bool = false) -> MNSegmentedSubpageConvertible? {
        guard isViewLoaded else { return nil }
        guard navigationView.isItemLoaded else { return nil }
        return pageCoordinator.subpage(for: index, allowAccess: access)
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
    public func replace(_ subpage: MNSegmentedSubpageConvertible, at index: Int) {
        if isViewLoaded, navigationView.isItemLoaded {
            guard index < numberOfPages else { return }
            // 删除旧页面缓存
            pageCoordinator.removeSubpage(at: index)
            // 缓存新页面
            pageCoordinator.setSubpage(subpage, for: index)
            if index == currentPageIndex {
                // 替换当前页面
                pageCoordinator.setSubpage(at: index, direction: .forward, animated: false)
            }
        } else {
            // 未有子页面
            pageCoordinator.setSubpage(subpage, for: index)
        }
    }
    
    /// 设置当前页面索引
    /// - Parameters:
    ///   - index: 子页面索引
    ///   - animated: 是否动态
    public func setSubpage(at index: Int, animated: Bool = false) {
        guard isViewLoaded else { return }
        guard navigationView.isItemLoaded else { return }
        guard index < numberOfPages else { return }
        let currentPageIndex = currentPageIndex
        if index == currentPageIndex { return }
        let direction: UIPageViewController.NavigationDirection = index >= currentPageIndex ? .forward : .reverse
        navigationView.setSelectedItem(at: index, animated: animated)
        pageCoordinator.setSubpage(at: index, direction: direction, animated: animated)
    }
}

// MARK: - Title
extension MNSegmentedViewController {
    
    /// 替换标题
    /// - Parameters:
    ///   - title: 新的标题
    ///   - index: 子页面索引
    public func replace(_ title: String, at index: Int) {
        guard isViewLoaded else { return }
        navigationView.replace(title, at: index)
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
    public func removeAllBadges() {
        guard isViewLoaded else { return }
        navigationView.removeAllBadges()
    }
}

// MARK: - Divider
extension MNSegmentedViewController {
    
    /// 替换分割线约束
    /// - Parameters:
    ///   - constraint: 分割线约束
    ///   - index: 子页面索引
    public func replace(_ constraint: MNSegmentedConfiguration.Constraint, at index: Int) {
        guard isViewLoaded else { return }
        navigationView.replace(constraint, at: index)
    }
}

// MARK: - MNSegmentedNavigationDataSource
extension MNSegmentedViewController: MNSegmentedNavigationDataSource {
    
    public var preferredSegmentedNavigationTitles: [String] {
        
        guard let dataSource = dataSource else { return [] }
        return dataSource.preferredSegmentedNavigationTitles
    }
    
    public var preferredSegmentedNavigationHeaderView: UIView? {
        
        guard let dataSource = dataSource, let headerView = dataSource.preferredSegmentedNavigationHeaderView else { return nil }
        return headerView
    }
    
    public var preferredSegmentedNavigationPresentationIndex: Int {
        
        guard let dataSource = dataSource, let presentationIndex = dataSource.preferredSegmentedNavigationPresentationIndex else { return 0 }
        return presentationIndex
    }
    
    public var preferredSegmentedNavigationBackgroundView: UIView? {
        
        guard let dataSource = dataSource, let backgroundView = dataSource.preferredSegmentedNavigationBackgroundView else { return nil }
        return backgroundView
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
        
        guard let dataSource = dataSource, let dimension = dataSource.segmentedViewController?(self, dimensionForSegmentedNavigationItemAt: index) else { return 0.0 }
        return dimension
    }
}

// MARK: - MNSegmentedNavigationDelegate
extension MNSegmentedViewController: MNSegmentedNavigationDelegate {
    
    func navigationViewDidReloadItem(_ navigationView: MNSegmentedNavigationView) {
        
        pageCoordinator.setSubpage(at: navigationView.selectedIndex, direction: .forward, animated: false)
    }
    
    func navigationView(_ navigationView: MNSegmentedNavigationView, shouldSelectItemAt index: Int) -> Bool {
        
        pageCoordinator.isScrolling == false
    }
    
    func navigationView(_ navigationView: MNSegmentedNavigationView, didSelectItemAt index: Int, direction: UIPageViewController.NavigationDirection) {
        
        pageCoordinator.setSubpage(at: index, direction: direction, animated: true)
    }
    
    func navigationView(_ navigationView: MNSegmentedNavigationView, willDisplay cell: any MNSegmentedNavigationCellConvertible, item: MNSegmentedNavigationItem, at index: Int) {
        
        guard let delegate = delegate else { return }
        delegate.segmentedViewController?(self, willDisplay: cell, item: item, at: index)
    }
}

// MARK: - MNSegmentedSubpageDataSource
extension MNSegmentedViewController: MNSegmentedSubpageDataSource {
    
    public var currentPageIndex: Int {
        
        navigationView.selectedIndex
    }
    
    public var numberOfPages: Int {
        
        navigationView.items.count
    }
    
    public var subpageHeaderHeight: CGFloat {
        
        // 顶部已预留导航栏高度
        navigationView.leadingSeparator.frame.minY
    }
    
    public var subpageHeaderGreatestFiniteOffset: CGFloat {
        
        max(0.0, subpageHeaderHeight - headerVisibleHeight)
    }
    
    public func subpage(at index: Int) -> (any MNSegmentedSubpageConvertible)? {
        
        guard let dataSource = dataSource else { return nil }
        return dataSource.segmentedViewController(self, subpageAt: index)
    }
    
    public func contentOffset(for subpage: any MNSegmentedSubpageConvertible) -> CGPoint {
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
            let maxOffsetY = greatestFiniteOffset - minY
            let offsetY: CGFloat = -scrollView.contentInset.top - navigationView.frame.minY
            if abs(abs(navigationView.frame.minY) - maxOffsetY) <= 0.01 {
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
        if scrollView.mn.isReachedMinimumSize, greatestFiniteOffset > 0.0 {
            var minY = 0.0
            if let superview = scrollView.superview {
                minY = superview.convert(scrollView.frame, to: subpage.view).minY
            }
            if greatestFiniteOffset > minY {
                // SegmentView最大可向上滑动的高度
                let maxOffsetY = greatestFiniteOffset - minY
                // ScrollView向上滑出的高度
                let offsetY: CGFloat = contentOffset.y + scrollView.contentInset.top
                let newY: CGFloat = min(0.0, max(-maxOffsetY, -offsetY))
                let oldY: CGFloat = navigationView.frame.minY
                if abs(oldY - newY) >= 0.01 {
                    print("minY: \(minY)")
                    print("greatestFiniteOffset: \(greatestFiniteOffset)")
                    print("maxOffsetY: \(maxOffsetY)")
                    print("offsetY: \(offsetY)")
                    print("newY: \(newY)")
                    print("oldY: \(oldY)")
                    navigationView.frame.origin.y = newY
                    /**
                     minY: -98.0
                     greatestFiniteOffset: 227.0
                     maxOffsetY: 325.0
                     offsetY: 1499.0
                     newY: -325.0
                     oldY: -227.0
                     */
                    // 告知页头变化
//                    let change: [NSKeyValueChangeKey:CGPoint] = [.oldKey:CGPoint(x: headerView.frame.minX, y: abs(oldY)),.newKey:CGPoint(x: headerView.frame.minX, y: abs(minY))]
//                    delegate?.splitViewController?(self, headerOffsetChanged: change)
                }
            }
        }
        if let delegate = delegate {
            delegate.segmentedViewController?(self, subpageDidChangeContentOffset: contentOffset)
        }
    }
}




