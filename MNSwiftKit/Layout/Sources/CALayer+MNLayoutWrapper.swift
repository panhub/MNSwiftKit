//
//  CALayer+MNLayout.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/19.
//  视图层位置便捷方法

import Foundation
import CoreFoundation

extension NameSpaceWrapper where Base: CALayer {
    
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
        get { CGPoint(x: base.frame.midX, y: base.frame.midY) }
        set {
            var frame = base.frame
            frame.origin.x = newValue.x - frame.width/2.0
            frame.origin.y = newValue.y - frame.height/2.0
            base.frame = frame
        }
    }
    
    /// 横向中心
    public var midX: CGFloat {
        get { base.frame.midX }
        set {
            var frame = base.frame
            frame.origin.x = newValue - frame.width/2.0
            base.frame = frame
        }
    }
    
    /// 纵向中心
    public var midY: CGFloat {
        get { base.frame.midY }
        set {
            var frame = base.frame
            frame.origin.y = newValue - frame.height/2.0
            base.frame = frame
        }
    }
    
    /// 自身中心点
    public var bounds_center: CGPoint {
        
        CGPoint(x: base.bounds.midX, y: base.bounds.midY)
    }
}
