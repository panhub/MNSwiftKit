//
//  Table.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/3/25.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import Foundation
import MNSwiftKit

enum Table: Int, CaseIterable {
    case user
    case order
    case comment
    
    var modelType: MNTableRowInitializable.Type {
        switch self {
        case .user:
            return User.self
        case .order:
            return Order.self
        case .comment:
            return Comment.self
        }
    }
    
    var tableName: String {
        switch self {
        case .user:
            return "t_user"
        case .order:
            return "t_order"
        case .comment:
            return "t_comment"
        }
    }
    
    var rowType: MNTableRowInitializable.Type {
        switch self {
        case .user: return User.self
        case .order: return Order.self
        case .comment: return Comment.self
        }
    }
    
    /// 追加数据页导航标题
    var navigationTitle: String {
        switch self {
        case .user:
            return "用户表"
        case .order:
            return "订单表"
        case .comment:
            return "评论表"
        }
    }
    
    static func placeholder(forColumn columnName: String) -> String {
        switch columnName {
        case "uid": return "请输入用户标识"
        case "birthday": return "选择生日"
        case "gender": return "选择性别"
        case "username": return "请输入用户名"
        case "phone": return "请输入手机号"
        case "email": return "请输入邮箱"
        case "status": return "选择状态"
        case "amount": return "请输入金额"
        case "title": return "请输入标题"
        case "subtitle": return "请输入副标题"
        case "createdAt": return "选择创建时间"
        case "favours": return "请输入点赞数量"
        case "content": return "请输入评论内容"
        case "comment": return "请输入追评"
        default: return columnName
        }
    }
}

extension Table {
    
    class Row {
        
        let fields: [Table.Row.Field]
        
        init(fields: [Table.Row.Field]) {
            self.fields = fields
        }
    }
}

extension Table.Row {
    
    class Field {
        
        let name: String
        
        let value: Any?
        
        let isPrimary: Bool
        
        var displayString: String {
            guard let value = value else { return "NULL" }
            return "\(value)"
        }
        
        var displayEditingString: String {
            guard let value = value else { return "NULL" }
            if name == "gender" {
                if let rawValue = value as? Int, let gender = User.Gender(rawValue: rawValue) {
                    return gender.stringValue
                } else {
                    return "--"
                }
            } else if name == "status" {
                if let rawValue = value as? Int, let status = User.Status(rawValue: rawValue) {
                    return status.stringValue
                } else {
                    return "--"
                }
            }
            return "\(value)"
        }
        
        init(name: String, value: Any?, isPrimary: Bool) {
            self.name = name
            self.value = value
            self.isPrimary = isPrimary
        }
    }
}
