//
//  MNFileManager.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/11.
//  文件管理

import Foundation

class MNFileManager {
    
    /// 磁盘容量
    public class var diskSize: Int64 {
        var fileSize: Int64 = 0
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let count = attributes[FileAttributeKey.systemSize] as? Int64 {
                fileSize = count
            }
        } catch {
#if DEBUG
            print("读取系统磁盘大小出错: \n\(error)")
#endif
        }
        return fileSize
    }
    
    /// 磁盘空余容量
    public class var freeSize: Int64 {
        var fileSize: Int64 = 0
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let count = attributes[FileAttributeKey.systemFreeSize] as? Int64 {
                fileSize = count
            }
        } catch {
#if DEBUG
            print("读取空余磁盘大小出错: \(error)")
#endif
        }
        return fileSize
    }
    
    /// 磁盘使用大小
    public class var usedSize: Int64 {
        let total = diskSize
        let free = freeSize
        return max(0, total - free)
    }
    
    /// 计算路径下文件大小
    /// - Parameter url: 指定路径
    /// - Returns: 文件大小
    public class func itemSize(at url: URL) -> Int64 {
        guard url.isFileURL else { return 0 }
        return itemSize(atPath: path(with: url))
    }
    
    /// 计算路径下文件大小
    /// - Parameter filePath: 指定路径
    /// - Returns: 文件大小
    public class func itemSize(atPath filePath: String) -> Int64 {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory) else { return 0 }
        if isDirectory.boolValue {
            // 文件夹
            guard let subpaths = FileManager.default.subpaths(atPath: filePath) else { return 0 }
            var fileSize: Int64 = 0
            for subpath in subpaths {
                let path = (filePath as NSString).appendingPathComponent(subpath)
                fileSize += itemSize(atPath: path)
            }
            return fileSize
        }
        // 文件
        return fileSize(atPath: filePath)
    }
    
    /// 计算单个文件大小
    /// - Parameter filePath: 文件路径
    /// - Returns: 文件大小
    public class func fileSize(atPath filePath: String) -> Int64 {
        guard FileManager.default.fileExists(atPath: filePath, isDirectory: nil) else { return 0 }
        var fileSize: Int64 = 0
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let count = attributes[FileAttributeKey.size] as? Int64 {
                fileSize = count
            }
        } catch {
#if DEBUG
            print("读取文件大小出错: \(error)")
#endif
        }
        return fileSize
    }
}

// MARK: - 创建文件夹
extension MNFileManager {
    
    @discardableResult
    public class func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
        guard FileManager.default.fileExists(atPath: path) == false else { return true }
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: createIntermediates, attributes: attributes)
        } catch {
#if DEBUG
            print("创建文件夹失败 path: \(path)\n\(error)")
#endif
            return false
        }
        return true
    }
    
    @discardableResult
    public class func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
        createDirectory(atPath: path(with: url), withIntermediateDirectories: createIntermediates, attributes: attributes)
    }
}

// MARK: - 复制文件
extension MNFileManager {
    
    @discardableResult
    public class func copyItem(atPath srcPath: String, toPath dstPath: String, overwritten: Bool = true) -> Bool {
        guard FileManager.default.fileExists(atPath: srcPath) else { return false }
        // 判断是否需要删除旧文件
        if overwritten, FileManager.default.fileExists(atPath: dstPath) {
            do {
                try FileManager.default.removeItem(atPath: dstPath)
            } catch {
#if DEBUG
                print("复制文件时删除旧文件失败 at: \(srcPath) to: \(dstPath)")
#endif
                return false
            }
        }
        // 若存在文件则直接返回
        if FileManager.default.fileExists(atPath: dstPath) { return true }
        // 创建目标目录文件夹
        let directory = (dstPath as NSString).deletingLastPathComponent
        if FileManager.default.fileExists(atPath: directory) == false {
            do {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("复制文件时创建目标目录失败 at: \(srcPath) to: \(dstPath)")
#endif
                return false
            }
        }
        // 复制文件操作
        do {
            try FileManager.default.copyItem(atPath: srcPath, toPath: dstPath)
        } catch {
#if DEBUG
            print("复制文件失败 at: \(srcPath) to: \(dstPath)")
#endif
            return false
        }
        return true
    }
    
    @discardableResult
    public class func copyItem(at srcURL: URL, to dstURL: URL, overwritten: Bool = true) -> Bool {
        copyItem(atPath: path(with: srcURL), toPath: path(with: dstURL), overwritten: overwritten)
    }
}

// MARK: - 移动文件
extension MNFileManager {
    
    @discardableResult
    public class func moveItem(atPath srcPath: String, toPath dstPath: String) -> Bool {
        guard FileManager.default.fileExists(atPath: srcPath) else { return false }
        if FileManager.default.fileExists(atPath: dstPath) {
            do {
                try FileManager.default.removeItem(atPath: dstPath)
            } catch {
#if DEBUG
            print("移动文件时删除旧文件失败 at: \(srcPath) to: \(dstPath)")
#endif
                return false
            }
        } else if FileManager.default.fileExists(atPath: (dstPath as NSString).deletingLastPathComponent) == false {
            do {
                try FileManager.default.createDirectory(atPath: (dstPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("移动文件时创建目录文件失败 at: \(srcPath) to: \(dstPath)")
#endif
                return false
            }
        }
        do {
            try FileManager.default.moveItem(atPath: srcPath, toPath: dstPath)
        } catch {
#if DEBUG
            print("移动文件失败 at: \(srcPath) to: \(dstPath)")
#endif
            return false
        }
        return true
    }
    
    @discardableResult
    public class func moveItem(at srcURL: URL, to dstURL: URL) -> Bool {
        moveItem(atPath: path(with: srcURL), toPath: path(with: dstURL))
    }
}

// MARK: - 删除文件
extension MNFileManager {
    
    @discardableResult
    public class func removeItem(atPath path: String) -> Bool {
        guard FileManager.default.fileExists(atPath: path) else { return true }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
#if DEBUG
            print("删除文件失败 at: \(path)")
#endif
            return false
        }
        return true
    }
    
    @discardableResult
    public class func removeItem(at url: URL) -> Bool {
        removeItem(atPath: path(with: url))
    }
}

// MARK: - 辅助
fileprivate extension MNFileManager {
    
    /// URL=>String
    class func path(with url: URL) -> String {
        if #available(iOS 16.0, *) {
            return url.path(percentEncoded: false)
        }
        return url.path
    }
}
