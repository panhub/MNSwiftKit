//
//  HTTPUploadAssistant.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//  上传内容表单辅助

import ImageIO
import Foundation
import CoreServices
import UniformTypeIdentifiers

/// 上传内容表单辅助
public class HTTPUploadAssistant {
    
    /// 边界标记
    public let boundary: String
    
    /// 字符串编码格式
    public let stringEncoding: String.Encoding
    
    /// 内部维护数据流
    private var body: Data = .init()
    
    /// 外部获取数据流
    public var data: Data {
        if body.isEmpty { return body }
        let data = "--\(boundary)--\r\n".data(using: stringEncoding)!
        return body + data
    }
    
    
    /// 构造适配器
    /// - Parameters:
    ///   - boundary: 边界字符串
    ///   - stringEncoding: 字符串编码方式
    public init(boundary: String, stringEncoding: String.Encoding = .utf8) {
        self.boundary = boundary
        self.stringEncoding = stringEncoding
    }
    
    
    /// 追加多个参数
    /// - Parameter params: 参数集
    /// - Returns: 是否追加成功
    @discardableResult
    public func append(params: [String:Any]) -> Bool {
        var string: String = ""
        for (key, value) in params {
            string.append("--\(boundary)\r\n")
            string.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            string.append("\(value)\r\n")
        }
        guard let data = string.data(using: stringEncoding) else { return false }
        body.append(data)
        return true
    }
    
    /// 追加参数
    /// - Parameters:
    ///   - name: 服务端根据此值取内容
    ///   - value: 值内容, 最终要转换为字符串
    /// - Returns: 是否追加成功
    @discardableResult
    public func append(name: String, value: Any) -> Bool {
        append(params: [name:"\(value)"])
    }
    
    /// 追加图片
    /// - Parameters:
    ///   - image: 图片
    ///   - name: 服务端根据此值取内容
    ///   - filename: 原始文件名(服务端不关心则不传也可, eg: aaaaaabc.jpg)
    /// - Returns: 是否追加成功
    @discardableResult
    public func append(image: UIImage, name: String, filename: String? = nil) -> Bool {
        var ext: String = "jpg"
        if let filename = filename {
            let pathExtension = (filename as NSString).pathExtension
            if pathExtension.isEmpty == false {
                ext = pathExtension.lowercased()
            }
        }
        // 压缩图片
        var mimeType = ""
        var imageData: Data = .init()
        switch ext {
        case "png":
            guard let pngData = image.pngData() else { return false }
            imageData.append(pngData)
            mimeType.append("image/png")
        case "heic":
            guard #available(iOS 17.0, *) else { return false }
            guard let heicData = image.heicData() else { return false }
            imageData.append(heicData)
            mimeType.append("image/heic")
        case "heif":
            guard #available(iOS 14.0, *) else { return false }
            guard let cgImage = image.cgImage else { return false }
            let heifType = UTType.heif
            let heifData = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(heifData as CFMutableData, heifType.identifier as CFString, 1, nil) else { return false }
            let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: 1.0]
            CGImageDestinationAddImage(imageDestination, cgImage, options as CFDictionary)
            guard CGImageDestinationFinalize(imageDestination) else { return false }
            guard heifData.isEmpty == false else { return false }
            imageData.append(heifData as Data)
            mimeType.append("image/heif")
        default:
            guard let jpegData = image.jpegData(compressionQuality: 1.0) else { return false }
            imageData.append(jpegData)
            mimeType.append("image/jpeg")
        }
        return append(data: imageData, name: name, mime: mimeType, filename: filename)
    }
    
    /// 追加文件
    /// - Parameters:
    ///   - url: 文件路径地址
    ///   - name: 服务端根据此值取内容
    /// - Returns: 是否追加成功
    @discardableResult
    public func append(file url: URL, name: String) -> Bool {
        var fileData: Data!
        do {
            fileData = try Data(contentsOf: url)
        } catch {
#if DEBUG
            print("读取文件内容失败: \(error)")
#endif
            return false
        }
        let mimeType = HTTPUploadAssistant.mimeType(withExtension: url.pathExtension)
        return append(data: fileData, name: name, mime: mimeType, filename: url.lastPathComponent)
    }
    
    /// 追加文件数据流
    /// - Parameters:
    ///   - data: 数据流
    ///   - name: 服务端根据此值取内容
    ///   - mime: 文件MIME
    ///   - filename: 原始文件名(服务端不关心则不传也可, eg: aaaaaabc.jpg)
    /// - Returns: 是否追加成功
    @discardableResult
    public func append(data: Data, name: String, mime: String, filename: String? = nil) -> Bool {
        var begin = "--\(boundary)\r\n"
        begin.append("Content-Disposition: form-data; name=\"\(name)\";")
        if let filename = filename, filename.isEmpty == false {
            begin.append(" filename=\"\(filename)\"")
        }
        begin.append("\r\n")
        begin.append("Content-Type: \(mime)\r\n\r\n")
        guard let beginData = begin.data(using: stringEncoding) else { return false }
        guard let endData = "\r\n".data(using: stringEncoding) else { return false }
        body.append(beginData + data + endData)
        return false
    }
    
    /// 根据文件扩展名获取文件MIME
    /// - Parameter pathExtension: 文件扩展名
    /// - Returns: 文件MIME
    public class func mimeType(withExtension fileExtension: String) -> String {
        if #available(iOS 14.0, *) {
            if let type = UTType(filenameExtension: fileExtension), let mime = type.preferredMIMEType {
                return mime
            }
        }
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeRetainedValue(), let mime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mime as String
        }
        return "application/octet-stream"
    }
}
