//
//  MNSegmentedConfiguration.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit
import Foundation
import CoreFoundation

/// 分段视图配置
public struct MNSegmentedViewConfiguration {
    
    /// 布局调整行为
    public enum AdjustmentBehavior {
        /// 自然布局，不做其它操作
        case standard
        /// 居中
        case centered
        /// 充满
        case expanded
    }
    
    /// 滑动位置
    public enum ScrollPosition {
        /// 不做操作
        case unspecified
        /// 停留头部
        case leading
        /// 停留中心
        case center
        /// 停留尾部
        case trailing
    }
    
    /// 分割线显示选项
    public struct SeparatorStyle: OptionSet {
        /// 显示前/左一条
        public static let leading = SeparatorStyle(rawValue: 1 << 0)
        /// 显示后/右一条
        public static let trailing = SeparatorStyle(rawValue: 1 << 1)
        /// 全部显示
        public static let all: SeparatorStyle = [.leading, .trailing]
        /// 不显示
        public static let none: SeparatorStyle = []
        
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    /// 尺寸
    /// - 横向：表示高度
    /// - 纵向：表示宽度
    public var dimension: CGFloat = 35.0
    
    /// item不足时的布局调整行为
    public var layoutAdjustmentBehavior: AdjustmentBehavior = .standard
    
    /// 分割线样式
    public var separatorStyle: SeparatorStyle = .none
    
    /// 分割线颜色
    public var separatorColor: UIColor = .gray.withAlphaComponent(0.15)
    
    /// 导航分割线约束
    public var separatorInset: UIEdgeInsets = .zero
    
    /// 选中位置
    public var scrollPosition: ScrollPosition = .unspecified
    
    /// 内部四周约束 会依据`contentMode`调整
    public var contentInset: UIEdgeInsets = .zero
    
    /// 背景颜色
    public var backgroundColor: UIColor = .clear
}

/// 分割视图Item配置
public struct MNSegmentedItemConfiguration {
    
    /// 外观配置
    public struct Appearance {
        
        /// 标题字体
        public var titleFont: UIFont = .systemFont(ofSize: 17.0, weight: .medium)
        
        /// 标题颜色
        public var titleColor: UIColor = .gray
        
        /// 标题的缩放因数, 不能小于1.0, 选中状态下有效
        public var titleScale: CGFloat = 1.0
        
        /// 边框宽度
        public var borderWidth: CGFloat = 0.0
        
        /// 边框颜色
        public var borderColor: UIColor?
        
        /// 圆角大小
        public var cornerRadius: CGFloat = 0.0
        
        /// 分割线颜色
        public var dividerColor: UIColor?
        
        /// 分割线尺寸
        public var dividerSize: CGSize = .zero
        
        /// 背景图片
        public var backgroundImage: UIImage?
        
        /// 背景颜色
        public var backgroundColor: UIColor = .white
    }
    
    /// 尺寸
    /// - 横向：追加的宽度
    /// - 纵向：分割项高度
    public var dimension: CGFloat = 36.0
    
    /// 相邻两个Item的间隔
    public var spacing: CGFloat = 0.0
    
    /// 转场动画时长
    public var transitionDuration: TimeInterval = 0.3
    
    /// 正常外观配置
    public var normal = Appearance()
    
    /// 选中时外观配置
    public var selected = Appearance(titleColor: .darkText)
}

/// 角标配置
public struct MNSegmentedBadgeConfiguration {
    
    /// 字体
    public var textFont: UIFont = .systemFont(ofSize: 11.0, weight: .medium)
    
    /// 字体颜色
    public var textColor: UIColor = .white
    
    /// 内容约束
    public var contentInset: UIEdgeInsets = .zero
    
    /// 背景图片
    public var backgroundImage: UIImage?
    
    /// 背景颜色
    public var backgroundColor: UIColor? = UIColor(red: 255.0/255.0, green: 58.0/255.0, blue: 58.0/255.0, alpha: 1.0)
    
    /// 偏移量 (角标中心点相对于右上角的偏移)
    public var offset: UIOffset = .zero
}

/// 指示器配置
public struct MNSegmentedIndicatorConfiguration {
    
    /// 尺寸模式
    public enum Size {
        /// 与标题同宽
        case matchTitle(dimension: CGFloat)
        /// 与item同宽
        case matchItem(dimension: CGFloat)
        /// 使用固定值
        case fixed(width: CGFloat, height: CGFloat)
    }
    
    /// 对齐方式
    public enum Alignment {
        /// 头部对齐
        case leading
        /// 中心对齐
        case center
        /// 尾部对齐
        case trailing
    }
    
    /// 移动样式
    public enum TransitionType {
        /// 平滑移动
        case move
        /// 拉伸
        case stretch
    }
    
    /// 放置位置
    public enum Position {
        /// 指示器在 item 之上（覆盖 / 前景）
        case above
        /// 指示器在 item 之下（背景 / 底层）
        case below
    }
    
    /// 指示器尺寸
    public var size: Size = .fixed(width: 15.0, height: 3.0)
    
    /// 指示器尺寸固定时的对齐方式
    public var alignment: Alignment = .center
    
    /// 指示视图在item上层还是下层
    public var position: Position = .above
    
    /// 转场类型
    public var transitionType: TransitionType = .move
    
    /// 内容填充模式
    public var contentMode: UIView.ContentMode = .scaleToFill
    
    /// 图片
    public var image: UIImage?
    
    /// 颜色
    public var backgroundColor: UIColor = .black
    
    /// 偏移量(横向参照`alignment`情况, 纵向参照底部)
    public var offset: UIOffset = .zero
    
    /// 圆角大小
    public var cornerRadius: CGFloat = 0.0
    
    /// 动画时长
    public var animationDuration: TimeInterval = 0.2
}

public struct MNSegmentedConfiguration {
    
    /// 分段视图配置
    public var view: MNSegmentedViewConfiguration = .init()
    
    /// 分段视图中每个item的配置
    public var item: MNSegmentedItemConfiguration = .init()
    
    /// 角标配置
    public var badge: MNSegmentedBadgeConfiguration = .init()
    
    /// 指示器配置
    public var indicator: MNSegmentedIndicatorConfiguration = .init()
    
    /// 滑动方向
    public var orientation = UIPageViewController.NavigationOrientation.horizontal
}
