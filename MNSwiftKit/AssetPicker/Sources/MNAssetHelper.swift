//
//  MNAssetHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/28.
//  辅助方法

import UIKit
import Photos
import Foundation

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

// MARK: - Collection
extension MNAssetHelper {
    
    /// 获取相簿
    /// - Parameters:
    ///   - options: 选择器配置模型
    ///   - completionHandler: 相簿集合结果回调
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
    ///   - completionHandler: 结束回调
    public class func fetchAsset(in album: MNAssetAlbum, options: MNAssetPickerOptions, start startHandler: (()->Void)? = nil, completion completionHandler: @escaping ()->Void) {
        DispatchQueue.global().async {
            // 循环拉取直到满足分页数量
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
                    var type = element.mn.contentType
                    if type == .video {
                        let duration = element.duration
                        if (options.minExportDuration > 0.0 && duration < options.minExportDuration) || (options.maxExportDuration > 0.0 && duration > options.maxExportDuration && options.maxPickingCount > 1 && options.allowsMultiplePickingVideo) { return }
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

// MARK: - Profile & Cover
extension MNAssetHelper {
    
    /// 请求描述信息(触发多次回调, 更新资源)
    /// - Parameters:
    ///   - asset: 资源模型
    ///   - options: 选择器配置
    public class func fetchProfile(_ asset: MNAsset, options: MNAssetPickerOptions) {
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
                let image = result.mn.resized
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
    public class func fetchCover(_ asset: MNAsset, completion completionHandler: ((MNAsset, UIImage?)->Void)?) {
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
            let image = result.mn.resized
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
    public class func fetchContents(_ asset: MNAsset, progress progressHandler: ((MNAsset, Double, Error?)->Void)?, completion completionHandler: ((MNAsset)->Void)?) {
        if let _ = asset.contents {
            completionHandler?(asset)
            return
        }
        guard let phAsset = asset.phAsset else {
            progressHandler?(asset, 0.0, nil)
            completionHandler?(asset)
            return
        }
        // 进度回调
        let progressHandler: PHAssetVideoProgressHandler = { progress, error, _, _ in
            DispatchQueue.main.async {
                asset.progress = progress
                progressHandler?(asset, progress, error)
            }
        }
        switch asset.type {
        case .video:
            let options = MNAssetHelper.helper.videoOptions
            options.version = .current
            options.deliveryMode = .automatic
            options.isNetworkAccessAllowed = true
            options.progressHandler = progressHandler
            asset.downloadId = PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { [weak asset] result, _, info in
                guard let asset = asset else { return }
                asset.progress = 0.0
                asset.downloadId = PHInvalidImageRequestID
                let isCancelled: Bool = info?[PHImageCancelledKey] as? Bool ?? false
                guard isCancelled == false else { return }
                if let avAsset = result as? AVURLAsset {
                    asset.contents = avAsset.url.mn.path
                }
                DispatchQueue.main.async {
                    if let completionHandler = completionHandler {
                        completionHandler(asset)
                    }
                }
            }
        case .livePhoto:
            guard #available(iOS 9.1, *) else { break }
            guard let options = MNAssetHelper.helper.livePhotoOptions as? PHLivePhotoRequestOptions else { break }
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.progressHandler = progressHandler
            asset.downloadId = PHImageManager.default().requestLivePhoto(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { [weak asset] result, info in
                guard let asset = asset else { return }
                asset.progress = 0.0
                asset.downloadId = PHInvalidImageRequestID
                let isCancelled: Bool = info?[PHImageCancelledKey] as? Bool ?? false
                guard isCancelled == false else { return }
                if let livePhoto = result {
                    asset.contents = livePhoto
                }
                DispatchQueue.main.async {
                    if let completionHandler = completionHandler {
                        completionHandler(asset)
                    }
                }
            }
        default:
            let options = MNAssetHelper.helper.imageOptions
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.progressHandler = progressHandler
            let resultHandler: (Data?, String?, Any, [AnyHashable : Any]?) -> Void = { [weak asset] imageData, _, _, info in
                guard let asset = asset else { return }
                asset.progress = 0.0
                asset.downloadId = PHInvalidImageRequestID
                let isCancelled: Bool = info?[PHImageCancelledKey] as? Bool ?? false
                guard isCancelled == false else { return }
                let result: UIImage? = asset.type == .gif ? UIImage.mn.image(contentsOfData: imageData) : (imageData == nil ? nil : UIImage(data: imageData!))
                if let image = result {
                    if image.mn.isAnimatedImage {
                        asset.contents = image
                    } else {
                        asset.contents = image.mn.resized
                    }
                }
                DispatchQueue.main.async {
                    if let completionHandler = completionHandler {
                        completionHandler(asset)
                    }
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
    public class func exportAsynchronously(_ assets: [MNAsset], options: MNAssetPickerOptions, progress progressHandler: ((Int, Int)->Void)?, completion completionHandler: @escaping ([MNAsset])->Void) {
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
    private class func exportRecursively(_ assets: [MNAsset], index: Int, options: MNAssetPickerOptions, succeed: [MNAsset], progress progressHandler: ((_ current: Int, _ count: Int)->Void)?, completion completionHandler: @escaping ([MNAsset])->Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // 超出则结束
            guard index < assets.count else {
                DispatchQueue.main.async {
                    completionHandler(succeed)
                }
                return
            }
            // 回调进度
            DispatchQueue.main.async {
                if let progressHandler = progressHandler {
                    progressHandler(index + 1, assets.count)
                }
            }
            // 获取内容
            let asset: MNAsset = assets[index]
            MNAssetHelper.exportContents( asset, options: options) { asset in
                var elements: [MNAsset] = succeed
                if let _ = asset.contents {
                    elements.append(asset)
                }
                MNAssetHelper.exportRecursively(assets, index: index + 1, options: options, succeed: elements, progress: progressHandler, completion: completionHandler)
            }
        }
    }
    
    /// 导出资源内容
    /// - Parameters:
    ///   - asset: 资源模型
    ///   - options: 选择器配置模型
    ///   - completionHandler: 结束回调
    private class func exportContents(_ asset: MNAsset, options: MNAssetPickerOptions, completion completionHandler: ((MNAsset)->Void)?) {
        guard let phAsset = asset.phAsset else {
            if let completionHandler = completionHandler {
                completionHandler(asset)
            }
            return
        }
        // 开始下载数据
        asset.contents = nil
        switch asset.type {
        case .video:
            let videoOptions = MNAssetHelper.helper.videoOptions
            videoOptions.version = .current
            videoOptions.isNetworkAccessAllowed = true
            videoOptions.deliveryMode = .highQualityFormat
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: videoOptions) { result, _, _ in
                if let avAsset = result as? AVURLAsset {
                    let outputURL: URL = MNAssetHelper.exportURL(preset: options.videoExportURL, ext: options.allowsExportVideo ? "mp4" : avAsset.url.pathExtension.lowercased())
                    try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                    if options.allowsExportVideo {
                        if let exportSession = AVAssetExportSession(asset: avAsset, presetName: options.videoExportPreset ?? AVAssetExportPresetHighestQuality) {
                            exportSession.outputURL = outputURL
                            exportSession.outputFileType = .mp4
                            exportSession.shouldOptimizeForNetworkUse = true
                            exportSession.exportAsynchronously {
                                if FileManager.default.fileExists(atPath: outputURL.mn.path) {
                                    asset.contents = outputURL.mn.path
                                    asset.reloadFileSize()
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
                        do {
                            try FileManager.default.copyItem(at: avAsset.url, to: outputURL)
                            asset.contents = outputURL.mn.path
                            asset.reloadFileSize()
                        } catch {
#if DEBUG
                            print("拷贝视频失败: \(error)")
#endif
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
            }
        case .livePhoto:
            guard #available(iOS 9.1, *), let livePhotoOptions = MNAssetHelper.helper.livePhotoOptions as? PHLivePhotoRequestOptions else {
                DispatchQueue.main.async {
                    if let completionHandler = completionHandler {
                        completionHandler(asset)
                    }
                }
                break
            }
            livePhotoOptions.isNetworkAccessAllowed = true
            livePhotoOptions.deliveryMode = .highQualityFormat
            PHImageManager.default().requestLivePhoto(for: phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: livePhotoOptions) { result, _ in
                if let livePhoto = result {
                    if options.allowsExportLiveResource {
                        MNAssetHelper.exportLivePhoto(livePhoto) { imageUrl, videoUrl, _ in
                            if let video = videoUrl, let image = imageUrl {
                                livePhoto.mn.videoFileURL = video
                                livePhoto.mn.imageFileURL = image
                                asset.contents = livePhoto
                                asset.reloadFileSize()
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
                        asset.contents = livePhoto
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
                if let result = asset.type == .gif ? UIImage.mn.image(contentsOfData: imageData) : (imageData == nil ? nil : UIImage(data: imageData!)) {
                    if result.mn.isAnimatedImage {
                        image = result
                        fileSize = Int64(imageData!.count)
                    } else if #available(iOS 10.0, *), options.allowsExportHeifc == false, phAsset.mn.isHeifc {
                        // 判断是否需要转化heif/heic格式图片
                        if let ciImage = CIImage(data: imageData!), let colorSpace = ciImage.colorSpace, let jpgData = CIContext().jpegRepresentation(of: ciImage, colorSpace: colorSpace, options: [CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String):max(min(options.compressionQuality, 1.0), 0.1)]) {
                            image = UIImage(data: jpgData)?.mn.resized
                            if let _ = image {
                                fileSize = Int64(jpgData.count)
                            }
                        }
                    } else {
                        isAllowCompress = true
                        image = result.mn.resized
                        fileSize = Int64(imageData!.count)
                    }
                    if isAllowCompress, options.compressionQuality < 1.0 {
                        image = image?.mn.resizing(to: 1280.0, quality: max(options.compressionQuality, 0.5), fileSize: &fileSize)
                        if image == nil { fileSize = 0 }
                    }
                }
                asset.contents = image
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
                if FileManager.default.fileExists(atPath: url.mn.path) {
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
    public class func cancelRequest(_ asset: MNAsset) {
        let requestId = asset.requestId
        if requestId == PHInvalidImageRequestID { return }
        asset.requestId = PHInvalidImageRequestID
        PHImageManager.default().cancelImageRequest(requestId)
    }
    
    /// 取消资源下载
    /// - Parameter asset: 资源模型
    public class func cancelDownload(_ asset: MNAsset) {
        let downloadId = asset.downloadId
        if downloadId == PHInvalidImageRequestID { return }
        asset.downloadId = PHInvalidImageRequestID
        PHImageManager.default().cancelImageRequest(downloadId)
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
                        } else if ["jpg", "png", "jpeg", "gif", "heif"].contains(url.pathExtension.lowercased()) {
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
        let videoUrl = URL(fileAtPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!).appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000.0))").appendingPathExtension("MOV")
        let imageUrl = URL(fileAtPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!).appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000.0))").appendingPathExtension("JPG")
        exportLivePhoto(livePhoto, imageUrl: imageUrl, videoUrl: videoUrl) { isSuccess, error in
            if isSuccess {
                completion?(imageUrl, videoUrl, nil)
            } else {
                completion?(nil, nil, error!.asPickError)
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
                if error == nil {
                    do {
                        try contents.write(to: type == .pairedVideo ? videoUrl : imageUrl, options: .atomic)
                    } catch {
#if DEBUG
                        print("写入LivePhoto文件失败: \(error)")
#endif
                    }
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            if FileManager.default.fileExists(atPath: imageUrl.mn.path), FileManager.default.fileExists(atPath: videoUrl.mn.path) {
                completion?(true, nil)
            } else {
                try? FileManager.default.removeItem(at: videoUrl)
                try? FileManager.default.removeItem(at: imageUrl)
                completion?(false, MNPickError.exportError(.requestFailed))
            }
        }
    }
}
