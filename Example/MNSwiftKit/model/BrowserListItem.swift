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
    
    var asAsset: MNAsset {
        let asset = MNAsset()
        asset.container = containerView
        switch type {
        case .photo:
            asset.type = .photo
            asset.cover = UIImage(named: name)
            asset.contents = UIImage(named: name)
        default:
            asset.type = .video
            asset.cover = UIImage(contentsOfFile: name)
            asset.contents = name.mn.deletingPathExtension.mn.appendingPathExtension("mp4")
        }
        return asset
    }
}
