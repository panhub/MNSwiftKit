//
//  FileHandle+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/9.
//

import Foundation

extension NameSpaceWrapper where Base: FileHandle {
    
    /// 构造读取句柄
    /// - Parameter url: 文件位置
    /// - Returns: 文件读取句柄
    public class func reading(from url: URL) -> FileHandle? {
        var fileHandle: FileHandle?
        do {
            fileHandle = try FileHandle(forReadingFrom: url)
        } catch {
#if DEBUG
            print("构造文件句柄失败: \(error)")
#endif
        }
        return fileHandle
    }
    
    /// 构建文件写入句柄
    /// - Parameter url: 写入位置
    /// - Returns: 文件写入句柄
    public class func writing(to url: URL) -> FileHandle? {
        var fileHandle: FileHandle?
        do {
            fileHandle = try FileHandle(forWritingTo: url)
        } catch {
#if DEBUG
            print("构造文件句柄失败: \(error)")
#endif
        }
        return fileHandle
    }
    
    /// 构建文件更新句柄
    /// - Parameter url: 文件位置
    /// - Returns: 文件更新句柄
    public class func updating(url: URL) -> FileHandle? {
        var fileHandle: FileHandle?
        do {
            fileHandle = try FileHandle(forUpdating: url)
        } catch {
#if DEBUG
            print("构造文件句柄失败: \(error)")
#endif
        }
        return fileHandle
    }
}

extension NameSpaceWrapper where Base: FileHandle {
    
    /// 当前偏移位置
    public var offset: UInt64 {
        if #available(iOS 13.4, *) {
            var count: UInt64 = 0
            do {
                count = try base.offset()
            } catch {
                return 0
            }
            return count
        } else {
            return base.offsetInFile
        }
    }
    
    /// 关闭文件句柄
    public func close() {
        if #available(iOS 13.0, *) {
            do {
                try base.close()
            } catch {
#if DEBUG
                print(error)
#endif
            }
        } else {
            base.closeFile()
        }
    }
    
    /// 截断数据
    /// - Parameter offset: 偏移
    /// - Returns: 是否操作成功
    @discardableResult
    public func truncate(atOffset offset: UInt64) -> Bool {
        if #available(iOS 13.0, *) {
            do {
                try base.truncate(atOffset: offset)
            } catch {
#if DEBUG
                print(error)
#endif
                return false
            }
        } else {
            base.truncateFile(atOffset: offset)
        }
        return true
    }
    
    /// 同步操作
    public func synchronize() {
        if #available(iOS 13.0, *) {
            do {
                try base.synchronize()
            } catch {
#if DEBUG
                print(error)
#endif
            }
        } else {
            base.synchronizeFile()
        }
    }
}

// MARK: - Seek
extension NameSpaceWrapper where Base: FileHandle {
    
    /// 跳转到结尾处
    /// - Returns: 数据长度
    @discardableResult
    public func seekToEnd() -> UInt64 {
        if #available(iOS 13.4, *) {
            var count: UInt64 = 0
            do {
                count = try base.seekToEnd()
            } catch {
#if DEBUG
                print(error)
#endif
            }
            return count
        } else {
            return base.seekToEndOfFile()
        }
    }
    
    /// 跳转到指定位置
    /// - Parameter offset: 偏移量
    public func seek(toOffset offset: UInt64) {
        if #available(iOS 13.0, *) {
            do {
                try base.seek(toOffset: offset)
            } catch {
#if DEBUG
                print(error)
#endif
            }
        } else {
            base.seek(toFileOffset: offset)
        }
    }
}

// MARK: - Read
extension NameSpaceWrapper where Base: FileHandle {
    
    /// 读取到结尾
    /// - Returns: 读取到的数据
    public func readToEnd() -> Data? {
        if #available(iOS 13.4, *) {
            var data: Data?
            do {
                data = try base.readToEnd()
            } catch {
                return nil
            }
            return data
        } else {
            return base.readDataToEndOfFile()
        }
    }
    
    /// 读取指定数量的数据
    /// - Parameter count: 指定数量
    /// - Returns: 读取到的数据
    public func readData(ofCount count: Int) -> Data? {
        var data: Data?
        if #available(iOS 13.4, *) {
            do {
                data = try base.read(upToCount: count)
            } catch {
#if DEBUG
                print(error)
#endif
                return nil
            }
        } else {
            data = base.readData(ofLength: count)
        }
        return data
    }
}

// MARK: - Write
extension NameSpaceWrapper where Base: FileHandle {
    
    /// 写入数据
    /// - Parameter data: 数据流
    /// - Returns: 是否写入成功
    @discardableResult
    public func write(contentsOf data: Data) -> Bool {
        if #available(iOS 13.4, *) {
            do {
                try base.write(contentsOf: data)
            } catch {
#if DEBUG
                print(error)
#endif
                return false
            }
            return true
        } else {
            base.write(data)
            return true
        }
    }
}

// MARK: - Helper
extension NameSpaceWrapper where Base: FileHandle {
    
    /// 复制文件
    /// - Parameters:
    ///   - srcPath: 原文件目录
    ///   - dstPath: 目标文件目录
    /// - Returns: 是否复制成功
    public class func copyItem(atPath srcPath: String, toPath dstPath: String) -> Bool {
        guard FileManager.default.fileExists(atPath: srcPath) else { return false }
        if FileManager.default.fileExists(atPath: dstPath) {
            do {
                try FileManager.default.removeItem(atPath: dstPath)
            } catch {
#if DEBUG
                print("删除旧文件失败: \(error)")
#endif
                return false
            }
        }
        let directory = (dstPath as NSString).deletingLastPathComponent
        if FileManager.default.fileExists(atPath: directory) == false {
            do {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("创建目标文件夹失败: \(error)")
#endif
                return false
            }
        }
        do {
            try FileManager.default.copyItem(atPath: srcPath, toPath: dstPath)
        } catch {
            return writeItem(atPath: srcPath, toPath: dstPath)
        }
        return true
    }
    
    /// 写入文件
    /// - Parameters:
    ///   - filePath: 原文件路径
    ///   - targetPath: 目标路径
    ///   - unitCount: 每次写入大小
    /// - Returns: 是否写入成功
    public class func writeItem(atPath filePath: String, toPath targetPath:String, units unitCount: UInt64 = 1024*1024*100) -> Bool {
        guard FileManager.default.fileExists(atPath: filePath) else { return false }
        if FileManager.default.fileExists(atPath: targetPath) {
            do {
                try FileManager.default.removeItem(atPath: targetPath)
            } catch {
#if DEBUG
                print("删除旧文件失败: \(error)")
#endif
                return false
            }
        }
        let directory = (targetPath as NSString).deletingLastPathComponent
        if FileManager.default.fileExists(atPath: directory) == false {
            do {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("创建目标文件夹失败: \(error)")
#endif
                return false
            }
        }
        guard FileManager.default.createFile(atPath: targetPath, contents: nil, attributes: nil) else {
#if DEBUG
            print("创建目标文件失败: \(targetPath)")
#endif
            return false
        }
        // 读
        guard let reader = FileHandle(forReadingAtPath: filePath) else { return false }
        defer {
            reader.mn.close()
        }
        let count = reader.mn.seekToEnd()
        guard count > 0 else { return false }
        // 写
        guard let writer = FileHandle(forWritingAtPath: targetPath) else { return false }
        defer {
            writer.mn.close()
        }
        // 再次保证从头开始
        guard writer.mn.truncate(atOffset: 0) else { return false }
        // 当前进度
        var offset: UInt64 = 0
        // 是否完成
        var done: Bool = false
        while done == false {
            // 是否失败
            var fail: Bool = false
            // 当前需要读取的长度
            let length = min(count - offset, unitCount)
            autoreleasepool {
                reader.mn.seek(toOffset: offset)
                var data = reader.mn.readData(ofCount: Int(length))
                if let buffer = data {
                    writer.mn.seekToEnd()
                    if writer.mn.write(contentsOf: buffer) == false {
                        fail = true
                    }
                } else {
                    fail = true
                }
                data = nil
            }
            guard fail == false else { break }
            offset += length
            if offset >= count { done = true }
        }
        if done == false {
            try? FileManager.default.removeItem(atPath: targetPath)
        }
        return done
    }
}

