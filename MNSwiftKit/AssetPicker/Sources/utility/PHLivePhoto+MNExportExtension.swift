//
//  PHLivePhoto+MNExportExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/12/20.
//

import Foundation
import Photos
import ObjectiveC.runtime

public typealias MNLivePhotoResourceKey = String
public let MNLivePhotoVideoUrlKey: MNLivePhotoResourceKey  = "com.mn.live.photo.video.url"
public let MNLivePhotoImageUrlKey: MNLivePhotoResourceKey  = "com.mn.live.photo.image.url"

@available(iOS 9.1, *)
extension PHLivePhoto {
    
    private struct MNResourceAssociated {
        nonisolated(unsafe) static var video = "com.mn.live.photo.video.url"
        nonisolated(unsafe) static var image = "com.mn.live.photo.image.url"
    }
    
    /// 视频文件定位器
    @objc public var videoFileURL: URL? {
        get { objc_getAssociatedObject(self, &MNResourceAssociated.video) as? URL}
        set { objc_setAssociatedObject(self, &MNResourceAssociated.video, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 图片文件定位器
    @objc public var imageFileURL: URL? {
        get { objc_getAssociatedObject(self, &MNResourceAssociated.image) as? URL}
        set { objc_setAssociatedObject(self, &MNResourceAssociated.image, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
}

// LivePhoto导出辅助
@available(iOS 9.1, *)
class PHLivePhotoBuffer {
    var data = Data()
    var type: PHAssetResourceType = .photo
}

