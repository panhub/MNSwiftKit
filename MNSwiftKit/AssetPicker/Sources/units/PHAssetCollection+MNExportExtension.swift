//
//  PHAssetCollection+MNExportExtension.swift
//  MNKit
//
//  Created by 冯盼 on 2022/1/30.
//

import Photos
import Foundation

extension PHAssetCollection {
    
    /// 是否是`相机胶卷`资源
    @objc public var isCameraRoll: Bool {
        guard assetCollectionType == .smartAlbum else { return false }
        let subtype: PHAssetCollectionSubtype = (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_2) ? .smartAlbumRecentlyAdded : .smartAlbumUserLibrary
        return assetCollectionSubtype == subtype
    }
    
    /// 获取相册标题
    @objc public var localizedName: String {
        if let localizedTitle = localizedTitle { return localizedTitle }
        if assetCollectionType == .album {
            return assetCollectionSubtype == .albumMyPhotoStream ? "我的照片" : "所有照片"
        }
        switch assetCollectionSubtype {
        case .smartAlbumUserLibrary, .smartAlbumRecentlyAdded: return "最近添加"
        case .smartAlbumPanoramas: return "全景照片"
        case .smartAlbumVideos: return "视频"
        case .smartAlbumFavorites: return "个人收藏"
        case .smartAlbumTimelapses: return "延时摄影"
        case .smartAlbumBursts: return "连拍快照"
        case .smartAlbumSlomoVideos: return "慢动作"
        case .smartAlbumSelfPortraits: return "自拍"
        case .smartAlbumScreenshots: return "屏幕快照"
        case .smartAlbumDepthEffect: return "人像"
        case .smartAlbumLivePhotos: return "Live Photo"
        default:
            if #available(iOS 11.0, *) {
                if assetCollectionSubtype == .smartAlbumAnimated { return "动图" }
                if assetCollectionSubtype == .smartAlbumLongExposures { return "长曝光" }
            }
            if #available(iOS 13.0, *), assetCollectionSubtype == .smartAlbumUnableToUpload { return "未上传" }
            if #available(iOS 15.0, *) {
                if assetCollectionSubtype == .smartAlbumRAW { return "原照" }
                if assetCollectionSubtype == .smartAlbumCinematic { return "电影" }
            }
            return "未命名相簿"
        }
    }
}
