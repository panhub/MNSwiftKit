//
//  MNListViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/5.
//  数据流控制器

import UIKit

/// 列表控制器
open class MNListViewController: MNExtendViewController {
    
    /// 列表类型
    @objc public enum ListType: Int {
        /// Table
        case table
        /// 瀑布流
        case collection
    }
    
    /// 是否需要刷新列表
    private var executeReloadList: Bool = false
    
    /// 数据列表视图
    @objc open var listView: UIScrollView { preferredListType == .table ? tableView : collectionView }
    
    /// 集合视图
    @objc public private(set) lazy var collectionView: UICollectionView = {
        let collectionView = preferredCollectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    /// 表格视图
    @objc public private(set) lazy var tableView: UITableView = {
        let tableView = preferredTableView
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let listView = listView
        contentView.addSubview(listView)
        if supportedRefreshEnabled {
            moveRefreshHeader(toParent: listView)
        }
        if supportedLoadMoreEnabled {
            moveLoadFooter(toParent: listView)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadListIfNeeded()
    }
}

// MARK: - 数据请求
extension MNListViewController {
    
    open override func prepareLoadData(_ request: HTTPDataRequest) {
        guard contentView.mn.isToastAppearing == false, listView.mn.isLoading == false else { return }
        contentView.mn.showActivityToast("请稍后")
    }
    
    open override func completeLoadData(_ result: HTTPResult) {
        reloadList()
        endRefrshing()
        super.completeLoadData(result)
    }
}

// MARK: - 刷新列表
extension MNListViewController {
    
    /// 重载列表
    @objc open func reloadList() -> Void {
        if preferredListType == .table {
            tableView.reloadData()
        } else {
            collectionView.reloadData()
        }
    }
    
    /// 标记需要重载列表
    @objc open func setNeedsReloadList() {
        executeReloadList = true
    }
    
    /// 如果被标记的话就重载列表
    @objc open func reloadListIfNeeded() {
        guard executeReloadList else { return }
        executeReloadList = false
        reloadList()
    }
}

// MARK: - 下拉刷新, 加载更多
extension MNListViewController {
    
    private func moveRefreshHeader(toParent listView: UIScrollView) {
        let header = preferredRefreshHeader
        header.addTarget(self, action: #selector(refresh))
        listView.mn.header = header
        didMoveRefreshHeader(header, toParent: listView)
    }
    
    private func moveLoadFooter(toParent listView: UIScrollView) {
        let footer = preferredLoadFooter
        footer.state = .noMoreData
        footer.addTarget(self, action: #selector(loadMore))
        listView.mn.footer = footer
        didMoveLoadFooter(footer, toParent: listView)
    }
    
    @objc private func refresh() {
        guard listView.mn.isLoadMore == false else {
            listView.mn.endRefreshing()
            return
        }
        beginRefresh()
    }
    
    @objc private func loadMore() {
        guard listView.mn.isRefreshing == false else {
            listView.mn.endLoadMore()
            return
        }
        beginLoadMore()
    }
    
    /// 开始刷新
    @objc open func beginRefresh() {
        guard let request = httpRequest, request.isRunning == false else {
            listView.mn.endRefreshing()
            return
        }
        reloadData()
    }
    
    /// 开始加载更多
    @objc open func beginLoadMore() {
        guard let request = httpRequest, request.isRunning == false else {
            listView.mn.endLoadMore()
            return
        }
        loadData()
    }
    
    /// 结束刷新/加载更多
    @objc open func endRefrshing() {
        listView.mn.endRefreshing()
        listView.mn.endLoadMore()
        guard let request = httpRequest else { return }
        listView.mn.isLoadMoreEnabled = request.hasMore
    }
    
    /// 即将添加刷新控件
    /// - Parameters:
    ///   - header: 刷新控件
    ///   - scrollView: 数据列表
    @objc open func didMoveRefreshHeader(_ header: MNRefreshHeader, toParent scrollView: UIScrollView) {}
    
    /// 即将添加加载更多控件
    /// - Parameters:
    ///   - footer: 加载更多控件
    ///   - scrollView: 数据列表
    @objc open func didMoveLoadFooter(_ footer: MNRefreshFooter, toParent scrollView: UIScrollView) {}
}

// MARK: - 数据支持
extension MNListViewController {
    
    /// 支持的列表类型
    /// - Returns: 列表类型
    @objc open var preferredListType: ListType { .table }

    /// 是否需要刷新控件
    /// - Returns: 是否需要刷新功能
    @objc open var supportedRefreshEnabled: Bool { false }
    
    /// 是否需要加载更多控件
    /// - Returns: 是否需要加载更多功能
    @objc open var supportedLoadMoreEnabled: Bool { false }
    
    /// 默认表格样式
    /// - Returns: 表格样式
    @objc open var preferredTableStyle: UITableView.Style { .plain }
    
    /// 默认表格视图
    /// - Returns: 表格视图
    @objc open var preferredTableView: UITableView {
        let tableView = UITableView(frame: contentView.bounds, style: preferredTableStyle)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = .white
        tableView.keyboardDismissMode = .onDrag
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        return tableView
    }
    
    /// 默认集合视图
    /// - Returns: 集合视图
    @objc open var preferredCollectionView: UICollectionView {
        let collectionView = UICollectionView(frame: contentView.bounds, collectionViewLayout: preferredCollectionViewLayout)
        collectionView.backgroundColor = .white
        collectionView.keyboardDismissMode = .onDrag
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }
    
    /// 默认集合视图约束对象
    /// - Returns: 集合视图约束对象
    @objc open var preferredCollectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.headerReferenceSize = .zero
        layout.footerReferenceSize = .zero
        return layout
    }
    
    /// 默认数据刷新控件
    /// - Returns: 刷新控件
    @objc open var preferredRefreshHeader: MNRefreshHeader {
        return MNRefreshStateHeader()
    }
    
    /// 默认加载更多控件
    /// - Returns: 加载更多控件
    @objc open var preferredLoadFooter: MNRefreshFooter {
        return MNRefreshStateFooter()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MNListViewController: UITableViewDelegate, UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 0 }
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("tableView(_:cellForRowAt:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MNListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 0 }
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("collectionView(_:cellForItemAt:) has not been implemented")
    }
}
