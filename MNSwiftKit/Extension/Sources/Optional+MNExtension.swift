//
//  Optional+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/8/29.
//  可选值辅助

import Foundation

extension Optional {
    
    /// 可选值是否为空
    public var isNil: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
}

extension Optional where Wrapped == String {
    
    public var isBlank: Bool {
        guard let self = self else { return true }
        return self.isBlank
    }
}
