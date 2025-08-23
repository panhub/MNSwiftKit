//
//  MNInfoToast.swift
//  MNKit
//  
//  Created by 冯盼 on 2022/1/14.
//

import UIKit

public class MNInfoToast: NSObject, MNToastBuilder {
    
    private lazy var activityView: UIView = {
        let activityView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 45.0, height: 45.0))
        activityView.contentMode = .scaleAspectFit
        activityView.tintColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        activityView.image = ToastResourceLoader.image(named: "info")?.withRenderingMode(.alwaysTemplate)
        return activityView
    }()
    
    public func contentColorForToast() -> ToastColor {
        .dark
    }
    
    public func positionForToast() -> ToastPosition {
        .center
    }
    
    public func contentInsetForToast() -> UIEdgeInsets {
        UIEdgeInsets(top: 13.0, left: 13.0, bottom: 13.0, right: 13.0)
    }
    
    public func spacingForToast() -> CGFloat {
        8.0
    }
    
    public func activityViewForToast() -> UIView? {
        activityView
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
    
    public func animationForToastShow() -> ToastAnimation {
        .fade
    }
    
    public func animationForToastDismiss() -> ToastAnimation {
        .fade
    }
    
    public func toastDidUpdateStatus(_ toast: MNToast) {
        MNToast.cancelPreviousPerformRequests(withTarget: toast)
        toast.perform(#selector(toast.close), with: nil, afterDelay: MNToast.duration(with: toast.text))
    }
    
    public func toastDidDisappear(_ toast: MNToast) {
        MNToast.cancelPreviousPerformRequests(withTarget: toast)
    }
}
