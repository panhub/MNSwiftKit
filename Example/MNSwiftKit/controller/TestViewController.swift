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
    
    private var shouldPlayEntrance = true
    
    private var animatedIndexPaths = Set<IndexPath>()


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
        
        // 父层透视：cell 沿 Z 轴位移时才有「从眼前落到屏幕」的景深
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 600.0
        collectionView.layer.sublayerTransform = perspective
        collectionView.register(TestCollectionCell.self, forCellWithReuseIdentifier: "TestCollectionCell")
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
        
        collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionCell", for: indexPath)
    }
    
    // 在 cell 将要显示的时候添加动画
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard shouldPlayEntrance, !animatedIndexPaths.contains(indexPath) else { return }
        animatedIndexPaths.insert(indexPath)
        applyZDropAnimation(to: cell, at: indexPath)
    }
    
    /// 沿屏幕法线（Z 轴）从眼前落到屏幕平面，按行列错开
    private func applyZDropAnimation(to cell: UICollectionViewCell, at indexPath: IndexPath) {
        let column = indexPath.item % 3
        let row = indexPath.item / 3
        let delay = 0.04 * Double(column) + 0.06 * Double(row)
        
        // 起始：更靠前（Z 更大）、更大，落屏冲击感更强
        var start = CATransform3DIdentity
        start = CATransform3DTranslate(start, 0, 0, 420)
        start = CATransform3DScale(start, 1.55, 1.55, 1)
        
        cell.layer.transform = start
        cell.alpha = 0.15
        
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
