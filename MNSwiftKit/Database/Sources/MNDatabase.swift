//
//  MNDatabase.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/3/4.
//  数据库解决方案

import Foundation
import AVFoundation
import CoreFoundation
import ObjectiveC.runtime
#if !canImport(SQLCipher)
import SQLite3
#endif

extension Dictionary where Key == String, Value == Any {
    
    /// 转化数据库语句
    public var sql: String { (self as [String:Any?]).sql }
}

extension Dictionary where Key == String, Value == Any? {
    
    /// 转化数据库语句
    fileprivate var sql: String {
        var elements: [String] = [String]()
        for (key, value) in self {
            guard let value = value else {
                elements.append("\(key) = NULL")
                continue
            }
            var string: String = "\(key) = "
            if (value is String || value is NSString) {
                string.append("'\(value)'")
            } else if (value is Int || value is Double || value is CGFloat || value is Float || value is Int64 || value is Int32 || value is Int16 || value is Int8 || value is Float32 || value is Float64) {
                string.append("\(value)")
            } else if value is Bool {
                string.append((value as! Bool) ? "1" : "0")
            } else if value is ObjCBool {
                string.append((value as! ObjCBool).boolValue ? "1" : "0")
            } else if value is NSNumber {
                string.append((value as! NSNumber).stringValue)
            } else if #available(iOS 14.0, *), value is Float16 {
                string.append("\(value)")
            }
            elements.append(string)
        }
        return elements.joined(separator: " AND ")
    }
}

/// 实例化支持
public protocol Initializable {
    
    init()
}

protocol Wrappedable {
    
    static var wrappedType: Any.Type { get }
}

extension Optional: Wrappedable {
    
    static var wrappedType: any Any.Type { Wrapped.self }
}

/// 表结构支持
public protocol TableColumnSupported {
    
    /// 自定义表字段
    static var supportedTableColumns: [String:MNTableColumn.FieldType] { get }
}

/// 绑定值时校验
public protocol TableColumnAssignment {
    
    /// 回调外界绑定值
    /// - Parameters:
    ///   - value: 属性值
    ///   - property: 属性名
    func setValue(_ value: Any, for property: String)
}

fileprivate let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// 表字段
public struct MNTableColumn {
    
    /// 字段类型
    public enum FieldType: String {
        /// 整数
        case integer
        /// 浮点数
        case float
        /// 字符串
        case text
        /// 数据流
        case blob
    }
    
    /// 运算类型
    public enum OperationType: String {
        /// 和
        case sum = "SUM"
        /// 平均值
        case avg = "AVG"
        /// 最小值
        case min = "MIN"
        /// 最大值
        case max = "MAX"
    }
    
    /// 排序方式
    public enum ComparisonResult {
        /// 升序(依据的字段)
        case ascending(_ field: String)
        /// 降序(依据的字段)
        case descending(_ field: String)
        
        /// 数据库语句
        fileprivate var sql: String {
            switch self {
            case .ascending(let field):
                return "ORDER BY \(field) ASC"
            case .descending(let field):
                return "ORDER BY \(field) DESC"
            }
        }
    }
    
    /// 匹配规则
    public enum MatchType {
        /// 指定开始(字段, 指定字符串, 其后限制字数<默认不限制>, 转义符<默认`\`>)
        case prefix(_ field: String, _ content: String, _ count: Int = 0, _ escape: String = "\\")
        /// 指定结尾(字段, 指定字符串, 其前限制字数<默认不限制>, 转义符<默认`\`>)
        case suffix(_ field: String, _ content: String, _ count: Int = 0, _ escape: String = "\\")
        /// 包含某字符串(字段, 指定字符串, 转义符<默认`\`>)
        case contains(_ field: String, _ content: String, _ escape: String = "\\")
        
        /// 数据库语句
        fileprivate var sql: String {
            var string: String = ""
            switch self {
            case .prefix(let field, var keyword, let count, var escapeChar):
                if field.isEmpty || keyword.isEmpty { break }
                if keyword.contains("%") || keyword.contains("_") {
                    if #available(iOS 16.0, *) {
                        keyword.replace("%", with: "\(escapeChar)%")
                        keyword.replace("_", with: "\(escapeChar)_")
                    } else {
                        keyword = keyword.replacingOccurrences(of: "%", with: "\(escapeChar)%")
                        keyword = keyword.replacingOccurrences(of: "_", with: "\(escapeChar)_")
                    }
                } else {
                    escapeChar.removeAll()
                }
                // 字数限制
                let placeholder: String = String(repeating: "_", count: max(0, count))
                // 拼接语句
                string.append("\(field) LIKE ")
                string.append("'\(keyword)\(placeholder.isEmpty ? "%" : placeholder)'")
                if escapeChar.isEmpty == false {
                    string.append(" ESCAPE '\(escapeChar)'")
                }
            case .suffix(let field, var keyword, let count, var escapeChar):
                if field.isEmpty || keyword.isEmpty { break }
                if keyword.contains("%") || keyword.contains("_") {
                    if #available(iOS 16.0, *) {
                        keyword.replace("%", with: "\(escapeChar)%")
                        keyword.replace("_", with: "\(escapeChar)_")
                    } else {
                        keyword = keyword.replacingOccurrences(of: "%", with: "\(escapeChar)%")
                        keyword = keyword.replacingOccurrences(of: "_", with: "\(escapeChar)_")
                    }
                } else {
                    escapeChar.removeAll()
                }
                // 字数限制
                let placeholder: String = String(repeating: "_", count: max(0, count))
                // 拼接语句
                string.append("\(field) LIKE ")
                string.append("'\(placeholder.isEmpty ? "%" : placeholder)\(keyword)'")
                if escapeChar.isEmpty == false {
                    string.append(" ESCAPE '\(escapeChar)'")
                }
            case .contains(let field, var keyword, var escapeChar):
                if field.isEmpty || keyword.isEmpty { break }
                if keyword.contains("%") || keyword.contains("_") {
                    if #available(iOS 16.0, *) {
                        keyword.replace("%", with: "\(escapeChar)%")
                        keyword.replace("_", with: "\(escapeChar)_")
                    } else {
                        keyword = keyword.replacingOccurrences(of: "%", with: "\(escapeChar)%")
                        keyword = keyword.replacingOccurrences(of: "_", with: "\(escapeChar)_")
                    }
                } else {
                    escapeChar.removeAll()
                }
                // 拼接语句
                string.append("\(field) LIKE ")
                string.append("'%\(keyword)%'")
                if escapeChar.isEmpty == false {
                    string.append(" ESCAPE '\(escapeChar)'")
                }
            }
            return string
        }
    }
    
    /// 自增主键
    fileprivate static let PrimaryKey: String = "id"
    /// 字段名
    public let name: String
    /// 类型
    public let type: FieldType
    /// 建表语句
    fileprivate var sql: String {
        var sql: String = name + " " + type.rawValue.uppercased()
        switch type {
        case .integer:
            sql.append(" NOT NULL DEFAULT 0")
        case .float:
            sql.append(" NOT NULL DEFAULT 0.0")
        case .text:
            sql.append(" NOT NULL DEFAULT ''")
        default: break
        }
        return sql
    }
    /// 默认值
    fileprivate var defaultValue: Any {
        switch type {
        case .integer:
            return 0
        case .float:
            return 0.0
        case .text:
            return ""
        case .blob:
            return Data()
        }
    }
    
    /// 构造器
    /// - Parameters:
    ///   - name: 字段名
    ///   - type: 字段类型
    public init(name: String, type: FieldType) {
        self.type = type
        self.name = name
    }
}

extension MNTableColumn: Hashable {}

extension MNTableColumn: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}

/// SQLite3数据库支持方案
public class MNDatabase {
    /// 异步操作结果回调
    public typealias CompletionHandler = (_ isSuccess: Bool)->Void
    /// 默认数据库名
    public static var name: String { "database" }
    /// 默认后缀
    public static var `extension`: String { "sqlite" }
    /// 快速构造入口
    nonisolated(unsafe) public static let `default` = MNDatabase()
    /// 信号量加锁保证线程安全
    private let semaphore = DispatchSemaphore(value: 1)
    /// 数据操作队列
    private let queue = DispatchQueue(label: "com.mn.database.queue", attributes: .concurrent)
    /// 打开数据库时查询存在的表
    private var searchExistTable = true
    /// 数据库路径
    public let path: String
    /// 数据库
    private var db: OpaquePointer?
    /// 表名
    private var tables = [String]()
    /// 句柄
    private var stmts = [String:OpaquePointer]()
    /// 表字段
    private var tableColumns = [String:[MNTableColumn]]()
    /// 类字段缓存
    private var classColumns = [String:[MNTableColumn]]()
    /// 默认路径
    public static var Path: String {
        let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return "\(documentPath)/\(MNDatabase.name).\(MNDatabase.extension)"
    }
    
    /// 指定初始化器
    /// - Parameter path: 数据库路径
    public init(path: String = MNDatabase.Path) {
        self.path = path
        if FileManager.default.fileExists(atPath: path) == false {
            do {
                try FileManager.default.createDirectory(at: URL(fileURLWithPath: path).deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            } catch {
#if DEBUG
                print("\n======create database directory failed======\n\(error)\n===============================")
#endif
            }
        }
#if DEBUG
        print("\n===============数据库路径===============\n\(path)\n======================================")
#endif
    }
}

// MARK: - 打开/关闭
extension MNDatabase {
    
    /// 打开数据库
    /// - Returns: 是否打开数据库
    @discardableResult
    public func `open`() -> Bool {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        guard opendb() else { return false }
        guard searchExistTable else { return true }
        tables.removeAll()
        // 加载表
        var stmt: OpaquePointer!
        let sql: String = "select name from sqlite_master where type = 'table';"
        if sqlite3_prepare_v2(db, sql.cString(using: .utf8), -1, &stmt, nil) == SQLITE_OK {
            searchExistTable = false
            repeat {
                let result = sqlite3_step(stmt)
                if result == SQLITE_ROW {
                    guard let value = sqlite3_column_text(stmt, 0) else { continue }
                    let name: String = String(cString: value)
                    tables.append(name)
                } else {
                    if result != SQLITE_DONE {
                        tables.removeAll()
                        searchExistTable = true
#if DEBUG
                        print("\n[\(#line)] sql <\(sql)> failed (\(result))")
                        if let errmsg = sqlite3_errmsg(db) {
                            let msg = String(cString: errmsg)
                            print(": \(msg)")
                        }
#endif
                    }
                    break
                }
            } while true
            sqlite3_finalize(stmt)
            stmt = nil
        } else {
#if DEBUG
            print("\n[\(#line)] load table name failed.")
#endif
            closedb()
        }
        return db != nil
    }
    
    /// 关闭数据库
    public func close() {
        semaphore.wait()
        closedb()
        stmts.removeAll()
        tables.removeAll()
        searchExistTable = true
        semaphore.signal()
    }
}

// MARK: - 创建表
extension MNDatabase {
    
    /// 创建表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - type: 建表参照类
    ///   - ordered: 字段排序类型 自增键固定第一列 其它默认升序排列
    /// - Returns: 是否创建成功
    @discardableResult
    public func create<T>(table tableName: String, using type: T.Type, ordered: Foundation.ComparisonResult = .orderedAscending) -> Bool where T: Initializable {
        create(table: tableName, using: columns(for: type), ordered: ordered)
    }
    
    /// 异步创建表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - type: 建表参照类
    ///   - ordered: 字段排序类型 自增键固定第一列 其它默认升序排列
    ///   - queue: 使用的队列
    ///   - completionHandler: 结束回调
    public func create<T>(table tableName: String, using type: T.Type, ordered: Foundation.ComparisonResult = .orderedAscending, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) where T: Initializable {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.create(table: tableName, using: type, ordered: ordered)
            completionHandler?(result)
        }
    }
    
    /// 创建表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 字段集合
    ///   - ordered: 字段排序类型 自增键固定第一列 其它默认升序排列
    /// - Returns: 是否创建成功
    @discardableResult
    public func create(table tableName: String, using columns: [String:MNTableColumn.FieldType], ordered: Foundation.ComparisonResult = .orderedAscending) -> Bool {
        create(table: tableName, using: columns.compactMap({ MNTableColumn(name: $0.key, type: $0.value)}), ordered: ordered)
    }
    
    /// 异步创建表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 字段集合
    ///   - ordered: 字段排序类型 自增键固定第一列 其它默认升序排列
    ///   - queue: 使用的队列
    ///   - completionHandler: 结果回调
    public func create(table tableName: String, using columns: [String:MNTableColumn.FieldType], ordered: Foundation.ComparisonResult = .orderedAscending, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.create(table: tableName, using: columns, ordered: ordered)
            completionHandler?(result)
        }
    }
    
    /// 创建表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 表字段
    ///   - ordered: 字段排序类型 自增键固定第一列 其它默认升序排列
    /// - Returns: 是否创建成功
    @discardableResult
    public func create(table tableName: String, using columns: [MNTableColumn], ordered: Foundation.ComparisonResult = .orderedAscending) -> Bool {
        guard tableName.isEmpty == false, columns.isEmpty == false else { return false }
        guard open() else { return false }
        guard exists(table:tableName) == false else { return true }
        // 去重
        var columns = columns.reduce([MNTableColumn]()) { $0.contains($1) ? $0 : $0 + [$1] }
        // 去除自增键
        columns.removeAll { $0.name.lowercased() == MNTableColumn.PrimaryKey }
        guard columns.isEmpty == false else { return false }
        // 排序
        if ordered == .orderedAscending || ordered == .orderedDescending {
            columns.sort { $0.name.localizedCompare($1.name) == ordered }
        }
        var elements: [String] = columns.compactMap { $0.sql }
        elements.insert("\(MNTableColumn.PrimaryKey) \(MNTableColumn.FieldType.integer.rawValue) PRIMARY KEY AUTOINCREMENT NOT NULL DEFAULT 0", at: 0)
        let sql: String = "CREATE TABLE IF NOT EXISTS '\(tableName)' (\(elements.joined(separator: ", ")));"
        semaphore.wait()
        let result: Bool = execute(sql)
        if result {
            tables.append(tableName)
        }
        semaphore.signal()
        return result
    }
    
    /// 异步创建表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 字段集合
    ///   - ordered: 字段排序类型 自增键固定第一列 其它默认升序排列
    ///   - queue: 使用的队列
    ///   - completionHandler: 结束回调
    public func createTable(table tableName: String, using columns: [MNTableColumn], ordered: Foundation.ComparisonResult = .orderedAscending, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.create(table: tableName, using: columns, ordered: ordered)
            completionHandler?(result)
        }
    }
}

// MARK: - 删除表&数据
extension MNDatabase {
    
    /// 删除表
    /// - Parameter tableName: 表名
    /// - Returns: 是否删除成功
    @discardableResult
    public func delete(table tableName: String) -> Bool {
        guard tableName.isEmpty == false else { return false }
        guard open() else { return false }
        let sql: String = "DROP TABLE IF EXISTS '\(tableName)';"
        semaphore.wait()
        let result = execute(sql)
        if result {
            tables.removeAll { $0 == tableName }
        }
        semaphore.signal()
        return result
    }
    
    /// 删除表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - queue: 使用的队列
    ///   - completionHandler: 结束回调
    public func delete(table tableName: String, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.delete(table: tableName)
            completionHandler?(result)
        }
    }
    
    /// 删除表中数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    /// - Returns: 执行结果
    @discardableResult
    public func delete(from tableName: String, where condition: String? = nil) -> Bool {
        guard exists(table:tableName) else { return false }
        var sql: String = "DELETE FROM '\(tableName)'"
        if let string = condition, string.isEmpty == false {
            sql.append(contentsOf: " WHERE \(string)")
        }
        sql.append(contentsOf: ";")
        semaphore.wait()
        let result = execute(sql)
        semaphore.signal()
        return result
    }
    
    /// 异步删除表中数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    ///   - queue: 使用队列
    ///   - completionHandler: 结果回调
    public func delete(from tableName: String, where condition: String? = nil, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.delete(from: tableName, where: condition)
            completionHandler?(result)
        }
    }
}

// MARK: - 插入数据
extension MNDatabase {
    
    /// 插入数据模型
    /// - Parameters:
    ///   - tableName: 表名
    ///   - model: 数据模型
    /// - Returns: 是否插入成功
    @discardableResult
    public func insert<T>(into tableName: String, using model: T) -> Bool where T: Initializable {
        return insert(into: tableName, using: field(for: model))
    }
    
    /// 异步插入数据模型
    /// - Parameters:
    ///   - tableName: 表名
    ///   - model: 数据模型
    ///   - queue: 使用队列
    ///   - completionHandler: 结束回调
    public func insert<T>(into tableName: String, using model: T, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) where T: Initializable {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.insert(into: tableName, using: model)
            completionHandler?(result)
        }
    }
    
    /// 插入数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - fields: 字段集合
    /// - Returns: 是否插入成功
    @discardableResult
    public func insert(into tableName: String, using fields: [String:Any]) -> Bool {
        guard fields.isEmpty == false else { return false }
        guard exists(table:tableName) else { return false }
        let tableColumns = columns(in: tableName)
        var contents: [(MNTableColumn, Any)] = [(MNTableColumn, Any)]()
        for (key, value) in fields {
            if key.lowercased() == MNTableColumn.PrimaryKey { continue }
            guard let first = tableColumns.first(where: { $0.name == key }) else { continue }
            switch value {
            case Optional<Any>.none:
                contents.append((first, first.defaultValue))
            default:
                contents.append((first, value))
            }
        }
        guard contents.isEmpty == false else { return false }
        var values = [String]()
        for index in 0..<contents.count {
            values.append("?\(index + 1)")
        }
        let params = contents.compactMap { $0.0.name }
        let sql = "INSERT INTO '\(tableName)' (\(params.joined(separator: ","))) VALUES (\(values.joined(separator: ",")));"
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        guard let stmt = stmt(sql) else { return false }
        guard bind(stmt, contents: contents) else {
#if DEBUG
            print("\n[\(#line)] sql <\(sql)> bind data failed.")
#endif
            return false
        }
        let result = sqlite3_step(stmt)
        guard result == SQLITE_DONE else {
#if DEBUG
            print("\n[\(#line)] sql <\(sql)> failed (\(result))")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            }
#endif
            return false
        }
        return true
    }
    
    /// 异步插入数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - fields: 字段数据集合
    ///   - queue: 使用队列
    ///   - completionHandler: 结束回调
    public func insert(into tableName: String, using fields: [String:Any], queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.insert(into: tableName, using: fields)
            completionHandler?(result)
        }
    }
    
    /// 插入多条数据模型
    /// - Parameters:
    ///   - tableName: 表名
    ///   - models: 数据模型集合
    /// - Returns: 是否插入成功
    @discardableResult
    public func insert<T>(into tableName: String, using models: [T]) -> Bool where T: Initializable {
        insert(into: tableName, using: models.compactMap({ field(for: $0) }))
    }
    
    /// 异步插入多条数据模型
    /// - Parameters:
    ///   - tableName: 表名
    ///   - models: 数据模型集合
    ///   - queue: 使用队列
    ///   - completionHandler: 结束回调
    public func insert<T>(into tableName: String, using models: [T], queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) where T: Initializable {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.insert(into: tableName, using: models)
            completionHandler?(result)
        }
    }
    
    /// 插入多条数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - array: 字段集合
    /// - Returns: 是否插入成功
    @discardableResult
    public func insert(into tableName: String, using array: [[String:Any]]) -> Bool {
        guard array.isEmpty == false else { return false }
        guard exists(table:tableName) else { return false }
        let tableColumns = columns(in: tableName)
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        guard begin() else { return false }
        var contents: [(MNTableColumn, Any)] = [(MNTableColumn, Any)]()
        for fields in array {
            for (key, value) in fields {
                if key.lowercased() == MNTableColumn.PrimaryKey { continue }
                guard let first = tableColumns.first(where: { $0.name == key }) else { continue }
                switch value {
                case Optional<Any>.none:
                    contents.append((first, first.defaultValue))
                default:
                    contents.append((first, value))
                }
            }
            guard contents.isEmpty == false else {
                rollback()
                return false
            }
            var values = [String]()
            for index in 0..<contents.count {
                values.append("?\(index + 1)")
            }
            let params = contents.compactMap { $0.0.name }
            let sql = "INSERT INTO '\(tableName)' (\(params.joined(separator: ","))) VALUES (\(values.joined(separator: ",")));"
            guard let stmt = stmt(sql) else {
                rollback()
                return false
            }
            guard bind(stmt, contents: contents) else {
#if DEBUG
                print("\n[\(#line)] sql <\(sql)> bind data failed.")
#endif
                rollback()
                return false
            }
            let result = sqlite3_step(stmt)
            guard result == SQLITE_DONE else {
#if DEBUG
                print("\n[\(#line)] sql <\(sql)> failed (\(result))")
                if let errmsg = sqlite3_errmsg(db) {
                    let msg = String(cString: errmsg)
                    print(": \(msg)")
                }
#endif
                rollback()
                return false
            }
            // 清空容器
            contents.removeAll()
        }
        commit()
        return true
    }
    
    /// 异步插入多条数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - array: 字段数据集合
    ///   - queue: 使用队列
    ///   - completionHandler: 结束回调
    public func insert(into tableName: String, using array: [[String:Any]], queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.insert(into: tableName, using: array)
            completionHandler?(result)
        }
    }
    
    /// 从指定表中导入数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - otherTableName: 指定表
    /// - Returns: 是否执行成功
    @discardableResult
    public func insert(into tableName: String, from otherTableName: String) -> Bool {
        guard exists(table:tableName), exists(table:otherTableName) else { return false }
        let sql: String = "REPLACE INTO '\(tableName)' SELECT * FROM '\(otherTableName)';"
        semaphore.wait()
        let result = execute(sql)
        semaphore.signal()
        return result
    }
    
    /// 异步从指定表中导入数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - fromTableName: 指定表
    ///   - queue: 使用队列
    ///   - completionHandler: 结束回调
    public func insert(into tableName: String, from fromTableName: String, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.insert(into: tableName, from: fromTableName)
            completionHandler?(result)
        }
    }
}

// MARK: - 更新数据
extension MNDatabase {
    
    /// 更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件(nil则更新全部内容)
    ///   - fields: 更新内容[字段:值]
    /// - Returns: 是否更新成功
    @discardableResult
    public func update(_ tableName: String, where condition: String? = nil, using fields: [String:Any]) -> Bool {
        guard fields.isEmpty == false else { return false }
        guard exists(table:tableName) else { return false }
        let tableColumns = columns(in: tableName)
        var contents: [(MNTableColumn, Any)] = [(MNTableColumn, Any)]()
        for (key, value) in fields {
            if key.lowercased() == MNTableColumn.PrimaryKey { continue }
            guard let first = tableColumns.first(where: { $0.name == key }) else { continue }
            switch value {
            case Optional<Any>.none:
                contents.append((first, first.defaultValue))
            default:
                contents.append((first, value))
            }
        }
        guard contents.isEmpty == false else { return false }
        var params = [String]()
        for (index, content) in contents.enumerated() {
            params.append("\(content.0.name)=?\(index + 1)")
        }
        var sql: String = "UPDATE '\(tableName)' SET \(params.joined(separator: ","))"
        if let string = condition, string.isEmpty == false {
            sql.append(" WHERE \(string)")
        }
        sql.append(";")
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        guard let stmt = stmt(sql) else { return false }
        guard bind(stmt, contents: contents) else {
#if DEBUG
            print("\n[\(#line)] sql <\(sql)> bind data faild.")
#endif
            return false
        }
        let result = sqlite3_step(stmt)
        guard result == SQLITE_DONE else {
#if DEBUG
            print("\n[\(#line)] sql <\(sql)> faild (\(result))")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            }
#endif
            return false
        }
        return true
    }
    
    /// 异步更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    ///   - fields: 更新内容[字段:值]
    ///   - queue: 使用队列
    ///   - completionHandler: 结果回调
    public func update(_ tableName: String, where condition: String? = nil, using fields: [String:Any], queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.update(tableName, where: condition, using: fields)
            completionHandler?(result)
        }
    }
    
    /// 更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    ///   - model: 数据模型
    /// - Returns: 是否更新成功
    @discardableResult
    public func update<T>(_ tableName: String, where condition: String? = nil, using model: T) -> Bool where T: Initializable {
        return update(tableName, where: condition, using: field(for: model))
    }
    
    /// 异步更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    ///   - model: 数据模型
    ///   - queue: 使用队列
    ///   - completionHandler: 结果回调
    public func update<T>(_ tableName: String, where condition: String? = nil, using model: T, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) where T: Initializable {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.update(tableName, where: condition, using: model)
            completionHandler?(result)
        }
    }
    
    /// 更新表名
    /// - Parameters:
    ///   - tableName: 原表名
    ///   - name: 新表名
    /// - Returns: 是否更新成功
    @discardableResult
    public func update(_ tableName: String, name: String) -> Bool {
        guard name.isEmpty == false else { return false }
        guard exists(table:tableName), exists(table:name) == false else { return false }
        let sql: String = "ALTER TABLE '\(tableName)' RENAME TO '\(name)';"
        semaphore.wait()
        let result = execute(sql)
        if result {
            tables.removeAll { $0 == tableName }
            tables.append(name)
        }
        semaphore.signal()
        return result
    }
    
    /// 异步更新表名
    /// - Parameters:
    ///   - tableName: 原表名
    ///   - name: 新表名
    ///   - queue: 使用的队列
    ///   - completionHandler: 结果回调
    public func update(_ tableName: String, name: String, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.update(tableName, name: name)
            completionHandler?(result)
        }
    }
    
    /// 更新表字段
    /// - Parameters:
    ///   - tableName: 表名
    ///   - type: 模型类
    /// - Returns: 是否更新成功
    @discardableResult
    public func update<T>(_ tableName: String, using type: T.Type) -> Bool where T: Initializable {
        guard exists(table: tableName) else { return false }
        // 类支持的字段
        let clsColumns = columns(for: type)
        guard clsColumns.isEmpty == false else { return false }
        // 表现在存在的字段
        let tabColumns = columns(in: tableName)
        // 需要增加字段
        let adds = Set(clsColumns).subtracting(Set(tabColumns)).map { $0 }
        // 需要删除的字段
        var removes = Set(tabColumns).subtracting(Set(clsColumns)).map { $0 }
        removes.removeAll { $0.name.lowercased() == MNTableColumn.PrimaryKey }
        guard adds.count + removes.count > 0 else { return true }
        var isSuccess: Bool = true
        semaphore.wait()
        begin()
        defer {
            if isSuccess {
                commit()
            } else {
                rollback()
            }
            semaphore.signal()
        }
        for column in adds {
            let sql = "ALTER TABLE '\(tableName)' ADD COLUMN \(column.sql);"
            guard execute(sql) else {
                isSuccess = false
                break
            }
        }
        guard isSuccess else { return false }
        for column in removes {
            let sql = "ALTER TABLE '\(tableName)' DROP COLUMN \(column.name);"
            guard execute(sql) else {
                isSuccess = false
                break
            }
        }
        // 删除字段缓存 下次使用再次获取
        tableColumns.removeValue(forKey: tableName)
        return true
    }
    
    /// 异步更新表字段
    /// - Parameters:
    ///   - tableName: 表名
    ///   - type: 表参照类
    ///   - queue: 使用的队列
    ///   - completionHandler: 回调
    public func update<T>(_ tableName: String, using type: T.Type, queue: DispatchQueue? = nil, completion completionHandler: CompletionHandler?) where T: Initializable {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.update(tableName, using: type)
            completionHandler?(result)
        }
    }
}

// MARK: - 查询数据
extension MNDatabase {
    
    /// 查询数量
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    /// - Returns: 结束回调
    public func selectCount(from tableName: String, where condition: String? = nil) -> Int? {
        guard exists(table: tableName) else { return nil }
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        // 将*替换为数字(比如1), 这种写法更高效更简洁, 因为它只关心存在与否不关心数据, 只扫描符合条件的行而不关心列的数据
        var sql: String = "SELECT COUNT(1) FROM '\(tableName)'"
        if let condition = condition, condition.isEmpty == false {
            sql.append(" WHERE \(condition)")
        }
        sql.append(";")
        guard let stmt = stmt(sql) else { return nil }
        var count: Int? = nil
        let result = sqlite3_step(stmt)
        if result == SQLITE_ROW {
            count = Int(sqlite3_column_int(stmt, 0))
        } else {
#if DEBUG
            print("\n[\(#line)] sql <\(sql)> failed (\(result))")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            }
#endif
        }
        return count
    }
    
    /// 异步查询数量
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    ///   - queue: 使用队列
    ///   - completionHandler: 结果回调
    public func selectCount(from tableName: String, where condition: String? = nil, queue: DispatchQueue? = nil, completion completionHandler: ((_ count: Int?)->Void)?) {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.selectCount(from: tableName, where: condition)
            completionHandler?(result)
        }
    }
    
    /// 计算极限值
    /// - Parameters:
    ///   - tableName: 表名
    ///   - field: 字段名
    ///   - condition: 限制条件
    ///   - operator: 运算符
    ///   - defaultValue: 若查询不到符合条件的数据, 则使用默认值
    public func selectFinite<T>(from tableName: String, field: String, where condition: String? = nil, operation operator: MNTableColumn.OperationType, default defaultValue: T) -> T? where T: Comparable {
        guard field.isEmpty == false else { return nil }
        guard exists(table: tableName) else { return nil }
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        var sql: String = "SELECT \(`operator`.rawValue)(\(field)) FROM '\(tableName)'"
        if let condition = condition, condition.isEmpty == false {
            sql.append(" WHERE \(condition)")
        }
        sql.append(";")
        guard let stmt = stmt(sql) else { return nil }
        var value: Any?
        let result = sqlite3_step(stmt)
        if result == SQLITE_ROW {
            let type = sqlite3_column_type(stmt, 0)
            switch type {
            case SQLITE_INTEGER:
                value = sqlite3_column_int64(stmt, 0)
            case SQLITE_FLOAT:
                value = sqlite3_column_double(stmt, 0)
            case SQLITE_TEXT, SQLITE3_TEXT:
                if let text = sqlite3_column_text(stmt, 0) {
                    value = String(cString: text)
                }
            case SQLITE_BLOB:
                if let bytes = sqlite3_column_blob(stmt, 0) {
                    let count = sqlite3_column_bytes(stmt, 0)
                    value = Data(bytes: bytes, count: Int(count))
                }
            case SQLITE_NULL:
                // 没有符合条件的数据会出现NULL
                value = defaultValue
            default:
#if DEBUG
                print("\n[\(#line)] sql <\(sql)> column type unknown (\(type)).")
#endif
            }
        } else {
#if DEBUG
            print("\n[\(#line)] sql <\(sql)> failed (\(result))")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            }
#endif
        }
        if let value = value, Swift.type(of: value) == Swift.type(of: defaultValue) {
            return value as? T
        }
        return nil
    }
    
    /// 计算极限值
    /// - Parameters:
    ///   - tableName: 表名
    ///   - field: 表字段
    ///   - condition: 限制条件
    ///   - operator: 运算符
    ///   - type: 返回类型
    ///   - queue: 执行队列
    ///   - completionHandler: 回调结果
    public func selectFinite<T>(from tableName: String, field: String, where condition: String? = nil, operation operator: MNTableColumn.OperationType, default defaultValue: T, queue: DispatchQueue? = nil, completion completionHandler: ((_ result: T?)->Void)?) where T: Comparable {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.selectFinite(from: tableName, field: field, where: condition, operation: `operator`, default: defaultValue)
            completionHandler?(result)
        }
    }
    
    /// 查询符合条件的数据模型
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    ///   - ordered: 排序方式
    ///   - range: 数量限制
    ///   - type: 数据模型的类型
    /// - Returns: 数据模型集合
    public func selectRows<T>(from tableName: String, where condition: String? = nil, regular: MNTableColumn.MatchType? = nil, ordered: MNTableColumn.ComparisonResult? = nil, limit range: NSRange? = nil, type: T.Type) -> [T]? where T: Initializable {
        let columns = columns(for: type)
        guard columns.isEmpty == false else { return nil }
        guard let rows = selectRows(tableName, where: condition, regular: regular, ordered: ordered, limit: range) else { return nil }
        return rows.compactMap { row in
            let model = T.init()
            if model is TableColumnAssignment {
                let delegate = model as! TableColumnAssignment
                for (field, value) in row {
                    delegate.setValue(value, for: field)
                }
                return model
            }
            if model is NSObject {
                let obj = model as! NSObject
                for (field, value) in row {
                    obj.setValue(value, forKey: field)
                }
                return model
            }
            return nil
        }
    }
    
    /// 异步查询符合条件的数据模型
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    ///   - ordered: 排序方式
    ///   - range: 数量限制
    ///   - type: 数据模型的类型
    ///   - queue: 使用队列
    ///   - completionHandler: 结果回调
    public func selectRows<T>(from tableName: String, where condition: String? = nil, regular: MNTableColumn.MatchType? = nil, ordered: MNTableColumn.ComparisonResult? = nil, limit range: NSRange? = nil, type: T.Type, queue: DispatchQueue? = nil, completion completionHandler: ((_ rows: [T]?)->Void)?) where T: Initializable {
        (queue ?? self.queue).async { [weak self] in
            guard let self = self else { return }
            let result = self.selectRows(from: tableName, where: condition, regular: regular, ordered: ordered, limit: range, type: type)
            completionHandler?(result)
        }
    }
    
    /// 查询符合条件的数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 条件
    ///   - ordered: 排序方式
    ///   - range: 数量限制
    /// - Returns: 数据集合
    private func selectRows(_ tableName: String, where condition: String? = nil, regular: MNTableColumn.MatchType? = nil, ordered: MNTableColumn.ComparisonResult? = nil, limit range: NSRange? = nil) -> [[String:Any]]? {
        guard exists(table: tableName) else { return nil }
        /*
        let columns = columns(from: tableName)
        guard columns.count > 0 else { return nil }
        let fields: [String] = columns.compactMap { $0.name }
        \(fields.joined(separator: ", "))
        */
        // 这里不再指定字段, 全部取出
        var sql: String = "SELECT * FROM '\(tableName)'"
        var string: String = ""
        if let condition = condition, condition.isEmpty == false {
            string.append(" WHERE \(condition)")
        }
        if let regular = regular?.sql, regular.isEmpty == false {
            string.append(string.isEmpty ? " WHERE " : " AND ")
            string.append(regular)
        }
        if string.isEmpty == false {
            sql.append(string)
        }
        if let string = ordered?.sql {
            sql.append(" \(string)")
        }
        if let range = range, range.length > 0 {
            // location = 0 可以省略
            if range.location > 0 {
                sql.append(" LIMIT \(range.location), \(range.length)")
            } else {
                sql.append(" LIMIT \(range.length)")
            }
        }
        sql.append(";")
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        guard let stmt = stmt(sql: sql) else { return nil }
        var rows: [[String:Any]]! = [[String:Any]]()
        repeat {
            let result = sqlite3_step(stmt)
            if result == SQLITE_ROW {
                // 取值
                var value: Any!
                var row: [String:Any] = [String:Any]()
                let count = sqlite3_column_count(stmt)
                for index in 0..<count {
                    // 确定字段以及类型
                    guard let cName = sqlite3_column_name(stmt, index) else { continue }
                    let name = String(cString: cName)
                    if name == MNTableColumn.PrimaryKey { continue }
                    /*
                    let cType = sqlite3_column_decltype(stmt, index)
                    let type = String(cString: cType)
                    */
                    let type = sqlite3_column_type(stmt, index)
                    switch type {
                    case SQLITE_INTEGER:
                        value = Int(sqlite3_column_int64(stmt, Int32(index)))
                    case SQLITE_FLOAT:
                        value = sqlite3_column_double(stmt, Int32(index))
                    case SQLITE_TEXT, SQLITE3_TEXT:
                        if let text = sqlite3_column_text(stmt, Int32(index)) {
                            value = String(cString: text)
                        } else {
                            value = ""
                        }
                    case SQLITE_BLOB:
                        if let bytes = sqlite3_column_blob(stmt, Int32(index)) {
                            let count = sqlite3_column_bytes(stmt, Int32(index))
                            value = Data(bytes: bytes, count: Int(count))
                        } else {
                            value = Data()
                        }
                    default: continue
                    }
                    row[name] = value
                }
                rows.append(row)
            } else {
                // 失败
                if result != SQLITE_DONE {
                    rows = nil
#if DEBUG
                    print("\n[\(#line)] sql <\(sql)> failed (\(result))")
                    if let errmsg = sqlite3_errmsg(db) {
                        let msg = String(cString: errmsg)
                        print(": \(msg)")
                    }
#endif
                }
                break
            }
        } while true
        sqlite3_finalize(stmt)
        return rows
    }
}

// MARK: - 数据库
extension MNDatabase {
    
    /// 开启数据库
    /// - Returns: 是否开启成功
    fileprivate func opendb() -> Bool {
        if let _ = db { return true }
        let result: Int32 = sqlite3_open(path.cString(using: .utf8), &db)
        guard result == SQLITE_OK else {
#if DEBUG
            print("\n[\(#line)] open db failed (\(result))")
            if let errmsg = sqlite3_errmsg(db) {
                let msg: String = String(cString: errmsg)
                print(": \(msg)")
            }
#endif
            return false
        }
        return true
    }
    
    /// 关闭数据库
    fileprivate func closedb() {
        guard let db = db else { return }
        repeat {
            let result = sqlite3_close(db)
            if result == SQLITE_BUSY {
                while let stmt = sqlite3_next_stmt(db, nil) {
                    sqlite3_finalize(stmt)
                }
            } else {
                if result != SQLITE_OK {
#if DEBUG
                    print("\n[\(#line)] close db failed (\(result))")
                    if let errmsg = sqlite3_errmsg(db) {
                        let msg: String = String(cString: errmsg)
                        print(": \(msg)")
                    }
#endif
                }
                break
            }
        } while true
        self.db = nil
    }
    
    /// 开始事务
    /// - Returns: 是否开启成功
    @discardableResult
    fileprivate func begin() -> Bool {
        execute("BEGIN TRANSACTION;")
    }
    
    /// 提交任务
    /// - Returns: 是否提交成功
    @discardableResult
    fileprivate func commit() -> Bool {
        execute("COMMIT TRANSACTION;")
    }
    
    /// 回滚任务
    /// - Returns: 是否回滚成功
    @discardableResult
    fileprivate func rollback() -> Bool {
        execute("ROLLBACK TRANSACTION;")
    }
    
    /// 执行语句
    /// - Parameter sql: 语句
    /// - Returns: 是否执行成功
    @discardableResult
    fileprivate func execute(_ sql: String) -> Bool {
        guard let db = db else { return false }
        let result = sqlite3_exec(db, sql.cString(using: .utf8), nil, nil, nil)
        guard result == SQLITE_OK else {
#if DEBUG
            print("\n[\(#line)] sql <\(sql)> failed (\(result))")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            }
#endif
            return false
        }
        return true
    }
    
    /// 获取缓存句柄没有就创建并缓存
    /// - Parameter sql: 数据库语句
    /// - Returns: 句柄
    fileprivate func stmt(_ sql: String) -> OpaquePointer? {
        if let stmt = stmts[sql] {
            sqlite3_reset(stmt)
            return stmt
        }
        if let stmt = stmt(sql: sql) {
            stmts[sql] = stmt
            return stmt
        }
        return nil
    }
    
    /// 创建句柄
    /// - Parameter sql: 数据库语句
    /// - Returns: 句柄
    fileprivate func stmt(sql: String) -> OpaquePointer? {
        var stmt: OpaquePointer?
        let result = sqlite3_prepare_v2(db, sql.cString(using: .utf8), -1, &stmt, nil)
        if result != SQLITE_OK {
#if DEBUG
            print("\n[\(#line)] prepare '\(sql)' failed (\(result))")
            if let errmsg = sqlite3_errmsg(db) {
                let msg = String(cString: errmsg)
                print(": \(msg)")
            }
#endif
        }
        return stmt
    }
}

// MARK: - 辅助
extension MNDatabase {
    
    /// 是否存在表
    /// - Parameter tableName: 表名
    /// - Returns: 是否存在表
    public func exists(table tableName: String) -> Bool {
        guard open() else { return false }
        semaphore.wait()
        let result: Bool = tables.contains(tableName)
        semaphore.signal()
        return result
    }
    
    /// 获取表字段信息
    /// - Parameter tableName: 表名
    /// - Returns: 表字段集合
    public func columns(in tableName: String) -> [MNTableColumn] {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        // 先取缓存字段
        if let columns = tableColumns[tableName] { return columns }
        // 查找数据库字段
        var stmt: OpaquePointer?
        var columns = [MNTableColumn]()
        let sql: String = "pragma table_info ('\(tableName)');"
        if sqlite3_prepare_v2(db, sql.cString(using: .utf8), -1, &stmt, nil) == SQLITE_OK {
            repeat {
                let result = sqlite3_step(stmt)
                if result == SQLITE_ROW {
                    guard let cName = sqlite3_column_text(stmt, 1), let cType = sqlite3_column_text(stmt, 2) else { continue }
                    guard let type = MNTableColumn.FieldType(rawValue: String(cString: cType).lowercased()) else { continue }
                    let name = String(cString: cName)
                    if name.lowercased() == MNTableColumn.PrimaryKey { continue }
                    columns.append(MNTableColumn(name: name, type: type))
                } else {
                    // 结束
                    if result != SQLITE_DONE {
                        columns.removeAll()
#if DEBUG
                        print("\n[\(#line)] sql <\(sql)> failed (\(result))")
                        if let errmsg = sqlite3_errmsg(db) {
                            let msg = String(cString: errmsg)
                            print(": \(msg)")
                        }
#endif
                    }
                    break
                }
            } while true
            sqlite3_finalize(stmt)
            if columns.isEmpty == false {
                tableColumns[tableName] = columns
            }
        }
        return columns
    }
    
    /// 映射数据模型在数据库中的字段
    /// - Parameter model: 模型对象
    /// - Returns: [字段:值]
    fileprivate func field<T>(for model: T) -> [String:Any] where T: Initializable {
        var result = [String:Any]()
        let columns = columns(for: Swift.type(of: model))
        let mirror = Mirror(reflecting: model)
        for (label, value) in mirror.children {
            guard let label = label else { continue }
            guard let _ = columns.first(where: { $0.name == label }) else { continue }
            switch value {
            case Optional<Any>.none:
                // nil, 先获取真实类型
                let propertyType = Swift.type(of: value)
                if let optionalType = propertyType as? Wrappedable.Type {
                    let wrappedType = optionalType.wrappedType
                    if let caseType = wrappedType as? any CaseIterable.Type {
                        // 枚举
                        if let firstCase = caseType.allCases.first, let rawValueProvider = firstCase as? any RawRepresentable {
                            result[label] = rawValueProvider.rawValue
                        }
                    } else {
                        result[label] = value
                    }
                }
            default:
                if let rawValueProvider = value as? any RawRepresentable {
                    result[label] = rawValueProvider.rawValue
                } else {
                    result[label] = value
                }
            }
        }
        return result
    }
    
    /// 映射类型在数据库中的字段
    /// - Parameter model: 模型对象
    /// - Returns: [字段:值]
    private func columns<T>(for type: T.Type) -> [MNTableColumn] where T: Initializable {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        let key = String(describing: type)
        // 先取缓存
        if let columns = classColumns[key] { return columns }
        // 查询协议
        if let convertible = type as? TableColumnSupported.Type {
            var columns: [MNTableColumn] = convertible.supportedTableColumns.compactMap {
                MNTableColumn(name: $0.key, type: $0.value)
            }
            columns.removeAll { $0.name.lowercased() == MNTableColumn.PrimaryKey }
            classColumns[key] = columns
            return columns
        }
        // 分析属性
        let instance = T.init()
        let mirror = Mirror(reflecting: instance)
        var columns = [MNTableColumn]()
        for (label, value) in mirror.children {
            guard let label = label else { continue }
            if label.lowercased() == MNTableColumn.PrimaryKey { continue }
            let propertyType = Swift.type(of: value)
            if propertyType == Int.self || propertyType == Int64.self || propertyType == Bool.self || propertyType == Int32.self || propertyType == UInt.self || propertyType is Optional<Int>.Type || propertyType is Optional<Int64>.Type || propertyType is Optional<Bool>.Type || propertyType is Optional<Int32>.Type || propertyType is Optional<UInt>.Type {
                // integer
                columns.append(MNTableColumn(name: label, type: .integer))
            } else if propertyType == Double.self || propertyType == CGFloat.self || propertyType == Float.self || propertyType is Optional<Double>.Type || propertyType is Optional<CGFloat>.Type || propertyType is Optional<Float>.Type {
                // float
                columns.append(MNTableColumn(name: label, type: .float))
            } else if propertyType == String.self || propertyType == NSString.self || propertyType is Optional<String>.Type || propertyType is Optional<NSString>.Type {
                // text
                columns.append(MNTableColumn(name: label, type: .text))
            } else if propertyType == Data.self || propertyType == NSData.self || propertyType is Optional<Data>.Type || propertyType is Optional<NSData>.Type {
                // blob
                columns.append(MNTableColumn(name: label, type: .blob))
            } else if let rawValueProvider = value as? any RawRepresentable {
                let rawValue = rawValueProvider.rawValue
                if rawValue is String {
                    // text
                    columns.append(MNTableColumn(name: label, type: .text))
                } else if rawValue is Int || rawValue is Int64 {
                    // integer
                    columns.append(MNTableColumn(name: label, type: .integer))
                }
            } else if let optionalType = propertyType as? Wrappedable.Type, let caseType = optionalType.wrappedType as? any CaseIterable.Type, let firstCase = caseType.allCases.first, let rawValueProvider = firstCase as? any RawRepresentable {
                let rawValue = rawValueProvider.rawValue
                if rawValue is String {
                    // text
                    columns.append(MNTableColumn(name: label, type: .text))
                } else if rawValue is Int || rawValue is Int64 {
                    // integer
                    columns.append(MNTableColumn(name: label, type: .integer))
                }
            }
        }
        classColumns[key] = columns
        return columns
    }
    /*
    /// 查询模型在数据库中的字段
    /// - Parameter obj: 模型对象
    /// - Returns: [字段:值]
    fileprivate func columns(obj: AnyObject) -> [String:Any] {
        var result = [String:Any]()
        guard let cls = object_getClass(obj) else { return result }
        let columns = columns(class: cls)
        guard columns.isEmpty == false else { return result }
        let children: Mirror.Children = Mirror(reflecting: obj).children
        guard children.isEmpty == false else { return result }
        for (label, value) in children {
            guard let name = label else { continue }
            guard let column = columns.first(where: { $0.name == name }) else { continue }
            // ExpressibleByNilLiteral
            switch value {
            case Optional<Any>.none:
                // 处理nil
                result[name] = column.defaultValue
            default:
                // 处理枚举
                let mirror = Mirror(reflecting: value)
                if let style = mirror.displayStyle, style == .enum {
                    result[name] = obj.value(forKey:name) ?? column.defaultValue
                } else {
                    result[name] = value
                }
            }
        }
        return result
    }
    
    /// 类映射的表字段
    /// - Parameter class: 指定类
    /// - Returns: 表字段
    fileprivate func columns(class: AnyClass) -> [MNTableColumn] {
        let clsString: String = NSStringFromClass(`class`)
        //guard let superclass = class_getSuperclass(cls), superclass == NSObject.self else { return columns }
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        // 先取缓存
        if let columns = classColumns[clsString] { return columns }
        // 查找协议
        if let convertible = `class` as? TableColumnSupported.Type {
            let columns: [MNTableColumn] = convertible.supportedTableColumns.compactMap {
                MNTableColumn(name: $0.key, type: $0.value)
            }
            if columns.isEmpty == false {
                classColumns[clsString] = columns
            }
            return columns
        }
        // 分析属性映射字段
        var count: UInt32 = 0
        var columns = [MNTableColumn]()
        if let properties = class_copyPropertyList(`class`, &count) {
            for idx in 0..<count {
                let property = properties[Int(idx)]
                let name = String(cString: property_getName(property))
                if name.lowercased() == MNTableColumn.PrimaryKey { continue }
                guard let type = type(property: property) else { continue }
                columns.append(MNTableColumn(name: name, type: type))
            }
            free(properties)
            if columns.isEmpty == false {
                classColumns[clsString] = columns
            }
        }
        return columns
    }
    
    /// 属性在数据库中对应的字段类型
    /// - Parameter property: 属性
    /// - Returns: 字段类型
    fileprivate func type(property: objc_property_t) -> MNTableColumn.FieldType? {
        guard let attr = property_getAttributes(property) else { return nil }
        let string = String(cString: attr)
        let attributes: [String] = string.components(separatedBy: ",")
        // 只读属性不做表字段
        guard attributes.contains("R") == false else { return nil }
        // NSString
        if attributes.contains("T@\"NSString\"") { return .text }
        // NSNumber Double Float CGFloat
        if attributes.contains("T@\"NSNumber\"") || attributes.contains("Td") || attributes.contains("Tf") { return .float }
        // Int BOOL NSInteger NSUInteger
        if attributes.contains("Ti") || attributes.contains("TB") || attributes.contains("Tq") || attributes.contains("TQ") { return .integer }
        // NSData
        if attributes.contains("T@\"NSData\"") { return .blob }
        return nil
    }
    */
    /// 绑定句柄
    /// - Parameters:
    ///   - stmt: 句柄
    ///   - contents: (字段, 绑定的值)
    fileprivate func bind(_ stmt: OpaquePointer, contents: [(MNTableColumn, Any)]) -> Bool {
        for (i, element) in contents.enumerated() {
            var result: Int32 = SQLITE_ERROR
            let column = element.0
            let value = element.1
            let index = Int32(i + 1)
            switch column.type {
            case .text:
                if value is String {
                   result = sqlite3_bind_text(stmt, index, ((value as! String) as NSString).utf8String, -1, SQLITE_TRANSIENT)
                } else if value is NSString {
                    result = sqlite3_bind_text(stmt, index, (value as! NSString).utf8String, -1, SQLITE_TRANSIENT)
                }
            case .integer:
                if value is Int {
                    result = sqlite3_bind_int64(stmt, index, sqlite3_int64(sqlite_int64(value as! Int)))
                } else if value is Int64 {
                    result = sqlite3_bind_int64(stmt, index, value as! sqlite3_int64)
                } else if value is Bool {
                    result = sqlite3_bind_int64(stmt, index, (value as! Bool) ? 1 : 0)
                } else if value is ObjCBool {
                    result = sqlite3_bind_int64(stmt, index, (value as! ObjCBool).boolValue ? 1 : 0)
                } else if value is Int32 {
                    result = sqlite3_bind_int64(stmt, index, sqlite3_int64(sqlite_int64(value as! Int32)))
                } else if value is Int16 {
                    result = sqlite3_bind_int64(stmt, index, sqlite3_int64(sqlite_int64(value as! Int16)))
                } else if value is Int8 {
                    result = sqlite3_bind_int64(stmt, index, sqlite3_int64(sqlite_int64(value as! Int8)))
                } else if value is NSNumber {
                    result = sqlite3_bind_int64(stmt, index, (value as! NSNumber).int64Value)
                } else if value is Date {
                    result = sqlite3_bind_int64(stmt, index, sqlite3_int64((value as! Date).timeIntervalSince1970))
                }
            case .float:
                if value is Double {
                    result = sqlite3_bind_double(stmt, index, value as! Double)
                } else if value is CGFloat {
                    result = sqlite3_bind_double(stmt, index, Double(value as! CGFloat))
                } else if value is Float {
                    result = sqlite3_bind_double(stmt, index, Double(value as! Float))
                } else if value is Bool {
                    result = sqlite3_bind_double(stmt, index, (value as! Bool) ? 1.0 : 0.0)
                } else if value is ObjCBool {
                    result = sqlite3_bind_double(stmt, index, (value as! ObjCBool).boolValue ? 1.0 : 0.0)
                } else if #available(iOS 14.0, *), value is Float16 {
                    result = sqlite3_bind_double(stmt, index, Double(value as! Float16))
                } else if value is NSNumber {
                    result = sqlite3_bind_double(stmt, index, (value as! NSNumber).doubleValue)
                } else if value is Date {
                    result = sqlite3_bind_double(stmt, index, (value as! Date).timeIntervalSince1970)
                }
            case .blob:
                if value is Data {
                    var bytes = [UInt8](value as! Data)
                    result = sqlite3_bind_blob(stmt, index, &bytes, Int32(bytes.count), SQLITE_TRANSIENT)
                } else if value is NSData {
                    let data = value as! NSData
                    result = sqlite3_bind_blob(stmt, index, data.bytes, Int32(data.length), SQLITE_TRANSIENT)
                }
            }
            guard result == SQLITE_OK else { return false }
        }
        return true
    }
}
