//
//  AVMutableComposition+MNMediaExport.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/30.
// 

import Foundation
import AVFoundation

extension NameSpaceWrapper where Base: AVMutableComposition {
    
    /// 获取合成轨道
    /// - Parameter mediaType: 媒体类型
    /// - Returns: 获取到的合成轨道(没有则添加后返回)
    public func compositionTrack(with mediaType: AVMediaType) -> AVMutableCompositionTrack? {
        let tracks = base.tracks(withMediaType: mediaType)
        if tracks.isEmpty {
            return base.addMutableTrack(withMediaType: mediaType, preferredTrackID: kCMPersistentTrackID_Invalid)
        }
        return tracks.first
    }
    
    /// 删除指定类型的轨道
    /// - Parameter mediaType: 媒体类型
    public func removeTrack(with mediaType: AVMediaType) {
        for track in base.tracks(withMediaType: mediaType) {
            base.removeTrack(track)
        }
    }
}

extension NameSpaceWrapper where Base: AVMutableComposition {
    
    /// 拼接媒体资源内音视频轨道
    /// - Parameter string: 媒体资源路径或远程地址
    /// - Returns: 是否拼接成功
    @discardableResult
    public func appendAsset(for string: String) -> Bool {
        guard let asset = AVURLAsset(string: string) else { return false }
        return append(asset: asset)
    }
    
    /// 拼接媒体资源内音视频轨道
    /// - Parameter url: 媒体资源定位器
    /// - Returns: 是否拼接成功
    @discardableResult
    public func appendAsset(for url: URL) -> Bool {
        let asset = AVURLAsset(for: url)
        return append(asset: asset)
    }
    
    /// 拼接媒体资源内音视频轨道
    /// - Parameter asset: 媒体资源
    /// - Returns: 是否拼接成功
    @discardableResult
    public func append(asset: AVAsset) -> Bool {
        if let videoTrack = track(with: .video) {
            guard append(track: videoTrack) else { return false }
        }
        if let audioTrack = track(with: .audio) {
            guard append(track: audioTrack) else { return false }
        }
        return true
    }
    
    /// 拼接轨道到尾部
    /// - Parameter track: 拼接的轨道
    /// - Returns: 是否拼接成功
    @discardableResult
    func append(track: AVAssetTrack) -> Bool {
        guard CMTIMERANGE_IS_VALID(track.timeRange) else { return false }
        guard let compositionTrack = compositionTrack(with: track.mediaType) else { return false }
        let timeRange = CMTimeRange(start: .zero, duration: track.timeRange.duration)
        do {
            try compositionTrack.insertTimeRange(timeRange, of: track, at: base.duration)
        } catch {
#if DEBUG
            print("插入轨道到媒体合成轨道出错: \(error)")
#endif
            return false
        }
        if track.mediaType == .video {
            compositionTrack.preferredTransform = track.mn.preferredTransform
        }
        return true
    }
}
