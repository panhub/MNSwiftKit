//
//  EditingTableCell.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/12/18.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

class EditingTableCell: UITableViewCell {
    
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
