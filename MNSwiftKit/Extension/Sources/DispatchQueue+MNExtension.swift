//
//  DispatchQueue+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/7.
//  针对一次执行的简单解决方案

import Foundation

extension DispatchQueue {
    
    nonisolated(unsafe) fileprivate static var MNQueueOnceTracker: [String] = [String]()
}

extension MNNameSpaceWrapper where Base == DispatchQueue {
    
    /// 执行一次
    /// - Parameters:
    ///   - token: 判断是否执行的key
    ///   - block: 执行回调
    public class func once(token: String, block: ()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if DispatchQueue.MNQueueOnceTracker.contains(token) { return }
        DispatchQueue.MNQueueOnceTracker.append(token)
        block()
    }
    
    /// 执行一次
    /// - Parameters:
    ///   - file: 当前文件
    ///   - function: 当前方法
    ///   - line: 当前行数
    ///   - block: 执行回调
    public class func once(file: String = #file, function: String = #function, line: Int = #line, block: ()->Void) {
        let token: String = [file, function, String(line)].joined(separator: "-")
        once(token: token, block: block)
    }
}

