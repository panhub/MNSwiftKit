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

extension NameSpaceWrapper where Base: UIImage {
    
    /// 是否是动态图
    public var isAnimatedImage: Bool {
        if base.duration > 0.0, let images = base.images, images.count > 1 { return true }
        return false
    }
    
    /// 数据流
    public var data: Data? {
        data()
    }
    
    /// 图片数据流
    /// - Parameters:
    ///   - quality: 对于jpg图片的压缩系数
    ///   - pointer: 图片格式
    /// - Returns: 数据流
    public func data(compression quality: CGFloat = 1.0, extension pointer: UnsafeMutablePointer<String>? = nil) -> Data? {
        var format: String?
        var imageData = Data()
        if let images = base.images, images.count > 1, base.duration > 0.0, isAnimatedImage {
            // GIF
            format = "gif"
            let count = images.count
            let delay: TimeInterval = base.duration/TimeInterval(count)
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
        } else if let pointer = pointer {
            // 以外界图片格式优先
            if pointer.pointee.lowercased() == "png" {
                if let pngData = base.pngData() {
                    // PNG
                    format = "png"
                    imageData.append(pngData)
                } else if let jpegData = base.jpegData(compressionQuality: quality) {
                    // JPEG
                    format = "jpeg"
                    imageData.append(jpegData)
                }
            } else if let jpegData = base.jpegData(compressionQuality: quality) {
                // JPEG
                format = "jpeg"
                imageData.append(jpegData)
            } else if let pngData = base.pngData() {
                // PNG
                format = "png"
                imageData.append(pngData)
            }
        } else if let jpegData = base.jpegData(compressionQuality: quality) {
            // JPEG
            format = "jpeg"
            imageData.append(jpegData)
        } else if let pngData = base.pngData() {
            // PNG
            format = "png"
            imageData.append(pngData)
        }
        //
        guard imageData.isEmpty == false else { return nil }
        if let format = format, let pointer = pointer {
            pointer.pointee = format
        }
        return imageData
    }
    
    /// 获取指定路径的图片
    /// - Parameter filePath: 图片本地路径
    /// - Returns: image对象
    public class func image(contentsAtFile filePath: String!) -> UIImage? {
        guard let filePath = filePath, FileManager.default.fileExists(atPath: filePath) else { return nil }
        var fileURL: URL!
        if #available(iOS 16.0, *) {
            fileURL = URL(filePath: filePath)
        } else {
            fileURL = URL(fileURLWithPath: filePath)
        }
        do {
            let imageData = try Data(contentsOf: fileURL)
            return image(contentsOfData: imageData)
        } catch {
#if DEBUG
            print("转换图片数据流失败: \(filePath)")
#endif
            return nil
        }
    }
    
    /// 将图片数据流转换为image对象
    /// - Parameter imageData: 图片数据流
    /// - Returns: image对象
    public class func image(contentsOfData imageData: Data!) -> UIImage? {
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
