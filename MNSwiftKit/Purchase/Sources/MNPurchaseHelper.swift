//
//  SKRequest+MNPurchase.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/11/7.
//  内购辅助

import StoreKit
import Foundation
import ObjectiveC.runtime

extension SKRequest {
    
    private struct MNPurchaseAssociated {
        
        nonisolated(unsafe) static var identifier: Void?
    }
    
    /// 自定义标识
    var mn_identifier: String {
        get { objc_getAssociatedObject(self, &SKRequest.MNPurchaseAssociated.identifier) as? String ?? "" }
        set { objc_setAssociatedObject(self, &SKRequest.MNPurchaseAssociated.identifier, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
}
