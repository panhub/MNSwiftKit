//
//  Order.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/24.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import Foundation
import MNSwiftKit

class Order: MNTableRowInitializable {
    
    var uid: String = ""
    
    var amount: Double = 0
    
    var title: String = ""
    
    var subtitle: String?
    
    var createdAt: String = ""
    
    required init() {}
}

extension Order: MNTableColumnAssignment {
    
    func setValue(_ value: Any?, forColumn name: String) {
        switch name {
        case "uid":
            uid = value as? String ?? ""
        case "amount":
            amount = value as? Double ?? (value as? NSNumber)?.doubleValue ?? 0.0
        case "title":
            title = value as? String ?? ""
        case "subtitle":
            subtitle = value as? String ?? ""
        case "createdAt":
            createdAt = value as? String ?? ""
        default: break
        }
    }
}
