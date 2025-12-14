//
//  UIDevice+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/3/30.
//  设备管理

import UIKit
import Foundation
import ObjectiveC.runtime

/// 标记设备model
fileprivate var MNDeviceModel: String?

/// 标记是否是越狱设备
fileprivate var MNDeviceJailbroken: Bool?

extension MNNameSpaceWrapper where Base: UIDevice {
    
    /// 系统版本号 Double
    public var version: Double {
        NSDecimalNumber(string: base.systemVersion).doubleValue
    }
    
    /// 是否是越狱设备
    public var isJailbroken: Bool {
        if let isJailbrokenDevice = MNDeviceJailbroken { return isJailbrokenDevice }
        var isJailbrokenDevice = false
        let paths: [String] = ["/Applications/Cydia.app", "/Library/MobileSubstrate/MobileSubstrate.dylib", "/bin/bash", "/usr/sbin/sshd", "/etc/apt"]
        if let _ = getenv("DYLD_INSERT_LIBRARIES") {
            isJailbrokenDevice = true
        } else {
            for path in paths {
                guard FileManager.default.fileExists(atPath: path) else { continue }
                isJailbrokenDevice = true
                break
            }
        }
        if isJailbrokenDevice == false {
            if let url = URL(string: "cydia://"), UIApplication.shared.canOpenURL(url) {
                isJailbrokenDevice = true
            } else if FileManager.default.fileExists(atPath: "User/Applications/"), let contents = FileManager.default.contents(atPath: "User/Applications/"), contents.isEmpty == false {
                isJailbrokenDevice = true
            }
        }
        MNDeviceJailbroken = isJailbrokenDevice
        return isJailbrokenDevice
    }
    
    /// 设备型号
    /// https://www.theiphonewiki.com/wiki/Models
    public var model: String {
        if let model = MNDeviceModel { return model }
        var systemInfo: utsname = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        var model = identifier
        switch identifier {
        case "i386", "x86_64": model = "Simulator"
        case "iPhone1,1": model = "iPhone"
        case "iPhone1,2": model = "iPhone 3G"
        case "iPhone2,1": model = "iPhone 3GS"
        case "iPhone3,1": model = "iPhone 4"
        case "iPhone3,2": model = "iPhone 4"
        case "iPhone3,3": model = "iPhone 4"
        case "iPhone4,1": model = "iPhone 4S"
        case "iPhone5,1": model = "iPhone 5"
        case "iPhone5,2": model = "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3": model = "iPhone 5C (GSM)"
        case "iPhone5,4": model = "iPhone 5C (GSM+CDMA)"
        case "iPhone6,1": model = "iPhone 5S (GSM)"
        case "iPhone6,2": model = "iPhone 5S (GSM+CDMA)"
        case "iPhone7,1": model = "iPhone 6 Plus"
        case "iPhone7,2": model = "iPhone 6"
        case "iPhone8,1": model = "iPhone 6S"
        case "iPhone8,2": model = "iPhone 6S Plus"
        case "iPhone8,4": model = "iPhone SE"
        case "iPhone9,1": model = "iPhone 7"
        case "iPhone9,2": model = "iPhone 7 Plus"
        case "iPhone9,3": model = "iPhone 7"
        case "iPhone9,4": model = "iPhone 7 Plus"
        case "iPhone10,1": model = "iPhone 8"
        case "iPhone10,2": model = "iPhone 8 Plus"
        case "iPhone10,3": model = "iPhone X"
        case "iPhone10,4": model = "iPhone 8"
        case "iPhone10,5": model = "iPhone 8 Plus"
        case "iPhone10,6": model = "iPhone X"
        case "iPhone11,2": model = "iPhone XS"
        case "iPhone11,4": model = "iPhone XS Max"
        case "iPhone11,6": model = "iPhone XS Max"
        case "iPhone11,8": model = "iPhone XR"
        case "iPhone12,1": model = "iPhone 11"
        case "iPhone12,3": model = "iPhone 11 Pro"
        case "iPhone12,5": model = "iPhone 11 Pro Max"
        case "iPhone12,8": model = "iPhone SE (2nd generation)"
        case "iPhone13,1": model = "iPhone 12 Mini"
        case "iPhone13,2": model = "iPhone 12"
        case "iPhone13,3": model = "iPhone 12 Pro"
        case "iPhone13,4": model = "iPhone 12 Pro Max"
        case "iPhone14,2": model = "iPhone 13 Pro"
        case "iPhone14,3": model = "iPhone 13 Pro Max"
        case "iPhone14,4": model = "iPhone 13 Mini"
        case "iPhone14,5": model = "iPhone 13"
        case "iPhone14,6": model = "iPhone SE (3rd generation)"
        case "iPhone14,7": model = "iPhone 14"
        case "iPhone14,8": model = "iPhone 14 Plus"
        case "iPhone15,2": model = "iPhone 14 Pro"
        case "iPhone15,3": model = "iPhone 14 Pro Max"
        case "iPad1,1": model = "iPad"
        case "iPad1,2": model = "iPad 3G"
        case "iPad2,1": model = "iPad 2 (WiFi)"
        case "iPad2,2": model = "iPad 2"
        case "iPad2,3": model = "iPad 2 (CDMA)"
        case "iPad2,4": model = "iPad 2"
        case "iPad2,5": model = "iPad Mini (WiFi)"
        case "iPad2,6": model = "iPad Mini"
        case "iPad2,7": model = "iPad Mini (GSM+CDMA)"
        case "iPad3,1": model = "iPad 3 (WiFi)"
        case "iPad3,2": model = "iPad 3 (GSM+CDMA)"
        case "iPad3,3": model = "iPad 3"
        case "iPad3,4": model = "iPad 4 (WiFi)"
        case "iPad3,5": model = "iPad 4"
        case "iPad3,6": model = "iPad 4 (GSM+CDMA)"
        case "iPad4,1": model = "iPad Air (WiFi)"
        case "iPad4,2": model = "iPad Air (Cellular)"
        case "iPad4,4": model = "iPad Mini 2 (WiFi)"
        case "iPad4,5": model = "iPad Mini 2 (Cellular)"
        case "iPad4,6": model = "iPad Mini 2"
        case "iPad4,7": model = "iPad Mini 3"
        case "iPad4,8": model = "iPad Mini 3"
        case "iPad4,9": model = "iPad Mini 3"
        case "iPad5,1": model = "iPad Mini 4 (WiFi)"
        case "iPad5,2": model = "iPad Mini 4 (LTE)"
        case "iPad5,3": model = "iPad Air 2"
        case "iPad5,4": model = "iPad Air 2"
        case "iPad6,3": model = "iPad Pro (9.7 inch)"
        case "iPad6,4": model = "iPad Pro (9.7 inch)"
        case "iPad6,7": model = "iPad Pro (12.9 inch)"
        case "iPad6,8": model = "iPad Pro (12.9 inch)"
        case "iPad6,11": model = "iPad 5 (WiFi)"
        case "iPad6,12": model = "iPad 5 (Cellular)"
        case "iPad7,1": model = "iPad Pro (12.9 inch) (2nd generation) (WiFi)"
        case "iPad7,2": model = "iPad Pro (12.9 inch) (2nd generation) (Cellular)"
        case "iPad7,3": model = "iPad Pro (10.5 inch) (WiFi)"
        case "iPad7,4": model = "iPad Pro (10.5 inch) (Cellular)"
        case "iPad7,5": model = "iPad (6th generation)"
        case "iPad7,6": model = "iPad (6th generation)"
        case "iPad7,11": model = "iPad (7th generation)"
        case "iPad7,12": model = "iPad (7th generation)"
        case "iPad8,1": model = "iPad Pro (11 inch)"
        case "iPad8,2": model = "iPad Pro (11 inch)"
        case "iPad8,3": model = "iPad Pro (11 inch)"
        case "iPad8,4": model = "iPad Pro (11 inch)"
        case "iPad8,5": model = "iPad Pro (12.9 inch) (3rd generation)"
        case "iPad8,6": model = "iPad Pro (12.9 inch) (3rd generation)"
        case "iPad8,7": model = "iPad Pro (12.9 inch) (3rd generation)"
        case "iPad8,8": model = "iPad Pro (12.9 inch) (3rd generation)"
        case "iPad8,9": model = "iPad Pro (11 inch) (2nd generation)"
        case "iPad8,10": model = "iPad Pro (11 inch) (2nd generation)"
        case "iPad8,11": model = "iPad Pro (12.9 inch) (4th generation)"
        case "iPad8,12": model = "iPad Pro (12.9 inch) (4th generation)"
        case "iPad11,1", "iPad11,2": model = "iPad Mini (5th generation)"
        case "iPad11,3", "iPad11,4": model = "iPad Air (3rd generation)"
        case "iPad11,6", "iPad11,7": model = "iPad (8th generation)"
        case "iPad12,1", "iPad12,2": model = "iPad (9th generation)"
        case "iPad13,18", "iPad13,19": model = "iPad (10th generation)"
        case "iPad13,1": model = "iPad Air (4th generation)"
        case "iPad13,2": model = "iPad Air (4th generation)"
        case "iPad13,4": model = "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,5": model = "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,6": model = "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,7": model = "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,8": model = "iPad Pro (12.9-inch) (5th generation)"
        case "iPad13,9": model = "iPad Pro (12.9-inch) (5th generation)"
        case "iPad13,10": model = "iPad Pro (12.9-inch) (5th generation)"
        case "iPad13,11": model = "iPad Pro (12.9-inch) (5th generation)"
        case "iPad13,16", "iPad13,17": model = "iPad Air (5th generation)"
        case "iPad14,1", "iPad14,2": model = "iPad Mini (6th generation)"
        default: break
        }
        MNDeviceModel = model
        return model
    }
    
    /// 旋转设备到指定用户界面
    /// - Parameters:
    ///   - orientation: 用户界面方向
    ///   - force: 即使当前用户界面符合, 是否继续
    public func rotationTo(orientation: UIInterfaceOrientation, force: Bool = false) {
        guard let deviceOrientation = UIDeviceOrientation(rawValue: orientation.rawValue) else { return }
        rotationTo(orientation: deviceOrientation, force: force)
    }
    
    /// 旋转设备到指定用户界面
    /// - Parameters:
    ///   - orientation: 设备方向
    ///   - force: 即使当前用户界面符合, 是否继续
    public func rotationTo(orientation: UIDeviceOrientation, force: Bool = false) {
        if force == false, base.orientation == orientation { return }
        base.setValue(orientation.rawValue, forKey: #keyPath(UIDevice.orientation))
        UIViewController.attemptRotationToDeviceOrientation()
    }
}
