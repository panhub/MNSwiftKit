//
//  HapticFeedback.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/3/15.
//  触觉反馈(适用于 iPhone 7、7 Plus 及其以上机型)

import UIKit
import Foundation
import AVFoundation

/// 触觉反馈
public class HapticFeedback {
    
    // UINotificationFeedbackGenerator
    @available(iOS 10.0, *)
    public class Notification {
        
        public class func success() {
            occurred(.success)
        }
        
        public class func warning() {
            occurred(.warning)
        }
        
        public class func error() {
            occurred(.error)
        }
        
        private class func occurred(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(notificationType)
        }
    }
    
    // UIImpactFeedbackGenerator
    @available(iOS 10.0, *)
    public class Impact {
        
        //private static var generator: UIImpactFeedbackGenerator?
        /// 轻度
        public class func light() {
            occurred(.light)
        }
        
        /// 中度
        public class func medium() {
            occurred(.medium)
        }
        
        /// 重度
        public class func heavy() {
            occurred(.heavy)
        }
        
        private class func occurred(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    // UISelectionFeedbackGenerator
    @available(iOS 10.0, *)
    public class Selection {

        public class func changed() {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    // AudioServicesPlaySystemSound
    public class AudioService {
        
        @available(iOS 9.0, *)
        public class func peek() {
            AudioServicesPlaySystemSound(1519)
        }
        
        @available(iOS 9.0, *)
        public class func pop() {
            AudioServicesPlaySystemSound(1520)
        }
        
        @available(iOS 9.0, *)
        public class func error() {
            AudioServicesPlaySystemSound(1521)
        }
        
        public class func vibration() {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    /// 振动反馈
    public class func vibration() {
        if #available(iOS 10.0, *) {
            HapticFeedback.Impact.medium()
        } else {
            HapticFeedback.AudioService.vibration()
        }
    }
}
