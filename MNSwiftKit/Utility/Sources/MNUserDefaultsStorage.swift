//
//  MNUserDefaultsStorage.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/23.
//  数据缓存包装

import Foundation

@propertyWrapper
/// 属性包装器
public struct MNUserDefaultsStorage<T> {
    /// 存取的key
    private let key: String
    /// 组名
    private let suite: String?
    /// 默认值
    private let defaultValue: T
    
    private var storage: UserDefaults? {
        if let suite = suite, suite.isEmpty == false {
            return UserDefaults(suiteName: suite)
        }
        return .standard
    }
    
    public var wrappedValue: T {
        get {
            guard let storage = storage else { return defaultValue }
            let value = storage.object(forKey: key)
            if let optionalType = T.self as? MNUserDefaultsOptional.Type {
                return optionalType.create(from: value) as! T
            }
            if let value = value as? T { return value }
            return defaultValue
        }
        set {
            guard let storage = storage else { return }
            if let optionalValue = newValue as? MNUserDefaultsOptional, optionalValue.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.set(newValue, forKey: key)
            }
            storage.synchronize()
        }
    }
    
    /// 构造属性包装器
    /// - Parameters:
    ///   - defaultName: 存储的key
    ///   - defaultValue: 默认值
    ///   - suiteName: 公共沙盒组名
    public init(suite suiteName: String? = nil, key defaultName: String, default defaultValue: T) {
        self.key = defaultName
        self.suite = suiteName
        self.defaultValue = defaultValue
    }
}

private protocol MNUserDefaultsOptional {
    
    var isNil: Bool { get }
    
    var wrappedValue: Any? { get }
    
    static func create(from value: Any?) -> Self
}

extension Optional: MNUserDefaultsOptional {
    
    var isNil: Bool {
        
        self == nil
    }
    
    var wrappedValue: Any? {
        switch self {
        case .none: return nil
        case .some(let wrapped): return wrapped
        }
    }
    
    static func create(from value: Any?) -> Wrapped? {
        if let value = value as? Wrapped {
            return value
        }
        return nil
    }
}
