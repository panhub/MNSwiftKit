//
//  MNAssetTypeView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/7.
//  媒体资源类型图

import UIKit

class MNAssetTypeView: UIImageView {
    
    private var attributes: [MNAssetType : UIImage] = [:]
    
    private let hdrImage = AssetPickerResource.image(named: "picker_asset_hdr")?.mn.rendering(to: UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0))
    
    var isHDR: Bool = false {
        didSet {
            guard type == .photo else { return }
            if isHDR {
                image = hdrImage
            } else {
                image = attributes[.photo]
            }
        }
    }
    
    var type: MNAssetType = .photo {
        didSet {
            if type == .photo {
                image = isHDR ? hdrImage : attributes[.photo]
            } else {
                image = attributes[type]
            }
        }
    }
    
    func setImage(_ image: UIImage?, for type: MNAssetType) {
        if let image = image {
            attributes[type] = image
        } else {
            attributes.removeValue(forKey: type)
        }
        if self.type == .photo {
            self.image = isHDR ? hdrImage : attributes[.photo]
        } else {
            self.image = attributes[self.type]
        }
    }
}
