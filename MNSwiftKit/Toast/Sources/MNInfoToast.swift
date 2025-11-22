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
        
        .vertical(spacing: 7.0)
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
        
        var image: UIImage!
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: "info.circle")
        } else {
            image = ToastResource.image(named: "info")
        }
        let imageView = UIImageView(frame: .init(origin: .zero, size: .init(width: 40.0, height: 40.0)))
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        return imageView
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
