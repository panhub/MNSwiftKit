//
//  SegmentedPageItem.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation

class SegmentedPageItem {
    
    var index: Int = 0
    
    var height: CGFloat = 55.0
    
    init() {}
    
    convenience init(height: CGFloat) {
        self.init()
        self.height = height
    }
}
