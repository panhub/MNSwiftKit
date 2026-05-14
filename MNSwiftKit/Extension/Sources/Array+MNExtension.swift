//
//  Array+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/6/4.
//  数组扩展

import Foundation

extension Array where Element: Equatable {
    
    /// 移动元素到首位
    /// - Parameter element: 元素
    /// - Returns: 是否移动成功
    @discardableResult
    public mutating func mn_moveToFirst(_ element: Element) -> Bool {
        mn_move(element, to: 0)
    }
    
    /// 移动元素到尾部
    /// - Parameter element: 元素
    /// - Returns: 是否移动成功
    @discardableResult
    public mutating func mn_moveToLast(_ element: Element) -> Bool {
        mn_move(element, to: count - 1)
    }
    
    /// 移动元素到指定位置
    /// - Parameter
    /// - element: 元素
    /// - newIndex: 新的索引
    /// - Returns: 是否移动成功
    @discardableResult
    public mutating func mn_move(_ element: Element, to newIndex: Int) -> Bool {
        guard let index = firstIndex(of: element) else { return false }
        return mn_move(at: index, to: newIndex)
    }
    
    /// 移动指定位置的元素到另一个位置
    /// - Parameter
    /// - index: 元素所在的索引
    /// - newIndex: 新的索引
    /// - Returns: 是否移动成功
    @discardableResult
    public mutating func mn_move(at index: Int, to newIndex: Int) -> Bool {
        guard index < count, newIndex >= 0, newIndex < count else { return false }
        if index == newIndex { return true }
        let element = remove(at: index)
        insert(element, at: newIndex)
        return true
    }
}

public protocol MNArrayRepresentable: RandomAccessCollection & MutableCollection & RangeReplaceableCollection
    where Index == Int, SubSequence == ArraySlice<Element> {
}

extension Array: MNArrayRepresentable {}

extension MNNameSpaceWrapper where Base: MNArrayRepresentable {
    
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

public protocol MNEquatableArray: RandomAccessCollection & MutableCollection & RangeReplaceableCollection
    where Element: Equatable, Index == Int, SubSequence == ArraySlice<Element> {
}

extension Array: MNEquatableArray where Element: Equatable {}

extension MNNameSpaceWrapper where Base: MNEquatableArray {
    
    /// 删除数组内相同元素
    /// - Returns: 删除相同元素后的数组
    public func uniqued() -> Base {
        guard base.isEmpty == false else { return base }
        if #available(iOS 15.0, *) {
            let orderedSet = NSOrderedSet(array: base as! [Any])
            return orderedSet.array as! Base
        }
        return base.reduce(into: [Base.Element]()) { partialResult, element in
            if partialResult.contains(element) == false {
                partialResult.append(element)
            }
        } as! Base
    }
}
