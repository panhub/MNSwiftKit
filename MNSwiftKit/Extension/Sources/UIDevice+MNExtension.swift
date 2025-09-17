//
//  UIDevice+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/3/30.
//  设备管理

import UIKit
import Foundation
import ObjectiveC.runtime

extension UIDevice {
    
    fileprivate struct MNAssociated {
        
        nonisolated(unsafe) static var model = "com.mn.device.model"
        
        nonisolated(unsafe) static var jailbroken = "com.mn.device.jailbroken"
    }
}

extension NameSpaceWrapper where Base: UIDevice {
    
    /// 系统版本号 Double
    public var version: Double {
        NSDecimalNumber(string: base.systemVersion).doubleValue
    }
    
    /// 是否是越狱设备
    public var isJailbroken: Bool {
        if let value = objc_getAssociatedObject(base, &UIDevice.MNAssociated.jailbroken) {
            return value as? Bool ?? false
        } else {
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
            objc_setAssociatedObject(base, &UIDevice.MNAssociated.jailbroken, isJailbrokenDevice, .OBJC_ASSOCIATION_ASSIGN)
            return isJailbrokenDevice
        }
    }
    
    /// 设备型号
    /// https://www.theiphonewiki.com/wiki/Models
    public var model: String {
        if let value = objc_getAssociatedObject(base, &UIDevice.MNAssociated.model) {
            return value as? String ?? "unknown"
        } else {
            var systemInfo: utsname = utsname()
            uname(&systemInfo)
            let mirror = Mirror(reflecting: systemInfo.machine)
            let identifier = mirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            var string = identifier
            switch identifier {
            case "i386", "x86_64": string = "Simulator"
            case "iPhone1,1": string = "iPhone"
            case "iPhone1,2": string = "iPhone 3G"
            case "iPhone2,1": string = "iPhone 3GS"
            case "iPhone3,1": string = "iPhone 4"
            case "iPhone3,2": string = "iPhone 4"
            case "iPhone3,3": string = "iPhone 4"
            case "iPhone4,1": string = "iPhone 4S"
            case "iPhone5,1": string = "iPhone 5"
            case "iPhone5,2": string = "iPhone 5 (GSM+CDMA)"
            case "iPhone5,3": string = "iPhone 5C (GSM)"
            case "iPhone5,4": string = "iPhone 5C (GSM+CDMA)"
            case "iPhone6,1": string = "iPhone 5S (GSM)"
            case "iPhone6,2": string = "iPhone 5S (GSM+CDMA)"
            case "iPhone7,1": string = "iPhone 6 Plus"
            case "iPhone7,2": string = "iPhone 6"
            case "iPhone8,1": string = "iPhone 6S"
            case "iPhone8,2": string = "iPhone 6S Plus"
            case "iPhone8,4": string = "iPhone SE"
            case "iPhone9,1": string = "iPhone 7"
            case "iPhone9,2": string = "iPhone 7 Plus"
            case "iPhone9,3": string = "iPhone 7"
            case "iPhone9,4": string = "iPhone 7 Plus"
            case "iPhone10,1": string = "iPhone 8"
            case "iPhone10,2": string = "iPhone 8 Plus"
            case "iPhone10,3": string = "iPhone X"
            case "iPhone10,4": string = "iPhone 8"
            case "iPhone10,5": string = "iPhone 8 Plus"
            case "iPhone10,6": string = "iPhone X"
            case "iPhone11,2": string = "iPhone XS"
            case "iPhone11,4": string = "iPhone XS Max"
            case "iPhone11,6": string = "iPhone XS Max"
            case "iPhone11,8": string = "iPhone XR"
            case "iPhone12,1": string = "iPhone 11"
            case "iPhone12,3": string = "iPhone 11 Pro"
            case "iPhone12,5": string = "iPhone 11 Pro Max"
            case "iPhone12,8": string = "iPhone SE (2nd generation)"
            case "iPhone13,1": string = "iPhone 12 Mini"
            case "iPhone13,2": string = "iPhone 12"
            case "iPhone13,3": string = "iPhone 12 Pro"
            case "iPhone13,4": string = "iPhone 12 Pro Max"
            case "iPhone14,2": string = "iPhone 13 Pro"
            case "iPhone14,3": string = "iPhone 13 Pro Max"
            case "iPhone14,4": string = "iPhone 13 Mini"
            case "iPhone14,5": string = "iPhone 13"
            case "iPhone14,6": string = "iPhone SE (3rd generation)"
            case "iPhone14,7": string = "iPhone 14"
            case "iPhone14,8": string = "iPhone 14 Plus"
            case "iPhone15,2": string = "iPhone 14 Pro"
            case "iPhone15,3": string = "iPhone 14 Pro Max"
            case "iPad1,1": string = "iPad"
            case "iPad1,2": string = "iPad 3G"
            case "iPad2,1": string = "iPad 2 (WiFi)"
            case "iPad2,2": string = "iPad 2"
            case "iPad2,3": string = "iPad 2 (CDMA)"
            case "iPad2,4": string = "iPad 2"
            case "iPad2,5": string = "iPad Mini (WiFi)"
            case "iPad2,6": string = "iPad Mini"
            case "iPad2,7": string = "iPad Mini (GSM+CDMA)"
            case "iPad3,1": string = "iPad 3 (WiFi)"
            case "iPad3,2": string = "iPad 3 (GSM+CDMA)"
            case "iPad3,3": string = "iPad 3"
            case "iPad3,4": string = "iPad 4 (WiFi)"
            case "iPad3,5": string = "iPad 4"
            case "iPad3,6": string = "iPad 4 (GSM+CDMA)"
            case "iPad4,1": string = "iPad Air (WiFi)"
            case "iPad4,2": string = "iPad Air (Cellular)"
            case "iPad4,4": string = "iPad Mini 2 (WiFi)"
            case "iPad4,5": string = "iPad Mini 2 (Cellular)"
            case "iPad4,6": string = "iPad Mini 2"
            case "iPad4,7": string = "iPad Mini 3"
            case "iPad4,8": string = "iPad Mini 3"
            case "iPad4,9": string = "iPad Mini 3"
            case "iPad5,1": string = "iPad Mini 4 (WiFi)"
            case "iPad5,2": string = "iPad Mini 4 (LTE)"
            case "iPad5,3": string = "iPad Air 2"
            case "iPad5,4": string = "iPad Air 2"
            case "iPad6,3": string = "iPad Pro (9.7 inch)"
            case "iPad6,4": string = "iPad Pro (9.7 inch)"
            case "iPad6,7": string = "iPad Pro (12.9 inch)"
            case "iPad6,8": string = "iPad Pro (12.9 inch)"
            case "iPad6,11": string = "iPad 5 (WiFi)"
            case "iPad6,12": string = "iPad 5 (Cellular)"
            case "iPad7,1": string = "iPad Pro (12.9 inch) (2nd generation) (WiFi)"
            case "iPad7,2": string = "iPad Pro (12.9 inch) (2nd generation) (Cellular)"
            case "iPad7,3": string = "iPad Pro (10.5 inch) (WiFi)"
            case "iPad7,4": string = "iPad Pro (10.5 inch) (Cellular)"
            case "iPad7,5": string = "iPad (6th generation)"
            case "iPad7,6": string = "iPad (6th generation)"
            case "iPad7,11": string = "iPad (7th generation)"
            case "iPad7,12": string = "iPad (7th generation)"
            case "iPad8,1": string = "iPad Pro (11 inch)"
            case "iPad8,2": string = "iPad Pro (11 inch)"
            case "iPad8,3": string = "iPad Pro (11 inch)"
            case "iPad8,4": string = "iPad Pro (11 inch)"
            case "iPad8,5": string = "iPad Pro (12.9 inch) (3rd generation)"
            case "iPad8,6": string = "iPad Pro (12.9 inch) (3rd generation)"
            case "iPad8,7": string = "iPad Pro (12.9 inch) (3rd generation)"
            case "iPad8,8": string = "iPad Pro (12.9 inch) (3rd generation)"
            case "iPad8,9": string = "iPad Pro (11 inch) (2nd generation)"
            case "iPad8,10": string = "iPad Pro (11 inch) (2nd generation)"
            case "iPad8,11": string = "iPad Pro (12.9 inch) (4th generation)"
            case "iPad8,12": string = "iPad Pro (12.9 inch) (4th generation)"
            case "iPad11,1": string = "iPad Mini (5th generation)"
            case "iPad11,2": string = "iPad Mini (5th generation)"
            case "iPad11,3": string = "iPad Air (3rd generation)"
            case "iPad11,4": string = "iPad Air (3rd generation)"
            case "iPad11,6": string = "iPad (8th generation)"
            case "iPad11,7": string = "iPad (8th generation)"
            case "iPad12,1": string = "iPad (9th generation)"
            case "iPad12,2": string = "iPad (9th generation)"
            case "iPad13,1": string = "iPad Air (4th generation)"
            case "iPad13,2": string = "iPad Air (4th generation)"
            case "iPad13,4": string = "iPad Pro (11-inch) (3rd generation)"
            case "iPad13,5": string = "iPad Pro (11-inch) (3rd generation)"
            case "iPad13,6": string = "iPad Pro (11-inch) (3rd generation)"
            case "iPad13,7": string = "iPad Pro (11-inch) (3rd generation)"
            case "iPad13,8": string = "iPad Pro (12.9-inch) (5th generation)"
            case "iPad13,9": string = "iPad Pro (12.9-inch) (5th generation)"
            case "iPad13,10": string = "iPad Pro (12.9-inch) (5th generation)"
            case "iPad13,11": string = "iPad Pro (12.9-inch) (5th generation)"
            case "iPad13,16": string = "iPad Air (5th generation)"
            case "iPad13,17": string = "iPad Air (5th generation)"
            case "iPad14,1": string = "iPad Mini (6th generation)"
            case "iPad14,2": string = "iPad Mini (6th generation)"
            default: break
            }
            objc_setAssociatedObject(base, &UIDevice.MNAssociated.model, string, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return string
        }
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
