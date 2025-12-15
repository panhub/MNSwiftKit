//
//  BrowserCollectionCell.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

class BrowserCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var playView: UIImageView!
    
    @IBOutlet weak var coverView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(item: BrowserListItem) {
        item.containerView = coverView
        playView.isHidden = item.type == .photo
        switch item.type {
        case .photo:
            coverView.image = UIImage(named: item.name)
        case .video:
            coverView.image = UIImage(contentsOfFile: item.name)
        }
    }
}
