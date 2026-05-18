//
//  DatabaseCollectionCell.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/24.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class DatabaseCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mn.layoutContentView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        mn.reuseContentView()
    }
    
    func updateRow(_ row: Table.Row) {
        let subviews = stackView.arrangedSubviews.compactMap { $0 as? DatabaseCollectionItem }
        for (index, field) in row.fields.enumerated() {
            if subviews.count > index {
                let subview = subviews[index]
                subview.isHidden = false
                subview.textLabel.text = field.displayString
            } else {
                // 添加
                let subview = DatabaseCollectionItem.mn.loadFromNib()!
                subview.textLabel.text = field.displayString
                stackView.addArrangedSubview(subview)
            }
        }
        if subviews.count > row.fields.count {
            let subviews = subviews.suffix(from: row.fields.count)
            subviews.forEach { $0.isHidden = true }
        }
    }
}
