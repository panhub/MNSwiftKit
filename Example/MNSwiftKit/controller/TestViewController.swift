//
//  TestViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/11.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class TestViewController: UIViewController {
    
    /// 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    /// 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    
    @IBOutlet weak var collectionTop: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!
    
    /// 仅首屏入场时播放 Z 轴落屏，用户滑动后不再触发
    private var allowsEntranceAnimation = true
    
    private var animatedIndexPaths = Set<IndexPath>()
    
    /// 首屏布局完成后允许播放入场的最大 item 索引（含部分露出的下一行）
    private var maxEntranceItemIndex: Int?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        collectionTop.constant = MN_TOP_BAR_HEIGHT
        
        collectionLayout.scrollDirection = .vertical
        collectionLayout.minimumInteritemSpacing = 10.0
        collectionLayout.minimumLineSpacing = 10.0
        collectionLayout.sectionInset = UIEdgeInsets(top: 5.0, left: 10.0, bottom: max(MN_BOTTOM_SAFE_HEIGHT, 10.0), right: 10.0)
        
        let itemWidth = floor((MN_SCREEN_WIDTH - collectionLayout.sectionInset.left - collectionLayout.sectionInset.right - collectionLayout.minimumInteritemSpacing*2.0)/3.0)
        collectionLayout.itemSize = .init(width: itemWidth, height: itemWidth)
        
        let collectionHeight = MN_SCREEN_HEIGHT - collectionTop.constant - collectionLayout.sectionInset.top - collectionLayout.sectionInset.bottom
        let rowHeight = itemWidth + collectionLayout.minimumLineSpacing
        let rowCount = max(1, Int(ceil(collectionHeight / rowHeight)))
        maxEntranceItemIndex = rowCount * 3 + 2
        
        // 父层透视：cell 沿 Z 轴位移时才有「从眼前落到屏幕」的景深
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 600.0
        collectionView.layer.sublayerTransform = perspective
        collectionView.register(TestCollectionCell.self, forCellWithReuseIdentifier: "TestCollectionCell")
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMaxEntranceItemIndexIfNeeded()
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
}

extension TestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 90
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionCell", for: indexPath)
        if allowsEntranceAnimation,
           animatedIndexPaths.contains(indexPath) == false,
           isEligibleForEntranceAnimation(at: indexPath) {
            applyZDropStartState(to: cell)
        } else {
            normalizeCellAppearance(cell)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard allowsEntranceAnimation else {
            normalizeCellAppearance(cell)
            return
        }
        if let maxIndex = maxEntranceItemIndex, indexPath.item > maxIndex {
            normalizeCellAppearance(cell)
            animatedIndexPaths.insert(indexPath)
            return
        }
        guard animatedIndexPaths.contains(indexPath) == false else { return }
        animatedIndexPaths.insert(indexPath)
        applyZDropAnimation(to: cell, at: indexPath)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endEntranceAnimation()
    }
    
    private func endEntranceAnimation() {
        guard allowsEntranceAnimation else { return }
        allowsEntranceAnimation = false
        collectionView.visibleCells.forEach { cell in
            cell.layer.removeAllAnimations()
            normalizeCellAppearance(cell)
        }
    }
    
    private func updateMaxEntranceItemIndexIfNeeded() {
        guard maxEntranceItemIndex == nil, collectionView.bounds.height > 0 else { return }
        let visibleItems = collectionView.indexPathsForVisibleItems.map(\.item)
        guard let maxVisible = visibleItems.max() else { return }
        maxEntranceItemIndex = maxVisible + 3
    }
    
    private func isEligibleForEntranceAnimation(at indexPath: IndexPath) -> Bool {
        guard let maxIndex = maxEntranceItemIndex else { return true }
        return indexPath.item <= maxIndex
    }
    
    private func normalizeCellAppearance(_ cell: UICollectionViewCell) {
        cell.layer.transform = CATransform3DIdentity
        cell.alpha = 1
    }
    
    private func applyZDropStartState(to cell: UICollectionViewCell) {
        var start = CATransform3DIdentity
        start = CATransform3DTranslate(start, 0, 0, 420)
        start = CATransform3DScale(start, 1.55, 1.55, 1)
        cell.layer.transform = start
        cell.alpha = 0.15
    }
    
    /// 沿屏幕法线（Z 轴）从眼前落到屏幕平面，按行列错开
    private func applyZDropAnimation(to cell: UICollectionViewCell, at indexPath: IndexPath) {
        let column = indexPath.item % 3
        let row = indexPath.item / 3
        // 首屏内按行列错开；延迟封顶，避免后排 cell 过久才落下
        let delay = min(0.04 * Double(column) + 0.06 * Double(row), 0.45)
        
        applyZDropStartState(to: cell)
        
        UIView.animate(
            withDuration: 0.95,
            delay: delay,
            usingSpringWithDamping: 0.62,
            initialSpringVelocity: 1.4,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1
        }
    }
}

class TestCollectionCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.backgroundColor = .mn.random
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
        layer.transform = CATransform3DIdentity
        alpha = 1.0
    }
}
