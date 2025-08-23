//
//  Calendar+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2025/1/9.
//  日历

import Foundation

extension Calendar {
    
    public func endOfDay(for date: Date) -> Date {
        self.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
}
