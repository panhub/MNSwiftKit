//
//  CAAnimation+MNHelper.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/8.
//

import Foundation
import QuartzCore

extension CAAnimation {
    
    /// 动画Key
    public struct KeyPath {
        
        /* 形变*/
        public static let transform: String = "transform"

        /* 旋转x,y,z分别是绕x,y,z轴旋转 */
        public static let rotation: String = "transform.rotation"
        public static let rotationX: String = "transform.rotation.x"
        public static let rotationY: String = "transform.rotation.y"
        public static let rotationZ: String = "transform.rotation.z"

        /* 缩放x,y,z分别是对x,y,z方向进行缩放 */
        public static let scale: String = "transform.scale"
        public static let scaleX: String = "transform.scale.x"
        public static let scaleY: String = "transform.scale.y"
        public static let scaleZ: String = "transform.scale.z"

        /* 平移x,y,z同上 */
        public static let translation: String = "transform.translation"
        public static let translationX: String = "transform.translation.x"
        public static let translationY: String = "transform.translation.y"
        public static let translationZ: String = "transform.translation.z"

        /* 平面 */
        /* CGPoint中心点改变位置，针对平面 */
        public static let position: String = "position"
        public static let positionX: String = "position.x"
        public static let positionY: String = "position.y"

        /* CGRect */
        public static let bounds: String = "bounds"
        public static let boundsSize: String = "bounds.size"
        public static let boundsSizeWidth: String = "bounds.size.width"
        public static let boundsSizeHeight: String = "bounds.size.height"
        public static let boundsOriginX: String = "bounds.origin.x"
        public static let boundsOriginY: String = "bounds.origin.y"

        /* 透明度 */
        public static let opacity: String = "opacity"
        /* 内容 */
        public static let contents: String = "contents"
        /* 开始路径 */
        public static let strokeStart: String = "strokeStart"
        /* 结束路径 */
        static let strokeEnd: String = "strokeEnd"
        /* 背景色 */
        public static let backgroundColor: String = "backgroundColor"
        /* 圆角 */
        public static let cornerRadius: String = "cornerRadius"
        /* 边框 */
        public static let borderWidth: String = "borderWidth"
        /* 阴影颜色 */
        public static let shadowColor: String = "shadowColor"
        /* 偏移量CGSize */
        public static let shadowOffset: String = "shadowOffset"
        /* 阴影透明度 */
        public static let shadowOpacity: String = "shadowOpacity"
        /* 阴影圆角 */
        public static let shadowRadius: String = "shadowRadius"
    }
    
    /// 构建基础动画
    public class func basic(keyPath: String, duration: TimeInterval, from: Any? = nil, to: Any? = nil) ->CABasicAnimation  {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.fromValue = from
        animation.toValue = to
        animation.autoreverses = false
        animation.beginTime = 0.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        return animation
    }
    
    /// 构建旋转动画
    public class func rotation(to: Double, duration: TimeInterval) ->CABasicAnimation {
        let animation = basic(keyPath: CAAnimation.KeyPath.rotationZ, duration: duration, to: to)
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        return animation
    }
    
    /// 构建内容动画
    public class func contents(to: Any, duration: TimeInterval) -> CABasicAnimation {
        return basic(keyPath: CAAnimation.KeyPath.contents, duration: duration, to: to)
    }
    
    /// 构建关键帧动画
    public class func keyframe(keyPath: String, duration: TimeInterval, values: [Any]?, times: [NSNumber]?) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.autoreverses = false
        animation.beginTime = 0.0
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.values = values
        animation.keyTimes = times
        return animation
    }
}
