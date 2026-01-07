//
//  SegmentedSubpageController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class SegmentedSubpageController: UIViewController {
    
    enum Style {
        case grid, table
    }
    
    // 表格样式
    private let style: SegmentedSubpageController.Style
    
    private var items: [SegmentedPageItem] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionLayout: MNCollectionViewFlowLayout!
    
    init(style: SegmentedSubpageController.Style) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        switch style {
        case .grid:
            //
            let width = floor((MN_SCREEN_WIDTH - 32.0)/3.0)
            collectionLayout.numberOfColumns = 3
            collectionLayout.itemSize = .init(width: width, height: 0.0)
            for index in 0...100 {
                let ratio = CGFloat.random(in: 0.45...1.8)
                let item = SegmentedPageItem(height: floor(width*ratio))
                item.index = index
                items.append(item)
            }
        case .table:
            collectionLayout.numberOfColumns = 1
            collectionLayout.itemSize = .init(width: MN_SCREEN_WIDTH - 16.0, height: 75.0)
            items.append(contentsOf: Array(repeating: SegmentedPageItem(height: 75.0), count: 50))
            (0..<50).forEach { index in
                items[index].index = index
            }
        }
        
        collectionLayout.minimumLineSpacing = 8.0
        collectionLayout.minimumInteritemSpacing = 8.0
        collectionLayout.sectionInset = .init(top: 8.0, left: 8.0, bottom: MN_BOTTOM_SAFE_HEIGHT, right: 8.0)
        
        collectionView.register(UINib(nibName: "SegmentedSubpageCell", bundle: .main), forCellWithReuseIdentifier: "SegmentedSubpageCell")
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension SegmentedSubpageController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.dequeueReusableCell(withReuseIdentifier: "SegmentedSubpageCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SegmentedSubpageCell else { return }
        cell.update(item: items[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SegmentedSubpageController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! MNCollectionViewFlowLayout
        return .init(width: layout.itemSize.width, height: items[indexPath.item].height)
    }
}

// MARK: - MNSplitPageConvertible
extension SegmentedSubpageController: MNSegmentedSubpageConvertible {
    
    var preferredSubpageScrollView: UIScrollView? {
        
        collectionView
    }
}
