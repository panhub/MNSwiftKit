//
//  MNAssetAlbum.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  相簿模型

import UIKit
import Photos

public class MNAssetAlbum: NSObject {
    
    /// 相簿展示名称
    public let name: String
    
    /// 系统相簿
    public let collection: PHAssetCollection
    
    /// 查询选项
    public let fetchOptions = PHFetchOptions()
    
    /// 资源总数
    public private(set) var count: Int = 0
    
    /// 当前已查询个数
    public internal(set) var offset: Int = 0
    
    /// 相簿资源集合
    public var assets: [MNAsset] = [MNAsset]()
    
    /// 是否选中
    public var isSelected: Bool = false
    
    /// 是否还有更多资源未查询
    public var hasMore: Bool { offset < count }
    
    
    /// 构造相簿资源
    /// - Parameters:
    ///   - collection: 系统照片束
    ///   - options: 选择器选项
    public init(collection: PHAssetCollection, options: MNAssetPickerOptions) {
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
#if !targetEnvironment(simulator)
        // 这里可以添加拍摄入口
        // TODO:
#endif
    }
}
