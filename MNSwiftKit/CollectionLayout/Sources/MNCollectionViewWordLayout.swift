//
//  MNCollectionViewWordLayout.swift
//  anhe
//
//  Created by panhub on 2022/6/2.
//  标签约束

import UIKit

/// 定制文字布局对象
@IBDesignable public class MNCollectionViewWordLayout: MNCollectionViewLayout {
    
    /// 标签对齐方式
    /// - left: 居左
    /// - center: 居中
    /// - right: 居右
    @objc(MNCollectionViewLayoutAlignment)
    public enum Alignment: Int {
        case left, center, right
    }
    
    /// 对齐方式
    @IBInspectable public var alignment: MNCollectionViewWordLayout.Alignment = .left {
        didSet { invalidateLayout() }
    }
    
    public override func prepare() {
        super.prepare()
        
        // 区数
        guard let collectionView = collectionView else { return }
        let numberOfSections = collectionView.numberOfSections
        guard numberOfSections > 0 else { return }
        
        let contentSize: CGSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: collectionView.contentInset).size
        guard contentSize.width > 0.0, contentSize.height > 0.0 else { return }
        
        // 占位
        for _ in 0..<numberOfSections {
            caches.append([0.0])
        }
        
        var top: CGFloat = 0.0
        
        // 分区约束
        for section in 0..<numberOfSections {
            // 区头间隔
            let headerHeight = referenceSizeForHeader(in: section).height
            if headerHeight > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0.0, y: top, width: contentSize.width, height: headerHeight)
                headerAttributes[section] = attributes
                self.attributes.append(attributes)
                top = attributes.frame.maxY
            }
            // 区边缘约束
            let sectionInset = sectionInset(at: section)
            top += sectionInset.top
            
            let left: CGFloat = sectionInset.left
            let right: CGFloat = sectionInset.right
            let itemCount = collectionView.numberOfItems(inSection: section)
            var items: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
            var itemAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
            let minimumLineSpacing: CGFloat = minimumLineSpacing(at: section)
            let minimumInteritemSpacing: CGFloat = minimumInteritemSpacing(at: section)
            
            var x: CGFloat = left
            var y: CGFloat = top
            let maxWidth: CGFloat = contentSize.width - left - right
            
            for idx in 0..<itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                var itemSize: CGSize = itemSize(at: indexPath)
                itemSize.width = min(itemSize.width, maxWidth)
                let paddingX: CGFloat = (x > left && itemSize.width > 0.0) ? minimumInteritemSpacing : 0.0
                // 判断是否需要换行
                if (x + paddingX + itemSize.width + right) > contentSize.width {
                    // 换行
                    layout(attributes: items, surplus: contentSize.width - x - right)
                    x = left
                    y = items.reduce(0.0, { max($0, $1.frame.maxY) })
                    items.removeAll()
                } else {
                    x += paddingX
                }
                let paddingY: CGFloat = (y > top && itemSize.height > 0.0) ? minimumLineSpacing : 0.0
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: x, y: y + paddingY, width: itemSize.width, height: itemSize.height)
                items.append(attributes)
                itemAttributes.append(attributes)
                self.attributes.append(attributes)
                x = attributes.frame.maxX
            }
            
            // 保存区内约束
            sectionAttributes.append(itemAttributes)
            
            // 结束时再约束一下位置
            if items.count > 0 {
                layout(attributes: items, surplus: contentSize.width - x - right)
                top = items.reduce(0.0, { max($0, $1.frame.maxY) })
                items.removeAll()
            }
            // 更新顶部位置
            if itemAttributes.count > 0 {
                top = itemAttributes.reduce(0.0, { max($0, $1.frame.maxY) })
            }
            
            // 区底部间隔
            top += sectionInset.bottom
            
            // 区尾
            let footerHeight = referenceSizeForFooter(in: section).height
            if footerHeight > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0.0, y: top, width: contentSize.width, height: footerHeight)
                footerAttributes[section] = attributes
                self.attributes.append(attributes)
                top = attributes.frame.maxY
            }
            
            // 标记此时高度
            caches[section][0] = top
        }
        
        // 更新区块
        updateUnions()
    }
    
    /// 依据对齐方式调整约束对象
    /// - Parameters:
    ///   - attributes: 约束对象集合
    ///   - surplus: 剩余宽度
    private func layout(attributes: [UICollectionViewLayoutAttributes], surplus: CGFloat) {
        guard attributes.count > 0 else { return }
        let maxY: CGFloat = attributes.reduce(0.0) { max($0, $1.frame.minY) }
        let maxHeight: CGFloat = attributes.reduce(0.0) { max($0, $1.frame.height) }
        // 横向约束
        switch alignment {
        case .center:
            for attribute in attributes {
                var frame = attribute.frame
                frame.origin.x += surplus/2.0
                attribute.frame = frame
            }
        case .right:
            for attribute in attributes {
                var frame = attribute.frame
                frame.origin.x += surplus
                attribute.frame = frame
            }
        default: break
        }
        // 纵向约束
        for attribute in attributes {
            var frame = attribute.frame
            frame.origin.y = (maxHeight - frame.height)/2.0 + maxY
            attribute.frame = frame
        }
    }
}
