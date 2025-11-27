//
//  MNMetadataExportSupported.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/11/26.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

public protocol MNMediaExportSupported {
    
    /// 轨道合成器
    var composition: AVMutableComposition { get }
}

extension MNMediaExportSupported {
    
    /// 拼接媒体资源内音视频轨道
    /// - Parameter string: 媒体资源路径或远程地址
    /// - Returns: 是否拼接成功
    @discardableResult
    func appendAsset(for string: String) -> Bool {
        
        composition.mn.appendAsset(for: string)
    }
    
    /// 拼接媒体资源内音视频轨道
    /// - Parameter url: 媒体资源定位器
    /// - Returns: 是否拼接成功
    @discardableResult
    func appendAsset(for url: URL) -> Bool {
        
        composition.mn.appendAsset(for: url)
    }
    
    /// 拼接媒体资源内音视频轨道
    /// - Parameter asset: 媒体资源
    /// - Returns: 是否拼接成功
    @discardableResult
    func append(asset: AVAsset) -> Bool {
        
        composition.mn.append(asset: asset)
    }
    
    /// 拼接轨道到尾部
    /// - Parameter track: 拼接的轨道
    /// - Returns: 是否拼接成功
    @discardableResult
    func append(track: AVAssetTrack) -> Bool {
        
        composition.mn.append(track: track)
    }
}

public protocol MNMetadataExportSupported {}

extension MNMetadataExportSupported {
    
    /// 获取媒体资源时长
    /// - Parameter string: 媒体文件路径或远程连接
    /// - Returns: 获取到的时长
    static func duration(for string: String) -> TimeInterval {
        guard let asset = AVURLAsset(string: string) else { return 0.0 }
        return asset.mn.seconds
    }
    
    /// 获取视频资源时长
    /// - Parameter url: 媒体文件定位器
    /// - Returns: 获取到的时长
    static func duration(for url: URL) -> TimeInterval {
        let asset = AVURLAsset(for: url)
        return asset.mn.seconds
    }
    
    /// 获取视频资源的原始尺寸
    /// - Parameter string: 视频文件路径或远程连接
    /// - Returns: 获取到的原始尺寸
    static func naturalSize(for string: String) -> CGSize {
        guard let asset = AVURLAsset(string: string) else { return .zero }
        return naturalSize(for: asset)
    }
    
    /// 获取视频资源的原始尺寸
    /// - Parameter url: 视频文件定位器
    /// - Returns: 获取到的原始尺寸
    static func naturalSize(for url: URL) -> CGSize {
        let asset = AVURLAsset(for: url)
        return naturalSize(for: asset)
    }
    
    /// 获取视频资源的原始尺寸
    /// - Parameter asset: 视频资源
    /// - Returns: 获取到的原始尺寸
    static func naturalSize(for asset: AVAsset) -> CGSize {
        guard let track = asset.mn.track(with: .video) else { return .zero }
        return track.mn.naturalSize
    }
    
    /// 依据媒体资源类型获取截图
    /// - Parameters:
    ///   - string: 文件路径或远程链接
    ///   - seconds: 秒数(视频资源有效)
    ///   - size: 期望最大尺寸(视频资源有效)
    /// - Returns: 获取到的截图(音频则返回插图)
    static func generateImage(for string: String, at seconds: any BinaryFloatingPoint = 0.0, maximum size: CGSize = .init(width: 300.0, height: 300.0)) -> UIImage? {
        guard let asset = AVURLAsset(string: string) else { return nil }
        return generateImage(for: asset, at: seconds, maximum: size)
    }
    
    /// 依据媒体资源类型获取截图
    /// - Parameters:
    ///   - url: 资源定位器
    ///   - seconds: 秒数(视频资源有效)
    ///   - size: 期望最大尺寸(视频资源有效)
    /// - Returns: 获取到的截图(音频则返回插图)
    static func generateImage(for url: URL, at seconds: any BinaryFloatingPoint = 0.0, maximum size: CGSize = .init(width: 300.0, height: 300.0)) -> UIImage? {
        let asset = AVURLAsset(for: url)
        return generateImage(for: asset, at: seconds, maximum: size)
    }
    
    /// 依据媒体资源类型获取截图
    /// - Parameters:
    ///   - asset: 媒体资源
    ///   - seconds: 秒数(视频资源有效)
    ///   - size: 期望最大尺寸(视频资源有效)
    /// - Returns: 获取到的截图(音频则返回插图)
    static func generateImage(for asset: AVAsset, at seconds: any BinaryFloatingPoint = 0.0, maximum size: CGSize = .init(width: 300.0, height: 300.0)) -> UIImage? {
        if let _ = asset.mn.track(with: .video) {
            // 视频
            return asset.mn.generateImage(at: seconds, maximum: size)
        }
        return asset.mn.artwork
    }
}

extension MNAssetExportSession: MNMediaExportSupported {}
extension MNAssetExportSession: MNMetadataExportSupported {}
