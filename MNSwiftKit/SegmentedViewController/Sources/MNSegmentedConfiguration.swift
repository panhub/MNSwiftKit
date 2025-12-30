//
//  MNSegmentedConfiguration.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit
import Foundation
import CoreFoundation

/// 分段视图控制器配置信息
public struct MNSegmentedConfiguration {
    
    /// 背景颜色
    public var backgroundColor: UIColor = .white
    
    /// 滑动方向
    public var orientation = UIPageViewController.NavigationOrientation.horizontal
    
    /// 导航item配置
    public var item: MNSegmentedConfiguration.Item = .init()
    
    /// 角标配置
    public var badge: MNSegmentedConfiguration.Badge = .init()
    
    /// 指示器配置
    public var indicator: MNSegmentedConfiguration.Indicator = .init()
    
    /// 分割线配置
    public var separator: MNSegmentedConfiguration.Separator = .init()
    
    /// 分段导航配置
    public var navigation: MNSegmentedConfiguration.Navigation = .init()
    
    
    /// 构造分段视图控制器配置入口
    public init() {}
}

extension MNSegmentedConfiguration {
    
    /// 分段导航配置
    public struct Navigation {
        
        /// 分段视图布局行为
        public enum AdjustmentBehavior {
            /// 自然布局，不做其它操作
            case standard
            /// 居中
            case centered
            /// 充满
            case expanded
        }

        /// 分段视图滑动位置
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
        
        /// 尺寸
        /// - 横向：分段视图高度
        /// - 纵向：分段视图宽度
        public var dimension: CGFloat = 40.0
        
        /// 内部四周约束 会依据`contentMode`调整
        public var contentInset: UIEdgeInsets = .zero
        
        /// 分割线颜色
        public var backgroundColor: UIColor = .gray.withAlphaComponent(0.15)
        
        /// 滑动位置
        public var scrollPosition: MNSegmentedConfiguration.Navigation.ScrollPosition = .unspecified
        
        /// item不足时的布局调整行为
        public var adjustmentBehavior: MNSegmentedConfiguration.Navigation.AdjustmentBehavior = .standard
    }
}

extension MNSegmentedConfiguration {
    
    /// 分段控制器指示器配置
    public struct Indicator {
        
        /// 指示视图尺寸
        public enum Constraint {
            /// 与标题同宽
            case matchTitle(dimension: CGFloat)
            /// 与item同宽
            case matchItem(dimension: CGFloat)
            /// 使用固定值
            case fixed(width: CGFloat, height: CGFloat)
        }

        /// 指示视图对齐方式
        public enum Alignment {
            /// 头部对齐
            case leading
            /// 中心对齐
            case center
            /// 尾部对齐
            case trailing
        }

        /// 指示视图动画类型
        public enum Animation {
            /// 平滑移动
            case move
            /// 拉伸
            case stretch
        }

        /// 指示视图放置位置
        public enum Position {
            /// 指示器在 item 之上（覆盖 / 前景）
            case above
            /// 指示器在 item 之下（背景 / 底层）
            case below
        }
        
        /// 图片
        public var image: UIImage?
        
        /// 偏移量(横向参照`alignment`情况, 纵向参照底部)
        public var offset: UIOffset = .zero
        
        /// 圆角大小
        public var cornerRadius: CGFloat = 0.0
        
        /// 颜色
        public var backgroundColor: UIColor = .black
        
        /// 动画时长
        public var animationDuration: TimeInterval = 0.25
        
        /// 内容填充模式
        public var contentMode: UIView.ContentMode = .scaleToFill
        
        /// 指示视图在item上层还是下层
        public var position: MNSegmentedConfiguration.Indicator.Position = .above
        
        /// 转场类型
        public var animation: MNSegmentedConfiguration.Indicator.Animation = .move
        
        /// 指示器尺寸固定时的对齐方式
        public var alignment: MNSegmentedConfiguration.Indicator.Alignment = .center
        
        /// 指示器约束
        public var constraint: MNSegmentedConfiguration.Indicator.Constraint = .matchTitle(dimension: 2.5)
    }
}

extension MNSegmentedConfiguration {
    
    /// 分段控制器角标配置
    public struct Badge {
        
        /// 偏移量 (角标中心点相对于右上角的偏移)
        public var offset: UIOffset = .zero
        
        /// 内容约束
        public var contentInset: UIEdgeInsets = .zero
        
        /// 字体颜色
        public var textColor: UIColor = .white
        
        /// 字体
        public var textFont: UIFont = .systemFont(ofSize: 11.0, weight: .medium)
        
        /// 背景图片
        public var backgroundImage: UIImage?
        
        /// 背景颜色
        public var backgroundColor: UIColor? = UIColor(red: 255.0/255.0, green: 58.0/255.0, blue: 58.0/255.0, alpha: 1.0)
    }
}

extension MNSegmentedConfiguration {
    
    /// 分段导航视图Item配置
    public struct Item {

        /// 外观配置
        public struct Appearance {
            
            /// 标题颜色
            public var titleColor: UIColor = .gray
            
            /// 标题的缩放因数, 不能小于1.0, 选中状态下有效
            public var titleScale: CGFloat = 1.0
            
            /// 边框颜色
            public var borderColor: UIColor?
            
            /// 背景图片
            public var backgroundImage: UIImage?
            
            /// 背景颜色
            public var backgroundColor: UIColor = .white
        }
        
        /// 尺寸
        /// - 横向：分段视图item在标题宽度追加的宽度
        /// - 纵向：分段视图item高度
        public var dimension: CGFloat = 40.0
        
        /// 相邻两个Item的间隔
        public var spacing: CGFloat = 0.0
        
        /// 边框宽度
        public var borderWidth: CGFloat = 0.0
        
        /// 圆角大小
        public var cornerRadius: CGFloat = 0.0
        
        /// 标题字体
        public var titleFont: UIFont = .systemFont(ofSize: 17.0, weight: .medium)
        
        /// 分割线颜色
        public var dividerColor: UIColor?
        
        /// 分割线约束
        public var dividerConstraint: MNSegmentedConfiguration.Constraint = .zero
        
        /// 正常外观配置
        public var normal = MNSegmentedConfiguration.Item.Appearance()
        
        /// 选中时外观配置
        public var selected = MNSegmentedConfiguration.Item.Appearance(titleColor: .darkText)
    }
}

extension MNSegmentedConfiguration {
    
    /// 分段控制器分割线配置
    public struct Separator {
        
        /// 分割线样式选项
        public struct Style: OptionSet {
            
            /// 显示前/左一条
            public static let leading = MNSegmentedConfiguration.Separator.Style(rawValue: 1 << 0)
            /// 显示后/右一条
            public static let trailing = MNSegmentedConfiguration.Separator.Style(rawValue: 1 << 1)
            /// 全部显示
            public static let all: MNSegmentedConfiguration.Separator.Style = [.leading, .trailing]
            /// 不显示
            public static let none: MNSegmentedConfiguration.Separator.Style = []
            
            public let rawValue: UInt
            
            public init(rawValue: UInt) {
                
                self.rawValue = rawValue
            }
        }
        
        
        /// 分割线颜色
        public var backgroundColor: UIColor = .white
        
        /// 分割线样式
        public var style: MNSegmentedConfiguration.Separator.Style = .trailing
        
        /// 分割线约束
        public var constraint: MNSegmentedConfiguration.Constraint = .zero
    }
}

extension MNSegmentedConfiguration {
    
    /// 约束
    public struct Constraint: Equatable {
        
        /// 上/左间隔
        public let leading: CGFloat
        /// 下/右间隔
        public let trailing: CGFloat
        /// 尺寸
        /// - 横向：分割线宽度
        /// - 纵向：分割线高度
        public let dimension: CGFloat
        
        /// 不显示分割线
        public static var zero = MNSegmentedConfiguration.Constraint(leading: 0.0, trailing: 0.0, dimension: 0.0)
        
        
        /// 构造分割线尺寸
        /// - Parameters:
        ///   - leading: 上/左间隔
        ///   - trailing: 下/右间隔
        ///   - dimension: 分割线宽度/高度
        public init(leading: CGFloat, trailing: CGFloat, dimension: CGFloat) {
            self.leading = leading
            self.trailing = trailing
            self.dimension = dimension
        }
        
        /// 构造分割线尺寸
        /// - Parameters:
        ///   - inset: 两侧间隔
        ///   - dimension: 分割线宽度/高度
        public init(inset: CGFloat, dimension: CGFloat) {
            self.leading = inset
            self.trailing = inset
            self.dimension = dimension
        }
        
        public static func == (lhs: MNSegmentedConfiguration.Constraint, rhs: MNSegmentedConfiguration.Constraint) -> Bool {
            
            return lhs.leading == rhs.leading && lhs.trailing == rhs.trailing && lhs.dimension == rhs.dimension
        }
    }
}
