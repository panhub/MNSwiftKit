//
//  MNPermission.swift
//  MNKit
//
//  Created by 冯盼 on 2021/12/12.
//  获取权限

import UIKit
import AdSupport
import Foundation
import AVFoundation
import Photos.PHPhotoLibrary
import AppTrackingTransparency

public class MNPermission {
    
    public typealias AuthorizationHandler = (_ granted: Bool)->Void
    
    /// 请求相册使用权限
    /// - Parameters:
    ///   - queue: 回调队列
    ///   - statusHandler: 回调结果
    public class func requestAlbum(using queue: DispatchQueue = DispatchQueue.main, statusHandler: AuthorizationHandler?) {
        var availables: [PHAuthorizationStatus] = [.authorized]
        if #available(iOS 14, *) {
            availables.append(.limited)
        }
        let authorizationHandler: (PHAuthorizationStatus)->Void = { status in
            queue.async {
                statusHandler?(availables.contains(status))
            }
        }
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            authorizationHandler(.restricted)
            return
        }
        var status: PHAuthorizationStatus = .denied
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        switch status {
        case .notDetermined:
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: authorizationHandler)
            } else {
                PHPhotoLibrary.requestAuthorization(authorizationHandler)
            }
        default:
            authorizationHandler(status)
        }
    }
    
    /// 请求相机使用权限
    /// - Parameters:
    ///   - queue: 回调队列
    ///   - statusHandler: 回调结果
    public class func requestCamera(using queue: DispatchQueue = DispatchQueue.main, statusHandler: AuthorizationHandler?) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { result in
                queue.async {
                    statusHandler?(result)
                }
            }
        } else {
            queue.async {
                statusHandler?(status == .authorized)
            }
        }
    }
    
    /// 请求麦克风使用权限 AVCaptureDevice
    /// - Parameters:
    ///   - queue: 回调队列
    ///   - statusHandler: 回调结果
    public class func requestMicrophone(using queue: DispatchQueue = DispatchQueue.main, statusHandler: AuthorizationHandler?) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { result in
                queue.async {
                    statusHandler?(result)
                }
            }
        } else {
            queue.async {
                statusHandler?(status == .authorized)
            }
        }
    }
    
    /// 请求麦克风使用权限 AVAudioSession
    /// - Parameters:
    ///   - queue: 回调队列
    ///   - statusHandler: 回调结果
    public class func requestMicrophonePermission(using queue: DispatchQueue = DispatchQueue.main, statusHandler: AuthorizationHandler?) {
        let permisson = AVAudioSession.sharedInstance().recordPermission
        if permisson == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { result in
                queue.async {
                    statusHandler?(result)
                }
            }
        } else {
            queue.async {
                statusHandler?(permisson == .granted)
            }
        }
    }
    
    /// 请求IDFA采集权限
    /// - Parameters:
    ///   - queue: 回调队列
    ///   - statusHandler: 回调结果
    public class func requestTracking(using queue: DispatchQueue = DispatchQueue.main, statusHandler: AuthorizationHandler?) {
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            if status == .notDetermined {
                ATTrackingManager.requestTrackingAuthorization { result in
                    queue.async {
                        statusHandler?(result == .authorized)
                    }
                }
            } else {
                queue.async {
                    statusHandler?(status == .authorized)
                }
            }
        } else {
            // Fallback on earlier versions
            let status = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            queue.async {
                statusHandler?(status)
            }
        }
    }
}
