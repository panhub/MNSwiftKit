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
        let indicatorView = UIActivityIndicatorView(style: style)
        indicatorView.hidesWhenStopped = false
        indicatorView.color = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        return indicatorView
    }()
}

extension MNActivityToast: MNToastBuilder {
    
    var axisForToast: MNToast.Axis {
        
        .vertical(spacing: 5.0)
    }
    
    var effectForToast: MNToast.Effect {
        
        .dark
    }
    
    var positionForToast: MNToast.Position {
        
        .center
    }
    
    var contentInsetForToast: UIEdgeInsets {
        
        .init(top: 12.0, left: 12.0, bottom: 11.0, right: 12.0)
    }
    
    var activityViewForToast: UIView? {
        
        activityView.color = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        return activityView
    }
    
    var attributesForToastStatus: [NSAttributedString.Key : Any] {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:UIFont.systemFont(ofSize: 15.0, weight: .regular), .paragraphStyle:paragraph, .foregroundColor:UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)]
    }
    
    var fadeInForToast: Bool {
        
        true
    }
    
    var fadeOutForToast: Bool {
        
        true
    }
    
    var allowUserInteractionWhenDisplayed: Bool {
        
        true
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
