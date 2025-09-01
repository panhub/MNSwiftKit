//
//  MNEmoticonInputView.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情输入复合视图

import UIKit

/// 表情输入视图事件代理
protocol MNEmoticonInputViewDelegate: NSObjectProtocol {
    /// 表情包切换时告知
    /// - Parameter index: 表情包索引
    func inputViewDidSelectPage(at index: Int)
    /// 告知当前表情包页数
    /// - Parameter count: 页数
    func inputViewDidUpdateEmoticon(with count: Int)
    /// 告知当前表情包页码
    /// - Parameter index: 页码
    func inputViewDidScrollEmoticon(to index: Int)
    /// 表情选择告知
    /// - Parameter emoticon: 表情
    func inputViewDidSelectEmoticon(_ emoticon: MNEmoticon)
    /// 收藏夹添加事件告知
    /// - Parameter inputView: 输入复合视图
    func inputViewShouldAddToFavorites(_ inputView: MNEmoticonInputView)
    /// 删除按钮事件告知
    /// - Parameter inputView: 输入复合视图
    func inputViewDeleteButtonTouchUpInside(_ inputView: MNEmoticonInputView)
    /// Return键事件告知
    /// - Parameter inputView: 输入复合视图
    func inputViewReturnButtonTouchUpInside(_ inputView: MNEmoticonInputView)
}

/// 表情输入视图
class MNEmoticonInputView: UIView {
    /// 样式
    private let style: MNEmoticonKeyboard.Style
    /// 配置选项
    private let options: MNEmoticonKeyboard.Options
    /// 事件代理
    weak var delegate: MNEmoticonInputViewDelegate?
    /// 表情包
    private(set) var packets: [MNEmoticon.Packet] = []
    /// 缓存
    private var emoticonViews: [Int:MNEmoticonView] = [:]
    /// 预览视图
    private let preview: MNEmoticonPreview = MNEmoticonPreview()
    /// 分割线
    private let separatorView = UIView()
    /// 分页控制视图
    private let pageView = MNEmoticonPageView()
    /// 猜想滑动到的界面索引
    private var guessPageIndex: Int = 0
    /// 开始滑动时的偏移
    private var startOffsetX: CGFloat = 0.0
    /// 选择的页面索引
    private var selectedIndex: Int = 0
    
    /// 构建表情输入视图
    /// - Parameters:
    ///   - style: 样式
    ///   - options: 键盘配置
    init(style: MNEmoticonKeyboard.Style, options: MNEmoticonKeyboard.Options) {
        self.style = style
        self.options = options
        super.init(frame: .zero)
        
        clipsToBounds = false
        backgroundColor = .clear
        
        separatorView.backgroundColor = options.separatorColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.7)
        ])
        
        pageView.delegate = self
        pageView.axis = .horizontal
        pageView.backgroundColor = .clear
        pageView.keyboardDismissMode = .none
        pageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageView)
        NSLayoutConstraint.activate([
            pageView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            pageView.leftAnchor.constraint(equalTo: leftAnchor),
            pageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        preview.isHidden = true
        addSubview(preview)
        
        NotificationCenter.default.addObserver(self, selector: #selector(emoticonDidChangeNotification(_:)), name: MNEmoticonDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 更新表情包
    /// - Parameter packets: 表情包集合
    func reloadPackets(_ packets: [MNEmoticon.Packet]) {
        // 删除子界面
        emoticonViews.forEach { $0.value.removeFromSuperview() }
        emoticonViews.removeAll()
        // 重载数据
        self.packets.removeAll()
        self.packets.append(contentsOf: packets)
        // 刷新页面
        pageView.numberOfPages = packets.count
        pageView.currentPageIndex = 0
        selectedIndex = 0
    }
    
    /// 设置当前页码
    /// - Parameters:
    ///   - pageIndex: 页码
    ///   - animated: 是否动态
    func setCurrentPage(at pageIndex: Int, animated: Bool) {
        guard pageIndex < packets.count else { return }
        pageView.setCurrentPage(at: pageIndex, animated: animated)
        selectedIndex = pageView.currentPageIndex
        guard let emoticonView = emoticonView(at: pageIndex) else { return }
        emoticonView.setCurrentPage(at: 0, animated: false)
        guard style == .paging, let delegate = delegate else { return }
        delegate.inputViewDidUpdateEmoticon(with: emoticonView.numberOfPages)
        delegate.inputViewDidScrollEmoticon(to: emoticonView.currentPageIndex)
    }
    
    /// 滑动表情到指定页码
    /// - Parameters:
    ///   - pageIndex: 页码
    ///   - animated: 是否动态
    func scrollEmoticon(to pageIndex: Int, animated: Bool) {
        guard let emoticonView = emoticonView(at: pageView.currentPageIndex, create: false) else { return }
        emoticonView.setCurrentPage(at: pageIndex, animated: animated)
    }
    
    /// 获取子界面
    /// - Parameters:
    ///   - pageIndex: 页码
    ///   - create: 没有缓存时是否允许创建
    /// - Returns: 表情子界面
    func emoticonView(at pageIndex: Int, create: Bool = true) -> MNEmoticonView? {
        if let inputView = emoticonViews[pageIndex] { return inputView }
        guard create else { return nil }
        guard pageIndex < packets.count else { return nil }
        let emoticonView = MNEmoticonView(style: style, options: options)
        emoticonView.delegate = self
        emoticonView.translatesAutoresizingMaskIntoConstraints = false
        pageView.addSubview(emoticonView)
        NSLayoutConstraint.activate([
            emoticonView.leftAnchor.constraint(equalTo: pageView.leftAnchor, constant: pageView.contentOffset(for: pageIndex).x),
            emoticonView.widthAnchor.constraint(equalTo: pageView.widthAnchor),
            emoticonView.topAnchor.constraint(equalTo: pageView.topAnchor),
            emoticonView.heightAnchor.constraint(equalTo: pageView.heightAnchor)
        ])
        emoticonViews[pageIndex] = emoticonView
        pageView.layoutIfNeeded()
        let packet = packets[pageIndex]
        emoticonView.reloadEmoticon(packet: packet)
        return emoticonView
    }
}

// MARK: - Notification
extension MNEmoticonInputView {
    
    /// 添加图片到收藏夹事件
    /// - Parameter notify: 通知
    @objc private func emoticonDidChangeNotification(_ notify: Notification) {
        guard let userInfo = notify.userInfo else { return }
        guard let name = userInfo[MNEmoticonPacketNameUserInfoKey] as? String else { return }
        guard let pageIndex = packets.firstIndex(where: { $0.name == name }) else { return }
        MNEmoticonManager.fetchEmoticonPacket([name]) { [weak self] packets in
            guard let self = self, let packet = packets.first else { return }
            guard let emoticonView = emoticonView(at: pageIndex, create: false) else { return }
            emoticonView.reloadEmoticon(packet: packet)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MNEmoticonInputView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guessPageIndex = pageView.currentPageIndex
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
            guard let emoticonView = emoticonView(at: guessPageIndex) else { return }
            emoticonView.setCurrentPage(at: 0, animated: false)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPageIndex = pageView.currentPageIndex
        if selectedIndex == currentPageIndex { return }
        selectedIndex = currentPageIndex
        guard let delegate = delegate else { return }
        guard let emoticonView = emoticonView(at: currentPageIndex) else { return }
        delegate.inputViewDidSelectPage(at: currentPageIndex)
        delegate.inputViewDidUpdateEmoticon(with: emoticonView.numberOfPages)
        delegate.inputViewDidScrollEmoticon(to: emoticonView.currentPageIndex)
    }
}

// MARK: - MNEmoticonViewDelegate
extension MNEmoticonInputView: MNEmoticonViewDelegate {
    
    func emoticonViewDidSelectEmoticon(_ emoji: MNEmoticon) {
        guard let delegate = delegate else { return }
        delegate.inputViewDidSelectEmoticon(emoji)
    }
    
    func emoticonViewShouldAddToFavorites(_ emojiView: MNEmoticonView) {
        guard let delegate = delegate else { return }
        delegate.inputViewShouldAddToFavorites(self)
    }
    
    func emoticonViewDeleteButtonTouchUpInside(_ emojiView: MNEmoticonView) {
        guard let delegate = delegate else { return }
        delegate.inputViewDeleteButtonTouchUpInside(self)
    }
    
    func emoticonViewReturnButtonTouchUpInside(_ emojiView: MNEmoticonView) {
        guard let delegate = delegate else { return }
        delegate.inputViewReturnButtonTouchUpInside(self)
    }
    
    func emoticonViewDidScrollPage(to index: Int) {
        guard let delegate = delegate else { return }
        delegate.inputViewDidScrollEmoticon(to: index)
    }
    
    func emoticonViewShouldPreviewEmoticon(_ emoticon: MNEmoticon?, at rect: CGRect) {
        if let emoticon = emoticon {
            var frame = preview.frame
            frame.origin = .init(x: rect.midX - frame.width/2.0, y: rect.maxY - frame.height)
            preview.frame = frame
            preview.updateEmoticon(emoticon)
            preview.isHidden = false
        } else {
            preview.isHidden = true
        }
    }
}
