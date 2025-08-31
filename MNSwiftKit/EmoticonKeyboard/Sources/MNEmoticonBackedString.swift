//
//  MNEmoticonBackedString.swift
//  MNSwiftKit
//
//  Created by 小斯 on 2023/2/13.
//  表情富文本描述

import UIKit

internal class MNEmoticonBackedString: NSObject {
    
    let string: String
    
    required init(string: String) {
        self.string = string
        super.init()
    }
}

extension MNEmoticonBackedString: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return MNEmoticonBackedString(string: string)
    }
}

extension MNEmoticonBackedString: NSMutableCopying {
    
    func mutableCopy(with zone: NSZone? = nil) -> Any {
        return MNEmoticonBackedString(string: string)
    }
}

extension NSAttributedString.Key {
    
    static let emojiBacked: NSAttributedString.Key = NSAttributedString.Key(rawValue: "com.mn.emoji.backed.attributed")
}
