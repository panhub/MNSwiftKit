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
public class MNAsset: NSObject, MNAssetBrowseSupported {
    
    /// 文件来源, 主要针对内部PHAsset
    @objc(MNAssetSource)
    public enum Source: Int {
        /// 未知
        case unknown
        /// 本地可用
        case local
        /// 云端
        case cloud
    }
    
    /// 本地标识
    @objc public var identifier: String = ""
    
    /// 内部标记是哪个Collection加载的资源
    @objc public var album: String = ""
    
    /// 文件类型
    @objc public var type: MNAssetType = .photo
    
    /// 来源
    @objc public var source: Source = .unknown
    
    /// 资源内容
    /// photo, gif: UIImage
    /// livePhoto: PHLivePhoto
    /// video: String路径
    @objc public var contents: Any?
    
    /// 封面渲染大小(不一定总是符合要求)
    @objc public var renderSize: CGSize = CGSize(width: 250.0, height: 250.0)
    
    /// 时长(仅视频资源有效)
    @objc public var duration: TimeInterval = 0.0
    
    /// 时长(duration的字符串表现形式)
    @objc public lazy var durationString: String = {
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
    
    /// 是否可选择
    @objc public var isEnabled: Bool = true
    
    /// 'Photos'框架下资源元数据
    @objc public var rawAsset: PHAsset!
    
    /// 是否是HDR资源
    @objc public var isHDR: Bool = false
    
    /// PHImageRequestID, 封面请求id
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
    @objc public var coverUpdateHandler: MNAssetUpdateHandler?
    
    /// 来源变化回调
    @objc public var sourceUpdateHandler: MNAssetUpdateHandler?
    
    /// 文件大小变化回调
    @objc public var fileSizeUpdateHandler: MNAssetUpdateHandler?
    
    
    /// 构造资源模型
    public override init() {
        super.init()
    }
    
    /// 构造资源模型
    /// - Parameter asset: 相册资源
    public convenience init(asset: PHAsset) {
        self.init()
        rawAsset = asset
        type = asset.mn.contentType
        duration = asset.duration
        identifier = asset.localIdentifier
        isHDR = asset.mediaSubtypes.contains(.photoHDR)
    }
    
    /// 取消内容请求
    public func cancelRequest() {
        MNAssetHelper.cancelRequest(self)
    }
    
    /// 取消内容下载请求
    public func cancelDownload() {
        MNAssetHelper.cancelDownload(self)
    }
    
    /// 更新缩略图
    /// - Parameter cover: 缩略图
    public func update(cover: UIImage?) {
        let executeHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.cover = cover
            if let coverUpdateHandler = self.coverUpdateHandler {
                coverUpdateHandler(self)
            }
        }
        if Thread.isMainThread {
            executeHandler()
        } else {
            DispatchQueue.main.async(execute: executeHandler)
        }
    }
    
    /// 更新来源
    /// - Parameter source: 来源
    public func update(source: MNAsset.Source) {
        let executeHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.source = source
            if let sourceUpdateHandler = self.sourceUpdateHandler {
                sourceUpdateHandler(self)
            }
        }
        if Thread.isMainThread {
            executeHandler()
        } else {
            DispatchQueue.main.async(execute: executeHandler)
        }
    }
    
    /// 更新文件大小
    /// - Parameter fileSize: 文件大小
    public func update(fileSize: Int64) {
        let executeHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.fileSize = fileSize
            self.fileSizeString = fileSize.mn.fileSizeString
            if let fileSizeUpdateHandler = self.fileSizeUpdateHandler {
                fileSizeUpdateHandler(self)
            }
        }
        if Thread.isMainThread {
            executeHandler()
        } else {
            DispatchQueue.main.async(execute: executeHandler)
        }
    }
    
    deinit {
        contents = nil
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
    public convenience init?(contents: Any, options: MNAssetPickerOptions? = nil) {
        self.init()
        if let options = options {
            renderSize = options.renderSize
        }
        var filePath: String!
        if contents is UIImage {
            // 图片
            let image = contents as! UIImage
            if let images = image.images, let first = images.first {
                type = .gif
                cover = first.mn.resizing(to: max(renderSize.width, renderSize.height))
            } else {
                type = .photo
                cover = image.mn.resizing(to: max(renderSize.width, renderSize.height))
            }
            self.contents = image
        } else if contents is String {
            filePath = contents as? String
        } else if contents is URL, let url = contents as? URL, url.isFileURL {
            filePath = url.mn.path
        }
        if let filePath = filePath, FileManager.default.fileExists(atPath: filePath) {
            type = .video
            cover = MNAssetExportSession.generateImage(for: filePath)
            duration = MNAssetExportSession.seconds(for: filePath)
            if let options = options, options.showFileSize, let attributes = try? FileManager.default.attributesOfItem(atPath: filePath), let fileSize = attributes[.size] as? Int64 {
                self.fileSize = fileSize
            }
            self.contents = filePath
        } else if #available(iOS 9.1, *) {
            if contents is PHLivePhoto, let livePhoto = contents as? PHLivePhoto, let videoURL = livePhoto.mn.videoFileURL, let imageURL = livePhoto.mn.imageFileURL {
                type = .livePhoto
                if let image = UIImage(contentsOfFile: imageURL.mn.path) {
                    cover = image.mn.resizing(to: max(renderSize.width, renderSize.height))
                }
                if let options = options, options.showFileSize {
                    var fileSize: Int64 = 0
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: imageURL.mn.path), let imageFileSize = attributes[.size] as? Int64 {
                        fileSize += imageFileSize
                    }
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: videoURL.path), let videoFileSize = attributes[.size] as? Int64 {
                        fileSize += videoFileSize
                    }
                    self.fileSize = fileSize
                }
                self.contents = livePhoto
            }
        }
        guard let _ = self.contents else { return nil }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if super.isEqual(object) { return true }
        guard let other = object as? MNAsset else { return false }
        if identifier == other.identifier, album == other.album { return true }
        return false
    }
}

extension MNAsset {
    
    /// 依据资源内容判定资源大小
    public func reloadFileSize() {
        guard let contents = contents else { return }
        var paths: [String] = []
        switch type {
        case .video:
            paths.append(contents as! String)
        case .livePhoto:
            if #available(iOS 9.1, *) {
                let livePhoto = contents as! PHLivePhoto
                if let videoURL = livePhoto.mn.videoFileURL, let imageURL = livePhoto.mn.imageFileURL {
                    paths.append(videoURL.mn.path)
                    paths.append(imageURL.mn.path)
                }
            }
        default: break
        }
        var fileSize: Int64 = 0
        for path in paths {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                if let size = attributes[.size] as? Int64 {
                    fileSize += size
                }
            } catch {
#if DEBUG
                print("查询文件大小出错: \(error)")
#endif
            }
        }
        if fileSize > 0 {
            update(fileSize: fileSize)
        }
    }
}
