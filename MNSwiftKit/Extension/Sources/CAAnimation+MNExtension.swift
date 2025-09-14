//
//  CAAnimation+MNHelper.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/8.
//

import Foundation
import QuartzCore

extension NameSpaceWrapper where Base == String {
    
    /// 形变
    public class var transform: String { "transform" }
    
    /// 旋转x,y,z分别是绕x,y,z轴旋转
    public class var rotation: String { "transform.rotation" }
    public class var rotationX: String { "transform.rotation.x" }
    public class var rotationY: String { "transform.rotation.y" }
    public class var rotationZ: String { "transform.rotation.z" }

    /// 缩放x,y,z分别是对x,y,z方向进行缩放
    public class var scale: String { "transform.scale" }
    public class var scaleX: String { "transform.scale.x" }
    public class var scaleY: String { "transform.scale.y" }
    public class var scaleZ: String { "transform.scale.z" }

    /// 平移x,y,z同上
    public class var translation: String { "transform.translation" }
    public class var translationX: String { "transform.translation.x" }
    public class var translationY: String { "transform.translation.y" }
    public class var translationZ: String { "transform.translation.z" }

    /// 平面
    /// CGPoint中心点改变位置，针对平面
    public class var position: String { "position" }
    public class var positionX: String { "position.x" }
    public class var positionY: String { "position.y" }

    /// CGRect
    public class var bounds: String { "bounds" }
    public class var boundsSize: String { "bounds.size" }
    public class var boundsSizeWidth: String { "bounds.size.width" }
    public class var boundsSizeHeight: String { "bounds.size.height" }
    public class var boundsOriginX: String { "bounds.origin.x" }
    public class var boundsOriginY: String { "bounds.origin.y" }

    /// 透明度
    public class var opacity: String { "opacity" }
    /// 内容
    public class var contents: String { "contents" }
    /// 开始路径
    public class var strokeStart: String { "strokeStart" }
    /// 结束路径
    public class var strokeEnd: String { "strokeEnd" }
    /// 背景色
    public class var backgroundColor: String { "backgroundColor" }
    /// 圆角
    public class var cornerRadius: String { "cornerRadius" }
    /// 边框
    public class var borderWidth: String { "borderWidth" }
    /// 阴影颜色
    public class var shadowColor: String { "shadowColor" }
    /// 偏移量CGSize
    public class var shadowOffset: String { "shadowOffset" }
    /// 阴影透明度
    public class var shadowOpacity: String { "shadowOpacity" }
    /// 阴影圆角
    public class var shadowRadius: String { "shadowRadius" }
}

extension CABasicAnimation {
    
    /// 构造基础动画
    /// - Parameters:
    ///   - path: 动画路径
    ///   - duration: 动画时长
    ///   - from: 起始
    ///   - to: 结束
    public convenience init(keyPath path: String, duration: TimeInterval, from: Any? = nil, to: Any? = nil) {
        self.init(keyPath: path)
        self.duration = duration
        fromValue = from
        toValue = to
        autoreverses = false
        beginTime = 0.0
        timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        isRemovedOnCompletion = false
        fillMode = .forwards
    }
    
    /// 构建旋转动画
    /// - Parameters:
    ///   - to: 弧度
    ///   - duration: 动画时长
    public convenience init(rotation to: Double, duration: TimeInterval) {
        self.init(keyPath: .mn.rotationZ, duration: duration, to: to)
        repeatCount = Float.greatestFiniteMagnitude
        timingFunction = CAMediaTimingFunction(name: .linear)
    }
    
    /// 内容动画
    /// - Parameters:
    ///   - contents: 新的内容
    ///   - duration: 动画时长
    public convenience init(contents: Any, duration: TimeInterval) {
        self.init(keyPath: .mn.contents, duration: duration, to: contents)
    }
}

extension CAKeyframeAnimation {
    
    /// 构建关键帧动画
    /// - Parameters:
    ///   - path: 动画路径
    ///   - duration: 动画时长
    ///   - values: 关键帧帧
    ///   - times: 时间节点
    public convenience init(keyPath path: String, duration: TimeInterval, values: [Any]?, times: [NSNumber]?) {
        self.init(keyPath: path)
        self.values = values
        self.duration = duration
        keyTimes = times
        autoreverses = false
        beginTime = 0.0
        timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        isRemovedOnCompletion = false
        fillMode = .forwards
    }
}
