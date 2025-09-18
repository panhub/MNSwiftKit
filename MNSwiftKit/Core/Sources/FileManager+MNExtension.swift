//
//  FileManager+MNExtension.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/11.
//  文件管理

import Foundation

extension NameSpaceWrapper where Base: FileManager {
    
    /// 磁盘容量
    public var diskSize: Int64 {
        var fileSize: Int64 = 0
        do {
            let attributes = try base.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let count = attributes[FileAttributeKey.systemSize] as? Int64 {
                fileSize = count
            }
        } catch {
#if DEBUG
            print("读取系统磁盘大小出错: \(error)")
#endif
        }
        return fileSize
    }
    
    /// 磁盘空余容量
    public var freeSize: Int64 {
        var fileSize: Int64 = 0
        do {
            let attributes = try base.attributesOfFileSystem(forPath: NSHomeDirectory())
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
    public var usedSize: Int64 {
        let total = diskSize
        let free = freeSize
        return max(0, total - free)
    }
    
    /// 计算路径下文件大小
    /// - Parameter url: 指定路径
    /// - Returns: 文件大小
    public func itemSize(at url: URL) -> Int64 {
        guard url.isFileURL else { return 0 }
        if #available(iOS 16.0, *) {
            return itemSize(atPath: url.path(percentEncoded: false))
        }
        return itemSize(atPath: url.path)
    }
    
    /// 计算路径下文件大小
    /// - Parameter filePath: 指定路径
    /// - Returns: 文件大小
    public func itemSize(atPath filePath: String) -> Int64 {
        var isDirectory: ObjCBool = false
        guard base.fileExists(atPath: filePath, isDirectory: &isDirectory) else { return 0 }
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
    public func fileSize(atPath filePath: String) -> Int64 {
        guard base.fileExists(atPath: filePath, isDirectory: nil) else { return 0 }
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
extension NameSpaceWrapper where Base: FileManager {
    
    @discardableResult
    public func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
        guard base.fileExists(atPath: path) == false else { return true }
        do {
            try base.createDirectory(atPath: path, withIntermediateDirectories: createIntermediates, attributes: attributes)
        } catch {
#if DEBUG
            print("创建文件夹失败 path: \(path)\n\(error)")
#endif
            return false
        }
        return true
    }
    
    @discardableResult
    public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) -> Bool {
        if #available(iOS 16.0, *) {
            return createDirectory(atPath: url.path(percentEncoded: false), withIntermediateDirectories: createIntermediates, attributes: attributes)
        }
        return createDirectory(atPath: url.path, withIntermediateDirectories: createIntermediates, attributes: attributes)
    }
}

// MARK: - 复制文件
extension NameSpaceWrapper where Base: FileManager {
    
    @discardableResult
    public func copyItem(atPath srcPath: String, toPath dstPath: String, overwritten: Bool = true) -> Bool {
        guard base.fileExists(atPath: srcPath) else { return false }
        // 判断是否需要删除旧文件
        if overwritten, base.fileExists(atPath: dstPath) {
            do {
                try base.removeItem(atPath: dstPath)
            } catch {
#if DEBUG
                print("复制文件时删除旧文件失败 at: \(srcPath) to: \(dstPath)")
#endif
                return false
            }
        }
        // 若存在文件则直接返回
        if base.fileExists(atPath: dstPath) { return true }
        // 创建目标目录文件夹
        let directory = (dstPath as NSString).deletingLastPathComponent
        if base.fileExists(atPath: directory) == false {
            do {
                try base.createDirectory(atPath: directory, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("复制文件时创建目标目录失败 at: \(srcPath) to: \(dstPath)")
#endif
                return false
            }
        }
        // 复制文件操作
        do {
            try base.copyItem(atPath: srcPath, toPath: dstPath)
        } catch {
#if DEBUG
            print("复制文件失败 at: \(srcPath) to: \(dstPath)")
#endif
            return false
        }
        return true
    }
    
    @discardableResult
    public func copyItem(at srcURL: URL, to dstURL: URL, overwritten: Bool = true) -> Bool {
        if #available(iOS 16.0, *) {
            return copyItem(atPath: srcURL.path(percentEncoded: false), toPath: dstURL.path(percentEncoded: false), overwritten: overwritten)
        }
        return copyItem(atPath: srcURL.path, toPath: dstURL.path, overwritten: overwritten)
    }
}

// MARK: - 移动文件
extension NameSpaceWrapper where Base: FileManager {
    
    @discardableResult
    public func moveItem(atPath srcPath: String, toPath dstPath: String) -> Bool {
        guard base.fileExists(atPath: srcPath) else { return false }
        if base.fileExists(atPath: dstPath) {
            do {
                try base.removeItem(atPath: dstPath)
            } catch {
#if DEBUG
            print("移动文件时删除旧文件失败 at: \(srcPath) to: \(dstPath)")
#endif
                return false
            }
        } else if base.fileExists(atPath: (dstPath as NSString).deletingLastPathComponent) == false {
            do {
                try base.createDirectory(atPath: (dstPath as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
            } catch {
#if DEBUG
                print("移动文件时创建目录文件失败 at: \(srcPath) to: \(dstPath)")
#endif
                return false
            }
        }
        do {
            try base.moveItem(atPath: srcPath, toPath: dstPath)
        } catch {
#if DEBUG
            print("移动文件失败 at: \(srcPath) to: \(dstPath)")
#endif
            return false
        }
        return true
    }
    
    @discardableResult
    public func moveItem(at srcURL: URL, to dstURL: URL) -> Bool {
        if #available(iOS 16.0, *) {
            return moveItem(atPath: srcURL.path(percentEncoded: false), toPath: dstURL.path(percentEncoded: false))
        }
        return moveItem(atPath: srcURL.path, toPath: dstURL.path)
    }
}

// MARK: - 删除文件
extension NameSpaceWrapper where Base: FileManager {
    
    @discardableResult
    public func removeItem(atPath path: String) -> Bool {
        guard base.fileExists(atPath: path) else { return true }
        do {
            try base.removeItem(atPath: path)
        } catch {
#if DEBUG
            print("删除文件失败 at: \(path)")
#endif
            return false
        }
        return true
    }
    
    @discardableResult
    public func removeItem(at url: URL) -> Bool {
        if #available(iOS 16.0, *) {
            return removeItem(atPath: url.path(percentEncoded: false))
        }
        return removeItem(atPath: url.path)
    }
}
