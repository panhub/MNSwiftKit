//
//  CFNotificationCenter.swift
//  MNFoundation
//
//  Created by MNFoundation on 2024/5/6.
//

import Foundation
import CoreFoundation
import ObjectiveC.runtime
import ObjectiveC.objc_sync

fileprivate class CFNotificationTarget: Equatable {
    /// 响应方法
    let selector: Selector
    /// 响应者
    weak var target: NSObject?
    
    /// 构造通知响应者
    /// - Parameters:
    ///   - target: 响应者
    ///   - selector: 响应方法
    init(target: NSObject, selector: Selector) {
        self.target = target
        self.selector = selector
    }
    
    /// 执行响应事件
    /// - Parameters:
    ///   - name: 通知名称
    ///   - object: 通知携带对象
    ///   - userInfo: 通知携带参数
    func strike(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable:Any]? = nil) {
        guard let target = target else { return }
        guard let cls = object_getClass(target) else { return }
        guard let method = class_getInstanceMethod(cls, selector) else { return }
        let numberOfArguments = method_getNumberOfArguments(method)
        if numberOfArguments > 0 {
            let notification = Notification(name: name, object: object, userInfo: userInfo)
            target.perform(selector, with: notification)
        } else {
            target.perform(selector)
        }
    }
    
    static func == (lhs: CFNotificationTarget, rhs: CFNotificationTarget) -> Bool {
        guard let lhstarget = lhs.target else { return false }
        guard let rhstarget = rhs.target else { return false }
        return lhstarget == rhstarget
    }
}

extension NotificationCenter {
    
    /// 获取本地通知中心
    public static let local: CFNotificationCenter = CFNotificationCenter(source: .local)
    
    /// 获取Darwin层通知中心
    public static let darwin: CFNotificationCenter = CFNotificationCenter(source: .darwin)
}

/// 通知中心
public class CFNotificationCenter {
    
    /// 通知中心类型
    public enum Source {
        ///   本地  darwin层
        case local, darwin
    }
    
    /// 通知中心类型
    private let source: CFNotificationCenter.Source
    
    /// 内部保存监听者
    fileprivate var targets = [Notification.Name:[CFNotificationTarget]]()
    
    /// 构造通知中心
    /// - Parameter source: 通知中心源
    public init(source: CFNotificationCenter.Source) {
        self.source = source
    }
    
    /// 发送通知
    /// - Parameter notification: 通知实例
    public func post(_ notification: Notification) {
        var userInfo: CFDictionary!
        if let info = notification.userInfo {
            userInfo = info as CFDictionary
        }
        var object: UnsafeRawPointer!
        if let obj = notification.object as? AnyObject {
            object = UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
        }
        let name = CFNotificationName(notification.name.rawValue as CFString)
        let center = source == .local ? CFNotificationCenterGetLocalCenter() : CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(center, name, object, userInfo, true)
    }

    
    /// 发送通知
    /// - Parameters:
    ///   - aName: 通知名称
    ///   - anObject: 传递实例
    ///   - aUserInfo: 传递信息
    public func post(name aName: Notification.Name, object anObject: AnyObject? = nil, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        let notification = Notification(name: aName, object: anObject, userInfo: aUserInfo)
        post(notification)
    }
    
    /// 注册通知
    /// - Parameters:
    ///   - aObserver: 响应对象
    ///   - aSelector: 响应方法
    ///   - aName: 通知名称
    ///   - anObject: 参数
    public func addObserver(_ aObserver: NSObject, selector aSelector: Selector, name aName: Notification.Name) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        var targets = targets[aName] ?? [CFNotificationTarget]()
        guard targets.contains(where: {
            guard let target = $0.target else { return false }
            return target == aObserver
        }) == false else { return }
        let target = CFNotificationTarget(target: aObserver, selector: aSelector)
        targets.append(target)
        self.targets[aName] = targets
        guard targets.count == 1 else { return }
        let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let center = source == .local ? CFNotificationCenterGetLocalCenter() : CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterAddObserver(center, observer, CFNotificationCenter.notificationEventHandler, aName.rawValue as CFString, nil, .deliverImmediately)
    }
    
    /// 删除通知
    /// - Parameters:
    ///   - aObserver: 该通知监听者
    ///   - aName: 通知名称
    public func removeObserver(_ aObserver: NSObject, name aName: Notification.Name) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        guard var targets = targets[aName] else { return }
        targets.removeAll {
            guard let target = $0.target else { return true }
            return target == aObserver
        }
        if targets.isEmpty {
            // 不再监听此通知
            self.targets.removeValue(forKey: aName)
            let name = CFNotificationName(aName.rawValue as CFString)
            let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
            let center = source == .local ? CFNotificationCenterGetLocalCenter() : CFNotificationCenterGetDarwinNotifyCenter()
            CFNotificationCenterRemoveObserver(center, observer, name, nil)
        } else {
            self.targets[aName] = targets
        }
    }
    
    /// 删除所有监听
    /// - Parameter aObserver: 监听对象
    public func removeObserver(_ aObserver: NSObject) {
        for name in targets.keys {
            removeObserver(aObserver, name: name)
        }
    }
    
    deinit {
        for name in targets.keys {
            let name = CFNotificationName(name.rawValue as CFString)
            let observer = UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque())
            let center = source == .local ? CFNotificationCenterGetLocalCenter() : CFNotificationCenterGetDarwinNotifyCenter()
            CFNotificationCenterRemoveObserver(center, observer, name, nil)
        }
        targets.removeAll()
    }
}

extension CFNotificationCenter {
    
    /// 通知响应回调
    private static let notificationEventHandler: CFNotificationCallback = { _, observer, name, object, userInfo in
        guard let observer = observer else { return }
        guard let center = Unmanaged<AnyObject>.fromOpaque(observer).takeUnretainedValue() as? CFNotificationCenter  else { return }
        guard let name = name else { return }
        let aName = Notification.Name(rawValue: name.rawValue as String)
        objc_sync_enter(center)
        let targets = center.targets[aName]
        objc_sync_exit(center)
        guard let targets = targets else { return }
        var aObject: Any?
        if let object = object {
            aObject = Unmanaged<AnyObject>.fromOpaque(object).takeUnretainedValue()
        }
        for target in targets {
            target.strike(name: aName, object: aObject, userInfo: userInfo as? [AnyHashable:Any])
        }
    }
}


