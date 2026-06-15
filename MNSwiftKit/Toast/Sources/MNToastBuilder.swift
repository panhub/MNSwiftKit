//
//  MNToastBuilder.swift
//  MNSwiftKit
//
//  Created by panhub on 2026/6/2.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

/// Toast构建规则
public protocol MNToastBuilder {
    
    /// Toast布局方向
    var axisForToast: MNToast.Axis { get }
    
    /// Toast视觉效果
    var effectForToast: MNToast.Effect { get }
    
    /// Toast圆角大小
    var cornerRadiusForToast: CGFloat { get }
    
    /// Toast内容四周约束
    var contentInsetForToast: UIEdgeInsets { get }
    
    /// Toast指示视图
    var activityViewForToast: UIView? { get }
    
    /// Toast中状态文字的富文本描述
    var attributesForToastStatus: [NSAttributedString.Key:Any] { get }
    
    /// Toast渐入式显示
    var fadeInForToast: Bool { get }
    
    /// Toast渐隐式取消
    var fadeOutForToast: Bool { get }
    
    /// Toast显示时是否允许交互
    var allowUserInteraction: Bool { get }
}

/// 弹框取消按钮支持
public protocol MNToastCancelSupported {
    
    /// Toast关闭按钮图片
    var closeImageResourceForToast: UIImage! { get }
}

/// 弹框动画规则
public protocol MNToastAnimationSupported {
    
    /// 开启动画
    func startAnimating()
    
    /// 停止动画
    func stopAnimating()
}

/// 弹框进度更新规则
public protocol MNToastProgressSupported {
    
    /// Toast需要更新进度
    /// - Parameter value: 进度值
    func toastShouldUpdateProgress(_ value: CGFloat)
}

/// 弹框自动关闭支持
public protocol MNToastCloseSupported {
    
    /// Toast想要定时自动关闭
    /// - Parameter status: 状态文字
    /// - Returns: 显示时长(nil则不做自动关闭操作)
    func toastShouldClose(with status: String?) -> TimeInterval
}
