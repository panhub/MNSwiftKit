//
//  EditingTableCell.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/12/18.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

class EditingTableCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mn.layoutEditingView()
    }
    
    func update(row: Int) {
        
        label.text = "表格索引--\(row)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
