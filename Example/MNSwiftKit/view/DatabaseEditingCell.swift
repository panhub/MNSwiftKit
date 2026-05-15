//
//  DatabaseEditingCell.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/3/25.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

protocol DatabaseEditing {
    
    func cellShouldBeginEditing(_ cell: DatabaseEditingCell) -> Bool
}

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        textField.placeholder = nil
    }
    
    func updateColumn(_ column: MNTableColumn) {
        textField.placeholder = Table.placeholder(forColumn: column.name)
        switch column.type {
        case .integer:
            textField.keyboardType = .numberPad
        case .float:
            textField.keyboardType = .decimalPad
        default:
            textField.keyboardType = .default
        }
    }
}

extension DatabaseEditingCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let delegate = mn.seek(as: DatabaseEditing.self) else { return false }
        return delegate.cellShouldBeginEditing(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
