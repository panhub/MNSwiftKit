//
//  MNEmoticonLayout.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/30.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  仅对表情布局做特殊处理

import UIKit

class MNEmoticonLayout: UICollectionViewFlowLayout {
    /// 列数
    public var numberOfColumns: Int = 3 {
        didSet { invalidateLayout() }
    }
    /// 指定内容尺寸
    public var preferredContentSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    /// 周期内布局对象的范围, 便于后期计算返回
    private var unions: [CGRect] = []
    /// 区内每一列/行的高/宽缓存
    private var caches: [CGFloat] = []
    /// 所有布局对象(包括区头区尾)缓存
    private var attributes: [UICollectionViewLayoutAttributes] = []
    /// 区布局对象缓存
    private var sectionAttributes: [[UICollectionViewLayoutAttributes]] = []
    
    /// 更新区块
    public func updateUnions() {
        var idx: Int = 0
        while idx < attributes.count {
            var rect = attributes[idx].frame
            let endIndex = min(idx + 20, attributes.count)
            for i in (idx + 1)..<endIndex {
                rect = rect.union(attributes[i].frame)
            }
            idx = endIndex
            unions.append(rect)
        }
    }
    
    /// 重写
    public override func prepare() {
        super.prepare()
        unions.removeAll()
        caches.removeAll()
        attributes.removeAll()
        sectionAttributes.removeAll()
        
        guard scrollDirection == .horizontal else { return }
        
        // 区数
        guard let collectionView = collectionView else { return }
        let numberOfSections = collectionView.numberOfSections
        guard numberOfSections > 0 else { return }
        
        // 占位
        caches.append(contentsOf: Array(repeating: 0.0, count: numberOfSections))
        
        let contentInset = collectionView.contentInset
        let contentSize: CGSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: contentInset).size
        guard contentSize.width > 0.0, contentSize.height > 0.0 else { return }
        
        var right: CGFloat = 0.0
        
        for section in 0..<numberOfSections {
            
            let sectionInset = sectionInset
            let columnCount = numberOfColumns
            let minimumLineSpacing = minimumLineSpacing
            let minimumInteritemSpacing = minimumInteritemSpacing
            let itemCount = collectionView.numberOfItems(inSection: section)
            
            var itemAttributes:[UICollectionViewLayoutAttributes] = []
            
            for index in 0..<itemCount {
                let x = right + sectionInset.left + (itemSize.width + minimumInteritemSpacing)*CGFloat(index%columnCount)
                let y = sectionInset.top + (itemSize.height + minimumLineSpacing)*CGFloat(index/columnCount)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: .init(item: index, section: section))
                attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
                itemAttributes.append(attributes)
                self.attributes.append(attributes)
            }
            
            sectionAttributes.append(itemAttributes)
            
            if numberOfSections == 1 {
                right = contentSize.width
            } else if section == 0 {
                right = collectionView.frame.width - contentInset.left
            } else if section == numberOfSections - 1 {
                right += (collectionView.frame.width - contentInset.right)
            } else {
                right += collectionView.frame.width
            }
            
            caches[section] = right
        }
        
        updateUnions()
    }
    
    public override var collectionViewContentSize: CGSize {
        guard scrollDirection == .horizontal else {
            return super.collectionViewContentSize
        }
        guard let collectionView = collectionView else { return .zero }
        var contentSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: collectionView.contentInset).size
        contentSize.width = preferredContentSize.width
        if let last = caches.last {
            contentSize.width = max(preferredContentSize.width, last)
        }
        return contentSize
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard scrollDirection == .horizontal else {
            return super.layoutAttributesForItem(at: indexPath)
        }
        guard indexPath.section < sectionAttributes.count else { return nil }
        let attributes = sectionAttributes[indexPath.section]
        guard indexPath.item < attributes.count else { return nil }
        return attributes[indexPath.item]
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard scrollDirection == .horizontal else {
            return super.layoutAttributesForElements(in: rect)
        }
        var begin: Int = 0
        var end: Int = 0
        let union: Int = 20
        var cells = [IndexPath: UICollectionViewLayoutAttributes]()
        var headers = [IndexPath: UICollectionViewLayoutAttributes]()
        var footers = [IndexPath: UICollectionViewLayoutAttributes]()
        var decorations = [IndexPath: UICollectionViewLayoutAttributes]()
        
        for i in 0..<unions.count {
            if rect.intersects(unions[i]) {
                begin = i*union
                break
            }
        }
        
        for i in (0..<unions.count).reversed() {
            if rect.intersects(unions[i]) {
                end = min((i + 1)*union, attributes.count)
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
