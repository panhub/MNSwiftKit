//
//  UIImageView+MNExtension.swift
//  MNKit
//
//  Created by 小斯 on 2023/5/5.
//

import UIKit
import Foundation

extension UIImageView {
    
    /// 以自身宽度约束尺寸
    @objc public func sizeFitToWidth() {
        guard let image = image ?? highlightedImage else { return }
        guard image.size.width > 0.0 else { return }
        var frame = frame
        frame.size.height = ceil(image.size.height/image.size.width*frame.width)
        self.frame = frame
    }
    
    /// 以自身高度约束尺寸
    @objc public func sizeFitToHeight() {
        guard let image = image ?? highlightedImage else { return }
        guard image.size.height > 0.0 else { return }
        var frame = frame
        frame.size.width = ceil(image.size.width/image.size.height*frame.height)
        self.frame = frame
    }
}
