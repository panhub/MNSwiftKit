//
//  PHAsset+MNExportExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/1/30.
//

import Photos
import Foundation

extension NameSpaceWrapper where Base: PHAsset {
    
    /// 资源类型
    public var contentType: MNAssetType {
        var type: MNAssetType = .photo
        switch base.mediaType {
        case .image:
            if isGif {
                type = .gif
            } else if #available(iOS 9.1, *), base.mediaSubtypes.contains(.photoLive) {
                type = .livePhoto
            }
        case .video:
            type = .video
        default: break
        }
        return type
    }
    
    /// 是否是gif动图资源
    public var isGif: Bool {
        if #available(iOS 9.0, *) {
            for resource in PHAssetResource.assetResources(for: base) {
                let uti = resource.uniformTypeIdentifier.lowercased()
                if uti.contains("gif") { return true }
            }
            if let filename = base.value(forKey: "filename") as? NSString {
                return filename.pathExtension.lowercased().contains("gif")
            }
            return false
        } else if let uti = base.value(forKey: "uniformTypeIdentifier") as? String {
            return uti.contains("gif")
        }
        return false
    }
    
    /// 是否是mov格式资源
    public var isMov: Bool {
        if #available(iOS 9.0, *) {
            for resource in PHAssetResource.assetResources(for: base) {
                let uti = resource.uniformTypeIdentifier.lowercased()
                if uti.contains("mov") { return true }
            }
            return false
        } else if let uti = base.value(forKey: "uniformTypeIdentifier") as? String {
            return uti.contains("mov")
        }
        return false
    }
    
    /// 是否是heic/heif图片
    public var isHeifc: Bool {
        if #available(iOS 9.0, *) {
            for resource in PHAssetResource.assetResources(for: base) {
                let uti = resource.uniformTypeIdentifier.lowercased()
                if uti.contains("heif") || uti.contains("heic") { return true }
            }
            return false
        } else if let uti = base.value(forKey: "uniformTypeIdentifier") as? String {
            return (uti.contains("heif") || uti.contains("heic"))
        }
        return false
    }
    
    /// 文件名
    public var filename: String? {
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: base)
            if let first = resources.first {
                return first.originalFilename
            }
        }
        return nil
    }
    
    /// 若是LivePhoto文件, 则返回图片文件名
    @available(iOS 9.1, *)
    public var imageFilename: String? {
        for resource in PHAssetResource.assetResources(for: base) {
            let filename = resource.originalFilename
            let lowercased = filename.lowercased()
            if lowercased.contains("jpg") || lowercased.contains("jpeg") {
                return filename
            }
        }
        return nil
    }
    
    
    /// 若是LivePhoto文件, 则返回视频文件名
    @available(iOS 9.1, *)
    public var videoFilename: String? {
        for resource in PHAssetResource.assetResources(for: base) {
            let filename = resource.originalFilename
            if filename.lowercased().contains("mov") {
                return filename
            }
        }
        return nil
    }
}
