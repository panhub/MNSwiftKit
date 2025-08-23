//
//  CALayer+MNLayout.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/19.
//  视图层位置便捷方法

import Foundation
import QuartzCore
import CoreGraphics

extension CALayer {
    
    public class MNLayoutWrapper {
        
        fileprivate let layer: CALayer
        
        fileprivate init(layer: CALayer) {
            self.layer = layer
        }
    }
    
    /// 布局属性包装器
    public var mn_layout: MNLayoutWrapper { MNLayoutWrapper(layer: self) }
}

extension CALayer.MNLayoutWrapper {
    
    /// 原点
    @objc public var origin: CGPoint {
        get { layer.frame.origin }
        set {
            var frame = layer.frame
            frame.origin = newValue
            layer.frame = frame
        }
    }
    /// 大小
    @objc public var size: CGSize {
        get { layer.frame.size }
        set {
            var frame = layer.frame
            frame.size = newValue
            layer.frame = frame
        }
    }
    /// 左
    @objc public var minX: CGFloat {
        get { layer.frame.minX }
        set {
            var frame = layer.frame
            frame.origin.x = newValue
            layer.frame = frame
        }
    }
    /// 右
    @objc public var maxX: CGFloat {
        get { layer.frame.maxX }
        set {
            var frame = layer.frame
            frame.origin.x = newValue - frame.size.width
            layer.frame = frame
        }
    }
    /// 上
    @objc public var minY: CGFloat {
        get { layer.frame.minY }
        set {
            var frame = layer.frame
            frame.origin.y = newValue
            layer.frame = frame
        }
    }
    /// 下
    @objc public var maxY: CGFloat {
        get { layer.frame.maxY }
        set {
            var frame = layer.frame
            frame.origin.y = newValue - frame.size.height
            layer.frame = frame
        }
    }
    /// 宽
    @objc public var width: CGFloat {
        get { layer.frame.width }
        set {
            var frame = layer.frame
            frame.size.width = newValue
            layer.frame = frame
        }
    }
    /// 高
    @objc public var height: CGFloat {
        get { layer.frame.height }
        set {
            var frame = layer.frame
            frame.size.height = newValue
            layer.frame = frame
        }
    }
    /// 中心点
    @objc public var center: CGPoint {
        get { CGPoint(x: layer.frame.midX, y: layer.frame.midY) }
        set {
            var frame = layer.frame
            frame.origin.x = newValue.x - frame.width/2.0
            frame.origin.y = newValue.y - frame.height/2.0
            layer.frame = frame
        }
    }
    /// 横向中心
    @objc public var midX: CGFloat {
        get { layer.frame.midX }
        set {
            var frame = layer.frame
            frame.origin.x = newValue - frame.width/2.0
            layer.frame = frame
        }
    }
    /// 纵向中心
    @objc public var midY: CGFloat {
        get { layer.frame.midY }
        set {
            var frame = layer.frame
            frame.origin.y = newValue - frame.height/2.0
            layer.frame = frame
        }
    }
    /// 自身中心点
    @objc public var Center: CGPoint {
        
        CGPoint(x: layer.bounds.midX, y: layer.bounds.midY)
    }
}

