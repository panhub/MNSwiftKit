//
//  MNQRCode.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/3/30.
//  二维码

import UIKit
import CoreImage
import Foundation
import CoreFoundation

/// 二维码
public class MNQRCode {
    
    /// 纠错等级
    public enum CorrectionLevel: String {
        /// 低 7%
        case low = "L"
        /// 中 15%
        case medium = "M"
        /// 较高 25%
        case quartile = "Q"
        /// 高 30%
        case higt = "H"
    }
    
    /// 生成二维码图片
    /// - Parameters:
    ///   - content: 存放的内容
    ///   - level: 纠错等级
    ///   - size: 图片尺寸
    ///   - color1: 背景色
    ///   - color0: 前景色
    /// - Returns: 二维码
    public class func generate(with content: String, level: CorrectionLevel, size: CGSize = .init(width: 300.0, height: 300.0), background color1: UIColor = .white, foreground color0: UIColor = .black) -> UIImage? {
        guard let baseImage = base(content: content, level: level) else { return nil }
        guard let appliedImage = apply(image: baseImage, background: color1, foreground: color0) else { return nil }
        let ciImage = scale(image: appliedImage, to: size)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    private class func base(content: String, level: CorrectionLevel) -> CIImage? {
        guard let data = content.data(using: .utf8) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(level.rawValue, forKey: "inputCorrectionLevel")
        return filter.outputImage
    }
    
    private class func apply(image: CIImage, background color1: UIColor, foreground color0: UIColor) -> CIImage? {
        guard let filter = CIFilter(name: "CIFalseColor") else { return nil }
        filter.setValue(image, forKey: "inputImage")
        filter.setValue(CIColor(color: color0), forKey: "inputColor0")
        filter.setValue(CIColor(color: color1), forKey: "inputColor1")
        return filter.outputImage
    }
    
    private class func scale(image: CIImage, to size: CGSize) -> CIImage {
        let scaleX = size.width/image.extent.size.width
        let scaleY = size.height/image.extent.size.height
        return image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
}
