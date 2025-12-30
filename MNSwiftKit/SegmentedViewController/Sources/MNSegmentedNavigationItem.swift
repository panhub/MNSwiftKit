//
//  MNSegmentedNavigationItem.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit
import Foundation
import CoreFoundation

/// 分段导航视图中Item模型
public class MNSegmentedNavigationItem: NSObject {
    
    /// 位置
    public var frame: CGRect = .zero
    /// 标记线位置
    public var indicatorFrame: CGRect = .zero
    /// 是否处于选中状态
    public var isSelected: Bool = false
    
    /// 标题
    public var title: String = ""
    /// 标题颜色
    public var titleColor: UIColor?
    /// 标题尺寸
    public var titleSize: CGSize = .zero
    /// 字体
    public var titleFont: UIFont = .systemFont(ofSize: 17.0, weight: .medium)
    /// 标题缩放因数
    public var titleScale: CGFloat = 1.0
    
    /// 边框颜色
    public var borderColor: UIColor?
    /// 背景颜色
    public var backgroundColor: UIColor?
    /// 背景图片
    public var backgroundImage: UIImage?
    
    /// 分割线颜色
    public var dividerColor: UIColor?
    /// 分割线尺寸约束
    public var dividerConstraint: MNSegmentedConfiguration.Constraint = .zero
    
    /// 边框宽度
    public var borderWidth: CGFloat = 0.0
    /// 边框圆角
    public var borderRadius: CGFloat = 0.0
    
    /// 角标
    public var badge: Any?
    /// 角标偏移
    public var badgeOffset: UIOffset = .zero
    /// 角标字体颜色
    public var badgeTextColor: UIColor = .white
    /// 角标内边距
    public var badgeInset: UIEdgeInsets = .zero
    /// 角标背景图片
    public var badgeImage: UIImage?
    /// 角标字体
    public var badgeFont: UIFont = .systemFont(ofSize: 11.0, weight: .medium)
    /// 角标背景颜色
    public var badgeColor: UIColor?
}

