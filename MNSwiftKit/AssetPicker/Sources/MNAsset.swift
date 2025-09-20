//
//  MNAsset.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  相册资源模型

import UIKit
import Photos
import Foundation
import AVFoundation.AVAsset

/**
 资源更新回调
 */
public typealias MNAssetUpdateHandler = (_ asset: MNAsset)->Void

/// 资源模型
public class MNAsset: NSObject {
    
    /**
     文件来源
     - unknown: 未知
     - cloud: iCloud
     - local: 本地
     */
    @objc public enum ResourceSource: Int {
        case unknown, local, cloud
    }
    
    /// 本地标识
    @objc public var identifier: String = ""
    
    /// 文件类型
    @objc public var type: ContentType = .photo
    
    /// 来源
    @objc public var source: ResourceSource = .unknown
    
    /**
     图片: 调整后的图片
     视频: 路径
     LivePhoto : PHLivePhoto
     */
    @objc public var content: Any?
    
    /// 显示大小
    @objc public var renderSize: CGSize = CGSize(width: 250.0, height: 250.0)
    
    /// 时长(仅视频资源有效)
    @objc public var duration: TimeInterval = 0.0
    
    /// 时长(duration的字符串表现形式)
    @objc public lazy var durationValue: String = {
        Date(timeIntervalSince1970: duration).mn.playTime
    }()
    
    /// 文件大小
    @objc public var fileSize: Int64 = 0
    
    /// 文件大小字符串
    @objc internal lazy var fileSizeString: String = {
        guard fileSize > 0 else { return "" }
        return fileSize.mn.fileSizeString
    }()
    
    /// 缩略图
    @objc public var cover: UIImage?
    
    /// 是否选中
    @objc public var isSelected: Bool = false
    
    /// 是否是有效资源
    @objc public var isEnabled: Bool = true
    
    /// 系统资源, 与'PHPhoto'交互时使用
    @objc public var phAsset: PHAsset?
    
    /// PHImageRequestID, 缩略图请求id
    @objc public var requestId: Int32 = PHInvalidImageRequestID
    
    /// PHImageRequestID, 内容下载id
    @objc public var downloadId: Int32 = PHInvalidImageRequestID
    
    /// 下载进度
    @objc public var progress: Double = 0.0
    
    /// 选择索引
    @objc public var index: Int = 0
    
    /// 标记展示它的View(预览时使用)
    @objc public weak var container: UIView?
    
    /// 缩略图变化回调
    @objc internal var coverUpdateHandler: MNAssetUpdateHandler?
    
    /// 来源变化回调
    @objc internal var sourceUpdateHandler: MNAssetUpdateHandler?
    
    /// 文件大小变化回调
    @objc internal var fileSizeUpdateHandler: MNAssetUpdateHandler?
    
    /// 构造资源模型
    public override init() {
        super.init()
    }
    
    /// 构造资源模型
    /// - Parameter asset: 相册资源
    public convenience init(asset: PHAsset) {
        self.init()
        phAsset = asset
        type = asset.contentType
        duration = asset.duration
        identifier = asset.localIdentifier
    }
    
    /// 取消内容请求
    func cancelRequest() {
        MNAssetHelper.cancelRequest(self)
    }
    
    /// 取消内容下载请求
    func cancelDownload() {
        MNAssetHelper.cancelDownload(self)
    }
    
    /// 修改缩略图
    /// - Parameter cover: 缩略图
    func update(cover: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cover = cover
            self.coverUpdateHandler?(self)
        }
    }
    
    /// 修改来源
    /// - Parameter source: 来源
    func update(source: ResourceSource) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.source = source
            self.sourceUpdateHandler?(self)
        }
    }
    
    /// 修改文件大小
    /// - Parameter fileSize: 文件大小
    func update(fileSize: Int64) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.fileSize = fileSize
            self.fileSizeString = fileSize.mn.fileSizeString
            self.fileSizeUpdateHandler?(self)
        }
    }
    
    deinit {
        content = nil
        coverUpdateHandler = nil
        sourceUpdateHandler = nil
        fileSizeUpdateHandler = nil
        cancelRequest()
        cancelDownload()
    }
    
    /// 构造资源模型
    /// - Parameters:
    ///   - content: 文件内容
    ///   - options: 资源选项
    public convenience init?(content: Any, options: MNAssetPickerOptions? = nil) {
        self.init()
        isEnabled = true
        source = .local
        if let options = options { renderSize = options.renderSize }
        var filePath: String!
        if content is UIImage {
            // 图片
            let image = content as! UIImage
            if let images = image.images, images.count > 1 {
                type = .gif
                cover = images.first!.mn.resizing(to: max(renderSize.width, renderSize.height))
            } else {
                type = .photo
                cover = image.mn.resizing(to: max(renderSize.width, renderSize.height))
            }
            self.content = image
        } else if content is String {
            filePath = content as? String
        } else if content is URL, let url = content as? URL, url.isFileURL {
            filePath = url.path
        }
        if let filePath = filePath, FileManager.default.fileExists(atPath: filePath) {
            type = .video
            duration = MNAssetExporter.duration(mediaAtPath: filePath)
            cover = MNAssetExporter.thumbnail(videoAtPath: filePath)
            if let options = options, options.showFileSize, let attributes = try? FileManager.default.attributesOfItem(atPath: filePath), let fileSize = (attributes[FileAttributeKey.size] as? NSNumber)?.int64Value {
                self.fileSize = fileSize
            }
            self.content = filePath
        } else if #available(iOS 9.1, *) {
            if content is PHLivePhoto, let livePhoto = content as? PHLivePhoto, let videoURL = livePhoto.videoFileURL, let imageURL = livePhoto.imageFileURL {
                type = .livePhoto
                cover = UIImage(contentsOfFile: imageURL.mn.path)?.mn.resizing(to: max(renderSize.width, renderSize.height))
                if let options = options, options.showFileSize {
                    var fileSize: Int64 = 0
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: imageURL.mn.path), let imageFileSize = attributes[FileAttributeKey.size] as? Int64 {
                        fileSize += imageFileSize
                    }
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: videoURL.path), let videoFileSize = attributes[FileAttributeKey.size] as? Int64 {
                        fileSize += videoFileSize
                    }
                    self.fileSize = fileSize
                }
                self.content = livePhoto
            }
        }
        guard let _ = self.content else { return nil }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard super.isEqual(object) == false else { return true }
        guard let asset = object as? MNAsset else { return false }
        guard let localIdentifier = phAsset?.localIdentifier, let otherIdentifier = asset.phAsset?.localIdentifier else { return false }
        return localIdentifier == otherIdentifier
    }
}

extension MNAsset {
    
    /// 依据资源内容判定资源大小
    func updateFileSize() {
        guard let content = content else { return }
        var paths: [String] = [String]()
        switch type {
        case .video:
            paths.append(content as! String)
        case .livePhoto:
            if #available(iOS 9.1, *) {
                let livePhoto = content as! PHLivePhoto
                if let videoURL = livePhoto.videoFileURL, let imageURL = livePhoto.imageFileURL {
                    if #available(iOS 16.0, *) {
                        paths.append(videoURL.path(percentEncoded: false))
                        paths.append(imageURL.path(percentEncoded: false))
                    } else {
                        paths.append(videoURL.path)
                        paths.append(imageURL.path)
                    }
                }
            }
        default: break
        }
        var fileSize: Int64 = 0
        for path in paths {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                if let size = (attributes[FileAttributeKey.size] as? NSNumber)?.int64Value, size > 0 {
                    fileSize += size
                }
            } catch {}
        }
        if fileSize > 0 {
            update(fileSize: fileSize)
        }
    }
}
