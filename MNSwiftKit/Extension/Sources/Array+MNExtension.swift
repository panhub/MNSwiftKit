//
//  Array+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/6/4.
//  数组扩展

import Foundation

extension NameSpaceWrapper where Base == Array<Any> {
    
    /// 遍历元素
    /// - Parameter block: 回调外界使用
    public func enumElement(_ block: (Base.Element, Int, UnsafeMutablePointer<Bool>) -> Void) {
        guard base.count > 0 else { return }
        var stop: Bool = false
        for idx in 0..<base.count {
            block(base[idx], idx, &stop)
            guard stop == false else { break }
        }
    }
    
    /// 按元素个数分组
    /// - Parameter capacity: 容量
    /// - Returns: 分组后的数组
    public func group(by capacity: Int) -> [[Base.Element]] {
        guard base.count > 0, capacity > 0 else { return [] }
        return stride(from: 0, to: base.count, by: capacity).map {
            Array(base[$0..<Swift.min($0 + capacity, base.count)])
        }
    }
}

//extension NameSpaceWrapper where Base == Array<any Equatable> {
//    
//    /// 删除数组内相同元素
//    /// - Returns: 删除相同元素后的数组
//    public func uniqued() -> [Base.Element] {
//        guard base.isEmpty == false else { return base }
//        if #available(iOS 15.0, *) {
//            let orderedSet = NSOrderedSet(array: base)
//            let uniqueArray = orderedSet.array as! [Base.Element]
//            return uniqueArray
//        }
//        return base.reduce(into: []) { partialResult, element in
//            if partialResult {
//                partialResult.append(element)
//            }
//        }
//    }
//}
