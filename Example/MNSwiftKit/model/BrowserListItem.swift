//
//  BrowserListItem.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import MNSwiftKit

class BrowserListItem {
    
    enum ItemType {
        case photo, video
    }
    
    var type: BrowserListItem.ItemType = .photo
    
    var name: String = ""
    
    var height: CGFloat = 0.0
    
    weak var containerView: UIView!
    
    init(type: BrowserListItem.ItemType, name: String) {
        self.type = type
        switch type {
        case .photo:
            self.name = name
        case .video:
            self.name = Bundle.main.path(forResource: name, ofType: "jpg")!
        }
    }
}

extension BrowserListItem {
    
    var asItem: MNAssetBrowser.Item {
        let item = MNAssetBrowser.Item()
        item.container = containerView
        switch type {
        case .photo:
            item.type = .photo
            item.cover = UIImage(named: name)
            item.contents = UIImage(named: name)
        default:
            item.type = .video
            item.cover = UIImage(contentsOfFile: name)
            item.contents = name.mn.deletingPathExtension.mn.appendingPathExtension("mp4")
        }
        return item
    }
}
