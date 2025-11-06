//
//  MNAssetHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/28.
//  辅助方法

import UIKit
import Photos
import Foundation

public class MNAssetHelper {}

// MARK: - Collection
extension MNAssetHelper {
    
    /// 获取相簿
    /// - Parameters:
    ///   - options: 选择器配置模型
    ///   - completionHandler: 相簿集合 主线程调用
    public class func fetchAlbum(_ options: MNAssetPickerOptions, completion completionHandler: @escaping ([MNAssetAlbum])->Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var albums: [MNAssetAlbum] = [MNAssetAlbum]()
            let smartResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            smartResult.enumerateObjects { collection, _, stop in
                let album = MNAssetAlbum(collection: collection, options: options)
                albums.append(album)
                stop.pointee = true
            }
            if options.allowsPickingAlbum {
                let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
                fetchResult.enumerateObjects { collection, _, _ in
                    let album = MNAssetAlbum(collection: collection, options: options)
                    albums.append(album)
                }
            }
            DispatchQueue.main.async {
                completionHandler(albums)
            }
        }
    }
    
    /// 获取相簿内资源
    /// - Parameters:
    ///   - album: 相簿模型
    ///   - options: 选择器配置模型
    ///   - startHandler: 开始加载回调
    ///   - completionHandler: 结束回调 主线程调用
    public class func fetchAsset(in album: MNAssetAlbum, options: MNAssetPickerOptions, start startHandler: (()->Void)? = nil, completion completionHandler: @escaping ()->Void) {
        DispatchQueue.global().async {
            // 循环拉取直到满足分页数量
            var assets: [MNAsset] = []
            repeat {
                var offset = 0
                let fetchOptions = album.fetchOptions
                fetchOptions.setValue(album.offset, forKey: "fetchOffset")
                fetchOptions.fetchLimit = options.pageCount
                let result = PHAsset.fetchAssets(in: album.collection, options: fetchOptions)
                result.enumerateObjects { element, index, stop in
                    offset = index + 1
                    var type = element.mn.contentType
                    if type == .video {
                        let duration = element.duration
                        if (options.minExportDuration > 0.0 && duration < options.minExportDuration) || (options.maxExportDuration > 0.0 && duration > options.maxExportDuration && options.maxPickingCount > 1) { return }
                    } else if type == .gif {
                        guard options.allowsPickingGif else { return }
                        if options.usingPhotoPolicyPickingGif {
                            type = .photo
                        }
                    } else if type == .livePhoto {
                        guard options.allowsPickingLivePhoto else { return }
                        if options.usingPhotoPolicyPickingLivePhoto {
                            type = .photo
                        }
                    }
                    let asset = MNAsset()
                    asset.type = type
                    asset.rawAsset = element
                    asset.duration = element.duration
                    asset.identifier = element.localIdentifier
                    asset.renderSize = options.renderSize
                    assets.append(asset)
                    // 如果超过每页数量就终止
                    if assets.count >= options.pageCount {
                        stop.pointee = true
                    }
                }
                album.offset += offset
            } while (assets.count < options.pageCount && album.offset < album.count)
            DispatchQueue.main.async {
                if options.sortAscending {
                    album.assets.append(contentsOf: assets)
                } else {
                    album.assets.insert(contentsOf: assets.reversed(), at: 0)
                }
                completionHandler()
            }
        }
    }
}

// MARK: - Profile & Cover
extension MNAssetHelper {
    
    /// 请求封面(可能多次回调, 利用模型内部回调更新, 针对于内部相册使用)
    /// - Parameters:
    ///   - asset: 资源模型
    ///   - options: 选择器配置
    public class func fetchCover(_ asset: MNAsset, options: MNAssetPickerOptions) {
        // 缩略图
        if let _ = asset.cover {
            DispatchQueue.main.async {
                asset.coverUpdateHandler?(asset)
            }
            return
        }
        guard let rawAsset = asset.rawAsset else {
            DispatchQueue.main.async {
                asset.coverUpdateHandler?(asset)
            }
            return
        }
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .current
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .opportunistic
        requestOptions.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: rawAsset, targetSize: options.renderSize, contentMode: .aspectFit, options: requestOptions) { [weak asset] image, info in
            // 可能调用多次
            guard let asset = asset else { return }
            guard let image = image else { return }
            asset.update(cover: image)
        }
    }
    
    /// 请求封面(不改变模型数据, 只回调一次)
    /// - Parameters:
    ///   - asset: 资源模型
    ///   - completionHandler: 结束后回调
    public class func fetchCover(_ asset: MNAsset, completion completionHandler: ((MNAsset)->Void)?) {
        if let _ = asset.cover {
            DispatchQueue.main.async {
                completionHandler?(asset)
            }
            return
        }
        guard let rawAsset = asset.rawAsset else {
            DispatchQueue.main.async {
                completionHandler?(asset)
            }
            return
        }
        exportCover(rawAsset, target: .init(width: 300.0, height: 300.0)) { cover, _ in
            if let cover = cover {
                asset.cover = cover
            }
            completionHandler?(asset)
        }
    }
    
    /// 输出封面图片
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - size: 目标尺寸大小
    ///   - completionHandler: 封面回调 主线程
    @discardableResult
    public class func exportCover(_ asset: PHAsset, target size: CGSize, completion completionHandler: ((_ cover: UIImage?, _ error: Error?)->Void)?) -> PHImageRequestID {
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .current
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isNetworkAccessAllowed = true
        return PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: requestOptions) { image, info in
            guard let image = image else {
                var error: MNPickError = .exportError(.requestFailed)
                if let info = info {
                    if let cancelled = info[PHImageCancelledKey] as? Bool, cancelled {
                        error = .exportError(.cancelled)
#if DEBUG
                        print("已取消请求资源图片")
#endif
                    }
                    if let underlyingError = info[PHImageErrorKey] as? Error {
                        error = .exportError(.underlyingError(underlyingError))
#if DEBUG
                        print("请求资源图片出错: \(underlyingError)")
#endif
                    }
                }
                DispatchQueue.main.async {
                    completionHandler?(image, error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler?(image, nil)
            }
        }
    }
    
    /// 获取资源大小
    /// - Parameters:
    ///   - asset: 相册资源模型
    ///   - queue: 处理任务的队列
    public class func fetchFileSize(_ asset: MNAsset, on queue: DispatchQueue = .global(qos: .userInitiated)) {
        guard asset.fileSize <= 0 else {
            DispatchQueue.main.async {
                asset.fileSizeUpdateHandler?(asset)
            }
            return
        }
        guard let rawAsset = asset.rawAsset else {
            DispatchQueue.main.async {
                asset.fileSizeUpdateHandler?(asset)
            }
            return
        }
        exportFileSize(rawAsset, on: queue) { [weak asset] fileSize in
            guard let asset = asset else { return }
            asset.update(fileSize: fileSize)
        }
    }
    
    /// 输出资源大小
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - queue: 处理任务的队列
    ///   - completionHandler: 结果回调  主线程
    public class func exportFileSize(_ asset: PHAsset, on queue: DispatchQueue = .global(qos: .userInitiated), completion completionHandler: ((_ fileSize: Int64)->Void)?) {
        queue.async {
            var fileSize: Int64 = 0
            PHAssetResource.assetResources(for: asset).forEach { resource in
                if let value = resource.value(forKey: "fileSize") as? Int64 {
                    fileSize += value
                }
            }
            DispatchQueue.main.async {
                completionHandler?(fileSize)
            }
        }
    }
    
    /// 获取资源内容
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - progressHandler: 进度回调
    ///   - completionHandler: 结束回调 主线程
    public class func fetchContents(_ asset: MNAsset, progress progressHandler: ((_ asset: MNAsset, _ value: Double, _ error: Error?)->Void)?, completion completionHandler: ((_ asset: MNAsset)->Void)?) {
        if let _ = asset.contents {
            DispatchQueue.main.async {
                completionHandler?(asset)
            }
            return
        }
        guard let rawAsset = asset.rawAsset else {
            DispatchQueue.main.async {
                completionHandler?(asset)
            }
            return
        }
        let options = MNAssetPickerOptions()
        options.allowsExportVideo = false
        options.allowsExportLiveResource = false
        exportContents(rawAsset, options: options) { [weak asset] value, error in
            guard let asset = asset else { return }
            progressHandler?(asset, value, error)
        } completion: { [weak asset] contents, fileSize, error in
            guard let asset = asset else { return }
            if let contents = contents {
                asset.contents = contents
            }
            completionHandler?(asset)
        }
    }
    
    /// 导出资源内容
    /// - Parameters:
    ///   - asset: 相册资源
    ///   - options: 相册配置选项
    ///   - progressHandler: 进度回调 主线程
    ///   - completionHandler: 结果回调 主线程
    public class func exportContents(_ asset: PHAsset, options: MNAssetPickerOptions, progress progressHandler: ((_ value: Double, _ error: Error?)->Void)?, completion completionHandler: ((_ contents: Any?, _ fileSize: Int64, _ error: Error?)->Void)?) {
        let contentType = asset.mn.contentType
        switch contentType {
        case .video:
            let requestOptions = PHVideoRequestOptions()
            requestOptions.version = .current
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.progressHandler = { value, underlyingError, _, _ in
                var error: MNPickError?
                if let underlyingError = underlyingError {
                    error = .exportError(.underlyingError(underlyingError))
                }
                var progress = value
                if options.allowsExportVideo {
                    progress = min(value, 0.9)
                } else if let _ = options.videoExportURL {
                    progress = min(value, 0.95)
                }
                DispatchQueue.main.async {
                    progressHandler?(progress, error)
                }
            }
            if options.allowsExportVideo {
                PHImageManager.default().requestExportSession(forVideo: asset, options: requestOptions, exportPreset: options.videoExportPreset ?? AVAssetExportPresetMediumQuality) { exportSession, info in
                    guard let session = exportSession else {
                        var error: MNPickError = .exportError(.requestFailed)
                        if let info = info {
                            if let cancelled = info[PHImageCancelledKey] as? Bool, cancelled {
                                error = .exportError(.cancelled)
                            }
                            if let underlyingError = info[PHImageErrorKey] as? Error {
                                error = .exportError(.underlyingError(underlyingError))
#if DEBUG
                                print("导出视频内容失败: \(underlyingError)")
#endif
                            }
                        }
                        DispatchQueue.main.async {
                            completionHandler?(nil, 0, error)
                        }
                        return
                    }
                    let outputURL = MNAssetHelper.exportURL(options.videoExportURL, ext: "mp4")
                    let outputDirectory = outputURL.deletingLastPathComponent()
                    if FileManager.default.fileExists(atPath: outputDirectory.mn.path) == false {
                        do {
                            try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
                        } catch {
#if DEBUG
                            print("创建视频文件夹出错: \(error)")
#endif
                            DispatchQueue.main.async {
                                completionHandler?(nil, 0, MNPickError.exportError(.cannotCreateDirectory))
                            }
                            return
                        }
                    }
                    session.shouldOptimizeForNetworkUse = true
                    if #available(iOS 18.0, *) {
                        Task {
                            do {
                                try await session.export(to: outputURL, as: .mp4)
                                let outputPath = outputURL.mn.path
                                let fileSize = FileManager.default.mn.itemSize(atPath: outputPath)
                                DispatchQueue.main.async {
                                    progressHandler?(1.0, nil)
                                    completionHandler?(outputPath, fileSize, nil)
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    completionHandler?(nil, 0, MNPickError.exportError(.underlyingError(error)))
                                }
                            }
                        }
                    } else {
                        session.outputURL = outputURL
                        session.outputFileType = .mp4
                        session.exportAsynchronously { [weak session] in
                            guard let session = session else {
                                DispatchQueue.main.async {
                                    completionHandler?(nil, 0, MNPickError.exportError(.requestFailed))
                                }
                                return
                            }
                            switch session.status {
                            case .completed:
                                let outputPath = outputURL.mn.path
                                let fileSize = FileManager.default.mn.itemSize(atPath: outputPath)
                                DispatchQueue.main.async {
                                    progressHandler?(1.0, nil)
                                    completionHandler?(outputPath, fileSize, nil)
                                }
                            case .cancelled:
                                DispatchQueue.main.async {
                                    completionHandler?(nil, 0, MNPickError.exportError(.cancelled))
                                }
                            default:
                                var error: MNPickError = .exportError(.requestFailed)
                                if let underlyingError = session.error {
                                    error = .exportError(.underlyingError(underlyingError))
#if DEBUG
                                    print("视频转码失败: \(underlyingError)")
#endif
                                }
                                DispatchQueue.main.async {
                                    completionHandler?(nil, 0, error)
                                }
                            }
                        }
                    }
                }
            } else {
                PHImageManager.default().requestAVAsset(forVideo: asset, options: requestOptions) { videoAsset, _, info in
                    guard let videoAsset = videoAsset as? AVURLAsset else {
                        var error: MNPickError = .exportError(.requestFailed)
                        if let info = info {
                            if let cancelled = info[PHImageCancelledKey] as? Bool, cancelled {
                                error = .exportError(.cancelled)
                            }
                            if let underlyingError = info[PHImageErrorKey] as? Error {
                                error = .exportError(.underlyingError(underlyingError))
#if DEBUG
                                print("导出视频内容失败: \(underlyingError)")
#endif
                            }
                        }
                        DispatchQueue.main.async {
                            completionHandler?(nil, 0, error)
                        }
                        return
                    }
                    let videoUrl = videoAsset.url
                    guard let videoExportURL = options.videoExportURL else {
                        let targetPath = videoUrl.mn.path
                        let fileSize = FileManager.default.mn.itemSize(atPath: targetPath)
                        DispatchQueue.main.async {
                            completionHandler?(targetPath, fileSize, nil)
                        }
                        return
                    }
                    // 拷贝视频到指定位置
                    let targetUrl = MNAssetHelper.exportURL(videoExportURL, ext: videoUrl.pathExtension.lowercased())
                    let targetDirectory = targetUrl.deletingLastPathComponent()
                    if FileManager.default.fileExists(atPath: targetDirectory.mn.path) == false {
                        do {
                            try FileManager.default.createDirectory(at: targetDirectory, withIntermediateDirectories: true)
                        } catch {
#if DEBUG
                            print("创建视频文件夹出错: \(error)")
#endif
                            DispatchQueue.main.async {
                                completionHandler?(nil, 0, MNPickError.exportError(.cannotCreateDirectory))
                            }
                            return
                        }
                    }
                    do {
                        try FileManager.default.copyItem(at: videoUrl, to: targetUrl)
                    } catch {
#if DEBUG
                        print("拷贝视频失败: \(error)")
#endif
                        DispatchQueue.main.async {
                            completionHandler?(nil, 0, MNPickError.exportError(.cannotCopyFile))
                        }
                        return
                    }
                    let targetPath = targetUrl.mn.path
                    let fileSize = FileManager.default.mn.itemSize(atPath: targetPath)
                    DispatchQueue.main.async {
                        progressHandler?(1.0, nil)
                        completionHandler?(targetPath, fileSize, nil)
                    }
                }
            }
        case .livePhoto:
            guard #available(iOS 9.1, *) else {
                DispatchQueue.main.async {
                    completionHandler?(nil, 0, MNPickError.exportError(.notSupportedForAsset))
                }
                return
            }
            let requestOptions = PHLivePhotoRequestOptions()
            requestOptions.version = .current
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.progressHandler = { value, underlyingError, _, _ in
                var error: MNPickError?
                if let underlyingError = underlyingError {
                    error = .exportError(.underlyingError(underlyingError))
                }
                var progress = value
                if options.allowsExportLiveResource {
                    progress = min(value, 0.9)
                }
                DispatchQueue.main.async {
                    progressHandler?(progress, error)
                }
            }
            PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { livePhoto, info in
                guard let livePhoto = livePhoto else {
                    var error: MNPickError = .exportError(.requestFailed)
                    if let info = info {
                        if let cancelled = info[PHImageCancelledKey] as? Bool, cancelled {
                            error = .exportError(.cancelled)
                        }
                        if let underlyingError = info[PHImageErrorKey] as? Error {
                            error = .exportError(.underlyingError(underlyingError))
#if DEBUG
                            print("导出LivePhoto失败: \(underlyingError)")
#endif
                        }
                    }
                    DispatchQueue.main.async {
                        completionHandler?(nil, 0, error)
                    }
                    return
                }
                if options.allowsExportLiveResource {
                    let videoUrl = MNAssetHelper.exportURL(nil, ext: asset.mn.videoFilename?.mn.pathExtension ?? "mov")
                    let imageUrl = MNAssetHelper.exportURL(nil, ext: asset.mn.imageFilename?.mn.pathExtension ?? "jpg")
                    MNAssetHelper.exportLivePhoto(livePhoto, imageUrl: imageUrl, videoUrl: videoUrl) { isSuccess, error in
                        if isSuccess {
                            livePhoto.mn.videoFileURL = videoUrl
                            livePhoto.mn.imageFileURL = imageUrl
                            let videoFileSize = FileManager.default.mn.itemSize(at: videoUrl)
                            let imageFileSize = FileManager.default.mn.itemSize(at: imageUrl)
                            progressHandler?(1.0, nil)
                            completionHandler?(livePhoto, videoFileSize + imageFileSize, nil)
                        } else {
                            completionHandler?(nil, 0, error)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler?(livePhoto, 0, nil)
                    }
                }
            }
        case .gif, .photo:
            let requestOptions = PHImageRequestOptions()
            requestOptions.version = .current
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .highQualityFormat
            requestOptions.progressHandler = { value, underlyingError, _, _ in
                var error: MNPickError?
                if let underlyingError = underlyingError {
                    error = .exportError(.underlyingError(underlyingError))
                }
                DispatchQueue.main.async {
                    progressHandler?(value, error)
                }
            }
            let resultHandler: (Data?, String?, Any, [AnyHashable : Any]?) -> Void = { imageData, _, _, info in
                guard let imageData = imageData else {
                    var error: MNPickError = .exportError(.requestFailed)
                    if let info = info {
                        if let cancelled = info[PHImageCancelledKey] as? Bool, cancelled {
                            error = .exportError(.cancelled)
                        }
                        if let underlyingError = info[PHImageErrorKey] as? Error {
                            error = .exportError(.underlyingError(underlyingError))
#if DEBUG
                            print("导出图片数据失败: \(underlyingError)")
#endif
                        }
                    }
                    DispatchQueue.main.async {
                        completionHandler?(nil, 0, error)
                    }
                    return
                }
                var image: UIImage?
                var fileSize: Int64 = 0
                var error: MNPickError?
                if let result = contentType == .gif ? UIImage.mn.image(contentsOfData: imageData) : UIImage(data: imageData) {
                    var isAllowCompress: Bool = false
                    if result.mn.isAnimatedImage {
                        image = result
                        fileSize = Int64(imageData.count)
                    } else if #available(iOS 10.0, *), options.allowsExportHeifc == false, (asset.mn.isHeic || asset.mn.isHeif) {
                        // 判断是否需要转化heif/heic格式图片
                        if let ciImage = CIImage(data: imageData),
                           let colorSpace = ciImage.colorSpace,
                           let jpgData = CIContext().jpegRepresentation(of: ciImage, colorSpace: colorSpace, options: [CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String):max(min(options.compressionQuality, 1.0), 0.1)]),
                           let jpgImage = UIImage(data: jpgData)?.mn.resized {
                            image = jpgImage
                            fileSize = Int64(jpgData.count)
                        }
                    } else {
                        isAllowCompress = true
                        image = result.mn.resized
                        fileSize = Int64(imageData.count)
                    }
                    if isAllowCompress, options.compressionQuality < 1.0, let compressionImage = image?.mn.resizing(to: 1280.0, quality: max(options.compressionQuality, 0.5), fileSize: &fileSize) {
                        image = compressionImage
                    }
                }
                if image == nil {
                    error = .exportError(.requestFailed)
                }
                DispatchQueue.main.async {
                    completionHandler?(image, fileSize, error)
                }
            }
            if #available(iOS 13.0, *) {
                PHImageManager.default().requestImageDataAndOrientation(for: asset, options: requestOptions, resultHandler: resultHandler)
            } else {
                PHImageManager.default().requestImageData(for: asset, options: requestOptions, resultHandler: resultHandler)
            }
        }
    }
}

// MARK: - Export
extension MNAssetHelper {
    
    /// 异步导出一组资源内容
    /// - Parameters:
    ///   - assets: 资源模型集合
    ///   - options: 选择器配置模型
    ///   - progressHandler: 进度回调
    ///   - completionHandler: 结束回调
    public class func exportAsynchronously(_ assets: [MNAsset], options: MNAssetPickerOptions, progress progressHandler: ((Int, Int)->Void)?, completion completionHandler: @escaping ([MNAsset])->Void) {
        
        MNAssetHelper.exportRecursively(assets, index: 0, options: options, container: [], progress: progressHandler, completion: completionHandler)
    }
    
    /// 递归导出资源内容
    /// - Parameters:
    ///   - assets: 资源集合
    ///   - index: 需要导出的资源索引
    ///   - options: 选择器配置模型
    ///   - container: 已成功导出的资源集合
    ///   - progressHandler: 进度回调
    ///   - completionHandler: 结束回调
    private class func exportRecursively(_ assets: [MNAsset], index: Int, options: MNAssetPickerOptions, container: [MNAsset], progress progressHandler: ((_ current: Int, _ count: Int)->Void)?, completion completionHandler: @escaping ([MNAsset])->Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // 超出则结束
            guard index < assets.count else {
                DispatchQueue.main.async {
                    completionHandler(container)
                }
                return
            }
            // 回调进度
            DispatchQueue.main.async {
                progressHandler?(index + 1, assets.count)
            }
            // 获取内容
            let asset: MNAsset = assets[index]
            guard let rawAsset = asset.rawAsset else {
                DispatchQueue.main.async {
                    MNAssetHelper.exportRecursively(assets, index: index + 1, options: options, container: container, progress: progressHandler, completion: completionHandler)
                }
                return
            }
            MNAssetHelper.exportContents(rawAsset, options: options, progress: nil) { contents, fileSize, error in
                var elements: [MNAsset] = container
                if let _ = contents {
                    asset.update(fileSize: fileSize)
                    elements.append(asset)
                }
                MNAssetHelper.exportRecursively(assets, index: index + 1, options: options, container: elements, progress: progressHandler, completion: completionHandler)
            }
        }
    }
}

// MARK: - URL
extension MNAssetHelper {
    
    /// 默认的资源导出目录
    private class var exportDirectory: String {
        
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/AssetPicker"
    }
    
    /// 获取资源导出路径
    /// - Parameter pathExtension: 后缀名
    private class func exportURL(_ url: URL?, ext: String) -> URL {
        if let url = url {
            if FileManager.default.fileExists(atPath: url.mn.path) {
                return url.deletingLastPathComponent().appendingPathComponent(UUID().uuidString).appendingPathExtension(url.pathExtension)
            }
            return url
        }
        return URL(fileAtPath: exportDirectory).appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
    }
}

// MARK: - Cancel
extension MNAssetHelper {
    
    /// 取消资源请求
    /// - Parameter asset: 资源模型
    public class func cancelRequest(_ asset: MNAsset) {
        let executeHandler: ()->Void = {
            let requestId = asset.requestId
            if requestId == PHInvalidImageRequestID { return }
            asset.requestId = PHInvalidImageRequestID
            PHImageManager.default().cancelImageRequest(requestId)
        }
        if Thread.isMainThread {
            executeHandler()
        } else {
            DispatchQueue.main.async(execute: executeHandler)
        }
    }
    
    /// 取消资源下载
    /// - Parameter asset: 资源模型
    public class func cancelDownload(_ asset: MNAsset) {
        let executeHandler: ()->Void = {
            let downloadId = asset.downloadId
            if downloadId == PHInvalidImageRequestID { return }
            asset.downloadId = PHInvalidImageRequestID
            PHImageManager.default().cancelImageRequest(downloadId)
        }
        if Thread.isMainThread {
            executeHandler()
        } else {
            DispatchQueue.main.async(execute: executeHandler)
        }
    }
}

// MARK: - Delete & Write to system album
extension MNAssetHelper {
    
    /// 删除相册内资源
    /// - Parameters:
    ///   - assets: 相册资源集合
    ///   - completion: 结束回调
    public class func deleteAssets(_ assets: [PHAsset], completion: ((_ error: Error?)->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard assets.isEmpty == false else {
                DispatchQueue.main.async {
                    completion?(MNPickError.deleteError(.fileIsEmpty))
                }
                return
            }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
            } completionHandler: { isSuccess, error in
                DispatchQueue.main.async {
                    if isSuccess {
                        completion?(nil)
                    } else if let error = error {
                        completion?(MNPickError.deleteError(.underlyingError(error)))
                    } else {
                        completion?(MNPickError.deleteError(.unknown))
                    }
                }
            }
        }
    }
    
    /// 保存图片到系统相册
    /// - Parameters:
    ///   - image: 图片
    ///   - completion: 结束回调
    public class func writeImage(toAlbum image: Any, completion: ((_ identifier: String?, _ error: Error?)->Void)?) {
        writeAssets([image], toAlbum: nil) { identifiers, error in
            completion?(identifiers?.first, error)
        }
    }
    
    /// 保存视频到系统相册
    /// - Parameters:
    ///   - video: 视频路径
    ///   - completion: 结束回调
    public class func writeVideo(toAlbum video: Any, completion: ((_ identifier: String?, _ error: Error?)->Void)?) {
        writeAssets([video], toAlbum: nil) { identifiers, error in
            completion?(identifiers?.first, error)
        }
    }
    
    /// 保存LivePhoto到系统相册
    /// - Parameters:
    ///   - livePhoto: LivePhoto
    ///   - completion: 结束回调
    @available(iOS 9.1, *)
    public class func writeLivePhoto(toAlbum livePhoto: PHLivePhoto, completion: ((_ identifier: String?, _ error: Error?)->Void)?) {
        writeAssets([livePhoto], toAlbum: nil) { identifiers, error in
            completion?(identifiers?.first, error)
        }
    }
    
    /// 保存本地资源到系统相册
    /// - Parameters:
    ///   - assets: 资源集合
    ///   - name: 相册名称
    ///   - completion: 结束回调
    public class func writeAssets(_ assets: [Any], toAlbum name: String? = nil, completion: ((_ identifiers: [String]?, _ error: Error?)->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var identifiers: [String] = [String]()
            var placeholders: [PHObjectPlaceholder] = [PHObjectPlaceholder]()
            PHPhotoLibrary.shared().performChanges {
                for var asset in assets {
                    // 转换资源
                    if asset is String {
                        guard let path = asset as? String, FileManager.default.fileExists(atPath: path) else { continue }
                        asset = URL(fileAtPath: path) as AnyObject
                    } else if asset is Data {
                        guard let image = UIImage(data: asset as! Data) else { continue }
                        asset = image
                    }
                    // 图片/视频
                    var placeholder: PHObjectPlaceholder?
                    if asset is UIImage {
                        placeholder = PHAssetChangeRequest.creationRequestForAsset(from: asset as! UIImage).placeholderForCreatedAsset
                    } else if asset is URL {
                        guard let url = asset as? URL, url.isFileURL, FileManager.default.fileExists(atPath: url.mn.path) else { continue }
                        if ["mp4", "mov", "3gp"].contains(url.pathExtension.lowercased()) {
                            placeholder = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)?.placeholderForCreatedAsset
                        } else if ["jpg", "png", "jpeg", "gif", "heic", "heif"].contains(url.pathExtension.lowercased()) {
                            placeholder = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)?.placeholderForCreatedAsset
                        }
                    }
                    // LivePhoto
                    if #available(iOS 9.1, *) {
                        if asset is PHLivePhoto {
                            let videoURL = (asset as? PHLivePhoto)?.mn.videoFileURL
                            let imageURL = (asset as? PHLivePhoto)?.mn.imageFileURL
                            guard let videoURL = videoURL, FileManager.default.fileExists(atPath: videoURL.mn.path), let imageURL = imageURL, FileManager.default.fileExists(atPath: imageURL.mn.path) else { continue }
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: videoURL, options: nil)
                            request.addResource(with: .photo, fileURL: imageURL, options: nil)
                            placeholder = request.placeholderForCreatedAsset
                        } else if asset is [MNLivePhotoResourceKey:AnyObject] {
                            guard let dictionary = asset as? [MNLivePhotoResourceKey:AnyObject] else { continue }
                            var videoURL: URL?, imageURL: URL?
                            if let path = dictionary[MNLivePhotoImageUrlKey] as? String, FileManager.default.fileExists(atPath: path) {
                                if (path as NSString).pathExtension.lowercased() == "jpg" || (path as NSString).pathExtension.lowercased() == "jpeg" {
                                    imageURL = URL(fileAtPath: path)
                                }
                            } else if let url = dictionary[MNLivePhotoImageUrlKey] as? URL, FileManager.default.fileExists(atPath: url.mn.path) {
                                if url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" {
                                    imageURL = url
                                }
                            }
                            if let path = dictionary[MNLivePhotoVideoUrlKey] as? String, FileManager.default.fileExists(atPath: path), (path as NSString).pathExtension.lowercased() == "mov" {
                                videoURL = URL(fileAtPath: path)
                            } else if let url = dictionary[MNLivePhotoVideoUrlKey] as? URL, FileManager.default.fileExists(atPath: url.mn.path), url.pathExtension.lowercased() == "mov" {
                                videoURL = url
                            }
                            guard let videoURL = videoURL, let imageURL = imageURL else { continue }
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: videoURL, options: nil)
                            request.addResource(with: .photo, fileURL: imageURL, options: nil)
                            placeholder = request.placeholderForCreatedAsset
                        } else if asset is [AnyObject] {
                            guard let array = asset as? [AnyObject], array.count == 2 else { continue }
                            var videoURL: URL?, imageURL: URL?
                            for item in array {
                                if item is String {
                                    guard let path = item as? String, FileManager.default.fileExists(atPath: path) else { continue }
                                    if (path as NSString).pathExtension.lowercased() == "mov" {
                                        videoURL = URL(fileAtPath: path)
                                    } else if (path as NSString).pathExtension.lowercased() == "jpg" || (path as NSString).pathExtension.lowercased() == "jpeg" {
                                        imageURL = URL(fileAtPath: path)
                                    }
                                } else if item is URL {
                                    guard let url = item as? URL, FileManager.default.fileExists(atPath: url.mn.path) else { continue }
                                    if url.pathExtension.lowercased() == "mov" {
                                        videoURL = url
                                    } else if url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" {
                                        imageURL = url
                                    }
                                }
                            }
                            guard let videoURL = videoURL, let imageURL = imageURL else { continue }
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: videoURL, options: nil)
                            request.addResource(with: .photo, fileURL: imageURL, options: nil)
                            placeholder = request.placeholderForCreatedAsset
                        }
                    }
                    guard let placeholder = placeholder else { continue }
                    placeholders.append(placeholder)
                    identifiers.append(placeholder.localIdentifier)
                }
                if placeholders.isEmpty == false {
                    MNAssetHelper.creationRequestForAssetCollection(with: name)?.addAssets(placeholders as NSFastEnumeration)
                }
            } completionHandler: { isSuccess, error in
                DispatchQueue.main.async {
                    if isSuccess {
                        completion?(identifiers, nil)
                    } else if let error = error {
                        completion?(nil, MNPickError.writeError(.underlyingError(error)))
                    } else {
                        completion?(nil, MNPickError.writeError(.unknown))
                    }
                }
            }
        }
    }
    
    private class func creationRequestForAssetCollection(with name: String? = nil) -> PHAssetCollectionChangeRequest? {
        var collection: PHAssetCollection?
        var title: String = name ?? ""
        title = title.isEmpty ? ((Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? "新建相簿") : title
        // 寻找相簿
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        result.enumerateObjects { obj, _, stop in
            if let localizedTitle = obj.localizedTitle, localizedTitle == title {
                collection = obj
                stop.pointee = true
            }
        }
        guard let collection = collection else {
            return PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
        }
        return PHAssetCollectionChangeRequest(for: collection)
    }
}

// MARK: - LivePhoto
@available(iOS 9.1, *)
extension MNAssetHelper {
    
    /// 请求LivePhoto
    /// - Parameters:
    ///   - urls: LivePhoto的视频和图片资源地址
    ///   - completion: 结束回调
    public class func requestLivePhoto(resourceFileURLs urls: [URL], completion: ((PHLivePhoto?, Error?)->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var videoURL: URL?
            var imageURL: URL?
            for url in urls {
                guard url.isFileURL, FileManager.default.fileExists(atPath: url.mn.path) else { continue }
                let pathExtension = url.pathExtension.lowercased()
                try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                if pathExtension == "mov" {
                    videoURL = url
                } else if pathExtension == "jpeg" || pathExtension == "jpg" {
                    imageURL = url
                }
            }
            guard let video = videoURL, let image = imageURL else {
                DispatchQueue.main.async {
                    completion?(nil, MNPickError.exportError(.fileNotExist))
                }
                return
            }
            PHLivePhoto.request(withResourceFileURLs: [video, image], placeholderImage: nil, targetSize: .zero, contentMode: .aspectFit) { livePhoto, info in
                DispatchQueue.main.async {
                    if let livePhoto = livePhoto {
                        // 可能会多次调用, 返回衰退LivePhoto
                        if let degraded = info[PHLivePhotoInfoIsDegradedKey] as? Bool, degraded { return }
                        livePhoto.mn.videoFileURL = video
                        livePhoto.mn.imageFileURL = image
                        completion?(livePhoto, nil)
                    } else if let error = info[PHLivePhotoInfoErrorKey] as? Error {
                        completion?(nil, MNPickError.exportError(.underlyingError(error)))
                    } else {
                        completion?(nil, MNPickError.exportError(.requestFailed))
                    }
                }
            }
        }
    }
    
    
    /// 导出LivePhoto视频和图片资源
    /// - Parameters:
    ///   - livePhoto: livePhoto对象
    ///   - completion: 结束回调
    public class func exportLivePhoto(_ livePhoto: PHLivePhoto, completion: ((_ imageUrl: URL?, _ videoUrl: URL?, _ error: Error?)->Void)?) {
        let videoUrl = exportURL(nil, ext: "mov")
        let imageUrl = exportURL(nil, ext: "jpg")
        exportLivePhoto(livePhoto, imageUrl: imageUrl, videoUrl: videoUrl) { isSuccess, error in
            if isSuccess {
                completion?(imageUrl, videoUrl, nil)
            } else {
                completion?(nil, nil, error)
            }
        }
    }
    
    /// 导出LivePhoto视频和图片资源到指定位置
    /// - Parameters:
    ///   - livePhoto: livePhoto对象
    ///   - imageUrl: 图片资源保存位置
    ///   - videoUrl: 视频资源保存位置
    ///   - completion: 结束回调
    public class func exportLivePhoto(_ livePhoto: PHLivePhoto, imageUrl: URL, videoUrl: URL, completion: ((_ isSuccess: Bool, _ error: Error?)->Void)?) {
        for url in [imageUrl, videoUrl] {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        var underlyingError: MNPickError?
        let group = DispatchGroup()
        let resources = PHAssetResource.assetResources(for: livePhoto)
        for resource in resources {
            group.enter()
            var contents = Data()
            let type = resource.type
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            PHAssetResourceManager.default().requestData(for: resource, options: options) { data in
                contents.append(data)
            } completionHandler: { error in
                if let error = error {
                    underlyingError = .exportError(.underlyingError(error))
                } else {
                    do {
                        try contents.write(to: type == .pairedVideo ? videoUrl : imageUrl, options: .atomic)
                    } catch {
                        underlyingError = .exportError(.underlyingError(error))
#if DEBUG
                        print("写入LivePhoto组件文件失败: \(error)")
#endif
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if let error = underlyingError {
                try? FileManager.default.removeItem(at: videoUrl)
                try? FileManager.default.removeItem(at: imageUrl)
                completion?(false, error)
            } else {
                completion?(true, nil)
            }
        }
    }
}
