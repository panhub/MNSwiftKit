//
//  MNEmoticonView.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
//  表情分页

import UIKit

/// 表情视图事件代理
protocol MNEmoticonViewDelegate: NSObjectProtocol {
    /// 表情选择告知
    /// - Parameter emoticon: 表情
    func emoticonViewDidSelectEmoticon(_ emoticon: MNEmoticon)
    /// 收藏夹添加事件告知
    /// - Parameter emoticonView: 表情视图
    func emoticonViewShouldAddToFavorites(_ emoticonView: MNEmoticonView)
    /// Delete键事件告知
    /// - Parameter emoticonView: 表情视图
    func emoticonViewDeleteButtonTouchUpInside(_ emoticonView: MNEmoticonView)
    /// Return键事件告知
    /// - Parameter emoticonView: 表情视图
    func emoticonViewReturnButtonTouchUpInside(_ emoticonView: MNEmoticonView)
    /// 当前页码告知
    /// - Parameter index: 页码
    func emoticonViewDidScrollPage(to index: Int)
    /// 预览事件告知
    /// - Parameters:
    ///   - emoticon: 表情
    ///   - rect: 位置
    func emoticonViewShouldPreviewEmoticon(_ emoticon: MNEmoticon?, at rect: CGRect)
}

class MNEmoticonView: UIView {
    /// 对于分页布局, 每页表情数量
    private var pageCount: Int = 0
    /// 对于分页布局, 总页数
    var numberOfPages = 0
    /// 表情包
    private var packet: MNEmoticon.Packet!
    /// 事件代理
    weak var delegate: MNEmoticonViewDelegate?
    /// 表情包集合
    private var emoticons: [[MNEmoticon]] = []
    /// 样式
    private let style: MNEmoticonKeyboard.Style
    /// 配置选项
    private let options: MNEmoticonKeyboard.Options
    /// 添加模型
    private lazy var adding = MNEmoticon.Adding()
    /// 表情布局视图
    private let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: MNEmoticonCollectionLayout())
    /// 功能视图
    private lazy var elementView: MNEmoticonElementView = MNEmoticonElementView(options: options)
    /// 当前页码 仅对 style == paging有效
    var currentPageIndex: Int {
        let offsetX = collectionView.contentOffset.x
        if offsetX.isFinite || offsetX.isNaN { return 0 }
        let width = collectionView.frame.width
        if width.isFinite || width.isNaN { return 0 }
        return Int(round(offsetX/width))
    }
    
    
    /// 构建表情视图
    /// - Parameters:
    ///   - style: 样式
    ///   - options: 键盘配置
    init(style: MNEmoticonKeyboard.Style, options: MNEmoticonKeyboard.Options) {
        self.style = style
        self.options = options
        super.init(frame: .init(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        
        backgroundColor = .clear
        
        let layout = collectionView.collectionViewLayout as! MNEmoticonCollectionLayout
        layout.sectionInset = .zero
        layout.numberOfColumns = 5
        layout.itemSize = .init(width: 30.0, height: 30.0)
        layout.scrollDirection = style == .compact ? .vertical : .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.headerReferenceSize = .zero
        layout.footerReferenceSize = .zero
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .none
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = style == .paging
        collectionView.alwaysBounceVertical = style == .compact
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MNEmoticonCell.self, forCellWithReuseIdentifier: "MNEmoticonCell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        if style == .compact {
            elementView.isHidden = true
            elementView.addTarget(self, forDeleteButtonTouchUpInside: #selector(deleteButtonTouchUpInside(_:)))
            elementView.addTarget(self, forReturnButtonTouchUpInside: #selector(returnButtonTouchUpInside(_:)))
            addSubview(elementView)
            // TODO 约束
        }
        
        /// 添加长按手势
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        recognizer.minimumPressDuration = 0.3
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重载表情
    /// - Parameters:
    ///   - packet: 表情包
    func reloadEmoticon(packet: MNEmoticon.Packet) {
        self.packet = packet
        emoticons.removeAll()
        var itemSize: CGSize = .zero
        var numberOfColumns = 0
        var minimumLineSpacing = 0.0
        var minimumInteritemSpacing = 0.0
        var sectionInset: UIEdgeInsets = .zero
        var preferredContentSize: CGSize = .zero
        if packet.style == .emoticon {
            // 文字表情
            numberOfColumns = frame.width >= 414.0 ? 8 : 7
            itemSize.width = frame.width >= 390.0 ? 32.0 : 30.0
            itemSize.height = itemSize.width
            minimumInteritemSpacing = (frame.width - itemSize.width*CGFloat(numberOfColumns))/(CGFloat(numberOfColumns) + 0.5)
            sectionInset.left = minimumInteritemSpacing*0.75
            sectionInset.right = sectionInset.left
            minimumLineSpacing = sectionInset.left
        } else {
            // 图片
            numberOfColumns = 4
            minimumLineSpacing = 10.0
            minimumInteritemSpacing = 20.0
            itemSize.width = (frame.width - minimumInteritemSpacing*CGFloat(numberOfColumns))/CGFloat(numberOfColumns)
            itemSize.height = itemSize.width
            sectionInset.left = minimumInteritemSpacing/2.0
            sectionInset.right = minimumInteritemSpacing/2.0
        }
        if style == .compact {
            sectionInset.top = minimumLineSpacing
            sectionInset.bottom = max(MN_BOTTOM_SAFE_HEIGHT, minimumLineSpacing)
            elementView.isHidden = packet.style == .emoticon
            var elements = packet.emoticons
            if packet.isFavorites {
                elements.insert(adding, at: 0)
            }
            if elements.isEmpty == false {
                emoticons.append(elements)
            }
        } else {
            let numberOfRows = max(0, Int((frame.height - minimumLineSpacing)/(itemSize.height + minimumLineSpacing)))
            let top = (frame.height - itemSize.height*CGFloat(numberOfRows) - minimumLineSpacing*CGFloat(max(0, numberOfRows - 1)))/2.0
            sectionInset.top = top
            sectionInset.bottom = top
            pageCount = numberOfColumns*numberOfRows
            numberOfPages = Int(ceil(Double(emoticons.count)/Double(pageCount)))
            preferredContentSize.width = frame.width*CGFloat(numberOfPages)
            preferredContentSize.height = frame.height
            let elements = stride(from: 0, to: packet.emoticons.count, by: pageCount).map {
                Array(packet.emoticons[$0..<Swift.min($0 + pageCount, packet.emoticons.count)])
            }
            if elements.isEmpty == false {
                emoticons.append(contentsOf: elements)
            }
        }
        let collectionLayout = collectionView.collectionViewLayout as! MNEmoticonCollectionLayout
        collectionLayout.itemSize = itemSize
        collectionLayout.sectionInset = sectionInset
        collectionLayout.minimumLineSpacing = minimumLineSpacing
        collectionLayout.minimumInteritemSpacing = minimumInteritemSpacing
        collectionLayout.preferredContentSize = preferredContentSize
        collectionView.reloadData()
    }
    
    func setCurrentPage(at pageIndex: Int, animated: Bool) {
        collectionView.setContentOffset(CGPoint(x: frame.width*CGFloat(pageIndex), y: 0.0), animated: animated)
    }
}

// MARK: - Convenience
extension MNEmoticonView {
    
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        emoticons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emoticons[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "MNEmoticonCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNEmoticonCell else { return }
        cell.updateEmoticon(emoticons[indexPath.section][indexPath.item])
        if elementView.isHidden {
            cell.contentView.alpha = 1.0
        } else {
            cell.contentView.alpha = alpha(for: cell, intersects: (collectionView.isDragging || collectionView.isDecelerating))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let emoticon = emoticons[indexPath.section][indexPath.item]
        if emoticon is MNEmoticon.Adding {
            delegate.emoticonViewShouldAddToFavorites(self)
        } else {
            delegate.emoticonViewDidSelectEmoticon(emoticon)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MNEmoticonView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard elementView.isHidden == false else { return }
        for cell in collectionView.visibleCells {
            cell.contentView.alpha = alpha(for: cell, intersects: collectionView.isDragging)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else { return }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard style == .paging, let delegate = delegate else { return }
        delegate.emoticonViewDidScrollPage(to: currentPageIndex)
    }
}

// MARK: - Event
private extension MNEmoticonView {
    
    @objc func deleteButtonTouchUpInside(_ sender: MNEmoticonButton) {
        guard let delegate = delegate else { return }
        delegate.emoticonViewDeleteButtonTouchUpInside(self)
    }
    
    @objc func returnButtonTouchUpInside(_ sender: MNEmoticonButton) {
        guard let delegate = delegate else { return }
        delegate.emoticonViewReturnButtonTouchUpInside(self)
    }
}

// MARK: - 预览
private extension MNEmoticonView {
    
    @objc func longPress(_ recognizer: UILongPressGestureRecognizer) {
        guard let packet = packet, packet.style == .emoticon else { return }
        switch recognizer.state {
        case .began:
            previewEmoticon(at: recognizer.location(in: self))
        case .changed:
            previewEmoticon(at: recognizer.location(in: self))
        default:
            previewEmoticon(at: .zero)
        }
    }
    
    private func previewEmoticon(at location: CGPoint) {
        guard let delegate = delegate else { return }
        for cell in collectionView.visibleCells {
            guard cell.contentView.alpha == 1.0 else { continue }
            let frame = collectionView.convert(cell.frame, to: self)
            guard frame.contains(location) else { continue }
            guard let indexPath = collectionView.indexPath(for: cell) else { continue }
            let emoticon = emoticons[indexPath.section][indexPath.item]
            delegate.emoticonViewShouldPreviewEmoticon(emoticon, at: collectionView.convert(cell.frame, to: self))
            break
        }
    }
}
