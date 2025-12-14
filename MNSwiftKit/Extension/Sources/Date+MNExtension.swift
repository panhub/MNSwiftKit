//
//  Date+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/27.
//  日期格式化

import Foundation

/// 内部保留播放时间格式化起
fileprivate var MNPlayTimeFormatter: DateFormatter?

extension MNNameSpaceWrapper where Base == Date {
    
    /// 时间戳 - 秒
    public var second: Int { Int(base.timeIntervalSince1970) }
    
    /// 时间戳 - 毫秒
    public var millisecond: Int { Int(base.timeIntervalSince1970*1000.0) }
    
    /// 格式化字符串 'yyyy-MM-dd HH:mm:ss'
    public var dateString: String { string(using: "yyyy-MM-dd HH:mm:ss") }
    
    /// 播放时间格式化
    public var playTime: String {
        var dateFormatter: DateFormatter!
        if let formatter = MNPlayTimeFormatter {
            dateFormatter = formatter
        } else {
            let formatter = DateFormatter()
            dateFormatter = formatter
            MNPlayTimeFormatter = formatter
        }
        if base.timeIntervalSince1970 >= 3600.0 {
            dateFormatter.dateFormat = "H:mm:ss"
        } else {
            dateFormatter.dateFormat = "mm:ss"
        }
        return dateFormatter.string(from: base)
    }
    
    /// 日期格式化
    /// - Parameter format: 格式
    /// - Returns: 格式化后的日期字符串
    public func string(using format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = format
        return formatter.string(from: base)
    }
}
