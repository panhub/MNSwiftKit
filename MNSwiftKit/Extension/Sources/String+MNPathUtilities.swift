//
//  String+MNPathUtilities.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/11.
//  文件路径

import Foundation

extension NameSpaceWrapper where Base == String {
    
    /// 文档目录
    public class var documentDirectory: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    /// 文档目录
    public class var libraryDirectory: String {
        NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
    }
    
    /// 缓存目录
    public class var cachesDirectory: String {
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    
    /// Preferences目录
    public class var preferencesDirectory: String {
        (libraryDirectory as NSString).appendingPathComponent("Preferences")
    }
    
    /// 在文档目录下追加路径
    /// - Parameter pathComponent: 追加的路径
    /// - Returns: 追加后的路径
    public class func document(appending pathComponent: String) -> String {
        (documentDirectory as NSString).appendingPathComponent(pathComponent)
    }
    
    /// 在文档目录下追加目录
    /// - Parameter pathComponent: 追加的路径
    /// - Returns: 追加后的路径
    public class func library(appending pathComponent: String) -> String {
        (libraryDirectory as NSString).appendingPathComponent(pathComponent)
    }
    
    /// 在缓存目录下追加目录
    /// - Parameter pathComponent: 追加的路径
    /// - Returns: 追加后的路径
    public class func caches(appending pathComponent: String) -> String {
        (cachesDirectory as NSString).appendingPathComponent(pathComponent)
    }
    
    /// 在偏好目录下追加目录
    /// - Parameter pathComponent: 追加的路径
    /// - Returns: 追加后的路径
    public class func preferences(appending pathComponent: String) -> String {
        (preferencesDirectory as NSString).appendingPathComponent(pathComponent)
    }
}

// MARK: - Path
extension NameSpaceWrapper where Base == String {
    
    /// 路径分割
    public var pathComponents: [String] {
        (base as NSString).pathComponents
    }
    
    /// 是否是绝对路径
    public var isAbsolutePath: Bool {
        (base as NSString).isAbsolutePath
    }
    
    /// 最后一个路径部分
    public var lastPathComponent: String {
        (base as NSString).lastPathComponent
    }
    
    /// 删除路径最后一部分
    public var deletingLastPathComponent: String {
        (base as NSString).deletingLastPathComponent
    }
    
    /// 路径后缀
    public var pathExtension: String {
        (base as NSString).pathExtension
    }
    
    /// 删除路径后缀
    public var deletingPathExtension: String {
        (base as NSString).deletingPathExtension
    }
    
    /// 追加路径
    /// - Parameter str: 追加的路径
    /// - Returns: 追加后的路径
    public func appendingPathComponent(_ str: String) -> String {
        (base as NSString).appendingPathComponent(str)
    }
    
    /// 追加后缀
    /// - Parameter str: 后缀
    /// - Returns: 追加后的路径
    public func appendingPathExtension(_ str: String) -> String! {
        (base as NSString).appendingPathExtension(str)
    }
    
    /// 可用的路径
    /// -----/abc.png => -----/abc_2.png
    /// -----/abc_2.png => -----/abc_3.png
    public var availablePath: String? {
        guard isAbsolutePath else { return nil }
        guard FileManager.default.fileExists(atPath: base) else { return base }
        var name = deletingPathExtension.mn.lastPathComponent
        var components = name.components(separatedBy: "_")
        if components.count > 1 {
            let last = components.removeLast()
            let digitCharacterSet: CharacterSet = .decimalDigits
            let isAllDigits = last.unicodeScalars.allSatisfy { digitCharacterSet.contains($0) }
            if isAllDigits {
                let number = NSDecimalNumber(string: last).intValue + 1
                let string = NSNumber(value: number).stringValue
                components.append(string)
                name = components.joined(separator: "_")
            } else {
                name.append("_2")
            }
        } else {
            name.append("_2")
        }
        let pathExtension = pathExtension
        if pathExtension.isEmpty == false {
            name.append("." + pathExtension)
        }
        let path = deletingLastPathComponent.mn.appendingPathComponent(name)
        return path.mn.availablePath
    }
}

