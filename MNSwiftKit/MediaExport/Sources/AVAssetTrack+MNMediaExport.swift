//
//  AVAssetTrack+MNMediaExport.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/30.
//

import Foundation
import AVFoundation
import CoreFoundation

extension NameSpaceWrapper where Base: AVAssetTrack {
    
    /// 轨道原始形变
    public var preferredTransform: CGAffineTransform {
        if #available(iOS 16.0, *) {
            var transform: CGAffineTransform = .identity
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    transform = try await base.load(.preferredTransform)
                } catch {
#if DEBUG
                    print("获取轨道转换设置出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
            return transform
        }
        return base.preferredTransform
    }
    
    /// 视频轨道原始尺寸
    public var naturalSize: CGSize {
        var naturalSize: CGSize = .zero
        if #available(iOS 16.0, *) {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    naturalSize = try await base.load(.naturalSize)
                } catch {
#if DEBUG
                    print("获取媒体数据的原始尺寸出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
        } else {
            naturalSize = base.naturalSize
        }
        let transform = preferredTransform
        let transformedSize = naturalSize.applying(transform)
        let width = abs(transformedSize.width)
        let height = abs(transformedSize.height)
        return .init(width: width, height: height)
    }
    
    /// 轨道帧率
    public var nominalFrameRate: CGFloat {
        if #available(iOS 16.0, *) {
            var frameRate: CGFloat = 0.0
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    let value = try await base.load(.nominalFrameRate)
                    frameRate = CGFloat(value)
                } catch {
#if DEBUG
                    print("获取轨道帧率出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
            return frameRate
        }
        return CGFloat(base.nominalFrameRate)
    }
    
    /// 获取视频轨道形变
    /// - Parameters:
    ///   - cropRect: 裁剪区域
    ///   - renderSize: 渲染尺寸
    /// - Returns: 视频轨道形变
    public func transform(for cropRect: CGRect, renderSize: CGSize? = nil) -> CGAffineTransform {
        var trackCropRect: CGRect
        let preferredTransform = preferredTransform
        if preferredTransform == .identity {
            // 没有 preferredTransform，直接使用原坐标
            trackCropRect = cropRect
        } else {
            // 有 preferredTransform，需要转换回轨道坐标
            let inverseTransform = preferredTransform.inverted()
            // 将裁剪矩形的四个角转换回轨道坐标
            let topLeft = CGPoint(x: cropRect.minX, y: cropRect.minY).applying(inverseTransform)
            let topRight = CGPoint(x: cropRect.maxX, y: cropRect.minY).applying(inverseTransform)
            let bottomLeft = CGPoint(x: cropRect.minX, y: cropRect.maxY).applying(inverseTransform)
            let bottomRight = CGPoint(x: cropRect.maxX, y: cropRect.maxY).applying(inverseTransform)
            // 计算转换后的边界矩形
            let minX = Swift.min(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x)
            let maxX = Swift.max(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x)
            let minY = Swift.min(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y)
            let maxY = Swift.max(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y)
            trackCropRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }
        // 构建 transform：先应用 preferredTransform，再平移，再缩放
        var transform = preferredTransform
        // 平移：将裁剪区域移动到左上角
        transform = transform.concatenating(
            CGAffineTransform(translationX: -trackCropRect.origin.x, y: -trackCropRect.origin.y)
        )
        // 缩放：将裁剪区域缩放到输出尺寸
        if let renderSize = renderSize, renderSize.width > 0.0, renderSize.height > 0.0 {
            let scaleX = renderSize.width/trackCropRect.width
            let scaleY = renderSize.height/trackCropRect.height
            transform = transform.concatenating(
                CGAffineTransform(scaleX: scaleX, y: scaleY)
            )
        }
//        if preferredTransform == .identity {
//            print("")
//        }
//        let inverseTransform = preferredTransform.inverted()
//        // 将显示坐标的矩形四个角映射回未旋转的 track 坐标
//        let topLeft = CGPoint(x: cropRect.minX, y: cropRect.minY).applying(inverseTransform)
//        let bottomRight = CGPoint(x: cropRect.maxX, y: cropRect.maxY).applying(inverseTransform)
//        let trackRect = CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
//        var transform = preferredTransform.concatenating(.init(translationX: -trackRect.minX, y: -trackRect.minY))
//        if let renderSize = renderSize, renderSize.width > 0.0, renderSize.height > 0.0 {
//            //
//            let scaleX = renderSize.width/trackRect.width
//            let scaleY = renderSize.height/trackRect.height
//            transform = transform.concatenating(.init(translationX: scaleX, y: scaleY))
//        }
        return transform
    }
}
