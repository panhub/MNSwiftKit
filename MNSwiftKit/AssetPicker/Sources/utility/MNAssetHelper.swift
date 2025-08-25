//
//  MNAssetHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/28.
//  辅助方法

import UIKit
import Photos
import Foundation
//#if canImport(MNSwiftKitAnimatedImage)
//import MNSwiftKitAnimatedImage
//#endif

class MNAssetHelper {
    
    /// 内部构造唯一入口
    fileprivate static let helper: MNAssetHelper = MNAssetHelper()
    
    /// 视频请求配置
    fileprivate lazy var videoOptions: PHVideoRequestOptions = {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        return options
    }()
    
    /// 图片请求配置
    fileprivate lazy var imageOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .fast
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        return options
    }()
    
    /// LivePhoto请求配置
    fileprivate lazy var livePhotoOptions: NSObject? = {
        guard #available(iOS 9.1, *) else { return nil }
        let options = PHLivePhotoRequestOptions()
        options.version = .current
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        return options
    }()
    
    /// 禁止外部直接构造
    private init() {}
}

// MARK: - Get Collection
extension MNAssetHelper {
    
    /// 获取相簿
    /// - Parameters:
    ///   - options: 选择器配置模型
    ///   - completionHandler: 相簿集合结果回调
    class func fetchAlbum(_ options: MNAssetPickerOptions, completion completionHandler: @escaping ([MNAssetAlbum])->Void) {
        DispatchQueue.global().async {
            var albums: [MNAssetAlbum] = [MNAssetAlbum]()
            let smartResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            smartResult.enumerateObjects { collection, _, stop in
                if collection.isCameraRoll {
                    let album = MNAssetAlbum(collection: collection, options: options)
                    albums.append(album)
                    stop.pointee = true
                }
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
    ///   - completionHandler: 结束回调
    class func fetchAsset(in album: MNAssetAlbum, options: MNAssetPickerOptions, start startHandler: (()->Void)? = nil, completion completionHandler: @escaping ()->Void) {
        DispatchQueue.global().async {
            /// 循环取直到满足分页数量
            var assets = [MNAsset]()
            let pageCount = options.pageCount
            let fetchOptions = album.fetchOptions
            repeat {
                if album.offset > 0 {
                    fetchOptions.setValue(album.offset, forKey: "fetchOffset")
                }
                album.offset += pageCount
                fetchOptions.fetchLimit = pageCount
                let result = PHAsset.fetchAssets(in: album.collection, options: fetchOptions)
                result.enumerateObjects { element, _, _ in
                    var type = element.contentType
                    if type == .video {
                        let duration: TimeInterval = floor(element.duration)
                        if (options.minExportDuration > 0.0 && duration < options.minExportDuration) || (options.maxExportDuration > 0.0 && duration > options.maxExportDuration && (options.allowsEditing == false || options.maxPickingCount > 1 || options.allowsMultiplePickingVideo == false)) { return }
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
                    asset.phAsset = element
                    asset.duration = element.duration
                    asset.identifier = element.localIdentifier
                    asset.renderSize = options.renderSize
                    assets.append(asset)
                }
            } while (assets.count < pageCount && album.offset < album.count)
            // 更新页码后回调
            album.page += 1
            if options.sortAscending {
                album.assets.append(contentsOf: assets)
            } else {
                album.assets.insert(contentsOf: assets.reversed(), at: 0)
            }
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}

// MARK: - Get Thumbnail
extension MNAssetHelper {
    
    /// 请求描述信息(触发多次回调, 更新资源)
    /// - Parameters:
    ///   - asset: 资源模型
    ///   - options: 选择器配置
    class func fetchProfile(_ asset: MNAsset, options: MNAssetPickerOptions) {
        // 缩略图
        if let _ = asset.cover {
            asset.coverUpdateHandler?(asset)
        } else {
            guard let phAsset = asset.phAsset else { return }
            let imageOptions = MNAssetHelper.helper.imageOptions
            imageOptions.resizeMode = .fast
            imageOptions.deliveryMode = .opportunistic
            imageOptions.isNetworkAccessAllowed = true
            asset.requestId = PHImageManager.default().requestImage(for: phAsset, targetSize: asset.renderSize, contentMode: .aspectFill, options: imageOptions) { [weak asset] result, info in
                // 可能调用多次
                guard let asset = asset else { return }
                let isCancelled: Bool = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue ?? false
                guard isCancelled == false else { return }
                guard let result = result else { return }
                let image = result.mn_picker.resized
                let isDegraded: Bool = (info?[PHImageResultIsDegradedKey] as? NSNumber)?.boolValue ?? false
                asset.update(cover: image)
                if isDegraded == false {
                    // 衰减图片
                    asset.requestId = PHInvalidImageRequestID
                }
            }
        }
        // 源文件是否是云端/文件大小
        if asset.source == .unknown {
            options.queue.async { [weak options] in
                var isClould: Bool = false
                guard let phAsset = asset.phAsset else { return }
                let resources = PHAssetResource.assetResources(for: phAsset)
                if let resource = resources.first {
                    isClould = (resource.value(forKey: "locallyAvailable") as? Bool ?? true) == false
                }
                asset.update(source: isClould ? .cloud : .local)
                if let options = options, options.showFileSize, asset.fileSize <= 0, isClould == false {
                    // 获取大小
                    var fileSize: Int64 = 0
                    for resource in resources {
                        fileSize += (resource.value(forKey: "fileSize") as? Int64 ?? 0)
                    }
                    asset.update(fileSize: fileSize)
                }
            }
        }
    }
    
    /// 请求缩略图
    /// - Parameters:
    ///   - asset: 资源模型
    ///   - completionHandler: 结束后回调
    class func fetchCover(_ asset: MNAsset, completion completionHandler: ((MNAsset, UIImage?)->Void)?) {
        if let image = asset.cover {
            completionHandler?(asset, image)
            return
        }
        guard let phAsset = asset.phAsset else {
            completionHandler?(asset, nil)
            return
        }
        let options = MNAssetHelper.helper.imageOptions
        options.resizeMode = .fast
        options.deliveryMode = .fastFormat
        options.isNetworkAccessAllowed = true
        asset.requestId = PHImageManager.default().requestImage(for: phAsset, targetSize: asset.renderSize, contentMode: .aspectFill, options: options) { [weak asset] result, info in
            guard let asset = asset else { return }
            let isCancelled: Bool = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue ?? false
            guard isCancelled == false else { return }
            asset.requestId = PHInvalidImageRequestID
            guard let result = result else { return }
            let image = result.mn_picker.resized
            DispatchQueue.main.async {
                completionHandler?(asset, image)
            }
        }
    }
}

// MARK: - Content
extension MNAssetHelper {
    
    /// 请求资源内容
    /// - Parameters:
    ///   - asset: 资源模型
    ///   - progressHandler: 进度回调
    ///   - completionHandler: 结果回调
    class func fetchContent(_ asset: MNAsset, progress progressHandler: ((Double, Error?, MNAsset)->Void)?, completion completionHandler: ((MNAsset)->Void)?) {
        if let _ = asset.content {
            completionHandler?(asset)
            return
        }
        guard let phAsset = asset.phAsset else {
            progressHandler?(0.0, nil, asset)
            completionHandler?(asset)
            return
        }
        switch asset.type {
        case .video:
            let options = MNAssetHelper.helper.videoOptions
            options.version = .current
            options.deliveryMode = .automatic
            options.isNetworkAccessAllowed = true
            options.progressHandler = { progress, error, _, _ in
                DispatchQueue.main.async {
                    asset.progress = progress
                    progressHandler?(progress, error, asset)
                }
            }
            asset.downloadId = PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { [weak asset] result, _, info in
                guard let asset = asset else { return }
                asset.progress = 0.0
                asset.downloadId = PHInvalidImageRequestID
                let isCancelled: Bool = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue ?? false
                guard isCancelled == false else { return }
                if let avAsset = result as? AVURLAsset {
                    asset.content = avAsset.url.path
                }
                DispatchQueue.main.async {
                    completionHandler?(asset)
                }
            }
        case .livePhoto:
            guard #available(iOS 9.1, *) else { break }
            guard let options = MNAssetHelper.helper.livePhotoOptions as? PHLivePhotoRequestOptions else { break }
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.progressHandler = { progress, error, _, _ in
                DispatchQueue.main.async {
                    asset.progress = progress
                    progressHandler?(progress, error, asset)
                }
            }
            asset.downloadId = PHImageManager.default().requestLivePhoto(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { [weak asset] result, info in
                guard let asset = asset else { return }
                asset.progress = 0.0
                asset.downloadId = PHInvalidImageRequestID
                let isCancelled: Bool = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue ?? false
                guard isCancelled == false else { return }
                if let livePhoto = result {
                    asset.content = livePhoto
                }
                DispatchQueue.main.async {
                    completionHandler?(asset)
                }
            }
        default:
            let options = MNAssetHelper.helper.imageOptions
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.progressHandler = { progress, error, _, _ in
                DispatchQueue.main.async {
                    asset.progress = progress
                    progressHandler?(progress, error, asset)
                }
            }
            let resultHandler: (Data?, String?, Any, [AnyHashable : Any]?) -> Void = { [weak asset] imageData, _, _, info in
                guard let asset = asset else { return }
                asset.progress = 0.0
                asset.downloadId = PHInvalidImageRequestID
                let isCancelled: Bool = (info?[PHImageCancelledKey] as? NSNumber)?.boolValue ?? false
                guard isCancelled == false else { return }
                let result: UIImage? = asset.type == .gif ? UIImage.image(contentsOfData: imageData) : (imageData == nil ? nil : UIImage(data: imageData!))
                if let image = result {
                    if image.isAnimatedImage {
                        asset.content = image
                    } else {
                        asset.content = image.mn_picker.resized
                    }
                }
                DispatchQueue.main.async {
                    completionHandler?(asset)
                }
            }
            if #available(iOS 13.0, *) {
                asset.downloadId = PHImageManager.default().requestImageDataAndOrientation(for: phAsset, options: options, resultHandler: resultHandler)
            } else {
                asset.downloadId = PHImageManager.default().requestImageData(for: phAsset, options: options, resultHandler: resultHandler)
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
    class func exportAsynchronously(_ assets: [MNAsset], options: MNAssetPickerOptions, progress progressHandler: ((Int, Int)->Void)?, completion completionHandler: @escaping ([MNAsset])->Void) {
        DispatchQueue.global().async {
            guard assets.count > 0 else {
                DispatchQueue.main.async {
                    completionHandler([])
                }
                return
            }
            MNAssetHelper.exportRecursively(assets, index: 0, options: options, succeed: [MNAsset](), progress: progressHandler, completion: completionHandler)
        }
    }
    
    /// 递归导出资源内容
    /// - Parameters:
    ///   - assets: 资源集合
    ///   - index: 需要导出的资源索引
    ///   - options: 选择器配置模型
    ///   - succeed: 已导出成功的资源模型
    ///   - progressHandler: 进度回调
    ///   - completionHandler: 结束回调
    private class func exportRecursively(_ assets: [MNAsset], index: Int, options: MNAssetPickerOptions, succeed: [MNAsset], progress progressHandler: ((Int, Int)->Void)?, completion completionHandler: @escaping ([MNAsset])->Void) {
        DispatchQueue.global().async {
            // 超出则结束
            guard index < assets.count else {
                DispatchQueue.main.async {
                    completionHandler(succeed)
                }
                return
            }
            // 回调进度
            DispatchQueue.main.async {
                progressHandler?(index + 1, assets.count)
            }
            // 获取内容
            let asset: MNAsset = assets[index]
            MNAssetHelper.exportContent( asset, options: options) { asset in
                var array: [MNAsset] = succeed
                if let _ = asset.content {
                    array.append(asset)
                }
                MNAssetHelper.exportRecursively(assets, index: index + 1, options: options, succeed: array, progress: progressHandler, completion: completionHandler)
            }
        }
    }
    
    /// 导出资源内容
    /// - Parameters:
    ///   - asset: 资源模型
    ///   - options: 选择器配置模型
    ///   - completionHandler: 结束回调
    private class func exportContent(_ asset: MNAsset, options: MNAssetPickerOptions, completion completionHandler: ((MNAsset)->Void)?) {
        guard let phAsset = asset.phAsset else {
            completionHandler?(asset)
            return
        }
        // 开始下载数据
        asset.content = nil
        switch asset.type {
        case .video:
            let videoOptions = MNAssetHelper.helper.videoOptions
            videoOptions.version = .current
            videoOptions.isNetworkAccessAllowed = true
            videoOptions.deliveryMode = .highQualityFormat
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: videoOptions) { result, _, _ in
                if let avAsset = result as? AVURLAsset {
                    if options.allowsExportMov == false, avAsset.url.pathExtension.lowercased().contains("mov") {
                        let outputURL: URL = MNAssetHelper.exportURL(preset: options.outputURL, ext: "mp4")
                        try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                        if let exportSession = AVAssetExportSession(asset: avAsset, presetName: options.exportPreset ?? AVAssetExportPresetHighestQuality) {
                            exportSession.outputURL = outputURL
                            exportSession.outputFileType = .mp4
                            exportSession.shouldOptimizeForNetworkUse = true
                            exportSession.exportAsynchronously { [weak exportSession] in
                                let status = exportSession?.status ?? .failed
                                if status == .completed, FileManager.default.fileExists(atPath: outputURL.path) {
                                    asset.content = outputURL.path
                                    asset.updateFileSize()
                                } else {
                                    try? FileManager.default.removeItem(at: outputURL)
                                }
                                DispatchQueue.main.async {
                                    completionHandler?(asset)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                completionHandler?(asset)
                            }
                        }
                    } else {
                        asset.content = avAsset.url.path
                        asset.updateFileSize()
                        DispatchQueue.main.async {
                            completionHandler?(asset)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler?(asset)
                    }
                }
            }
        case .livePhoto:
            guard #available(iOS 9.1, *), let livePhotoOptions = MNAssetHelper.helper.livePhotoOptions as? PHLivePhotoRequestOptions else {
                DispatchQueue.main.async {
                    completionHandler?(asset)
                }
                break
            }
            livePhotoOptions.isNetworkAccessAllowed = true
            livePhotoOptions.deliveryMode = .highQualityFormat
            PHImageManager.default().requestLivePhoto(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: livePhotoOptions) { result, _ in
                if let livePhoto = result {
                    if options.allowsExportLiveResource {
                        MNAssetHelper.exportLivePhoto(livePhoto) { imageUrl, videoUrl in
                            if let image = imageUrl, let video = videoUrl {
                                livePhoto.imageFileURL = image
                                livePhoto.videoFileURL = video
                                asset.content = livePhoto
                                asset.updateFileSize()
                                DispatchQueue.main.async {
                                    completionHandler?(asset)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completionHandler?(asset)
                                }
                            }
                        }
                    } else {
                        asset.content = livePhoto
                        DispatchQueue.main.async {
                            completionHandler?(asset)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler?(asset)
                    }
                }
            }
        default:
            let imageOptions = MNAssetHelper.helper.imageOptions
            imageOptions.isNetworkAccessAllowed = true
            imageOptions.deliveryMode = .highQualityFormat
            let resultHandler: (Data?, String?, Any, [AnyHashable : Any]?) -> Void = { imageData, _, _, _ in
                var image: UIImage?
                var fileSize: Int64 = 0
                var isAllowCompress: Bool = false
                if let result = asset.type == .gif ? UIImage.image(contentsOfData: imageData) : (imageData == nil ? nil : UIImage(data: imageData!)) {
                    if result.isAnimatedImage {
                        image = result
                        fileSize = Int64(imageData!.count)
                    } else if #available(iOS 10.0, *), options.allowsExportHeifc == false, phAsset.isHeifc {
                        // 判断是否需要转化heif/heic格式图片
                        if let ciImage = CIImage(data: imageData!), let colorSpace = ciImage.colorSpace, let jpgData = CIContext().jpegRepresentation(of: ciImage, colorSpace: colorSpace, options: [CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String):max(min(options.compressionQuality, 1.0), 0.1)]) {
                            image = UIImage(data: jpgData)?.mn_picker.resized
                            if let _ = image {
                                fileSize = Int64(jpgData.count)
                            }
                        }
                    } else {
                        isAllowCompress = true
                        image = result.mn_picker.resized
                        fileSize = Int64(imageData!.count)
                    }
                    if isAllowCompress, options.compressionQuality < 1.0 {
                        image = image?.mn_picker.compress(pixel: 1280.0, quality: max(options.compressionQuality, 0.5), fileSize: &fileSize)
                        if image == nil { fileSize = 0 }
                    }
                }
                asset.content = image
                if fileSize > 0 {
                    asset.update(fileSize: fileSize)
                }
                DispatchQueue.main.async {
                    completionHandler?(asset)
                }
            }
            if #available(iOS 13.0, *) {
                PHImageManager.default().requestImageDataAndOrientation(for: phAsset, options: imageOptions, resultHandler: resultHandler)
            } else {
                PHImageManager.default().requestImageData(for: phAsset, options: imageOptions, resultHandler: resultHandler)
            }
        }
    }
    
    /// 获取资源导出路径
    /// - Parameter pathExtension: 后缀名
    private class func exportURL(preset url: URL?, ext: String) -> URL {
        if let url = url {
            if url.isFileURL {
                if FileManager.default.fileExists(atPath: url.path) {
                    return url.deletingLastPathComponent().appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000))").appendingPathExtension(url.pathExtension)
                }
                return url
            }
            return url.appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000))").appendingPathExtension(url.pathExtension)
        }
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!).appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000.0))").appendingPathExtension(ext)
    }
}

// MARK: - Cancel
extension MNAssetHelper {
    
    /// 取消资源请求
    /// - Parameter asset: 资源模型
    class func cancelRequest(_ asset: MNAsset) {
        let requestId = asset.requestId
        if requestId == PHInvalidImageRequestID { return }
        asset.requestId = PHInvalidImageRequestID
        PHImageManager.default().cancelImageRequest(requestId)
    }
    
    /// 取消资源下载
    /// - Parameter asset: 资源模型
    class func cancelDownload(_ asset: MNAsset) {
        let downloadId = asset.downloadId
        if downloadId == PHInvalidImageRequestID { return }
        asset.downloadId = PHInvalidImageRequestID
        PHImageManager.default().cancelImageRequest(downloadId)
    }
}

// MARK: - 相册操作
extension MNAssetHelper {
    
    @objc class func deleteAssets(_ assets: [PHAsset], completion: ((Error?)->Void)?) {
        DispatchQueue.global().async {
            guard assets.count > 0 else {
                DispatchQueue.main.async {
                    completion?(MNPHError.deleteError(.isEmpty))
                }
                return
            }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
            } completionHandler: { flag, error in
                DispatchQueue.main.async {
                    if flag {
                        completion?(nil)
                    } else {
                        completion?(error == nil ? MNPHError.deleteError(.unknown) : MNPHError.deleteError(.underlyingError(error!)))
                    }
                }
            }
        }
    }
    
    @objc class func writeImage(toAlbum image: Any, completion: ((String?, Error?)->Void)?) {
        writeAssets([image], toAlbum: nil) { identifiers, error in
            completion?(identifiers?.first, error)
        }
    }
    
    @objc class func writeVideo(toAlbum video: Any, completion: ((String?, Error?)->Void)?) {
        writeAssets([video], toAlbum: nil) { identifiers, error in
            completion?(identifiers?.first, error)
        }
    }
    
    @available(iOS 9.1, *)
    @objc class func writeLivePhoto(toAlbum livePhoto: PHLivePhoto, completion: ((String?, Error?)->Void)?) {
        writeAssets([livePhoto], toAlbum: nil) { identifiers, error in
            completion?(identifiers?.first, error)
        }
    }
    
    @objc class func writeAssets(_ assets: [Any], toAlbum title: String? = nil, completion: (([String]?, Error?)->Void)?) {
        DispatchQueue.global().async {
            var identifiers: [String] = [String]()
            var placeholders: [PHObjectPlaceholder] = [PHObjectPlaceholder]()
            PHPhotoLibrary.shared().performChanges {
                for var asset in assets {
                    // 转换资源
                    if asset is String {
                        guard let path = asset as? String, FileManager.default.fileExists(atPath: path) else { continue }
                        asset = URL(fileURLWithPath: path) as AnyObject
                    } else if asset is Data {
                        guard let image = UIImage(data: asset as! Data) else { continue }
                        asset = image
                    }
                    // 图片/视频
                    var placeholder: PHObjectPlaceholder?
                    if asset is UIImage {
                        placeholder = PHAssetChangeRequest.creationRequestForAsset(from: asset as! UIImage).placeholderForCreatedAsset
                    } else if asset is URL {
                        guard let url = asset as? URL, url.isFileURL, FileManager.default.fileExists(atPath: url.path) else { continue }
                        if ["mp4", "mov", "3gp"].contains(url.pathExtension.lowercased()) {
                            placeholder = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)?.placeholderForCreatedAsset
                        } else if ["jpg", "png", "jpeg", "gif", "heif"].contains(url.pathExtension.lowercased()) {
                            placeholder = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)?.placeholderForCreatedAsset
                        }
                    }
                    // LivePhoto
                    if #available(iOS 9.1, *) {
                        if asset is PHLivePhoto {
                            let videoURL = (asset as? PHLivePhoto)?.videoFileURL
                            let imageURL = (asset as? PHLivePhoto)?.imageFileURL
                            guard let video = videoURL, FileManager.default.fileExists(atPath: video.path), let image = imageURL, FileManager.default.fileExists(atPath: image.path) else { continue }
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: video, options: nil)
                            request.addResource(with: .photo, fileURL: image, options: nil)
                            placeholder = request.placeholderForCreatedAsset
                        } else if asset is [MNLivePhotoResourceKey:AnyObject] {
                            guard let dictionary = asset as? [MNLivePhotoResourceKey:AnyObject] else { continue }
                            var videoURL: URL?, imageURL: URL?
                            if let path = dictionary[MNLivePhotoImageUrlKey] as? String, FileManager.default.fileExists(atPath: path) {
                                if (path as NSString).pathExtension.lowercased() == "jpg" || (path as NSString).pathExtension.lowercased() == "jpeg" {
                                    imageURL = URL(fileURLWithPath: path)
                                }
                            } else if let url = dictionary[MNLivePhotoImageUrlKey] as? URL, FileManager.default.fileExists(atPath: url.path) {
                                if url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" {
                                    imageURL = url
                                }
                            }
                            if let path = dictionary[MNLivePhotoVideoUrlKey] as? String, FileManager.default.fileExists(atPath: path), (path as NSString).pathExtension.lowercased() == "mov" {
                                videoURL = URL(fileURLWithPath: path)
                            } else if let url = dictionary[MNLivePhotoVideoUrlKey] as? URL, FileManager.default.fileExists(atPath: url.path), url.pathExtension.lowercased() == "mov" {
                                videoURL = url
                            }
                            guard let video = videoURL, let image = imageURL else { continue }
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: video, options: nil)
                            request.addResource(with: .photo, fileURL: image, options: nil)
                            placeholder = request.placeholderForCreatedAsset
                        } else if asset is [AnyObject] {
                            guard let array = asset as? [AnyObject], array.count == 2 else { continue }
                            var videoURL: URL?, imageURL: URL?
                            for item in array {
                                if item is String {
                                    guard let path = item as? String, FileManager.default.fileExists(atPath: path) else { continue }
                                    if (path as NSString).pathExtension.lowercased() == "mov" {
                                        videoURL = URL(fileURLWithPath: path)
                                    } else if (path as NSString).pathExtension.lowercased() == "jpg" || (path as NSString).pathExtension.lowercased() == "jpeg" {
                                        imageURL = URL(fileURLWithPath: path)
                                    }
                                } else if item is URL {
                                    guard let url = item as? URL, FileManager.default.fileExists(atPath: url.path) else { continue }
                                    if url.pathExtension.lowercased() == "mov" {
                                        videoURL = url
                                    } else if url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" {
                                        imageURL = url
                                    }
                                }
                            }
                            guard let video = videoURL, let image = imageURL else { continue }
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: video, options: nil)
                            request.addResource(with: .photo, fileURL: image, options: nil)
                            placeholder = request.placeholderForCreatedAsset
                        }
                    }
                    guard let _ = placeholder else { continue }
                    placeholders.append(placeholder!)
                    identifiers.append(placeholder!.localIdentifier)
                }
                if placeholders.count > 0 {
                    MNAssetHelper.creationRequestForAssetCollection(with: title)?.addAssets(placeholders as NSFastEnumeration)
                }
            } completionHandler: { result, error in
                DispatchQueue.main.async {
                    if result {
                        completion?(identifiers, nil)
                    } else {
                        completion?(nil, (error == nil ? MNPHError.writeError(.unknown) : MNPHError.writeError(.underlyingError(error!))))
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
    // 合成
    @objc class func requestLivePhoto(resourceFileURLs urls: [URL], completion: ((PHLivePhoto?, Error?)->Void)?) {
        DispatchQueue.global().async {
            var videoURL: URL?
            var imageURL: URL?
            for url in urls {
                guard url.isFileURL, FileManager.default.fileExists(atPath: url.path) else { continue }
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
                    completion?(nil, MNPHError.livePhotoError(.fileNotExist))
                }
                return
            }
            PHLivePhoto.request(withResourceFileURLs: [video, image], placeholderImage: nil, targetSize: .zero, contentMode: .aspectFit) { photo, info in
                if let livePhoto = photo {
                    guard ((info[PHLivePhotoInfoIsDegradedKey] as? NSNumber)?.boolValue ?? false) == false else { return }
                    livePhoto.videoFileURL = video
                    livePhoto.imageFileURL = image
                    DispatchQueue.main.async {
                        completion?(livePhoto, nil)
                    }
                } else {
                    let error = info[PHLivePhotoInfoErrorKey] as? Error
                    DispatchQueue.main.async {
                        completion?(nil, (error == nil ? MNPHError.livePhotoError(.requestFailed) : MNPHError.livePhotoError(.underlyingError(error!))))
                    }
                }
            }
        }
    }
    
    // 导出
    @objc class func exportLivePhoto(_ livePhoto: PHLivePhoto, completion: ((URL?, URL?)->Void)?) {
        let videoUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!).appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000.0))").appendingPathExtension("MOV")
        let imageUrl = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!).appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000.0))").appendingPathExtension("JPG")
        exportLivePhoto(livePhoto, imageUrl: imageUrl, videoUrl: videoUrl) { result in
            if result {
                completion?(imageUrl, videoUrl)
            } else {
                completion?(nil, nil)
            }
        }
    }
    
    @objc class func exportLivePhoto(_ livePhoto: PHLivePhoto, imageUrl: URL, videoUrl: URL, completion: ((Bool)->Void)?) {
        for url in [imageUrl, videoUrl] {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        }
        let group = DispatchGroup()
        let resources = PHAssetResource.assetResources(for: livePhoto)
        for resource in resources {
            group.enter()
            let buffer = PHLivePhotoBuffer()
            buffer.type = resource.type
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            PHAssetResourceManager.default().requestData(for: resource, options: options) { data in
                buffer.data.append(contentsOf: data)
            } completionHandler: { error in
                if error == nil {
                    if buffer.type == .pairedVideo {
                        try? buffer.data.write(to: videoUrl, options: .atomic)
                    } else {
                        try? buffer.data.write(to: imageUrl, options: .atomic)
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            if FileManager.default.fileExists(atPath: imageUrl.path), FileManager.default.fileExists(atPath: videoUrl.path) {
                completion?(true)
            } else {
                try? FileManager.default.removeItem(at: videoUrl)
                try? FileManager.default.removeItem(at: imageUrl)
                completion?(false)
            }
        }
    }
}
