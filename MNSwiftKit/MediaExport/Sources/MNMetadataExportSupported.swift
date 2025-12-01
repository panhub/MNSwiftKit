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

public protocol MNMetadataExportSupported {}

extension MNAssetExportSession: MNMetadataExportSupported {}

extension MNMetadataExportSupported {
    
    /// 获取媒体资源时长
    /// - Parameter string: 媒体文件路径或远程连接
    /// - Returns: 获取到的时长
    static func seconds(for string: String) -> TimeInterval {
        guard let asset = AVURLAsset(for: string) else { return 0.0 }
        return asset.mn.seconds
    }
    
    /// 获取视频资源时长
    /// - Parameter url: 媒体文件定位器
    /// - Returns: 获取到的时长
    static func seconds(for url: URL) -> TimeInterval {
        let asset = AVURLAsset(for: url)
        return asset.mn.seconds
    }
    
    /// 获取视频资源的原始尺寸
    /// - Parameter string: 视频文件路径或远程连接
    /// - Returns: 获取到的原始尺寸
    static func renderSize(for string: String) -> CGSize {
        guard let asset = AVURLAsset(for: string) else { return .zero }
        return renderSize(for: asset)
    }
    
    /// 获取视频资源的原始尺寸
    /// - Parameter url: 视频文件定位器
    /// - Returns: 获取到的原始尺寸
    static func renderSize(for url: URL) -> CGSize {
        let asset = AVURLAsset(for: url)
        return renderSize(for: asset)
    }
    
    /// 获取视频资源的原始尺寸
    /// - Parameter asset: 视频资源
    /// - Returns: 获取到的原始尺寸
    static func renderSize(for asset: AVAsset) -> CGSize {
        guard let track = asset.mn.track(with: .video) else { return .zero }
        return track.mn.renderSize
    }
    
    /// 依据媒体资源类型获取截图
    /// - Parameters:
    ///   - string: 文件路径或远程链接
    ///   - seconds: 秒数(视频资源有效)
    ///   - size: 期望最大尺寸(视频资源有效)
    /// - Returns: 获取到的截图(音频则返回插图)
    static func generateImage(for string: String, at seconds: any BinaryFloatingPoint = 0.0, maximum size: CGSize = .init(width: 300.0, height: 300.0)) -> UIImage? {
        guard let asset = AVURLAsset(for: string) else { return nil }
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

extension MNMetadataExportSupported {
    
    /// 依据文件后缀获取文件类型
    /// - Parameter fileExtension: 文件后缀
    /// - Returns: 文件类型
    static func fileType(for fileExtension: String) -> AVFileType? {
        let ext = fileExtension.lowercased()
        if #available(iOS 14.0, *), let type = UTType(filenameExtension: ext) {
            // 根据 UTType 返回对应的 AVFileType
            if type.conforms(to: .quickTimeMovie)
            {
                return .mov
            }
            else if type.conforms(to: .mpeg4Movie)
            {
                return .mp4
            }
            else if type.conforms(to: .appleProtectedMPEG4Video)
            {
                return .m4v
            }
            else if type.conforms(to: .appleProtectedMPEG4Audio)
            {
                return .m4a
            }
            else if type.conforms(to: .wav)
            {
                return .wav
            }
            else if type.conforms(to: .aiff)
            {
                return .aiff
            }
            else if type.conforms(to: .mp3)
            {
                return .mp3
            }
            else if type.conforms(to: .heic)
            {
                return .heic
            }
            else if type.conforms(to: .heif)
            {
                return .heif
            }
            else if type.conforms(to: .tiff)
            {
                return .tif
            }
            else if #available(iOS 17.0, *), type.conforms(to: .ahap)
            {
                return .AHAP
            }
            else if #available(iOS 18.0, *), type.conforms(to: .dng)
            {
                return .dng
            }
        }
        // 直接映射
        switch ext {
        case "mov", "qt": return .mov
        case "mp4": return .mp4
        case "m4v": return .m4v
        case "m4a": return .m4a
        case "3gp", "3gpp", "sdv": return .mobile3GPP
        case "3g2", "3gp2": return .mobile3GPP2
        case "caf": return .caf
        case "wav", "wave", "bwf": return .wav
        case "aif", "aiff": return .aiff
        case "aifc", "cdda": return .aifc
        case "amr": return .amr
        case "mp3": return .mp3
        case "au", "snd": return .au
        case "ac3": return .ac3
        case "eac3": return .eac3
        case "jpg", "jpeg":
            if #available(iOS 11.0, *) { return .jpg }
            return nil
        case "dng":
            if #available(iOS 11.0, *) { return .dng }
            return nil
        case "heic":
            if #available(iOS 11.0, *) { return .heic }
            return nil
        case "heif":
            if #available(iOS 11.0, *) { return .heif }
            return nil
        case "avci":
            if #available(iOS 11.0, *) { return .avci }
            return nil
        case "tif", "tiff":
            if #available(iOS 11.0, *) { return .tif }
            return nil
        case "ahap":
            if #available(iOS 17.0, *) { return .AHAP }
            return nil
        case "itt":
            if #available(iOS 18.0, *) { return .appleiTT }
            return nil
        case "scc":
            if #available(iOS 18.0, *) { return .SCC }
            return nil
        default: return nil
        }
    }
}
