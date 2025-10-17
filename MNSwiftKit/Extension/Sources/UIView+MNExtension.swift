//
//  UIView+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/14.
//

import UIKit
import Foundation

extension NameSpaceWrapper where Base: UIView {
    
    /// 设置锚点但不改变相对位置
    public var anchor: CGPoint {
        get { base.layer.anchorPoint }
        set {
            let x = Swift.min(Swift.max(0.0, newValue.x), 1.0)
            let y = Swift.min(Swift.max(0.0, newValue.y), 1.0)
            let frame = base.frame
            let point = base.layer.anchorPoint
            let xMargin = x - point.x
            let yMargin = y - point.y
            base.layer.anchorPoint = CGPoint(x: x, y: y)
            var position = base.layer.position
            position.x += xMargin*frame.size.width
            position.y += yMargin*frame.size.height
            base.layer.position = position
        }
    }
    
    /// 移除所有子视图
    public func removeAllSubviews() {
        for view in base.subviews.reversed() {
            base.willRemoveSubview(view)
            view.removeFromSuperview()
        }
    }
    
    /// 内容图片
    public var contents: UIImage? {
        set {
            if base is UIImageView {
                let imageView = base as! UIImageView
                imageView.image = newValue
            } else if base is UIButton {
                let button = base as! UIButton
                button.setBackgroundImage(newValue, for: .normal)
            } else {
                base.layer.contents = newValue?.cgImage
            }
        }
        get {
            if base is UIImageView {
                let imageView = base as! UIImageView
                return imageView.image ?? imageView.highlightedImage
            } else if base is UIButton {
                let button = base as! UIButton
                return button.currentBackgroundImage ?? button.currentImage
            } else if let contents = base.layer.contents {
                return UIImage(cgImage: contents as! CGImage)
            }
            return nil
        }
    }
    
    /// 截图
    public var snapshotImage: UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: base.frame.size)
            return renderer.image { context in
                base.drawHierarchy(in: base.bounds, afterScreenUpdates: true)
            }
        }
        return base.layer.mn.snapshotImage
    }
}

extension NameSpaceWrapper where Base == UIView.ContentMode {
    
    /// UIView.ContentMode => CALayerContentsGravity
    public var gravity: CALayerContentsGravity {
        switch base {
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
