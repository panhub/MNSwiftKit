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
    @objc optional func dimensionForSegmentedAt(_ index: Int) -> CGFloat
}

@objc protocol MNSegmentedViewDelegate: AnyObject {
    
    /// 重载分割项告知
    /// - Parameter segmentedView: 分割视图
    func segmentedViewDidReloadItems(_ segmentedView: MNSegmentedView)
    
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
    
    /// 表格重用标识符
    private var reuseIdentifier: String = "com.mn.segmented.cell.identifier"
    
    /// 当前选中索引
    private(set) var selectedIndex: Int = 0
    
    /// 上一次选中索引
    private(set) var lastSelectedIndex: Int = 0
    
    /// 指示视图
    var indicatorView = UIImageView()
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
    /// 集合视图
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    
    init(configuration: MNSegmentedConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        backgroundColor = configuration.view.backgroundColor
        
        leadingSeparator.backgroundColor = configuration.view.separatorColor
        leadingSeparator.isHidden = configuration.view.separatorStyle.contains(.leading) == false
        leadingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingSeparator)
        
        trailingSeparator.backgroundColor = configuration.view.separatorColor
        trailingSeparator.isHidden = configuration.view.separatorStyle.contains(.trailing) == false
        trailingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trailingSeparator)
        
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
        
        switch configuration.orientation {
        case .horizontal:
            //
            NSLayoutConstraint.activate([
                leadingSeparator.topAnchor.constraint(equalTo: topAnchor),
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: configuration.view.separatorInset.left),
                leadingSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -configuration.view.separatorInset.right),
                leadingSeparator.heightAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                trailingSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: configuration.view.separatorInset.left),
                trailingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
                trailingSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -configuration.view.separatorInset.right),
                trailingSeparator.heightAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: leadingSeparator.isHidden ? topAnchor : leadingSeparator.bottomAnchor),
                collectionView.leftAnchor.constraint(equalTo: leftAnchor),
                collectionView.bottomAnchor.constraint(equalTo: trailingSeparator.isHidden ? bottomAnchor : trailingSeparator.topAnchor),
                collectionView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        default:
            //
            NSLayoutConstraint.activate([
                leadingSeparator.topAnchor.constraint(equalTo: topAnchor, constant: configuration.view.separatorInset.top),
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
                leadingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -configuration.view.separatorInset.bottom),
                leadingSeparator.widthAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                trailingSeparator.topAnchor.constraint(equalTo: topAnchor, constant: configuration.view.separatorInset.top),
                trailingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -configuration.view.separatorInset.bottom),
                trailingSeparator.rightAnchor.constraint(equalTo: rightAnchor),
                trailingSeparator.widthAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.leftAnchor.constraint(equalTo: leadingSeparator.isHidden ? leftAnchor : leadingSeparator.rightAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                collectionView.rightAnchor.constraint(equalTo: trailingSeparator.isHidden ? rightAnchor : trailingSeparator.leftAnchor)
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
        
        if bounds.isNull || bounds.isEmpty { return }
        guard mn.isFirstAssociated else { return }
        if let dataSource = dataSource, let index = dataSource.preferredPresentationSegmentedIndex {
            selectedIndex = index
        } else {
            selectedIndex = 0
        }
        reloadBackgroundView()
        reloadAccessoryView()
        reloadItems()
        if let delegate = delegate {
            delegate.segmentedViewDidReloadItems(self)
        }
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
        reloadData()
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
            if let dataSource = dataSource, let width = dataSource.dimensionForSegmentedAt?(index), width > 0.0 {
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
                switch configuration.view.layoutAdjustmentBehavior {
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
            if let dataSource = dataSource, let height = dataSource.dimensionForSegmentedAt?(index), height > 0.0 {
                item.frame.size.height = height
            }
            items.append(item)
            y += (itemHeight + interitemSpacing)
        }
        if let first = items.first, let last = items.last {
            let height = last.frame.maxY - first.frame.minY
            let deviation = contentSize.height - height
            if deviation > 0.0 {
                // 内容不够
                switch configuration.view.layoutAdjustmentBehavior {
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
                        // 全部补充至右侧
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
                // 与item同宽
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
            item.transformScale = max(1.0, configuration.item.selected.titleScale)
            item.borderColor = configuration.item.selected.borderColor
            item.borderWidth = configuration.item.selected.borderWidth
            item.backgroundColor = configuration.item.selected.backgroundColor
            item.backgroundImage = configuration.item.selected.backgroundImage
            indicatorView.frame = item.indicatorFrame
        } else {
            indicatorView.frame = .init(origin: .init(x: 0.0, y: collectionView.frame.height), size: .zero)
        }
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
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
        let pageIndex = indexPath.item
        let lastSelectedIndex = selectedIndex
        guard pageIndex < items.count else { return }
        if pageIndex == lastSelectedIndex { return }
        guard let delegate = delegate else { return }
        guard delegate.segmentedView(self, shouldSelectItemAt: indexPath.item) else { return }
        //setCurrentPage(at: indexPath.item, animated: true)
        delegate.segmentedView(self, didSelectItemAt: pageIndex, direction: pageIndex >= lastSelectedIndex ? .forward : .reverse)
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didScroll ratio: CGFloat) {
        
    }
    
    func pageViewController(_ viewController: UIPageViewController, willScrollToPageAt index: Int) {
        
    }
    
    func pageViewController(_ viewController: UIPageViewController, didScrollToPageAt index: Int) {
        
    }
    
    func pageViewControllerWillBeginDragging(_ pageViewController: UIPageViewController) {
        
    }
}

