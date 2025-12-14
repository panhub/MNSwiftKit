//
//  PHAsset+MNExportExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/1/30.
//

import Photos
import Foundation
import UniformTypeIdentifiers

extension MNNameSpaceWrapper where Base: PHAsset {
    
    /// 资源类型
    public var contentType: MNAssetType {
        switch base.mediaType {
        case .image:
            if isGif {
                return .gif
            } else if #available(iOS 9.1, *), base.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            return .photo
        case .video: return .video
        default: return .photo
        }
    }
    
    /// 是否是gif动图资源
    public var isGif: Bool {
        if #available(iOS 14.0, *) {
            for resource in PHAssetResource.assetResources(for: base) {
                if let type = UTType(resource.uniformTypeIdentifier), type.conforms(to: .gif) {
                    return true
                }
            }
        }
        if let filename = base.value(forKey: "filename") as? NSString {
            return filename.pathExtension.lowercased() == "gif"
        }
        return false
    }
    
    /// 是否是mov格式
    public var isMov: Bool {
        if #available(iOS 14.0, *) {
            for resource in PHAssetResource.assetResources(for: base) {
                if let type = UTType(resource.uniformTypeIdentifier), type.conforms(to: .quickTimeMovie) {
                    return true
                }
            }
        }
        if let filename = base.value(forKey: "filename") as? NSString {
            return filename.pathExtension.lowercased() == "mov"
        }
        return false
    }
    
    /// 是否是Mp4格式
    public var isMp4: Bool {
        if #available(iOS 14.0, *) {
            for resource in PHAssetResource.assetResources(for: base) {
                if let type = UTType(resource.uniformTypeIdentifier), type.conforms(to: .mpeg4Movie) {
                    return true
                }
            }
        }
        if let filename = base.value(forKey: "filename") as? NSString {
            return filename.pathExtension.lowercased() == "mp4"
        }
        return false
    }
    
    /// 是否是heic格式
    public var isHeic: Bool {
        if #available(iOS 14.0, *) {
            for resource in PHAssetResource.assetResources(for: base) {
                if let type = UTType(resource.uniformTypeIdentifier), type.conforms(to: .heic) {
                    return true
                }
            }
        }
        if let filename = base.value(forKey: "filename") as? NSString {
            let lowercased = filename.pathExtension.lowercased()
            return lowercased == "heic"
        }
        return false
    }
    
    /// 是否是heif格式
    public var isHeif: Bool {
        if #available(iOS 14.0, *) {
            for resource in PHAssetResource.assetResources(for: base) {
                if let type = UTType(resource.uniformTypeIdentifier), type.conforms(to: .heif) {
                    return true
                }
            }
        }
        if let filename = base.value(forKey: "filename") as? NSString {
            let lowercased = filename.pathExtension.lowercased()
            return lowercased == "heif"
        }
        return false
    }
    
    /// 文件名
    public var filename: String? {
        let resources = PHAssetResource.assetResources(for: base)
        if let first = resources.first {
            return first.originalFilename
        }
        if let filename = base.value(forKey: "filename") as? String {
            return filename
        }
        return nil
    }
    
    /// 主要用于LivePhoto文件, 寻找图片文件名
    public var imageFilename: String? {
        for resource in PHAssetResource.assetResources(for: base) {
            let type = resource.type
            guard type == .photo || type == .fullSizePhoto else { continue }
            let filename = resource.originalFilename
            return filename
        }
        return nil
    }
    
    /// 主要用于LivePhoto文件, 寻找视频文件名
    public var videoFilename: String? {
        for resource in PHAssetResource.assetResources(for: base) {
            var types: [PHAssetResourceType] = [.video, .fullSizeVideo]
            if #available(iOS 9.1, *) {
                types.append(.pairedVideo)
            }
            if #available(iOS 10.0, *) {
                types.append(.fullSizePairedVideo)
            }
            guard types.contains(resource.type) else { continue }
            let filename = resource.originalFilename
            return filename
        }
        return nil
    }
}
