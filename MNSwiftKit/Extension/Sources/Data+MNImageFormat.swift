//
//  Data+MNImageFormat.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/17.
//  获取图片格式

import UIKit
import Foundation

/// 定义图片格式
public enum MNImageFormat {
    case undefined, jpeg, png, gif, tiff, webp, heic
}

extension MNNameSpaceWrapper where Base == Data {
    
    /// 图片格式
    public var imageFormat: MNImageFormat {
        guard let first = base.first else { return .undefined }
        switch first {
        case 0xFF:
            return .jpeg
        case 0x89:
            return .png
        case 0x47:
            return .gif
        case 0x49, 0x4D:
            return .tiff
        case 0x52:
            if base.count >= 12, let string = String(data: base.subdata(in: 0..<12), encoding: .ascii) {
                if string.hasPrefix("RIFF") || string.hasSuffix("WEBP") {
                    return .webp
                }
            }
        case 0x00:
            if base.count >= 12, let string = String(data: base.subdata(in: 4..<12), encoding: .ascii) {
                if string == "ftypheic" || string == "ftypheix" || string == "ftyphevc" || string == "ftyphevx" {
                    return .heic
                }
            }
        default: break
        }
        return .undefined
    }
}
