//
//  MNPathUtilities.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/11.
//  文件路径

import Foundation

public func MNDocumentDirectory() -> String {
    NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
}

public func MNLibraryDirectory() -> String {
    NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
}

public func MNCachesDirectory() -> String {
    NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
}

public func MNPreferencesDirectory() -> String {
    MNLibraryAppending("Preferences")
}

public func MNDocumentAppending(_ pathComponent: String) -> String {
    MNDocumentDirectory().appendingPathComponent(pathComponent)
}

public func MNLibraryAppending(_ pathComponent: String) -> String {
    MNLibraryDirectory().appendingPathComponent(pathComponent)
}

public func MNCachesAppending(_ pathComponent: String) -> String {
    MNCachesDirectory().appendingPathComponent(pathComponent)
}

// MARK: - Path
extension String {
    
    public var pathComponents: [String] { (self as NSString).pathComponents }

    public var isAbsolutePath: Bool { (self as NSString).isAbsolutePath }

    public var lastPathComponent: String { (self as NSString).lastPathComponent }

    public var deletingLastPathComponent: String { (self as NSString).deletingLastPathComponent }

    public var pathExtension: String { (self as NSString).pathExtension }

    public var deletingPathExtension: String { (self as NSString).deletingPathExtension }

    public func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
    
    public func appendingPathExtension(_ str: String) -> String? {
        return (self as NSString).appendingPathExtension(str)
    }
    
    /// 可用的路径
    /// -----/abc.png => -----/abc 2.png
    /// -----/abc 2.png => -----/abc 3.png
    public var availablePath: String? {
        guard (self as NSString).isAbsolutePath else { return nil }
        guard FileManager.default.fileExists(atPath: self) else { return self }
        var name = ((self as NSString).lastPathComponent as NSString).deletingPathExtension
        var components = name.components(separatedBy: " ")
        if components.count > 1 {
            let last = components.removeLast()
            let scanner = Scanner(string: last)
            scanner.charactersToBeSkipped = CharacterSet()
            var result: Int64 = 0
            if scanner.scanInt64(&result), scanner.isAtEnd {
                let component = NSNumber(value: result + 1).stringValue
                components.append(component)
                name = components.joined(separator: " ")
            } else if last.isEmpty {
                name.append("2")
            } else {
                name.append(" 2")
            }
        } else {
            name.append(" 2")
        }
        let pathExtension = (self as NSString).pathExtension
        if pathExtension.isEmpty == false {
            name.append("." + pathExtension)
        }
        let path = ((self as NSString).deletingLastPathComponent as NSString).appendingPathComponent(name)
        return path.availablePath
    }
}

