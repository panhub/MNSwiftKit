//
//  AppWebClip.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/5/4.
//  Web标签

import UIKit
import Foundation

/// Web标签
public class MNWebClip {
    
    /// 文件内容
    private var content: String = ""
    
    /// 实例化Web标签入口
    /// - Parameters:
    ///   - name: 桌面显示的应用名称
    ///   - base64String: 图标base64编码后的字符串
    ///   - uuid: 启动标识
    ///   - scheme: 调用标识
    ///   - id: 宿主应用标识
    ///   - flag: 是否允许从桌面删除
    public init(name: String, icon base64String: String, uuid: String, scheme: String, bundle id: String, allowsRemoveFromDestop flag: Bool = true) {
        content.append("<dict>\n")
        content.append("<key>FullScreen</key><true/>\n")
        content.append("<key>IsRemovable</key>\n")
        content.append("<\(flag ? "true" : "false")/>\n")
        content.append("<key>Icon</key><data>\(base64String)</data>\n")
        content.append("<key>Label</key>\n")
        content.append("<string>\(name)</string>\n")
        content.append("<key>PayloadDescription</key>\n")
        content.append("<string>配置 Web Clip 设置</string>\n")
        content.append("<key>PayloadDisplayName</key>\n")
        content.append("<string>Web Clip</string>\n")
        content.append("<key>PayloadIdentifier</key>\n")
        content.append("<string>com.apple.webClip.managed.\(uuid)</string>\n")
        content.append("<key>PayloadType</key>\n")
        content.append("<string>com.apple.webClip.managed</string>\n")
        content.append("<key>PayloadUUID</key>\n")
        content.append("<string>\(uuid)</string>\n")
        content.append("<key>PayloadVersion</key>\n")
        content.append("<real>1</real>\n")
        content.append("<key>Precomposed</key><true/>\n")
        content.append("<key>URL</key>\n<string>\(scheme)</string>\n")
        content.append("<key>TargetApplicationBundleIdentifier</key>\n")
        content.append("<string>\(id)</string>\n")
        content.append("</dict>\n")
    }
    
    /// 写入.mobileconfig文件
    /// - Parameters:
    ///   - path: 文件路径
    ///   - uuid: 文件标识
    ///   - name: Web标签名
    ///   - desc: Web标签描述
    /// - Returns: 是否创建成功
    @discardableResult
    public func write(toFile path: String, uuid: String, display name: String = "WebClip描述文件", desc: String? = nil) -> Bool {
        let desc: String = desc ?? "该文件为快捷启动方式, 不会对原APP本身有任何影响, 安装该文件后, 将在桌面添加此快捷方式。"
        var string: String = "<?xml version='1.0' encoding='UTF-8'?><!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'><plist version='1.0'><dict><key>PayloadContent</key><array>\n"
        string.append("\(content)\n")
        string.append("</array><key>PayloadDescription</key>\n")
        string.append("<string>\(desc)</string>\n")
        string.append("<key>PayloadDisplayName</key>\n")
        string.append("<string>\(name)</string>\n")
        string.append("<key>PayloadIdentifier</key>\n")
        string.append("<string>CoderWGB.\(uuid)</string>\n")
        string.append("<key>PayloadRemovalDisallowed</key><false/>\n")
        string.append("<key>PayloadType</key><string>Configuration</string>\n")
        string.append("<key>PayloadUUID</key>\n")
        string.append("<string>\(uuid)</string>\n")
        string.append("<key>PayloadVersion</key>\n")
        string.append("<integer>1</integer>\n")
        string.append("</dict>\n")
        string.append("</plist>\n")
        guard let data = string.data(using: .utf8) else {
#if DEBUG
            print("转换mobileconfig失败")
#endif
            return false
        }
        var url: URL!
        if #available(iOS 16.0, *) {
            url = URL(filePath: path)
        } else {
            url = URL(fileURLWithPath: path)
        }
        try? FileManager.default.removeItem(at: url)
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        } catch {
#if DEBUG
            print("写入mobileconfig失败:\n\(error)\n")
#endif
            return false
        }
        return FileManager.default.createFile(atPath: path, contents: data)
    }
    
    /// 创建描述文件 ".mobileconfig"
    /// - Parameters:
    ///   - path: 文件路径
    ///   - name: 应用名称
    ///   - icon: 应用图标Base64字符串
    ///   - uuid: 启动标识
    ///   - scheme: 调用标识, 若不填则提示文件损坏
    ///   - id: 应用标识
    ///   - identifier: 配置文件唯一标识
    ///   - title: 配置文件显示标题
    ///   - desc: 配置文件描述信息
    /// - Returns: 是否创建成功
    @discardableResult
    public class func createFile(atPath path: String, name: String, icon base64String: String, uuid: String, scheme: String, bundle id: String, identifier: String, title: String = "WebClip描述文件", desc: String? = nil) -> Bool {
        
        let webClip = MNWebClip(name: name, icon: base64String, uuid: uuid, scheme: scheme, bundle: id)
        
        return webClip.write(toFile: path, uuid: identifier, display: title, desc: desc)
    }
}
