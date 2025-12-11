//
//  HTTPParam.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/19.
//  链接参数提取

import Foundation
import CoreFoundation

public struct HTTPParam {
    
    /// 字段
    public let field: String
    
    /// 值
    public let value: String
    
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
}

extension HTTPParam {
    
    /// 字符串形式
    /// - Parameter options: 编码选项
    /// - Returns: 字符串形式
    public func encode(options: EncodeOptions = .all) -> String? {
        let field = options.contains(.field) ? HTTPParam.encoding(field) : field
        guard let field = field, field.isEmpty == false else { return nil }
        let value = options.contains(.value) ? HTTPParam.encoding(value) : value
        guard let value = value else { return nil }
        return field + "=" + value
    }
    
    /// 对字符串进行URL编码
    /// - Parameters:
    ///   - string: 需要编码的字符串
    ///   - count: 步长, 即每次处理的字符数量
    ///   - delimiters: 需要强制编码的的字符
    /// - Returns: 编码后的字符串
    public static func encoding(_ string: String, step count: Int = 100, mandatory delimiters: String = ":#@!$&?'()[]*+,;= ") -> String? {
        // 定义通用编码字符集
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: delimiters)
        // 分段编码
        var result = ""
        var encoded = result.count
        while encoded < string.count {
            let length = min(string.count - encoded, count)
            let startIndex = string.index(string.startIndex, offsetBy: encoded)
            let endIndex = string.index(startIndex, offsetBy: length - 1)
            let range = string.rangeOfComposedCharacterSequences(for: startIndex...endIndex)
            let substring = String(string[range])
            guard let encodstring = substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) else { return nil }
            result.append(encodstring)
            encoded += substring.count
        }
        return result
    }
    
    /// 提取网络请求使用的参数
    /// - Parameters:
    ///   - param: 参数来源
    ///   - options: 编码选项
    /// - Returns: 参数字符串
    public static func extract(_ param: Any!, options: HTTPParam.EncodeOptions = .all) -> String? {
        guard let param = param else { return nil }
        // 字符串直接编码
        if param is String {
            let string = param as! String
            return options.isEmpty ? string : HTTPParam.encoding(string)
        }
        // 字典
        guard let dic = param as? [String: Any] else { return nil }
        guard let pairs = pairs(from: dic) else { return nil }
        let result = pairs.compactMap { $0.encode(options: options) }
        return result.isEmpty ? nil : result.joined(separator: "&")
    }
    
    /// 提取网络请求使用的参数集合
    /// - Parameter items: 参数集合来源
    /// - Returns: 参数集合
    public static func pairs(from items: [String: Any]) -> [HTTPParam]? {
        var pairs = [HTTPParam]()
        for (key, param) in items {
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
        return pairs.isEmpty ? nil : pairs
    }
}
