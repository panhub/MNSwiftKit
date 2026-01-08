//
//  MNNetworkParser.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/27.
//  请求结果序列化

import Foundation

/// 解析类型
public enum MNNetworkSerializationType {
    /// 不处理任何结果
    case none
    /// JSON数据类型
    case json
    /// 属性列表
    case plist
    /// XML类型
    case xml
    /// 字符串
    case plainText
}

extension MNNetworkSerializationType {
    
    /// 受支持的MIME类型
    public var mimeTypes: [String] {
        switch self {
        case .none: return []
        case .json:
            return [
                "application/json",                    // 标准的 JSON 类型, 或带字符集(charset=utf-8)
                "text/json",                          // 文本形式的 JSON（较少见）
                "text/javascript",                    // JSONP 或旧式 API 可能使用
                "application/javascript"              // JSONP 可能使用
            ]
        case .plist:
            return [
                "application/x-plist",            // 最常用的 plist 类型
                "application/xml",               // plist 本质是 XML
                "text/xml",                      // XML 文本格式
                "application/octet-stream",      // 二进制 plist
                "text/plain"                     // 文本格式的 plist
            ]
        case .xml:
            return [
                "application/xml",                // 最标准的 XML 类型
                "text/xml",                      // 文本形式的 XML
                "application/xhtml+xml",         // XHTML
                "application/rss+xml",           // RSS feed
                "application/atom+xml",          // Atom feed
                "application/soap+xml",          // SOAP
                "image/svg+xml",                 // SVG 图像
                "+xml"                           // 任何以 +xml 结尾的类型
            ]
        case .plainText:
            return [
                "text/plain",                    // 纯文本
                "text/html",                     // HTML
                "text/css",                      // CSS
                "text/javascript",               // JavaScript
                "text/markdown",                 // Markdown
                "text/csv",                      // CSV
                "text/xml",                      // XML（也是文本）
                "application/json",              // JSON（也是文本）
                "application/javascript",        // JavaScript
                "application/xml",               // XML
                "application/xhtml+xml",         // XHTML
                "text/rtf",                      // RTF
                "text/calendar",                 // iCalendar
                "text/vcard",                    // vCard
                "text/sgml",                     // SGML
                "text/tab-separated-values",     // TSV
                "text/yaml",                      // YAML
                "text/x-yaml",                    // YAML
                "application/yaml",               // YAML
                "application/x-yaml"              // YAML
            ]
        }
    }
}

/// 下载选项
public struct MNNetworkDownloadOptions: OptionSet {
    
    /// 当路径不存在时自动创建文件夹
    public static let createIntermediateDirectories = MNNetworkDownloadOptions(rawValue: 1 << 0)
    
    /// 删除已存在的文件 否则存在则使用旧文件
    public static let removeExistsFile = MNNetworkDownloadOptions(rawValue: 1 << 1)
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public class MNNetworkParser {
    
    /// 数据解析回调 (先于内部解析)
    public typealias AnalyticHandler = (Data, MNNetworkSerializationType)->Any?
    
    /// 字符串编码格式
    public var stringEncoding: String.Encoding = .utf8
    /// 接受的响应码
    public var acceptableStatusCodes: IndexSet = IndexSet(integersIn: 200..<300)
    /// JSON格式编码选项
    public var jsonReadingOptions: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
    /// 数据解析方式
    public var serializationType: MNNetworkSerializationType = .json
    /// 数据解析回调
    public var analyticHandler: MNNetworkParser.AnalyticHandler?
    /// 默认解析实例
    public static let `default`: MNNetworkParser = MNNetworkParser()
    /// 下载选项
    public var downloadOptions: MNNetworkDownloadOptions = [.createIntermediateDirectories, .removeExistsFile]
    
    public init() {}
    
    /// 解析响应结果
    /// - Parameters:
    ///   - response: 响应者
    ///   - data: 数据体
    ///   - error: 请求错误信息
    /// - Returns: 解析后的数据
    public func parse(response: URLResponse?, data: Data?, error: Error?) throws -> Any? {
        
        // 解析响应结果
        do {
            try parse(response: response, error: error)
        } catch {
            throw error
        }
        
        // 不解析数据则返回nil
        if serializationType == .none {
            return data
        }
        
        // 判断数据是否为空
        guard let responseData = data, responseData.isEmpty == false else {
            throw MNNetworkError.dataParseFailure(.zeroByteData)
        }
        
        if responseData == Data(bytes: " ", count: 1) {
            throw MNNetworkError.dataParseFailure(.zeroByteData)
        }
        
        // 判断是否支持自定义解析数据
        if let analyticHandler = analyticHandler {
            guard let responseObject = analyticHandler(responseData, serializationType) else {
                throw MNNetworkError.dataParseFailure(.cannotDecodeData)
            }
            return responseObject
        }
        
        // 解析数据
        var responseObject: Any = responseData
        switch serializationType {
        case .json:
            responseObject = try json(responseData)
        case .xml:
            responseObject = try xml(responseData)
        case .plist:
            responseObject = try plist(responseData)
        case .plainText:
            responseObject = try plainText(responseData)
        default: break
        }
        
        return responseObject
    }
    
    /// 解析响应者
    /// - Parameters:
    ///   - response: 响应者
    ///   - error: 请求错误信息
    private func parse(response: URLResponse?, error: Error?) throws {
        
        // 是否有响应错误
        if let error = error {
            throw MNNetworkError.responseParseFailure(.underlyingError(error))
        }

        // 响应是否合法
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MNNetworkError.responseParseFailure(.cannotParseResponse(response))
        }
        
        // 检查状态码
        let statusCode = httpResponse.statusCode
        guard acceptableStatusCodes.contains(statusCode) else {
            throw MNNetworkError.responseParseFailure(.unacceptedStatusCode(statusCode))
        }
        
        // 不关注结果，则不验证
        if serializationType == .none { return }
        
        // 确定服务端返回的类型
        guard let mimeType = httpResponse.mimeType else {
            throw MNNetworkError.responseParseFailure(.missingMimeType)
        }
        
        let lowercasedMimeType = mimeType.lowercased()
        for type in serializationType.mimeTypes {
            if lowercasedMimeType.contains(type) {
                // 符合预期数据类型
                return
            }
        }
        
        // 数据类型不符合预期
        throw MNNetworkError.responseParseFailure(.unacceptedContentType(mimeType))
    }
}

// MARK: - 数据解析
private extension MNNetworkParser {
    
    /// 解析JSON数据
    /// - Parameter data: JSON数据流
    /// - Returns: JSON对象
    func json(_ data: Data) throws -> Any {
        
        var jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: jsonReadingOptions)
        } catch {
            throw MNNetworkError.dataParseFailure(.underlyingError(error))
        }
        
        return jsonObject
    }
    
    /// 解析文本数据
    /// - Parameter data: 文本数据流
    /// - Returns: 文本
    func plainText(_ data: Data) throws -> String {
        
        guard let stringObject = String(data: data, encoding: stringEncoding) else {
            throw MNNetworkError.dataParseFailure(.cannotDecodeData)
        }
        return stringObject
    }
    
    /// 解析XML数据
    /// - Parameter data: XML数据流
    /// - Returns: XML解析器
    func xml(_ data: Data) throws -> XMLParser {
        
        XMLParser(data: data)
    }
    
    /// 解析Plist数据
    /// - Parameter data: Plist数据流
    /// - Returns: Plist数据
    func plist(_ data: Data) throws -> Any {
        
        var propertyList: Any
        do {
            propertyList = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        } catch {
            throw MNNetworkError.dataParseFailure(.cannotDecodeData)
        }
        return propertyList
    }
}
