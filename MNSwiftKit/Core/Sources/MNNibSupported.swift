//
//  MNNibSupported.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/8/1.
//  核心协议

import UIKit
import Foundation
import ObjectiveC.runtime

extension NameSpaceWrapper where Base: UIView {
    
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
