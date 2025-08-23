//
//  MNSpliter.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/29.
//  导航项配置信息

import UIKit
import Foundation
import CoreGraphics

public class MNSpliter: NSObject {
    /// 标题
    public var title: String = ""
    /// 角标
    public var badge: Any? = nil
    /// 位置
    public var frame: CGRect = .zero
    /// 标题尺寸
    public var titleSize: CGSize = .zero
    /// 边框颜色
    public var borderColor: UIColor?
    /// 背景颜色
    public var backgroundColor: UIColor?
    /// 背景图片
    public var backgroundImage: UIImage?
    /// 标题颜色
    public var titleColor: UIColor?
    /// 标记线位置
    public var shadowFrame: CGRect = .zero
    /// transform缩放因数
    public var transformScale: CGFloat = 1.0
    /// 字体
    public var titleFont: UIFont = .systemFont(ofSize: 17.0, weight: .medium)
    /// 分割线颜色
    public var dividerColor: UIColor?
    /// 分割线约束
    public var dividerInset: UIEdgeInsets = .zero
    /// 边框宽度
    public var borderWidth: CGFloat = 0.0
    /// 边框圆角
    public var borderRadius: CGFloat = 0.0
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
    /// 是否处于选中状态
    public var isSelected: Bool = false
}
