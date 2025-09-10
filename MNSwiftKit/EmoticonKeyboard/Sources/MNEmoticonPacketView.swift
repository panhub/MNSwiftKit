//
//  MNEmoticonPacketView.swift
//  MNSwiftKit
//
//  Created by panhub on 2023/1/28.
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
    weak var delegate: MNEmoticonPacketViewDelegate?
    /// 样式
    private let style: MNEmoticonKeyboard.Style
    /// 配置选项
    private let options: MNEmoticonKeyboard.Options
    /// 表情包集合
    private(set) var packets: [MNEmoticon.Packet] = []
    /// 分割线
    private let separatorView = UIView()
    /// Return键阴影
    private lazy var shadowView = UIImageView()
    /// Return键
    private lazy var returnButton = MNEmoticonButton()
    /// 表情包浏览
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    
    /// 构建表情包视图
    /// - Parameters:
    ///   - style: 样式
    ///   - options: 键盘配置
    init(style: MNEmoticonKeyboard.Style, options: MNEmoticonKeyboard.Options) {
        self.style = style
        self.options = options
        super.init(frame: .zero)
        
        backgroundColor = options.packetBarColor
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.sectionInset = options.packetSectionInset
        layout.minimumLineSpacing = options.packetInteritemSpacing
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MNEmoticonPacketCell.self, forCellWithReuseIdentifier: "MNEmoticonPacketCell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: style == .compact ? 0.0 : -MN_BOTTOM_SAFE_HEIGHT),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: style == .compact ? 0.0 : -78.0)
        ])
        
        if style == .paging {
            // 阴影
            if let image = EmoticonResource.image(named: "shadow") {
                shadowView.image = image
                shadowView.contentMode = .scaleToFill
                shadowView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(shadowView)
                NSLayoutConstraint.activate([
                    shadowView.topAnchor.constraint(equalTo: collectionView.topAnchor),
                    shadowView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
                    shadowView.widthAnchor.constraint(equalTo: shadowView.heightAnchor, multiplier: floor(image.size.width/image.size.height*10.0)/10.0),
                    shadowView.centerXAnchor.constraint(equalTo: collectionView.rightAnchor)
                ])
            }
            // Return键
            returnButton.text = options.returnKeyType.preferredTitle
            returnButton.textFont = options.returnKeyTitleFont
            returnButton.textColor = options.returnKeyTitleColor
            returnButton.backgroundColor = options.returnKeyColor
            returnButton.textInset = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
            returnButton.addTarget(self, action: #selector(returnButtonTouchUpInside(_:)), for: .touchUpInside)
            returnButton.translatesAutoresizingMaskIntoConstraints = false
            addSubview(returnButton)
            NSLayoutConstraint.activate([
                returnButton.topAnchor.constraint(equalTo: collectionView.topAnchor),
                returnButton.leftAnchor.constraint(equalTo: collectionView.rightAnchor),
                returnButton.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
                returnButton.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
        
        separatorView.backgroundColor = options.separatorColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.7)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(emoticonDidChangeNotification(_:)), name: MNEmoticonPacketChangedNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 重载表情包
    /// - Parameter packets: 表情包集合
    func reloadPackets(_ packets: [MNEmoticon.Packet]) {
        self.packets.removeAll()
        self.packets.append(contentsOf: packets)
        selectedIndex = 0
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }
    }
    
    /// 设置选择索引
    /// - Parameter index: 选择索引
    func setSelected(at index: Int) {
        guard index < packets.count else { return }
        selectedIndex = index
        UIView.performWithoutAnimation {
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
        }
    }
    
    /// Return键点击事件
    /// - Parameter sender: 按钮
    @objc private func returnButtonTouchUpInside(_ sender: MNEmoticonButton) {
        guard let delegate = delegate else { return }
        delegate.packetViewReturnButtonTouchUpInside(self)
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
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
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
        guard let delegate = delegate else { return }
        delegate.packetViewDidSelectPacket(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MNEmoticonPacketView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let contentHeight = CGRect(origin: .zero, size: collectionView.frame.size).inset(by: collectionView.contentInset).height - options.packetSectionInset.top - options.packetSectionInset.bottom
        let itemHeight = max(0.0, contentHeight)
        return .init(width: itemHeight, height: itemHeight)
    }
}

// MARK: - Notification
extension MNEmoticonPacketView {
    
    /// 添加图片到收藏夹事件
    /// - Parameter notify: 通知
    @objc private func emoticonDidChangeNotification(_ notify: Notification) {
        guard let userInfo = notify.userInfo else { return }
        guard let name = userInfo[MNEmoticonPacketNameUserInfoKey] as? String else { return }
        guard let pageIndex = packets.firstIndex(where: { $0.name == name }) else { return }
        MNEmoticonManager.fetchEmoticonPacket([name]) { [weak self] packets in
            guard let self = self, let packet = packets.first else { return }
            self.packets[pageIndex] = packet
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: [IndexPath(item: pageIndex, section: 0)])
            }
        }
    }
}
