//
//  URL+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/10/27.
//  URL扩展

import Foundation

extension URL {
    
    /// 获取参数列表, 若链接不合法, 则为空
    public var queryItems: [String:String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String:String]()) { $0[$1.name] = ($1.value ?? "") }
    }
    
    /// 初始化本地路径引用
    /// - Parameter filePath: 本地绝对路径
    public init(fileAtPath filePath: String) {
        if #available(iOS 16.0, *) {
            self.init(filePath: filePath)
        } else {
            self.init(fileURLWithPath: filePath)
        }
    }
    
    /// 路径的字符串表示
    public var rawPath: String {
        if #available(iOS 16.0, *) {
            return path(percentEncoded: false)
        }
        return path
    }
}
