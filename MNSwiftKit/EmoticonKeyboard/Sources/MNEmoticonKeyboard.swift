//
//  MNEmoticonKeyboard.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情键盘

import UIKit

/// 表情键盘事件代理
@objc public protocol MNEmoticonKeyboardDelegate: NSObjectProtocol {
    /// 表情点击事件
    /// - Parameters:
    ///   - emoticon: 表情图片
    ///   - desc: 表情描述
    ///   - style: 样式
    func emoticonKeyboardShouldInput(emoticon: UIImage!, desc: String, style: MNEmoticon.Style)
    /// Return键点击事件
    /// - Parameter keyboard: 表情键盘
    func emoticonKeyboardReturnButtonTouchUpInside(_ keyboard: MNEmoticonKeyboard)
    /// 删除事件
    /// - Parameter keyboard: 表情键盘
    func emoticonKeyboardDeleteButtonTouchUpInside(_ keyboard: MNEmoticonKeyboard)
    /// 收藏夹添加事件
    /// - Parameter keyboard: 表情键盘
    @objc optional func emoticonKeyboardShouldAddToFavorites(_ keyboard: MNEmoticonKeyboard)
}

public class MNEmoticonKeyboard: UIView {
    /// 标记需要加载表情包
    private var needsReloadEmoticonPacket: Bool = true
    /// 事件代理
    public weak var delegate: MNEmoticonKeyboardDelegate?
    /// 样式
    private let style: MNEmoticonKeyboard.Style
    /// 配置选项
    public let options: MNEmoticonKeyboard.Options
    /// 页码选择器
    private lazy var pageControl = MNPageControl()
    /// 表情包选择视图
    private lazy var packetView = MNEmoticonPacketView(style: style, options: options)
    /// 表情视图
    private lazy var emoticonView = MNEmoticonInputView(style: style, options: options)
    
    /// 构建表情键盘
    /// - Parameters:
    ///   - frame: 位置
    ///   - style: 样式
    ///   - options: 配置
    public init(frame: CGRect, style: MNEmoticonKeyboard.Style = .compact, options: MNEmoticonKeyboard.Options = .init()) {
        self.style = style
        self.options = options
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        backgroundColor = options.backgroundColor
        
        switch style {
        case .compact:
            // 纵向滑动
            packetView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(packetView)
            NSLayoutConstraint.activate([
                packetView.topAnchor.constraint(equalTo: topAnchor),
                packetView.leftAnchor.constraint(equalTo: leftAnchor),
                packetView.rightAnchor.constraint(equalTo: rightAnchor),
                packetView.heightAnchor.constraint(equalToConstant: 50.0)
            ])
            
            emoticonView.delegate = self
            emoticonView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(emoticonView)
            NSLayoutConstraint.activate([
                emoticonView.topAnchor.constraint(equalTo: packetView.bottomAnchor),
                emoticonView.leftAnchor.constraint(equalTo: leftAnchor),
                emoticonView.bottomAnchor.constraint(equalTo: bottomAnchor),
                emoticonView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        case .paging:
            // 横向分页滑动
            packetView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(packetView)
            NSLayoutConstraint.activate([
                packetView.leftAnchor.constraint(equalTo: leftAnchor),
                packetView.bottomAnchor.constraint(equalTo: bottomAnchor),
                packetView.rightAnchor.constraint(equalTo: rightAnchor),
                packetView.heightAnchor.constraint(equalToConstant: 50.0 + MN_BOTTOM_SAFE_HEIGHT)
            ])
            
            pageControl.delegate = self
            pageControl.axis = .horizontal
            pageControl.spacing = 11.0
            pageControl.hidesForSinglePage = true
            pageControl.contentVerticalAlignment = .top
            pageControl.contentHorizontalAlignment = .center
            pageControl.pageIndicatorSize = .init(width: 7.0, height: 7.0)
            pageControl.pageIndicatorTintColor = .gray.withAlphaComponent(0.37)
            pageControl.currentPageIndicatorTintColor = .gray.withAlphaComponent(0.88)
            pageControl.translatesAutoresizingMaskIntoConstraints = false
            addSubview(pageControl)
            NSLayoutConstraint.activate([
                pageControl.leftAnchor.constraint(equalTo: leftAnchor),
                pageControl.bottomAnchor.constraint(equalTo: packetView.topAnchor),
                pageControl.rightAnchor.constraint(equalTo: rightAnchor),
                pageControl.heightAnchor.constraint(equalToConstant: 20.0)
            ])
            emoticonView.delegate = self
            emoticonView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(emoticonView)
            NSLayoutConstraint.activate([
                emoticonView.topAnchor.constraint(equalTo: topAnchor),
                emoticonView.leftAnchor.constraint(equalTo: leftAnchor),
                emoticonView.bottomAnchor.constraint(equalTo: pageControl.topAnchor),
                emoticonView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(removedEmoticonPacket(_:)), name: MNEmoticonPacketRemovedNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 设置当前表情包
    /// - Parameter name: 表情包名称
    /// - Parameter animated: 是否动态
    public func setCurrentEmoticonPacket(_ name: String, animated: Bool) {
        guard let index = emoticonView.packets.firstIndex(where: { $0.name == name }) else { return }
        setEmoticonPacket(at: index, animated: animated)
    }
    
    /// 设置当前所在的表情包
    /// - Parameter index: 索引
    /// - Parameter animated: 是否动态
    public func setEmoticonPacket(at index: Int, animated: Bool) {
        packetView.setSelected(at: index)
        emoticonView.setCurrentPage(at: index, animated: animated)
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard needsReloadEmoticonPacket else { return }
        needsReloadEmoticonPacket = false
        reloadEmoticonPackets()
    }
    
    /// 重载表情包
    private func reloadEmoticonPackets() {
        MNEmoticonManager.fetchEmoticonPacket(options.packets) { [weak self] packets in
            guard let self = self else { return }
            self.packetView.reloadPackets(packets)
            self.emoticonView.reloadPackets(packets)
            self.setEmoticonPacket(at: self.packetView.selectedIndex, animated: false)
        }
    }
}

// MARK: - Notification
extension MNEmoticonKeyboard {
    
    /// 删除表情包通知
    @objc private func removedEmoticonPacket(_ notify: Notification) {
        guard let userInfo = notify.userInfo, let name = userInfo[MNEmoticonPacketNameUserInfoKey] as? String else { return }
        guard emoticonView.packets.contains(where: { $0.name == name }) else { return }
        if let _ = window {
            reloadEmoticonPackets()
        } else {
            needsReloadEmoticonPacket = true
        }
    }
}

// MARK: - MNEmoticonPacketViewDelegate
extension MNEmoticonKeyboard: MNEmoticonPacketViewDelegate {
    
    func packetViewDidSelectPacket(at index: Int) {
        emoticonView.setCurrentPage(at: index, animated: false)
    }
    
    func packetViewReturnButtonTouchUpInside(_ packetView: MNEmoticonPacketView) {
        guard let delegate = delegate else { return }
        delegate.emoticonKeyboardReturnButtonTouchUpInside(self)
    }
}

// MARK: - MNPageControlDelegate
extension MNEmoticonKeyboard: MNPageControlDelegate {
    
    public func pageControl(_ pageControl: MNPageControl, didSelectPageAt index: Int) {
        emoticonView.scrollEmoticon(to: index, animated: false)
    }
}

// MARK: - MNEmoticonInputViewDelegate
extension MNEmoticonKeyboard: MNEmoticonInputViewDelegate {
    
    func inputViewDidSelectPage(at index: Int) {
        packetView.selectedIndex = index
    }
    
    func inputViewDidUpdateEmoticon(with count: Int) {
        guard pageControl.isHidden == false else { return }
        pageControl.numberOfPages = count
    }
    
    func inputViewDidScrollEmoticon(to index: Int) {
        guard pageControl.isHidden == false else { return }
        pageControl.currentPageIndex = index
    }
    
    func inputViewDidSelectEmoticon(_ emoticon: MNEmoticon) {
        guard let delegate = delegate else { return }
        delegate.emoticonKeyboardShouldInput(emoticon: emoticon.image, desc: emoticon.desc, style: emoticon.style)
    }
    
    func inputViewShouldAddToFavorites(_ inputView: MNEmoticonInputView) {
        guard let delegate = delegate else { return }
        delegate.emoticonKeyboardShouldAddToFavorites?(self)
    }
    
    func inputViewDeleteButtonTouchUpInside(_ inputView: MNEmoticonInputView) {
        guard let delegate = delegate else { return }
        delegate.emoticonKeyboardDeleteButtonTouchUpInside(self)
    }
    
    func inputViewReturnButtonTouchUpInside(_ inputView: MNEmoticonInputView) {
        guard let delegate = delegate else { return }
        delegate.emoticonKeyboardReturnButtonTouchUpInside(self)
    }
}

// MARK: - UIInputViewAudioFeedback
extension MNEmoticonKeyboard: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool { options.enableFeedbackWhenInputClicks }
}
