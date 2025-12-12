//
//  MNCollectionViewLayout.swift
//  anhe
//
//  Created by panhub on 2022/6/2.
//  瀑布流约束对象

import UIKit

extension UICollectionView {
    
    /// 自定义标识符
    public struct Identifier {
        /// Cell 标识符
        static let cell: String = "com.mn.collection.cell.reuseIdentifier"
        /// 头视图标识符
        static let header: String = "com.mn.collection.section.header.reuseIdentifier"
        /// 尾视图标识符
        static let footer: String = "com.mn.collection.section.footer.reuseIdentifier"
    }
}

/// 布局对象定制代理
@MainActor public protocol MNCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    
    /// 定制区列数/行数
    /// - Parameters:
    ///   - collectionView: 视图
    ///   - collectionViewLayout: 约束对象
    ///   - section: 区索引
    /// - Returns: 列数/行数
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: MNCollectionViewLayout, numberOfColumnsInSection section: Int) -> Int
}

/// CollectionView约束对象
@IBDesignable public class MNCollectionViewLayout: UICollectionViewLayout {
    
    /// 尺寸
    @IBInspectable public var itemSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    /// 滑动方向相邻两个表格的间隔
    @IBInspectable public var minimumLineSpacing: CGFloat = 0.0 {
        didSet { invalidateLayout() }
    }
    
    /// 滑动相反方向两个表格的间隔
    @IBInspectable public var minimumInteritemSpacing: CGFloat = 0.0 {
        didSet { invalidateLayout() }
    }
    
    /// 区头大小(竖向取高度, 纵向取宽度)
    @IBInspectable public var headerReferenceSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    /// 区尾大小(竖向取高度, 纵向取宽度)
    @IBInspectable public var footerReferenceSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    /// 区间隔
    @IBInspectable public var sectionInset: UIEdgeInsets = .zero {
        didSet { invalidateLayout() }
    }
    
    /// 纵向列数, 横向行数
    @IBInspectable public var numberOfColumns: Int = 3 {
        didSet { invalidateLayout() }
    }
    
    /// 指定内容尺寸
    @IBInspectable public var preferredContentSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    /// 定义单位区块包含的数量
    private let numberOfAttributesInUnion: Int = 20
    /// 周期内布局对象的范围, 便于后期计算返回
    private var unions: [CGRect] = []
    /// 区内每一列/行的高/宽缓存
    var caches: [[CGFloat]] = []
    /// 所有布局对象(包括区头区尾)缓存
    var attributes: [UICollectionViewLayoutAttributes] = []
    /// 区头布局对象缓存
    var headerAttributes: [Int: UICollectionViewLayoutAttributes] = [:]
    /// 区尾布局对象缓存
    var footerAttributes: [Int: UICollectionViewLayoutAttributes] = [:]
    /// 区布局对象缓存
    var sectionAttributes: [[UICollectionViewLayoutAttributes]] = []
    
    
    public override func prepare() {
        super.prepare()
        unions.removeAll()
        caches.removeAll()
        attributes.removeAll()
        footerAttributes.removeAll()
        headerAttributes.removeAll()
        sectionAttributes.removeAll()
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        var contentSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: collectionView.contentInset).size
        if let last = caches.last, let value = last.first {
            contentSize.height = max(preferredContentSize.height, value)
        } else {
            contentSize.height = preferredContentSize.height
        }
        return contentSize
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < sectionAttributes.count else { return nil }
        guard indexPath.item < sectionAttributes[indexPath.section].count else { return nil }
        return sectionAttributes[indexPath.section][indexPath.item]
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return headerAttributes[indexPath.section]
        case UICollectionView.elementKindSectionFooter:
            return footerAttributes[indexPath.section]
        default: return nil
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin: Int = 0
        var end: Int = 0
        var cells = [IndexPath: UICollectionViewLayoutAttributes]()
        var headers = [IndexPath: UICollectionViewLayoutAttributes]()
        var footers = [IndexPath: UICollectionViewLayoutAttributes]()
        var decorations = [IndexPath: UICollectionViewLayoutAttributes]()
        
        for i in 0..<unions.count {
            if rect.intersects(unions[i]) {
                begin = i*numberOfAttributesInUnion
                break
            }
        }
        
        for i in (0..<unions.count).reversed() {
            if rect.intersects(unions[i]) {
                end = min((i + 1)*numberOfAttributesInUnion, attributes.count)
                break
            }
        }
        
        for i in begin..<end {
            let attributes = attributes[i]
            if rect.intersects(attributes.frame) {
                switch attributes.representedElementCategory {
                case .cell:
                    cells[attributes.indexPath] = attributes
                case .decorationView:
                    decorations[attributes.indexPath] = attributes
                case .supplementaryView:
                    if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                        headers[attributes.indexPath] = attributes
                    } else if attributes.representedElementKind == UICollectionView.elementKindSectionFooter {
                        footers[attributes.indexPath] = attributes
                    }
                @unknown default:
#if DEBUG
                    print("'layoutAttributesForElements(in:)' 出现未确定选项")
#endif
                }
            }
        }
        
        var result = [UICollectionViewLayoutAttributes]()
        result.append(contentsOf: cells.values)
        result.append(contentsOf: headers.values)
        result.append(contentsOf: footers.values)
        result.append(contentsOf: decorations.values)
        
        return result.count > 0 ? result : nil
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        return newBounds.size != collectionView.bounds.size
    }
}

// MARK: - 获取约束信息
extension MNCollectionViewLayout {
    
    /// 获取区列数、行数
    /// - Parameter section: 区索引
    /// - Returns: 列数、行数
    func numberOfColumns(in section: Int) -> Int {
        if let collectionView = collectionView, let dataSource = collectionView.dataSource as? MNCollectionViewDelegateFlowLayout {
            let numberOfColumns = dataSource.collectionView(collectionView, layout: self, numberOfColumnsInSection: section)
            return max(numberOfColumns, 1)
        }
        return max(numberOfColumns, 1)
    }
    
    /// 滑动方向上间隔
    /// - Parameter section: 区索引
    /// - Returns: 间隔
    func minimumLineSpacing(at section: Int) -> CGFloat {
        if let collectionView = collectionView, let dataSource = collectionView.dataSource as? UICollectionViewDelegateFlowLayout, let minimumLineSpacing = dataSource.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) {
            return minimumLineSpacing
        }
        return minimumLineSpacing
    }
    
    /// 与滑动方向相反方向的相邻表格间隔
    /// - Parameter section: 区索引
    /// - Returns: 间隔
    func minimumInteritemSpacing(at section: Int) -> CGFloat {
        if let collectionView = collectionView, let dataSource = collectionView.dataSource as? UICollectionViewDelegateFlowLayout, let minimumInteritemSpacing = dataSource.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) {
            return minimumInteritemSpacing
        }
        return minimumInteritemSpacing
    }
    
    /// 区四周约束
    /// - Parameter section: 区索引
    /// - Returns: 约束
    func sectionInset(at section: Int) -> UIEdgeInsets {
        if let collectionView = collectionView, let dataSource = collectionView.dataSource as? UICollectionViewDelegateFlowLayout, let sectionInset = dataSource.collectionView?(collectionView, layout: self, insetForSectionAt: section) {
            return sectionInset
        }
        return sectionInset
    }
    
    /// 表格尺寸
    /// - Parameter indexPath: 表格索引
    /// - Returns: 表格尺寸
    func itemSize(at indexPath: IndexPath) -> CGSize {
        if let collectionView = collectionView, let dataSource = collectionView.dataSource as? UICollectionViewDelegateFlowLayout, let itemSize = dataSource.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            return itemSize
        }
        return itemSize
    }
    
    /// 区头视图尺寸
    /// - Parameter section: 区索引
    /// - Returns: 区头尺寸
    func referenceSizeForHeader(in section: Int) -> CGSize {
        if let collectionView = collectionView, let dataSource = collectionView.dataSource as? UICollectionViewDelegateFlowLayout, let headerReferenceSize = dataSource.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
            return headerReferenceSize
        }
        return headerReferenceSize
    }
    
    /// 区尾尺寸
    /// - Parameter section: 区索引
    /// - Returns: 区尾尺寸
    func referenceSizeForFooter(in section: Int) -> CGSize {
        if let collectionView = collectionView, let dataSource = collectionView.dataSource as? UICollectionViewDelegateFlowLayout, let footerReferenceSize = dataSource.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
            return footerReferenceSize
        }
        return footerReferenceSize
    }
    
    /// 寻找最短一列/行
    /// - Parameter section: 区索引
    /// - Returns: 最短列/行索引
    public func shortestColumnIndex(in section: Int) -> Int {
        var index: Int = 0
        let items = caches[section]
        var height: CGFloat = CGFloat.greatestFiniteMagnitude
        for (idx, value) in items.enumerated() {
            guard value < height else { continue }
            index = idx
            height = value
        }
        return index
    }
    
    /// 寻找最长一列/行
    /// - Parameter section: 区索引
    /// - Returns: 最长列/行索引
    public func longestColumnIndex(in section: Int) -> Int {
        var index: Int = 0
        var height: CGFloat = 0.0
        let items = caches[section]
        for (idx, value) in items.enumerated() {
            guard value > height else { continue }
            index = idx
            height = value
        }
        return index
    }
    
    /// 更新区块
    public func updateUnions() {
        // 保存区域便于查找
        var idx: Int = 0
        while idx < attributes.count {
            var rect = attributes[idx].frame
            let endIndex = min(idx + numberOfAttributesInUnion, attributes.count)
            for i in (idx + 1)..<endIndex {
                rect = rect.union(attributes[i].frame)
            }
            idx = endIndex
            unions.append(rect)
        }
    }
}
