//
//  MNNumberKeyboard.swift
//  MNTest
//
//  Created by 冯盼 on 2022/9/28.
//  数字键盘

import UIKit

@objc public protocol MNNumberKeyboardDelegate: NSObjectProtocol {
    /// 询问是否响应数字按键
    /// - Parameters:
    ///   - keyboard: 数字键盘
    ///   - key: 按键类型
    /// - Returns: 是否响应按键
    @objc optional func numberKeyboard(_ keyboard: MNNumberKeyboard, shouldInput key: MNNumberKeyboard.Key) -> Bool
    /// 按键响应告知
    /// - Parameters:
    ///   - keyboard: 数字键盘
    ///   - key: 按键类型
    @objc optional func numberKeyboard(_ keyboard: MNNumberKeyboard, didInput key: MNNumberKeyboard.Key) -> Void
    /// 按键点击告知
    /// - Parameters:
    ///   - keyboard: 数字键盘
    ///   - key: 按键类型
    @objc optional func numberKeyboard(_ keyboard: MNNumberKeyboard, didClick key: MNNumberKeyboard.Key) -> Void
}

public class MNNumberKeyboard: UIView {
    
    /// 按键
    @objc public enum Key: Int {
        
        public enum Name {
            case none, decimal, delete, clear, done
        }
        
        case zero, one, two, three, four, five, six, seven, eight, nine, decimal, delete, clear, done, none
    }
    
    /// 数字键盘配置
    public struct Options {
        /// 列数
        public let columns: Int = 3
        /// 按键间隔
        public var spacing: CGFloat = 1.5
        /// 是否可以输入小数点
        public var decimalCapable: Bool = true
        /// 按键高度
        public var keyButtonHeight: CGFloat = 55.0
        /// 按键标题字体
        public var textFont: UIFont?
        /// 是否乱序排列数字
        public var isScramble: Bool = false
        /// 左键类型
        public var leftKey: Key.Name = .none
        /// 右键类型
        public var rightKey: Key.Name = .none
        /// 按键标题颜色
        public var textColor: UIColor?
        /// 按键背景颜色
        public var keyBackgroundColor: UIColor?
        /// 按键高亮颜色
        public var keyHighlightedColor: UIColor?
        
        /// 键盘高度
        public var visibleHeight: CGFloat {
            let rows: Int = 12/columns
            return (spacing + keyButtonHeight)*CGFloat(rows) + MN_BOTTOM_SAFE_HEIGHT
        }
        
        public init() {}
    }
    
    /// 输入结果
    public private(set) var text: String = ""
    /// 事件代理
    public weak var delegate: MNNumberKeyboardDelegate?
    
    /// 数字键盘构造入口
    /// - Parameter options: 配置选项
    public required init(options: Options) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: options.visibleHeight))
        
        backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
        let columns: Int = options.columns
        let height: CGFloat = options.keyButtonHeight
        let spacing: CGFloat = max(options.spacing, 0.0)
        let width: CGFloat = ceil((frame.width - spacing*CGFloat(columns - 1))/CGFloat(columns))
        let textFont = options.textFont ?? .systemFont(ofSize: 20.0, weight: .medium)
        let textColor = options.textColor ?? .black
        let backgroundImage = UIImage(color: options.keyBackgroundColor ?? .white)
        let highlightedImage = UIImage(color: options.keyHighlightedColor ?? UIColor(red: 169.0/255.0, green: 169.0/255.0, blue: 169.0/255.0, alpha: 1.0))
        var keys: [MNNumberKeyboard.Key] = [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero]
        if options.isScramble {
            for index in 1..<keys.count {
                let random = Int(arc4random_uniform(100000)) % index
                if random != index {
                    keys.swapAt(index, random)
                }
            }
        }
        let last = keys.removeLast()
        keys.appendKey(options.leftKey)
        keys.append(last)
        keys.appendKey(options.rightKey)
        
        CGRect(x: 0.0, y: spacing, width: width, height: height).grid(offset: UIOffset(horizontal: spacing, vertical: spacing), count: keys.count, column: columns) { idx, rect, _ in
            
            let key = keys[idx]
            if key == .none { return }
            
            let button: UIButton = UIButton(type: .custom)
            if #available(iOS 15.0, *) {
                var attributedTitle = AttributedString(key.rawTitle)
                attributedTitle.font = key == .decimal ? .systemFont(ofSize: 37.0, weight: .bold) : textFont
                attributedTitle.foregroundColor = textColor
                var configuration = UIButton.Configuration.plain()
                configuration.titleAlignment = .center
                configuration.attributedTitle = attributedTitle
                configuration.background.backgroundColor = .clear
                button.configuration = configuration
                button.configurationUpdateHandler = { sender in
                    switch sender.state {
                    case .normal:
                        sender.configuration?.background.image = backgroundImage
                    case .highlighted:
                        sender.configuration?.background.image = highlightedImage
                    default: break
                    }
                }
            } else {
                let attributedTitle = NSMutableAttributedString(string: key.rawTitle)
                attributedTitle.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: attributedTitle.length))
                attributedTitle.addAttribute(.font, value: key == .decimal ? .systemFont(ofSize: 37.0, weight: .bold) : textFont, range: NSRange(location: 0, length: attributedTitle.length))
                button.contentVerticalAlignment = .center
                button.contentHorizontalAlignment = .center
                button.setAttributedTitle(attributedTitle, for: .normal)
                button.setBackgroundImage(backgroundImage, for: .normal)
                button.setBackgroundImage(highlightedImage, for: .highlighted)
            }
            button.frame = rect
            button.tag = key.rawValue
            button.addTarget(self, action: #selector(keyButtonTouchUpInside(_:)), for: .touchUpInside)
            addSubview(button)
        }
    }
    
    /// 以默认配置初始化键盘
    public convenience init() {
        self.init(options: Options())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 按键点击事件
    /// - Parameter sender: 按键
    @objc private func keyButtonTouchUpInside(_ sender: UIButton) {
        UIDevice.current.playInputClick()
        guard let key = MNNumberKeyboard.Key(rawValue: sender.tag) else { return }
        if (delegate?.numberKeyboard?(self, shouldInput: key) ?? true) == true {
            var inputed: Bool = false
            // 按键分析
            switch key {
            case .delete:
                // 删除
                if text.isEmpty == false {
                    inputed = true
                    text.removeLast()
                }
            case .clear:
                // 清空
                if text.isEmpty == false {
                    inputed = true
                    text.removeAll()
                }
            case .decimal:
                // 小数点
                let string = key.rawString
                if text.isEmpty == false, text.contains(string) == false {
                    inputed = true
                    let number = NSDecimalNumber(string: text)
                    text.removeAll()
                    text.append(number.stringValue)
                    text.append(string)
                }
            case .done, .none: break
            default:
                inputed = true
                text.append(key.rawString)
            }
            // 响应告知
            if inputed {
                delegate?.numberKeyboard?(self, didInput: key)
            }
        }
        // 点击告知
        delegate?.numberKeyboard?(self, didClick: key)
    }
}

extension MNNumberKeyboard {
    
    /// 设置字体
    /// - Parameters:
    ///   - font: 字体
    ///   - key: 按键类型
    public func setFont(_ font: UIFont, for key: MNNumberKeyboard.Key) {
        for subview in subviews {
            guard let k: MNNumberKeyboard.Key = MNNumberKeyboard.Key(rawValue: subview.tag) else { continue }
            guard k == key else { continue }
            guard let button = subview as? UIButton else { break }
            if #available(iOS 15.0, *) {
                guard var attributedTitle = button.configuration?.attributedTitle  else { break }
                attributedTitle.font = font
                button.configuration?.attributedTitle = attributedTitle
                button.updateConfiguration()
            } else {
                guard let attributedString = button.attributedTitle(for: .normal)  else { break }
                let attributedTitle = NSMutableAttributedString(attributedString: attributedString)
                attributedTitle.addAttribute(.font, value: font, range: NSRange(location: 0, length: attributedTitle.length))
                button.setAttributedTitle(attributedTitle, for: .normal)
            }
        }
    }
    
    /// 设置标题
    /// - Parameters:
    ///   - title: 标题
    ///   - key: 按键类型
    public func setTitle(_ title: String, for key: MNNumberKeyboard.Key) {
        for subview in subviews {
            guard let k: MNNumberKeyboard.Key = MNNumberKeyboard.Key(rawValue: subview.tag) else { continue }
            guard k == key else { continue }
            guard let button = subview as? UIButton else { break }
            if #available(iOS 15.0, *) {
                guard let attributedString = button.configuration?.attributedTitle  else { break }
                var attributedTitle = AttributedString(title)
                attributedTitle.font = attributedString.font
                attributedTitle.foregroundColor = attributedString.foregroundColor
                button.configuration?.attributedTitle = attributedTitle
                button.updateConfiguration()
            } else {
                guard let attributedString = button.attributedTitle(for: .normal)  else { break }
                let attributes = attributedString.attributes(at: 0, effectiveRange: nil)
                let attributedTitle = NSAttributedString(string: title, attributes: attributes)
                button.setAttributedTitle(attributedTitle, for: .normal)
            }
        }
    }
}

extension MNNumberKeyboard: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool { true }
}

extension MNNumberKeyboard.Key {
    
    fileprivate var rawTitle: String {
        if self == .decimal { return "·" }
        return rawString
    }
    
    fileprivate var rawString: String {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .decimal: return "."
        case .done: return "done"
        case .delete: return "delete"
        case .clear: return "clear"
        case .none: return ""
        }
    }
}

fileprivate extension Array where Element == MNNumberKeyboard.Key {
    
    mutating func appendKey(_ name: MNNumberKeyboard.Key.Name) {
        switch name {
        case .none:
            append(.none)
        case .decimal:
            append(.decimal)
        case .delete:
            append(.delete)
        case .clear:
            append(.clear)
        case .done:
            append(.done)
        }
    }
}
