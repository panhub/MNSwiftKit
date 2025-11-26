//
//  AVMutableComposition+MNMediaExport.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/30.
// 

import Foundation
import AVFoundation

// MARK: - Composition
extension AVMutableComposition {
    
    /// 转换合成器
    /// - Parameter mediaType: 媒体类型
    /// - Returns: 合成轨
    public func composition(mediaType: AVMediaType) -> AVMutableCompositionTrack? {
        let tracks = tracks(withMediaType: mediaType)
        guard tracks.isEmpty == false else {
            return addMutableTrack(withMediaType: mediaType, preferredTrackID: kCMPersistentTrackID_Invalid)
        }
        return tracks.first
    }
    
    /// 删除媒体轨
    /// - Parameter mediaType: 轨类型
    public func removeTrack(mediaType: AVMediaType) {
        for track in tracks(withMediaType: mediaType) {
            removeTrack(track)
        }
    }
    
    /// 删除所有媒体轨
    public func removeAllTrack() {
        for type in [AVMediaType.video, AVMediaType.audio, AVMediaType.text, AVMediaType.subtitle] {
            removeTrack(mediaType: type)
        }
    }
}

// MARK: - append
extension AVMutableComposition {
    
    /// 追加媒体资源
    /// - Parameter url: 文件地址
    /// - Returns: 是否追加成功
    @discardableResult
    func append(assetOfURL url: URL) -> Bool {
        let asset = AVURLAsset(mediaOfURL: url)
        return append(asset: asset)
    }
    
    /// 追加资源
    /// - Parameter asset: 资源
    /// - Returns: 是否成功
    @discardableResult
    func append(asset: AVAsset) -> Bool {
        if let videoTrack = asset.track(mediaType: .video), append(track: videoTrack) == false { return false }
        if let audioTrack = asset.track(mediaType: .audio), append(track: audioTrack) == false { return false }
        return true
    }
    
    /// 追加资源
    /// - Parameters:
    ///   - url: 文件地址
    ///   - mediaType: 媒体类型
    /// - Returns: 是否成功
    @discardableResult
    func append(assetOfURL url: URL, mediaType: AVMediaType) -> Bool {
        let asset = AVURLAsset(mediaOfURL: url)
        guard let track = asset.track(mediaType: mediaType) else { return false }
        return append(track: track)
    }
    
    /// 追加资源轨
    /// - Parameter track: 资源轨
    /// - Returns: 是否成功
    @discardableResult
    func append(track: AVAssetTrack) -> Bool {
        guard CMTIMERANGE_IS_VALID(track.timeRange) else { return false }
        if track.mediaType == .video {
            // 视频轨道
            guard let videoTrack = composition(mediaType: .video) else { return false }
            let time: CMTime = CMTIMERANGE_IS_VALID(videoTrack.timeRange) ? videoTrack.timeRange.duration : .zero
            do {
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: track.timeRange.duration), of: track, at: time)
            } catch {
#if DEBUG
                print(error)
#endif
                return false
            }
            return true
        } else if track.mediaType == .audio {
            // 音频轨道
            guard let audioTrack = composition(mediaType: .audio) else { return false }
            let time: CMTime = CMTIMERANGE_IS_VALID(audioTrack.timeRange) ? audioTrack.timeRange.duration : .zero
            do {
                try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: track.timeRange.duration), of: track, at: time)
            } catch  {
#if DEBUG
                print(error)
#endif
                return false
            }
            return true
        }
        return false
    }
}
