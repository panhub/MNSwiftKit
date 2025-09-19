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
    
    /// 渲染纯色图片
    /// - Parameters:
    ///   - color: 渲染颜色
    ///   - size: 渲染尺寸
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
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

extension NameSpaceWrapper where Base: UIImage {
    
    /// 灰度图
    public var grayed: UIImage? {
        guard let cgImage = base.cgImage else { return nil }
        let size: CGSize = CGSize(width: base.size.width*base.scale, height: base.size.height*base.scale)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        guard let newImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newImage)
    }
    
    /// 调整方向
    public var resized: UIImage {
        
        guard base.imageOrientation != .up, let cgImage = base.cgImage, let colorSpace = cgImage.colorSpace else { return base }
        
        let size = CGSize(width: base.size.width*base.scale, height: base.size.height*base.scale)
        
        guard let context = CGContext.init(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else { return base }
        
        var transform: CGAffineTransform = .identity
        
        switch base.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.rotated(by: .pi/2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: size.height)
            transform = transform.rotated(by: -.pi/2.0)
        default:
            break
        }
        
        switch base.imageOrientation {
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
        
        switch base.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: size.height, height: size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        }
        
        guard let bitcgImage = context.makeImage() else { return base }
        
        return UIImage(cgImage: bitcgImage)
    }
    
    /// 调整图片颜色
    /// - Parameter color: 渲染颜色
    /// - Returns: 渲染后的图片
    public func rendering(to color: UIColor) -> UIImage! {
        guard let cgImage = base.cgImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(base.size, true, base.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: 0.0, y: base.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect: CGRect = .init(origin: .zero, size: base.size)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 裁剪部分图像
    /// - Parameter rect: 裁剪区域
    /// - Returns: 裁剪后的图片
    public func cropping(to rect: CGRect) -> UIImage! {
        if rect == .zero { return base }
        guard let cgImage = base.cgImage else { return base }
        guard let result = cgImage.cropping(to: CGRect(x: floor(rect.minX)*base.scale, y: floor(rect.minY)*base.scale, width: floor(rect.width)*base.scale, height: floor(rect.height)*base.scale)) else { return nil }
        return UIImage(cgImage: result)
    }
    
    /// 调整图片尺寸
    /// - Parameter dimension: 横纵向最大分辨率
    /// - Returns: 调整后的图片
    public func resizing(to dimension: CGFloat) -> UIImage! {
        var size = CGSize(width: base.size.width*base.scale, height: base.size.height*base.scale)
        guard Swift.max(size.width, size.height) > dimension else { return base }
        if size.width >= size.height {
            size.height = dimension/size.width*size.height
            size.width = dimension
        } else {
            size.width = dimension/size.height*size.width
            size.height = dimension
        }
        return resizing(to: size)
    }
    
    /// 调整图片尺寸
    /// - Parameter size: 指定渲染尺寸
    /// - Returns: 调整后的图片
    public func resizing(to size: CGSize) -> UIImage! {
        let targetSize = CGSize(width: floor(size.width), height: floor(size.height))
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
        base.draw(in: .init(origin: .zero, size: targetSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 调整图片至大约内存大小
    /// - Parameter:
    ///   - bytes: 字节数
    ///   - attempts: 最大尝试次数
    /// - Returns: 调整后的图片
    public func compress(to bytes: Int, attempts: Int = 10) -> UIImage! {
        var compression: CGFloat = 1.0
        let imageData = base.jpegData(compressionQuality: compression)
        guard var compressedData = imageData else { return nil }
        // 如果原始图片已经小于目标大小，直接返回
        if compressedData.count <= bytes { return base }
        // 二分法压缩
        var count: Int = 0
        var minCompression: CGFloat = 0.0
        var maxCompression: CGFloat = 1.0
        while count < attempts, compressedData.count > bytes {
            count += 1
            compression = (maxCompression + minCompression)/2.0
            guard let newData = base.jpegData(compressionQuality: compression) else { break }
            compressedData = newData
            if newData.count > bytes {
                maxCompression = compression
            } else {
                minCompression = compression
            }
        }
        return UIImage(data: compressedData, scale: base.scale)
    }
}

extension NameSpaceWrapper where Base: UIImage {
    
    /// 将图片写入本地
    /// - Parameter filePath: 本地路径
    /// - Returns: 是否写入成功
    public func write(toFile filePath: String) -> Bool {
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
    public func write(to url: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        } catch {
#if DEBUG
            print(error)
#endif
            return false
        }
        guard let imageData = data else { return false }
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
    /// - Parameters:
    ///   - quality: 对于jpg封装格式的压缩参数
    ///   - referencePath: 参考路径
    /// - Returns: 图片路径
    public func writeToFile(compression quality: CGFloat = 1.0, referencePath: String) -> String? {
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
        guard let imageData = data(compression: quality, extension: &format) else { return nil }
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
