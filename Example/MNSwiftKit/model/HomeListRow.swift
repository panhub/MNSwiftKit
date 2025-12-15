//
//  HomeListRow.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

class HomeListRow {
    
    let cls: String
    
    let index: Int
    
    
    let title: NSAttributedString!
    
    init(index: Int, name: String, cls: String) {
        
        let prefix = String(format: "%02ld.", index + 1)
        
        let fullName = prefix + " " + name
        
        let attributedText = NSMutableAttributedString(string: fullName, attributes: [.font:UIFont(name: "Heiti SC", size: 16.0)!, .foregroundColor:UIColor.black.withAlphaComponent(0.65)])
        attributedText.addAttribute(.font, value: UIFont(name: "GillSans-Italic", size: 16.0)!, range: (fullName as NSString).range(of: prefix))
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemRed.withAlphaComponent(0.65), range: (fullName as NSString).range(of: prefix))
        title = attributedText
        self.cls = cls
        self.index = index
    }
}
