//
//  MNNetworkReachability.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/27.
//  网络可达性检测<可达性并不保证数据包一定会被主机接收到>

import CoreAudio
import Foundation
import CoreTelephony
import SystemConfiguration
import ObjectiveC.objc_sync

public extension Notification.Name {
    
    /// 网络监测通知
    static let networkReachabilityNotificationName = Notification.Name("com.mn.network.reachability.notification.name")
}

public class MNNetworkReachability: NSObject {
    
    /// 定义网络状态
    public enum Status: String {
        /// 不可达
        case unreachable
        /// 基带网络
        case wwan = "WWAN"
        /// 局域网Wi-Fi
        case wifi = "Wi-Fi"
    }
    
    /// 定义广域网技术格式
    public enum Technology: String {
        case unknown
        case wwan2g = "2G"
        case wwan3g = "3G"
        case wwan4g = "4G"
        case wwan5g = "5G"
    }
    
    /// 内部检测实例
    private var reachability: SCNetworkReachability?
    
    /// 外界快速获取实例
    public static let `default`: MNNetworkReachability = MNNetworkReachability()
    
    /// 是否在监听
    public private(set) var isMonitoring: Bool = false
    
    /// 网络信息
    private let networkInfo = CTTelephonyNetworkInfo()
    
    /// 检测回调队列
    private static let Queue = DispatchQueue(label: "com.mn.network.reachability")
    
    /// 检测事件回调 主线程
    public var updateHandler: ((MNNetworkReachability.Status)->Void)?
    
    /// 获取广域网状态标识
    private lazy var technologys: [String: MNNetworkReachability.Technology] = {
        var technologys: [String: MNNetworkReachability.Technology] = [:]
        technologys[CTRadioAccessTechnologyGPRS] = .wwan2g
        technologys[CTRadioAccessTechnologyEdge] = .wwan2g
        technologys[CTRadioAccessTechnologyWCDMA] = .wwan3g
        technologys[CTRadioAccessTechnologyHSDPA] = .wwan3g
        technologys[CTRadioAccessTechnologyHSUPA] = .wwan3g
        technologys[CTRadioAccessTechnologyCDMA1x] = .wwan3g
        technologys[CTRadioAccessTechnologyCDMAEVDORev0] = .wwan3g
        technologys[CTRadioAccessTechnologyCDMAEVDORevA] = .wwan3g
        technologys[CTRadioAccessTechnologyCDMAEVDORevB] = .wwan3g
        technologys[CTRadioAccessTechnologyeHRPD] = .wwan3g
        technologys[CTRadioAccessTechnologyLTE] = .wwan4g
        if #available(iOS 14.1, *) {
            technologys[CTRadioAccessTechnologyNRNSA] = .wwan5g
            technologys[CTRadioAccessTechnologyNR] = .wwan5g
        }
        return technologys
    }()
    
    /// 网络状态变化回调
    private lazy var reachabilityCallBack: SCNetworkReachabilityCallBack = { _, _, context in
        // 通知状态变化
        guard let context = context else { return }
        guard let target = Unmanaged<AnyObject>.fromOpaque(context).takeUnretainedValue() as? MNNetworkReachability else { return }
        let status = target.status
        DispatchQueue.main.async { [weak target] in
            guard let target = target else { return }
            target.updateHandler?(status)
            NotificationCenter.default.post(name: .networkReachabilityNotificationName, object: target)
        }
    }
    
    deinit {
        cancelMonitoring()
    }
    
    public override init() {
        super.init()
        var addr_in: sockaddr_in = sockaddr_in()
        bzero(&addr_in, MemoryLayout.size(ofValue: addr_in))
        addr_in.sin_len = __uint8_t(MemoryLayout.size(ofValue: addr_in))
        addr_in.sin_family = sa_family_t(AF_INET)
        guard let reachability = withUnsafePointer(to: &addr_in, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        }) else { return }
        self.reachability = reachability
    }
    
    public init(reachability: SCNetworkReachability) {
        super.init()
        self.reachability = reachability
    }
    
    public convenience init?(hostname: String) {
        guard let chars = hostname.cString(using: .utf8) else { return nil }
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, chars) else { return nil }
        self.init(reachability: reachability)
    }
    
    public convenience init?(address: sockaddr) {
        var addr = address
        guard let reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &addr) else { return nil }
        self.init(reachability: reachability)
    }
    
    public func startMonitoring() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        guard isMonitoring == false, let reachability = reachability else { return }
        var context = SCNetworkReachabilityContext()
        context.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        guard SCNetworkReachabilitySetCallback(reachability, reachabilityCallBack, &context) else {
#if DEBUG
            print("SCNetworkReachabilitySetCallback() failed: \(SCErrorString(SCError()))")
#endif
            return
        }
        guard SCNetworkReachabilitySetDispatchQueue(reachability, MNNetworkReachability.Queue) else {
            SCNetworkReachabilitySetCallback(reachability, nil, nil)
#if DEBUG
            print("SCNetworkReachabilitySetDispatchQueue() failed: \(SCErrorString(SCError()))")
#endif
            return
        }
        isMonitoring = true
    }
    
    public func cancelMonitoring() {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        guard isMonitoring, let reachability = reachability else { return }
        isMonitoring = false
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
    }
}

// MARK: - 网络状态
extension MNNetworkReachability {
    
    /// 是否可达
    public var isReachable: Bool { status != .unreachable }
    
    /// 是否是Wifi
    public var isWifiReachable: Bool { status == .wifi }
    
    /// 是否是无线广域网
    public var isCellularReachable: Bool { status == .wwan }
    
    /// 当前网络状态
    public var status: MNNetworkReachability.Status {
        guard let reachability = reachability else { return .unreachable }
        var flags: SCNetworkReachabilityFlags = []
        guard SCNetworkReachabilityGetFlags(reachability, &flags) else { return .unreachable }
        return status(with: flags)
    }
    
    private func status(with flags: SCNetworkReachabilityFlags) -> MNNetworkReachability.Status {
        // 无法连接网络
        guard flags.contains(.reachable) else { return .unreachable }
        if flags.contains(.interventionRequired) { return .unreachable } //|| flags.contains(.transientConnection)
        if flags.contains(.isWWAN) {
#if !arch(i386) && !arch(x86_64) && !targetEnvironment(simulator)
            // 真机
            return .wwan
#endif
        }
        return .wifi
    }
}

// MARK: - 无线广域网类型
extension MNNetworkReachability {
    
    /// 当前广域网状态
    public var technology: MNNetworkReachability.Technology {
        guard isCellularReachable else { return .unknown }
        var technology: MNNetworkReachability.Technology = .unknown
        if #available(iOS 12.0, *) {
            if let serviceCurrentRadioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology {
                for key in serviceCurrentRadioAccessTechnology.values {
                    guard let value = technologys[key] else { continue }
                    technology = value
                    break
                }
            }
        } else if let current = networkInfo.currentRadioAccessTechnology, let value = technologys[current] {
            technology = value
        }
        return technology
    }
}

// MARK: - DEBUG
extension MNNetworkReachability {
    
    override public var debugDescription: String {
        
        "status:\(status.rawValue) technology:\(technology.rawValue)"
    }
}
