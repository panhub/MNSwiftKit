//
//  NSDateFormatter+MNExtension.swift
//  MNFoundation
//
//  Created by MNFoundation on 2021/10/27.
//  日期格式化器

import Foundation

extension DateFormatter {
    
    /// 时间格式
    @objc public static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "mm:ss"
        return formatter
    }()
}
