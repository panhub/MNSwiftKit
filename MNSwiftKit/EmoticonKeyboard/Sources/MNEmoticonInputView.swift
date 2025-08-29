//
//  MNEmoticonInputView.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情输入复合视图

import UIKit

/// 表情输入视图事件代理
protocol MNEmoticonInputViewDelegate: NSObjectProtocol {
    /// 表情包切换时告知
    /// - Parameter index: 表情包索引
    func inputViewDidSelectPage(at index: Int) -> Void
    /// 告知当前表情包页数
    /// - Parameter count: 页数
    func inputViewDidUpdateEmoji(with count: Int) -> Void
    /// 告知当前表情包页码
    /// - Parameter index: 页码
    func inputViewDidScrollEmoji(to index: Int) -> Void
    /// 表情选择告知
    /// - Parameter emoji: 表情
    func inputViewDidSelectEmoji(_ emoji: MNEmoticon) -> Void
    /// 收藏夹添加事件告知
    /// - Parameter inputView: 输入复合视图
    func inputViewShouldAddToFavorites(_ inputView: MNEmoticonInputView) -> Void
    /// 删除按钮事件告知
    /// - Parameter inputView: 输入复合视图
    func inputViewDeleteButtonTouchUpInside(_ inputView: MNEmoticonInputView) -> Void
    /// Return键事件告知
    /// - Parameter inputView: 输入复合视图
    func inputViewReturnButtonTouchUpInside(_ inputView: MNEmoticonInputView) -> Void
}

/// 表情输入视图
class MNEmoticonInputView: MNPageScrollView {
    /// 配置选项
    private let options: MNEmoticonKeyboardOptions
    /// 表情包
    private(set) var packets: [MNEmoticonPacket] = [MNEmoticonPacket]()
    /// 缓存
    private var emojiViews: [Int:MNEmoticonView] = [Int:MNEmoticonView]()
    /// 预览视图
    private let preview: MNEmoticonPreview = MNEmoticonPreview()
    /// 开始滑动时的偏移
    private var startOffsetX: CGFloat = 0.0
    /// 猜想滑动到的界面索引
    private var guessPageIndex: Int = 0
    /// 事件代理
    weak var proxy: MNEmoticonInputViewDelegate?
    /// 选择的页面索引
    private var selectedIndex: Int = 0
    /// 分割线
    private lazy var separator: UIView = {
        let separator: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: 0.7))
        separator.backgroundColor = options.separatorColor
        separator.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        return separator
    }()
    
    init(frame: CGRect, options: MNEmoticonKeyboardOptions) {
        self.options = options
        super.init(frame: frame)
        
        delegate = self
        clipsToBounds = false
        backgroundColor = .clear
        
        separator.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: 0.7)
        separator.backgroundColor = options.separatorColor
        addSubview(separator)
        
        preview.isHidden = true
        addSubview(preview)
        
        NotificationCenter.default.addObserver(self, selector: #selector(emojiDidChangeNotification(_:)), name: MNEmoticonDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 更新表情包
    /// - Parameter packets: 表情包集合
    func reloadPackets(_ packets: [MNEmoticonPacket]) {
        // 删除子界面
        for (_, emojiView) in emojiViews {
            emojiView.removeFromSuperview()
        }
        emojiViews.removeAll()
        // 重载数据
        self.packets.removeAll()
        self.packets.append(contentsOf: packets)
        // 刷新页面
        numberOfPages = packets.count
        currentPageIndex = 0
        selectedIndex = 0
    }
    
    /// 设置当前页码
    /// - Parameters:
    ///   - pageIndex: 页码
    ///   - animated: 是否动态
    override func setCurrentPage(at pageIndex: Int, animated: Bool) {
        guard pageIndex < packets.count else { return }
        super.setCurrentPage(at: pageIndex, animated: animated)
        selectedIndex = currentPageIndex
        guard let emojiView = emojiView(at: pageIndex) else { return }
        emojiView.setCurrentPage(at: 0, animated: false)
        proxy?.inputViewDidUpdateEmoji(with: emojiView.numberOfPages)
        proxy?.inputViewDidScrollEmoji(to: emojiView.currentPageIndex)
    }
    
    /// 滑动表情到指定页码
    /// - Parameters:
    ///   - pageIndex: 页码
    ///   - animated: 是否动态
    func scrollEmoji(to pageIndex: Int, animated: Bool) {
        guard let emojiView = emojiView(at: currentPageIndex, allowsAcquire: false) else { return }
        emojiView.setCurrentPage(at: pageIndex, animated: animated)
    }
    
    /// 获取子界面
    /// - Parameters:
    ///   - pageIndex: 页码
    ///   - allowsAcquire: 是否允许存取
    /// - Returns: 表情子界面
    func emojiView(at pageIndex: Int, allowsAcquire: Bool = true) -> MNEmoticonView? {
        if let inputView = emojiViews[pageIndex] { return inputView }
        guard allowsAcquire else { return nil }
        guard pageIndex < packets.count else { return nil }
        let emojiView = MNEmoticonView(frame: bounds, options: options)
        emojiView.proxy = self
        emojiView.origin = contentOffset(for: pageIndex)
        emojiView.reloadEmojis(packets[pageIndex])
        insertSubview(emojiView, belowSubview: separator)
        emojiViews[pageIndex] = emojiView
        return emojiView
    }
}

// MARK: - Notification
extension MNEmoticonInputView {
    
    /// 添加图片到收藏夹事件
    /// - Parameter notify: 通知
    @objc private func emojiDidChangeNotification(_ notify: Notification) {
        guard let userInfo = notify.userInfo else { return }
        guard let name = userInfo[MNEmoticonPacketNameUserInfoKey] as? MNEmoticonPacket.Name else { return }
        guard let pageIndex = packets.firstIndex(where: { $0.name == name.rawValue }) else { return }
        let packet = packets[pageIndex]
        if let emoji = userInfo[MNEmoticonAddedUserInfoKey] as? MNEmoticon {
            // 添加事件
            packet.emojis.insert(emoji, at: 1)
        } else if let emoji = userInfo[MNEmoticonRemovedUserInfoKey] as? MNEmoticon {
            // 删除事件
            guard let desc = emoji.desc else { return }
            packet.emojis.removeAll { $0.desc == desc }
        }
        guard let emojiView = emojiView(at: pageIndex, allowsAcquire: false) else { return }
        emojiView.reloadEmojis(packet)
    }
}

// MARK: - UIScrollViewDelegate
extension MNEmoticonInputView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guessPageIndex = currentPageIndex
        if let x = scrollView.value(forKey: "startOffsetX") as? CGFloat {
            startOffsetX = x
        } else {
            startOffsetX = scrollView.contentOffset.x
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging, scrollView.isDecelerating == false else { return }
        let lastGuessIndex = guessPageIndex
        let width: CGFloat = scrollView.frame.width
        let offsetX: CGFloat = scrollView.contentOffset.x
        let ratio = offsetX/width
        if offsetX > startOffsetX {
            guessPageIndex = Int(ceil(ratio))
        } else {
            guessPageIndex = Int(floor(ratio))
        }
        // 更新界面
        if guessPageIndex != lastGuessIndex, guessPageIndex != selectedIndex {
            guard let emojiView = emojiView(at: guessPageIndex) else { return }
            emojiView.setCurrentPage(at: 0, animated: false)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPageIndex = currentPageIndex
        if selectedIndex == currentPageIndex { return }
        selectedIndex = currentPageIndex
        guard let emojiView = emojiView(at: currentPageIndex) else { return }
        proxy?.inputViewDidSelectPage(at: currentPageIndex)
        proxy?.inputViewDidUpdateEmoji(with: emojiView.numberOfPages)
        proxy?.inputViewDidScrollEmoji(to: emojiView.currentPageIndex)
    }
}

// MARK: - MNEmojiViewDelegate
extension MNEmoticonInputView: MNEmojiViewDelegate {
    
    func emojiViewDidSelectEmoji(_ emoji: MNEmoticon) {
        proxy?.inputViewDidSelectEmoji(emoji)
    }
    
    func emojiViewShouldAddToFavorites(_ emojiView: MNEmoticonView) {
        proxy?.inputViewShouldAddToFavorites(self)
    }
    
    func emojiViewDeleteButtonTouchUpInside(_ emojiView: MNEmoticonView) {
        proxy?.inputViewDeleteButtonTouchUpInside(self)
    }
    
    func emojiViewReturnButtonTouchUpInside(_ emojiView: MNEmoticonView) {
        proxy?.inputViewReturnButtonTouchUpInside(self)
    }
    
    func emojiViewDidScrollPage(to index: Int) {
        proxy?.inputViewDidScrollEmoji(to: index)
    }
    
    func emojiViewShouldPreviewEmoji(_ emoji: MNEmoticon?, at rect: CGRect) {
        if let emoji = emoji {
            preview.midX = rect.midX
            preview.maxY = rect.maxY
            preview.updateEmoji(emoji)
            preview.isHidden = false
        } else {
            preview.isHidden = true
        }
    }
}
