//
//  EmptySortedCollectionCell.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/1/16.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

class EmptySortedCollectionCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    
    func update(text: String) {
        
        textLabel.text = text
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
