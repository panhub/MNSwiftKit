//
//  AVURLAsset+MNMediaExport.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/30.
//

import UIKit
import Dispatch
import Foundation
import AVFoundation

extension AVURLAsset {
    
    /// 构造媒体资源
    /// - Parameter path: 文件路径或远程链接
    public convenience init?(for string: String) {
        var isDirectory: ObjCBool = true
        if FileManager.default.fileExists(atPath: string, isDirectory: &isDirectory) {
            // 本地路径
            guard isDirectory.boolValue == false else { return nil }
            if #available(iOS 16.0, *) {
                self.init(for: URL(filePath: string))
            } else {
                self.init(for: URL(fileURLWithPath: string))
            }
        } else if let url = URL(string: string) {
            self.init(for: url)
        } else {
            return nil
        }
    }
    
    /// 构造媒体资源
    /// - Parameter url: 资源定位器
    public convenience init(for url: URL) {
        self.init(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: url.isFileURL])
    }
}

extension NameSpaceWrapper where Base: AVAsset {
    
    /// 媒体资源时长(CMTime)
    public var duration: CMTime {
        if #available(iOS 16.0, *) {
            var duration: CMTime = .zero
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    duration = try await base.load(.duration)
                } catch {
#if DEBUG
                    print("获取媒体资源时长出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
            return duration
        }
        return base.duration
    }
    
    /// 媒体资源时长(秒)
    public var seconds: TimeInterval {
        TimeInterval(CMTimeGetSeconds(duration))
    }
    
    
    /// 获取媒体资源轨道
    /// - Parameter mediaType: 媒体类型
    /// - Returns: 找寻到的轨道
    public func track(with mediaType: AVMediaType) -> AVAssetTrack? {
        if #available(iOS 16.0, *) {
            var track: AVAssetTrack?
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    track = try await base.loadTracks(withMediaType: mediaType).first
                } catch {
#if DEBUG
                    print("获取媒体资源轨迹出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
            return track
        }
        let tracks = base.tracks(withMediaType: mediaType)
        return tracks.first
    }
    
    
    /// 获取时间片段
    /// - Parameters:
    ///   - from: 起始进度值
    ///   - to: 结束进度值
    /// - Returns: 时间片段
    public func timeRange(withProgress from: any BinaryFloatingPoint, to: any BinaryFloatingPoint) -> CMTimeRange {
        let seconds = seconds
        let fromSeconds = seconds*Double(from)
        let toSeconds = seconds*Double(to)
        return timeRange(from: fromSeconds, to: toSeconds)
    }
    
    /// 获取时间片段
    /// - Parameters:
    ///   - from: 起始秒数
    ///   - to: 结束秒数
    /// - Returns: 时间片段
    public func timeRange(from: any BinaryFloatingPoint, to: any BinaryFloatingPoint) -> CMTimeRange {
        let duration = duration
        let seconds = CMTimeGetSeconds(duration)
        let fromSeconds = Float64(from)
        let toSeconds = Float64(to)
        guard fromSeconds >= 0.0, toSeconds <= seconds, toSeconds > fromSeconds else { return .zero }
        return CMTimeRangeFromTimeToTime(start: CMTime(seconds: fromSeconds, preferredTimescale: duration.timescale), end: CMTime(seconds: toSeconds, preferredTimescale: duration.timescale))
    }
}

extension NameSpaceWrapper where Base: AVAsset {
    
    
    /// 获取视频资源在某个时间的截图
    /// - Parameters:
    ///   - seconds: 秒数
    ///   - size: 期望最大尺寸
    /// - Returns: 获取到的截图
    public func generateImage(at seconds: any BinaryFloatingPoint = 0.0, maximum size: CGSize = .init(width: 300.0, height: 300.0)) -> UIImage? {
        let duration = duration
        //let value = Swift.min(Swift.max(0.0, Double(seconds)), Double(CMTimeGetSeconds(duration)))
        let time = CMTime(seconds: Double(seconds), preferredTimescale: duration.timescale)
        let imageGenerator = AVAssetImageGenerator(asset: base)
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero
        imageGenerator.appliesPreferredTrackTransform = true
        if size.width > 0.0, size.height > 0.0 {
            imageGenerator.maximumSize = size
        }
        var image: UIImage?
        if #available(iOS 16.0, *) {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    let cgImage = try await imageGenerator.image(at: time).image
                    image = UIImage(cgImage: cgImage)
                } catch {
#if DEBUG
                    print("获取媒体资源图片出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
        } else {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                image = UIImage(cgImage: cgImage)
            } catch {
#if DEBUG
                print("获取媒体资源图片出错: \(error)")
#endif
            }
        }
        return image
    }
    
    /// 媒体资源插图
    public var artwork: UIImage? {
        var metadatas: [AVMetadataItem]!
        if #available(iOS 16.0, *) {
            let semaphore = DispatchSemaphore(value: 0)
            Task {
                do {
                    metadatas = try await base.load(.metadata)
                } catch {
#if DEBUG
                    print("获取媒体元数据出错: \(error)")
#endif
                }
                semaphore.signal()
            }
            semaphore.wait()
        } else {
            metadatas = base.metadata
        }
        var image: UIImage?
        for metadata in metadatas {
            guard let commonKey = metadata.commonKey else { continue }
            guard commonKey == .commonKeyArtwork else { continue }
            if #available(iOS 16.0, *) {
                let semaphore = DispatchSemaphore(value: 0)
                Task {
                    do {
                        let value = try await metadata.load(.value)
                        if let imageData = value as? Data {
                            image = UIImage(data: imageData)
                        }
                    } catch {
#if DEBUG
                        print("获取媒体资源插图出错: \(error)")
#endif
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            } else if let imageData = metadata.value as? Data {
                image = UIImage(data: imageData)
            }
            break
        }
        return image
    }
}
