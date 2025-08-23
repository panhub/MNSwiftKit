//
//  MNActivityToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  Indicator弹窗

import UIKit

public class MNActivityToast: NSObject, MNToastBuilder {
    
    public lazy var activityView: UIActivityIndicatorView = {
        var style: UIActivityIndicatorView.Style!
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .whiteLarge
        }
        let indicatorView = UIActivityIndicatorView(style: style)
        indicatorView.color = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        indicatorView.hidesWhenStopped = false
        indicatorView.startAnimating()
        return indicatorView
    }()
    
    public func contentColorForToast() -> ToastColor {
        .dark
    }
    
    public func attributesForToastDescription() -> [NSAttributedString.Key : Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:UIFont.systemFont(ofSize: 16.8, weight: .regular), .paragraphStyle:paragraph, .foregroundColor:UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)]
    }
    
    public func contentInsetForToast() -> UIEdgeInsets {
        UIEdgeInsets(top: 13.0, left: 13.0, bottom: 12.0, right: 13.0)
    }
    
    public func spacingForToast() -> CGFloat {
        5.0
    }
    
    public func supportedAdjustsKeyboard() -> Bool {
        true
    }
    
    public func spacingForKeyboard() -> CGFloat {
        15.0
    }
    
    public func supportedUserInteraction() -> Bool {
        false
    }
    
    public func activityViewForToast() -> UIView? {
        activityView
    }
    
    public func positionForToast() -> ToastPosition {
        .center
    }
    
    public func offsetYForToast() -> CGFloat {
        0.0
    }
    
    public func animationForToastShow() -> ToastAnimation {
        .fade
    }
    
    public func animationForToastDismiss() -> ToastAnimation {
        .none
    }
}
