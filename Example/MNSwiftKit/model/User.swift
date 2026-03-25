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
    }
    
    enum Gender: Int {
        case unknown
        case male
        case female
    }
    
    var uid: Int = 0
    
    var age: Int?
    
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
            .init(name: "age", type: .integer, nullable: true),
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
        case "age":
            age = value as? Int
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
