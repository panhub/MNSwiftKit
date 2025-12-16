//
//  HomeTableCell.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

class HomeTableCell: UITableViewCell {
    
    @IBOutlet weak var clsLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var podLabel: UILabel!
    
    @IBOutlet weak var spmLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(row: HomeListRow) {
        
        nameLabel.attributedText = row.title
        
        clsLabel.text = row.cls
        
        podLabel.text = "'\(row.module)'"
        
        spmLabel.text = "MN\(row.module)"
        
        contentView.backgroundColor = row.index%2 == 0 ? .white : .gray.withAlphaComponent(0.04)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
