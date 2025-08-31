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
    weak var proxy: MNEmoticonPacketViewDelegate?
    /// 样式
    private let style: MNEmoticonKeyboard.Style
    /// 配置选项
    private let options: MNEmoticonKeyboard.Options
    /// 表情包集合
    private var packets: [MNEmoticonPacket] = [MNEmoticonPacket]()
    /// 分割线
    private let separatorView: UIView = .init()
    /// 表情包浏览
    private let collectionView: UICollectionView = .init()
    /// Return键
    private lazy var returnButton: MNEmoticonButton = .init()
    /// Return键阴影
    private lazy var shadowView: UIImageView = .init()
    
    
    /// 构建表情包视图
    /// - Parameters:
    ///   - style: 样式
    ///   - options: 键盘配置
    init(style: MNEmoticonKeyboard.Style, options: MNEmoticonKeyboard.Options) {
        self.style = style
        self.options = options
        super.init(frame: .zero)
        
        backgroundColor = options.tintColor
        
        separatorView.backgroundColor = options.separatorColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.7)
        ])
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.sectionInset = options.packetSectionInset
        layout.minimumInteritemSpacing = options.packetInteritemSpacing
        collectionView.collectionViewLayout = layout
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
            collectionView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: style == .compact ? 0.0 : MN_BOTTOM_SAFE_HEIGHT),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: style == .compact ? 0.0 : 75.0)
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
                    shadowView.widthAnchor.constraint(equalTo: shadowView.heightAnchor, multiplier: image.size.width/image.size.height),
                    shadowView.centerXAnchor.constraint(equalTo: collectionView.rightAnchor)
                ])
            }
            // Return键
            returnButton.text = options.returnKeyType.preferredTitle
            returnButton.textFont = options.returnKeyTitleFont
            returnButton.textColor = options.returnKeyTitleColor
            returnButton.backgroundColor = options.returnKeyColor
            returnButton.textInset = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
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
            collectionView.reloadData()
        }
        proxy?.packetViewDidSelectPacket(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MNEmoticonPacketView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemHeight = max(0.0, collectionView.frame.height - options.packetSectionInset.top - options.packetSectionInset.bottom)
        return .init(width: itemHeight, height: itemHeight)
    }
}
