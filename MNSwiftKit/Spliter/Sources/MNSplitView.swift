//
//  MNSplitView.swift
//  anhe
//
//  Created by 冯盼 on 2022/5/29.
//  页面控制视图

import UIKit
#if canImport(MNSwiftKit_Layout)
import MNSwiftKit_Layout
#endif

@objc public protocol MNSplitViewDataSource: AnyObject {
    
    /// 子界面标题集合
    var preferredPageTitles: [String] { get }
    
    /// 导航前附属视图
    @objc optional var preferredHeadAccessoryView: UIView? { get }
    
    /// 导航后附属视图
    @objc optional var preferredTailAccessoryView: UIView? { get }
    
    /// 指定分割项尺寸 依据布局方向取宽高
    @objc optional func widthForSpliter(at index: Int) -> CGFloat
}

@objc protocol MNSplitViewDelegate: AnyObject {
    
    /// 页面导航询问是否响应点击事件
    /// - Parameter pageIndex: 点击索引
    func splitViewShouldSelectSpliter(at pageIndex: Int) -> Bool
    
    /// 页面导航选择告知
    /// - Parameter pageIndex: 页面索引
    func splitViewDidSelectSpliter(at pageIndex: Int)
    
    /// 导航项即将显示
    /// - Parameters:
    ///   - cell: 导航项
    ///   - spliter: 分割项模型
    ///   - index: 索引
    @objc optional func splitCell(_ cell: MNSplitCellConvertible, willDisplay spliter: MNSpliter, forItemAt index: Int)
}

/// 页面导航视图
class MNSplitView: UIView {
    /// 配置信息
    private let options: MNSplitOptions
    /// 上一次索引
    internal var lastPageIndex: Int = 0
    /// 当前索引
    internal var currentPageIndex: Int = 0
    /// 外界指定是否允许点击
    internal var isSelectionEnabled: Bool = true
    /// 布局方向
    internal var axis: NSLayoutConstraint.Axis = .horizontal
    /// 猜想滑动到的界面索引
    private var guessPageIndex: Int = 0
    /// 前附属视图
    private weak var headAccessoryView: UIView?
    /// 后附属视图
    private weak var tailAccessoryView: UIView?
    /// 表格重用标识符
    private var reuseIdentifier: String = "com.mn.split.cell.identifier"
    /// 顶部分割线
    private let headSeparator: UIView = .init()
    /// 底部分割线
    private let tailSeparator: UIView = .init()
    /// 数据源模型
    private var spliters: [MNSpliter] = []
    /// 背景内容视图
    private var backgroundContentView: UIView!
    /// 事件代理
    internal weak var delegate: MNSplitViewDelegate?
    /// 数据源
    internal weak var dataSource: MNSplitViewDataSource?
    /// 页数
    internal var numberOfPages: Int { spliters.count }
    /// 标记选中
    private lazy var shadow: UIImageView = {
        let shadow = UIImageView()
        shadow.clipsToBounds = true
        shadow.contentMode = .scaleToFill
        return shadow
    }()
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(MNSplitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }()
    
    init(frame: CGRect, options: MNSplitOptions) {
        self.options = options
        super.init(frame: frame)
        
        addSubview(collectionView)
        
        headSeparator.isHidden = true
        addSubview(headSeparator)
        
        tailSeparator.isHidden = true
        addSubview(tailSeparator)
        
        if options.sendShadowToBack {
            // 将标记视图后置与文字之后
            let backgroundView = UIView()
            backgroundView.isUserInteractionEnabled = false
            collectionView.backgroundView = backgroundView
            
            backgroundContentView = UIView(frame: backgroundView.bounds)
            backgroundView.addSubview(backgroundContentView)
            
            backgroundContentView.addSubview(shadow)
            
            collectionView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.old, .new], context: nil)
            collectionView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
        } else {
            collectionView.addSubview(shadow)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let _ = backgroundContentView {
            collectionView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
            collectionView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
    }
    
    override func layoutSubviews() {
        switch axis {
        case .horizontal:
            headSeparator.mn_layout.minY = 0.0
            tailSeparator.mn_layout.maxY = frame.height
        default:
            headSeparator.mn_layout.minX = 0.0
            tailSeparator.mn_layout.maxX = frame.width
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let change = change else { return }
        switch keyPath {
        case #keyPath(UIScrollView.contentSize):
            guard let contentSize = change[.newKey] as? CGSize else { break }
            backgroundContentView.mn_layout.size = contentSize
        case #keyPath(UIScrollView.contentOffset):
            guard let contentOffset = change[.newKey] as? CGPoint else { break }
            switch axis {
            case .horizontal:
                backgroundContentView.mn_layout.minX = -contentOffset.x
            default:
                backgroundContentView.mn_layout.minY = -contentOffset.y
            }
        default:
            // 一般不会走到这里
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - 便捷方法
extension MNSplitView {
    
    /// 分割线样式
    var separatorStyle: MNSplitOptions.SeparatorStyle {
        set {
            switch newValue {
            case .none:
                tailSeparator.isHidden = true
                headSeparator.isHidden = true
            case .head:
                headSeparator.isHidden = false
                tailSeparator.isHidden = true
            case .tail:
                headSeparator.isHidden = true
                tailSeparator.isHidden = false
            case .all:
                tailSeparator.isHidden = false
                headSeparator.isHidden = false
            }
        }
        get {
            if headSeparator.isHidden, tailSeparator.isHidden {
                return .none
            }
            if headSeparator.isHidden == false, tailSeparator.isHidden == false {
                return .all
            }
            if headSeparator.isHidden == false {
                return .head
            }
            return .tail
        }
    }
    
    /// 分割线颜色
    var separatorColor: UIColor! {
        set {
            headSeparator.backgroundColor = newValue
            tailSeparator.backgroundColor = newValue
        }
        get {
            headSeparator.backgroundColor
        }
    }
    
    /// 分割线约束
    var separatorInset: UIEdgeInsets {
        set {
            switch axis {
            case .horizontal:
                headSeparator.mn_layout.height = 0.7
                headSeparator.mn_layout.minX = newValue.left
                headSeparator.mn_layout.width = frame.width - newValue.left - newValue.right
            default:
                headSeparator.mn_layout.width = 0.7
                headSeparator.mn_layout.minY = newValue.top
                headSeparator.mn_layout.height = frame.height - newValue.top - newValue.bottom
            }
            tailSeparator.frame = headSeparator.frame
            setNeedsLayout()
            layoutIfNeeded()
        }
        get {
            switch axis {
            case .horizontal:
                return .init(top: 0.0, left: headSeparator.frame.minX, bottom: 0.0, right: frame.width - headSeparator.frame.maxX)
            default:
                return .init(top: headSeparator.frame.minY, left: 0.0, bottom: frame.height - headSeparator.frame.maxY, right: 0.0)
            }
        }
    }
    
    /// 分割项之间分割线颜色
    var dividerColor: UIColor? {
        set {
            spliters.forEach { $0.dividerColor = newValue }
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
        get {
            guard let spliter = spliters.first else { return nil }
            return spliter.dividerColor
        }
    }
    
    /// 分割项分割线约束
    var dividerInset: UIEdgeInsets {
        set {
            spliters.forEach { $0.dividerInset = newValue }
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
        }
        get {
            guard let spliter = spliters.first else { return .zero }
            return spliter.dividerInset
        }
    }
    
    /// 注册表格
    /// - Parameters:
    ///   - cellClass: 表格类
    ///   - reuseIdentifier: 表格重用标识符
    func register<T>(_ cellClass: T.Type, forSplitterWithReuseIdentifier reuseIdentifier: String) where T: MNSplitCellConvertible {
        self.reuseIdentifier = reuseIdentifier
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func register(_ nib: UINib?, forSplitterWithReuseIdentifier reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    /// 重载附属视图
    func reloadAccessoryView() {
        if let headAccessoryView = headAccessoryView {
            self.headAccessoryView = nil
            headAccessoryView.removeFromSuperview()
        }
        let splitInset = options.splitInset
        if let accessoryView = (dataSource?.preferredHeadAccessoryView ?? nil) {
            switch axis {
            case .horizontal:
                accessoryView.frame = .init(x: 0.0, y: splitInset.top, width: accessoryView.frame.width, height: frame.height - splitInset.top - splitInset.bottom)
            default:
                accessoryView.frame = .init(x: splitInset.left, y: 0.0, width: frame.width - splitInset.left - splitInset.right, height: accessoryView.frame.height)
            }
            insertSubview(accessoryView, aboveSubview: collectionView)
            headAccessoryView = accessoryView
        }
        if let tailAccessoryView = tailAccessoryView {
            self.tailAccessoryView = nil
            tailAccessoryView.removeFromSuperview()
        }
        if let accessoryView = (dataSource?.preferredTailAccessoryView ?? nil) {
            switch axis {
            case .horizontal:
                accessoryView.frame = .init(x: frame.width - accessoryView.frame.width, y: splitInset.top, width: accessoryView.frame.width, height: frame.height - splitInset.top - splitInset.bottom)
            default:
                accessoryView.frame = .init(x: splitInset.left, y: frame.height - accessoryView.frame.height, width: frame.width - splitInset.left - splitInset.right, height: accessoryView.frame.height)
            }
            insertSubview(accessoryView, aboveSubview: collectionView)
            tailAccessoryView = accessoryView
        }
    }
}

// MARK: - Reload
extension MNSplitView {
    
    /// 删除所有控制项
    func removeAllSplitter() {
        lastPageIndex = 0
        guessPageIndex = 0
        currentPageIndex = 0
        shadow.frame = .zero
        spliters.removeAll()
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }
    
    /// 更新视图
    func updateSubviews() {
        backgroundColor = options.backgroundColor
        shadow.image = options.shadowImage
        shadow.backgroundColor = options.shadowColor
        shadow.layer.cornerRadius = options.shadowRadius
        shadow.contentMode = options.shadowContentMode
        collectionView.isUserInteractionEnabled = true
        collectionView.backgroundColor = options.splitColor
        separatorInset = options.separatorInset
        separatorStyle = options.separatorStyle
        separatorColor = options.separatorColor
        reloadSpliters()
        setNeedsLayout()
    }
    
    /// 重载所有控制项
    /// - Parameter titles: 使用标题
    func reloadSpliters(titles: [String]? = nil) {
        let items: [String] = (titles ?? (dataSource?.preferredPageTitles)) ?? []
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var sectionInset = options.splitInset
        switch axis {
        case .horizontal:
            layout.scrollDirection = .horizontal
            sectionInset.left += (headAccessoryView?.frame.width ?? 0.0)
            sectionInset.right += (tailAccessoryView?.frame.width ?? 0.0)
            layout.sectionInset = sectionInset
            layoutHorizontalSplitter(titles: items)
            // 横向滑动在这里处理相邻项间隔
            if let first = spliters.first, spliters.allSatisfy({ $0.frame.width == first.frame.width }) {
                layout.minimumInteritemSpacing = 0.0
                layout.minimumLineSpacing = options.interSpliterSpacing
            } else {
                layout.minimumLineSpacing = 0.0
                layout.minimumInteritemSpacing = options.interSpliterSpacing
            }
        default:
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = options.interSpliterSpacing
            sectionInset.top += (headAccessoryView?.frame.height ?? 0.0)
            sectionInset.bottom += (tailAccessoryView?.frame.height ?? 0.0)
            layout.sectionInset = sectionInset
            layoutVerticalSplitter(titles: items)
        }
        currentPageIndex = max(0, min(currentPageIndex, spliters.count - 1))
        if currentPageIndex < spliters.count {
            let spliter = spliters[currentPageIndex]
            spliter.isSelected = true
            spliter.titleColor = options.highlightedTitleColor
            spliter.transformScale = options.highlightedScale
            spliter.borderColor = options.spliterHighlightedBorderColor
            spliter.backgroundColor = options.spliterHighlightedBackgroundColor
            spliter.backgroundImage = options.spliterHighlightedBackgroundImage
            shadow.frame = spliter.shadowFrame
        } else {
            shadow.frame = .zero
        }
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }
    
    /// 获取横向约束控制项
    /// - Parameter titles: 标题集合
    func layoutHorizontalSplitter(titles: [String]) {
        // 约束信息
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var sectionInset: UIEdgeInsets = layout.sectionInset
        // 起始
        var x: CGFloat = sectionInset.left
        // 标记线宽度
        let shadowWidth: CGFloat = options.shadowSize.width
        // 标记线高度
        let shadowHeight: CGFloat = options.shadowSize.height
        // 标题项高度
        let itemHeight: CGFloat = collectionView.bounds.inset(by: sectionInset).height
        // 内容最大宽度
        let contentWidth: CGFloat = collectionView.bounds.inset(by: sectionInset).width
        // 标记线偏移
        let shadowOffset: UIOffset = options.shadowOffset
        // 标记线纵向起始
        let shadowY: CGFloat = collectionView.frame.height - shadowHeight
        // 标题项追加宽度
        let appendWidth: CGFloat = options.spliterSize.width
        // item间隔
        let interSpliterSpacing: CGFloat = options.interSpliterSpacing
        // 缩放因数
        let highlightedScale: CGFloat = options.highlightedScale
        // 标题字体
        let titleFont: UIFont = options.titleFont
        //
        var spliters = [MNSpliter]()
        for (index, title) in titles.enumerated() {
            var titleSize: CGSize = title.size(withAttributes: [.font:titleFont])
            titleSize.width = ceil(titleSize.width)
            titleSize.height = ceil(titleSize.height)
            var itemWidth: CGFloat = max(titleSize.width + appendWidth, ceil(titleSize.width*highlightedScale))
            if let dataSource = dataSource, let width = dataSource.widthForSpliter?(at: index), width > 0.0 {
                itemWidth = width
            }
            let spliter = MNSpliter()
            spliter.title = title
            spliter.titleSize = titleSize
            spliter.titleFont = options.titleFont
            spliter.titleColor = options.titleColor
            spliter.borderColor = options.spliterBorderColor
            spliter.borderWidth = options.spliterBorderWidth
            spliter.borderRadius = options.spliterBorderRadius
            spliter.dividerInset = options.dividerInset
            spliter.dividerColor = options.dividerColor
            spliter.badgeFont = options.badgeFont
            spliter.badgeInset = options.badgeInset
            spliter.badgeColor = options.badgeColor
            spliter.badgeImage = options.badgeImage
            spliter.badgeOffset = options.badgeOffset
            spliter.badgeTextColor = options.badgeTextColor
            spliter.backgroundColor = options.spliterBackgroundColor
            spliter.backgroundImage = options.spliterBackgroundImage
            spliter.frame = CGRect(x: x, y: sectionInset.top, width: itemWidth, height: itemHeight)
            x += (itemWidth + interSpliterSpacing)
            spliters.append(spliter)
        }
        if let first = spliters.first, let last = spliters.last {
            let width = last.frame.maxX - first.frame.minX
            if contentWidth > width {
                // 内容不够
                switch options.contentMode {
                case .fit:
                    // 居中
                    let append = (contentWidth - width)/2.0
                    sectionInset.left += append
                    sectionInset.right += append
                    layout.sectionInset = sectionInset
                    for spliter in spliters {
                        var rect = spliter.frame
                        rect.origin.x += append
                        spliter.frame = rect
                    }
                case .fill:
                    // 填满
                    let append: CGFloat = ceil((contentWidth - width)/CGFloat(spliters.count))
                    for (idx, spliter) in spliters.enumerated() {
                        var rect = spliter.frame
                        rect.origin.x += (CGFloat(idx)*append)
                        rect.size.width += append
                        spliter.frame = rect
                    }
                default: break
                }
            }
        }
        // 计算标记视图位置
        for spliter in spliters {
            let rect = spliter.frame
            let highlightTitleWidth = ceil(spliter.titleSize.width*highlightedScale)
            switch options.shadowMask {
            case .fit:
                // 与标题同宽
                let margin: CGFloat = (rect.width - highlightTitleWidth)/2.0
                spliter.shadowFrame = CGRect(x: margin + rect.minX + shadowOffset.horizontal, y: shadowY + shadowOffset.vertical, width: highlightTitleWidth, height: shadowHeight)
            case .fill:
                // 与item同宽
                spliter.shadowFrame = CGRect(x: rect.minX + shadowOffset.horizontal, y: shadowY + shadowOffset.vertical, width: rect.width, height: shadowHeight)
            case .constant:
                // 使用指定宽度
                switch options.shadowAlignment {
                case .head:
                    // 居左
                    let margin: CGFloat = (rect.width - highlightTitleWidth)/2.0
                    spliter.shadowFrame = CGRect(x: margin + rect.minX + shadowOffset.horizontal, y: shadowY + shadowOffset.vertical, width: shadowWidth, height: shadowHeight)
                case .center:
                    // 居中
                    spliter.shadowFrame = CGRect(x: rect.midX - shadowWidth/2.0 + shadowOffset.horizontal, y: shadowY + shadowOffset.vertical, width: shadowWidth, height: shadowHeight)
                case .tail:
                    // 居右
                    let margin: CGFloat = (rect.width - highlightTitleWidth)/2.0
                    spliter.shadowFrame = CGRect(x: rect.maxX - margin - shadowWidth + shadowOffset.horizontal, y: shadowY + shadowOffset.vertical, width: shadowWidth, height: shadowHeight)
                }
            }
        }
        self.spliters.removeAll()
        self.spliters.append(contentsOf: spliters)
    }
    
    /// 获取纵向约束控制项
    /// - Parameter titles: 标题集合
    func layoutVerticalSplitter(titles: [String]) {
        // 约束信息
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var sectionInset: UIEdgeInsets = layout.sectionInset
        // 起始
        var y: CGFloat = sectionInset.top
        // 标记线宽度
        let shadowWidth: CGFloat = options.shadowSize.width
        // 标记线高度
        let shadowHeight: CGFloat = options.shadowSize.height
        // 标题项高度
        let itemHeight: CGFloat = options.spliterSize.height
        // 标题项宽度
        let itemWidth: CGFloat = collectionView.bounds.inset(by: sectionInset).width
        // 内容最大高度
        let contentHeight: CGFloat = collectionView.bounds.inset(by: sectionInset).height
        // 标记线偏移
        let shadowOffset: UIOffset = options.shadowOffset
        // 标记选横向起始
        let shadowX: CGFloat = collectionView.frame.width - shadowWidth
        // item间隔
        let interSpliterSpacing: CGFloat = options.interSpliterSpacing
        // 缩放因数
        let highlightedScale: CGFloat = options.highlightedScale
        // 标题字体
        let titleFont: UIFont = options.titleFont
        let spliters: [MNSpliter] = titles.compactMap { title in
            var titleSize: CGSize = title.size(withAttributes: [.font:titleFont])
            titleSize.width = ceil(titleSize.width)
            titleSize.height = ceil(titleSize.height)
            let spliter = MNSpliter()
            spliter.title = title
            spliter.titleSize = titleSize
            spliter.titleFont = options.titleFont
            spliter.titleColor = options.titleColor
            spliter.borderColor = options.spliterBorderColor
            spliter.borderWidth = options.spliterBorderWidth
            spliter.borderRadius = options.spliterBorderRadius
            spliter.dividerInset = options.dividerInset
            spliter.dividerColor = options.dividerColor
            spliter.badgeFont = options.badgeFont
            spliter.badgeInset = options.badgeInset
            spliter.badgeColor = options.badgeColor
            spliter.badgeImage = options.badgeImage
            spliter.badgeOffset = options.badgeOffset
            spliter.badgeTextColor = options.badgeTextColor
            spliter.backgroundColor = options.spliterBackgroundColor
            spliter.backgroundImage = options.spliterBackgroundImage
            spliter.frame = CGRect(x: sectionInset.left, y: y, width: itemWidth, height: itemHeight)
            y += (itemHeight + interSpliterSpacing)
            return spliter
        }
        if let first = spliters.first, let last = spliters.last {
            let height = last.frame.maxY - first.frame.minY
            if contentHeight > height {
                // 内容不够
                switch options.contentMode {
                case .fit:
                    // 居中
                    let append = (contentHeight - height)/2.0
                    sectionInset.top += append
                    sectionInset.bottom += append
                    layout.sectionInset = sectionInset
                    for spliter in spliters {
                        var rect = spliter.frame
                        rect.origin.y += append
                        spliter.frame = rect
                    }
                case .fill:
                    // 填满
                    let append: CGFloat = ceil((contentHeight - height)/CGFloat(spliters.count))
                    for (idx, spliter) in spliters.enumerated() {
                        var rect = spliter.frame
                        rect.origin.y += (CGFloat(idx)*append)
                        rect.size.height += append
                        spliter.frame = rect
                    }
                default: break
                }
            }
        }
        // 计算标记视图位置
        for spliter in spliters {
            let rect = spliter.frame
            let highlightTitleHeight = ceil(spliter.titleSize.height*highlightedScale)
            switch options.shadowMask {
            case .fit:
                // 与标题同高
                let margin: CGFloat = (rect.height - highlightTitleHeight)/2.0
                spliter.shadowFrame = CGRect(x: shadowX + shadowOffset.horizontal, y: margin + rect.minY + shadowOffset.vertical, width: shadowWidth, height: highlightTitleHeight)
            case .fill:
                // 与item同高
                spliter.shadowFrame = CGRect(x: shadowX + shadowOffset.horizontal, y: rect.minY + shadowOffset.vertical, width: shadowWidth, height: rect.height)
            case .constant:
                // 使用指定宽度
                switch options.shadowAlignment {
                case .head:
                    // 居上
                    let margin: CGFloat = (rect.width - highlightTitleHeight)/2.0
                    spliter.shadowFrame = CGRect(x: shadowX + shadowOffset.horizontal, y: margin + rect.minY + shadowOffset.vertical, width: shadowWidth, height: shadowHeight)
                case .center:
                    // 居中
                    spliter.shadowFrame = CGRect(x: shadowX + shadowOffset.horizontal, y: rect.midY - shadowHeight/2.0 + shadowOffset.vertical, width: shadowWidth, height: shadowHeight)
                case .tail:
                    // 居下
                    let margin: CGFloat = (rect.width - highlightTitleHeight)/2.0
                    spliter.shadowFrame = CGRect(x: shadowX + shadowOffset.horizontal, y: rect.maxY - margin - shadowHeight + shadowOffset.vertical, width: shadowWidth, height: shadowHeight)
                }
            }
        }
        self.spliters.removeAll()
        self.spliters.append(contentsOf: spliters)
    }
    
    /// 检测并重载数据
    /// - Parameter titles: 标题集合
    func reloadSplitter(using titles: [String]?) {
        if let titles = titles {
            let items: [String] = spliters.compactMap { $0.title }
            guard items.count > 0 else { return }
            if titles.count < items.count {
                reloadSpliters(titles: titles + items[titles.count..<items.count])
            } else {
                reloadSpliters(titles: titles)
            }
        } else {
            reloadSpliters()
        }
    }
}

// MARK: - Item&Page控制
extension MNSplitView {
    
    /// 获取页面标题
    /// - Parameter index: 指定页码
    /// - Returns: 页面标题
    public func splitterTitle(at index: Int) -> String? {
        guard index < spliters.count else { return nil }
        return spliters[index].title
    }
    
    /// 插入页面控制项
    /// - Parameters:
    ///   - titles: 标题集合
    ///   - index: 开始的索引
    func insertSpliters(_ titles: [String], at index: Int) {
        var items: [String] = spliters.compactMap { $0.title }
        items.insert(contentsOf: titles, at: index)
        reloadSpliters(titles: items)
    }
    
    /// 删除页面控制项
    /// - Parameter index: 指定页码
    func removeSpliter(at index: Int) {
        guard index < spliters.count else { return }
        var items: [String] = spliters.compactMap { $0.title }
        items.remove(at: index)
        reloadSpliters(titles: items)
    }
    
    /// 替换页面标题
    /// - Parameters:
    ///   - pageIndex: 页码
    ///   - title: 标题
    func replaceSpliter(at index: Int, with title: String) {
        guard index < spliters.count else { return }
        var items: [String] = spliters.compactMap { $0.title }
        items.remove(at: index)
        items.insert(title, at: index)
        reloadSpliters(titles: items)
    }
    
    /// 指定选择索引
    /// - Parameters:
    ///   - index: 页面索引
    ///   - animated: 是否动态
    func setCurrentPage(at index: Int, animated: Bool) {
        collectionView.isUserInteractionEnabled = false
        let targetSpliter: MNSpliter? = index < spliters.count ? (spliters[index]) : nil
        let currentSpliter: MNSpliter? = currentPageIndex < spliters.count ? (spliters[currentPageIndex]) : nil
        let targetIndexPath: IndexPath = IndexPath(item: index, section: 0)
        let currentIndexPath: IndexPath = IndexPath(item: currentPageIndex, section: 0)
        currentPageIndex = index
        currentSpliter?.isSelected = false
        currentSpliter?.transformScale = 1.0
        currentSpliter?.titleColor = options.titleColor
        currentSpliter?.borderColor = options.spliterBorderColor
        currentSpliter?.backgroundColor = options.spliterBackgroundColor
        currentSpliter?.backgroundImage = options.spliterBackgroundImage
        targetSpliter?.isSelected = true
        targetSpliter?.transformScale = options.highlightedScale
        targetSpliter?.titleColor = options.highlightedTitleColor
        targetSpliter?.borderColor = options.spliterHighlightedBorderColor
        targetSpliter?.backgroundColor = options.spliterHighlightedBackgroundColor
        targetSpliter?.backgroundImage = options.spliterHighlightedBackgroundImage
        let currentSpliterCell: MNSplitCellConvertible? = collectionView.cellForItem(at: currentIndexPath) as? MNSplitCellConvertible
        currentSpliterCell?.updateTitleColor?(options.titleColor)
        currentSpliterCell?.updateBorderColor?(options.spliterBorderColor)
        currentSpliterCell?.updateBackgroundImage?(options.spliterBackgroundImage)
        currentSpliterCell?.updateItemState?(false, at: currentIndexPath.item)
        let targetSpliterCell: MNSplitCellConvertible? = collectionView.cellForItem(at: targetIndexPath) as? MNSplitCellConvertible
        targetSpliterCell?.updateTitleColor?(options.highlightedTitleColor)
        targetSpliterCell?.updateBorderColor?(options.spliterHighlightedBorderColor)
        targetSpliterCell?.updateBackgroundImage?(options.spliterHighlightedBackgroundImage)
        targetSpliterCell?.updateItemState?(true, at: targetIndexPath.item)
        UIView.animate(withDuration: animated ? options.transitionDuration : .leastNormalMagnitude, delay: 0.0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            if let item = currentSpliter, let cell = currentSpliterCell {
                cell.updateTitleScale?(item.transformScale)
                cell.updateBackgroundColor?(item.backgroundColor)
            }
            if let item = targetSpliter {
                if let cell = targetSpliterCell {
                    cell.updateTitleScale?(item.transformScale)
                    cell.updateBackgroundColor?(item.backgroundColor)
                }
                self.shadow.frame = item.shadowFrame
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.isUserInteractionEnabled = true
            if let _ = targetSpliter {
                self.scrollSpliter(at: index, to: self.options.scrollPosition, animated: animated)
            }
        }
    }
    
    /// 移动当前选中项到指定位置
    /// - Parameters:
    ///   - position: 指定位置
    ///   - animated: 是否显示动画过程
    private func scrollSpliter(at index: Int, to position: MNSplitOptions.ScrollPosition, animated: Bool) {
        var scrollPosition: UICollectionView.ScrollPosition = .centeredHorizontally
        switch position {
        case .head:
            scrollPosition = axis == .horizontal ? .left : .top
        case .tail:
            scrollPosition = axis == .horizontal ? .right : .bottom
        case .center:
            scrollPosition = axis == .horizontal ? .centeredHorizontally : .centeredVertically
        default: return
        }
        collectionView.scrollToItem(at: IndexPath(item: currentPageIndex, section: 0), at: scrollPosition, animated: animated)
    }
}

// MARK: - Badge
extension MNSplitView {
    
    /// 获取页面角标
    /// - Parameter index: 页码
    /// - Returns: 角标
    func badge(for index: Int) -> Any? {
        guard index < spliters.count else { return nil }
        return spliters[index].badge
    }
    
    /// 设置角标
    /// - Parameters:
    ///   - badge: 角标
    ///   - index: 页码
    func setBadge(_ badge: Any?, for index: Int) {
        guard index < spliters.count else { return }
        spliters[index].badge = badge
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    /// 删除所有角标
    func removeAllBadges() {
        guard spliters.count > 0 else { return }
        spliters.forEach { $0.badge = nil }
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }
}

// MARK: - MNSplitPageControllerScrollHandler
extension MNSplitView: MNSplitPageControllerScrollHandler {
    
    func pageViewControllerWillBeginDragging(_ viewController: MNSplitPageController) {
        lastPageIndex = currentPageIndex
        guessPageIndex = currentPageIndex
    }
    
    func pageViewController(_ viewController: MNSplitPageController, didScroll ratio: CGFloat) {
        guard collectionView.isUserInteractionEnabled else { return }
        // 修改标记线位置与标题缩放
        let lessPageIndex: Int = Int(floor(ratio))
        if lessPageIndex < currentPageIndex {
            guessPageIndex = lessPageIndex
        } else {
            guessPageIndex = Int(ceil(ratio))
        }
        let guessIndexPath = IndexPath(item: guessPageIndex, section: 0)
        let currentIndexPath = IndexPath(item: currentPageIndex, section: 0)
        let progress: CGFloat = guessPageIndex < currentPageIndex ? (CGFloat(currentPageIndex) - ratio) : (ratio - CGFloat(currentPageIndex))
        let guessSpliter = spliters[guessPageIndex]
        let currentSpliter = spliters[currentPageIndex]
        var shadowFrame: CGRect = currentSpliter.shadowFrame
        switch options.shadowAnimation {
        case .normal:
            if axis == .horizontal {
                let x = (guessSpliter.shadowFrame.minX - shadowFrame.minX)*progress + shadowFrame.minX
                let width = (guessSpliter.shadowFrame.width - shadowFrame.width)*progress + shadowFrame.width
                shadowFrame.origin.x = x
                shadowFrame.size.width = width
            } else {
                let y = (guessSpliter.shadowFrame.minY - shadowFrame.minY)*progress + shadowFrame.minY
                let height = (guessSpliter.shadowFrame.height - shadowFrame.height)*progress + shadowFrame.height
                shadowFrame.origin.y = y
                shadowFrame.size.height = height
            }
        case .adsorb:
            if guessPageIndex >= currentPageIndex {
                // 左/上滑
                if progress <= 0.5 {
                    // 修改标记线位置
                    if axis == .horizontal {
                        shadowFrame.size.width = progress/0.5*(guessSpliter.shadowFrame.maxX - currentSpliter.shadowFrame.maxX) + currentSpliter.shadowFrame.width
                    } else {
                        shadowFrame.size.height = progress/0.5*(guessSpliter.shadowFrame.maxY - currentSpliter.shadowFrame.maxY) + currentSpliter.shadowFrame.height
                    }
                    // 修改标题缩放
                    if options.highlightedScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSplitCellConvertible {
                            cell.updateTitleScale?(options.highlightedScale)
                        }
                        if let cell = collectionView.cellForItem(at: guessIndexPath) as? MNSplitCellConvertible {
                            cell.updateTitleScale?(1.0)
                        }
                    }
                } else {
                    // 修改标记线位置
                    if axis == .horizontal {
                        shadowFrame.size.width = (1.0 - progress)/0.5*(guessSpliter.shadowFrame.minX - currentSpliter.shadowFrame.minX) + guessSpliter.shadowFrame.width
                        shadowFrame.origin.x = guessSpliter.shadowFrame.maxX - shadowFrame.width
                    } else {
                        shadowFrame.size.height = (1.0 - progress)/0.5*(guessSpliter.shadowFrame.minY - currentSpliter.shadowFrame.minY) + guessSpliter.shadowFrame.height
                        shadowFrame.origin.y = guessSpliter.shadowFrame.maxY - shadowFrame.height
                    }
                    // 修改标题缩放
                    if options.highlightedScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSplitCellConvertible {
                            let transformScale = (1.0 - progress)/0.5*(options.highlightedScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                        if let cell = collectionView.cellForItem(at: guessIndexPath) as? MNSplitCellConvertible {
                            let transformScale = (progress - 0.5)/0.5*(options.highlightedScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                    }
                }
            } else {
                // 右/下滑
                if progress <= 0.5 {
                    // 修改标记线位置
                    if axis == .horizontal {
                        shadowFrame.size.width = progress/0.5*(currentSpliter.shadowFrame.minX - guessSpliter.shadowFrame.minX) + currentSpliter.shadowFrame.width
                        shadowFrame.origin.x = currentSpliter.shadowFrame.maxX - shadowFrame.width
                    } else {
                        shadowFrame.size.height = progress/0.5*(currentSpliter.shadowFrame.minY - guessSpliter.shadowFrame.minY) + currentSpliter.shadowFrame.height
                        shadowFrame.origin.y = currentSpliter.shadowFrame.maxY - shadowFrame.height
                    }
                    // 修改标题缩放
                    if options.highlightedScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSplitCellConvertible {
                            cell.updateTitleScale?(options.highlightedScale)
                        }
                        if let cell = collectionView.cellForItem(at: guessIndexPath) as? MNSplitCellConvertible {
                            cell.updateTitleScale?(1.0)
                        }
                    }
                } else {
                    // 修改标记线位置
                    if axis == .horizontal {
                        shadowFrame.size.width = (1.0 - progress)/0.5*(currentSpliter.shadowFrame.maxX - guessSpliter.shadowFrame.maxX) + guessSpliter.shadowFrame.width
                        shadowFrame.origin.x = guessSpliter.shadowFrame.minX
                    } else {
                        shadowFrame.size.height = (1.0 - progress)/0.5*(currentSpliter.shadowFrame.maxY - guessSpliter.shadowFrame.maxY) + guessSpliter.shadowFrame.height
                        shadowFrame.origin.y = guessSpliter.shadowFrame.minY
                    }
                    // 修改标题缩放
                    if options.highlightedScale > 1.0 {
                        if let cell = collectionView.cellForItem(at: currentIndexPath) as? MNSplitCellConvertible {
                            let transformScale = (1.0 - progress)/0.5*(options.highlightedScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                        if let cell = collectionView.cellForItem(at: guessIndexPath) as? MNSplitCellConvertible {
                            let transformScale = (progress - 0.5)/0.5*(options.highlightedScale - 1.0) + 1.0
                            cell.updateTitleScale?(transformScale)
                        }
                    }
                }
            }
        }
        shadow.frame = shadowFrame
        // 修改标题颜色
        let roundPageIndex: Int = Int(round(ratio))
        if roundPageIndex != lastPageIndex {
            let lastIndexPath = IndexPath(item: lastPageIndex, section: 0)
            let roundIndexPath = IndexPath(item: roundPageIndex, section: 0)
            lastPageIndex = roundPageIndex
            if let lastCell = collectionView.cellForItem(at: lastIndexPath) as? MNSplitCellConvertible {
                lastCell.updateTitleColor?(options.titleColor)
                lastCell.updateBorderColor?(options.spliterBorderColor)
                lastCell.updateBackgroundColor?(options.spliterBackgroundColor)
                lastCell.updateBackgroundImage?(options.spliterBackgroundImage)
                lastCell.updateItemState?(false, at: lastIndexPath.item)
            }
            if let roundCell = collectionView.cellForItem(at: roundIndexPath) as? MNSplitCellConvertible {
                roundCell.updateTitleColor?(options.highlightedTitleColor)
                roundCell.updateBorderColor?(options.spliterHighlightedBorderColor)
                roundCell.updateBackgroundColor?(options.spliterHighlightedBackgroundColor)
                roundCell.updateBackgroundImage?(options.spliterHighlightedBackgroundImage)
                roundCell.updateItemState?(true, at: roundIndexPath.item)
            }
        }
    }
    
    func pageViewControllerDidEndDragging(_ viewController: MNSplitPageController) {
        if lastPageIndex == currentPageIndex { return }
        let lastIndexPath: IndexPath = IndexPath(item: lastPageIndex, section: 0)
        lastPageIndex = currentPageIndex
        guard let cell = collectionView.cellForItem(at: lastIndexPath) as? MNSplitCellConvertible else { return }
        cell.updateTitleScale?(1.0)
        cell.updateTitleColor?(options.titleColor)
        cell.updateBorderColor?(options.spliterBorderColor)
        cell.updateBackgroundColor?(options.spliterBackgroundColor)
        cell.updateBackgroundImage?(options.spliterBackgroundImage)
        cell.updateItemState?(false, at: lastIndexPath.item)
    }
    
    func pageViewController(_ viewController: MNSplitPageController, willScrollTo index: Int) {
        collectionView.isUserInteractionEnabled = false
        let currentPageIndex = currentPageIndex
        self.currentPageIndex = index
        let targetSpliter: MNSpliter = spliters[index]
        let currentSpliter: MNSpliter = spliters[currentPageIndex]
        let targetIndexPath: IndexPath = IndexPath(item: index, section: 0)
        let currentIndexPath: IndexPath = IndexPath(item: currentPageIndex, section: 0)
        currentSpliter.isSelected = false
        currentSpliter.transformScale = 1.0
        currentSpliter.titleColor = options.titleColor
        currentSpliter.borderColor = options.spliterBorderColor
        currentSpliter.backgroundColor = options.spliterBackgroundColor
        currentSpliter.backgroundImage = options.spliterBackgroundImage
        targetSpliter.isSelected = true
        targetSpliter.transformScale = options.highlightedScale
        targetSpliter.titleColor = options.highlightedTitleColor
        targetSpliter.borderColor = options.spliterHighlightedBorderColor
        targetSpliter.backgroundColor = options.spliterHighlightedBackgroundColor
        targetSpliter.backgroundImage = options.spliterHighlightedBackgroundImage
        let currentSpliterCell: MNSplitCellConvertible? = collectionView.cellForItem(at: currentIndexPath) as? MNSplitCellConvertible
        currentSpliterCell?.updateTitleColor?(options.titleColor)
        currentSpliterCell?.updateBorderColor?(options.spliterBorderColor)
        currentSpliterCell?.updateBackgroundColor?(options.spliterBackgroundColor)
        currentSpliterCell?.updateBackgroundImage?(options.spliterBackgroundImage)
        currentSpliterCell?.updateItemState?(false, at: currentIndexPath.item)
        let targetSpliterCell: MNSplitCellConvertible? = collectionView.cellForItem(at: targetIndexPath) as? MNSplitCellConvertible
        targetSpliterCell?.updateTitleColor?(options.highlightedTitleColor)
        targetSpliterCell?.updateBorderColor?(options.spliterHighlightedBorderColor)
        targetSpliterCell?.updateBackgroundColor?(options.spliterHighlightedBackgroundColor)
        targetSpliterCell?.updateBackgroundImage?(options.spliterHighlightedBackgroundImage)
        targetSpliterCell?.updateItemState?(true, at: targetIndexPath.item)
        UIView.animate(withDuration: options.transitionDuration, delay: 0.01, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            if let cell = currentSpliterCell {
                cell.updateTitleScale?(currentSpliter.transformScale)
            }
            if let cell = targetSpliterCell {
                cell.updateTitleScale?(targetSpliter.transformScale)
            }
            if self.lastPageIndex == index {
                self.shadow.frame = targetSpliter.shadowFrame
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.isUserInteractionEnabled = true
            self.scrollSpliter(at: index, to: self.options.scrollPosition, animated: true)
        }
        if lastPageIndex != index {
            // 标记线动画
            let duration: TimeInterval = options.transitionDuration/2.0
            let animations: ()->Void = { [weak self] in
                guard let self = self else { return }
                guard self.options.shadowAnimation == .adsorb else { return }
                var shadowFrame = self.shadow.frame
                if index > currentPageIndex {
                    if self.axis == .horizontal {
                        shadowFrame.size.width = targetSpliter.shadowFrame.maxX - shadowFrame.minX
                    } else {
                        shadowFrame.size.height = targetSpliter.shadowFrame.maxY - shadowFrame.minY
                    }
                } else {
                    if self.axis == .horizontal {
                        shadowFrame.size.width = shadowFrame.maxX - targetSpliter.shadowFrame.minX
                        shadowFrame.origin.x = targetSpliter.shadowFrame.minX
                    } else {
                        shadowFrame.size.height = shadowFrame.maxY - targetSpliter.shadowFrame.minY
                        shadowFrame.origin.y = targetSpliter.shadowFrame.minY
                    }
                }
                self.shadow.frame = shadowFrame
            }
            UIView.animate(withDuration: options.shadowAnimation == .adsorb ? duration : .leastNormalMagnitude, animations: animations) { [weak self] _ in
                UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut) {
                    guard let self = self else { return }
                    self.shadow.frame = targetSpliter.shadowFrame
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MNSplitView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { spliters.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNSplitCellConvertible else { return }
        let spliter = spliters[indexPath.item]
        cell.update?(spliter: spliter, at: indexPath.item, axis: axis)
        delegate?.splitCell?(cell, willDisplay: spliter, forItemAt: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isSelectionEnabled else { return }
        let pageIndex: Int = indexPath.item
        guard pageIndex < spliters.count else { return }
        guard indexPath.item != currentPageIndex else { return }
        guard delegate?.splitViewShouldSelectSpliter(at: pageIndex) ?? true else { return }
        setCurrentPage(at: indexPath.item, animated: true)
        delegate?.splitViewDidSelectSpliter(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MNSplitView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { spliters[indexPath.item].frame.size }
}
