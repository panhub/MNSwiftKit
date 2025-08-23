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
    
    public func or(_ defaultValue: Wrapped) -> Wrapped {
        return self ?? defaultValue
    }
    
    public func or(closure expression: @autoclosure () -> Wrapped) -> Wrapped {
        return self ?? expression()
    }
    
    public func or(else creater: ()->Wrapped) -> Wrapped {
        return self ?? creater()
    }
}

extension Optional where Wrapped == String {
    
    public var isBlank: Bool {
        guard let self = self else { return true }
        return self.isBlank
    }
}
