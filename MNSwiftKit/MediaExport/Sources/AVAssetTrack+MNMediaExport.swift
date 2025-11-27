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
    
    /// 轨道转换设置
    public var preferredTransform: CGAffineTransform {
        if #available(iOS 16.0, *) {
            var transform: CGAffineTransform = .identity
            Task {
                do {
                    transform = try await base.load(.preferredTransform)
                } catch {
#if DEBUG
                    print("获取轨道转换设置出错: \(error)")
#endif
                }
            }
            return transform
        }
        return base.preferredTransform
    }
    
    /// 该轨道所引用的媒体数据的原始尺寸(视频轨道有效)
    public var naturalSize: CGSize {
        var naturalSize: CGSize = .zero
        if #available(iOS 16.0, *) {
            Task {
                do {
                    naturalSize = try await base.load(.naturalSize)
                } catch {
#if DEBUG
                    print("获取媒体数据的原始尺寸出错: \(error)")
#endif
                }
            }
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
            Task {
                do {
                    let value = try await base.load(.nominalFrameRate)
                    frameRate = CGFloat(value)
                } catch {
#if DEBUG
                    print("获取轨道帧率出错: \(error)")
#endif
                }
            }
            return frameRate
        }
        return CGFloat(base.nominalFrameRate)
    }
    
    public func transform(for cropRect: CGRect, renderSize: CGSize? = nil) -> CGAffineTransform {
        
        let preferredTransform = preferredTransform
        let inverseTransform = preferredTransform.inverted()
        // 将显示坐标的矩形四个角映射回未旋转的 track 坐标
        let topLeft = CGPoint(x: cropRect.minX, y: cropRect.minY).applying(inverseTransform)
        let bottomRight = CGPoint(x: cropRect.maxX, y: cropRect.maxY).applying(inverseTransform)
        let trackRect = CGRect(x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y)
        
        var transform = preferredTransform.concatenating(.init(translationX: -trackRect.minX, y: -trackRect.minY))
        if let renderSize = renderSize, renderSize.width > 0.0, renderSize.height > 0.0 {
            //
            let scaleX = renderSize.width/trackRect.width
            let scaleY = renderSize.height/trackRect.height
            transform = transform.concatenating(.init(translationX: scaleX, y: scaleY))
        }
        
        return transform
    }
}
