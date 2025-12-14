//
//  MNEditingOptions.swift
//  MNTest
//
//  Created by 冯盼 on 2022/8/22.
//  表格编辑配置信息

import UIKit
import CoreFoundation

public class MNEditingOptions: NSObject {
    
    /// 圆角
    @objc public var cornerRadius: CGFloat = 0.0
    
    /// 内容偏移
    /// left: 'direction = right'时有效, right: 'direction = left'时有效
    @objc public var contentInset: UIEdgeInsets = .zero
    
    /// 背景颜色
    @objc public var backgroundColor: UIColor? = .clear
    
    /// 使用内部按钮响应事件
    @objc public var usingInnerInteraction: Bool = true
}
