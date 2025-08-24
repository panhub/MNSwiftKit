//
//  MNAssetAlbumView.swift
//  MNKit
//
//  Created by 冯盼 on 2022/1/31.
//  相簿视图

import UIKit

/// 相簿事件代理
protocol MNAssetAlbumViewDelegate: NSObjectProtocol {
    /// 相簿点击事件
    /// - Parameters:
    ///   - albumView: 相簿视图
    ///   - album: 选择的相簿模型
    func albumView(_ albumView: MNAssetAlbumView, didSelect album: MNAssetAlbum?) -> Void
}

/// 相簿视图
class MNAssetAlbumView: UIView {
    /// 相簿数据集合
    var albums: [MNAssetAlbum] = [MNAssetAlbum]()
    /// 相册配置信息
    private let options: MNAssetPickerOptions
    /// 显示相簿
    private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    /// 事件代理
    weak var delegate: MNAssetAlbumViewDelegate?
    /// 表格顶部约束
    private lazy var tableTopLayout = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
    /// 表格高度约束
    private lazy var tableHeightLayout = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
    
    /// 构造相簿视图
    /// - Parameter options: 相册配置模型
    init(options: MNAssetPickerOptions) {
        
        self.options = options
        
        super.init(frame: .zero)
        
        isHidden = true
        clipsToBounds = true
        backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 63.0
        tableView.separatorStyle = .singleLine
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = options.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 10.0))
        tableView.separatorColor = options.mode == .light ? .gray.withAlphaComponent(0.15) : .black.withAlphaComponent(0.85)
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        addSubview(tableView)
        tableView.addConstraint(tableHeightLayout)
        addConstraints([
            tableTopLayout,
            NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        tap.delegate = self
        tap.numberOfTouchesRequired = 1
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新相簿数据
    /// - Parameter albums: 相簿集合
    func update(albums: [MNAssetAlbum]) {
        let rowHeight = tableView.rowHeight
        let footerHeight = tableView.tableFooterView?.frame.height ?? 0.0
        var count: Int = min(7, albums.count)
        var height: CGFloat = rowHeight*CGFloat(count)
        let max: CGFloat = ceil(frame.height/4.0*3.0)
        if height > max {
            count = Int((max - footerHeight)/CGFloat(rowHeight))
            height = rowHeight*CGFloat(count)
        }
        self.albums.removeAll()
        self.albums.append(contentsOf: albums)
        tableHeightLayout.constant = height
        tableTopLayout.constant = -height
        setNeedsLayout()
    }
    
    /// 刷新相簿
    func reloadVisibleRows() {
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        tableView.reloadRows(at: indexPaths, with: .none)
    }
    
    /// 背景点击事件
    @objc func tap() {
        guard let delegate = delegate else { return }
        delegate.albumView(self, didSelect: nil)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension MNAssetAlbumView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { albums.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MNAssetAlbumCell.self)) ?? MNAssetAlbumCell(reuseIdentifier: NSStringFromClass(MNAssetAlbumCell.self), options: options)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < albums.count, let cell = cell as? MNAssetAlbumCell else { return }
        let album = albums[indexPath.row]
        cell.updateAlbum(album)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < albums.count else { return }
        let album = albums[indexPath.row]
        guard album.isSelected == false else { return }
        for (index, obj) in albums.enumerated() {
            obj.isSelected = index == indexPath.row
        }
        if let indexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRows(at: indexPaths, with: .none)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) { [weak self] in
            guard let self = self, let delegate = self.delegate else { return }
            delegate.albumView(self, didSelect: album)
        }
    }
}

// MARK: - Show & Dismiss
extension MNAssetAlbumView {
    
    /// 展示相簿视图
    /// - Parameter completion: 展示后回调
    func show(completion: (()->Void)? = nil) {
        guard isHidden else { return }
        isHidden = false
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.tableTopLayout.constant = 0.0
            self.backgroundColor = .black.withAlphaComponent(0.45)
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
    
    /// 结束展示
    /// - Parameter completion: 结束展示后回调
    func dismiss(completion: (()->Void)? = nil) {
        guard isHidden == false else { return }
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.backgroundColor = .clear
            self.tableTopLayout.constant = -self.tableHeightLayout.constant
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.isHidden = true
            completion?()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNAssetAlbumView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return false }
        return view == self
    }
}

