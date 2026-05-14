//
//  Comment.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/24.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import Foundation
import MNSwiftKit

class Comment: MNTableRowInitializable {
    
    var cid: Int = 0
    
    var userId: Int = 0
    
    var orderId: Int?
    
    var content: String = ""
    
    var createdAt: String = ""
    
    required init() {}
}

extension Comment: MNTableColumnSupported {
    
    static var supportedTableColumns: [MNSwiftKit.MNTableColumn] {
        [
            .init(name: "cid", type: .integer, primary: true),
            .init(name: "userId", type: .integer),
            .init(name: "orderId", type: .integer, nullable: true),
            .init(name: "content", type: .text),
            .init(name: "createdAt", type: .text)
        ]
    }
}

extension Comment: MNTableColumnAssignment {
    
    func setValue(_ value: Any?, forColumn name: String) {
        switch name {
        case "cid":
            cid = value as? Int ?? 0
        case "userId":
            userId = value as? Int ?? 0
        case "orderId":
            orderId = value as? Int
        case "content":
            content = value as? String ?? ""
        case "createdAt":
            createdAt = value as? String ?? ""
        default: break
        }
    }
}
