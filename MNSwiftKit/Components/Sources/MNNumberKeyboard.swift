//
//  MNNumberKeyboard.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/9/28.
//  数字键盘

import UIKit

/// 数字键盘代理
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
    func numberKeyboard(_ keyboard: MNNumberKeyboard, didInput key: MNNumberKeyboard.Key)
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
    public struct Configuration {
        /// 列数
        public let columns: Int = 3
        /// 按键间隔
        public var spacing: CGFloat = 1.5
        /// 是否可以输入小数点
        public var decimalCapable: Bool = true
        /// 按键标题字体
        public var textFont: UIFont?
        /// 是否乱序排列数字
        public var isScramble: Bool = false
        /// 左键类型
        public var leftKeyName: Key.Name = .none
        /// 右键类型
        public var rightKeyName: Key.Name = .none
        /// 按键标题颜色
        public var textColor: UIColor?
        /// 按键背景颜色
        public var keyBackgroundColor: UIColor?
        /// 按键高亮颜色
        public var keyHighlightedColor: UIColor?
        
        public init() {}
    }
    
    /// 输入结果
    public private(set) var text: String = ""
    
    /// 内部布局视图
    private let stackView = UIStackView()
    
    /// 事件代理
    public weak var delegate: MNNumberKeyboardDelegate?
    
    
    /// 构造数字键盘
    /// - Parameters:
    ///   - frame: 位置
    ///   - configuration: 配置信息
    public init(frame: CGRect, configuration: Configuration) {
        super.init(frame: frame)
        
        var keys: [MNNumberKeyboard.Key] = [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero]
        if configuration.isScramble {
            for index in 1..<keys.count {
                let random = Int(arc4random_uniform(100000)) % index
                if random != index {
                    keys.swapAt(index, random)
                }
            }
        }
        keys.insertKey(configuration.leftKeyName, at: keys.count - 2)
        keys.appendKey(configuration.rightKeyName)
        
        let elements: [[MNNumberKeyboard.Key]] = stride(from: 0, to: keys.count, by: 3).map {
            Array(keys[$0..<Swift.min($0 + 3, keys.count)])
        }
        
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = configuration.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: configuration.spacing),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -configuration.spacing)
        ])
        
        let textFont = configuration.textFont ?? .systemFont(ofSize: 20.0, weight: .medium)
        let textColor = configuration.textColor ?? .black
        let backgroundImage = UIImage(color: configuration.keyBackgroundColor ?? .white)
        let highlightedImage = UIImage(color: configuration.keyHighlightedColor ?? UIColor(red: 169.0/255.0, green: 169.0/255.0, blue: 169.0/255.0, alpha: 1.0))
        
        for element in elements {
            
            let arrangedStackView = UIStackView()
            arrangedStackView.axis = .horizontal
            arrangedStackView.alignment = .fill
            arrangedStackView.distribution = .fillEqually
            arrangedStackView.spacing = configuration.spacing
            stackView.addArrangedSubview(arrangedStackView)
            
            for key in element {
                
                let button: UIButton = UIButton(type: .custom)
                if #available(iOS 15.0, *) {
                    var attributedTitle = AttributedString(key.text)
                    attributedTitle.font = textFont
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
                    let attributedTitle = NSAttributedString(string: key.text, attributes: [.font : textFont, .foregroundColor : textColor])
                    button.contentVerticalAlignment = .center
                    button.contentHorizontalAlignment = .center
                    button.setAttributedTitle(attributedTitle, for: .normal)
                    button.setBackgroundImage(backgroundImage, for: .normal)
                    button.setBackgroundImage(highlightedImage, for: .highlighted)
                }
                button.tag = key.rawValue
                button.alpha = key == .none ? 0.0 : 1.0
                button.addTarget(self, action: #selector(keyButtonTouchUpInside(_:)), for: .touchUpInside)
                arrangedStackView.addArrangedSubview(button)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 按键点击事件
    /// - Parameter sender: 按键
    @objc private func keyButtonTouchUpInside(_ sender: UIButton) {
        UIDevice.current.playInputClick()
        guard let key = MNNumberKeyboard.Key(rawValue: sender.tag) else { return }
        if let delegate = delegate, let shouldInput = delegate.numberKeyboard?(self, shouldInput: key), shouldInput == false { return }
        var inputed = false
        // 按键分析
        switch key {
        case .delete:
            // 删除
            guard text.isEmpty == false else { break }
            text.removeLast()
            inputed = true
        case .clear:
            // 清空
            guard text.isEmpty == false else { break }
            text.removeAll()
            inputed = true
        case .decimal:
            // 小数点
            let string = key.text
            if text.isEmpty == false, text.contains(string) == false {
                let number = NSDecimalNumber(string: text)
                text.removeAll()
                text.append(number.stringValue)
                text.append(string)
                inputed = true
            }
        case .done, .none: break
        default:
            inputed = true
            text.append(key.text)
        }
        // 输入后告知
        if inputed, let delegate = delegate {
            delegate.numberKeyboard(self, didInput: key)
        }
    }
}

extension MNNumberKeyboard {
    
    /// 设置字体
    /// - Parameters:
    ///   - font: 字体
    ///   - key: 按键类型
    public func setFont(_ font: UIFont, for key: MNNumberKeyboard.Key) {
        let stackViews = stackView.arrangedSubviews.compactMap { $0 as? UIStackView }
        let buttons = stackViews.flatMap { $0.arrangedSubviews.compactMap { $0 as? UIButton }}
        for button in buttons {
            guard let k: MNNumberKeyboard.Key = MNNumberKeyboard.Key(rawValue: button.tag) else { continue }
            guard k == key else { continue }
            if #available(iOS 15.0, *) {
                guard let configuration = button.configuration, var attributedTitle = configuration.attributedTitle else { break }
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
        let stackViews = stackView.arrangedSubviews.compactMap { $0 as? UIStackView }
        let buttons = stackViews.flatMap { $0.arrangedSubviews.compactMap { $0 as? UIButton }}
        for button in buttons {
            guard let k: MNNumberKeyboard.Key = MNNumberKeyboard.Key(rawValue: button.tag) else { continue }
            guard k == key else { continue }
            if #available(iOS 15.0, *) {
                guard let configuration = button.configuration, let attributedString = configuration.attributedTitle  else { break }
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
    
    fileprivate var text: String {
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
    
    mutating func insertKey(_ name: MNNumberKeyboard.Key.Name, at index: Int) {
        switch name {
        case .none:
            insert(.none, at: index)
        case .decimal:
            insert(.decimal, at: index)
        case .delete:
            insert(.delete, at: index)
        case .clear:
            insert(.clear, at: index)
        case .done:
            insert(.done, at: index)
        }
    }
}
