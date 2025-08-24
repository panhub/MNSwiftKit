//
//  UIImage+MNAnimated.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/27.
//  动态图

import UIKit
import Foundation
import ImageIO.ImageIOBase
import CoreServices.UTCoreTypes
import UniformTypeIdentifiers.UTType

extension UIImage {
    
    /// 是否是动态图
    @objc public var isAnimatedImage: Bool {
        NSStringFromClass(Self.self).contains("UIAnimatedImage")
    }
    
    /// 图片=>数据流
    @objc public var contentData: Data? {
        return Data(image: self)
    }
    
    /// 获取指定路径的图片
    /// - Parameter filePath: 图片本地路径
    /// - Returns: image对象
    @objc public class func image(contentsAtFile filePath: String!) -> UIImage? {
        guard let path = filePath, FileManager.default.fileExists(atPath: path) else { return nil }
        return image(contentsOfData: try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    
    /// 将图片数据流转换为image对象
    /// - Parameter imageData: 图片数据流
    /// - Returns: image对象
    @objc public class func image(contentsOfData imageData: Data!) -> UIImage? {
        guard let imageData = imageData, imageData.isEmpty == false else { return nil }
        var identifier: CFString
        if #available(iOS 15.0, *) {
            identifier = UTType.gif.identifier as CFString
        } else {
            identifier = kUTTypeGIF
        }
        let options: [CFString: Any] = [kCGImageSourceShouldCache:kCFBooleanTrue!, kCGImageSourceTypeIdentifierHint:identifier]
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, options as CFDictionary) else { return nil }
        let count = CGImageSourceGetCount(imageSource)
        guard count > 0 else { return nil }
        if count == 1 { return UIImage(data: imageData) }
        // 时长
        var duration: TimeInterval = 0.0
        var images: [UIImage] = [UIImage]()
        for index in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, options as CFDictionary) else { continue }
            let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, options as CFDictionary) else { continue }
            let key = Unmanaged.passRetained(kCGImagePropertyGIFDictionary as NSString).autorelease().toOpaque()
            guard let value = CFDictionaryGetValue(properties, key) else { continue }
            let dic = Unmanaged<NSDictionary>.fromOpaque(value).takeUnretainedValue()
            guard let frameProperties = dic as? [CFString:Any] else { continue }
            var interval: TimeInterval = 0.0
            if let time = frameProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval, time > 0.0 {
                interval = time
            } else if let time = frameProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval, time > 0.0 {
                interval = time
            }
            duration += interval
            images.append(image)
        }
        // 生成动态图
        guard images.isEmpty == false else { return UIImage(data: imageData) }
        if images.count == 1 { return images.first }
        return UIImage.animatedImage(with: images, duration: duration)
    }
}

// MARK: - 获取图片数据流
extension Data {
    
    /// 依据图片实例化Data
    /// - Parameters:
    ///   - image: 图片集合
    ///   - quality: 非动态图时的压缩系数
    ///   - pointer: 回调格式
    public init?(image: UIImage!, compression quality: CGFloat = 0.7, extension pointer: UnsafeMutablePointer<String>? = nil) {
        guard let image = image else { return nil }
        var format: String?
        var imageData: Data = Data()
        if let images = image.images, images.count > 1, image.duration > 0.0, image.isAnimatedImage {
            // GIF
            format = "gif"
            let count = images.count
            let delay: TimeInterval = image.duration/TimeInterval(count)
            let frameProperties: [CFString:[CFString:Any]] = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFDelayTime :delay]]
            var identifier: CFString
            if #available(iOS 15.0, *) {
                identifier = UTType.gif.identifier as CFString
            } else {
                identifier = kUTTypeGIF
            }
            guard let frameData = CFDataCreateMutable(nil, 0) else { return nil }
            guard let destination = CGImageDestinationCreateWithData(frameData, identifier, count, nil) else { return nil }
            let gifProperties: [CFString:[CFString:Any]] = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFLoopCount:0]]
            CGImageDestinationSetProperties(destination, gifProperties as CFDictionary)
            for image in images {
                guard let cgImage = image.cgImage else { continue }
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
            guard CGImageDestinationFinalize(destination) else { return nil }
            imageData.append(frameData as Data)
        } else if let jpegData = image.jpegData(compressionQuality: quality) {
            // JPEG
            format = "jpeg"
            imageData.append(jpegData)
        } else if let pngData = image.pngData() {
            // PNG
            format = "png"
            imageData.append(pngData)
        }
        //
        guard imageData.isEmpty == false else { return nil }
        if let format = format, let pointer = pointer {
            pointer.pointee = format
        }
        let bytes = [UInt8](imageData)
        self.init(bytes: bytes, count: bytes.count)
    }
}
