//
//  UIImage+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/15.
//  UIImage扩展

import UIKit
import Foundation
import QuartzCore
import CoreGraphics

extension UIImage {
    
    /// 灰度图片
    @objc public var grayed: UIImage? {
        guard let cgImage = cgImage else { return nil }
        let size: CGSize = CGSize(width: size.width*scale, height: size.height*scale)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        guard let newImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newImage)
    }
    
    /**调整方向*/
    @objc public var resizedOrientation: UIImage {
        
        guard imageOrientation != .up, let cgImage = cgImage, let colorSpace = cgImage.colorSpace else { return self }
        
        guard let context = CGContext.init(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else { return self }
        
        var transform: CGAffineTransform = .identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.rotated(by: CGFloat(Double.pi/2.0))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: size.height)
            transform = transform.rotated(by: -CGFloat(Double.pi/2.0))
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        default:
            break
        }
    
        context.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: size.height, height: size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        }
        
        guard let bitcgImage = context.makeImage() else { return self }
        
        return UIImage(cgImage: bitcgImage)
    }
    
    // MARK: - 裁剪部分图像
    @objc public func crop(rect: CGRect) -> UIImage! {
        if rect == .zero { return self }
        guard let cgImage = cgImage?.cropping(to: CGRect(x: floor(rect.minX)*scale, y: floor(rect.minY)*scale, width: floor(rect.width)*scale, height: floor(rect.height)*scale)) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - 调整图片尺寸
    @objc public func resizing(toMax pix: CGFloat) -> UIImage! {
        var size = CGSize(width: size.width*scale, height: size.height*scale)
        guard max(size.width, size.height) > pix else { return self }
        if size.width >= size.height {
            size.height = pix/size.width*size.height
            size.width = pix
        } else {
            size.width = pix/size.height*size.width
            size.height = pix
        }
        return resizing(toSize: size)
    }
    
    @objc public func resizing(toSize size: CGSize) -> UIImage! {
        let targetSize = CGSize(width: floor(size.width), height: floor(size.height))
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        draw(in: CGRect(x: 0.0, y: 0.0, width: targetSize.width, height: targetSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // 压缩至指定质量(约值) 失败则返回原图
    @objc public func resizing(toQuality bytes: Int) -> UIImage {
        let min: CGFloat = 0.1
        let max: CGFloat = 0.9
        var data: Data?
        var last: CGFloat = max
        var quality: CGFloat = 0.6
        repeat {
            guard quality >= min, quality <= max else { break }
            guard let imageData = jpegData(compressionQuality: quality) else { break }
            data = imageData
            let count: Int = imageData.count
            guard fabs(Double(count - bytes)) > 1000.0 else { break }
            if count > bytes {
                last = quality
                quality = (quality - min)/2.0 + min
            } else {
                quality = (last - quality)/2.0 + quality
            }
        } while (true)
        guard let imageData = data else { return self }
        return UIImage(data: imageData) ?? self
    }
    
    @objc public func renderBy(color: UIColor) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: 0.0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 渲染纯色图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 尺寸
    @objc public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

// MARK: - 图片处理
extension UIImage {
    
    /// 近似微信朋友圈图片压缩 (以1280为界以 0.6为压缩系数)
    /// - Parameters:
    ///   - pixel: 像素阀值
    ///   - quality: 压缩系数
    ///   - pointer: 图片大小
    /// - Returns: (压缩后图片, 图片质量)
    @objc public func compress(pixel: CGFloat = 1280.0, quality: CGFloat, fileSize pointer: UnsafeMutablePointer<Int64>? = nil) -> UIImage? {
        guard pixel > 0.0, quality > 0.01 else { return nil }
        // 调整尺寸
        var width: CGFloat = size.width*scale
        var height: CGFloat = size.height*scale
        guard width > 0.0, height > 0.0 else { return nil }
        let boundary: CGFloat = pixel
        let isSquare: Bool = width == height
        if width > boundary || height > boundary {
            if max(width, height)/min(width, height) <= 2.0 {
                let ratio: CGFloat = boundary/max(width, height)
                if width >= height {
                    width = boundary
                    height = height*ratio
                } else {
                    height = boundary
                    width = width*ratio
                }
            } else if min(width, height) > boundary {
                let ratio: CGFloat = boundary/min(width, height)
                if width <= height {
                    width = boundary
                    height = height*ratio
                } else {
                    height = boundary
                    width = width*ratio
                }
            }
            width = ceil(width)
            height = ceil(height)
            if isSquare {
                width = min(width, height)
                height = width
            }
        }
        // 缩图片
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        draw(in: CGRect(x: 0.0, y: 0.0, width: width, height: height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // 压图片
        if let imageData = result?.jpegData(compressionQuality: quality), let image = UIImage(data: imageData) {
            if let pointer = pointer {
                pointer.pointee = Int64(imageData.count)
            }
            return image
        }
        return nil
    }
    
    /**近似微信朋友圈图片压缩(以1280为界以0.6为压缩系数)*/
    @objc public func compress(quality: CGFloat) -> UIImage? {
        compress(pixel: 1280.0, quality: quality)
    }
}

extension UIImage {
    
    /// 将图片写入本地
    /// - Parameter filePath: 本地路径
    /// - Returns: 是否写入成功
    @objc public func write(toFile filePath: String) -> Bool {
        let url: URL?
        if #available(iOS 16.0, *) {
            url = URL(filePath: filePath)
        } else {
            url = URL(fileURLWithPath: filePath)
        }
        guard let url = url else { return false }
        return write(to: url)
    }
    
    /// 写入图片
    /// - Parameter url: 本地绝对路径
    /// - Returns: 是否写入成功
    @objc public func write(to url: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        } catch {
#if DEBUG
            print(error)
#endif
            return false
        }
        guard let imageData = Data(image: self) else { return false }
        do {
            try imageData.write(to: url)
        } catch {
#if DEBUG
            print(error)
#endif
            return false
        }
        return true
    }
    
    /// 写入图片
    /// - Parameter referencePath: 参考路径
    /// - Returns: 图片路径
    @objc public func writeToFile(referencePath: String) -> String? {
        let url: URL?
        if #available(iOS 16.0, *) {
            url = URL(filePath: referencePath)
        } else {
            url = URL(fileURLWithPath: referencePath)
        }
        guard let url = url else { return nil }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        } catch {
#if DEBUG
            print(error)
#endif
            return nil
        }
        var format: String = url.pathExtension.lowercased()
        guard let imageData = Data(image: self, extension: &format) else { return nil }
        let fileUrl: URL = format == url.pathExtension.lowercased() ? url : url.deletingPathExtension().appendingPathExtension(format)
        do {
            try imageData.write(to: fileUrl)
        } catch {
#if DEBUG
            print(error)
#endif
            return nil
        }
        if #available(iOS 16.0, *) {
            return fileUrl.path()
        }
        return fileUrl.path
    }
}
