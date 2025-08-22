//
//  Calendar+MNExtension.swift
//  MNFoundation
//
//  Created by MNFoundation on 2025/1/9.
//  日历

import Foundation

extension Calendar {
    
    public func endOfDay(for date: Date) -> Date {
        self.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }
}
