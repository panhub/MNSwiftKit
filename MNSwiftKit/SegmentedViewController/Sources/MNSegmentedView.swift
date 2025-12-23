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
    
    /// 配置
    private let configuration: MNSegmentedConfiguration
    
    /// 分各项数组
    private var items: [MNSegmentedItem] = []
    
    /// 背景内容视图
    private var backgroundContentView: UIView!
    
    /// 表格重用标识符
    private var reuseIdentifier: String = "com.mn.segmented.cell.identifier"
    
    /// 上一次选中索引
    internal var lastSelectIndex: Int = 0
    /// 当前选中索引
    internal var selectedIndex: Int = 0
    
    // 指示视图
    var indicatorView = UIImageView()
    // 前/左分割线
    private let leadingSeparator = UIView()
    // 后/右分割线
    private let trailingSeparator = UIView()
    /// 前附属视图
    private weak var leadingAccessoryView: UIView?
    /// 后附属视图
    private weak var trailingAccessoryView: UIView?
    // 集合视图
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    
    init(configuration: MNSegmentedConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        leadingSeparator.backgroundColor = configuration.view.separatorColor
        leadingSeparator.isHidden = configuration.view.separatorStyle.contains(.leading) == false
        leadingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leadingSeparator)
        
        trailingSeparator.backgroundColor = configuration.view.separatorColor
        trailingSeparator.isHidden = configuration.view.separatorStyle.contains(.trailing) == false
        trailingSeparator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trailingSeparator)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = configuration.view.contentInset
        layout.scrollDirection = configuration.orientation == .horizontal ? .horizontal : .vertical
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = configuration.orientation == .horizontal ? configuration.item.spacing : 0.0
        layout.minimumInteritemSpacing = configuration.orientation == .horizontal ? 0.0 : configuration.item.spacing
        
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
        
        switch configuration.orientation {
        case .horizontal:
            //
            NSLayoutConstraint.activate([
                leadingSeparator.topAnchor.constraint(equalTo: topAnchor),
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: configuration.view.separatorInset.left),
                leadingSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -configuration.view.separatorInset.right),
                leadingSeparator.heightAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                trailingSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: configuration.view.separatorInset.left),
                trailingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
                trailingSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -configuration.view.separatorInset.right),
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
                leadingSeparator.topAnchor.constraint(equalTo: topAnchor, constant: configuration.view.separatorInset.top),
                leadingSeparator.leftAnchor.constraint(equalTo: leftAnchor),
                leadingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -configuration.view.separatorInset.bottom),
                leadingSeparator.widthAnchor.constraint(equalToConstant: 0.7)
            ])
            NSLayoutConstraint.activate([
                trailingSeparator.topAnchor.constraint(equalTo: topAnchor, constant: configuration.view.separatorInset.top),
                trailingSeparator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -configuration.view.separatorInset.bottom),
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
        
        // 指示器视图
        indicatorView.clipsToBounds = true
        indicatorView.image = configuration.indicator.image
        indicatorView.layer.cornerRadius = configuration.indicator.cornerRadius
        indicatorView.contentMode = configuration.indicator.contentMode
        indicatorView.backgroundColor = configuration.indicator.backgroundColor
        switch configuration.indicator.size {
        case .matchTitle(let height):
            indicatorView.frame.size.height = height
        case .matchItem(let height):
            indicatorView.frame.size.height = height
        case .fixed(_, let height):
            indicatorView.frame.size.height = height
        }
        switch configuration.indicator.position {
        case .above:
            // 指示器在上层
            collectionView.addSubview(indicatorView)
        case .below:
            // 指示器在底层
            
            let backgroundView = UIView()
            backgroundView.isUserInteractionEnabled = false
            collectionView.backgroundView = backgroundView
            
            backgroundContentView = UIView(frame: backgroundView.bounds)
            backgroundContentView.autoresizingMask = [.flexibleHeight]
            backgroundView.addSubview(backgroundContentView)
            
            backgroundContentView.addSubview(indicatorView)
            
            collectionView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.old, .new], context: nil)
            collectionView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.old, .new], context: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let _ = backgroundContentView {
            collectionView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
            collectionView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let change = change else { return }
        switch keyPath {
        case #keyPath(UIScrollView.contentSize):
            guard let contentSize = change[.newKey] as? CGSize else { break }
            backgroundContentView.frame.size.width = contentSize.width
        case #keyPath(UIScrollView.contentOffset):
            guard let contentOffset = change[.newKey] as? CGPoint else { break }
            switch configuration.orientation {
            case .horizontal:
                backgroundContentView.frame.origin.x = -contentOffset.x
            default:
                backgroundContentView.frame.origin.y = -contentOffset.y
            }
        default:
            // 一般不会走到这里
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension MNSegmentedView {
    
    /// 注册表格
    /// - Parameters:
    ///   - cellClass: 表格类
    ///   - reuseIdentifier: 表格重用标识符
    func register<T>(_ cellClass: T.Type, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) where T: MNSplitCellConvertible {
        self.reuseIdentifier = reuseIdentifier
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func register(_ nib: UINib?, forSegmentedCellWithReuseIdentifier reuseIdentifier: String) {
        self.reuseIdentifier = reuseIdentifier
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

// MARK: - Reload
extension MNSegmentedView {
    
    /// 重载附属视图
    func reloadAccessoryView() {
        let contentInset = configuration.view.contentInset
        if let accessoryView = leadingAccessoryView {
            accessoryView.removeFromSuperview()
            leadingAccessoryView = nil
        }
        if let dataSource = dataSource, let accessoryView = dataSource.preferredHeadAccessoryView, let accessoryView = accessoryView {
            // 前/左附属视图
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(accessoryView, aboveSubview: collectionView)
            leadingAccessoryView = accessoryView
            switch configuration.orientation {
            case .horizontal:
                NSLayoutConstraint.activate([
                    accessoryView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: contentInset.top),
                    accessoryView.leftAnchor.constraint(equalTo: leftAnchor),
                    accessoryView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -contentInset.bottom),
                    accessoryView.widthAnchor.constraint(equalToConstant: accessoryView.frame.width)
                ])
            default:
                NSLayoutConstraint.activate([
                    accessoryView.topAnchor.constraint(equalTo: topAnchor),
                    accessoryView.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: contentInset.left),
                    accessoryView.rightAnchor.constraint(equalTo: collectionView.rightAnchor, constant: -contentInset.right),
                    accessoryView.heightAnchor.constraint(equalToConstant: accessoryView.frame.height)
                ])
            }
        }
        if let accessoryView = trailingAccessoryView {
            accessoryView.removeFromSuperview()
            trailingAccessoryView = nil
        }
        if let dataSource = dataSource, let accessoryView = dataSource.preferredTailAccessoryView, let accessoryView = accessoryView {
            // 后/右附属视图
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(accessoryView, aboveSubview: collectionView)
            trailingAccessoryView = accessoryView
            switch configuration.orientation {
            case .horizontal:
                NSLayoutConstraint.activate([
                    accessoryView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: contentInset.top),
                    accessoryView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -contentInset.bottom),
                    accessoryView.rightAnchor.constraint(equalTo: rightAnchor),
                    accessoryView.widthAnchor.constraint(equalToConstant: accessoryView.frame.width)
                ])
            default:
                NSLayoutConstraint.activate([
                    accessoryView.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: contentInset.left),
                    accessoryView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    accessoryView.rightAnchor.constraint(equalTo: collectionView.rightAnchor, constant: -contentInset.right),
                    accessoryView.heightAnchor.constraint(equalToConstant: accessoryView.frame.height)
                ])
            }
        }
    }
    
    /// 重载所有控制项
    /// - Parameter titles: 使用标题
    func reloadItems() {
        var titles: [String] = []
        if let dataSource = dataSource {
            titles.append(contentsOf: dataSource.preferredPageTitles)
        }
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        switch layout.scrollDirection {
        case .horizontal:
            reloadHorizontalItems(titles)
        default:
            reloadVerticalItems(titles)
        }
        selectedIndex = max(0, min(selectedIndex, items.count - 1))
//        if currentPageIndex < spliters.count {
//            let spliter = spliters[currentPageIndex]
//            spliter.isSelected = true
//            spliter.titleColor = options.highlightedTitleColor
//            spliter.transformScale = options.highlightedScale
//            spliter.borderColor = options.spliterHighlightedBorderColor
//            spliter.backgroundColor = options.spliterHighlightedBackgroundColor
//            spliter.backgroundImage = options.spliterHighlightedBackgroundImage
//            shadow.frame = spliter.shadowFrame
//        } else {
//            shadow.frame = .zero
//        }
//        UIView.performWithoutAnimation {
//            collectionView.reloadData()
//        }
    }
    
    private func reloadHorizontalItems(_ titles: [String]) {
        
    }
    
    private func reloadVerticalItems(_ titles: [String]) {
        
    }
}
