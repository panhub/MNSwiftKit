//
//  MNNibSupported.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/8/1.
//  核心协议

import UIKit
import Foundation
import ObjectiveC.runtime

extension MNNameSpaceWrapper where Base: UIView {
    
    /// 从xib加载类
    /// - Parameters:
    ///   - bundle: 资源束实例
    ///   - nibName: nib文件名
    ///   - owner: 所属
    /// - Returns: 类实例
    public static func loadFromNib(_ bundle: Bundle = Bundle(for: Base.self as AnyClass), named nibName: String? = nil, owner: Any? = nil) -> Base! {
        guard let result = bundle.loadNibNamed(nibName ?? "\(self)", owner: owner) else { return nil }
        return result.first { $0 is Base } as? Base
    }
}

extension UIView {
    
    /// 圆角大小
    @IBInspectable public var mn_radius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    /// 边框宽度
    @IBInspectable public var mn_border_width: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    /// 边框颜色
    @IBInspectable public var mn_border_color: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set { layer.borderColor = newValue?.cgColor }
    }
}

extension UIControl {
    
    /// 是否可点击
    @IBInspectable public var mn_enabled: Bool {
        get { isEnabled }
        set { isEnabled = newValue }
    }
    
    /// 是否选中状态
    @IBInspectable public var mn_selected: Bool {
        get { isSelected }
        set { isSelected = newValue }
    }
}
