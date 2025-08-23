//
//  MNToast+Extension.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/14.
//  Window弹窗

import UIKit
import Foundation

public extension MNToast {
    
    @objc static var exist: Bool { window?.existToast ?? false }
    
    @objc static var window: UIWindow? {
        if #available(iOS 15.0, *) {
            return mainWindow(in: UIApplication.shared.delegate?.window??.windowScene?.windows.reversed())
        } else {
            return mainWindow(in: UIApplication.shared.windows.reversed())
        }
    }
    private static func mainWindow(in windows: [UIWindow]?) -> UIWindow? {
        guard let windows = windows else { return nil }
        for window in windows {
            let isOnMainScreen = window.screen == UIScreen.main
            let isVisible = (window.isHidden == false && window.alpha > 0.01)
            if isOnMainScreen, isVisible, window.isKeyWindow {
                return window
            }
        }
        return nil
    }
    
    @objc class func showInfo(_ status: String, completion: (()->Void)? = nil) {
        
    }
}

//// MARK: - Window显示弹窗
//public extension MNToast {
//    
//    @objc class func show(_ status: String?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showToast(status)
//        }
//    }
//    
//    @objc class func showActivity(_ status: String?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showActivityToast(status)
//        }
//    }
//    
//    @objc class func showMask(_ status: String?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showMaskToast(status)
//        }
//    }
//    
//    @objc class func showMsg(_ status: String) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showMsgToast(status)
//        }
//    }
//    
//    @objc class func showMsg(_ status: String, completion: (()->Void)?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showMsgToast(status, completion: completion)
//        }
//    }
//    
//    @objc class func showInfo(_ status: String) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showInfoToast(status)
//        }
//    }
//    
//    @objc class func showInfo(_ status: String, completion: (()->Void)?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showInfoToast(status, completion: completion)
//        }
//    }
//    
//    @objc class func showComplete(_ status: String?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showCompleteToast(status)
//        }
//    }
//    
//    @objc class func showComplete(_ status: String?, completion: (()->Void)?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showCompleteToast(status, completion: completion)
//        }
//    }
//
//    @objc class func showError(_ status: String?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showFailureToast(status)
//        }
//    }
//    
//    @objc class func showError(_ status: String?, completion: (()->Void)?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showFailureToast(status, completion: completion)
//        }
//    }
//    
//    @objc class func showProgress(_ status: String?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.showProgressToast(status)
//        }
//    }
//}
//
//// MARK: - Window更新弹窗
//public extension MNToast {
//    @objc class func update(progress pro: Double) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.updateToast(progress: pro)
//        }
//    }
//    
//    @objc class func update(status msg: String?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.updateToast(status: msg)
//        }
//    }
//    
//    @objc class func update(success completion:(()->Void)?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.updateToast(success: completion)
//        }
//    }
//}
//
//// MARK: - Window关闭弹窗
//public extension MNToast {
//    @objc class func close() {
//        OperationQueue.main.addOperation {
//            MNToast.window?.closeToast()
//        }
//    }
//    
//    @objc class func close(completion: (()->Void)?) {
//        OperationQueue.main.addOperation {
//            MNToast.window?.closeToast(completion: completion)
//        }
//    }
//}
