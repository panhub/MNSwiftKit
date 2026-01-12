//
//  FontFamily.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/1/12.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

struct FontFamily {
    
    /// 簇名
    let name: String
    
    /// 字体名称
    let fontNames: [FontName]
    
    init(name: String) {
        self.name = name
        self.fontNames = UIFont.fontNames(forFamilyName: name).compactMap({ FontName(name: $0) })
    }
}

struct FontName {
    /// 字体名称
    let name: String
    /// 字体
    let font: UIFont
    /// 行高
    let rowHeight: CGFloat
    
    init(name: String) {
        self.name = name
        self.font = UIFont(name: name, size: 17.0)!
        let size = name.size(withAttributes: [.font:font])
        self.rowHeight = max(ceil(size.height + 30.0), 45.0)
    }
}

struct FontFamilyCollation {
    
    let title: String
    
    let familys: [FontFamily]
}
