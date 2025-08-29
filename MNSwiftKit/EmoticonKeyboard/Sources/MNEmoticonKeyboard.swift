//
//  MNEmoticonKeyboard.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情键盘

import UIKit

/// 表情键盘事件代理
@objc public protocol MNEmoticonKeyboardDelegate: NSObjectProtocol {
    /// 表情点击事件
    /// - Parameter emoji: 表情
    func emojiKeyboardDidTouchEmoji(_ emoji: MNEmoticon) -> Void
    /// Return键点击事件
    /// - Parameter keyboard: 表情键盘
    func emojiKeyboardReturnButtonTouchUpInside(_ keyboard: MNEmoticonKeyboard) -> Void
    /// 删除事件
    /// - Parameter keyboard: 表情键盘
    func emojiKeyboardDeleteButtonTouchUpInside(_ keyboard: MNEmoticonKeyboard) -> Void
    /// 收藏夹添加事件
    /// - Parameter keyboard: 表情键盘
    @objc optional func emojiKeyboardShouldAddToFavorites(_ keyboard: MNEmoticonKeyboard) -> Void
}

public class MNEmoticonKeyboard: UIView {
    /// 是否已加载表情包
    private var isLoaded: Bool = false
    /// 事件代理
    public weak var delegate: MNEmoticonKeyboardDelegate?
    /// 配置选项
    public private(set) var options: MNEmoticonKeyboardOptions = MNEmoticonKeyboardOptions()
    /// 表情包选择视图
    private lazy var packetView: MNEmoticonPacketView = {
        let packetView = MNEmoticonPacketView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: options.packetViewHeight + (options.axis == .horizontal ? MN_BOTTOM_SAFE_HEIGHT : 0.0)), options: options)
        if options.axis == .horizontal {
            packetView.maxY = frame.height
        } else if options.packets.count <= 1, options.hidesForSinglePacket {
            packetView.isHidden = true
        }
        packetView.proxy = self
        return packetView
    }()
    /// 页码选择器
    private lazy var pageControl: MNPageControl = {
        let pageControl = MNPageControl(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: options.pageControlHeight))
        if options.axis == .horizontal {
            pageControl.maxY = packetView.minY
        } else {
            pageControl.isHidden = true
        }
        pageControl.delegate = self
        pageControl.axis = .horizontal
        pageControl.spacing = 11.0
        pageControl.alignment = .center
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = .gray.withAlphaComponent(0.37)
        pageControl.currentPageIndicatorTintColor = .gray.withAlphaComponent(0.88)
        pageControl.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: pageControl.frame.height - 7.0, right: 0.0)
        pageControl.pageIndicatorTouchInset = UIEdgeInsets(top: 0.0, left: -pageControl.spacing/2.0, bottom: -pageControl.contentInset.bottom, right: -pageControl.spacing/2.0)
        pageControl.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        return pageControl
    }()
    /// 表情视图
    private lazy var emojiView: MNEmoticonInputView = {
        var rect: CGRect = .zero
        rect.origin.y = options.axis == .horizontal ? 0.0 : (packetView.isHidden ? 0.0 : packetView.maxY)
        rect.size.width = frame.width
        rect.size.height = options.axis == .horizontal ? pageControl.minY : (frame.height - (packetView.isHidden ? 0.0 : packetView.maxY))
        let emojiView = MNEmoticonInputView(frame: rect, options: options)
        emojiView.proxy = self
        emojiView.keyboardDismissMode = .none
        return emojiView
    }()
    
    /// 实例化键盘
    /// - Parameter options: 键盘选项
    public init(options: MNEmoticonKeyboardOptions) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: max(options.preferredHeight, options.leastNormalRect.height)))
        self.options = options
        isMultipleTouchEnabled = false
        backgroundColor = options.backgroundColor
        addSubview(packetView)
        addSubview(pageControl)
        insertSubview(emojiView, belowSubview: pageControl)
    }
    
    /// 依据默认配置构造
    public convenience init() {
        self.init(options: MNEmoticonKeyboardOptions())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置当前表情包
    /// - Parameter name: 表情包名称
    /// - Parameter animated: 是否动态
    public func setCurrentEmojiPacket(_ name: MNEmoticonPacket.Name, animated: Bool) {
        let index = emojiView.packets.firstIndex { $0.name == name.rawValue }
        guard let index = index else { return }
        setEmojiPacket(at: index, animated: animated)
    }
    
    /// 设置当前所在的表情包
    /// - Parameter index: 索引
    /// - Parameter animated: 是否动态
    public func setEmojiPacket(at index: Int, animated: Bool) {
        packetView.setSelected(at: index)
        emojiView.setCurrentPage(at: index, animated: animated)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let _ = superview, isLoaded == false else { return }
        isLoaded = true
        MNEmoticonManager.fetchEmojiPackets(with: options.packets) { [weak self] packets in
            guard let self = self else { return }
            self.packetView.reloadPackets(packets)
            self.emojiView.reloadPackets(packets)
            self.setEmojiPacket(at: self.packetView.selectedIndex, animated: false)
        }
    }
}

// MARK: - MNEmoticonPacketViewDelegate
extension MNEmoticonKeyboard: MNEmoticonPacketViewDelegate {
    
    func packetViewDidSelectPacket(at index: Int) {
        emojiView.setCurrentPage(at: index, animated: false)
    }
    
    func packetViewReturnButtonTouchUpInside(_ packetView: MNEmoticonPacketView) {
        delegate?.emojiKeyboardReturnButtonTouchUpInside(self)
    }
}

// MARK: - MNPageControlDelegate
extension MNEmoticonKeyboard: MNPageControlDelegate {
    
    public func pageControl(_ pageControl: MNPageControl, didSelectPageAt index: Int) {
        emojiView.scrollEmoji(to: index, animated: false)
    }
}

// MARK: - MNEmoticonInputViewDelegate
extension MNEmoticonKeyboard: MNEmoticonInputViewDelegate {
    
    func inputViewDidSelectPage(at index: Int) {
        packetView.selectedIndex = index
    }
    
    func inputViewDidUpdateEmoji(with count: Int) {
        guard pageControl.isHidden == false else { return }
        pageControl.numberOfPages = count
    }
    
    func inputViewDidScrollEmoji(to index: Int) {
        guard pageControl.isHidden == false else { return }
        pageControl.currentPageIndex = index
    }
    
    func inputViewDidSelectEmoji(_ emoji: MNEmoticon) {
        delegate?.emojiKeyboardDidTouchEmoji(emoji)
    }
    
    func inputViewShouldAddToFavorites(_ inputView: MNEmoticonInputView) {
        delegate?.emojiKeyboardShouldAddToFavorites?(self)
    }
    
    func inputViewDeleteButtonTouchUpInside(_ inputView: MNEmoticonInputView) {
        delegate?.emojiKeyboardDeleteButtonTouchUpInside(self)
    }
    
    func inputViewReturnButtonTouchUpInside(_ inputView: MNEmoticonInputView) {
        delegate?.emojiKeyboardReturnButtonTouchUpInside(self)
    }
}

// MARK: - UIInputViewAudioFeedback
extension MNEmoticonKeyboard: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool { options.enableFeedbackWhenInputClicks }
}
