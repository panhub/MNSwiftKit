//
//  MNCollectionViewFlowLayout.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/5.
//  数据流约束对象

import UIKit

public class MNCollectionViewFlowLayout: MNCollectionViewLayout {
    
    /// 滑动方向
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet { invalidateLayout() }
    }
    
    public override func prepare() {
        super.prepare()
        if scrollDirection == .vertical {
            prepareVerticalLayout()
        } else {
            prepareHorizontalLayout()
        }
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        var contentSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: collectionView.contentInset).size
        if let last = caches.last, let value = last.first {
            if scrollDirection == .vertical {
                contentSize.height = max(preferredContentSize.height, value)
            } else {
                contentSize.width = max(preferredContentSize.width, value)
            }
        } else if scrollDirection == .vertical {
            contentSize.height = preferredContentSize.height
        } else {
            contentSize.width = preferredContentSize.width
        }
        return contentSize
    }
    
    /// 纵向约束
    public func prepareVerticalLayout() {
        
        // 区数
        guard let collectionView = collectionView else { return }
        let numberOfSections = collectionView.numberOfSections
        guard numberOfSections > 0 else { return }
        
        let contentSize: CGSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: collectionView.contentInset).size
        guard contentSize.width > 0.0, contentSize.height > 0.0 else { return }
        
        // 占位
        for section in 0..<numberOfSections {
            let columnCount = numberOfColumns(inSection: section)
            let sectionColumnHeights: [CGFloat] = [CGFloat](repeating: 0.0, count: columnCount)
            caches.append(sectionColumnHeights)
        }
        
        var top: CGFloat = 0.0
        
        // 区
        for section in 0..<numberOfSections {
            // 区边缘约束
            let sectionInset = sectionInset(atIndex: section)
            // 区顶部间隔
            top += sectionInset.top
            // 区头间隔
            let headerInset = headerInset(inSection: section)
            let headerHeight = referenceSizeForHeader(inSection: section).height
            top += headerInset.top
            if headerHeight > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: sectionInset.left + headerInset.left, y: top, width: contentSize.width - sectionInset.left - sectionInset.right - headerInset.left - headerInset.right, height: headerHeight)
                headerAttributes[section] = attributes
                self.attributes.append(attributes)
                top = attributes.frame.maxY
            }
            top += headerInset.bottom
            
            // 区内数量
            let columnCount = numberOfColumns(inSection: section)
            
            // 标记此时高度
            for idx in 0..<columnCount {
                caches[section][idx] = top
            }
            
            let minimumInteritemSpacing = minimumInteritemSpacing(inSection: section)
            let itemWidth: CGFloat = floor((contentSize.width - sectionInset.left - sectionInset.right - CGFloat(columnCount - 1)*minimumInteritemSpacing)/CGFloat(columnCount)*10.0)/10.0
            
            assert(itemWidth >= 0.0, "每一项宽度需要大于0.0才能布局")
            
            let minimumLineSpacing = minimumLineSpacing(inSection: section)
            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes:[UICollectionViewLayoutAttributes] = []
            
            for idx in 0..<itemCount {
                // 当前
                let indexPath = IndexPath(item: idx, section: section)
                let itemSize = itemSize(at: indexPath)
                var itemHeight: CGFloat = 0.0
                if abs(itemSize.width - itemSize.height) <= 0.1 {
                    // 方形布局
                    itemHeight = itemWidth
                } else if abs(itemSize.width - itemWidth) <= 0.1 {
                    // 以给定尺寸布局
                    itemHeight = floor(itemSize.height*10.0)/10.0
                } else if itemSize.width > 0.0 {
                    // 以同等比例计算
                    itemHeight = floor(itemSize.height/itemSize.width*itemWidth*10.0)/10.0
                }
                // 需要追加的列
                let appendIndex = shortestColumnIndex(inSection: section)
                // 寻找起始位置
                var y: CGFloat = caches[section][appendIndex]
                if y > top, itemHeight > 0.0 {
                    y += minimumLineSpacing
                }
                let x: CGFloat = sectionInset.left + (itemWidth + minimumInteritemSpacing)*CGFloat(appendIndex)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                self.attributes.append(attributes)
                // 保存时添加间隔
                caches[section][appendIndex] = attributes.frame.maxY
            }
            
            sectionAttributes.append(itemAttributes)
            
            // 更新顶部标记
            let longestColumnIndex = longestColumnIndex(inSection: section)
            top = caches[section][longestColumnIndex]
            
            // 区尾间隔
            let footerInset = footerInset(inSection: section)
            let footerHeight = referenceSizeForFooter(inSection: section).height
            top += footerInset.top
            if footerHeight > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: sectionInset.left + footerInset.left, y: top, width: contentSize.width - sectionInset.left - sectionInset.right - footerInset.left - footerInset.right, height: footerHeight)
                footerAttributes[section] = attributes
                self.attributes.append(attributes)
                top = attributes.frame.maxY
            }
            top += footerInset.bottom
            
            // 区底部间隔
            top += sectionInset.bottom
            
            // 标记此时高度
            for idx in 0..<columnCount {
                caches[section][idx] = top
            }
        }
        
        // 更新区块
        updateUnions()
    }
    
    /// 横向布局约束
    public func prepareHorizontalLayout() {
        
        // 区数
        guard let collectionView = collectionView else { return }
        let numberOfSections = collectionView.numberOfSections
        guard numberOfSections > 0 else { return }
        
        let contentSize: CGSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: collectionView.contentInset).size
        guard contentSize.width > 0.0, contentSize.height > 0.0 else { return }
        
        // 占位
        for section in 0..<numberOfSections {
            let columnCount = numberOfColumns(inSection: section)
            let sectionColumnWidths: [CGFloat] = [CGFloat](repeating: 0.0, count: columnCount)
            caches.append(sectionColumnWidths)
        }
        
        var right: CGFloat = 0.0
        
        // 区
        for section in 0..<numberOfSections {
            
            let sectionInset = sectionInset(atIndex: section)
            
            // 区顶部间隔
            right += sectionInset.left
            
            // 区头间隔
            let headerInset = headerInset(inSection: section)
            let headerWidth = referenceSizeForHeader(inSection: section).width
            right += headerInset.left
            if headerWidth > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: right, y: sectionInset.top + headerInset.top, width: headerWidth, height: contentSize.height - sectionInset.top - headerInset.top - sectionInset.bottom - headerInset.bottom)
                headerAttributes[section] = attributes
                self.attributes.append(attributes)
                right = attributes.frame.maxX
            }
            right += headerInset.right
            
            // 区行数
            let columnCount = numberOfColumns(inSection: section)
            
            // 标记此时宽度
            for idx in 0..<columnCount {
                caches[section][idx] = right
            }
            
            let minimumLineSpacing: CGFloat = minimumLineSpacing(inSection: section)
            
            let itemHeight: CGFloat = floor((contentSize.height - sectionInset.top - sectionInset.bottom - CGFloat(columnCount - 1)*minimumLineSpacing)/Double(columnCount)*10.0)/10.0
            
            assert(itemHeight >= 0.0, "每一项高度需要大于0.0才能布局")
            
            let minimumInteritemSpacing: CGFloat = minimumInteritemSpacing(inSection: section)
            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes:[UICollectionViewLayoutAttributes] = []
            
            for idx in 0..<itemCount {
                // 计算尺寸
                var itemWidth: CGFloat = 0.0
                let indexPath = IndexPath(item: idx, section: section)
                let itemSize = itemSize(at: indexPath)
                if abs(itemSize.width - itemSize.height) <= 0.1 {
                    // 正方形布局
                    itemWidth = itemHeight
                } else if abs(itemSize.height - itemHeight) <= 0.1 {
                    // 以给定尺寸布局
                    itemWidth = floor(itemSize.width*10.0)/10.0
                } else if itemSize.height > 0.0 {
                    // 比例布局
                    itemWidth = floor(itemSize.width/itemSize.height*itemHeight*10.0)/10.0
                }
                // 需要追加的行
                let appendIndex = shortestColumnIndex(inSection: section)
                // 这里不添加间隔 避免第一列出错
                var x = caches[section][appendIndex]
                if x > right, itemWidth > 0.0 {
                    x += minimumInteritemSpacing
                }
                let y = sectionInset.top + (itemHeight + minimumLineSpacing)*CGFloat(appendIndex)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                self.attributes.append(attributes)
                // 保存时添加间隔
                caches[section][appendIndex] = attributes.frame.maxX
            }
            
            sectionAttributes.append(itemAttributes)
            
            // 更新右标记
            let longestColumnIndex = longestColumnIndex(inSection: section)
            right = caches[section][longestColumnIndex]
            
            // 区尾间隔
            let footerInset = footerInset(inSection: section)
            let footerWidth = referenceSizeForFooter(inSection: section).width
            right += footerInset.right
            if footerWidth > 0.0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: right, y: sectionInset.top + footerInset.top, width: footerWidth, height: contentSize.height - sectionInset.left - sectionInset.right - headerInset.left - headerInset.right)
                footerAttributes[section] = attributes
                self.attributes.append(attributes)
                right = attributes.frame.maxX
            }
            right += footerInset.right
            
            // 区底部间隔
            right += sectionInset.right
            
            // 标记此时高度
            for idx in 0..<columnCount {
                caches[section][idx] = right
            }
        }
        // 更新区块
        updateUnions()
    }
}
