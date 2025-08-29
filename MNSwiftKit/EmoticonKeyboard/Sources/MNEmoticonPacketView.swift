//
//  MNEmoticonPacketView.swift
//  MNKit
//
//  Created by 冯盼 on 2023/1/28.
//  表情包选择视图

import UIKit

/// 表情包栏事件代理
protocol MNEmoticonPacketViewDelegate: NSObjectProtocol {
    
    /// 表情包选择告知
    /// - Parameter index: 索引
    func packetViewDidSelectPacket(at index: Int) -> Void
    
    /// Return键点击事件
    /// - Parameter packetView: 表情包视图
    func packetViewReturnButtonTouchUpInside(_ packetView: MNEmoticonPacketView) -> Void
}

/// 表情包选择视图
class MNEmoticonPacketView: UIView {
    /// 选择索引
    var selectedIndex: Int = 0
    /// 事件代理
    weak var proxy: MNEmoticonPacketViewDelegate?
    /// 配置选项
    private let options: MNEmoticonKeyboardOptions
    /// 表情包集合
    private var packets: [MNEmoticonPacket] = [MNEmoticonPacket]()
    /// 分割线
    private lazy var separator: UIView = {
        let separator: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: 0.7))
        separator.isUserInteractionEnabled = false
        separator.backgroundColor = options.separatorColor
        separator.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        return separator
    }()
    /// Return键
    private lazy var returnButton: MNEmoticonButton = {
        let returnButton: MNEmoticonButton = MNEmoticonButton(frame: CGRect(x: 0.0, y: separator.maxY, width: 75.0, height: frame.height - separator.maxY - (options.axis == .horizontal ? MN_BOTTOM_SAFE_HEIGHT : 0.0)))
        if options.axis == .horizontal {
            returnButton.isHidden = false
            returnButton.maxX = frame.width
            returnButton.text = options.returnKeyType.preferredTitle
            returnButton.textFont = options.returnKeyTitleFont
            returnButton.textColor = options.returnKeyTitleColor
            returnButton.backgroundColor = options.returnKeyColor
            returnButton.textInset = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
        } else {
            returnButton.isHidden = true
            returnButton.minX = frame.width
        }
        returnButton.addTarget(self, action: #selector(returnButtonTouchUpInside(_:)), for: .touchUpInside)
        return returnButton
    }()
    /// Return键阴影
    private lazy var shadowView: UIView = {
        let imageView = UIImageView()
        imageView.isHidden = returnButton.isHidden
        if let image = MNEmoticonKeyboard.image(named: "shadow") {
            imageView.size = CGSize(width: floor(image.size.width/image.size.height*returnButton.frame.height), height: returnButton.frame.height)
            imageView.image = image
            imageView.contentMode = .scaleToFill
        }
        imageView.midY = returnButton.midY
        imageView.midX = returnButton.minX
        return imageView
    }()
    /// 表情包浏览
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumInteritemSpacing = options.packetInteritemSpacing
        var sectionInset = options.packetContentInset
        sectionInset.left = max(options.accessoryView?.frame.maxX ?? 0, sectionInset.left)
        sectionInset.right = max(sectionInset.right, frame.width - returnButton.frame.minX)
        layout.sectionInset = sectionInset
        layout.itemSize = CGSize(width: returnButton.height - sectionInset.top - sectionInset.bottom, height: returnButton.height - sectionInset.top - sectionInset.bottom)
        let collectionView = UICollectionView(frame: CGRect(x: 0.0, y: returnButton.minY, width: frame.width, height: returnButton.height), layout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        collectionView.register(MNEmoticonPacketCell.self, forCellWithReuseIdentifier: "MNEmoticonPacketCell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        if let accessoryView = options.accessoryView {
            collectionView.addSubview(accessoryView)
        }
        return collectionView
    }()
    
    init(frame: CGRect, options: MNEmoticonKeyboardOptions) {
        self.options = options
        super.init(frame: frame)
        
        backgroundColor = options.tintColor
        
        // 分割线
        addSubview(separator)
        // Return
        addSubview(returnButton)
        // 阴影
        insertSubview(shadowView, belowSubview: returnButton)
        // 表情包
        insertSubview(collectionView, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重载表情包
    /// - Parameter packets: 表情包集合
    func reloadPackets(_ packets: [MNEmoticonPacket]? = nil) {
        if let packets = packets {
            self.packets.removeAll()
            self.packets.append(contentsOf: packets)
        }
        if selectedIndex >= self.packets.count {
            selectedIndex = max(0, min(selectedIndex, self.packets.count - 1))
        }
        collectionView.reloadData()
    }
    
    /// 设置选择索引
    /// - Parameter index: 选择索引
    func setSelected(at index: Int) {
        guard index < packets.count else { return }
        selectedIndex = index
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
    
    /// Return键点击事件
    /// - Parameter sender: 按钮
    @objc private func returnButtonTouchUpInside(_ sender: MNEmoticonButton) {
        proxy?.packetViewReturnButtonTouchUpInside(self)
    }
}

extension MNEmoticonPacketView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        packets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "MNEmoticonPacketCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item < packets.count else { return }
        guard let cell = cell as? MNEmoticonPacketCell else { return }
        cell.updatePacket(packets[indexPath.item], options: options, highlighted: indexPath.item == selectedIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedIndex { return }
        guard indexPath.item < packets.count else { return }
        selectedIndex = indexPath.item
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
        proxy?.packetViewDidSelectPacket(at: indexPath.item)
    }
}
