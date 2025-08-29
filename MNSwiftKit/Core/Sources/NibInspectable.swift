//
//  NIBInspectable.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/9/19.
//

import UIKit
import Foundation

extension UIView {
    
    /// 圆角大小
    @IBInspectable public var ib_radius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    /// 边框宽度
    @IBInspectable public var ib_border_width: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    /// 边框颜色
    @IBInspectable public var ib_border_color: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set { layer.borderColor = newValue?.cgColor }
    }
}

extension UIControl {
    
    /// 是否可点击
    @IBInspectable public var ib_enabled: Bool {
        get { isEnabled }
        set { isEnabled = newValue }
    }
    
    /// 是否选中状态
    @IBInspectable public var ib_selected: Bool {
        get { isSelected }
        set { isSelected = newValue }
    }
}
