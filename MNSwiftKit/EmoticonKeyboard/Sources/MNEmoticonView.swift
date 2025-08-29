//
//  MNEmoticonView.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情分页

import UIKit

/// 表情视图事件代理
protocol MNEmojiViewDelegate: NSObjectProtocol {
    /// 表情选择告知
    /// - Parameter emoji: 表情
    func emojiViewDidSelectEmoji(_ emoji: MNEmoticon) -> Void
    /// 收藏夹添加事件告知
    /// - Parameter emojiView: 表情视图
    func emojiViewShouldAddToFavorites(_ emojiView: MNEmoticonView) -> Void
    /// Delete键事件告知
    /// - Parameter emojiView: 表情视图
    func emojiViewDeleteButtonTouchUpInside(_ emojiView: MNEmoticonView) -> Void
    /// Return键事件告知
    /// - Parameter emojiView: 表情视图
    func emojiViewReturnButtonTouchUpInside(_ emojiView: MNEmoticonView) -> Void
    /// 当前页码告知
    /// - Parameter index: 页码
    func emojiViewDidScrollPage(to index: Int) -> Void
    /// 预览事件告知
    /// - Parameters:
    ///   - emoji: 表情
    ///   - rect: 位置
    func emojiViewShouldPreviewEmoji(_ emoji: MNEmoticon?, at rect: CGRect) -> Void
}

class MNEmoticonView: MNPageScrollView {
    /// 表情包
    private var packet: MNEmoticonPacket!
    /// 按钮缓存
    private var buttons: [MNEmoticonButton] = [MNEmoticonButton]()
    /// 配置选项
    private let options: MNEmoticonKeyboardOptions
    /// 事件代理
    weak var proxy: MNEmojiViewDelegate?
    /// 功能视图
    private lazy var elementView: MNEmoticonElementView = {
        return MNEmoticonElementView(options: options)
    }()
    /// 表情展示
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .zero
        layout.sectionInset = .zero
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.headerReferenceSize = .zero
        layout.footerReferenceSize = .zero
        let collectionView = UICollectionView(frame: bounds, layout: layout)
        collectionView.tag = 1
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .none
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MNEmoticonCell.self, forCellWithReuseIdentifier: "MNEmoticonCell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }()
    
    init(frame: CGRect, options: MNEmoticonKeyboardOptions) {
        self.options = options
        super.init(frame: frame)
        
        delegate = self
        backgroundColor = .clear
        keyboardDismissMode = .none
        addSubview(collectionView)
        
        elementView.isHidden = true
        elementView.addTarget(self, forDeleteButtonTouchUpInside: #selector(deleteButtonTouchUpInside(_:)))
        elementView.addTarget(self, forReturnButtonTouchUpInside: #selector(returnButtonTouchUpInside(_:)))
        addSubview(elementView)
        
        /// 添加长按手势
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        recognizer.minimumPressDuration = 0.3
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重载表情
    /// - Parameters:
    ///   - packet: 表情包
    func reloadEmojis(_ packet: MNEmoticonPacket) {
        self.packet = packet
        // 删除所有表情
        for subview in subviews {
            guard let button = subview as? MNEmoticonButton else { continue }
            button.removeFromSuperview()
            buttons.append(button)
        }
        let itemSize = options.prefersItemSize(rect: frame, style: packet.style)
        let lineSpacing = options.prefersLineSpacing(rect: frame, style: packet.style)
        let interitemSpacing = options.prefersInteritemSpacing(rect: frame, style: packet.style)
        let numberOfColumns = options.prefersNumberOfColumns(rect: frame, style: packet.style)
        let x: CGFloat = floor((frame.width - itemSize.width*CGFloat(numberOfColumns) - interitemSpacing*CGFloat(numberOfColumns - 1))/2.0)
        if options.axis == .horizontal {
            // 使用自身布局emoji
            isScrollEnabled = true
            elementView.isHidden = true
            collectionView.isHidden = true
            var deleteImage: UIImage?
            let numberOfRows = options.prefersNumberOfRows(rect: frame, style: packet.style)
            var numberOfEmojis: Int = numberOfColumns*numberOfRows
            if packet.style == .emoji {
                numberOfEmojis -= 1
                deleteImage = MNEmoticonKeyboard.image(named: "delete-hor")
            }
            let y: CGFloat = floor((frame.height - itemSize.height*CGFloat(numberOfRows) - lineSpacing*CGFloat(numberOfRows - 1))/2.0)
            let groups: [[MNEmoticon]] = packet.emojis.group(by: numberOfEmojis)
            numberOfPages = groups.count
            let numberOfItems: Int = numberOfEmojis + (packet.style == .emoji ? 1 : 0)
            let boundInset: UIEdgeInsets = packet.style == .emoji ? UIEdgeInsets(top: -lineSpacing/2.0, left: -interitemSpacing/2.0, bottom: -lineSpacing/2.0, right: -interitemSpacing/2.0) : .zero
            for (pageIndex, group) in groups.enumerated() {
                let originX = CGFloat(pageIndex)*frame.width + x
                CGRect(x: originX, y: y, width: itemSize.width, height: itemSize.height).grid(offset: UIOffset(horizontal: interitemSpacing, vertical: lineSpacing), count: numberOfItems, column: numberOfColumns) { idx, rect, _ in
                    if idx < group.count {
                        // 表情
                        let button: MNEmoticonButton = emojiButton(frame: rect)
                        button.emoji = group[idx]
                        button.boundInset = boundInset
                        button.addTarget(self, action: #selector(emojiButtonTouchUpInside(_:)), for: .touchUpInside)
                        addSubview(button)
                    } else if idx == (numberOfItems - 1) {
                        // 删除按钮
                        let button: MNEmoticonButton = emojiButton(frame: rect)
                        if let deleteImage = deleteImage {
                            button.size = CGSize(width: 40.0, height: ceil(deleteImage.size.height/deleteImage.size.width*40.0))
                            button.midY = rect.midY
                            button.maxX = rect.maxX
                            button.image = deleteImage
                        }
                        button.addTarget(self, action: #selector(deleteButtonTouchUpInside(_:)), for: .touchUpInside)
                        addSubview(button)
                    }
                }
            }
        } else {
            // 使用collectionView布局emoji
            numberOfPages = 1
            isScrollEnabled = false
            collectionView.isHidden = false
            if packet.style == .image {
                elementView.isHidden = true
            } else {
                elementView.isHidden = false
                elementView.height = itemSize.height + ceil(lineSpacing/4.0*3.0)
                elementView.width = itemSize.width*3.0 + interitemSpacing*2.0
                elementView.maxX = frame.width - x
                elementView.maxY = frame.height - max(lineSpacing, MN_BOTTOM_SAFE_HEIGHT)
            }
            let remainder: Int = packet.emojis.count % numberOfColumns
            var sectionInset: UIEdgeInsets = .zero
            sectionInset.top = max(lineSpacing, 25.0)
            sectionInset.left = x
            sectionInset.right = x
            if remainder > 0, (numberOfColumns - remainder) >= 3 {
                sectionInset.bottom = frame.height - elementView.frame.maxY + ceil((elementView.frame.height - itemSize.height)/2.0)
            } else {
                sectionInset.bottom = frame.height - elementView.frame.minY + ceil(lineSpacing/2.0)
            }
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = sectionInset
            layout.minimumLineSpacing = lineSpacing
            layout.minimumInteritemSpacing = interitemSpacing
            layout.itemSize = itemSize
            collectionView.reloadData()
        }
    }
    
    override func setCurrentPage(at pageIndex: Int, animated: Bool) {
        super.setCurrentPage(at: pageIndex, animated: animated)
        if pageIndex == 0, collectionView.isHidden == false {
            collectionView.setContentOffset(CGPoint(x: 0.0, y: -collectionView.contentInset.top), animated: animated)
        }
    }
}

// MARK: - Convenience
extension MNEmoticonView {
    
    /// 取出表情按钮(没有则创建)
    /// - Parameter frame: 位置
    /// - Returns: 表情按钮
    private func emojiButton(frame: CGRect) -> MNEmoticonButton {
        var button: MNEmoticonButton! = buttons.first
        if let _ = button {
            buttons.removeFirst()
        } else {
            button = MNEmoticonButton()
        }
        button.frame = frame
        return button
    }
    
    /// 计算Cell的透明度
    /// - Parameters:
    ///   - cell: 表格控件
    ///   - intersects: 是否允许与'ElementView'相交
    /// - Returns: 透明度
    private func alpha(for cell: UICollectionViewCell, intersects: Bool = true) -> CGFloat {
        let frame = collectionView.convert(cell.frame, to: self)
        guard frame.maxX > elementView.frame.minX else { return 1.0 }
        guard frame.minY < elementView.frame.minY else { return 0.0 }
        if intersects {
            let rect = frame.intersection(elementView.frame)
            guard rect.height > 0.0 else { return 1.0 }
            return 1.0 - min(1.0, rect.height/(frame.height/5.0*2.0))
        }
        return frame.intersects(elementView.frame) ? 0.0 : 1.0
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension MNEmoticonView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let packet = packet else { return 0 }
        return packet.emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "MNEmoticonCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item < packet.emojis.count else { return }
        guard let cell = cell as? MNEmoticonCell else { return }
        cell.updateEmoji(packet.emojis[indexPath.item])
        if elementView.isHidden {
            cell.contentView.alpha = 1.0
        } else {
            cell.contentView.alpha = alpha(for: cell, intersects: (collectionView.isDragging || collectionView.isDecelerating))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let packet = packet else { return }
        guard indexPath.item < packet.emojis.count else { return }
        if packet.style == .image, indexPath.item == 0 {
            proxy?.emojiViewShouldAddToFavorites(self)
        } else {
            let emoji = packet.emojis[indexPath.item]
            proxy?.emojiViewDidSelectEmoji(emoji)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MNEmoticonView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.tag == collectionView.tag else { return }
        guard elementView.isHidden == false else { return }
        for cell in collectionView.visibleCells {
            cell.contentView.alpha = alpha(for: cell, intersects: collectionView.isDragging)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.tag == tag else { return }
        guard decelerate == false else { return }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.tag == tag else { return }
        proxy?.emojiViewDidScrollPage(to: currentPageIndex)
    }
}

// MARK: - Event
private extension MNEmoticonView {
    
    @objc func deleteButtonTouchUpInside(_ sender: MNEmoticonButton) {
        proxy?.emojiViewDeleteButtonTouchUpInside(self)
    }
    
    @objc func returnButtonTouchUpInside(_ sender: MNEmoticonButton) {
        proxy?.emojiViewReturnButtonTouchUpInside(self)
    }
    
    @objc func emojiButtonTouchUpInside(_ sender: MNEmoticonButton) {
        guard let emoji = sender.emoji else { return }
        proxy?.emojiViewDidSelectEmoji(emoji)
    }
}

// MARK: - Gesture - 预览
private extension MNEmoticonView {
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard let packet = packet, packet.style == .emoji else { return }
        switch recognizer.state {
        case .began:
            previewEmoji(at: recognizer.location(in: self))
        case .changed:
            previewEmoji(at: recognizer.location(in: self))
        default:
            previewEmoji(at: .zero)
        }
    }
    
    private func previewEmoji(at location: CGPoint) {
        var emoji: MNEmoticon?
        var rect: CGRect = .zero
        switch options.axis {
        case .horizontal:
            let offsetX = contentOffset.x
            for subview in subviews {
                guard subview.frame.contains(location) else { continue }
                guard let button = subview as? MNEmoticonButton else { continue }
                guard let e = button.emoji else { continue }
                emoji = e
                rect = button.frame
                rect.origin.x -= offsetX
            }
        default:
            for cell in collectionView.visibleCells {
                guard cell.contentView.alpha == 1.0 else { continue }
                let frame = collectionView.convert(cell.frame, to: self)
                guard frame.contains(location) else { continue }
                guard let indexPath = collectionView.indexPath(for: cell) else { continue }
                guard indexPath.item < packet.emojis.count else { continue }
                rect = frame
                emoji = packet.emojis[indexPath.item]
            }
        }
        proxy?.emojiViewShouldPreviewEmoji(emoji, at: rect)
    }
}
