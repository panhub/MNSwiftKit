//
//  DispatchQueue+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/7.
//  针对一次执行的解决方案

import Foundation

extension DispatchQueue {
    
    nonisolated(unsafe) private static var onceTracker: [String] = [String]()
    
    public class func once(token: String, block: ()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if onceTracker.contains(token) { return }
        onceTracker.append(token)
        block()
    }
    
    public class func once(file: String = #file, function: String = #function, line: Int = #line, block: ()->Void) {
        let token: String = [file, function, String(line)].joined(separator: "-")
        once(token: token, block: block)
    }
}
