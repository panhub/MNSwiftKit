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
    
    /// 背景视图
    @objc optional var preferredSubpageBackgroundView: UIView? { get }
    
    /// 页头视图
    @objc optional var preferredSubpageHeaderView: UIView? { get }
    
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, dimensionForSegmentedAt index: Int) -> CGFloat
    
    /// 获取子界面
    /// - Parameters:
    ///   - viewController: 分段视图控制器
    ///   - index: 页码索引
    /// - Returns: 子界面控制器
    func segmentedViewController(_ viewController: MNSegmentedViewController, subpageAt index: Int) -> MNSegmentedSubpageConvertible
}

@objc public protocol MNSegmentedViewControllerDelegate: AnyObject {
    
    @objc optional func segmentedViewController(_ viewController: MNSegmentedViewController, willDisplay cell: MNSegmentedCellConvertible, item: MNSegmentedItem, at index: Int)
}

public class MNSegmentedViewController: UIViewController {
    
    /// 事件代理
    public weak var delegate: MNSegmentedViewControllerDelegate?
    
    /// 数据源
    public weak var dataSource: MNSegmentedViewControllerDataSource?
    
    /// 页面协调器
    private lazy var pageCoordinator = MNSegmentedPageCoordinator(configuration: configuration, pageViewController: pageViewController)
    
    /// 分页控制器
    private let pageViewController = UIPageViewController()
    
    /// 公共页头视图
    private let headerView = UIView()
    
    private lazy var segmentedView = MNSegmentedView(configuration: configuration)
    
    /// 配置信息
    private lazy var configuration = MNSegmentedConfiguration()
    
    
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
            // 横向
            NSLayoutConstraint.activate([
                pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
            // 放置公共视图与分段视图
            headerView.frame.size.width = view.frame.width
            headerView.autoresizingMask = [.flexibleWidth]
            view.addSubview(headerView)
            // 选择视图
            segmentedView.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(segmentedView)
            NSLayoutConstraint.activate([
                segmentedView.heightAnchor.constraint(equalToConstant: configuration.view.dimension)
            ])
            // 添加公共视图
            if let dataSource = dataSource, let subview = dataSource.preferredSubpageHeaderView, let subview = subview {
                // 添加公共视图
                subview.translatesAutoresizingMaskIntoConstraints = false
                headerView.insertSubview(subview, at: 0)
                NSLayoutConstraint.activate([
                    subview.topAnchor.constraint(equalTo: headerView.topAnchor),
                    subview.leftAnchor.constraint(equalTo: headerView.leftAnchor),
                    subview.rightAnchor.constraint(equalTo: headerView.rightAnchor),
                    subview.heightAnchor.constraint(equalToConstant: headerView.frame.height)
                ])
                NSLayoutConstraint.activate([
                    segmentedView.topAnchor.constraint(equalTo: subview.bottomAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    segmentedView.topAnchor.constraint(equalTo: headerView.topAnchor)
                ])
            }
            NSLayoutConstraint.activate([
                segmentedView.leftAnchor.constraint(equalTo: headerView.leftAnchor),
                segmentedView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
                segmentedView.rightAnchor.constraint(equalTo: headerView.rightAnchor)
            ])
        default:
            // 纵向
            segmentedView.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(segmentedView, belowSubview: pageViewController.view)
            NSLayoutConstraint.activate([
                segmentedView.topAnchor.constraint(equalTo: view.topAnchor),
                segmentedView.leftAnchor.constraint(equalTo: view.leftAnchor),
                segmentedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                segmentedView.widthAnchor.constraint(equalToConstant: configuration.view.dimension)
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

// MARK: - 禁止生命周期转发
extension MNSegmentedViewController {
    
    /// 禁止生命周期转发到子控制器
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool { false }
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
    
    public func dimensionForSegmentedAt(_ index: Int) -> CGFloat {
        
        guard let dataSource = dataSource, let dimension = dataSource.segmentedViewController?(self, dimensionForSegmentedAt: index) else { return 0.0 }
        return dimension
    }
}

// MARK: - MNSegmentedViewDelegate
extension MNSegmentedViewController: MNSegmentedViewDelegate {
    
    func segmentedViewDidReloadItems(_ segmentedView: MNSegmentedView) {
        
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
    
    func subpage(at index: Int) -> (any MNSegmentedSubpageConvertible)? {
        
        guard let dataSource = dataSource else { return nil }
        return dataSource.segmentedViewController(self, subpageAt: index)
    }
}

// MARK: - MNSegmentedPageCoordinatorDelegate
extension MNSegmentedViewController: MNSegmentedPageCoordinatorDelegate {
    
    func pageViewController(_ viewController: UIPageViewController, subpage: any MNSegmentedSubpageConvertible, didChangeContentOffset contentOffset: CGPoint) {
        
    }
}




