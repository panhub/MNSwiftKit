//
//  UIView+MNHelper.swift
//  MNKit
//
//  Created by 冯盼 on 2021/7/14.
//

import UIKit
import Foundation

extension UIView {
    
    /// 设置锚点但不改变相对位置
    @objc public var anchor: CGPoint {
        get { layer.anchorPoint }
        set {
            let x = min(max(0.0, newValue.x), 1.0)
            let y = min(max(0.0, newValue.y), 1.0)
            let frame = frame
            let point = layer.anchorPoint
            let xMargin = x - point.x
            let yMargin = y - point.y
            layer.anchorPoint = CGPoint(x: x, y: y)
            var position = layer.position
            position.x += xMargin*frame.size.width
            position.y += yMargin*frame.size.height
            layer.position = position
        }
    }
    
    /// 移除所有子视图
    @objc public func removeAllSubviews() {
        for view in subviews.reversed() {
            willRemoveSubview(view)
            view.removeFromSuperview()
        }
    }
}

extension UIView.ContentMode {
    
    /// UIView.ContentMode => CALayerContentsGravity
    public var gravity: CALayerContentsGravity {
        switch self {
        case .scaleToFill: return .resize
        case .scaleAspectFit: return .resizeAspect
        case .scaleAspectFill: return .resizeAspectFill
        case .top: return .top
        case .left: return .left
        case .bottom: return .bottom
        case .right: return .right
        case .center: return .center
        case .topLeft: return .topLeft
        case .topRight: return .topRight
        case .bottomLeft: return .bottomLeft
        case .bottomRight: return .bottomRight
        default:  return .resize
        }
    }
}
