//
//  Calendar+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/1/9.
//  日历

import Foundation

extension MNNameSpaceWrapper where Base == Calendar {
    
    /// 某个日期的结束时间
    public func endOfDay(for date: Date) -> Date {
        
        base.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
}
