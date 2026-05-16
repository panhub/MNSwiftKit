//
//  Comment.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/24.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import Foundation
import MNSwiftKit

class Comment: NSObject, MNTableRowInitializable {
    
    @objc var uid: String = ""
    
    @objc var favours: Int = 0
    
    @objc var content: String = ""
    
    @objc var comment: String = ""
    
    @objc var createdAt: String = ""
    
    required override init() {
        super.init()
    }
}
