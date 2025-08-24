//
//  AVURLAsset+MNExporting.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/30.
//

import Foundation
import AVFoundation

extension AVAsset {
    
    /// 时长
    public var seconds: TimeInterval {
        CMTimeGetSeconds(duration)
    }
    
    /// 获取资源轨道
    /// - Parameter mediaType: 媒体类型
    /// - Returns: 资源轨道
    public func track(mediaType: AVMediaType) -> AVAssetTrack? {
        let tracks = tracks(withMediaType: mediaType)
        guard tracks.count > 0 else { return nil }
        return tracks.first
    }
    
    /// 获取资源轨道
    /// - Parameters:
    ///   - path: 资源路径
    ///   - type: 媒体类型
    /// - Returns: 资源轨道
    public class func track(mediaAtPath path: String, mediaType type: AVMediaType) -> AVAssetTrack? {
        guard let asset = AVURLAsset(mediaAtPath: path) else { return nil }
        return asset.track(mediaType: type)
    }
    
    /// 获取资源轨道
    /// - Parameters:
    ///   - url: 资源地址
    ///   - type: 媒体类型
    /// - Returns: 资源轨道
    public class func track(mediaOfURL url: URL, mediaType type: AVMediaType) -> AVAssetTrack? {
        let asset = AVURLAsset(mediaOfURL: url)
        return asset.track(mediaType: type)
    }
    
    /// 获取时间片段
    /// - Parameters:
    ///   - from: 起始进度
    ///   - to: 结束进度
    /// - Returns: 时间片段
    public func progressRange(from: Double, to: Double) -> CMTimeRange {
        guard from >= 0.0, to <= 1.0, to > from else { return .zero }
        let start = CMTimeMultiplyByFloat64(duration, multiplier: Float64(from))
        let duration = CMTimeMultiplyByFloat64(duration, multiplier: Float64(to - from))
        return CMTimeRange(start: start, duration: duration)
    }
    
    /// 获取时间片段
    /// - Parameters:
    ///   - from: 起始秒数
    ///   - to: 结束秒数
    /// - Returns: 时间片段
    public func timeRange(from: Double, to: Double) -> CMTimeRange {
        let time: CMTime = duration
        let duration: Double = Double(CMTimeGetSeconds(time))
        let begin = min(duration, max(0.0, from))
        let end = min(duration, max(begin, to))
        guard duration > 0.0, end > from else { return .zero }
        return CMTimeRange(start: CMTime(seconds: begin, preferredTimescale: time.timescale), duration: CMTime(seconds: end - begin, preferredTimescale: time.timescale))
    }
}

extension AVURLAsset {
    
    /// 构造媒体文件
    /// - Parameter url: 文件路径
    public convenience init(mediaOfURL url: URL) {
        self.init(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: url.isFileURL])
    }
    
    /// 构造媒体文件
    /// - Parameter path: 文件路径
    public convenience init?(mediaAtPath path: String) {
        guard path.isEmpty == false else { return nil }
        let url = FileManager.default.fileExists(atPath: path) ? URL(fileURLWithPath: path) : URL(string: path)
        guard let url = url else { return nil }
        self.init(mediaOfURL: url)
    }
}
