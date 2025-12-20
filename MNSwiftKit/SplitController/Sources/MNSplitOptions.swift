//
//  MNSplitOptions.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//  分段视图配置信息

import UIKit
import Foundation

public class MNSplitOptions: NSObject {
    
    /// 补全方案
    public enum ContentMode: Int {
        /// 不做操作
        case normal
        /// 居中
        case fit
        /// 充满
        case fill
    }
    
    /// 标记视图的补充方案
    public enum ShadowMask: Int {
        /// 与标题同宽
        case fit
        /// 与item同宽
        case fill
        /// 使用shadowSize
        case constant
    }
    
    /// 标记视图的对齐方式(相对于标题)
    public enum ShadowAlignment: Int {
        /// 头部对齐
        case head
        /// 中心对齐
        case center
        /// 尾部对齐
        case tail
    }
    
    /// 标记视图的动画类型
    public enum ShadowAnimation: Int {
        /// 正常移动
        case normal
        /// 长度变化
        case adsorb
    }
    
    /// 导航滑动时, 选中位置
    public enum ScrollPosition: Int {
        /// 不做操作
        case none
        /// 停留头部
        case head
        /// 停留中心
        case center
        /// 停留尾部
        case tail
    }
    
    /// 分割线样式
    public enum SeparatorStyle : Int {
        /// 不显示分割线
        case none
        /// 只显示前一条
        case head
        /// 只显示后一条
        case tail
        /// 显示全部分割线
        case all
    }
    
    /**
     switch axis {
     case .horizontal:
         width: 分离器每一项追加的宽度 height: 分离器高度
     default:
         width: 分离器宽度 height: 分离器每一项的高度
     }
    */
    public var spliterSize: CGSize = CGSize(width: 36.0, height: 42.0)
    /// 补全方案
    public var contentMode: ContentMode = .normal
    /// 标记视图的补充方案
    public var shadowMask: ShadowMask = .fit
    /// 标记视图的显示模式
    public var shadowContentMode: UIView.ContentMode = .scaleToFill
    /// 导航区选中项位置
    public var scrollPosition: ScrollPosition = .none
    /// 标记视图对齐方式
    public var shadowAlignment: ShadowAlignment = .center
    /// 标记视图动画类型
    public var shadowAnimation: ShadowAnimation = .normal
    /// 标记视图的大小(配合ShadowMask.constant使用宽度)
    public var shadowSize: CGSize = CGSize(width: 15.0, height: 4.0)
    /// 标记视图的图片
    public var shadowImage: UIImage?
    /// 标记视图的颜色
    public var shadowColor: UIColor = .black
    /// 标记视图的偏移
    public var shadowOffset: UIOffset = .zero
    /// 标记视图的圆角大小
    public var shadowRadius: CGFloat = 0.0
    /// 放置阴影线到背景视图
    public var sendShadowToBack: Bool = false
    /// 标题的颜色
    public var titleColor: UIColor = .gray
    /// 标题字体
    public var titleFont: UIFont = .systemFont(ofSize: 17.0, weight: .medium)
    /// 标题高亮颜色
    public var highlightedTitleColor: UIColor = .black
    /// 导航视图颜色
    public var splitColor: UIColor = .white
    /// 背景颜色
    public var backgroundColor: UIColor = .white
    /// 分割线颜色
    public var separatorColor: UIColor = .gray.withAlphaComponent(0.15)
    /// 导航分割线约束
    public var separatorInset: UIEdgeInsets = .zero
    /// 分离器分割线样式
    public var separatorStyle: SeparatorStyle = .none
    /// 分割项之间分割线颜色
    public var dividerColor: UIColor?
    /// 分割项分割线约束
    public var dividerInset: UIEdgeInsets = .zero
    /// 分割项边框宽度
    public var spliterBorderWidth: CGFloat = 0.0
    /// 分割项边框圆角
    public var spliterBorderRadius: CGFloat = 0.0
    /// 分割项边框颜色
    public var spliterBorderColor: UIColor?
    /// 分割项边框高亮颜色
    public var spliterHighlightedBorderColor: UIColor?
    /// 分割项背景颜色
    public var spliterBackgroundColor: UIColor = .white
    /// 分割项高亮时背景颜色
    public var spliterHighlightedBackgroundColor: UIColor = .white
    /// 分割项背景图片
    public var spliterBackgroundImage: UIImage?
    /// 分割项高亮时背景图片
    public var spliterHighlightedBackgroundImage: UIImage?
    /// 导航左右边距
    /// 内部会依据`contentMode`调整
    public var splitInset: UIEdgeInsets = .zero
    /// 导航标题项间隔
    public var interSpliterSpacing: CGFloat = 0.0
    /// 角标背景图片
    public var badgeImage: UIImage?
    /// 角标字体
    public var badgeFont: UIFont = .systemFont(ofSize: 11.0, weight: .medium)
    /// 角标颜色
    public var badgeColor: UIColor? = UIColor(red: 255.0/255.0, green: 58.0/255.0, blue: 58.0/255.0, alpha: 1.0)
    /// 角标字体颜色
    public var badgeTextColor: UIColor = .white
    /// 角标内边距
    public var badgeInset: UIEdgeInsets = .zero
    /// 角标偏移 (角标中心点相对于右上角的偏移)
    public var badgeOffset: UIOffset = .zero
    /// 标题项选中时transform动画缩放因数
    /// 不能小于1.0
    public var highlightedScale: CGFloat = 1.0
    /// 转场动画时长
    public var transitionDuration: TimeInterval = 0.3
}
