//
//  FontTableCell.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/1/12.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

class FontTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func update(font: FontName, index: Int) {
        
        nameLabel.font = font.font
        nameLabel.text = font.name
        contentView.backgroundColor = index%2 == 0 ? .white : .gray.withAlphaComponent(0.04)
    }
}
