//
//  MNUserDefaults.swift
//  MNKit
//
//  Created by 冯盼 on 2021/9/23.
//  数据缓存包装

import Foundation

@propertyWrapper
/// 属性包装器
public struct UserDefaultsWrapper<T> {
    /// 存取的key
    private let key: String
    /// 组名
    private let suite: String?
    /// 默认值
    private let defaultValue: T?
    
    private var userDefaults: UserDefaults? {
        if let suite = suite, suite.isEmpty == false {
            return UserDefaults(suiteName: suite)
        }
        return .standard
    }
    
    public var wrappedValue: T? {
        get {
            guard let userDefaults = userDefaults else { return defaultValue }
            guard let value = userDefaults.object(forKey: key) as? T else { return defaultValue }
            return value
        }
        set {
            guard let userDefaults = userDefaults else { return }
            if let newValue = newValue {
                userDefaults.set(newValue, forKey: key)
            } else {
                userDefaults.removeObject(forKey: key)
            }
            userDefaults.synchronize()
        }
    }
    
    /// 构造属性包装器
    /// - Parameters:
    ///   - defaultName: 存储的key
    ///   - defaultValue: 默认值
    ///   - suiteName: 公共沙盒组名
    public init(suite suiteName: String? = nil, key defaultName: String, default defaultValue: T?) {
        self.key = defaultName
        self.suite = suiteName
        self.defaultValue = defaultValue
    }
}
