//
//  UIButton+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/5/5.
//

import UIKit
import Foundation

extension MNNameSpaceWrapper where Base: UIButton {
    
    /// 以自身宽度约束尺寸
    public func sizeFitToWidth() {
        guard let image = base.currentBackgroundImage ?? base.currentImage else { return }
        guard image.size.width > 0.0 else { return }
        var frame = base.frame
        frame.size.height = ceil(image.size.height/image.size.width*frame.width)
        base.frame = frame
    }
    
    /// 以自身高度约束尺寸
    public func sizeFitToHeight() {
        guard let image = base.currentBackgroundImage ?? base.currentImage else { return }
        guard image.size.height > 0.0 else { return }
        var frame = base.frame
        frame.size.width = ceil(image.size.width/image.size.height*frame.height)
        base.frame = frame
    }
}
