//
//  MNRequestDatabase.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/3.
//  网络数据缓存

import SQLite3
import Foundation

fileprivate let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

/// 网络数据缓存
public class MNRequestDatabase {
    /// 定义存储项
    fileprivate struct CacheEntry {
        var key: String!
        var data: Data!
        var time: TimeInterval = 0.0
    }
    /// 默认表名
    public static let Table: String = "t_request_result"
    /// 默认数据库路径
    public static let Path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/request_cache.sqlite"
    /// 操作线程
    private let queue = DispatchQueue(label: "com.mn.request.data.result.queue", attributes: .concurrent)
    /// 数据库路径
    private var path: String = Path
    /// 快速实例入口
    public static let `default`: MNRequestDatabase = MNRequestDatabase()
    /// 线程安全
    private let semaphore = DispatchSemaphore(value: 1)
    /// 句柄缓存
    private var stmts: [String: OpaquePointer] = [String: OpaquePointer]()
    /// 数据库指针
    private var db: OpaquePointer!
    
    /// 构造缓存工具
    /// - Parameters:
    ///   - path: 数据库路径
    public init(path: String = Path) {
        self.path = path
#if DEBUG
        print("\n===============网络缓存路径===============\n\(path)\n======================================")
#endif
        if FileManager.default.fileExists(atPath: path) == false {
            do {
                try FileManager.default.createDirectory(atPath: (path as NSString).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            } catch {
#if DEBUG
                print("\n=========网络缓存文件夹创建失败=========\n\(error)\n============================")
#endif
            }
        }
    }
    
    deinit {
        close()
    }
    
    /// 写入缓存
    /// - Parameters:
    ///   - cache: 缓存数据
    ///   - key: 缓存标识
    /// - Returns: 是否写入成功
    public func setCache(_ cache: Any, forKey key:  String) -> Bool {
        var data: Data!
        do {
            data = try JSONSerialization.data(withJSONObject: cache, options: .fragmentsAllowed)
        } catch {
#if DEBUG
            print("\n缓存编码失败:\n\(error)")
#endif
            return false
        }
        var entry = CacheEntry()
        entry.key = key
        entry.data = data
        entry.time = Date().timeIntervalSince1970
        var result: Bool = false
        semaphore.wait()
        if let count = count(for: key) {
            if count <= 0 {
                result = insert(data, key: key)
            } else {
                result = update(data, for: key)
            }
        }
        semaphore.signal()
        return result
    }
    
    /// 异步写入缓存
    /// - Parameters:
    ///   - cache: 缓存数据
    ///   - key: 缓存标识
    ///   - completionHandler: 结束回调
    public func setCache(_ cache: Any, forKey key:  String, completion completionHandler: ((Bool)->Void)?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let result = self.setCache(cache, forKey: key)
            completionHandler?(result)
        }
    }
    
    /// 读取缓存
    /// - Parameters:
    ///   - key: 缓存标识
    ///   - ttl: 缓存有效时长 单位秒
    /// - Returns: 缓存数据
    public func cache(forKey key: String, ttl: TimeInterval = 0.0) -> Any? {
        semaphore.wait()
        let entry = entry(for: key)
        semaphore.signal()
        guard let entry = entry, let data = entry.data else { return nil }
        if ttl > 0.0  {
            let time =  TimeInterval(time(nil))
            guard time <= (entry.time + ttl) else { return nil }
        }
        var object: Any?
        do {
            object = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        } catch {
#if DEBUG
            print("\n解析缓存数据失败:\n\(error)")
#endif
        }
        return object
    }
    
    /// 异步读取缓存
    /// - Parameters:
    ///   - key: 缓存标识
    ///   - ttl: 缓存有效时长 单位秒
    ///   - completionHandler: 缓存数据回调
    public func cache(forKey key: String, ttl: TimeInterval = 0.0, completion completionHandler: @escaping ((Any?)->Void)) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let object = self.cache(forKey:key, ttl: ttl)
            completionHandler(object)
        }
    }
    
    /// 判断是否包含某条缓存
    /// - Parameter key: 缓存标识
    /// - Returns: 判断结果
    public func containsCache(forKey key: String) -> Bool {
        guard let count = count(for: key) else { return false }
        return count > 0
    }
    
    /// 异步判断是否包含某条缓存
    /// - Parameters:
    ///   - key: 缓存标识
    ///   - completionHandler: 判断结果回调
    public func containsCache(forKey key: String, completion completionHandler: @escaping ((Bool)->Void)) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let result = self.containsCache(forKey: key)
            completionHandler(result)
        }
    }
    
    /// 删除指定缓存
    /// - Parameter key: 缓存标识
    /// - Returns: 是否删除成功
    public func removeCache(forKey key: String) -> Bool {
        semaphore.wait()
        let result = deleteRow(for: key)
        semaphore.signal()
        return result
    }
    
    /// 异步删除指定缓存
    /// - Parameters:
    ///   - key: 缓存标识
    ///   - completionHandler: 结束回调
    public func removeCache(forKey key: String, completion completionHandler: ((Bool)->Void)?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let result = self.removeCache(forKey: key)
            completionHandler?(result)
        }
    }
    
    /// 删除所有缓存
    /// - Returns: 是否删除成功
    public func removeAll() -> Bool { deleteAll() }
    
    /// 异步删除所有缓存
    /// - Parameter completionHandler: 结束回调
    public func removeAll(completion completionHandler: ((Bool)->Void)?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let result = self.removeAll()
            completionHandler?(result)
        }
    }
}

// MARK: - 数据库支持
fileprivate extension MNRequestDatabase {
    
    // 打开数据库
    func open() -> Bool {
        if let _ = db { return true }
        if sqlite3_open(path.cString(using: .utf8), &db) == SQLITE_OK, execute(sql: "create table if not exists '\(MNRequestDatabase.Table)' (id integer primary key autoincrement, time float, key text, value blob);") {
#if DEBUG
            print("\n已打开网络缓存数据库")
#endif
            return true
        }
        close()
#if DEBUG
            print("\n打开网络缓存数据库失败")
#endif
        return false
    }
    
    // 关闭数据库
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
                    print("\n已关闭网络缓存数据库")
                } else {
                    print("\n关闭网络缓存数据库失败")
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
    
    /// 插入数据
    /// - Parameters:
    ///   - data: 需要插入的数据
    ///   - key: 需要插入的数据
    /// - Returns: 是否插入缓存
    func insert(_ data: Data, key: String) -> Bool {
        let sql: String = "insert into '\(MNRequestDatabase.Table)' (time, key, value) values (?1, ?2, ?3);"
        guard let stmt = stmt(sql: sql) else { return false }
        sqlite3_bind_double(stmt, 1, Double(time(nil)))
        sqlite3_bind_text(stmt, 2, key.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        sqlite3_bind_blob(stmt, 3, [UInt8](data), Int32(data.count), SQLITE_TRANSIENT)
        return sqlite3_step(stmt) == SQLITE_DONE
    }
    
    /// 更新数据
    /// - Parameters:
    ///   - data: 需要更新的数据
    ///   - key: 依据的数据
    /// - Returns: 是否更新成功
    func update(_ data: Data, for key: String) -> Bool {
        let sql: String = "update '\(MNRequestDatabase.Table)' set time = ?1, value = ?2 where key = ?3;"
        guard let stmt = stmt(sql: sql) else { return false }
        sqlite3_bind_double(stmt, 1, Double(time(nil)))
        sqlite3_bind_blob(stmt, 2, [UInt8](data), Int32(data.count), SQLITE_TRANSIENT)
        sqlite3_bind_text(stmt, 3, key.cString(using: .utf8), -1, SQLITE_TRANSIENT)
        return sqlite3_step(stmt) == SQLITE_DONE
    }
    
    
    /// 获取数据并封装为模型
    /// - Parameter key: 依据的数据
    /// - Returns: 查询到的数据
    func entry(for key: String) -> CacheEntry? {
        let sql: String = "select time, value from '\(MNRequestDatabase.Table)' where key = ?1;"
        guard let stmt = stmt(sql: sql) else { return nil }
        guard sqlite3_bind_text(stmt, 1, key.cString(using: .utf8), -1, SQLITE_TRANSIENT) == SQLITE_OK else { return nil }
        if sqlite3_step(stmt) == SQLITE_ROW {
            let time = sqlite3_column_double(stmt, 0)
            let bytes = sqlite3_column_blob(stmt, 1)
            let count = sqlite3_column_bytes(stmt, 1)
            var entry = CacheEntry()
            entry.key = key
            entry.time = time
            if let bytes = bytes {
                entry.data = Data(bytes: bytes, count: Int(count))
            }
            return entry
        }
        return nil
    }
    
    /// 获取数据数量
    func count(for key: String) -> Int? {
        let sql = "select count(*) from '\(MNRequestDatabase.Table)' where key = ?1;"
        guard let stmt = stmt(sql: sql) else { return nil }
        guard sqlite3_bind_text(stmt, 1, key.cString(using: .utf8), -1, SQLITE_TRANSIENT) == SQLITE_OK else { return nil }
        if sqlite3_step(stmt) == SQLITE_ROW {
            let count = Int(sqlite3_column_int(stmt, 0))
            return count
        }
        return nil
    }
    
    // 删除指定数据
    func deleteRow(for key: String) -> Bool {
        guard open() else { return false }
        return execute(sql: "delete from '\(MNRequestDatabase.Table)' where key = '\(key)';")
    }
    
    // 删除所有数据
    func deleteAll() -> Bool {
        guard open() else { return false }
        return execute(sql: "delete from '\(MNRequestDatabase.Table)';")
    }
    
    // 执行语句
    func execute(sql: String) -> Bool {
        return sqlite3_exec(db, sql.cString(using: .utf8), nil, nil, nil) == SQLITE_OK
    }
    
    // 获取句柄
    func stmt(sql: String) -> OpaquePointer? {
        guard open() else { return nil }
        var stmt: OpaquePointer! = stmts[sql]
        if let stmt = stmt {
            sqlite3_reset(stmt)
        } else if sqlite3_prepare_v2(db, sql.cString(using: .utf8), -1, &stmt, nil) == SQLITE_OK {
            stmts[sql] = stmt
        }
        return stmt
    }
}
