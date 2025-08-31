//
//  MNEmoticonCollectionLayout.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/8/30.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  仅对表情布局做特殊处理

import UIKit

class MNEmoticonCollectionLayout: MNCollectionViewFlowLayout {
    
    override func prepareHorizontalLayout() {
        
        // 区数
        guard let collectionView = collectionView else { return }
        let numberOfSections = collectionView.numberOfSections
        guard numberOfSections > 0 else { return }
        
        // 占位
        for section in 0..<numberOfSections {
            caches.append([0.0])
        }
        
        let contentInset = collectionView.contentInset
        let contentSize: CGSize = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: contentInset).size
        guard contentSize.width > 0.0, contentSize.height > 0.0 else { return }
        
        var right: CGFloat = 0.0
        
        for section in 0..<numberOfSections {
            
            let sectionInset = sectionInset(atIndex: section)
            let columnCount = numberOfColumns(inSection: section)
            let minimumLineSpacing = minimumLineSpacing(inSection: section)
            let minimumInteritemSpacing = minimumInteritemSpacing(inSection: section)
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
            
            caches[section][0] = right
        }
        
        updateUnions()
    }
}
