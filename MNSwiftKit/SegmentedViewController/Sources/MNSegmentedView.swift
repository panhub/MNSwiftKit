//
//  MNSegmentedView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit

@objc public protocol MNSegmentedViewDataSource: AnyObject {
    
    /// 子界面标题集合
    var preferredSegmentedTitles: [String] { get }
    
    /// 初始子界面索引
    @objc optional var preferredPresentationSegmentedIndex: Int { get }
    
    /// 分割器背景视图
    @objc optional var preferredSegmentedBackgroundView: UIView? { get }
    
    /// 前/左附属视图
    @objc optional var preferredSegmentedLeadingAccessoryView: UIView? { get }
    
    /// 后/右附属视图
    @objc optional var preferredSegmentedTrailingAccessoryView: UIView? { get }
    
    /// 指定分割项尺寸 依据布局方向取宽高
    /// - Parameter index: 索引
    /// - Returns: 分割项尺寸
    @objc optional func dimensionForSegmentedItemAt(_ index: Int) -> CGFloat
}

@objc protocol MNSegmentedViewDelegate: AnyObject {
    
    /// 重载分割项告知
    /// - Parameter segmentedView: 分割视图
    func segmentedViewDidReloadItem(_ segmentedView: MNSegmentedView)
    
    /// 询问是否响应点击事件
    /// - Parameters:
    ///   - segmentedView: 分割视图
    ///   - index: 点击索引
    /// - Returns: 是否允许选择
    func segmentedView(_ segmentedView: MNSegmentedView, shouldSelectItemAt index: Int) -> Bool
    
    /// 分割项选择告知
    /// - Parameters:
    ///   - segmentedView: 分割视图
    ///   - index: 点击的索引
    ///   - direction: 点击的索引是大于还是小于原索引
    func segmentedView(_ segmentedView: MNSegmentedView, didSelectItemAt index: Int, direction: UIPageViewController.NavigationDirection)
    
    /// 即将显示分割项
    /// - Parameters:
    ///   - segmentedView: 分割视图
    ///   - cell: 分割项
    ///   - item: 分割项模型
    ///   - index: 索引
    @objc optional func segmentedView(_ segmentedView: MNSegmentedView, willDisplay cell: MNSegmentedCellConvertible, item: MNSegmentedItem, at index: Int)
}

class MNSegmentedView: UIView {
    /// 配置
    private let configuration: MNSegmentedConfiguration
    /// 外界指定是否允许点击
    var isSelectionEnabled: Bool = true
    /// 事件代理
    weak var delegate: MNSegmentedViewDelegate?
    /// 数据源
    weak var dataSource: MNSegmentedViewDataSource?
    /// 分各项数组
    private(set) var items: [MNSegmentedItem] = []
    /// 集合视图的背景视图(放置指示视图)
    private var collectionBackgroundView: UIView!
    /// 当前选中索引
    private(set) var selectedIndex: Int = 0
    /// 上一次选中索引
    private(set) var lastSelectedIndex: Int = 0
    /// 猜测将要选择的索引
    private var willSelectIndex: Int = 0
    /// 指示视图
    private var indicatorView = UIImageView()
    /// 前/左方分割线
    private let leadingSeparator = UIView()
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
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    /// 构造分段导航视图
    /// - Parameters:
    ///   - configuration: 配置信息
    ///   - headerView: 公共头视图
    init(configuration: MNSegmentedConfiguration, headerView: UIView?) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        backgroundColor = configuration.view.backgroundColor
        
        leadingSeparator.backgroundColor = configuration.separator.backgroundColor
        leadingSeparator.isHidden = configuration.separator.style.contains(.leading) == false
        leadingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingSeparator)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = configuration.view.contentInset
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
        collectionView.register(MNSegmentedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
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
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: configuration.separator.inset.left),
                leadingSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -configuration.separator.inset.right),
                leadingSeparator.heightAnchor.constraint(equalToConstant: configuration.separator.dimension)
            ])
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: configuration.separator.style.contains(.leading) ? leadingSeparator.bottomAnchor : leadingSeparator.topAnchor),
                collectionView.leftAnchor.constraint(equalTo: leftAnchor),
                collectionView.rightAnchor.constraint(equalTo: rightAnchor),
                collectionView.heightAnchor.constraint(equalToConstant: configuration.view.dimension)
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
                leadingSeparator.topAnchor.constraint(equalTo: topAnchor, constant: configuration.separator.inset.top),
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
                leadingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -configuration.separator.inset.bottom),
                leadingSeparator.widthAnchor.constraint(equalToConstant: configuration.separator.dimension)
            ])
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.leftAnchor.constraint(equalTo: configuration.separator.style.contains(.leading) ? leadingSeparator.rightAnchor : leadingSeparator.leftAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                collectionView.widthAnchor.constraint(equalToConstant: configuration.view.dimension)
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
        guard mn.isFirstAssociated else { return }
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
extension MNSegmentedView {
    
    /// 注册表格
    /// - Parameters:
    ///   - cellClass: 表格类
    ///   - reuseIdentifier: 表格重用标识符
    func register<T>(_ cellClass: T.Type, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) where T: MNSegmentedCellConvertible {
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
extension MNSegmentedView {
    
    /// 移动当前选中项到指定位置
    /// - Parameters:
    ///   - index: 选中的item索引
    ///   - position: 目标位置
    ///   - animated: 是否动态
    private func scrollToItem(at index: Int, to position: MNSegmentedScrollPosition, animated: Bool) {
        var scrollPosition: UICollectionView.ScrollPosition = .centeredHorizontally
        switch position {
        case .leading:
            scrollPosition = configuration.orientation == .horizontal ? .left : .top
        case .trailing:
            scrollPosition = configuration.orientation == .horizontal ? .right : .bottom
        case .center:
            scrollPosition = configuration.orientation == .horizontal ? .centeredHorizontally : .centeredVertically
        default: return
        }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: scrollPosition, animated: animated)
    }
    
    /// 指定选择的item索引
    /// - Parameters:
    ///   - index: 索引值
    ///   - animated: 是否动态
    private func setSelectedItem(at index: Int, animated: Bool) {
        let targetItem: MNSegmentedItem? = index < items.count ? items[index] : nil
        let currentItem: MNSegmentedItem? = selectedIndex < items.count ? items[selectedIndex] : nil
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
        let currentItemCell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedCellConvertible
        currentItemCell?.updateTitleColor?(configuration.item.normal.titleColor)
        currentItemCell?.updateBorderColor?(configuration.item.normal.borderColor)
        currentItemCell?.updateBackgroundImage?(configuration.item.normal.backgroundImage)
        currentItemCell?.updateCell?(selected: false, at: currentIndexPath.item)
        let targetItemCell = collectionView.cellForItem(at: targetIndexPath) as? MNSegmentedCellConvertible
        targetItemCell?.updateTitleColor?(configuration.item.selected.titleColor)
        targetItemCell?.updateBorderColor?(configuration.item.selected.borderColor)
        targetItemCell?.updateBackgroundImage?(configuration.item.selected.backgroundImage)
        targetItemCell?.updateCell?(selected: true, at: targetIndexPath.item)
        collectionView.isUserInteractionEnabled = false
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
                self.scrollToItem(at: index, to: configuration.view.scrollPosition, animated: animated)
            }
        }
    }
}

// MARK: - Reload
extension MNSegmentedView {
    
    /// 重载子视图
    func reloadSubviews() {
        reloadBackgroundView()
        reloadAccessoryView()
        reloadItems()
        if let dataSource = dataSource, let index = dataSource.preferredPresentationSegmentedIndex {
            selectedIndex = index
        } else {
            selectedIndex = 0
        }
        reloadData()
        if let delegate = delegate {
            delegate.segmentedViewDidReloadItem(self)
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
        let contentInset = configuration.view.contentInset
        if let accessoryView = leadingAccessoryView {
            accessoryView.removeFromSuperview()
            leadingAccessoryView = nil
        }
        if let dataSource = dataSource, let accessoryView = dataSource.preferredSegmentedLeadingAccessoryView, let accessoryView = accessoryView {
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
        if let dataSource = dataSource, let accessoryView = dataSource.preferredSegmentedTrailingAccessoryView, let accessoryView = accessoryView {
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
    
    /// 重载所有控制项
    /// - Parameter titles: 使用标题
    func reloadItems() {
        var titles: [String] = []
        if let dataSource = dataSource {
            titles.append(contentsOf: dataSource.preferredSegmentedTitles)
        }
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        switch layout.scrollDirection {
        case .horizontal:
            reloadHorizontalItems(titles)
        default:
            reloadVerticalItems(titles)
        }
    }
    
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
        // 缩放因数
        let titleScale: CGFloat = max(configuration.item.selected.titleScale, 1.0)
        // 标题字体
        let titleFont: UIFont = configuration.item.normal.titleFont
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
            if let dataSource = dataSource, let width = dataSource.dimensionForSegmentedItemAt?(index), width > 0.0 {
                itemWidth = width
            }
            let item = MNSegmentedItem()
            item.title = title
            item.titleSize = titleSize
            item.titleFont = titleFont
            item.titleColor = configuration.item.normal.titleColor
            item.borderColor = configuration.item.normal.borderColor
            item.borderWidth = configuration.item.normal.borderWidth
            item.borderRadius = configuration.item.normal.cornerRadius
            item.dividerSize = configuration.item.normal.dividerSize
            item.dividerColor = configuration.item.normal.dividerColor
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
                switch configuration.view.adjustmentBehavior {
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
            switch configuration.indicator.size {
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
        let titleFont: UIFont = configuration.item.normal.titleFont
        // 起始
        var y: CGFloat = sectionInset.top
        //
        items.removeAll()
        for (index, title) in titles.enumerated() {
            var titleSize: CGSize = title.size(withAttributes: [.font:titleFont])
            titleSize.width = ceil(titleSize.width)
            titleSize.height = ceil(titleSize.height)
            let item = MNSegmentedItem()
            item.title = title
            item.titleSize = titleSize
            item.titleFont = titleFont
            item.titleColor = configuration.item.normal.titleColor
            item.borderColor = configuration.item.normal.borderColor
            item.borderWidth = configuration.item.normal.borderWidth
            item.borderRadius = configuration.item.normal.cornerRadius
            item.dividerSize = configuration.item.normal.dividerSize
            item.dividerColor = configuration.item.normal.dividerColor
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
            if let dataSource = dataSource, let height = dataSource.dimensionForSegmentedItemAt?(index), height > 0.0 {
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
                switch configuration.view.adjustmentBehavior {
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
            switch configuration.indicator.size {
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
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        scrollToItem(at: selectedIndex, to: .leading, animated: false)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MNSegmentedView: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        
        guard let cell = cell as? MNSegmentedCellConvertible else { return }
        let item = items[indexPath.item]
        cell.update?(item: item, at: indexPath.item, orientation: configuration.orientation)
        if let delegate = delegate {
            delegate.segmentedView?(self, willDisplay: cell, item: item, at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard isSelectionEnabled else { return }
        let lastSelectedIndex = selectedIndex
        guard indexPath.item < items.count else { return }
        if indexPath.item == lastSelectedIndex { return }
        guard let delegate = delegate else { return }
        guard delegate.segmentedView(self, shouldSelectItemAt: indexPath.item) else { return }
        setSelectedItem(at: indexPath.item, animated: true)
        delegate.segmentedView(self, didSelectItemAt: indexPath.item, direction: indexPath.item >= lastSelectedIndex ? .forward : .reverse)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MNSegmentedView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        items[indexPath.item].frame.size
    }
}

// MARK: - MNSegmentedPageCoordinatorScrollDelegate
extension MNSegmentedView: MNSegmentedPageCoordinatorScrollDelegate {
    
    func pageViewControllerWillBeginDragging(_ pageViewController: UIPageViewController) {
        willSelectIndex = selectedIndex
        lastSelectedIndex = selectedIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didScroll ratio: CGFloat) {
        let floorIndex: Int = Int(floor(ratio))
        if floorIndex < selectedIndex {
            willSelectIndex = floorIndex
        } else {
            willSelectIndex = Int(ceil(ratio))
        }
        let guessIndexPath = IndexPath(item: willSelectIndex, section: 0)
        let currentIndexPath = IndexPath(item: selectedIndex, section: 0)
        var progress: CGFloat = ratio.truncatingRemainder(dividingBy: 1.0)
        if willSelectIndex < selectedIndex {
            progress = 1.0 - progress
        }
        let guessItem = items[willSelectIndex]
        let currentItem = items[selectedIndex]
        var indicatorFrame: CGRect = currentItem.indicatorFrame
        switch configuration.indicator.transitionType {
        case .move:
            // 移动
            if configuration.orientation == .horizontal {
                let x = (guessItem.indicatorFrame.minX - indicatorFrame.minX)*progress + indicatorFrame.minX
                let width = (guessItem.indicatorFrame.width - indicatorFrame.width)*progress + indicatorFrame.width
                indicatorFrame.origin.x = x
                indicatorFrame.size.width = width
            } else {
                let y = (guessItem.indicatorFrame.minY - indicatorFrame.minY)*progress + indicatorFrame.minY
                let height = (guessItem.indicatorFrame.height - indicatorFrame.height)*progress + indicatorFrame.height
                indicatorFrame.origin.y = y
                indicatorFrame.size.height = height
            }
        case .stretch:
            // 拉伸
            if willSelectIndex >= selectedIndex {
                // 左/上滑动
                if progress <= 0.5 {
                    // 未超过一半进度
                    if configuration.orientation == .horizontal {
                        indicatorFrame.size.width = progress/0.5*(guessItem.indicatorFrame.maxX - currentItem.indicatorFrame.maxX) + currentItem.indicatorFrame.width
                    } else {
                        indicatorFrame.size.height = progress/0.5*(guessItem.indicatorFrame.maxY - currentItem.indicatorFrame.maxY) + currentItem.indicatorFrame.height
                    }
                    // 修改标题缩放
                    if configuration.item.selected.titleScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedCellConvertible {
                            cell.updateTitleScale?(configuration.item.selected.titleScale)
                        }
                        if let cell = collectionView.cellForItem(at: guessIndexPath) as? MNSegmentedCellConvertible {
                            cell.updateTitleScale?(1.0)
                        }
                    }
                } else {
                    // 超过一半
                    if configuration.orientation == .horizontal {
                        indicatorFrame.size.width = (1.0 - progress)/0.5*(guessItem.indicatorFrame.minX - currentItem.indicatorFrame.minX) + guessItem.indicatorFrame.width
                        indicatorFrame.origin.x = guessItem.indicatorFrame.maxX - indicatorFrame.width
                    } else {
                        indicatorFrame.size.height = (1.0 - progress)/0.5*(guessItem.indicatorFrame.minY - currentItem.indicatorFrame.minY) + guessItem.indicatorFrame.height
                        indicatorFrame.origin.y = guessItem.indicatorFrame.maxY - indicatorFrame.height
                    }
                    // 修改标题缩放
                    if configuration.item.selected.titleScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedCellConvertible {
                            let transformScale = (1.0 - progress)/0.5*(configuration.item.selected.titleScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                        if let cell = collectionView.cellForItem(at: guessIndexPath) as? MNSegmentedCellConvertible {
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
                        indicatorFrame.size.width = progress/0.5*(currentItem.indicatorFrame.minX - guessItem.indicatorFrame.minX) + currentItem.indicatorFrame.width
                        indicatorFrame.origin.x = currentItem.indicatorFrame.maxX - indicatorFrame.width
                    } else {
                        indicatorFrame.size.height = progress/0.5*(currentItem.indicatorFrame.minY - guessItem.indicatorFrame.minY) + currentItem.indicatorFrame.height
                        indicatorFrame.origin.y = currentItem.indicatorFrame.maxY - indicatorFrame.height
                    }
                    // 修改标题缩放
                    if configuration.item.selected.titleScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedCellConvertible {
                            cell.updateTitleScale?(configuration.item.selected.titleScale)
                        }
                        if let cell = collectionView.cellForItem(at: guessIndexPath) as? MNSegmentedCellConvertible {
                            cell.updateTitleScale?(1.0)
                        }
                    }
                } else {
                    // 修改标记线位置
                    if configuration.orientation == .horizontal {
                        indicatorFrame.size.width = (1.0 - progress)/0.5*(currentItem.indicatorFrame.maxX - guessItem.indicatorFrame.maxX) + guessItem.indicatorFrame.width
                        indicatorFrame.origin.x = guessItem.indicatorFrame.minX
                    } else {
                        indicatorFrame.size.height = (1.0 - progress)/0.5*(currentItem.indicatorFrame.maxY - guessItem.indicatorFrame.maxY) + guessItem.indicatorFrame.height
                        indicatorFrame.origin.y = guessItem.indicatorFrame.minY
                    }
                    // 修改标题缩放
                    if configuration.item.selected.titleScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedCellConvertible {
                            let transformScale = (1.0 - progress)/0.5*(configuration.item.selected.titleScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                        if let cell = collectionView.cellForItem(at: guessIndexPath) as? MNSegmentedCellConvertible {
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
            if let lastSelectedCell = collectionView.cellForItem(at: lastIndexPath) as? MNSegmentedCellConvertible {
                lastSelectedCell.updateTitleColor?(configuration.item.normal.titleColor)
                lastSelectedCell.updateBorderColor?(configuration.item.normal.borderColor)
                lastSelectedCell.updateBackgroundColor?(configuration.item.normal.backgroundColor)
                lastSelectedCell.updateBackgroundImage?(configuration.item.normal.backgroundImage)
                lastSelectedCell.updateCell?(selected: false, at: lastIndexPath.item)
            }
            if let roundSelectedCell = collectionView.cellForItem(at: roundIndexPath) as? MNSegmentedCellConvertible {
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
        let currentItemCell = collectionView.cellForItem(at: currentIndexPath) as? MNSegmentedCellConvertible
        currentItemCell?.updateTitleColor?(configuration.item.normal.titleColor)
        currentItemCell?.updateBorderColor?(configuration.item.normal.borderColor)
        currentItemCell?.updateBackgroundColor?(configuration.item.normal.backgroundColor)
        currentItemCell?.updateBackgroundImage?(configuration.item.normal.backgroundImage)
        currentItemCell?.updateCell?(selected: false, at: currentIndexPath.item)
        let targetItemCell = collectionView.cellForItem(at: targetIndexPath) as? MNSegmentedCellConvertible
        targetItemCell?.updateTitleColor?(configuration.item.selected.titleColor)
        targetItemCell?.updateBorderColor?(configuration.item.selected.borderColor)
        targetItemCell?.updateBackgroundColor?(configuration.item.selected.backgroundColor)
        targetItemCell?.updateBackgroundImage?(configuration.item.selected.backgroundImage)
        targetItemCell?.updateCell?(selected: true, at: targetIndexPath.item)
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
                self.indicatorView.frame = targetItem.indicatorFrame
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.isUserInteractionEnabled = true
            self.scrollToItem(at: index, to: configuration.view.scrollPosition, animated: true)
        }
        if lastSelectedIndex != index {
            // 标记线动画
            let duration = configuration.indicator.transitionType == .stretch ? configuration.indicator.animationDuration/2.0 : configuration.indicator.animationDuration
            let animations: ()->Void = { [weak self] in
                guard let self = self else { return }
                guard self.configuration.indicator.transitionType == .stretch else { return }
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
            UIView.animate(withDuration: configuration.indicator.transitionType == .stretch ? duration : 0.0, animations: animations) { [weak self] _ in
                UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut) {
                    guard let self = self else { return }
                    self.indicatorView.frame = targetItem.indicatorFrame
                }
            }
        }
    }
}

