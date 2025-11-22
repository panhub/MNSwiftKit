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
    
    var effectForToast: MNToast.Effect {
        
        .dark
    }
    
    var positionForToast: MNToast.Position {
        
        .center
    }
    
    var contentInsetForToast: UIEdgeInsets {
        
        .init(top: 10.0, left: 12.0, bottom: 9.0, right: 12.0)
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

extension MNMsgToast: MNToastTimerHandler {
    
    func toastShouldDelayDismiss(with status: String?) -> TimeInterval? {
        
        MNToast.displayTimeInterval(with: status)
    }
}
