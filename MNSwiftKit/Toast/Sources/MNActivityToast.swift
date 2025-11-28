//
//  MNActivityToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  Activity弹窗

import UIKit

/// Activity弹窗构建者
class MNActivityToast {
    
    /// 弹窗视图
    lazy var activityView: UIActivityIndicatorView = {
        var style: UIActivityIndicatorView.Style!
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .whiteLarge
        }
        let activityView = UIActivityIndicatorView(style: style)
        activityView.hidesWhenStopped = false
        activityView.color = MNToast.Configuration.shared.color
        return activityView
    }()
}

extension MNActivityToast: MNToastBuilder {
    
    var axisForToast: MNToast.Axis {
        
        MNToast.Configuration.shared.axis
    }
    
    var effectForToast: MNToast.Effect {
        
        MNToast.Configuration.shared.effect
    }
    
    var contentInsetForToast: UIEdgeInsets {
        
        MNToast.Configuration.shared.contentInset
    }
    
    var activityViewForToast: UIView? {
        
        activityView
    }
    
    var attributesForToastStatus: [NSAttributedString.Key : Any] {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:MNToast.Configuration.shared.font, .foregroundColor:MNToast.Configuration.shared.color, .paragraphStyle:paragraph]
    }
    
    var fadeInForToast: Bool {
        
        true
    }
    
    var fadeOutForToast: Bool {
        
        true
    }
    
    var allowUserInteraction: Bool {
        
        false
    }
}

extension MNActivityToast: MNToastAnimationHandler {
    
    func startAnimating() {
        
        if activityView.isAnimating { return }
        
        activityView.startAnimating()
    }
    
    func stopAnimating() {
        
        activityView.stopAnimating()
    }
}
