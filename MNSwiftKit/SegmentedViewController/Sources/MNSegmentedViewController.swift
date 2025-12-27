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
    var preferredSubpageScrollView: UIScrollView { get }
    
    /// 告知已修改ContentInset
    /// - Parameter scrollView: 滑动视图
    @objc optional func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView)
    
    /// 告知`scrollView`最小内容尺寸
    /// - Parameters:
    ///   - scrollView: 滑动视图
    ///   - contentSize: 内容尺寸
    @objc optional func scrollView(_ scrollView: UIScrollView, determinedMinimumContentSize contentSize: CGSize)
}

@objc public protocol MNSegmentedViewControllerDataSource: MNSegmentedViewDataSource {
    
    /// 公共背景视图
    @objc optional var preferredSubpageBackgroundView: UIView? { get }
    
    /// 公共页头视图
    @objc optional var preferredSubpageHeaderView: UIView? { get }
    
    /// 获取分段item尺寸
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - index: 索引
    /// - Returns: item尺寸
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, dimensionForSegmentedItemAt index: Int) -> CGFloat
    
    /// 获取子界面
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - index: 页码索引
    /// - Returns: 子界面控制器
    func segmentedViewController(_ viewController: MNSegmentedViewController, subpageAt index: Int) -> MNSegmentedSubpageConvertible
}

@objc public protocol MNSegmentedViewControllerDelegate: AnyObject {
    
    /// 即将显示分段Cell
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - cell: 分段Cell
    ///   - item: 数据模型
    ///   - index: 索引
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, willDisplay cell: MNSegmentedCellConvertible, item: MNSegmentedItem, at index: Int)
}

public class MNSegmentedViewController: UIViewController {
    
    /// 配置信息
    private lazy var configuration = MNSegmentedConfiguration()
    
    /// 除了`segmentedView`，headerView需要在屏幕上显示的高度
    public var headerVisibleHeight: CGFloat = 0.0
    
    /// 事件代理
    public weak var delegate: MNSegmentedViewControllerDelegate?
    
    /// 数据源
    public weak var dataSource: MNSegmentedViewControllerDataSource?
    
    /// 页面协调器
    private lazy var pageCoordinator = MNSegmentedPageCoordinator(configuration: configuration, pageViewController: pageViewController)
    
    /// 分页控制器
    private let pageViewController = UIPageViewController()
    
    /// 标记是否主动加载了分段视图
    private var isSegmentLoaded: Bool = false
    
    /// 分段视图 + 头视图
    private lazy var segmentedView: MNSegmentedView = {
        var headerView: UIView?
        if configuration.orientation == .horizontal, let dataSource = dataSource, let subview = dataSource.preferredSubpageHeaderView, let subview = subview {
            headerView = subview
        }
        return MNSegmentedView(configuration: configuration, headerView: headerView)
    }()
    
    
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
    /// - Parameter configuration: 配置信息
    convenience init(configuration: MNSegmentedConfiguration) {
        self.init(nibName: nil, bundle: nil)
        self.configuration = configuration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        switch configuration.orientation {
        case .horizontal:
            // 横向，有公共头视图
            NSLayoutConstraint.activate([
                pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
            // 放置公共视图与分段视图
            segmentedView.frame.size.width = view.frame.width
            segmentedView.autoresizingMask = [.flexibleWidth]
            view.addSubview(segmentedView)
        default:
            // 纵向，无公共头视图
            segmentedView.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(segmentedView, belowSubview: pageViewController.view)
            NSLayoutConstraint.activate([
                segmentedView.topAnchor.constraint(equalTo: view.topAnchor),
                segmentedView.leftAnchor.constraint(equalTo: view.leftAnchor),
                segmentedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            NSLayoutConstraint.activate([
                pageViewController.view.leftAnchor.constraint(equalTo: segmentedView.rightAnchor)
            ])
        }
        
        // 激活协调器
        pageCoordinator.delegate = self
        pageCoordinator.dataSource = self
        pageCoordinator.scrollDelegate = segmentedView
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isSegmentLoaded == false else { return }
        isSegmentLoaded = true
        segmentedView.reloadSubviews()
    }
}

// MARK: - Custom Cell
extension MNSegmentedViewController {
    
    /// 注册表格
    /// - Parameters:
    ///   - cellClass: 表格类
    ///   - reuseIdentifier: 表格重用标识符
    public func register<T>(_ cellClass: T.Type, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) where T: MNSegmentedCellConvertible {
        segmentedView.register(cellClass, forSegmentedCellWithReuseIdentifier: reuseIdentifier)
    }
    
    /// 注册表格
    /// - Parameters:
    ///   - nib: xib
    ///   - reuseIdentifier: 表格重用标识符
    public func register(_ nib: UINib?, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) {
        segmentedView.register(nib, forSegmentedCellWithReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - MNSegmentedViewDataSource
extension MNSegmentedViewController: MNSegmentedViewDataSource {
    
    public var preferredSegmentedTitles: [String] {
        
        guard let dataSource = dataSource else { return [] }
        return dataSource.preferredSegmentedTitles
    }
    
    public var preferredPresentationSegmentedIndex: Int {
        
        guard let dataSource = dataSource, let presentationIndex = dataSource.preferredPresentationSegmentedIndex else { return 0 }
        return presentationIndex
    }
    
    public var preferredSegmentedBackgroundView: UIView? {
        
        guard let dataSource = dataSource, let backgroundView = dataSource.preferredSegmentedBackgroundView else { return nil }
        return backgroundView
    }
    
    public var preferredSegmentedLeadingAccessoryView: UIView? {
        
        guard let dataSource = dataSource, let accessoryView = dataSource.preferredSegmentedLeadingAccessoryView else { return nil }
        return accessoryView
    }
    
    public var preferredSegmentedTrailingAccessoryView: UIView? {
        
        guard let dataSource = dataSource, let accessoryView = dataSource.preferredSegmentedTrailingAccessoryView else { return nil }
        return accessoryView
    }
    
    public func dimensionForSegmentedItemAt(_ index: Int) -> CGFloat {
        
        guard let dataSource = dataSource, let dimension = dataSource.segmentedViewController?(self, dimensionForSegmentedItemAt: index) else { return 0.0 }
        return dimension
    }
}

// MARK: - MNSegmentedViewDelegate
extension MNSegmentedViewController: MNSegmentedViewDelegate {
    
    func segmentedViewDidReloadItem(_ segmentedView: MNSegmentedView) {
        
        pageCoordinator.setPage(at: segmentedView.selectedIndex, direction: .forward, animated: false)
    }
    
    func segmentedView(_ segmentedView: MNSegmentedView, shouldSelectItemAt index: Int) -> Bool {
        
        true
    }
    
    func segmentedView(_ segmentedView: MNSegmentedView, didSelectItemAt index: Int, direction: UIPageViewController.NavigationDirection) {
        
        pageCoordinator.setPage(at: index, direction: direction, animated: true)
    }
    
    func segmentedView(_ segmentedView: MNSegmentedView, willDisplay cell: any MNSegmentedCellConvertible, item: MNSegmentedItem, at index: Int) {
        
        guard let delegate = delegate else { return }
        delegate.segmentedViewController?(self, willDisplay: cell, item: item, at: index)
    }
}

// MARK: - MNSegmentedPageCoordinatorDataSource
extension MNSegmentedViewController: MNSegmentedPageCoordinatorDataSource {
    
    var currentPageIndex: Int {
        
        segmentedView.selectedIndex
    }
    
    var numberOfPages: Int {
        
        segmentedView.items.count
    }
    
    var subpageHeaderHeight: CGFloat {
        
        segmentedView.frame.height
    }
    
    var subpageHeaderGreatestFiniteOffset: CGFloat {
        
        let minY = segmentedView.collectionView.frame.minY
        return max(0.0, minY - headerVisibleHeight)
    }
    
    func subpage(at index: Int) -> (any MNSegmentedSubpageConvertible)? {
        
        guard let dataSource = dataSource else { return nil }
        return dataSource.segmentedViewController(self, subpageAt: index)
    }
    
    func subpageContentOffset(_ page: any MNSegmentedSubpageConvertible) -> CGPoint {
        
        let scrollView = page.preferredSubpageScrollView
        var contentOffset = scrollView.contentOffset
        switch configuration.orientation {
        case .horizontal:
            guard scrollView.mn.isReachedLeastSize else { break }
            let greatestFiniteOffset = subpageHeaderGreatestFiniteOffset
            var minY = 0.0
            if let superview = scrollView.superview {
                minY = superview.convert(scrollView.frame, to: view).minY
            }
            guard greatestFiniteOffset > minY else { break }
            let maxOffsetY = greatestFiniteOffset - minY
            let offsetY: CGFloat = -scrollView.contentInset.top - segmentedView.frame.minY
            if abs(abs(segmentedView.frame.minY) - maxOffsetY) <= 0.01 {
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

// MARK: - MNSegmentedPageCoordinatorDelegate
extension MNSegmentedViewController: MNSegmentedPageCoordinatorDelegate {
    
    func pageViewController(_ viewController: UIPageViewController, didScrollTo subpage: any MNSegmentedSubpageConvertible) {
        
    }
    
    func pageViewController(_ viewController: UIPageViewController, subpage: any MNSegmentedSubpageConvertible, didChangeContentOffset contentOffset: CGPoint) {
        
    }
}




