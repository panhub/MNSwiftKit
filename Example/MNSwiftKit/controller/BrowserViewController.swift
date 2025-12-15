//
//  BrowserViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class BrowserViewController: UIViewController {
    
    private var isReloaded: Bool = false
    
    private var items: [BrowserListItem] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionLayout: MNCollectionViewFlowLayout!
    
    @IBOutlet weak var backTop: NSLayoutConstraint!
    
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    
    @IBOutlet weak var navHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        let width = floor((MN_SCREEN_WIDTH - 32.0)/3.0)
        collectionLayout.numberOfColumns = 3
        collectionLayout.minimumLineSpacing = 8.0
        collectionLayout.minimumInteritemSpacing = 8.0
        collectionLayout.itemSize = .init(width: width, height: 0.0)
        collectionLayout.sectionInset = .init(top: 8.0, left: 8.0, bottom: MN_BOTTOM_SAFE_HEIGHT, right: 8.0)
        
        collectionView.register(UINib(nibName: "BrowserCollectionCell", bundle: .main), forCellWithReuseIdentifier: "BrowserCollectionCell")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            for index in 0...22 {
                let item = BrowserListItem(type: .photo, name: "b_\(index)")
                let ratio = CGFloat.random(in: 0.45...1.8)
                item.height = floor(width*ratio)
                self.items.append(item)
            }
            for index in 1...3 {
                let item = BrowserListItem(type: .video, name: "b_\(index)")
                let ratio = CGFloat.random(in: 0.45...1.8)
                item.height = floor(width*ratio)
                self.items.insert(item, at: .random(in: 0...self.items.count))
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isReloaded = true
                self.collectionView.reloadData()
            }
        }
    }

    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
}

extension BrowserViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        isReloaded ? items.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.dequeueReusableCell(withReuseIdentifier: "BrowserCollectionCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BrowserCollectionCell else { return }
        cell.update(item: items[indexPath.item])
        cell.contentView.layer.removeAllAnimations()
        cell.contentView.alpha = 0.0
        UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseOut) { [weak cell] in
            guard let cell = cell else { return }
            cell.contentView.alpha = 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assets = items.compactMap { $0.asAsset }
        let browser = MNAssetBrowser(assets: assets)
        browser.autoPlaying = true
        browser.leftBarEvent = .back
        browser.exitWhenPulled = true
        browser.exitWhenTouched = true
        browser.backgroundColor = .black
        browser.present(in: view, from: indexPath.item, animated: true)
    }
}

extension BrowserViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! MNCollectionViewFlowLayout
        return .init(width: layout.itemSize.width, height: items[indexPath.item].height)
    }
}
