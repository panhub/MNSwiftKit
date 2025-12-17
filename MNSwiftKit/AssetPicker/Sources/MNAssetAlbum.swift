//
//  MNAssetAlbum.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  相簿模型

import UIKit
import Photos

/// 相簿
public class MNAssetAlbum: NSObject {
    
    /// 相簿展示名称
    public let name: String
    
    /// 本地标识
    public let identifier: String
    
    /// 系统相簿
    public let collection: PHAssetCollection
    
    /// 查询选项
    public let options = PHFetchOptions()
    
    /// 资源总数
    public var count: Int = 0
    
    /// 当前已查询个数
    public var offset: Int = 0
    
    /// 系统相簿
    public var isFirstAppear: Bool = true
    
    /// 是否选中
    public var isSelected: Bool = false
    
    /// 已加载的资源集合
    public var assets: [MNAsset] = []
    
    /// 封面图片
    public var cover: UIImage?
    
    /// 封面变化回调
    public var coverUpdateHandler: ((_ album: MNAssetAlbum)->Void)?
    
    
    /// 构造相簿
    /// - Parameters:
    ///   - collection: 系统资源束
    ///   - options: 选择器选项
    public init(collection: PHAssetCollection, options: MNAssetPickerOptions) {
        self.collection = collection
        self.identifier = collection.localIdentifier
        self.name = collection.mn.localizedName
        super.init()
        if options.allowsPickingVideo == false {
            self.options.predicate = NSPredicate(format: "\(#keyPath(PHAsset.mediaType)) == %ld", PHAssetMediaType.image.rawValue)
        } else if options.allowsPickingPhoto == false, options.allowsPickingGif == false, options.allowsPickingLivePhoto == false {
            self.options.predicate = NSPredicate(format: "\(#keyPath(PHAsset.mediaType)) == %ld", PHAssetMediaType.video.rawValue)
        } else {
            self.options.predicate = NSPredicate(format: "\(#keyPath(PHAsset.mediaType)) == %ld || \(#keyPath(PHAsset.mediaType)) == %ld", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        }
        self.options.sortDescriptors = [NSSortDescriptor(key: #keyPath(PHAsset.creationDate), ascending: options.sortAscending)]
        let result = PHAsset.fetchAssets(in: collection, options: self.options)
        self.count = result.count
        if let first = result.firstObject {
            updateCover(using: first, size: options.renderSize)
        }
    }
    
    /// 更新封面
    /// - Parameters:
    ///   - asset: 使用的相册资产
    ///   - size: 目标尺寸
    public func updateCover(using asset: PHAsset, size: CGSize) {
        MNAssetHelper.exportCover(for: asset, mode: .opportunistic, size: size) { [weak self] cover, error in
            guard let self = self else { return }
            guard let cover = cover else { return }
            self.cover = cover
            self.coverUpdateHandler?(self)
        }
    }
}
