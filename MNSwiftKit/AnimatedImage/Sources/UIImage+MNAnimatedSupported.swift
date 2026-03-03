//
//  UIImage+MNAnimatedSupported.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/27.
//  动态图

import UIKit
import ImageIO
import Foundation
import CoreServices
import CoreFoundation
import UniformTypeIdentifiers

extension MNNameSpaceWrapper where Base: UIImage {
    
    /// 是否是动态图
    public var isAnimatedImage: Bool {
        if let images = base.images, images.count > 1 { return true }
        if base.duration > 0.0 { return true }
        return false
    }
    
    /// 图片数据流
    /// - Parameters:
    ///   - quality: 对于jpg图片的压缩系数
    ///   - pointer: 图片格式
    /// - Returns: 数据流
    public func data(compression quality: CGFloat = 1.0, extension pointer: UnsafeMutablePointer<String>? = nil) -> Data? {
        var format: String?
        var imageData = Data()
        if let images = base.images, images.count > 1, base.duration > 0.0 {
            // GIF
            format = "gif"
            let count = images.count
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
            let delayTime: TimeInterval = base.duration/TimeInterval(count)
            let frameProperties: [CFString:[CFString:Any]] = [kCGImagePropertyGIFDictionary:[kCGImagePropertyGIFDelayTime :delayTime]]
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
        guard count > 1 else { return UIImage(data: imageData) }
        // 时长
        var duration: TimeInterval = 0.0
        var images: [UIImage] = []
        for index in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, options as CFDictionary) else { continue }
            let image = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
            /*
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, options as CFDictionary) else { continue }
            let key = Unmanaged.passRetained(kCGImagePropertyGIFDictionary as NSString).autorelease().toOpaque()
            guard let value = CFDictionaryGetValue(properties, key) else { continue }
            let dic = Unmanaged<NSDictionary>.fromOpaque(value).takeUnretainedValue()
            guard let frameProperties = dic as? [CFString:Any] else { continue }
            */
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, options as CFDictionary) as? [String:Any] else { continue }
            guard let frameProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String:Any] else { continue }
            // 帧持续时间，优先使用 kCGImagePropertyGIFUnclampedDelayTime 来获取动图帧的持续时间，如果这个值不存在，则回退使用 kCGImagePropertyGIFDelayTime。
            // - kCGImagePropertyGIFUnclampedDelayTime: 显示下一帧前等待的秒数，此值可以为 0 毫秒或更高。无下限限制，它返回的是GIF文件中记录的原始、未经修改的值。
            // - kCGImagePropertyGIFDelayTime: 显示下一帧前等待的秒数，会被限制在最小值 100 毫秒。有下限限制，如果GIF文件中记录的原始值小于 100 毫秒 (0.1秒)，Image I/O 会将其强制提升到 0.1 秒。
            // 现代的动图，特别是APNG或某些特殊GIF，可能会设计低于100毫秒的延迟以实现流畅的动画效果 。如果在这种情况下使用 kCGImagePropertyGIFDelayTime，你读取到的时间将是“矫正”后的0.1秒，而不是动画原本设计的更短延迟，这会导致动画播放速度变慢，与设计预期不符。
            // kCGImagePropertyGIFUnclampedDelayTime 的引入正是为了解决这个问题，它允许开发者读取到存储在文件中的原始、未经过任何修改的延迟时间 。这也是像 SDWebImage 这样的知名库在处理动图时采用的标准策略。
            var delayTime: TimeInterval = 0.0
            if let timeInterval = frameProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval, timeInterval > 0.0 {
                delayTime = timeInterval
            } else if let timeInterval = frameProperties[kCGImagePropertyGIFDelayTime as String] as? TimeInterval, timeInterval > 0.0 {
                delayTime = timeInterval
            }
            duration += delayTime
            images.append(image)
        }
        // 生成动态图
        guard images.isEmpty == false else { return UIImage(data: imageData) }
        if images.count == 1 { return images.first }
        return UIImage.animatedImage(with: images, duration: duration)
    }
}
