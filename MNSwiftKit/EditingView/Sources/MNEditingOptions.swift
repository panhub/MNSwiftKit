//
//  MNEditingOptions.swift
//  MNTest
//
//  Created by 冯盼 on 2022/8/22.
//  表格编辑配置信息

import UIKit
import CoreFoundation

public class MNEditingOptions: NSObject {
    
    /// 圆角大小
    public var cornerRadius: CGFloat = 0.0
    
    /// 内容四周约束
    /// - left: direction = .right 时有效
    /// - right: direction = .left 时有效
    public var contentInset: UIEdgeInsets = .zero
    
    /// 背景颜色
    public var backgroundColor: UIColor? = .clear
}
