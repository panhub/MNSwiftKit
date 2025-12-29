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
    
    fileprivate struct MNResourceAssociated {
        
        nonisolated(unsafe) static var video: Void?
        nonisolated(unsafe) static var image: Void?
    }
}

@available(iOS 9.1, *)
extension MNNameSpaceWrapper where Base: PHLivePhoto {
    
    /// 视频文件定位器
    public var videoFileURL: URL? {
        get { objc_getAssociatedObject(base, &PHLivePhoto.MNResourceAssociated.video) as? URL}
        set { objc_setAssociatedObject(base, &PHLivePhoto.MNResourceAssociated.video, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    /// 图片文件定位器
    public var imageFileURL: URL? {
        get { objc_getAssociatedObject(base, &PHLivePhoto.MNResourceAssociated.image) as? URL}
        set { objc_setAssociatedObject(base, &PHLivePhoto.MNResourceAssociated.image, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
}
