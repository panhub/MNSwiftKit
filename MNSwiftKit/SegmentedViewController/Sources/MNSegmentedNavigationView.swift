//
//  MNSegmentedNavigationView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit

/// 分段导航视图数据源
@objc public protocol MNSegmentedNavigationDataSource: AnyObject {
    
    /// 子界面标题集合
    var preferredSegmentedNavigationTitles: [String] { get }
    
    /// 公共页头视图
    @objc optional var preferredSegmentedNavigationHeaderView: UIView? { get }
    
    /// 初始子界面索引
    @objc optional var preferredSegmentedNavigationPresentationIndex: Int { get }
    
    /// 前/左附属视图
    @objc optional var preferredSegmentedNavigationLeadingAccessoryView: UIView? { get }
    
    /// 后/右附属视图
    @objc optional var preferredSegmentedNavigationTrailingAccessoryView: UIView? { get }
    
    /// 指定分割导航项item尺寸 依据布局方向取宽高
    /// - Parameter index: 索引
    /// - Returns: 导航项item尺寸
    @objc optional func dimensionForSegmentedNavigationItemAt(_ index: Int) -> CGFloat
}

/// 分段导航事件代理
@objc protocol MNSegmentedNavigationDelegate: AnyObject {
    
    /// 重载分割项告知
    /// - Parameter navigationView: 分割视图
    func navigationViewDidReloadItem(_ navigationView: MNSegmentedNavigationView)
    
    /// 询问是否响应点击事件
    /// - Parameters:
    ///   - navigationView: 分割视图
    ///   - index: 点击索引
    /// - Returns: 是否允许选择
    func navigationView(_ navigationView: MNSegmentedNavigationView, shouldSelectItemAt index: Int) -> Bool
    
    /// 分割项选择告知
    /// - Parameters:
    ///   - navigationView: 分割视图
    ///   - index: 点击的索引
    ///   - direction: 点击的索引是大于还是小于原索引
    func navigationView(_ navigationView: MNSegmentedNavigationView, didSelectItemAt index: Int, direction: UIPageViewController.NavigationDirection)
    
    /// 即将显示分割项
    /// - Parameters:
    ///   - navigationView: 分割视图
    ///   - cell: 分割项
    ///   - item: 分割项模型
    ///   - index: 索引
    @objc optional func navigationView(_ navigationView: MNSegmentedNavigationView, willDisplay cell: MNSegmentedNavigationCellConvertible, item: MNSegmentedNavigationItem, at index: Int)
}

/// 分段导航视图
class MNSegmentedNavigationView: UIView {
    /// 配置
    private let configuration: MNSegmentedConfiguration
    /// 是否可以点击
    var isSeletionEnabled: Bool = true
    /// 是否已加载过item
    private(set) var isItemLoaded: Bool = false
    /// 事件代理
    weak var delegate: MNSegmentedNavigationDelegate?
    /// 数据源
    weak var dataSource: MNSegmentedNavigationDataSource?
    /// 分各项数组
    private(set) var items: [MNSegmentedNavigationItem] = []
    /// 集合视图的背景视图(放置指示视图)
    private var collectionBackgroundView: UIView!
    /// 滑动中猜测目标索引
    private var targetIndex: Int = 0
    /// 当前选中索引
    private(set) var selectedIndex: Int = 0
    /// 滑动中索引变化
    private var lastSelectedIndex: Int = 0
    /// 指示视图
    private var indicatorView = UIImageView()
    /// 前/左方分割线
    let leadingSeparator = UIView()
    /// 后/右方分割线
    private let trailingSeparator = UIView()
    /// 背景视图
    private weak var backgroundView: UIView?
    /// 左/上方附属视图
    private weak var leadingAccessoryView: UIView?
    /// 右/下方附属视图
    private weak var trailingAccessoryView: UIView?
    /// 表格重用标识符
    private var reuseIdentifier: String = "com.mn.segmented.cell.identifier"
    /// 集合视图
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    /// 构造分段控制器的导航视图
    /// - Parameters:
    ///   - configuration: 配置信息
    ///   - headerView: 公共头视图
    init(configuration: MNSegmentedConfiguration, headerView: UIView?) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        backgroundColor = configuration.navigation.backgroundColor
        
        leadingSeparator.backgroundColor = configuration.separator.backgroundColor
        leadingSeparator.isHidden = configuration.separator.style.contains(.leading) == false
        leadingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingSeparator)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = configuration.navigation.contentInset
        layout.scrollDirection = configuration.orientation == .horizontal ? .horizontal : .vertical
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = configuration.orientation == .horizontal ? configuration.item.spacing : 0.0
        layout.minimumInteritemSpacing = configuration.orientation == .horizontal ? 0.0 : configuration.item.spacing
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = configuration.orientation == .vertical
        collectionView.alwaysBounceHorizontal = configuration.orientation == .horizontal
        collectionView.register(MNSegmentedNavigationCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        trailingSeparator.backgroundColor = configuration.separator.backgroundColor
        trailingSeparator.isHidden = configuration.separator.style.contains(.trailing) == false
        trailingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trailingSeparator)
        
        switch configuration.orientation {
        case .horizontal:
            // 横向，有公共头视图
            if let headerView = headerView {
                headerView.translatesAutoresizingMaskIntoConstraints = false
                insertSubview(headerView, at: 0)
                NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: topAnchor),
                    headerView.leftAnchor.constraint(equalTo: leftAnchor),
                    headerView.rightAnchor.constraint(equalTo: rightAnchor),
                    headerView.heightAnchor.constraint(equalToConstant: headerView.frame.height)
                ])
                NSLayoutConstraint.activate([
                    leadingSeparator.topAnchor.constraint(equalTo: headerView.bottomAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    leadingSeparator.topAnchor.constraint(equalTo: topAnchor)
                ])
            }
            NSLayoutConstraint.activate([
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: configuration.separator.constraint.leading),
                leadingSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -configuration.separator.constraint.trailing),
                leadingSeparator.heightAnchor.constraint(equalToConstant: configuration.separator.constraint.dimension)
            ])
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: configuration.separator.style.contains(.leading) ? leadingSeparator.bottomAnchor : leadingSeparator.topAnchor),
                collectionView.leftAnchor.constraint(equalTo: leftAnchor),
                collectionView.rightAnchor.constraint(equalTo: rightAnchor),
                collectionView.heightAnchor.constraint(equalToConstant: configuration.navigation.dimension)
            ])
            
            if configuration.separator.style.contains(.trailing) {
                NSLayoutConstraint.activate([
                    trailingSeparator.topAnchor.constraint(equalTo: collectionView.bottomAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    trailingSeparator.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
                ])
            }
            
            NSLayoutConstraint.activate([
                trailingSeparator.leftAnchor.constraint(equalTo: leadingSeparator.leftAnchor),
                trailingSeparator.rightAnchor.constraint(equalTo: leadingSeparator.rightAnchor),
                trailingSeparator.heightAnchor.constraint(equalTo: leadingSeparator.heightAnchor),
                trailingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        default:
            // 纵向，无公共头视图
            NSLayoutConstraint.activate([
                leadingSeparator.topAnchor.constraint(equalTo: topAnchor, constant: configuration.separator.constraint.leading),
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
                leadingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -configuration.separator.constraint.trailing),
                leadingSeparator.widthAnchor.constraint(equalToConstant: configuration.separator.constraint.dimension)
            ])
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.leftAnchor.constraint(equalTo: configuration.separator.style.contains(.leading) ? leadingSeparator.rightAnchor : leadingSeparator.leftAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                collectionView.widthAnchor.constraint(equalToConstant: configuration.navigation.dimension)
            ])
            
            if configuration.separator.style.contains(.trailing) {
                NSLayoutConstraint.activate([
                    trailingSeparator.leftAnchor.constraint(equalTo: collectionView.rightAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    trailingSeparator.rightAnchor.constraint(equalTo: collectionView.rightAnchor)
                ])
            }
            
            NSLayoutConstraint.activate([
                trailingSeparator.topAnchor.constraint(equalTo: leadingSeparator.topAnchor),
                trailingSeparator.bottomAnchor.constraint(equalTo: leadingSeparator.bottomAnchor),
                trailingSeparator.widthAnchor.constraint(equalTo: leadingSeparator.widthAnchor),
                trailingSeparator.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
        
        // 指示器视图
        indicatorView.clipsToBounds = true
        indicatorView.image = configuration.indicator.image
        indicatorView.layer.cornerRadius = configuration.indicator.cornerRadius
        indicatorView.contentMode = configuration.indicator.contentMode
        indicatorView.backgroundColor = configuration.indicator.backgroundColor
        switch configuration.indicator.position {
        case .above:
            // 指示器在上层
            collectionView.addSubview(indicatorView)
        case .below:
            // 指示器在底层
            let backgroundView = UIView()
            backgroundView.isUserInteractionEnabled = false
            collectionView.backgroundView = backgroundView
            collectionBackgroundView = UIView(frame: backgroundView.bounds)
            collectionBackgroundView.autoresizingMask = configuration.orientation == .horizontal ? [.flexibleHeight] : [.flexibleWidth]
            backgroundView.addSubview(collectionBackgroundView)
            collectionBackgroundView.addSubview(indicatorView)
            collectionView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.old, .new], context: nil)
            collectionView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let _ = collectionBackgroundView {
            collectionView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
            collectionView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard isItemLoaded == false else { return }
        isItemLoaded = true
        reloadSubview()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let change = change else { return }
        switch keyPath {
        case #keyPath(UIScrollView.contentSize):
            guard let contentSize = change[.newKey] as? CGSize else { break }
            collectionBackgroundView.frame.size.width = contentSize.width
        case #keyPath(UIScrollView.contentOffset):
            guard let contentOffset = change[.newKey] as? CGPoint else { break }
            switch configuration.orientation {
            case .horizontal:
                collectionBackgroundView.frame.origin.x = -contentOffset.x
            default:
                collectionBackgroundView.frame.origin.y = -contentOffset.y
            }
        default:
            // 一般不会走到这里
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - Register
extension MNSegmentedNavigationView {
    
    /// 注册表格
    /// - Parameters:
    ///   - cellClass: 表格类
    ///   - reuseIdentifier: 表格重用标识符
    func register<T>(_ cellClass: T.Type, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) where T: MNSegmentedNavigationCellConvertible {
        self.reuseIdentifier = reuseIdentifier
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    /// 注册表格
    /// - Parameters:
    ///   - nib: xib
    ///   - reuseIdentifier: 表格重用标识符
    func register(_ nib: UINib?, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - Reload
extension MNSegmentedNavigationView {
    
    /// 移动当前选中项到指定位置
    /// - Parameters:
    ///   - index: 选中的item索引
    ///   - position: 目标位置
    ///   - animated: 是否动态
    private func scrollToItem(at index: Int, to position: MNSegmentedConfiguration.Navigation.ScrollPosition, animated: Bool) {
        var scrollPosition: UICollectionView.ScrollPosition = .centeredHorizontally
        switch position {
        case .leading:
            scrollPosition = configuration.orientation == .horizontal ? .left : .top
        case .trailing:
            scrollPosition = configuration.orientation == .horizontal ? .right : .bottom
        case .center:
            scrollPosition = configuration.orientation == .horizontal ? .centeredHorizontally : .centeredVertically
        default:
            // 可见即可
            if index < items.count {
                let item = items[index]
                collectionView.scrollRectToVisible(item.frame, animated: animated)
            }
            return
        }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: scrollPosition, animated: animated)
    }
    
    /// 指定选择的item索引
    /// - Parameters:
    ///   - index: 索引值
    ///   - animated: 是否动态
    func setSelectedItem(at index: Int, animated: Bool) {
        let targetItem: MNSegmentedNavigationItem? = index < items.count ? items[index] : nil
        let currentItem: MNSegmentedNavigationItem? = selectedIndex < items.count ? items[selectedIndex] : nil
        let targetIndexPath: IndexPath = IndexPath(item: index, section: 0)
        let currentIndexPath: IndexPath = IndexPath(item: selectedIndex, section: 0)
        selectedIndex = index
        currentItem?.isSelected = false
        currentItem?.titleScale = 1.0
        currentItem?.titleColor = configuration.item.normal.titleColor
        currentItem?.borderColor = configuration.item.normal.borderColor
        currentItem?.backgroundColor = configuration.item.normal.backgroundColor
        currentItem?.backgroundImage = configuration.item.normal.backgroundImage
        targetItem?.isSelected = true
        targetItem?.titleScale = max(1.0, configuration.item.selected.titleScale)
        targetItem?.titleColor = configuration.item.selected.titleColor
        targetItem?.borderColor = configuration.item.selected.borderColor
        targetItem?.backgroundColor = configuration.item.selected.backgroundColor
        targetItem?.backgroundImage = configuration.item.selected.backgroundImage
        let currentItemCell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedNavigationCellConvertible
        currentItemCell?.updateTitleColor?(configuration.item.normal.titleColor)
        currentItemCell?.updateBorderColor?(configuration.item.normal.borderColor)
        currentItemCell?.updateBackgroundImage?(configuration.item.normal.backgroundImage)
        currentItemCell?.updateCell?(selected: false, at: currentIndexPath.item)
        let targetItemCell = collectionView.cellForItem(at: targetIndexPath) as? MNSegmentedNavigationCellConvertible
        targetItemCell?.updateTitleColor?(configuration.item.selected.titleColor)
        targetItemCell?.updateBorderColor?(configuration.item.selected.borderColor)
        targetItemCell?.updateBackgroundImage?(configuration.item.selected.backgroundImage)
        targetItemCell?.updateCell?(selected: true, at: targetIndexPath.item)
        // 动画结束
        let completionHandler: (Bool)->Void = { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.isUserInteractionEnabled = true
            if let _ = targetItem {
                self.scrollToItem(at: index, to: self.configuration.navigation.scrollPosition, animated: animated)
            }
        }
        // 开始指示图动画
        collectionView.isUserInteractionEnabled = false
        switch configuration.indicator.animationType {
        case .move:
            // 滑动
            UIView.animate(withDuration: animated ? configuration.indicator.animationDuration : 0.0, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
                guard let self = self else { return }
                if let item = currentItem, let cell = currentItemCell {
                    cell.updateTitleScale?(item.titleScale)
                    cell.updateBackgroundColor?(item.backgroundColor)
                }
                if let item = targetItem {
                    if let cell = targetItemCell {
                        cell.updateTitleScale?(item.titleScale)
                        cell.updateBackgroundColor?(item.backgroundColor)
                    }
                    self.indicatorView.frame = item.indicatorFrame
                }
            }, completion: completionHandler)
        case .stretch:
            // 拉伸
            let animationDuration = animated ? configuration.indicator.animationDuration/2.0 : 0.0
            UIView.animate(withDuration: animationDuration) { [weak self] in
                guard let self = self else { return }
                guard let currentItem = currentItem else { return }
                if let cell = currentItemCell {
                    cell.updateTitleScale?(currentItem.titleScale)
                    cell.updateBackgroundColor?(currentItem.backgroundColor)
                }
                guard let targetItem = targetItem else { return }
                if targetIndexPath.item > currentIndexPath.item {
                    //
                    if self.configuration.orientation == .horizontal {
                        // 横向布局
                        self.indicatorView.frame.size.width = targetItem.indicatorFrame.maxX - currentItem.indicatorFrame.minX
                    } else {
                        // 纵向布局
                        self.indicatorView.frame.size.height = targetItem.indicatorFrame.maxY - currentItem.indicatorFrame.minY
                    }
                } else {
                    //
                    if self.configuration.orientation == .horizontal {
                        // 横向布局
                        self.indicatorView.frame.origin.x = targetItem.indicatorFrame.minX
                        self.indicatorView.frame.size.width = currentItem.indicatorFrame.maxX - targetItem.indicatorFrame.minX
                    } else {
                        // 纵向布局
                        self.indicatorView.frame.origin.y = targetItem.indicatorFrame.minY
                        self.indicatorView.frame.size.height = currentItem.indicatorFrame.maxY - targetItem.indicatorFrame.minY
                    }
                }
            } completion: { [weak self] _ in
                UIView.animate(withDuration: animationDuration, animations: {
                    guard let self = self else { return }
                    guard let targetItem = targetItem else { return }
                    if let targetItemCell = targetItemCell {
                        targetItemCell.updateTitleScale?(targetItem.titleScale)
                        targetItemCell.updateBackgroundColor?(targetItem.backgroundColor)
                    }
                    self.indicatorView.frame = targetItem.indicatorFrame
                }, completion: completionHandler)
            }
        }
        /*
        UIView.animate(withDuration: animated ? configuration.indicator.animationDuration : 0.0, delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            if let item = currentItem, let cell = currentItemCell {
                cell.updateTitleScale?(item.titleScale)
                cell.updateBackgroundColor?(item.backgroundColor)
            }
            if let item = targetItem {
                if let cell = targetItemCell {
                    cell.updateTitleScale?(item.titleScale)
                    cell.updateBackgroundColor?(item.backgroundColor)
                }
                self.indicatorView.frame = item.indicatorFrame
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.isUserInteractionEnabled = true
            if let _ = targetItem {
                self.scrollToItem(at: index, to: self.configuration.navigation.scrollPosition, animated: animated)
            }
        }
        */
    }
}

// MARK: - Reload
extension MNSegmentedNavigationView {
    
    /// 重载子视图
    func reloadSubview() {
        reloadBackgroundView()
        reloadAccessoryView()
        reloadItems()
        if let dataSource = dataSource, let index = dataSource.preferredSegmentedNavigationPresentationIndex {
            selectedIndex = index
        } else {
            selectedIndex = 0
        }
        reloadData()
        if let delegate = delegate {
            delegate.navigationViewDidReloadItem(self)
        }
    }
    
    /// 重载背景视图
    func reloadBackgroundView() {
        if let backgroundView = backgroundView {
            backgroundView.removeFromSuperview()
            self.backgroundView = nil
        }
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(backgroundView, at: 0)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
    
    /// 重载附属视图
    func reloadAccessoryView() {
        let contentInset = configuration.navigation.contentInset
        if let accessoryView = leadingAccessoryView {
            accessoryView.removeFromSuperview()
            leadingAccessoryView = nil
        }
        if let dataSource = dataSource, let accessoryView = dataSource.preferredSegmentedNavigationLeadingAccessoryView, let accessoryView = accessoryView {
            // 左/上方附属视图
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(accessoryView, aboveSubview: collectionView)
            leadingAccessoryView = accessoryView
            switch configuration.orientation {
            case .horizontal:
                NSLayoutConstraint.activate([
                    accessoryView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: contentInset.top),
                    accessoryView.leftAnchor.constraint(equalTo: leftAnchor),
                    accessoryView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -contentInset.bottom),
                    accessoryView.widthAnchor.constraint(equalToConstant: accessoryView.frame.width)
                ])
            default:
                NSLayoutConstraint.activate([
                    accessoryView.topAnchor.constraint(equalTo: topAnchor),
                    accessoryView.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: contentInset.left),
                    accessoryView.rightAnchor.constraint(equalTo: collectionView.rightAnchor, constant: -contentInset.right),
                    accessoryView.heightAnchor.constraint(equalToConstant: accessoryView.frame.height)
                ])
            }
        }
        if let accessoryView = trailingAccessoryView {
            accessoryView.removeFromSuperview()
            trailingAccessoryView = nil
        }
        if let dataSource = dataSource, let accessoryView = dataSource.preferredSegmentedNavigationTrailingAccessoryView, let accessoryView = accessoryView {
            // 右/下方附属视图
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(accessoryView, aboveSubview: collectionView)
            trailingAccessoryView = accessoryView
            switch configuration.orientation {
            case .horizontal:
                NSLayoutConstraint.activate([
                    accessoryView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: contentInset.top),
                    accessoryView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -contentInset.bottom),
                    accessoryView.rightAnchor.constraint(equalTo: rightAnchor),
                    accessoryView.widthAnchor.constraint(equalToConstant: accessoryView.frame.width)
                ])
            default:
                NSLayoutConstraint.activate([
                    accessoryView.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: contentInset.left),
                    accessoryView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    accessoryView.rightAnchor.constraint(equalTo: collectionView.rightAnchor, constant: -contentInset.right),
                    accessoryView.heightAnchor.constraint(equalToConstant: accessoryView.frame.height)
                ])
            }
        }
    }
    
    /// 重载分割item
    func reloadItems() {
        var titles: [String] = []
        if let dataSource = dataSource {
            titles.append(contentsOf: dataSource.preferredSegmentedNavigationTitles)
        }
        switch configuration.orientation {
        case .horizontal:
            reloadHorizontalItems(titles)
        default:
            reloadVerticalItems(titles)
        }
    }
    
    /// 重载横向布局分割item
    /// - Parameter titles: 标题集合
    private func reloadHorizontalItems(_ titles: [String]) {
        // 约束信息
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var sectionInset: UIEdgeInsets = layout.sectionInset
        // 内容尺寸
        let contentSize: CGSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: sectionInset).size
        // 标题项追加宽度
        let appendWidth: CGFloat = configuration.item.dimension
        // item间隔
        let interitemSpacing: CGFloat = configuration.item.spacing
        // 标题字体
        let titleFont: UIFont = configuration.item.titleFont
        // 缩放因数
        let titleScale: CGFloat = max(configuration.item.selected.titleScale, 1.0)
        // 起始
        var x: CGFloat = sectionInset.left
        // 
        items.removeAll()
        for (index, title) in titles.enumerated() {
            var titleSize: CGSize = title.size(withAttributes: [.font:titleFont])
            titleSize.width = ceil(titleSize.width)
            titleSize.height = ceil(titleSize.height)
            var itemWidth: CGFloat = max(titleSize.width + appendWidth, ceil(titleSize.width*titleScale))
            // 外界指定
            if let dataSource = dataSource, let width = dataSource.dimensionForSegmentedNavigationItemAt?(index), width > 0.0 {
                itemWidth = width
            }
            let item = MNSegmentedNavigationItem()
            item.title = title
            item.titleSize = titleSize
            item.titleFont = titleFont
            item.titleColor = configuration.item.normal.titleColor
            item.borderColor = configuration.item.normal.borderColor
            item.borderWidth = configuration.item.borderWidth
            item.borderRadius = configuration.item.cornerRadius
            item.dividerColor = configuration.item.dividerColor
            item.dividerConstraint = configuration.item.dividerConstraint
            item.badgeFont = configuration.badge.textFont
            item.badgeTextColor = configuration.badge.textColor
            item.badgeInset = configuration.badge.contentInset
            item.badgeColor = configuration.badge.backgroundColor
            item.badgeImage = configuration.badge.backgroundImage
            item.badgeOffset = configuration.badge.offset
            item.backgroundColor = configuration.item.normal.backgroundColor
            item.backgroundImage = configuration.item.normal.backgroundImage
            item.frame = CGRect(x: x, y: sectionInset.top, width: itemWidth, height: contentSize.height)
            items.append(item)
            x += (itemWidth + interitemSpacing)
        }
        // 布局行为
        if let first = items.first, let last = items.last {
            let width = last.frame.maxX - first.frame.minX
            let deviation = contentSize.width - width
            if deviation > 0.0 {
                // 内容不够
                switch configuration.navigation.adjustmentBehavior {
                case .centered:
                    // 居中
                    let append = (deviation + sectionInset.left + sectionInset.right)/2.0 - sectionInset.left
                    if append > 0.0 {
                        for item in items {
                            item.frame.origin.x += append
                        }
                        sectionInset.left += append
                        sectionInset.right += (deviation - append)
                    } else {
                        // 全部补充至右侧
                        sectionInset.right += deviation
                    }
                    layout.sectionInset = sectionInset
                case .expanded:
                    // 充满
                    let append: CGFloat = floor(deviation/CGFloat(items.count)*10.0)/10.0
                    for (index, item) in items.enumerated() {
                        item.frame.origin.x += (CGFloat(index)*append)
                        item.frame.size.width += append
                    }
                default: break
                }
            }
        }
        // 指示视图偏移
        let indicatorOffset: UIOffset = configuration.indicator.offset
        // 指示视图位置
        for item in items {
            let selectedTitleWidth = ceil(item.titleSize.width*titleScale)
            switch configuration.indicator.constraint {
            case .matchTitle(let height):
                // 与标题同宽
                let margin: CGFloat = (item.frame.width - selectedTitleWidth)/2.0
                item.indicatorFrame = .init(x: item.frame.minX + margin + indicatorOffset.horizontal, y: collectionView.frame.height - height + indicatorOffset.vertical, width: selectedTitleWidth, height: height)
            case .matchItem(let height):
                // 与item同宽
                item.indicatorFrame = .init(x: item.frame.minX + indicatorOffset.horizontal, y: collectionView.frame.height - height + indicatorOffset.vertical, width: item.frame.width, height: height)
            case .fixed(let width, let height):
                // 使用固定尺寸
                let y: CGFloat = collectionView.frame.height - height + indicatorOffset.vertical
                switch configuration.indicator.alignment {
                case .leading:
                    // 头部对齐
                    item.indicatorFrame = .init(x: item.frame.minX + indicatorOffset.horizontal, y: y, width: width, height: height)
                case .center:
                    // 中心对齐
                    let margin: CGFloat = (item.frame.width - width)/2.0
                    item.indicatorFrame = .init(x: item.frame.minX + margin + indicatorOffset.horizontal, y: y, width: width, height: height)
                case .trailing:
                    // 尾部对齐
                    item.indicatorFrame = .init(x: item.frame.maxX - width + indicatorOffset.horizontal, y: y, width: width, height: height)
                }
            }
        }
    }
    
    /// 重载纵向分割item
    /// - Parameter titles: 标题集合
    private func reloadVerticalItems(_ titles: [String]) {
        // 约束信息
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var sectionInset: UIEdgeInsets = layout.sectionInset
        // 内容尺寸
        let contentSize: CGSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: sectionInset).size
        // 分割项高度
        let itemHeight: CGFloat = configuration.item.dimension
        // item间隔
        let interitemSpacing: CGFloat = configuration.item.spacing
        // 标题字体
        let titleFont: UIFont = configuration.item.titleFont
        // 起始
        var y: CGFloat = sectionInset.top
        //
        items.removeAll()
        for (index, title) in titles.enumerated() {
            var titleSize: CGSize = title.size(withAttributes: [.font:titleFont])
            titleSize.width = ceil(titleSize.width)
            titleSize.height = ceil(titleSize.height)
            let item = MNSegmentedNavigationItem()
            item.title = title
            item.titleSize = titleSize
            item.titleFont = titleFont
            item.titleColor = configuration.item.normal.titleColor
            item.borderColor = configuration.item.normal.borderColor
            item.borderWidth = configuration.item.borderWidth
            item.borderRadius = configuration.item.cornerRadius
            item.dividerColor = configuration.item.dividerColor
            item.dividerConstraint = configuration.item.dividerConstraint
            item.badgeFont = configuration.badge.textFont
            item.badgeTextColor = configuration.badge.textColor
            item.badgeInset = configuration.badge.contentInset
            item.badgeColor = configuration.badge.backgroundColor
            item.badgeImage = configuration.badge.backgroundImage
            item.badgeOffset = configuration.badge.offset
            item.backgroundColor = configuration.item.normal.backgroundColor
            item.backgroundImage = configuration.item.normal.backgroundImage
            item.frame = CGRect(x: sectionInset.left, y: y, width: contentSize.width, height: itemHeight)
            // 外界指定高度
            if let dataSource = dataSource, let height = dataSource.dimensionForSegmentedNavigationItemAt?(index), height > 0.0 {
                item.frame.size.height = height
            }
            items.append(item)
            y += (item.frame.height + interitemSpacing)
        }
        if let first = items.first, let last = items.last {
            let height = last.frame.maxY - first.frame.minY
            let deviation = contentSize.height - height
            if deviation > 0.0 {
                // 内容不够
                switch configuration.navigation.adjustmentBehavior {
                case .centered:
                    // 居中
                    let append = (deviation + sectionInset.top + sectionInset.bottom)/2.0 - sectionInset.top
                    if append > 0.0 {
                        for item in items {
                            item.frame.origin.y += append
                        }
                        sectionInset.top += append
                        sectionInset.bottom += (deviation - append)
                    } else {
                        // 全部补充至下方
                        sectionInset.bottom += deviation
                    }
                    layout.sectionInset = sectionInset
                case .expanded:
                    // 充满
                    let append: CGFloat = floor(deviation/CGFloat(items.count)*10.0)/10.0
                    for (index, item) in items.enumerated() {
                        item.frame.origin.y += (CGFloat(index)*append)
                        item.frame.size.height += append
                    }
                default: break
                }
            }
        }
        // 指示视图偏移
        let indicatorOffset: UIOffset = configuration.indicator.offset
        // 缩放因数
        let titleScale: CGFloat = max(configuration.item.selected.titleScale, 1.0)
        // 指示视图位置
        for item in items {
            let selectedTitleHeight = ceil(item.titleSize.height*titleScale)
            switch configuration.indicator.constraint {
            case .matchTitle(let width):
                // 与标题同高
                let margin: CGFloat = (item.frame.height - selectedTitleHeight)/2.0
                item.indicatorFrame = .init(x: collectionView.frame.width - width + indicatorOffset.horizontal, y: item.frame.minY + margin + indicatorOffset.vertical, width: width, height: selectedTitleHeight)
            case .matchItem(let width):
                // 与item同高
                item.indicatorFrame = .init(x: collectionView.frame.width - width + indicatorOffset.horizontal, y: item.frame.minY + indicatorOffset.vertical, width: width, height: item.frame.height)
            case .fixed(let width, let height):
                // 使用固定尺寸
                let x: CGFloat = collectionView.frame.width - width + indicatorOffset.horizontal
                switch configuration.indicator.alignment {
                case .leading:
                    // 头部对齐
                    item.indicatorFrame = .init(x: x, y: item.frame.minY + indicatorOffset.vertical, width: width, height: height)
                case .center:
                    // 中心对齐
                    let margin: CGFloat = (item.frame.height - height)/2.0
                    item.indicatorFrame = .init(x: x, y: item.frame.minY + margin + indicatorOffset.vertical, width: width, height: height)
                case .trailing:
                    // 尾部对齐
                    item.indicatorFrame = .init(x: x, y: item.frame.minY - height + indicatorOffset.vertical, width: width, height: height)
                }
            }
        }
    }
    
    /// 重载数据
    func reloadData() {
        selectedIndex = max(0, min(selectedIndex, items.count - 1))
        if selectedIndex < items.count {
            let item = items[selectedIndex]
            item.isSelected = true
            item.titleColor = configuration.item.selected.titleColor
            item.titleScale = max(1.0, configuration.item.selected.titleScale)
            item.borderColor = configuration.item.selected.borderColor
            item.backgroundColor = configuration.item.selected.backgroundColor
            item.backgroundImage = configuration.item.selected.backgroundImage
            indicatorView.frame = item.indicatorFrame
        } else {
            indicatorView.frame = .init(origin: .init(x: 0.0, y: collectionView.frame.height), size: .zero)
        }
        collectionView.performBatchUpdates { [weak self] in
            guard let self = self else { return }
            self.collectionView.reloadData()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            if self.selectedIndex < self.items.count {
                self.scrollToItem(at: self.selectedIndex, to: self.configuration.navigation.scrollPosition, animated: false)
            }
        }
    }
}

// MARK: - Title
extension MNSegmentedNavigationView {
    
    /// 替换标题
    /// - Parameters:
    ///   - title: 新的标题
    ///   - index: 子页面索引
    func replaceTitle(_ title: String, at index: Int) {
        guard isItemLoaded else { return }
        guard index < items.count else { return }
        let titles = items.compactMap { $0.title }
        switch configuration.orientation {
        case .horizontal:
            reloadHorizontalItems(titles)
        default:
            reloadVerticalItems(titles)
        }
        reloadData()
    }
    
    /// 获取分割项标题
    /// - Parameter index: 子页面索引
    /// - Returns: 获取到的标题
    func title(for index: Int) -> String? {
        guard isItemLoaded else { return nil }
        guard index < items.count else { return nil }
        return items[index].title
    }
}

// MARK: - Badge
extension MNSegmentedNavigationView {
    
    /// 获取角标
    /// - Parameter index: 页码
    /// - Returns: 角标
    func badge(for index: Int) -> Any? {
        guard isItemLoaded else { return nil }
        guard index < items.count else { return nil }
        return items[index].badge
    }
    
    /// 设置角标
    /// - Parameters:
    ///   - badge: 角标
    ///   - index: 页码
    func setBadge(_ badge: Any?, for index: Int) {
        guard isItemLoaded else { return }
        guard index < items.count else { return }
        items[index].badge = badge
        if let indexPath = collectionView.indexPathsForVisibleItems.first(where: { $0.item == index }) {
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    /// 删除所有角标
    func removeAllBadge() {
        guard isItemLoaded else { return }
        items.forEach { $0.badge = nil }
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
    }
}

// MARK: - Divider
extension MNSegmentedNavigationView {
    
    /// 替换分割线约束
    /// - Parameters:
    ///   - constraint: 分割线约束
    ///   - index: 子页面索引
    public func replaceDividerConstraint(_ constraint: MNSegmentedConfiguration.Constraint, at index: Int) {
        guard isItemLoaded else { return }
        guard index < items.count else { return }
        items[index].dividerConstraint = constraint
        if let indexPath = collectionView.indexPathsForVisibleItems.first(where: { $0.item == index }) {
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MNSegmentedNavigationView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? MNSegmentedNavigationCellConvertible else { return }
        let item = items[indexPath.item]
        cell.update?(item: item, at: indexPath.item, orientation: configuration.orientation)
        if let delegate = delegate {
            delegate.navigationView?(self, willDisplay: cell, item: item, at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isSeletionEnabled else { return }
        guard indexPath.item < items.count else { return }
        let currentSelectedIndex = selectedIndex
        if indexPath.item == currentSelectedIndex { return }
        guard let delegate = delegate else { return }
        guard delegate.navigationView(self, shouldSelectItemAt: indexPath.item) else { return }
        setSelectedItem(at: indexPath.item, animated: true)
        delegate.navigationView(self, didSelectItemAt: indexPath.item, direction: indexPath.item >= currentSelectedIndex ? .forward : .reverse)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MNSegmentedNavigationView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        items[indexPath.item].frame.size
    }
}

// MARK: - MNSegmentedSubpageScrolling
extension MNSegmentedNavigationView: MNSegmentedSubpageScrolling {
    
    func pageViewControllerWillBeginDragging(_ pageViewController: UIPageViewController) {
        targetIndex = selectedIndex
        lastSelectedIndex = selectedIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didScroll ratio: CGFloat) {
        let floorIndex = Int(floor(ratio))
        if floorIndex < selectedIndex {
            targetIndex = floorIndex
        } else {
            targetIndex = Int(ceil(ratio))
        }
        let targetIndexPath = IndexPath(item: targetIndex, section: 0)
        let currentIndexPath = IndexPath(item: selectedIndex, section: 0)
        var progress: CGFloat = ratio.truncatingRemainder(dividingBy: 1.0)
        if targetIndex < selectedIndex {
            progress = 1.0 - progress
        }
        let targetItem = items[targetIndex]
        let currentItem = items[selectedIndex]
        var indicatorFrame: CGRect = currentItem.indicatorFrame
        switch configuration.indicator.animationType {
        case .move:
            // 移动
            if configuration.orientation == .horizontal {
                let x = (targetItem.indicatorFrame.minX - indicatorFrame.minX)*progress + indicatorFrame.minX
                let width = (targetItem.indicatorFrame.width - indicatorFrame.width)*progress + indicatorFrame.width
                indicatorFrame.origin.x = x
                indicatorFrame.size.width = width
            } else {
                let y = (targetItem.indicatorFrame.minY - indicatorFrame.minY)*progress + indicatorFrame.minY
                let height = (targetItem.indicatorFrame.height - indicatorFrame.height)*progress + indicatorFrame.height
                indicatorFrame.origin.y = y
                indicatorFrame.size.height = height
            }
        case .stretch:
            // 拉伸
            if targetIndex >= selectedIndex {
                // 左/上滑动
                if progress <= 0.5 {
                    // 未超过一半进度
                    if configuration.orientation == .horizontal {
                        indicatorFrame.size.width = progress/0.5*(targetItem.indicatorFrame.maxX - currentItem.indicatorFrame.maxX) + currentItem.indicatorFrame.width
                    } else {
                        indicatorFrame.size.height = progress/0.5*(targetItem.indicatorFrame.maxY - currentItem.indicatorFrame.maxY) + currentItem.indicatorFrame.height
                    }
                    // 修改标题缩放
                    if configuration.item.selected.titleScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedNavigationCellConvertible {
                            cell.updateTitleScale?(configuration.item.selected.titleScale)
                        }
                        if let cell = collectionView.cellForItem(at: targetIndexPath) as? MNSegmentedNavigationCellConvertible {
                            cell.updateTitleScale?(1.0)
                        }
                    }
                } else {
                    // 超过一半
                    if configuration.orientation == .horizontal {
                        indicatorFrame.size.width = (1.0 - progress)/0.5*(targetItem.indicatorFrame.minX - currentItem.indicatorFrame.minX) + targetItem.indicatorFrame.width
                        indicatorFrame.origin.x = targetItem.indicatorFrame.maxX - indicatorFrame.width
                    } else {
                        indicatorFrame.size.height = (1.0 - progress)/0.5*(targetItem.indicatorFrame.minY - currentItem.indicatorFrame.minY) + targetItem.indicatorFrame.height
                        indicatorFrame.origin.y = targetItem.indicatorFrame.maxY - indicatorFrame.height
                    }
                    // 修改标题缩放
                    if configuration.item.selected.titleScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedNavigationCellConvertible {
                            let transformScale = (1.0 - progress)/0.5*(configuration.item.selected.titleScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                        if let cell = collectionView.cellForItem(at: targetIndexPath) as? MNSegmentedNavigationCellConvertible {
                            let transformScale = (progress - 0.5)/0.5*(configuration.item.selected.titleScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                    }
                }
            } else {
                // 右/下滑动
                if progress <= 0.5 {
                    // 修改标记线位置
                    if configuration.orientation == .horizontal {
                        indicatorFrame.size.width = progress/0.5*(currentItem.indicatorFrame.minX - targetItem.indicatorFrame.minX) + currentItem.indicatorFrame.width
                        indicatorFrame.origin.x = currentItem.indicatorFrame.maxX - indicatorFrame.width
                    } else {
                        indicatorFrame.size.height = progress/0.5*(currentItem.indicatorFrame.minY - targetItem.indicatorFrame.minY) + currentItem.indicatorFrame.height
                        indicatorFrame.origin.y = currentItem.indicatorFrame.maxY - indicatorFrame.height
                    }
                    // 修改标题缩放
                    if configuration.item.selected.titleScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedNavigationCellConvertible {
                            cell.updateTitleScale?(configuration.item.selected.titleScale)
                        }
                        if let cell = collectionView.cellForItem(at: targetIndexPath) as? MNSegmentedNavigationCellConvertible {
                            cell.updateTitleScale?(1.0)
                        }
                    }
                } else {
                    // 修改标记线位置
                    if configuration.orientation == .horizontal {
                        indicatorFrame.size.width = (1.0 - progress)/0.5*(currentItem.indicatorFrame.maxX - targetItem.indicatorFrame.maxX) + targetItem.indicatorFrame.width
                        indicatorFrame.origin.x = targetItem.indicatorFrame.minX
                    } else {
                        indicatorFrame.size.height = (1.0 - progress)/0.5*(currentItem.indicatorFrame.maxY - targetItem.indicatorFrame.maxY) + targetItem.indicatorFrame.height
                        indicatorFrame.origin.y = targetItem.indicatorFrame.minY
                    }
                    // 修改标题缩放
                    if configuration.item.selected.titleScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedNavigationCellConvertible {
                            let transformScale = (1.0 - progress)/0.5*(configuration.item.selected.titleScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                        if let cell = collectionView.cellForItem(at: targetIndexPath) as? MNSegmentedNavigationCellConvertible {
                            let transformScale = (progress - 0.5)/0.5*(configuration.item.selected.titleScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                    }
                }
            }
        }
        indicatorView.frame = indicatorFrame
        // 修改标题颜色
        let roundSelectedIndex: Int = Int(round(ratio))
        if roundSelectedIndex != lastSelectedIndex {
            let lastIndexPath = IndexPath(item: lastSelectedIndex, section: 0)
            let roundIndexPath = IndexPath(item: roundSelectedIndex, section: 0)
            lastSelectedIndex = roundSelectedIndex
            if let lastSelectedCell = collectionView.cellForItem(at: lastIndexPath) as? MNSegmentedNavigationCellConvertible {
                lastSelectedCell.updateTitleColor?(configuration.item.normal.titleColor)
                lastSelectedCell.updateBorderColor?(configuration.item.normal.borderColor)
                lastSelectedCell.updateBackgroundColor?(configuration.item.normal.backgroundColor)
                lastSelectedCell.updateBackgroundImage?(configuration.item.normal.backgroundImage)
                lastSelectedCell.updateCell?(selected: false, at: lastIndexPath.item)
            }
            if let roundSelectedCell = collectionView.cellForItem(at: roundIndexPath) as? MNSegmentedNavigationCellConvertible {
                roundSelectedCell.updateTitleColor?(configuration.item.selected.titleColor)
                roundSelectedCell.updateBorderColor?(configuration.item.selected.borderColor)
                roundSelectedCell.updateBackgroundColor?(configuration.item.selected.backgroundColor)
                roundSelectedCell.updateBackgroundImage?(configuration.item.selected.backgroundImage)
                roundSelectedCell.updateCell?(selected: true, at: roundIndexPath.item)
            }
        }
    }
    
    func pageViewController(_ viewController: UIPageViewController, willScrollToSubpageAt index: Int) {
        let currentIndex = selectedIndex
        selectedIndex = index
        let targetItem = items[index]
        let currentItem = items[currentIndex]
        let targetIndexPath: IndexPath = IndexPath(item: index, section: 0)
        let currentIndexPath: IndexPath = IndexPath(item: currentIndex, section: 0)
        currentItem.isSelected = false
        currentItem.titleScale = 1.0
        currentItem.titleColor = configuration.item.normal.titleColor
        currentItem.borderColor = configuration.item.normal.borderColor
        currentItem.backgroundColor = configuration.item.normal.backgroundColor
        currentItem.backgroundImage = configuration.item.normal.backgroundImage
        targetItem.isSelected = true
        targetItem.titleScale = max(1.0, configuration.item.selected.titleScale)
        targetItem.titleColor = configuration.item.selected.titleColor
        targetItem.borderColor = configuration.item.selected.borderColor
        targetItem.backgroundColor = configuration.item.selected.backgroundColor
        targetItem.backgroundImage = configuration.item.selected.backgroundImage
        let currentItemCell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedNavigationCellConvertible
        currentItemCell?.updateTitleColor?(configuration.item.normal.titleColor)
        currentItemCell?.updateBorderColor?(configuration.item.normal.borderColor)
        currentItemCell?.updateBackgroundColor?(configuration.item.normal.backgroundColor)
        currentItemCell?.updateBackgroundImage?(configuration.item.normal.backgroundImage)
        currentItemCell?.updateCell?(selected: false, at: currentIndexPath.item)
        let targetItemCell = collectionView.cellForItem(at: targetIndexPath) as? MNSegmentedNavigationCellConvertible
        targetItemCell?.updateTitleColor?(configuration.item.selected.titleColor)
        targetItemCell?.updateBorderColor?(configuration.item.selected.borderColor)
        targetItemCell?.updateBackgroundColor?(configuration.item.selected.backgroundColor)
        targetItemCell?.updateBackgroundImage?(configuration.item.selected.backgroundImage)
        targetItemCell?.updateCell?(selected: true, at: targetIndexPath.item)
        indicatorView.layer.removeAllAnimations()
        collectionView.isUserInteractionEnabled = false
        UIView.animate(withDuration: configuration.indicator.animationDuration, delay: 0.01, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            if let cell = currentItemCell {
                cell.updateTitleScale?(currentItem.titleScale)
            }
            if let cell = targetItemCell {
                cell.updateTitleScale?(targetItem.titleScale)
            }
            if self.lastSelectedIndex == index {
                // 滑动中已导致索引即将变化
                self.indicatorView.frame = targetItem.indicatorFrame
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.isUserInteractionEnabled = true
            self.scrollToItem(at: index, to: self.configuration.navigation.scrollPosition, animated: true)
        }
        if lastSelectedIndex != index {
            // 标记线动画
            let duration = configuration.indicator.animationType == .stretch ? configuration.indicator.animationDuration/2.0 : configuration.indicator.animationDuration
            let animations: ()->Void = { [weak self] in
                guard let self = self else { return }
                guard self.configuration.indicator.animationType == .stretch else { return }
                var indicatorFrame = self.indicatorView.frame
                if index > currentIndex {
                    if self.configuration.orientation == .horizontal {
                        indicatorFrame.size.width = targetItem.indicatorFrame.maxX - indicatorFrame.minX
                    } else {
                        indicatorFrame.size.height = targetItem.indicatorFrame.maxY - indicatorFrame.minY
                    }
                } else {
                    if self.configuration.orientation == .horizontal {
                        indicatorFrame.size.width = indicatorFrame.maxX - targetItem.indicatorFrame.minX
                        indicatorFrame.origin.x = targetItem.indicatorFrame.minX
                    } else {
                        indicatorFrame.size.height = indicatorFrame.maxY - targetItem.indicatorFrame.minY
                        indicatorFrame.origin.y = targetItem.indicatorFrame.minY
                    }
                }
                self.indicatorView.frame = indicatorFrame
            }
            UIView.animate(withDuration: configuration.indicator.animationType == .stretch ? duration : 0.0, animations: animations) { [weak self] _ in
                UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut) {
                    guard let self = self else { return }
                    self.indicatorView.frame = targetItem.indicatorFrame
                }
            }
        }
    }
}
