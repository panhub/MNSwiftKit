//
//  MNMsgToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  提示信息

import UIKit

class MNMsgToast: MNToastBuilder {
    
    var axisForToast: MNToast.Axis {
        .vertical(spacing: 3.0)
    }
    
    var colorForToast: MNToast.Color {
        .dark
    }
    
    var contentInsetForToast: UIEdgeInsets {
        .init(top: 8.0, left: 10.0, bottom: 7.0, right: 10.0)
    }
    
    var activityViewForToast: UIView? { nil }
    
    var userInteractionEnabledForToast: Bool { true }
    
    var positionForToast: MNToast.Position { .center }
    
    var fadeInForToast: Bool { true }
    
    var fadeOutForToast: Bool { true }
    
    var attributesForToastDescription: [NSAttributedString.Key : Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:UIFont.systemFont(ofSize: 16.0, weight: .regular), .paragraphStyle:paragraph, .foregroundColor:UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)]
    }
}

extension MNMsgToast: MNToastAnimationHandler {
    
    func startAnimating(_ toast: MNToast) {
        toast.dismiss(after: 2.0)
    }
    
    func stopAnimating(_ toast: MNToast) {
        
    }
}
