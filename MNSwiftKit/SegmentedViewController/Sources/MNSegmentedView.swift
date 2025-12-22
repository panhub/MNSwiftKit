//
//  MNSegmentedView.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//

import UIKit

class MNSegmentedView: UIView {
    
    /// 数据源
    internal weak var dataSource: MNSplitViewDataSource?
    
    private let options: MNSegmentedViewController.Options
    
    private var referenceBounds: CGRect = .zero
    
    // 方向
    var orientation = UIPageViewController.NavigationOrientation.horizontal
    // 指示视图
    var indicatorView = UIView()
    // 前/左分割线
    private let leadingSeparator = UIView()
    // 后/右分割线
    private let trailingSeparator = UIView()
    // 集合视图
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    
    init(options: MNSegmentedViewController.Options) {
        self.options = options
        super.init(frame: .zero)
        
        leadingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingSeparator)
        NSLayoutConstraint.activate([
            leadingSeparator.topAnchor.constraint(equalTo: topAnchor),
            leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
            leadingSeparator.rightAnchor.constraint(equalTo: rightAnchor),
            leadingSeparator.heightAnchor.constraint(equalToConstant: 0.7)
        ])
        
        trailingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trailingSeparator)
        NSLayoutConstraint.activate([
            trailingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
            trailingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailingSeparator.rightAnchor.constraint(equalTo: rightAnchor),
            trailingSeparator.heightAnchor.constraint(equalToConstant: 0.7)
        ])
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        
        //collectionView.delegate = self
        //collectionView.dataSource = self
        collectionView.clipsToBounds = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        //collectionView.register(MNSplitCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: leadingSeparator.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: trailingSeparator.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        //
        addSubview(indicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(orientation: UIPageViewController.NavigationOrientation) {
        if self.orientation == orientation { return }
        self.orientation = orientation
        // 先删除原约束
        NSLayoutConstraint.deactivate(leadingSeparator.constraints)
        NSLayoutConstraint.deactivate(trailingSeparator.constraints)
        NSLayoutConstraint.deactivate(constraints.filter({
            guard let firstItem = $0.firstItem as? UIView else { return false }
            if firstItem == leadingSeparator { return true }
            if firstItem == trailingSeparator { return true }
            if firstItem == collectionView { return true }
            return true
        }))
        // 更新
        leadingSeparator.isHidden = options.separatorVisibility.contains(.leading) == false
        trailingSeparator.isHidden = options.separatorVisibility.contains(.trailing) == false
        // 添加新的
        switch orientation {
        case .horizontal:
            //
            NSLayoutConstraint.activate([
                leadingSeparator.topAnchor.constraint(equalTo: topAnchor),
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
                leadingSeparator.rightAnchor.constraint(equalTo: rightAnchor),
                leadingSeparator.heightAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                trailingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
                trailingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
                trailingSeparator.rightAnchor.constraint(equalTo: rightAnchor),
                trailingSeparator.heightAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: leadingSeparator.isHidden ? topAnchor : leadingSeparator.bottomAnchor),
                collectionView.leftAnchor.constraint(equalTo: leftAnchor),
                collectionView.bottomAnchor.constraint(equalTo: trailingSeparator.isHidden ? bottomAnchor : trailingSeparator.topAnchor),
                collectionView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        default:
            //
            NSLayoutConstraint.activate([
                leadingSeparator.topAnchor.constraint(equalTo: topAnchor),
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
                leadingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
                leadingSeparator.widthAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                trailingSeparator.topAnchor.constraint(equalTo: topAnchor),
                trailingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
                trailingSeparator.rightAnchor.constraint(equalTo: rightAnchor),
                trailingSeparator.widthAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.leftAnchor.constraint(equalTo: leadingSeparator.isHidden ? leftAnchor : leadingSeparator.rightAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                collectionView.rightAnchor.constraint(equalTo: trailingSeparator.isHidden ? rightAnchor : trailingSeparator.leftAnchor)
            ])
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.isNull || bounds.isEmpty { return }
        if bounds == referenceBounds { return }
        referenceBounds = bounds
        
    }
}

// MARK: -
extension MNSegmentedView {
    
    
    /// 重载所有控制项
    /// - Parameter titles: 使用标题
    func reloadItems(with titles: [String]? = nil) {
        var elements: [String] = []
        if let titles = titles, titles.isEmpty == false {
            elements.append(contentsOf: titles)
        } else if let dataSource = dataSource {
            elements.append(contentsOf: dataSource.preferredPageTitles)
        }
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var sectionInset = options.splitInset
        switch axis {
        case .horizontal:
            layout.scrollDirection = .horizontal
            sectionInset.left += (headAccessoryView?.frame.width ?? 0.0)
            sectionInset.right += (tailAccessoryView?.frame.width ?? 0.0)
            layout.sectionInset = sectionInset
            layoutHorizontalSplitter(titles: items)
            // 横向滑动在这里处理相邻项间隔
            if let first = spliters.first, spliters.allSatisfy({ $0.frame.width == first.frame.width }) {
                layout.minimumInteritemSpacing = 0.0
                layout.minimumLineSpacing = options.interSpliterSpacing
            } else {
                layout.minimumLineSpacing = 0.0
                layout.minimumInteritemSpacing = options.interSpliterSpacing
            }
        default:
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = options.interSpliterSpacing
            sectionInset.top += (headAccessoryView?.frame.height ?? 0.0)
            sectionInset.bottom += (tailAccessoryView?.frame.height ?? 0.0)
            layout.sectionInset = sectionInset
            layoutVerticalSplitter(titles: items)
        }
        currentPageIndex = max(0, min(currentPageIndex, spliters.count - 1))
        if currentPageIndex < spliters.count {
            let spliter = spliters[currentPageIndex]
            spliter.isSelected = true
            spliter.titleColor = options.highlightedTitleColor
            spliter.transformScale = options.highlightedScale
            spliter.borderColor = options.spliterHighlightedBorderColor
            spliter.backgroundColor = options.spliterHighlightedBackgroundColor
            spliter.backgroundImage = options.spliterHighlightedBackgroundImage
            shadow.frame = spliter.shadowFrame
        } else {
            shadow.frame = .zero
        }
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }
    
}
