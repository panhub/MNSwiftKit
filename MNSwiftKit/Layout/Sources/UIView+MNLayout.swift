//
//  UIView+MNLayout.swift
//  MNKit
//
//  Created by 冯盼 on 2021/7/14.
//  视图位置便捷方法

import UIKit
import CoreGraphics

extension UIView {
    
    public class MNLayoutWrapper {
        
        fileprivate let view: UIView
        
        fileprivate init(view: UIView) {
            self.view = view
        }
    }
    
    /// 布局属性包装器
    public var mn_layout: MNLayoutWrapper { MNLayoutWrapper(view: self) }
}

extension UIView.MNLayoutWrapper {
    
    /// 原点
    @objc public var origin: CGPoint {
        get { view.frame.origin }
        set {
            var frame = view.frame
            frame.origin = newValue
            view.frame = frame
        }
    }
    
    /// 大小
    @objc public var size: CGSize {
        get { view.frame.size }
        set {
            var frame = view.frame
            frame.size = newValue
            view.frame = frame
        }
    }
    
    /// 左
    @objc public var minX: CGFloat {
        get { view.frame.minX }
        set {
            var frame = view.frame
            frame.origin.x = newValue
            view.frame = frame
        }
    }
    
    /// 右
    @objc public var maxX: CGFloat {
        get { view.frame.maxX }
        set {
            var frame = view.frame
            frame.origin.x = newValue - frame.size.width
            view.frame = frame
        }
    }
    
    /// 上
    @objc public var minY: CGFloat {
        get { view.frame.minY }
        set {
            var frame = view.frame
            frame.origin.y = newValue
            view.frame = frame
        }
    }
    
    /// 下
    @objc public var maxY: CGFloat {
        get { view.frame.maxY }
        set {
            var frame = view.frame
            frame.origin.y = newValue - frame.size.height
            view.frame = frame
        }
    }
    
    /// 宽
    @objc public var width: CGFloat {
        get { view.frame.width }
        set {
            var frame = view.frame
            frame.size.width = newValue
            view.frame = frame
        }
    }
    
    /// 高
    @objc public var height: CGFloat {
        get { view.frame.height }
        set {
            var frame = view.frame
            frame.size.height = newValue
            view.frame = frame
        }
    }
    
    /// 横向中心
    @objc public var midX: CGFloat {
        get { view.center.x }
        set {
            var center = view.center
            center.x = newValue
            view.center = center
        }
    }
    
    /// 纵向中心
    @objc public var midY: CGFloat {
        get { view.center.y }
        set {
            var center = view.center
            center.y = newValue
            view.center = center
        }
    }
    
    ///  自身中心点
    @objc public var Center: CGPoint {
        
        CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
}
