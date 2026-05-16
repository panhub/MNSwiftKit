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
    
//    /// 表单与表头展示用列标题
//    func displayTitle(forColumn columnName: String) -> String {
//        switch self {
//        case .user:
//            switch columnName {
//            case "uid": return "用户标识"
//            case "birthday": return "生日"
//            case "gender": return "性别"
//            case "username": return "用户名"
//            case "phone": return "手机号"
//            case "email": return "邮箱"
//            case "status": return "状态"
//            default: return columnName
//            }
//        case .order:
//            switch columnName {
//            case MNDatabase.PrimaryKey: return "用户标识"
//            case "uid": return "用户标识"
//            case "amount": return "金额"
//            case "title": return "标题"
//            case "createdAt": return "创建时间"
//            default: return columnName
//            }
//        case .comment:
//            switch columnName {
//            case "cid": return "评论标识"
//            case "userId": return "用户标识"
//            case "orderId": return "订单标识"
//            case "content": return "内容"
//            case "createdAt": return "创建时间"
//            default: return columnName
//            }
//        }
//    }
    
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
        
        let contents: [String]
        
        init(contents: [String]) {
            self.contents = contents
        }
    }
}

