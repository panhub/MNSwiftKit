//
//  MNAssetTypeView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/7.
//  媒体资源类型图

import UIKit

class MNAssetTypeView: UIImageView {
    
    private var attributes: [MNAssetType : UIImage] = [:]
    
    var type: MNAssetType = .photo {
        didSet {
            image = attributes[type]
        }
    }
    
    func setImage(_ image: UIImage?, for type: MNAssetType) {
        if let image = image {
            attributes[type] = image
        } else {
            attributes.removeValue(forKey: type)
        }
        self.image = attributes[self.type]
    }
}
