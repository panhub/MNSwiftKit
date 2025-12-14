//
//  AVAssetTrack+MNMediaExport.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/30.
//

import Foundation
import AVFoundation
import CoreFoundation

extension MNNameSpaceWrapper where Base: AVAssetTrack {
    
    /// 视频轨道原始形变
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
    
    /// 视频轨道原始渲染尺寸
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
        let preferredTransform = preferredTransform
        /*
        let transformedSize = naturalSize.applying(preferredTransform)
        let width = abs(transformedSize.width)
        let height = abs(transformedSize.height)
        return .init(width: width, height: height)
        */
        let transformedRect = CGRect(origin: .zero, size: naturalSize).applying(preferredTransform).standardized
        return transformedRect.size
    }
    
    /// 轨道帧率
    public var nominalFrameRate: Float {
        if #available(iOS 16.0, *) {
            var frameRate: Float = 0.0
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    frameRate = try await base.load(.nominalFrameRate)
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
        return base.nominalFrameRate
    }
    
    /// 最小帧率持续时间
    public var minFrameDuration: CMTime {
        if #available(iOS 16.0, *) {
            var time: CMTime = .invalid
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    time = try await base.load(.minFrameDuration)
                } catch {
#if DEBUG
                    print("获取轨道最小帧率持续时间出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
            return time
        }
        return base.minFrameDuration
    }
    
    /// 预估比特率
    public var estimatedDataRate: Float {
        if #available(iOS 16.0, *) {
            var bitrate: Float = 0.0
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    bitrate = try await base.load(.estimatedDataRate)
                } catch {
#if DEBUG
                    print("获取轨道预估比特率出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
            return bitrate
        }
        return base.estimatedDataRate
    }
    
    /// 格式说明
    public var formatDescriptions: [Any] {
        if #available(iOS 16.0, *) {
            var descriptions: [Any] = []
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    descriptions = try await base.load(.formatDescriptions)
                } catch {
#if DEBUG
                    print("获取轨道格式说明出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
            return descriptions
        }
        return base.formatDescriptions
    }
    
    /// 获取视频轨道形变
    /// - Parameters:
    ///   - cropRect: 裁剪区域
    ///   - renderSize: 渲染尺寸
    /// - Returns: 视频轨道形变
    public func transform(for cropRect: CGRect, renderSize: CGSize? = nil) -> CGAffineTransform {
        let preferredTransform = preferredTransform
        var transform = preferredTransform.concatenating(.init(translationX: -cropRect.minX, y: -cropRect.minY))
        if let renderSize = renderSize, renderSize.width > 0.0, renderSize.height > 0.0 {
            let scaleX = renderSize.width/cropRect.width
            let scaleY = renderSize.height/cropRect.height
            transform = transform.concatenating(.init(scaleX: scaleX, y: scaleY))
        }
        return transform
    }
}
