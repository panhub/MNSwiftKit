//
//  HTTPParser.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/27.
//  请求结果序列化

import Foundation

public class HTTPParser {
    
    /// 数据解析回调 (先于内部解析)
    public typealias AnalyticHandler = (Data, HTTPContentType)->Any?
    
    /// 字符串编码格式
    public var stringEncoding: String.Encoding = .utf8
    /// 接受的响应码
    public var acceptableStatusCodes: IndexSet = IndexSet(integersIn: 200..<300)
    /// JSON格式编码选项
    public var jsonReadingOptions: JSONSerialization.ReadingOptions = [.fragmentsAllowed]
    /// 删除空数据 针对JsonObject有效
    public var removeNullValues: Bool = false
    /// 数据解析方式
    public var contentType: HTTPContentType = .json
    /// 数据解析回调
    public var analyticHandler: HTTPParser.AnalyticHandler?
    /// 默认解析实例
    public static let `default`: HTTPParser = HTTPParser()
    /// 下载选项
    public var downloadOptions: HTTPDownloadOptions = [.createIntermediateDirectories, .removeExistsFile]
    /// 接受的响应数据类型
    public var acceptableContentTypes: [HTTPContentType]!
    
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
        if contentType == .none {
            return data
        }
        
        // 判断数据是否为空
        guard let responseData = data, responseData.isEmpty == false else {
            throw HTTPError.dataParseFailure(.zeroByteData)
        }
        
        if responseData == Data(bytes: " ", count: 1) {
            throw HTTPError.dataParseFailure(.zeroByteData)
        }
        
        // 判断是否支持自定义解析数据
        if let analyticHandler = analyticHandler {
            guard let responseObject = analyticHandler(responseData, contentType) else {
                throw HTTPError.dataParseFailure(.cannotDecodeData)
            }
            return responseObject
        }
        
        // 解析数据
        var responseObject: Any = responseData
        switch contentType {
        case .json:
            responseObject = try json(responseData)
        case .plainText:
            responseObject = try plainText(responseData)
        case .xml:
            responseObject = try xml(responseData)
        case .plist:
            responseObject = try plist(responseData)
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
            throw HTTPError.responseParseFailure(.underlyingError(error))
        }

        // 响应是否合法
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.responseParseFailure(.cannotParseResponse(response))
        }
        
        // 检查状态码
        let statusCode = httpResponse.statusCode
        guard acceptableStatusCodes.contains(statusCode) else {
            throw HTTPError.responseParseFailure(.unacceptedStatusCode(statusCode))
        }
        
        // 检查数据类型 先确认是否检查, 便于外部自定义
        var expectedContentTypes: [HTTPContentType] = []
        if let acceptableContentTypes = acceptableContentTypes {
            expectedContentTypes.append(contentsOf: acceptableContentTypes)
        }
        if contentType != .none {
            expectedContentTypes.append(contentType)
        }
        guard expectedContentTypes.isEmpty == false else { return }
        guard let mimeType = httpResponse.mimeType else {
            throw HTTPError.responseParseFailure(.missingMimeType)
        }
        // 判断是否接受响应类型
        var acceptable = false
        for expectedContentType in expectedContentTypes {
            if mimeType.contains(expectedContentType.rawString) {
                acceptable = true
                break
            }
        }
        guard acceptable else {
            let rawStrings = expectedContentTypes.compactMap { $0.rawString }
            throw HTTPError.responseParseFailure(.unacceptedContentType(mimeType, accepts: rawStrings))
        }
    }
}

// MARK: - 数据解析
private extension HTTPParser {
    
    /// 解析JSON数据
    /// - Parameter data: JSON数据流
    /// - Returns: JSON对象
    func json(_ data: Data) throws -> Any {
        
        var jsonObject: Any
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: jsonReadingOptions)
        } catch {
            throw HTTPError.dataParseFailure(.underlyingError(error))
        }
        
        // 删除null
        if removeNullValues {
            if let array = jsonObject as? [Any?] {
                var result: [Any] = [Any]()
                for value in array {
                    guard let value = value else { continue }
                    if value is NSNull { continue }
                    result.append(value)
                }
                jsonObject = result
            } else if let dic = jsonObject as? [AnyHashable:Any?] {
                var result: [AnyHashable:Any] = [AnyHashable:Any]()
                for (key, value) in dic {
                    guard let value = value else { continue }
                    if value is NSNull { continue }
                    result[key] = value
                }
                jsonObject = result
            }
        }
        
        return jsonObject
    }
    
    /// 解析文本数据
    /// - Parameter data: 文本数据流
    /// - Returns: 文本
    func plainText(_ data: Data) throws -> String {
        
        guard let stringObject = String(data: data, encoding: stringEncoding) else {
            throw HTTPError.dataParseFailure(.cannotDecodeData)
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
            throw HTTPError.dataParseFailure(.cannotDecodeData)
        }
        return propertyList
    }
}
