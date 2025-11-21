//
//  MNActivityToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  Indicator弹窗

import UIKit

public class MNActivityToast: MNToastBuilder {
    
    public var axisForToast: MNToast.Axis {
        .vertical(spacing: 2.0)
    }
    
    public var colorForToast: MNToast.Color {
        .dark
    }
    
    public var contentInsetForToast: UIEdgeInsets {
        .init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    public var activityViewForToast: UIView? {
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
    }
    
    public var userInteractionEnabledForToast: Bool { true }
    
    public var positionForToast: MNToast.Position { .center }
    
    public var fadeInForToast: Bool { true }
    
    public var fadeOutForToast: Bool { true }
    
    public var attributesForToastDescription: [NSAttributedString.Key : Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:UIFont.systemFont(ofSize: 16.0, weight: .regular), .paragraphStyle:paragraph, .foregroundColor:UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)]
    }
}
