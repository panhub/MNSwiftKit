//
//  MNAssetPicker+Extension.swift
//  MNSwiftKit
//
//  Created by panhub on 2024/12/19.
//  系统相册选择

import UIKit
import Photos
import PhotosUI
import Foundation
import ObjectiveC.runtime

@available(iOS 14.0, *)
extension MNAssetPicker {
    
    fileprivate class HandlerLitted {
        public let value: Any
        public init(value: Any) {
            self.value = value
        }
        public init(_ value: Any) {
            self.value = value
        }
    }

    fileprivate struct HandlerAssociated {
        nonisolated(unsafe) static var close: Void?
        nonisolated(unsafe) static var result: Void?
        nonisolated(unsafe) static var content: Void?
        nonisolated(unsafe) static var progress: Void?
    }
}

@available(iOS 14.0, *)
extension MNAssetPicker {
    
    /// 通过系统相册选择资源
    /// LivePhoto: PHLivePhoto对象
    /// - Parameters:
    ///   - limit: 数量限制
    ///   - filter: 过滤条件
    ///   - parent: 从哪个控制器调起
    ///   - presentationStyle: 展示样式
    ///   - start: 即将调起回调, 延迟5s后调起
    ///   - presented: 调起后回调
    ///   - Returns: 资源选择控制器
    public class func pick(limit: Int, filter: PHPickerFilter? = nil, from parent: UIViewController, style presentationStyle: UIModalPresentationStyle = .automatic, start: (()->Void)? = nil, presented: (()->Void)? = nil) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = filter
        configuration.selectionLimit = limit
        configuration.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = MNPHPickerProxy.shared
        picker.modalPresentationStyle = presentationStyle
        let presentHandler: ()->Void = { [weak parent] in
            guard let parent else { return }
            parent.present(picker, animated: true, completion: presented)
        }
        if let start = start {
            start()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: presentHandler)
        } else {
            presentHandler()
        }
        return picker
    }
}

@available(iOS 14.0, *)
extension MNNameSpaceWrapper where Base: PHPickerViewController {
    
    fileprivate var closeHandler: (()->Void)? {
        set {
            if let newValue = newValue {
                let association = MNAssetPicker.HandlerLitted(value: newValue)
                objc_setAssociatedObject(base, &MNAssetPicker.HandlerAssociated.close, association, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &MNAssetPicker.HandlerAssociated.close, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            guard let association = objc_getAssociatedObject(base, &MNAssetPicker.HandlerAssociated.close) as? MNAssetPicker.HandlerLitted else { return nil }
            return association.value as? ()->Void
        }
    }
    
    fileprivate var contentHandler: (([Any])->Void)? {
        set {
            if let newValue = newValue {
                let association = MNAssetPicker.HandlerLitted(value: newValue)
                objc_setAssociatedObject(base, &MNAssetPicker.HandlerAssociated.content, association, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &MNAssetPicker.HandlerAssociated.content, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            guard let association = objc_getAssociatedObject(base, &MNAssetPicker.HandlerAssociated.content) as? MNAssetPicker.HandlerLitted else { return nil }
            return association.value as? ([Any])->Void
        }
    }
    
    fileprivate var resultHandler: (([PHPickerResult])->Void)? {
        set {
            if let newValue = newValue {
                let association = MNAssetPicker.HandlerLitted(value: newValue)
                objc_setAssociatedObject(base, &MNAssetPicker.HandlerAssociated.result, association, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &MNAssetPicker.HandlerAssociated.result, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            guard let association = objc_getAssociatedObject(base, &MNAssetPicker.HandlerAssociated.result) as? MNAssetPicker.HandlerLitted else { return nil }
            return association.value as? ([PHPickerResult])->Void
        }
    }
    
    fileprivate var progressHandler: ((Int, Int)->Void)? {
        set {
            if let newValue = newValue {
                let association = MNAssetPicker.HandlerLitted(value: newValue)
                objc_setAssociatedObject(base, &MNAssetPicker.HandlerAssociated.progress, association, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(base, &MNAssetPicker.HandlerAssociated.progress, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            guard let association = objc_getAssociatedObject(base, &MNAssetPicker.HandlerAssociated.progress) as? MNAssetPicker.HandlerLitted else { return nil }
            return association.value as? (Int, Int)->Void
        }
    }
    
    /// 设置进度回调
    /// - Parameters:
    ///   - progressHandler: 回调
    ///   - Returns: 资源选择控制器
    @discardableResult
    public func progress(_ progressHandler: @escaping (_ index: Int, _ count: Int)->Void) -> PHPickerViewController {
        self.progressHandler = progressHandler
        return base
    }
    
    /// 设置资源结果回调
    /// - Parameters:
    ///   - resultHandler: 回调
    ///   - Returns: 资源选择控制器
    @discardableResult
    public func result(_ resultHandler: @escaping (_ results: [PHPickerResult])->Void) -> PHPickerViewController {
        self.resultHandler = resultHandler
        return base
    }
    
    /// 设置资源内容回调
    /// 静态图/Gif: 本地文件路径(String)
    /// 视频: 本地文件资源定位器(URL)
    /// LivePhoto: PHLivePhoto对象
    /// - Parameters:
    ///   - contentHandler: 回调
    ///   - Returns: 资源选择控制器
    @discardableResult
    public func contents(_ contentHandler: @escaping (_ contents: [Any])->Void) -> PHPickerViewController {
        self.contentHandler = contentHandler
        return base
    }
    
    /// 设置关闭回调
    /// - Parameters:
    ///   - closeHandler: 回调
    ///   - Returns: 资源选择控制器
    @discardableResult
    public func close(_ closeHandler: @escaping ()->Void) -> PHPickerViewController {
        self.closeHandler = closeHandler
        return base
    }
}

@available(iOS 14.0, *)
fileprivate class MNPHPickerProxy: NSObject, PHPickerViewControllerDelegate {
    
    static let shared = MNPHPickerProxy()
    
    private override init() {
        super.init()
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let closeHandler = picker.mn.closeHandler
        let resultHandler = picker.mn.resultHandler
        let contentHandler = picker.mn.contentHandler
        let progressHandler = picker.mn.progressHandler
        picker.dismiss(animated: true) {
            guard results.isEmpty == false else {
                if let closeHandler = closeHandler {
                    closeHandler()
                }
                return
            }
            if let contentHandler = contentHandler {
                MNPHPickerProxy.load(results: results, progress: progressHandler, completion: contentHandler)
            } else if let resultHandler = resultHandler {
                resultHandler(results)
            }
        }
    }
    
    private class func load(results: [PHPickerResult], progress progressHandler: ((Int, Int)->Void)?, completion completionHandler: (([Any])->Void)?) {
        
        load(results: results, index: 0, contents: [], progress: progressHandler, completion: completionHandler)
    }
    
    private class func load(results: [PHPickerResult], index: Int, contents: [Any], progress progressHandler: ((Int, Int)->Void)?, completion completionHandler: (([Any])->Void)?) {
        guard index < results.count else {
            if Thread.isMainThread {
                completionHandler?(contents)
            } else {
                DispatchQueue.main.async {
                    completionHandler?(contents)
                }
            }
            return
        }
        // 回调进度
        if Thread.isMainThread {
            progressHandler?(index, results.count)
        } else {
            DispatchQueue.main.async {
                progressHandler?(index, results.count)
            }
        }
        // 加载资源
        let result = results[index]
        load(result: result) { content in
            var contents = contents
            if let content = content {
                contents.append(content)
            }
            MNPHPickerProxy.load(results: results, index: index + 1, contents: contents, progress: progressHandler, completion: completionHandler)
        }
    }
    
    class func load(result: PHPickerResult, completion completionHandler: ((_ content: Any?)->Void)?) {
        DispatchQueue.global().async {
            // 加载资源
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: PHLivePhoto.self) {
                // 尝试加载LivePhoto
                provider.loadObject(ofClass: PHLivePhoto.self) { reading, error in
                    guard let photo = reading as? PHLivePhoto else {
                        DispatchQueue.main.async {
                            completionHandler?(nil)
                        }
                        return
                    }
                    // 查找本地文件名
                    var filename: String?
                    var pairedname: String?
                    if let assetIdentifier = result.assetIdentifier {
                        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
                        if let asset = fetchResult.firstObject, asset.mediaType == .image, asset.mediaSubtypes.contains(.photoLive) {
                            let resources = PHAssetResource.assetResources(for: asset)
                            for resource in resources {
                                let originalFilename = resource.originalFilename.lowercased()
                                let pathExtension = originalFilename.mn.pathExtension
                                if pathExtension == "jpg" || pathExtension == "heic" {
                                    filename = originalFilename
                                } else if pathExtension == "mov" {
                                    pairedname = originalFilename
                                }
                            }
                        }
                    }
                    let jpgName: String = filename ?? ("\(Int(Date().timeIntervalSince1970*1000.0)).jpg")
                    let movName: String = pairedname ?? ("\(Int(Date().timeIntervalSince1970*1000.0)).mov")
                    guard let jpgPath = String.mn.cachesDirectory.mn.appendingPathComponent(jpgName).mn.availablePath, let movPath = String.mn.cachesDirectory.mn.appendingPathComponent(movName).mn.availablePath else {
                        DispatchQueue.main.async {
                            completionHandler?(nil)
                        }
                        return
                    }
                    let jpgURL = URL(mn_filePath: jpgPath)
                    let movURL = URL(mn_filePath: movPath)
                    MNAssetHelper.exportLivePhoto(photo, imageUrl: jpgURL, videoUrl: movURL) { flag, _ in
                        if flag {
                            photo.mn.videoFileURL = movURL
                            photo.mn.imageFileURL = jpgURL
                            completionHandler?(photo)
                        } else {
                            completionHandler?(nil)
                        }
                    }
                }
            } else {
                // 尝试加载图片/视频
                let canLoadImage = provider.canLoadObject(ofClass: UIImage.self)
                let handleUrl: (URL?)->Void = { url in
                    if let url = url, let targetPath = String.mn.cachesDirectory.mn.appendingPathComponent(url.lastPathComponent).mn.availablePath, FileManager.default.mn.moveItem(at: url, to: URL(mn_filePath: targetPath)) {
                        DispatchQueue.main.async {
                            completionHandler?(canLoadImage ? targetPath : URL(mn_filePath: targetPath))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completionHandler?(nil)
                        }
                    }
                }
                if #available(iOS 16.0, *) {
                    _ = provider.loadFileRepresentation(for: canLoadImage ? .image : .movie) { url, _, _ in
                        handleUrl(url)
                    }
                } else {
                    _ = provider.loadFileRepresentation(forTypeIdentifier: canLoadImage ? UTType.image.identifier : UTType.video.identifier) { url, _ in
                        handleUrl(url)
                    }
                }
            }
        }
    }
}
