//
//  User.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/24.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import MNSwiftKit

class User: MNTableRowInitializable {
    
    enum Status: Int {
        case forbidden
        case normal
        case inactive
        
        var stringValue: String {
            switch self {
            case .forbidden: return "禁止"
            case .normal: return "正常"
            case .inactive: return "不活跃"
            }
        }
        
        init?(rawString: String) {
            switch rawString {
            case "禁止":
                self = .forbidden
            case "正常":
                self = .normal
            case "不活跃":
                self = .inactive
            default:
                return nil
            }
        }
    }
    
    enum Gender: Int {
        case unknown
        case male
        case female
        
        var stringValue: String {
            switch self {
            case .unknown: return "未知"
            case .male: return "男"
            case .female: return "女"
            }
        }
        
        init?(rawString: String) {
            switch rawString {
            case "未知":
                self = .unknown
            case "男":
                self = .male
            case "女":
                self = .female
            default:
                return nil
            }
        }
    }
    
    var uid: Int = 0
    
    var birthday: String?
    
    var gender: User.Gender = .unknown
    
    var username: String = ""
    
    var phone: String?
    
    var email: String?
    
    var status: User.Status?
    
    required init() {}
}

extension User: MNTableColumnSupported {
    
    static var supportedTableColumns: [MNSwiftKit.MNTableColumn] {
        [
            .init(name: "uid", type: .integer, primary: true),
            .init(name: "birthday", type: .text, nullable: true),
            .init(name: "gender", type: .integer),
            .init(name: "username", type: .text),
            .init(name: "phone", type: .text, nullable: true),
            .init(name: "email", type: .text, nullable: true),
            .init(name: "status", type: .integer, nullable: true)
        ]
    }
}


extension User: MNTableColumnAssignment {
    
    func setValue(_ value: Any?, forColumn name: String) {
        switch name {
        case "uid":
            uid = value as? Int ?? 0
        case "birthday":
            birthday = value as? String
        case "gender":
            if let rawValue = value as? Int, let gender = Gender(rawValue: rawValue) {
                self.gender = gender
            } else {
                self.gender = .unknown
            }
        case "username":
            username = value as? String ?? ""
        case "phone":
            phone = value as? String
        case "email":
            email = value as? String
        case "status":
            if let rawValue = value as? Int, let status = Status(rawValue: rawValue) {
                self.status = status
            }
        default: break
        }
    }
}
