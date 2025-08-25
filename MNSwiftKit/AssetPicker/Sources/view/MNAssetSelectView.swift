//
//  MNAssetSelectView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/4.
//  资源选择视图

import UIKit

/// 资源选择视图代理
protocol MNAssetSelectViewDelegate: NSObjectProtocol {
    /// 选择告知
    /// - Parameters:
    ///   - selectView: 资源选择视图
    ///   - asset: 选中的资源模型
    func selectView(_ selectView: MNAssetSelectView, didSelect asset: MNAsset) -> Void
}

/// 资源选择视图
class MNAssetSelectView: UIView {
    /// 选择索引
    private var selectedIndex: Int = 0
    /// 配置信息
    private let options: MNAssetPickerOptions
    /// 资源集合
    private var assets: [MNAsset] = [MNAsset]()
    /// 事件代理
    weak var delegate: MNAssetSelectViewDelegate?
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 13.0
        layout.minimumInteritemSpacing = 0.0
        layout.headerReferenceSize = .zero
        layout.footerReferenceSize = .zero
        layout.itemSize = CGSize(width: frame.height - 26.0, height: frame.height - 26.0)
        layout.sectionInset = UIEdgeInsets(top: 13.0, left: 13.0, bottom: 13.0, right: 13.0)
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MNAssetSelectCell.self, forCellWithReuseIdentifier: "com.mn.asset.select.cell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never;
        }
        return collectionView
    }()
    
    init(frame: CGRect, assets: [MNAsset], options: MNAssetPickerOptions) {
        self.options = options
        super.init(frame: frame)
        self.assets.append(contentsOf: assets)
        
        backgroundColor = UIColor(red: 32.0/255.0, green: 32.0/255.0, blue: 35.0/255.0, alpha: 0.45)
        
        addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新选择索引
    /// - Parameter index: 指定索引
    func selection(index: Int) {
        let lastSelectIndex = selectedIndex
        selectedIndex = index
        var indexPaths: [IndexPath] = [IndexPath]()
        if lastSelectIndex != .min {
            indexPaths.append(IndexPath(item: lastSelectIndex, section: 0))
        }
        if index != lastSelectIndex {
            indexPaths.append(IndexPath(item: index, section: 0))
        }
        guard indexPaths.count > 0 else { return }
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: indexPaths)
        }
    }
    
    /// 删除资源
    /// - Parameter asset: 资源模型
    func deleteAsset(_ asset: MNAsset) {
        guard let index = assets.firstIndex(of: asset) else { return }
        selectedIndex = .min
        assets.remove(at: index)
        isHidden = assets.isEmpty
        UIView.performWithoutAnimation {
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    /// 追加资源并选中
    /// - Parameter asset: 资源模型
    func appendAsset(_ asset: MNAsset) {
        isHidden = false
        assets.append(asset)
        selectedIndex = assets.count - 1
        UIView.performWithoutAnimation {
            collectionView.insertItems(at: [IndexPath(item: selectedIndex, section: 0)])
            collectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .right, animated: false)
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MNAssetSelectView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { assets.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.mn.asset.select.cell", for: indexPath)
        if let cell = cell as? MNAssetSelectCell {
            cell.borderView.layer.borderColor = options.themeColor.cgColor
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay c: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = c as? MNAssetSelectCell else { return }
        cell.updateAsset(assets[indexPath.item])
        cell.updateSelected(indexPath.item == selectedIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == selectedIndex { return }
        guard indexPath.item < assets.count else { return }
        guard let delegate = delegate else { return }
        let asset = assets[indexPath.item]
        delegate.selectView(self, didSelect: asset)
    }
}
