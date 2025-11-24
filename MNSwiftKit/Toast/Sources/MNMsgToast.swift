//
//  MNMsgToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  提示信息

import UIKit

class MNMsgToast: MNToastBuilder {
    
    var axisForToast: MNToast.Axis {
        
        MNToast.Configuration.shared.axis
    }
    
    var effectForToast: MNToast.Effect {
        
        MNToast.Configuration.shared.effect
    }
    
    var contentInsetForToast: UIEdgeInsets {
        
        .init(top: 11.0, left: 12.0, bottom: 10.0, right: 12.0)
    }
    
    var activityViewForToast: UIView? {
        
        nil
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
    
    var allowUserInteractionWhenDisplayed: Bool {
        
        true
    }
}

extension MNMsgToast: MNToastTimerHandler {
    
    func toastShouldDelayDismiss(with status: String?) -> TimeInterval? {
        
        MNToast.displayDuration(with: status)
    }
}
