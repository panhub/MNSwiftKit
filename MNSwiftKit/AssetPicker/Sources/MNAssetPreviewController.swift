//
//  MNAssetPreviewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/4.
//  资源预览控制器

import UIKit

/// 资源浏览控制器代理
@objc protocol MNAssetPreviewControllerDelegate: NSObjectProtocol {
    
    /// 告知更新资源状态
    /// - Parameter asset: 资源模型
    @objc func previewControllerUpdateAsset(_ asset: MNAsset)
}

/// 资源预览控制器
class MNAssetPreviewController: UIViewController {
    /// 间隔
    private let itemInterSpacing: CGFloat = 15.0
    /// 媒体数组
    private var assets: [MNAsset] = []
    /// 当前展示的索引
    private var displayIndex: Int = .min
    /// 配置信息
    private let options: MNAssetPickerOptions
    /// 是否在销毁时删除本地资源文件
    var clearWhenExit: Bool = false
    /// 是否允许自动播放
    var isAllowsAutoPlaying: Bool = true
    /// 事件代理
    weak var delegate: MNAssetPreviewControllerDelegate?
    /// 顶部导航栏
    private let navView = UIImageView()
    /// 导航右侧选择按钮
    private let rightBarButton = UIButton(type: .custom)
    /// 底部选择栏
    private lazy var selectView = MNAssetSelectView(assets: assets, options: options)
    /// 集合视图
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    /// 构造资源浏览器
    /// - Parameters:
    ///   - assets: 资源模型集合
    ///   - options: 资源选择器配置
    init(assets: [MNAsset], options: MNAssetPickerOptions) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
        self.assets.append(contentsOf: assets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if clearWhenExit {
            assets.forEach { $0.contents = nil }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // 集合视图
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.headerReferenceSize = .zero
        layout.footerReferenceSize = .zero
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = itemInterSpacing
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: itemInterSpacing/2.0, bottom: 0.0, right: itemInterSpacing/2.0)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.delaysContentTouches = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.canCancelContentTouches = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MNAssetBrowserCell.self, forCellWithReuseIdentifier: "com.mn.asset.preview.cell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never;
        }
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: -itemInterSpacing/2.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: itemInterSpacing/2.0)
        ])
        
        // 导航
        navView.contentMode = .scaleToFill
        navView.isUserInteractionEnabled = true
        navView.image = AssetPickerResource.image(named: "top")
        navView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navView)
        NSLayoutConstraint.activate([
            navView.topAnchor.constraint(equalTo: view.topAnchor),
            navView.leftAnchor.constraint(equalTo: view.leftAnchor),
            navView.rightAnchor.constraint(equalTo: view.rightAnchor),
            navView.heightAnchor.constraint(equalToConstant: options.topBarHeight)
        ])
        
        // 返回
        let back = UIButton(type: .custom)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.addTarget(self, action: #selector(self.back), for: .touchUpInside)
        let backImage = AssetPickerResource.image(named: "back")
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.background.backgroundColor = .clear
            back.configuration = configuration
            back.configurationUpdateHandler = { button in
                switch button.state {
                case .normal, .highlighted:
                    button.configuration?.background.image = backImage
                default: break
                }
            }
        } else {
            back.adjustsImageWhenHighlighted = false
            back.setBackgroundImage(backImage, for: .normal)
        }
        navView.addSubview(back)
        NSLayoutConstraint.activate([
            back.widthAnchor.constraint(equalToConstant: 24.0),
            back.heightAnchor.constraint(equalToConstant: 24.0),
            back.leftAnchor.constraint(equalTo: navView.leftAnchor, constant: 16.0),
            back.topAnchor.constraint(equalTo: navView.topAnchor, constant: options.statusBarHeight + (options.navBarHeight - 24.0)/2.0)
        ])
        
        // 选择
        rightBarButton.isSelected = true
        rightBarButton.clipsToBounds = true
        rightBarButton.layer.cornerRadius = 12.0
        rightBarButton.translatesAutoresizingMaskIntoConstraints = false
        rightBarButton.addTarget(self, action: #selector(rightBarButtonTouchUpInside(_:)), for: .touchUpInside)
        let normalImage = AssetPickerResource.image(named: "unselect")
        let selectedImage = AssetPickerResource.image(named: "selected")
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.background.backgroundColor = .clear
            rightBarButton.configuration = configuration
            rightBarButton.configurationUpdateHandler = { button in
                switch button.state {
                case .normal:
                    button.configuration?.background.image = normalImage
                case .selected:
                    button.configuration?.background.image = selectedImage
                case .highlighted:
                    button.configuration?.background.image = button.isSelected ? selectedImage : normalImage
                default: break
                }
            }
        } else {
            rightBarButton.adjustsImageWhenHighlighted = false
            rightBarButton.setBackgroundImage(normalImage, for: .normal)
            rightBarButton.setBackgroundImage(selectedImage, for: .selected)
        }
        navView.addSubview(rightBarButton)
        NSLayoutConstraint.activate([
            rightBarButton.widthAnchor.constraint(equalToConstant: 23.0),
            rightBarButton.heightAnchor.constraint(equalToConstant: 23.0),
            rightBarButton.rightAnchor.constraint(equalTo: navView.rightAnchor, constant: -16.0),
            rightBarButton.centerYAnchor.constraint(equalTo: back.centerYAnchor)
        ])
        
        // 底部选择视图
        selectView.delegate = self
        selectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectView)
        NSLayoutConstraint.activate([
            selectView.leftAnchor.constraint(equalTo: view.leftAnchor),
            selectView.rightAnchor.constraint(equalTo: view.rightAnchor),
            selectView.heightAnchor.constraint(equalToConstant: 100.0),
            selectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -MNAssetBrowserCell.ToolBarHeight),
        ])
        
        // 放大
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(double(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        // 清屏
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(single(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        view.addGestureRecognizer(singleTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if displayIndex == .min {
            updateDisplayIndex()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let cell = currentDisplayCell {
            cell.pauseDisplaying()
        }
    }
    
    /// 状态栏
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MNAssetPreviewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { assets.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.mn.asset.preview.cell", for: indexPath)
        if let cell = cell as? MNAssetBrowserCell {
            cell.delegate = self
            cell.isAllowsAutoPlaying = isAllowsAutoPlaying
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetBrowserCell, indexPath.item < assets.count else { return }
        let asset = assets[indexPath.item]
        cell.willDisplay(asset)
        cell.updateToolBar(visible: navView.transform == .identity, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetBrowserCell else { return }
        cell.endDisplaying()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false, scrollView.isDragging == false, scrollView.isDecelerating == false else { return }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateDisplayIndex()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MNAssetPreviewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let rect = collectionView.frame.inset(by: layout.sectionInset)
        return rect.size
    }
}

// MARK: - MNAssetBrowseResourceHandler
extension MNAssetPreviewController: MNAssetBrowseResourceHandler {
    
    func browserCell(_ cell: MNAssetBrowserCell, fetchCover asset: any MNAssetBrowseSupported, completion completionHandler: @escaping (any MNAssetBrowseSupported) -> Void) {
        
        MNAssetHelper.fetchCover(for: asset as! MNAsset, completion: completionHandler)
    }
    
    func browserCell(_ cell: MNAssetBrowserCell, fetchContents asset: any MNAssetBrowseSupported, progress progressHandler: @escaping (any MNAssetBrowseSupported, Double, (any Error)?) -> Void, completion completionHandler: @escaping (any MNAssetBrowseSupported) -> Void) {
        
        MNAssetHelper.fetchContents(for: asset as! MNAsset, progress: progressHandler, completion: completionHandler)
    }
}

// MARK: -
private extension MNAssetPreviewController {
    
    /// 获取当前表格
    private var currentDisplayCell: MNAssetBrowserCell? {
        collectionView.cellForItem(at: IndexPath(item: displayIndex, section: 0)) as? MNAssetBrowserCell
    }
    
    /// 更新索引
    func updateDisplayIndex() {
        var currentIndex: Int = Int(round(collectionView.contentOffset.x/collectionView.bounds.width))
        if currentIndex == displayIndex { return }
        guard currentIndex < assets.count else { return }
        let asset = assets[currentIndex]
        if let index = assets.firstIndex(where: { $0.isSelected == false }) {
            // 删除无效资源
            let model = assets.remove(at: index)
            if clearWhenExit {
                model.contents = nil
            }
            currentIndex = assets.firstIndex(of: asset)!
            UIView.performWithoutAnimation {
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
        displayIndex = currentIndex
        rightBarButton.isSelected = asset.isSelected
        if asset.isSelected {
            selectView.selection(index: currentIndex)
        }
        if let cell = currentDisplayCell {
            cell.preparedDisplay()
        }
    }
}

// MARK: - 手势交互
extension MNAssetPreviewController {
    
    /// 双击事件
    /// - Parameter recognizer: 手势
    @objc func double(recognizer: UITapGestureRecognizer) {
        guard let cell = currentDisplayCell else { return }
        let location = recognizer.location(in: cell.scrollView.contentView)
        guard cell.scrollView.contentView.bounds.contains(location) else { return }
        if cell.scrollView.zoomScale > 1.0 {
            cell.scrollView.setZoomScale(1.0, animated: true)
        } else {
            let scale = cell.scrollView.maximumZoomScale
            let width = cell.scrollView.bounds.width/scale
            let height = cell.scrollView.bounds.height/scale
            cell.scrollView.zoom(to: CGRect(x: location.x - width/2.0, y: location.y - height/2.0, width: width, height: height), animated: true)
        }
    }
    
    /// 单击事件
    /// - Parameter recognizer: 手势
    @objc func single(recognizer: UITapGestureRecognizer) {
        let visible = navView.transform == .identity
        if visible {
            let location = recognizer.location(in: view)
            if selectView.isHidden == false {
                guard selectView.frame.contains(location) == false else { return }
            }
            guard view.bounds.inset(by: UIEdgeInsets(top: navView.frame.maxY, left: 0.0, bottom: 0.0, right: 0.0)).contains(location) else { return }
        }
        guard let cell = currentDisplayCell else { return }
        let location = recognizer.location(in: cell.scrollView.contentView)
        guard cell.scrollView.contentView.bounds.contains(location) else { return }
        cell.updateToolBar(visible: visible == false, animated: true)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
            guard let self = self else { return }
            self.navView.transform = visible ? .init(translationX: 0.0, y: -self.navView.frame.maxY) : .identity
            self.selectView.alpha = visible ? 0.0 : 1.0
        }
    }
}

// MARK: - Event
extension MNAssetPreviewController {
    
    /// 返回事件
    /// - Parameter sender: 返回按钮
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 更新资源
    /// - Parameter sender: 选择按钮
    @objc private func rightBarButtonTouchUpInside(_ sender: UIButton) {
        guard displayIndex < assets.count else { return }
        let asset = assets[displayIndex]
        if let delegate = delegate {
            delegate.previewControllerUpdateAsset(asset)
        }
        if sender.isSelected {
            // 取消选中
            guard asset.isSelected == false else { return }
            sender.isSelected = false
            selectView.deleteAsset(asset)
        } else {
            // 选中
            guard asset.isSelected else { return }
            sender.isSelected = true
            if assets.count > 1, displayIndex != (assets.count - 1) {
                let lastDisplayIndex: Int = displayIndex
                if let index = assets.firstIndex(of: asset) {
                    assets.remove(at: index)
                    assets.append(asset)
                }
                displayIndex = assets.count - 1
                UIView.performWithoutAnimation {
                    collectionView.moveItem(at: IndexPath(item: lastDisplayIndex, section: 0), to: IndexPath(item: displayIndex, section: 0))
                    collectionView.scrollToItem(at: IndexPath(item: displayIndex, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
            selectView.appendAsset(asset)
        }
    }
}

// MARK: - MNAssetSelectViewDelegate
extension MNAssetPreviewController: MNAssetSelectViewDelegate {
    
    func selectView(_ selectView: MNAssetSelectView, didSelect asset: MNAsset) {
        guard let index = assets.firstIndex(of: asset) else { return }
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.updateDisplayIndex()
        }
    }
}

// MARK: - 屏幕旋转
extension MNAssetPreviewController {
    override var shouldAutorotate: Bool { false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
}
