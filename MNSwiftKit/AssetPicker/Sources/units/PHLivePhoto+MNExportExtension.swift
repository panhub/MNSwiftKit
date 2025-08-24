//
//  PHLivePhoto+MNExportExtension.swift
//  MNKit
//
//  Created by 冯盼 on 2021/12/20.
//

import Foundation
import Photos
import ObjectiveC.runtime

public typealias MNLivePhotoResourceKey = String
public let MNLivePhotoVideoUrlKey: MNLivePhotoResourceKey  = "com.mn.live.photo.video.url"
public let MNLivePhotoImageUrlKey: MNLivePhotoResourceKey  = "com.mn.live.photo.image.url"

@available(iOS 9.1, *)
extension PHLivePhoto {
    
    private struct ResourceAssociated {
        static var video = "com.mn.live.photo.video.url"
        static var image = "com.mn.live.photo.image.url"
    }
    
    /// 视频文件定位器
    @objc public var videoFileURL: URL? {
        get { objc_getAssociatedObject(self, &ResourceAssociated.video) as? URL}
        set { objc_setAssociatedObject(self, &ResourceAssociated.video, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 图片文件定位器
    @objc public var imageFileURL: URL? {
        get { objc_getAssociatedObject(self, &ResourceAssociated.image) as? URL}
        set { objc_setAssociatedObject(self, &ResourceAssociated.image, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
}

// LivePhoto导出辅助
@available(iOS 9.1, *)
class PHLivePhotoBuffer {
    var data = Data()
    var type: PHAssetResourceType = .photo
}

