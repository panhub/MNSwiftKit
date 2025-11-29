//
//  MNActivityToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  Activity弹窗

import UIKit

/// 活动Toast构建者
public class MNActivityToast {
    
    /// 活动视图样式
    public enum Style {
        /// 大号
        case large
        /// 中号
        case medium
    }
    
    /// 活动Toast样式
    public let style: MNActivityToast.Style
    
    /// 构造活动Toast
    /// - Parameter style: 样式
    public init(style: MNActivityToast.Style) {
        self.style = style
    }
    
    /// 活动视图
    lazy var activityView: UIActivityIndicatorView = {
        var activityStyle: UIActivityIndicatorView.Style!
        switch style {
        case .large:
            if #available(iOS 13.0, *) {
                activityStyle = .large
            } else {
                activityStyle = .whiteLarge
            }
        case .medium:
            if #available(iOS 13.0, *) {
                activityStyle = .medium
            } else {
                activityStyle = .white
            }
        }
        let activityView = UIActivityIndicatorView(style: activityStyle)
        activityView.hidesWhenStopped = false
        activityView.color = MNToast.Configuration.shared.color
        return activityView
    }()
}

extension MNActivityToast: MNToastBuilder {
    
    public var axisForToast: MNToast.Axis {
        
        MNToast.Configuration.shared.axis
    }
    
    public var effectForToast: MNToast.Effect {
        
        MNToast.Configuration.shared.effect
    }
    
    public var contentInsetForToast: UIEdgeInsets {
        
        MNToast.Configuration.shared.contentInset
    }
    
    public var activityViewForToast: UIView? {
        
        activityView
    }
    
    public var attributesForToastStatus: [NSAttributedString.Key : Any] {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:MNToast.Configuration.shared.font, .foregroundColor:MNToast.Configuration.shared.color, .paragraphStyle:paragraph]
    }
    
    public var fadeInForToast: Bool {
        
        true
    }
    
    public var fadeOutForToast: Bool {
        
        true
    }
    
    public var allowUserInteraction: Bool {
        
        false
    }
}

extension MNActivityToast: MNToastAnimationSupported {
    
    public func startAnimating() {
        
        if activityView.isAnimating { return }
        
        activityView.startAnimating()
    }
    
    public func stopAnimating() {
        
        activityView.stopAnimating()
    }
}
