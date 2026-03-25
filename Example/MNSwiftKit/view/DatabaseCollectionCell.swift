//
//  DatabaseCollectionCell.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/24.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

class DatabaseCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateRow(_ row: Table.Row) {
        let subviews = stackView.arrangedSubviews.compactMap { $0 as? DatabaseCollectionItem }
        for (index, content) in row.contents.enumerated() {
            if subviews.count > index {
                let subview = subviews[index]
                subview.isHidden = false
                subview.textLabel.text = content
            } else {
                // 添加
                let subview = DatabaseCollectionItem.mn.loadFromNib()!
                subview.textLabel.text = content
                stackView.addArrangedSubview(subview)
            }
        }
        if subviews.count > row.contents.count {
            let subviews = subviews.suffix(from: row.contents.count)
            subviews.forEach { $0.isHidden = true }
        }
    }
}
