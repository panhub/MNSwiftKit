//
//  SegmentedPageCell.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

class SegmentedPageCell: UICollectionViewCell {
    
    // 
    @IBOutlet weak var borderView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(item: SegmentedPageItem) {
        
        borderView.backgroundColor = item.index % 2 == 0 ? .gray.withAlphaComponent(0.04) : .white
    }
}
