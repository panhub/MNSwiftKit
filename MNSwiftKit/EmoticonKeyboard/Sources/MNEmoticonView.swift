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
    /// 页数 仅对 style == paging有效
    private(set) var numberOfPages: Int = 1
    /// 当前页码 仅对 style == paging有效
    private(set) var currentPageIndex: Int = 0
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
    
    
    /// 构建表情视图
    /// - Parameters:
    ///   - style: 样式
    ///   - options: 键盘配置
    init(style: MNEmoticonKeyboard.Style, options: MNEmoticonKeyboard.Options) {
        self.style = style
        self.options = options
        super.init(frame: .zero)
        backgroundColor = .clear
        
        let layout = collectionView.collectionViewLayout as! MNEmoticonCollectionLayout
        layout.itemSize = .init(width: 30.0, height: 30.0)
        layout.scrollDirection = style == .compact ? .vertical : .horizontal
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
            elementView.translatesAutoresizingMaskIntoConstraints = false
            elementView.addTarget(self, forDeleteButtonTouchUpInside: #selector(deleteButtonTouchUpInside(_:)))
            elementView.addTarget(self, forReturnButtonTouchUpInside: #selector(returnButtonTouchUpInside(_:)))
            addSubview(elementView)
            NSLayoutConstraint.activate([
                elementView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25.0),
                elementView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10.0),
                elementView.widthAnchor.constraint(equalToConstant: 130.0),
                elementView.heightAnchor.constraint(equalToConstant: 45.0)
            ])
        }
        
        // 添加长按手势
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        recognizer.minimumPressDuration = 0.3
        recognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(recognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重载表情
    /// - Parameters:
    ///   - packet: 表情包
    func reload(packet: MNEmoticon.Packet) {
        emoticons.removeAll()
        var itemSize: CGSize = .zero
        var numberOfColumns = 0
        var minimumLineSpacing = 0.0
        var minimumInteritemSpacing = 0.0
        var sectionInset: UIEdgeInsets = .zero
        var preferredContentSize: CGSize = .zero
        var elements = packet.emoticons
        if packet.style == .emoticon {
            // 文字表情
            numberOfColumns = collectionView.frame.width >= 414.0 ? 8 : 7
            itemSize.width = collectionView.frame.width >= 390.0 ? 32.0 : 30.0
            itemSize.height = itemSize.width
            minimumInteritemSpacing = floor((collectionView.frame.width - itemSize.width*CGFloat(numberOfColumns))/(CGFloat(numberOfColumns) + 0.5)*10.0)/10.0
            sectionInset.left = minimumInteritemSpacing*0.75
            sectionInset.right = sectionInset.left
            minimumLineSpacing = sectionInset.left
        } else {
            // 图片
            numberOfColumns = 4
            minimumLineSpacing = 10.0
            minimumInteritemSpacing = 20.0
            itemSize.width = (collectionView.frame.width - minimumInteritemSpacing*CGFloat(numberOfColumns - 1) - minimumLineSpacing*2.0)/CGFloat(numberOfColumns)
            itemSize.height = itemSize.width
            sectionInset.left = minimumLineSpacing
            sectionInset.right = minimumLineSpacing
            if packet.allowsEditing {
                elements.insert(adding, at: 0)
            }
        }
        if style == .compact {
            sectionInset.top = minimumLineSpacing
            if packet.style == .emoticon {
                // 文字表情
                elementView.isHidden = false
                let height = ceil(itemSize.height + minimumLineSpacing*0.7)
                let width = ceil((itemSize.width + minimumInteritemSpacing)*2.0 + itemSize.width/2.0)
                let bottom = max(minimumLineSpacing, MN_BOTTOM_SAFE_HEIGHT) + 5.0
                elementView.constraints.forEach { constraint in
                    guard let firstItem = constraint.firstItem as? MNEmoticonElementView, firstItem == elementView else { return }
                    if constraint.firstAttribute == .width {
                        constraint.constant = width
                    } else if constraint.firstAttribute == .height {
                        constraint.constant = height
                    }
                }
                constraints.forEach { constraint in
                    guard let firstItem = constraint.firstItem as? MNEmoticonElementView, firstItem == elementView else { return }
                    if constraint.firstAttribute == .bottom {
                        constraint.constant = -bottom
                    } else if constraint.firstAttribute == .right {
                        constraint.constant = -sectionInset.right
                    }
                }
                // 底部间隔
                let residue = elements.count % numberOfColumns
                if residue > 0, numberOfColumns - residue >= 3 {
                    sectionInset.bottom = (height - itemSize.height)/2.0 + bottom
                } else {
                    sectionInset.bottom = ceil(bottom + height + minimumLineSpacing/2.0)
                }
            } else {
                elementView.isHidden = true
                sectionInset.bottom = max(MN_BOTTOM_SAFE_HEIGHT, minimumLineSpacing) + 5.0
            }
            if elements.isEmpty == false {
                emoticons.append(elements)
            }
        } else {
            let numberOfRows = max(0, Int((collectionView.frame.height - minimumLineSpacing)/(itemSize.height + minimumLineSpacing)))
            let top = (collectionView.frame.height - itemSize.height*CGFloat(numberOfRows) - minimumLineSpacing*CGFloat(max(0, numberOfRows - 1)))/2.0
            sectionInset.top = top
            sectionInset.bottom = top
            let pageCount = numberOfColumns*numberOfRows
            let numberOfPages = pageCount > 0 ? Int(ceil(Double(elements.count)/Double(pageCount))) : 0
            preferredContentSize.width = max(collectionView.frame.width*CGFloat(numberOfPages), collectionView.frame.width)
            preferredContentSize.height = collectionView.frame.height
            if pageCount > 0, elements.isEmpty == false {
                let array = stride(from: 0, to: elements.count, by: pageCount).map {
                    Array(elements[$0..<Swift.min($0 + pageCount, elements.count)])
                }
                emoticons.append(contentsOf: array)
            }
        }
        let collectionLayout = collectionView.collectionViewLayout as! MNEmoticonCollectionLayout
        collectionLayout.itemSize = itemSize
        collectionLayout.sectionInset = sectionInset
        collectionLayout.numberOfColumns = numberOfColumns
        collectionLayout.minimumLineSpacing = minimumLineSpacing
        collectionLayout.minimumInteritemSpacing = minimumInteritemSpacing
        collectionLayout.preferredContentSize = preferredContentSize
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
        if let gestureRecognizers = gestureRecognizers, let gestureRecognizer = gestureRecognizers.first(where: { $0 is UILongPressGestureRecognizer }) {
            gestureRecognizer.isEnabled = packet.style == .emoticon
        }
    }
    
    func setCurrentPage(at pageIndex: Int, animated: Bool) {
        if style == .paging {
            collectionView.setContentOffset(CGPoint(x: collectionView.frame.width*CGFloat(pageIndex), y: 0.0), animated: animated)
        } else {
            collectionView.setContentOffset(.zero, animated: animated)
        }
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
        guard style == .compact else { return }
        if elementView.isHidden {
            cell.imageView.alpha = 1.0
        } else {
            cell.imageView.alpha = alpha(for: cell, intersects: (collectionView.isDragging || collectionView.isDecelerating))
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
        guard style == .compact, elementView.isHidden == false else { return }
        for cell in collectionView.visibleCells {
            guard let cell = cell as? MNEmoticonCell else { continue }
            cell.imageView.alpha = alpha(for: cell, intersects: collectionView.isDragging)
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
        switch recognizer.state {
        case .began:
            preview(at: recognizer.location(in: self))
        case .changed:
            preview(at: recognizer.location(in: self))
        default:
            guard let delegate = delegate else { break }
            delegate.emoticonViewShouldPreviewEmoticon(nil, at: .zero)
        }
    }
    
    private func preview(at location: CGPoint) {
        guard let delegate = delegate else { return }
        let point = CGPoint(x: location.x + collectionView.contentOffset.x, y: location.y)
        if let indexPath = collectionView.indexPathForItem(at: point), let cell = collectionView.cellForItem(at: indexPath) as? MNEmoticonCell, cell.imageView.alpha == 1.0 {
            let rect = collectionView.convert(cell.frame, to: self)
            let emoticon = emoticons[indexPath.section][indexPath.item]
            delegate.emoticonViewShouldPreviewEmoticon(emoticon, at: rect)
        } else {
            delegate.emoticonViewShouldPreviewEmoticon(nil, at: .zero)
        }
    }
}
