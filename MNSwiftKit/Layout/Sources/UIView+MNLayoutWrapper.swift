//
//  UIView+MNLayout.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/14.
//  视图位置便捷方法

import UIKit
import CoreFoundation

extension MNNameSpaceWrapper where Base: UIView {
    
    /// 原点
    public var origin: CGPoint {
        get { base.frame.origin }
        set {
            var frame = base.frame
            frame.origin = newValue
            base.frame = frame
        }
    }
    
    /// 大小
    public var size: CGSize {
        get { base.frame.size }
        set {
            var frame = base.frame
            frame.size = newValue
            base.frame = frame
        }
    }
    
    /// 左
    public var minX: CGFloat {
        get { base.frame.minX }
        set {
            var frame = base.frame
            frame.origin.x = newValue
            base.frame = frame
        }
    }
    
    /// 右
    public var maxX: CGFloat {
        get { base.frame.maxX }
        set {
            var frame = base.frame
            frame.origin.x = newValue - frame.size.width
            base.frame = frame
        }
    }
    
    /// 上
    public var minY: CGFloat {
        get { base.frame.minY }
        set {
            var frame = base.frame
            frame.origin.y = newValue
            base.frame = frame
        }
    }
    
    /// 下
    public var maxY: CGFloat {
        get { base.frame.maxY }
        set {
            var frame = base.frame
            frame.origin.y = newValue - frame.size.height
            base.frame = frame
        }
    }
    
    /// 宽
    public var width: CGFloat {
        get { base.frame.width }
        set {
            var frame = base.frame
            frame.size.width = newValue
            base.frame = frame
        }
    }
    
    /// 高
    public var height: CGFloat {
        get { base.frame.height }
        set {
            var frame = base.frame
            frame.size.height = newValue
            base.frame = frame
        }
    }
    
    /// 中心点
    public var center: CGPoint {
        get { base.center }
        set {
            var frame = base.frame
            frame.origin.x = newValue.x - frame.width/2.0
            frame.origin.y = newValue.y - frame.height/2.0
            base.frame = frame
        }
    }
    
    /// 横向中心
    public var midX: CGFloat {
        get { base.center.x }
        set {
            var center = base.center
            center.x = newValue
            base.center = center
        }
    }
    
    /// 纵向中心
    public var midY: CGFloat {
        get { base.center.y }
        set {
            var center = base.center
            center.y = newValue
            base.center = center
        }
    }
    
    ///  自身中心点
    public var bounds_center: CGPoint {
        
        CGPoint(x: base.bounds.midX, y: base.bounds.midY)
    }
}
