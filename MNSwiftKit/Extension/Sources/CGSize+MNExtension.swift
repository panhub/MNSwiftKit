//
//  CGSize+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/9/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import CoreFoundation

extension NameSpaceWrapper where Base == CGSize {
    
    public var isEmpty: Bool {
        return (base.width.isNaN || base.height.isNaN || base.width <= 0.0 || base.height <= 0.0)
    }
    
    public func multiplyTo(width: CGFloat) -> CGSize {
        guard isEmpty == false else { return .zero }
        return CGSize(width: width, height: width/base.width*base.height)
    }
    
    public func multiplyTo(height: CGFloat) -> CGSize {
        guard isEmpty == false else { return .zero }
        return CGSize(width: height/base.height*base.width, height: height)
    }
    
    public func multiplyTo(min: CGFloat) -> CGSize {
        guard isEmpty == false else { return .zero }
        return base.width <= base.height ? multiplyTo(width: min) : multiplyTo(height: min)
    }
    
    public func multiplyTo(max: CGFloat) -> CGSize {
        guard isEmpty == false else { return .zero }
        return base.width >= base.height ? multiplyTo(width: max) : multiplyTo(height: max)
    }
    
    /// 适应尺寸
    /// - Parameters:
    ///   - size: 目标尺寸
    /// - Returns: 依据比例适应的结果
    public func scaleFit(in size: CGSize) -> CGSize {
        let targetSize = CGSize(width: floor(size.width), height: floor(size.height))
        guard Swift.min(targetSize.width, targetSize.height) > 0.0, Swift.min(base.width, base.height) > 0.0 else { return targetSize }
        var width: Double = 0.0
        var height: Double = 0.0
        if targetSize.height >= targetSize.width {
            // 竖屏/方形
            width = targetSize.width
            height = base.height/base.width*width
            if height.isNaN || height < 1.0 {
                height = 1.0
            } else if height > targetSize.height {
                height = targetSize.height
                width = base.width/base.height*height
                if (width.isNaN || width < 1.0) { width = 1.0 }
                width = floor(width)
            } else {
                height = floor(height)
            }
        } else {
            // 横屏
            height = targetSize.height
            width = base.width/base.height*height
            if width.isNaN || width < 1.0 {
                width = 1.0
            } else if width > targetSize.width {
                width = targetSize.width
                height = base.height/base.width*width
                if height.isNaN || height < 1.0 { height = 1.0 }
                height = floor(height)
            } else {
                width = floor(width)
            }
        }
        return CGSize(width: width, height: height)
    }
}
