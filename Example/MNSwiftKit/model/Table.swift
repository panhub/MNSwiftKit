//
//  Table.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/25.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import Foundation
import MNSwiftKit

enum Table: Int {
    case user
    case order
    case comment
    
    var modelType: MNTableRowInitializable.Type {
        
        User.self
    }
    
    var tableName: String {
        
        "t_user"
    }
}

extension Table {
    
    class Row {
        
        let contents: [String]
        
        init(contents: [String]) {
            self.contents = contents
        }
    }
}

