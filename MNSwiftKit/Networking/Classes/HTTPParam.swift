//
//  HTTPParam.swift
//  MNKit
//
//  Created by 冯盼 on 2021/7/19.
//  链接参数提取

import Foundation
import CoreGraphics

/// 提取参数
/// - Parameters:
///   - param: 参数
///   - options: 编码选项
/// - Returns: 提取后拼接的参数
public func HTTPExtractParam(_ param: Any!, options: HTTPParam.EncodeOptions = .all) -> String? {
    guard let param = param else { return nil }
    // 字符串直接编码
    if param is String {
        let string = param as! String
        return options.isEmpty ? string : HTTPParamEncoding(string)
    }
    // 字典
    if param is [String: Any] {
        let dic = param as! [String: Any]
        let pairs = HTTPParamPairExtract(dic)
        let result: [String] = pairs.compactMap { $0.encode(options: options) }
        return result.count > 0 ? result.joined(separator: "&") : nil
    }
    // 拒绝其他类型
    return nil
}

fileprivate func HTTPParamPairExtract(_ item: [String: Any]) -> [HTTPParam] {
    var pairs = [HTTPParam]()
    for (key, param) in item {
        var value: String?
        if param is String {
            value = param as? String
        } else if (param is Int || param is Double || param is CGFloat || param is Float || param is Int64 || param is Int32 || param is Int16 || param is Int8 || param is Float32 || param is Float64) {
            value = "\(param)"
        } else if param is Bool {
            value = (param as! Bool) ? "1" : "0"
        } else if param is ObjCBool {
            value = (param as! ObjCBool).boolValue ? "1" : "0"
        } else if param is NSNumber {
            value = (param as! NSNumber).stringValue
        } else if #available(iOS 14.0, *), param is Float16 {
            value = "\(param)"
        } else if let data = try?JSONSerialization.data(withJSONObject: param) {
            value = String(data: data, encoding: .utf8)
        }
        guard let value = value else { continue }
        let pair = HTTPParam(field: key, value: value)
        pairs.append(pair)
    }
    return pairs
}

// 参数编码
fileprivate let HTTPParamEncodeBatchLength = 100
fileprivate let HTTPParamEncodeDelimiters: String = ":#@!$&?'()[]*+,;= "
public func HTTPParamEncoding(_ string: String!) -> String? {
    guard let string = string else { return nil }
    // 定义通用编码字符集
    var allowedCharacterSet = CharacterSet.urlQueryAllowed
    allowedCharacterSet.remove(charactersIn: HTTPParamEncodeDelimiters)
    // 分段编码
    var count: Int = 0
    var param: String = ""
    while count < string.count {
        let length = min(string.count - count, HTTPParamEncodeBatchLength)
        let startIndex = string.index(string.startIndex, offsetBy: count)
        let endIndex = string.index(startIndex, offsetBy: length - 1)
        let range = string.rangeOfComposedCharacterSequences(for: startIndex...endIndex)
        let substring = String(string[range])
        guard let encodstring = substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) else { return nil }
        param.append(encodstring)
        count += substring.count
    }
    return param
}

public struct HTTPParam {
    
    /// 字段
    let field: String
    
    /// 值
    let value: String
    
    /// 编码选项
    public struct EncodeOptions: OptionSet {
        
        // 对字段编码
        public static let field = EncodeOptions(rawValue: 1 << 0)
        
        // 对值编码
        public static let value = EncodeOptions(rawValue: 1 << 1)
        
        // 全部编码
        public static let all: EncodeOptions = [.field, .value]
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// 字符串形式
    /// - Parameter options: 编码选项
    /// - Returns: 字符串形式
    func encode(options: EncodeOptions = .all) -> String? {
        let field: String? = options.contains(.field) ? HTTPParamEncoding(field) : field
        guard let field = field, field.count > 0 else { return nil }
        let value: String? = options.contains(.value) ? HTTPParamEncoding(value) : value
        guard let value = value else { return nil }
        return "\(field)=\(value)"
    }
}
