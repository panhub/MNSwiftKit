//
//  MNAssetAlbum.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  相簿模型

import UIKit
import Photos

class MNAssetAlbum: NSObject {
    
    /// 资源总数
    var count: Int = 0
    
    /// 当前已查询个数
    var offset: Int = 0
    
    /// 相簿展示名称
    let name: String
    
    /// 系统相簿
    let collection: PHAssetCollection
    
    /// 查询选项
    let fetchOptions = PHFetchOptions()
    
    /// 封面资源模型
    var cover: MNAsset?
    
    /// 相簿资源集合
    var assets: [MNAsset] = [MNAsset]()
    
    /// 是否选中
    var isSelected: Bool = false
    
    /// 构造相簿资源
    /// - Parameters:
    ///   - collection: 系统照片束
    ///   - options: 选择器选项
    init(collection: PHAssetCollection, options: MNAssetPickerOptions) {
        self.collection = collection
        self.name = collection.mn.localizedName
        super.init()
        if options.allowsPickingVideo == false {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        } else if options.allowsPickingPhoto == false, options.allowsPickingGif == false, options.allowsPickingLivePhoto == false {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        } else {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        }
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: options.sortAscending)]
        let result = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        count = result.count
        if let first = result.firstObject {
            let asset = MNAsset(asset: first)
            asset.renderSize = options.renderSize
            cover = asset
        }
#if !targetEnvironment(simulator)
        // 这里可以添加拍摄入口
        // TODO:
#endif
    }
    
    /// 添加资源
    /// - Parameter asset: 资源模型
    func addAsset(_ asset: MNAsset) {
        objc_sync_enter(self)
        if assets.isEmpty {
            assets.append(asset)
        } else {
            assets[assets.count - 1] = asset
        }
        objc_sync_exit(self)
    }
    
    /// 插入资源
    /// - Parameter asset: 资源模型
    func insertAsset(atFront asset: MNAsset) {
        objc_sync_enter(self)
        if assets.isEmpty {
            assets[0] = asset
        } else {
            assets[1] = asset
        }
        objc_sync_exit(self)
    }
    
    /// 删除所有资源
    func removeAllAssets() {
        objc_sync_enter(self)
        assets.removeAll()
        objc_sync_exit(self)
    }
    
    /// 删除指定资源
    /// - Parameter assets: 指定资源集合
    func removeAssets(_ assets: [MNAsset]) {
        objc_sync_enter(self)
        self.assets.removeAll { assets.contains($0) }
        objc_sync_exit(self)
    }
    
    /// 添加指定资源
    /// - Parameter assets: 指定资源集合
    func addAssets(_ assets: [MNAsset]) {
        objc_sync_enter(self)
        self.assets.append(contentsOf: assets)
        objc_sync_exit(self)
    }
    
    /// 删除指定的相册资源
    /// - Parameter assets: 相册资源集合
    func removeAssets(with assets: [PHAsset]) {
        objc_sync_enter(self)
        let localIdentifiers = assets.compactMap { $0.localIdentifier }
        self.assets.removeAll { asset in
            guard let rawAsset = asset.rawAsset else { return false }
            return localIdentifiers.contains(rawAsset.localIdentifier)
        }
        objc_sync_exit(self)
    }
}
