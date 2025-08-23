//
//  MNWeakProxy.swift
//  MNKit
//
//  Created by 小斯 on 2023/5/4.
//  弱引用代理

import Foundation
import ObjectiveC.runtime

public class MNWeakProxy: NSObject {
    
    private(set) weak var target: NSObjectProtocol?
    
    public init(target: NSObjectProtocol) {
        self.target = target
    }
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? { target }
    
    public override func responds(to aSelector: Selector!) -> Bool {
        guard let target = target else { return false }
        return target.responds(to: aSelector)
    }
    
    public override func isMember(of aClass: AnyClass) -> Bool {
        guard let target = target else { return false }
        return target.isMember(of: aClass)
    }
    
    public override func isKind(of aClass: AnyClass) -> Bool {
        guard let target = target else { return false }
        return target.isKind(of: aClass)
    }
    
    public override func conforms(to aProtocol: Protocol) -> Bool {
        guard let target = target else { return false }
        return target.conforms(to: aProtocol)
    }
    
    public override var hash: Int { target?.hash ?? 0 }
    
    public override var description: String { target?.description ?? "not found target description." }
    
    public override var debugDescription: String { target?.debugDescription ?? "not found target debugDescription." }
}
