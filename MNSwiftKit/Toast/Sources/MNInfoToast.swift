//
//  MNInfoToast.swift
//  MNSwiftKit
//  
//  Created by panhub on 2022/1/14.
//  Info样式弹窗

import UIKit

/// Info样式弹窗构造者
class MNInfoToast: MNToastBuilder {
    
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
        
        var image: UIImage!
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: "info.circle")
        } else {
            image = ToastResource.image(named: "info")
        }
        let imageView = UIImageView(frame: .init(origin: .zero, size: .init(width: 40.0, height: 40.0)))
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = MNToast.Configuration.shared.color
        return imageView
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
        
        MNToast.Configuration.shared.allowUserInteractionWhenDisplayed
    }
}
