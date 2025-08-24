//
//  QRCode.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/3/30.
//  二维码

import UIKit
import Foundation
import CoreImage
import CoreGraphics

/// 二维码
class QRCode {
    
    private(set) var image: UIImage
    
    /// 构造二维码模型
    /// - Parameter image: 二维码图片
    init(image: UIImage) {
        self.image = image
    }
    
    /// 构造二维码模型
    /// - Parameters:
    ///   - metadata: 元数据
    ///   - pixel: 像素
    convenience init?(metadata: Data, pixel: Int) {
        guard pixel > 0 else { return nil }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator", parameters: nil) else { return nil }
        filter.setDefaults()
        filter.setValue(metadata, forKey: "inputMessage")
        guard let outputImage = filter.outputImage else { return nil }
        
        let extent = outputImage.extent.integral
        guard let context = CGContext(data: nil, width: pixel, height: pixel, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        guard let cgimage = CIContext().createCGImage(outputImage, from: extent) else { return nil }
        context.interpolationQuality = .none
        context.scaleBy(x: CGFloat(pixel)/extent.width, y: CGFloat(pixel)/extent.height)
        context.draw(cgimage, in: extent)
        guard let cgImage = context.makeImage() else { return nil }
        self.init(image: UIImage(cgImage: cgImage))
    }
}
