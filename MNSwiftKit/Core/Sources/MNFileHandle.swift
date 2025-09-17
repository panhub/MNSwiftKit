//
//  MNFileHandle.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/9.
//

import Foundation

public class MNFileHandle {
    
    private let fileHandle: FileHandle
    
    public init?(forReadingAtPath path: String) {
        guard let fileHandle = FileHandle(forReadingAtPath: path) else { return nil }
        self.fileHandle = fileHandle
    }

    public init?(forWritingAtPath path: String) {
        guard let fileHandle = FileHandle(forWritingAtPath: path) else { return nil }
        self.fileHandle = fileHandle
    }

    public init?(forUpdatingAtPath path: String) {
        guard let fileHandle = FileHandle(forUpdatingAtPath: path) else { return nil }
        self.fileHandle = fileHandle
    }
    
    public init?(forReadingFrom url: URL) {
        guard let fileHandle = try? FileHandle(forReadingFrom: url) else { return nil }
        self.fileHandle = fileHandle
    }

    public init?(forWritingTo url: URL) {
        guard let fileHandle = try? FileHandle(forWritingTo: url) else { return nil }
        self.fileHandle = fileHandle
    }
    
    public init?(forUpdating url: URL) {
        guard let fileHandle = try? FileHandle(forUpdating: url) else { return nil }
        self.fileHandle = fileHandle
    }
    
    public var offset: UInt64 {
        if #available(iOS 13.4, *) {
            var count: UInt64 = 0
            do {
                count = try fileHandle.offset()
            } catch {
                return 0
            }
            return count
        } else {
            return fileHandle.offsetInFile
        }
    }
    
    public func close() {
        if #available(iOS 13.0, *) {
            do {
                try fileHandle.close()
            } catch {
#if DEBUG
                print(error)
#endif
            }
        } else {
            fileHandle.closeFile()
        }
    }
    
    public func truncate(atOffset offset: UInt64) -> Bool {
        if #available(iOS 13.0, *) {
            do {
                try fileHandle.truncate(atOffset: offset)
            } catch {
#if DEBUG
                print(error)
#endif
                return false
            }
        } else {
            fileHandle.truncateFile(atOffset: offset)
        }
        return true
    }
    
    public func synchronize() {
        if #available(iOS 13.0, *) {
            do {
                try fileHandle.synchronize()
            } catch {
#if DEBUG
                print(error)
#endif
            }
        } else {
            fileHandle.synchronizeFile()
        }
    }
}

// MARK: - Seek
extension MNFileHandle {
    
    public func seekToEnd() -> UInt64 {
        if #available(iOS 13.4, *) {
            var count: UInt64 = 0
            do {
                count = try fileHandle.seekToEnd()
            } catch {
#if DEBUG
                print(error)
#endif
            }
            return count
        } else {
            return fileHandle.seekToEndOfFile()
        }
    }
    
    public func seek(toOffset offset: UInt64) {
        if #available(iOS 13.0, *) {
            do {
                try fileHandle.seek(toOffset: offset)
            } catch {
#if DEBUG
                print(error)
#endif
            }
        } else {
            fileHandle.seek(toFileOffset: offset)
        }
    }
}

// MARK: - Read
extension MNFileHandle {
    
    public func readToEnd() -> Data? {
        if #available(iOS 13.4, *) {
            var data: Data?
            do {
                data = try fileHandle.readToEnd()
            } catch {
                return nil
            }
            return data
        } else {
            return fileHandle.readDataToEndOfFile()
        }
    }
    
    public func readData(ofCount count: Int) -> Data? {
        var data: Data?
        if #available(iOS 13.4, *) {
            do {
                data = try fileHandle.read(upToCount: count)
            } catch {
#if DEBUG
                print(error)
#endif
                return nil
            }
        } else {
            data = fileHandle.readData(ofLength: count)
        }
        return data
    }
}

// MARK: - Write
extension MNFileHandle {
    
    public func write(contentsOf data: Data) -> Bool {
        if #available(iOS 13.4, *) {
            do {
                try fileHandle.write(contentsOf: data)
            } catch {
#if DEBUG
                print(error)
#endif
                return false
            }
            return true
        } else {
            fileHandle.write(data)
            return true
        }
    }
}

// MARK: - Helper
extension MNFileHandle {
    
    /// 复制文件到指定文件
    /// - Parameters:
    ///   - srcPath: 原文件
    ///   - dstPath: 目标文件
    /// - Returns: 是否操作成功
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
        guard let reader = MNFileHandle(forReadingAtPath: filePath) else { return false }
        defer {
            reader.close()
        }
        let count = reader.seekToEnd()
        guard count > 0 else { return false }
        // 写
        guard let writer = MNFileHandle(forWritingAtPath: targetPath) else { return false }
        defer {
            writer.close()
        }
        // 再次保证从头开始
        guard writer.truncate(atOffset: 0) else { return false }
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
                reader.seek(toOffset: offset)
                var data = reader.readData(ofCount: Int(length))
                if let buffer = data {
                    let _ = writer.seekToEnd()
                    if writer.write(contentsOf: buffer) == false {
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

