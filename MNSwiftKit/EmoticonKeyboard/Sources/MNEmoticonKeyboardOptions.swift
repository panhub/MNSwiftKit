//
//  MNEmoticonKeyboardOptions.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情键盘配置选项

import UIKit
import Foundation

/// 表情键盘配置选项
public class MNEmoticonKeyboardOptions {
    /// 键盘高度
    public var preferredHeight: CGFloat = 0.0
    /// 布局方向
    public var axis: NSLayoutConstraint.Axis = .vertical
    /// returnKey类型
    public var returnKeyType: UIReturnKeyType = .default
    /// 表情包
    public var packets: [MNEmoticonPacket.Name] = [.default, .favorites]
    /// 表情包相邻间隔
    public var packetInteritemSpacing: CGFloat = 6.0
    /// 表情包大小约束
    public var packetContentInset: UIEdgeInsets = UIEdgeInsets(top: 6.0, left: 10.0, bottom: 6.0, right: 10.0)
    /// returnKey颜色
    public var returnKeyColor: UIColor! = .white
    /// returnKey标题颜色
    public var returnKeyTitleColor: UIColor! = .black
    /// returnKey标题字体
    public var returnKeyTitleFont: UIFont = .systemFont(ofSize: 17.0, weight: .medium)
    /// 表情包导航栏背景颜色
    public var tintColor: UIColor! = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    /// 表情包选择背景颜色
    public var highlightedColor: UIColor! = .white
    /// 附属视图
    public var accessoryView: UIView?
    /// 分割线颜色
    public var separatorColor: UIColor! = .darkGray.withAlphaComponent(0.15)
    /// 背景颜色
    public var backgroundColor: UIColor! = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 1.0)
    /// 页码指示器高度
    public var pageControlHeight: CGFloat = 20.0
    /// 表情包导航栏高度
    public var packetViewHeight: CGFloat = 48.0
    /// 页码指示器颜色
    public var pageIndicatorColor: UIColor! = .gray.withAlphaComponent(0.37)
    /// 页码指示器选中颜色
    public var currentPageIndicatorColor: UIColor! = .gray.withAlphaComponent(0.9)
    /// 是否允许播放音效
    public var enableFeedbackWhenInputClicks: Bool = false
    /// 只有一个表情包时 是否隐藏表情包栏 (由于横向布局发送键在表情包栏, 所以只对纵向布局有效)
    public var hidesForSinglePacket: Bool = true
    
    public init() {
        preferredHeight = preferredRect.height
    }
}
