//
//  DatabaseEditingCell.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/3/25.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit

class DatabaseEditingCell: UICollectionViewCell {
    
    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: 35)))
        
        textField.rightViewMode = .always
        textField.rightView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: 35)))
    }

}
