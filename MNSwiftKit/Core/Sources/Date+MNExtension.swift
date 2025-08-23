//
//  Date+MNExtension.swift
//  MNFoundation
//
//  Created by MNFoundation on 2021/10/27.
//

import Foundation

extension Date {
    
    /**时间戳 - 秒*/
    public static var timestamps: String { "\(Int(Date().timeIntervalSince1970))" }
    
    /**时间戳 - 毫秒*/
    public static var shortTimestamps: String { "\(Int(Date().timeIntervalSince1970*1000.0))" }
    
    /**格式化*/
    public var stringValue: String { stringValue(format: "yyyy-MM-dd HH:mm:ss") }
    
    /**播放时间格式*/
    public var timeValue: String {
        let formatter = DateFormatter.timeFormatter
        if timeIntervalSince1970 >= 3600.0 {
            formatter.dateFormat = "H:mm:ss"
        } else {
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: self)
    }
    
    public func stringValue(format: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 3600*8)
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// 前进一周
    public func forwardWeek() -> (from: Date, to: Date) {
        
        let calendar: Calendar = .current
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: self)!
        let startDate = calendar.startOfDay(for: tomorrow)
        
        let date = calendar.date(byAdding: .day, value: 7, to: self)!
        let endDate = calendar.endOfDay(for: date)
        
        return (startDate, endDate)
    }
    
    // 后退一周
    public func backwardWeek() -> (from: Date, to: Date)? {
        
        let calendar: Calendar = .current
        
        let date = calendar.date(byAdding: .day, value: -7, to: self)!
        let startDate = calendar.startOfDay(for: date)
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: self)!
        let endDate = calendar.endOfDay(for: yesterday)
        
        return (startDate, endDate)
    }
}

extension NSDate {
    
    /// 播放时间格式
    @objc public var timeValue: String {
        return (self as Date).timeValue
    }
}
