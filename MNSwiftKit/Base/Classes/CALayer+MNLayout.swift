//
//  CALayer+MNLayout.swift
//  anhe
//
//  Created by 冯盼 on 2022/2/19.
//  视图层位置便捷方法

import Foundation
import QuartzCore
import CoreGraphics

extension CALayer {
    /// 原点
    @objc public var origin: CGPoint {
        get { frame.origin }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    /// 大小
    @objc public var size: CGSize {
        get { frame.size }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    /// 左
    @objc public var minX: CGFloat {
        get { frame.minX }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    /// 右
    @objc public var maxX: CGFloat {
        get { frame.maxX }
        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }
    /// 上
    @objc public var minY: CGFloat {
        get { frame.minY }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    /// 下
    @objc public var maxY: CGFloat {
        get { frame.maxY }
        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }
    /// 宽
    @objc public var width: CGFloat {
        get { frame.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    /// 高
    @objc public var height: CGFloat {
        get { frame.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    /// 中心点
    @objc public var center: CGPoint {
        get { CGPoint(x: frame.minX + frame.width/2.0, y: frame.minY + frame.height/2.0) }
        set {
            var frame = self.frame
            frame.origin.x = newValue.x - frame.width/2.0
            frame.origin.y = newValue.y - frame.height/2.0
            self.frame = frame
        }
    }
    /// 横向中心
    @objc public var midX: CGFloat {
        get { frame.midX }
        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.width/2.0
            self.frame = frame
        }
    }
    /// 纵向中心
    @objc public var midY: CGFloat {
        get { frame.midY }
        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.height/2.0
            self.frame = frame
        }
    }
    /// 自身中心点
    @objc public var Center: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
}

