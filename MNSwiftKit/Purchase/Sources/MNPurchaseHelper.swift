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
    
    private struct PurchaseAssociated {
        static var identifier = "com.mn.purchase.request.identifier"
    }
    
    /// 自定义标识
    var identifier: String {
        get { objc_getAssociatedObject(self, &SKRequest.PurchaseAssociated.identifier) as? String ?? "" }
        set { objc_setAssociatedObject(self, &SKRequest.PurchaseAssociated.identifier, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
}
