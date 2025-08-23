//
//  Array+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/6/4.
//  数组扩展

import Foundation

extension Array {
    
    /// 遍历元素
    /// - Parameter block: 回调外界使用
    public func enumElement(_ block: (Element, Int, UnsafeMutablePointer<Bool>) -> Void) {
        guard count > 0 else { return }
        var stop: Bool = false
        for idx in 0..<count {
            block(self[idx], idx, &stop)
            guard stop == false else { break }
        }
    }
    
    /// 按元素个数分组
    /// - Parameter capacity: 容量
    /// - Returns: 分组后的数组
    public func group(by capacity: Int) -> [[Element]] {
        guard count > 0, capacity > 0 else { return [] }
        return stride(from: 0, to: count, by: capacity).map {
            Array(self[$0..<Swift.min($0 + capacity, count)])
        }
    }
}

extension Array where Element: Equatable {
    
    /// 删除数组内相同元素
    /// - Returns: 删除相同元素后的数组
    public func uniqued() -> [Element] {
        guard isEmpty == false else { return self }
        if #available(iOS 15.0, *) {
            let orderedSet = NSOrderedSet(array: self)
            let uniqueArray = orderedSet.array as! [Element]
            return uniqueArray
        }
        return reduce(into: [Element]()) {
            if $0.contains($1) == false {
                $0.append($1)
            }
        }
        //reduce([Element]()) { $0.contains($1) ? $0 : ($0 + [$1]) }
    }
    
    /// 删除数组内相同元素
    public mutating func unique() {
        removeAll()
        append(contentsOf: uniqued())
    }
}

extension Array where Element: NSObjectProtocol {
    
    /// 元素调用函数
    /// - Parameters:
    ///   - aSelector: 函数
    public func makeObjectsPerform(_ aSelector: Selector) {
        for element in self {
            let _ = element.perform(aSelector)
        }
    }
    
    /// 元素调用函数
    /// - Parameters:
    ///   - aSelector: 函数
    ///   - object: 参数
    public func makeObjectsPerform(_ aSelector: Selector, with object: Any!) {
        for element in self {
            let _ = element.perform(aSelector, with: object)
        }
    }
    
    /// 元素调用函数
    /// - Parameters:
    ///   - aSelector: 函数
    ///   - object1: 参数1
    ///   - object2: 参数2
    public func makeObjectsPerform(_ aSelector: Selector, with object1: Any!, with object2: Any!) {
        for element in self {
            let _ = element.perform(aSelector, with: object1, with: object2)
        }
    }
}
