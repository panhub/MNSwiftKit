//
//  MNReceiptBase.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/12/1.
//  购买收据缓存

import SQLite3
import Foundation

/// 主键
fileprivate var MNReceiptPrimaryKey = "id"

/// 避免乱码
fileprivate let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public class MNPurchaseReceipt: NSObject {
    /// 标识(当前时间戳 ms)
    @objc public var identifier: String = ""
    /// 产品标识
    @objc public var product: String = ""
    /// 价格
    @objc public var price: Double = 0.0
    /// 用户定制信息
    @objc public var userInfo: String?
    /// 凭据内容
    @objc public var content: String = ""
    /// 失败的次数
    @objc public var failCount: Int = 0
    /// 交易标识
    @objc public var transactionIdentifier: String?
    /// 原始交易标识
    @objc public var originalTransactionIdentifier: String?
    /// 交易时间 m
    @objc public var transactionDate: TimeInterval = 0.0
    /// 原始交易时间 m
    @objc public var originalTransactionDate: TimeInterval = 0.0
    /// 验证用户名
    @objc public var applicationUsername: String?
    /// 是否是本地凭据
    public var isLocal: Bool = false
    /// 是否是恢复购买凭据
    public var isRestore: Bool = false
    
    public override init() {
        super.init()
        self.identifier = NSDecimalNumber(value: Date().timeIntervalSince1970*1000.0).stringValue
    }
    
    /// 构造内购凭据
    /// - Parameter receiptData: 内购凭据二进制数据
    public convenience init(receiptData: Data) {
        self.init()
        self.content = receiptData.base64EncodedString(options: .endLineWithLineFeed)
    }
    
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
#if DEBUG
        print("\n关联内购凭据出错: \(key)")
#endif
    }
}

public class MNReceiptBase {
    /// 默认表名
    private static let Table: String = "t_receipt"
    /// 默认数据库路径
    public static let Path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/receipts.sqlite"
    /// 数据库路径
    private var path: String = Path
    /// 数据库指针
    private var db: OpaquePointer!
    /// 映射表支持字段 属性:类型
    private lazy var columns: [String:Int32] = {
        var count: UInt32 = 0
        var columns = [String:Int32]()
        if let properties = class_copyPropertyList(MNPurchaseReceipt.self, &count) {
            for idx in 0..<count {
                let property = properties[Int(idx)]
                let name = String(cString: property_getName(property))
                guard let attr = property_getAttributes(property) else { continue }
                let string = String(cString: attr)
                let attributes: [String] = string.components(separatedBy: ",")
                guard attributes.contains("R") == false else { continue }
                if attributes.contains("T@\"NSString\"") {
                    columns[name] = SQLITE_TEXT
                } else if attributes.contains("T@\"NSNumber\"") || attributes.contains("Td") || attributes.contains("Tf") {
                    columns[name] = SQLITE_FLOAT
                } else if attributes.contains("Ti") || attributes.contains("TB") || attributes.contains("Tq") || attributes.contains("TQ") {
                    columns[name] = SQLITE_INTEGER
                } else if attributes.contains("T@\"NSData\"") {
                    columns[name] = SQLITE_BLOB
                }
            }
            free(properties)
        }
        return columns
    }()
    /// 现有内购凭据集合
    public var receipts: [MNPurchaseReceipt]? {
        guard open() else { return nil }
        let sql = "SELECT * FROM '\(MNReceiptBase.Table)';"
        var stmt: OpaquePointer!
        guard sqlite3_prepare_v2(db, sql.cString(using: .utf8), -1, &stmt, nil) == SQLITE_OK else { return nil }
        var receipts = [MNPurchaseReceipt]()
        while sqlite3_step(stmt) == SQLITE_ROW {
            let receipt = MNPurchaseReceipt()
            let count = sqlite3_column_count(stmt)
            for index in 0..<count {
                guard let cName = sqlite3_column_name(stmt, index) else { continue }
                let name = String(cString: cName)
                if name == MNReceiptPrimaryKey { continue }
                let type = sqlite3_column_type(stmt, index)
                var value: Any!
                switch type {
                case SQLITE_INTEGER:
                    value = Int(sqlite3_column_int64(stmt, Int32(index)))
                case SQLITE_FLOAT:
                    value = sqlite3_column_double(stmt, Int32(index))
                case SQLITE_TEXT, SQLITE3_TEXT:
                    if let text = sqlite3_column_text(stmt, Int32(index)) {
                        value = String(cString: text)
                    }
                case SQLITE_BLOB:
                    if let bytes = sqlite3_column_blob(stmt, Int32(index)) {
                        let count = sqlite3_column_bytes(stmt, Int32(index))
                        value = Data(bytes: bytes, count: Int(count))
                    }
                default: continue
                }
                if let value = value {
                    receipt.setValue(value, forKey: name)
                }
            }
            receipts.append(receipt)
        }
        sqlite3_finalize(stmt)
        return receipts.isEmpty ? nil : receipts
    }
    
    /// 创建缓存数据库
    /// - Parameters:
    ///   - path: 数据库路径
    ///   - table: 表名
    public init(path: String = Path) {
        if FileManager.default.fileExists(atPath: path) == false {
            do {
                try FileManager.default.createDirectory(atPath: (path as NSString).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            } catch {
#if DEBUG
                print("\n内购缓存文件夹创建失败:\n\(error)\n")
#endif
            }
        }
        self.path = path
#if DEBUG
        print("\n===============内购缓存路径===============\n\(path)\n========================================")
#endif
    }
    
    deinit {
        close()
    }
    
    /// 是否存在内购凭据
    /// - Parameter identifier: 内购凭据标识符
    /// - Returns: 是否存在 `nil`代表出错
    public func exist(_ identifier: String) -> Bool? {
        guard open() else { return nil }
        let sql = "SELECT COUNT(1) FROM '\(MNReceiptBase.Table)' WHERE \(#keyPath(MNPurchaseReceipt.identifier))='\(identifier)';"
        var stmt: OpaquePointer!
        guard sqlite3_prepare_v2(db, sql.cString(using: .utf8), -1, &stmt, nil) == SQLITE_OK else { return nil }
        var isExist: Bool!
        if sqlite3_step(stmt) == SQLITE_ROW {
            isExist = sqlite3_column_int(stmt, 0) > 0
        }
        sqlite3_finalize(stmt)
#if DEBUG
        if let isExist = isExist {
            print("\n查询到内购凭据\(isExist ? "存在" : "不存在"): \(identifier)")
        } else {
            print("\n查询凭据是否存在出错")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            } else {
                print(": \(identifier)")
            }
        }
#endif
        return isExist
    }
    
    /// 插入内购凭据
    /// - Parameter receipt: 内购凭据模型
    /// - Returns: 是否插入成功
    @discardableResult
    public func insert(_ receipt: MNPurchaseReceipt) -> Bool {
        // 先查询是否存在
        guard let exist = exist(receipt.identifier) else { return false }
        if exist {
            return update(receipt)
        }
        // 插入
        let contents = columns(from: receipt).compactMap { ($0, $1) }
        guard contents.isEmpty == false else { return false }
        var values = [String]()
        for index in 0..<contents.count {
            values.append("?\(index + 1)")
        }
        let params = contents.compactMap { $0.0 }
        let sql = "INSERT INTO '\(MNReceiptBase.Table)' (\(params.joined(separator: ","))) VALUES (\(values.joined(separator: ",")));"
        let isSuccess = execute(sql, params: contents)
#if DEBUG
        if isSuccess {
            print("\n插入内购凭据成功: \(receipt.identifier)")
        } else {
            print("\n插入内购凭据失败")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            } else {
                print(": \(receipt.identifier)")
            }
        }
#endif
        return isSuccess
    }
    
    /// 更新内购凭据
    /// - Parameter receipt: 内购凭据模型
    /// - Returns: 是否更新成功
    @discardableResult
    public func update(_ receipt: MNPurchaseReceipt) -> Bool {
        guard open() else { return false }
        let contents = columns(from: receipt).compactMap { ($0, $1) }
        guard contents.isEmpty == false else { return false }
        var params = [String]()
        for (index, content) in contents.enumerated() {
            params.append("\(content.0)=?\(index + 1)")
        }
        let sql: String = "UPDATE '\(MNReceiptBase.Table)' SET \(params.joined(separator: ",")) WHERE \(#keyPath(MNPurchaseReceipt.identifier))='\(receipt.identifier)';"
        let isSuccess = execute(sql, params: contents)
#if DEBUG
        if isSuccess {
            print("\n更新内购凭据成功: \(receipt.identifier)")
        } else {
            print("\n更新内购凭据失败")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            } else {
                print(": \(receipt.identifier)")
            }
        }
#endif
        return isSuccess
    }
    
    /// 删除内购凭据
    /// - Parameter identifier: 内购标识符或事务标识符
    /// - Returns: 是否删除
    @discardableResult
    public func delete(_ identifier: String) -> Bool {
        guard open() else { return false }
        let sql = "DELETE FROM '\(MNReceiptBase.Table)' WHERE \(#keyPath(MNPurchaseReceipt.identifier))='\(identifier)';"
        let result = sqlite3_exec(db, sql.cString(using: .utf8), nil, nil, nil) == SQLITE_OK
#if DEBUG
        if result {
            print("\n已删除内购凭据: \(identifier)")
        } else {
            print("\n删除内购凭据出错")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            } else {
                print(": \(identifier)")
            }
        }
#endif
        return result
    }
    
    /// 执行语句
    /// - Parameters:
    ///   - sql: 数据库语句
    ///   - params: 参数
    /// - Returns: 是否执行成功
    private func execute(_ sql: String, params: [(String,Any?)]) -> Bool {
        var stmt: OpaquePointer!
        guard sqlite3_prepare_v2(db, sql.cString(using: .utf8), -1, &stmt, nil) == SQLITE_OK else { return false }
        // 绑定数据
        var isSuccess: Bool = true
        for (index, param) in params.enumerated() {
            let value = param.1
            let type = columns[param.0]
            switch type {
            case SQLITE_TEXT, SQLITE3_TEXT:
                if let string = value as? String {
                    isSuccess = sqlite3_bind_text(stmt, Int32(index + 1), (string as NSString).utf8String, -1, SQLITE_TRANSIENT) == SQLITE_OK
                } else {
                    isSuccess = sqlite3_bind_null(stmt, Int32(index + 1)) == SQLITE_OK
                }
            case SQLITE_INTEGER:
                if let number = value as? sqlite3_int64 {
                    isSuccess = sqlite3_bind_int64(stmt, Int32(index + 1), number) == SQLITE_OK
                }
            case SQLITE_FLOAT:
                if let number = value as? Double {
                    isSuccess = sqlite3_bind_double(stmt, Int32(index + 1), number) == SQLITE_OK
                }
            case SQLITE_BLOB:
                if let data = value as? Data {
                    var bytes = [UInt8](data)
                    isSuccess = sqlite3_bind_blob(stmt, Int32(index + 1), &bytes, Int32(bytes.count), SQLITE_TRANSIENT) == SQLITE_OK
                } else {
                    isSuccess = sqlite3_bind_null(stmt, Int32(index + 1)) == SQLITE_OK
                }
            default: break
            }
            guard isSuccess else { break }
        }
        // 执行
        let result = isSuccess ? (sqlite3_step(stmt) == SQLITE_DONE) : false
        sqlite3_finalize(stmt)
        return result
    }
}

extension MNReceiptBase {
    
    /// 从模型中映射数据
    /// - Parameter obj: 内购凭据模型
    /// - Returns: 数据
    private func columns(from obj: MNPurchaseReceipt) -> [String:Any?] {
        var result = [String:Any]()
        guard columns.isEmpty == false else { return result }
        let children: Mirror.Children = Mirror(reflecting: obj).children
        guard children.isEmpty == false else { return result }
        for (label, value) in children {
            guard let name = label else { continue }
            // 保证存在字段
            guard let _ = columns[name] else { continue }
            // ExpressibleByNilLiteral
            switch value {
            case Optional<Any>.none:
                // 处理nil
                result[name] = nil
            default:
                // 处理枚举
                let mirror = Mirror(reflecting: value)
                if let style = mirror.displayStyle, style == .enum {
                    result[name] = obj.value(forKey:name)
                } else {
                    result[name] = value
                }
            }
        }
        return result
    }
    
    /// 转换类型
    /// - Parameter type: 数据库类型
    /// - Returns: 类型的字符串形式
    private func sql(for type: Int32) -> String {
        switch type {
        case SQLITE_TEXT, SQLITE3_TEXT: return "TEXT"
        case SQLITE_INTEGER: return "INTEGER"
        case SQLITE_FLOAT: return "FLOAT"
        case SQLITE_BLOB: return "BLOB"
        default: return "TEXT"
        }
    }
}

extension MNReceiptBase {
    
    /**打开数据库*/
    private func open() -> Bool {
        if let _ = db { return true }
        if sqlite3_open(path.cString(using: .utf8), &db) == SQLITE_OK, sqlite3_exec(db, "create table if not exists '\(MNReceiptBase.Table)' (\(MNReceiptPrimaryKey) INTEGER primary key autoincrement, \(columns.compactMap({ $0 + " " + sql(for: $1) }).joined(separator: ", ")));".cString(using: .utf8), nil, nil, nil) == SQLITE_OK {
#if DEBUG
            print("\n已打开内购缓存数据库")
#endif
            return true
        }
#if DEBUG
            print("\n打开内购缓存数据库失败")
#endif
        close()
        return false
    }
    
    /**关闭数据库*/
    private func close() {
        guard let db = db else { return }
        repeat {
            let result = sqlite3_close(db)
            if result == SQLITE_BUSY {
                while let stmt = sqlite3_next_stmt(db, nil) {
                    sqlite3_finalize(stmt)
                }
            } else {
#if DEBUG
                if result == SQLITE_DONE {
                    print("\n已关闭内购缓存数据库")
                } else {
                    print("\n关闭内购缓存数据库失败")
                    if let errmsg = sqlite3_errmsg(db) {
                        let msg = String(cString: errmsg)
                        print(": \(msg)")
                    } else {
                        print(": \(result)")
                    }
                }
#endif
                break
            }
        } while true
        self.db = nil
    }
}
