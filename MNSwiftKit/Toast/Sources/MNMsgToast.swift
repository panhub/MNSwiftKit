//
//  MNMsgToast.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/10.
//  提示信息

import UIKit

class MNMsgToast: NSObject, MNToastBuilder {
    
    
    func contentColorForToast() -> ToastColor {
        .dark
    }
    
    func positionForToast() -> ToastPosition {
        .center
    }
    
    func offsetYForToast() -> CGFloat {
        0.0
    }
    
    func spacingForToast() -> CGFloat {
        0.0
    }
    
    func activityViewForToast() -> UIView? {
        nil
    }
    
    func contentInsetForToast() -> UIEdgeInsets {
        UIEdgeInsets(top: 10.0, left: 13.0, bottom: 10.0, right: 13.0)
    }
    
    func attributesForToastDescription() -> [NSAttributedString.Key : Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 1.0
        paragraph.paragraphSpacing = 1.0
        paragraph.lineHeightMultiple = 1.0
        paragraph.paragraphSpacingBefore = 1.0
        return [.font:UIFont.systemFont(ofSize: 16.8, weight: .regular), .paragraphStyle:paragraph, .foregroundColor:UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)]
    }
    
    func supportedUserInteraction() -> Bool {
        true
    }
    
    func supportedAdjustsKeyboard() -> Bool {
        true
    }
    
    func spacingForKeyboard() -> CGFloat {
        15.0
    }
    
    func animationForToastShow() -> ToastAnimation {
        .fade
    }
    
    func animationForToastDismiss() -> ToastAnimation {
        .fade
    }
    
    func toastDidUpdateStatus(_ toast: MNToast) {
        MNToast.cancelPreviousPerformRequests(withTarget: toast)
        toast.perform(#selector(toast.close), with: nil, afterDelay: MNToast.duration(with: toast.text))
    }
    
    func toastDidDisappear(_ toast: MNToast) {
        MNToast.cancelPreviousPerformRequests(withTarget: toast)
    }
}
