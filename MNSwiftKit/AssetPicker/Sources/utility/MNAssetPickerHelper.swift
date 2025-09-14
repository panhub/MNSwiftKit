//
//  UIImage+MNAssetExport.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/29.
//  辅助工具

import UIKit
import Foundation
import CoreGraphics

extension UIViewController {
    
    class mn_picker {}
}

extension UIViewController.mn_picker {
    
    /// 获取当前控制器
    class var current: UIViewController? {
        var viewController = UIApplication.shared.delegate?.window??.rootViewController
        while let vc = viewController {
            if let presented = vc.presentedViewController {
                viewController = presented
            } else if let navigationController = vc as? UINavigationController {
                viewController = navigationController.viewControllers.last
            } else if let tabBarController = vc as? UITabBarController {
                viewController = tabBarController.selectedViewController
            } else { break }
        }
        return viewController
    }
}

extension UIViewController {
    
    class MNPickingWrapper {
        
        fileprivate let controller: UIViewController
        
        fileprivate init(controller: UIViewController) {
            self.controller = controller
        }
    }
    
    /// 包装器
    var `mn_picker`: MNPickingWrapper { MNPickingWrapper(controller: self) }
}

extension UIViewController.MNPickingWrapper {
    
    /// 依据情况出栈或模态弹出
    /// - Parameters:
    ///   - animated: 是否动态显示
    ///   - completionHandler: 结束回调(对模态弹出有效)
    func pop(animated: Bool = true, completion completionHandler: (()->Void)? = nil) {
        if let nav = controller.navigationController {
            if nav.viewControllers.count > 1 {
                nav.popViewController(animated: animated)
                if let completionHandler = completionHandler {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: completionHandler)
                }
            } else if let _ = nav.presentingViewController {
                nav.dismiss(animated: animated, completion: completionHandler)
            }
        } else if let _ = controller.presentingViewController {
            controller.dismiss(animated: animated, completion: completionHandler)
        }
    }
}

extension DateFormatter {
    
    class mn_picker {
        
        /// 时间格式
        fileprivate static let time: DateFormatter = {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "mm:ss"
            return formatter
        }()
    }
}

extension Date {
    
    class MNPickingWrapper {
        
        fileprivate let date: Date
        
        fileprivate init(date: Date) {
            self.date = date
        }
    }
    
    /// 包装器
    var mn_picker: MNPickingWrapper { MNPickingWrapper(date: self) }
}

extension Date.MNPickingWrapper {
    
    /// 时间格式
    var timeString: String {
        let formatter: DateFormatter = .mn_picker.time
        if date.timeIntervalSince1970 >= 3600.0 {
            formatter.dateFormat = "H:mm:ss"
        } else {
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date)
    }
}

extension URL {
    
    class MNPickingWrapper {
        
        fileprivate let url: URL
        
        fileprivate init(url: URL) {
            self.url = url
        }
    }
    
    /// 包装器
    var mn_picker: MNPickingWrapper { MNPickingWrapper(url: self) }
    
    init(picker_fileAtPath filePath: String) {
        if #available(iOS 16.0, *) {
            self.init(filePath: filePath)
        } else {
            self.init(fileURLWithPath: filePath)
        }
    }
}

extension URL.MNPickingWrapper {
    
    /// 路径
    var path: String {
        if #available(iOS 16.0, *) {
            return url.path(percentEncoded: false)
        } else {
            return url.path
        }
    }
}

extension UIImage {
    
    class MNPickingWrapper {
        
        fileprivate let image: UIImage
        
        fileprivate init(image: UIImage) {
            self.image = image
        }
    }
    
    /// 包装器
    var mn_picker: MNPickingWrapper { MNPickingWrapper(image: self) }
    
    /// 渲染纯色图片
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 尺寸
    convenience init?(picker_color color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = image, let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIImage.MNPickingWrapper {
    
    /// 灰度图片
    var grayed: UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let size: CGSize = CGSize(width: image.size.width*image.scale, height: image.size.height*image.scale)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        guard let newImage = context.makeImage() else { return nil }
        return UIImage(cgImage: newImage)
    }
    
    /// 调整方向
    var resized: UIImage {
        
        guard image.imageOrientation != .up, let cgImage = image.cgImage, let colorSpace = cgImage.colorSpace else { return image }
        
        guard let context = CGContext.init(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else { return image }
        
        var transform: CGAffineTransform = .identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0.0)
            transform = transform.rotated(by: .pi/2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: image.size.height)
            transform = transform.rotated(by: -.pi/2.0)
        default:
            break
        }
        
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        default:
            break
        }
    
        context.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: image.size.height, height: image.size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height))
        }
        
        guard let bitcgImage = context.makeImage() else { return image }
        
        return UIImage(cgImage: bitcgImage)
    }
    
    /// 调整图片尺寸
    /// - Parameter pix: 最大像素
    /// - Returns: 调整后的图片
    func resizing(toMax pix: CGFloat) -> UIImage! {
        var size = CGSize(width: image.size.width*image.scale, height: image.size.height*image.scale)
        guard max(size.width, size.height) > pix else { return image }
        if size.width >= size.height {
            size.height = pix/size.width*size.height
            size.width = pix
        } else {
            size.width = pix/size.height*size.width
            size.height = pix
        }
        return resizing(toSize: size)
    }
    
    /// 调整图片尺寸
    /// - Parameter size: 指定尺寸
    /// - Returns: 调整后的图片
    func resizing(toSize size: CGSize) -> UIImage! {
        let targetSize = CGSize(width: floor(size.width), height: floor(size.height))
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: .init(origin: .zero, size: targetSize))
        let currentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return currentImage
    }
    
    /// 渲染颜色
    /// - Parameter color: 指定颜色
    /// - Returns: 渲染后的图片
    func renderBy(color: UIColor) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: 0.0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)
        let currentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return currentImage
    }
    
    /// 近似微信朋友圈图片压缩 (以1280为界以 0.6为压缩系数)
    /// - Parameters:
    ///   - pixel: 像素阀值
    ///   - quality: 压缩系数
    ///   - pointer: 图片大小
    /// - Returns: (压缩后图片, 图片质量)
    func compress(pixel: CGFloat = 1280.0, quality: CGFloat, fileSize pointer: UnsafeMutablePointer<Int64>? = nil) -> UIImage? {
        guard pixel > 0.0, quality > 0.01 else { return nil }
        // 调整尺寸
        var width: CGFloat = image.size.width*image.scale
        var height: CGFloat = image.size.height*image.scale
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
        image.draw(in: CGRect(x: 0.0, y: 0.0, width: width, height: height))
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
}

extension CALayer {
    
    class MNPickingWrapper {
        
        fileprivate let layer: CALayer
        
        fileprivate init(layer: CALayer) {
            self.layer = layer
        }
    }
    
    /// 包装器
    var mn_picker: MNPickingWrapper { MNPickingWrapper(layer: self) }
}

extension CALayer.MNPickingWrapper {
    
    /// 设置圆角效果
    /// - Parameters:
    ///   - radius: 圆角大小
    ///   - corners: 圆角位置
    func setRadius(_ radius: CGFloat, by corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: layer.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    /// 截图
    var snapshot: UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: layer.bounds)
            return renderer.image { context in
                layer.render(in: context.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(layer.bounds.size, false, layer.contentsScale)
            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
    }
}

extension UIWindow {
    
    class mn_picker {}
}

extension UIWindow.mn_picker {
    
    class var current: UIWindow? {
        if #available(iOS 15.0, *) {
            return current(in: UIApplication.shared.delegate?.window??.windowScene?.windows.reversed())
        } else {
            return current(in: UIApplication.shared.windows.reversed())
        }
    }
    
    private class func current(in windows: [UIWindow]?) -> UIWindow? {
        guard let windows = windows else { return nil }
        for window in windows {
            let isOnMainScreen = window.screen == UIScreen.main
            let isVisible = (window.isHidden == false && window.alpha > 0.01)
            if isOnMainScreen, isVisible, window.isKeyWindow {
                return window
            }
        }
        return nil
    }
}

extension UIView {
    
    class MNPickingWrapper {
        
        fileprivate let view: UIView
        
        fileprivate init(view: UIView) {
            self.view = view
        }
    }
    
    /// 包装器
    var `mn_picker`: MNPickingWrapper { MNPickingWrapper(view: self) }
}

extension UIView.MNPickingWrapper {
    
    func sizeFitToWidth() {
        if view is UIImageView {
            let imageView = view as! UIImageView
            guard let image = imageView.image ?? imageView.highlightedImage else { return }
            guard image.size.width > 0.0 else { return }
            var frame = imageView.frame
            frame.size.height = ceil(image.size.height/image.size.width*frame.width)
            imageView.frame = frame
        } else if view is UIButton {
            let button = view as! UIButton
            guard let image = button.currentBackgroundImage ?? button.currentImage else { return }
            guard image.size.width > 0.0 else { return }
            var frame = button.frame
            frame.size.height = ceil(image.size.height/image.size.width*frame.width)
            button.frame = frame
        }
    }
    
    func sizeFitToHeight() {
        if view is UIImageView {
            let imageView = view as! UIImageView
            guard let image = imageView.image ?? imageView.highlightedImage else { return }
            guard image.size.height > 0.0 else { return }
            var frame = imageView.frame
            frame.size.width = ceil(image.size.width/image.size.height*frame.height)
            imageView.frame = frame
        } else if view is UIButton {
            let button = view as! UIButton
            guard let image = button.currentBackgroundImage ?? button.currentImage else { return }
            guard image.size.height > 0.0 else { return }
            var frame = button.frame
            frame.size.width = ceil(image.size.width/image.size.height*frame.height)
            button.frame = frame
        }
    }
}

extension CGSize {
    
    class MNPickingWrapper {
        
        fileprivate let size: CGSize
        
        fileprivate init(size: CGSize) {
            self.size = size
        }
    }
    
    /// 包装器
    var mn_picker: MNPickingWrapper { MNPickingWrapper(size: self) }
}

extension CGSize.MNPickingWrapper {
    
    var isEmpty: Bool {
        return (size.width.isNaN || size.height.isNaN || size.width <= 0.0 || size.height <= 0.0)
    }
    
    func multiplyTo(width: CGFloat) -> CGSize {
        guard isEmpty == false else { return .zero }
        return CGSize(width: width, height: width/size.width*size.height)
    }
    
    func multiplyTo(height: CGFloat) -> CGSize {
        guard isEmpty == false else { return .zero }
        return CGSize(width: height/size.height*size.width, height: height)
    }
    
    func multiplyTo(min: CGFloat) -> CGSize {
        guard isEmpty == false else { return .zero }
        return size.width <= size.height ? multiplyTo(width: min) : multiplyTo(height: min)
    }
    
    func multiplyTo(max: CGFloat) -> CGSize {
        guard isEmpty == false else { return .zero }
        return size.width >= size.height ? multiplyTo(width: max) : multiplyTo(height: max)
    }
    
    /// 适应尺寸
    /// - Parameters:
    ///   - target: 目标尺寸
    /// - Returns: 依据比例适应的结果
    func scaleFit(toSize target: CGSize) -> CGSize {
        let targetSize = CGSize(width: floor(target.width), height: floor(target.height))
        guard min(targetSize.width, targetSize.height) > 0.0, min(size.width, size.height) > 0.0 else { return targetSize }
        var width: Double = 0.0
        var height: Double = 0.0
        if targetSize.height >= targetSize.width {
            // 竖屏/方形
            width = targetSize.width
            height = size.height/size.width*width
            if height.isNaN || height < 1.0 {
                height = 1.0
            } else if height > targetSize.height {
                height = targetSize.height
                width = size.width/size.height*height
                if (width.isNaN || width < 1.0) { width = 1.0 }
                width = floor(width)
            } else {
                height = floor(height)
            }
        } else {
            // 横屏
            height = targetSize.height
            width = size.width/size.height*height
            if width.isNaN || width < 1.0 {
                width = 1.0
            } else if width > targetSize.width {
                width = targetSize.width
                height = size.height/size.width*width
                if height.isNaN || height < 1.0 { height = 1.0 }
                height = floor(height)
            } else {
                width = floor(width)
            }
        }
        return CGSize(width: width, height: height)
    }
}

extension Int64 {
    
    class MNPickingWrapper {
        
        fileprivate let bytes: Int64
        
        fileprivate init(bytes: Int64) {
            self.bytes = bytes
        }
    }
    
    /// 包装器
    var mn_picker: MNPickingWrapper { MNPickingWrapper(bytes: self) }
}

extension Int64.MNPickingWrapper {
    
    /// 文件大小格式化
    var fileSizeString: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.isAdaptive = true
        formatter.includesUnit = true
        formatter.allowedUnits = [.useAll]
        return formatter.string(fromByteCount: bytes)
    }
}
