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
    
    let index: Int
    
    let subtitle: String
    
    let module: String
    
    let title: NSAttributedString!
    
    init(index: Int, title: String, subtitle: String, module: String) {
        
        let prefix = String(format: "%02ld.", index + 1)
        
        let fullTitle = prefix + " " + title
        
        let attributedText = NSMutableAttributedString(string: fullTitle, attributes: [.font:UIFont(name: "Heiti SC", size: 16.0)!, .foregroundColor:UIColor.black.withAlphaComponent(0.65)])
        attributedText.addAttribute(.font, value: UIFont(name: "GillSans-Italic", size: 16.0)!, range: (fullTitle as NSString).range(of: prefix))
        attributedText.addAttribute(.foregroundColor, value: UIColor.systemRed.withAlphaComponent(0.65), range: (fullTitle as NSString).range(of: prefix))
        self.title = attributedText
        self.subtitle = subtitle
        self.index = index
        self.module = module
    }
}
