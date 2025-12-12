//
//  CollectionViewCell.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var cccview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cccview.backgroundColor = .systemBlue
    }
}
