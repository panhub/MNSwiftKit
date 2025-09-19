//
//  MNAssetPreviewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/2/4.
//  资源预览控制器

import UIKit
//#if canImport(MNSwiftKitLayout)
//import MNSwiftKitLayout
//#endif
//#if canImport(MNSwiftKitDefinition)
//import MNSwiftKitDefinition
//#endif

/// 资源浏览控制器代理
@objc protocol MNAssetPreviewControllerDelegate: NSObjectProtocol {
    /// 告知更新资源状态
    /// - Parameter asset: 资源模型
    @objc optional func previewControllerUpdateAsset(_ asset: MNAsset) -> Void
    /// 资源浏览控制器滑动告知
    /// - Parameter controller: 资源浏览控制器
    @objc optional func previewController(didScroll controller: MNAssetPreviewController) -> Void
    /// 资源浏览控制器事件
    /// - Parameters:
    ///   - controller: 资源浏览控制器
    ///   - sender: 按钮
    @objc optional func previewController(_ controller: MNAssetPreviewController, buttonTouchUpInside sender: UIControl) -> Void
}

/// 资源预览控制器
class MNAssetPreviewController: UIViewController {
    /// 事件
    struct Event: OptionSet {
        /// 选择
        static let select = Event(rawValue: 1 << 1)
        /// 确定
        static let done = Event(rawValue: 1 << 2)
        
        let rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    /// 间隔
    private let itemInterSpacing: CGFloat = 15.0
    /// 媒体数组
    private var assets: [MNAsset] = [MNAsset]()
    /// 配置信息
    private let options: MNAssetPickerOptions
    /// 是否在销毁时删除本地资源文件
    var cleanWhenExit: Bool = false
    /// 外界定制功能
    var events: Event = []
    /// 事件代理
    weak var delegate: MNAssetPreviewControllerDelegate?
    /// 是否允许自动播放
    var isAllowsAutoPlaying: Bool = true
    /// 当前展示的索引
    private(set) var displayIndex: Int = .min
    /// 状态栏
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    /// 底部选择栏
    private lazy var selectView: MNAssetSelectView = {
        let selectView = MNAssetSelectView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: 100.0), assets: assets, options: options)
        selectView.mn.maxY = view.bounds.height - MNAssetBrowserCell.ToolBarHeight
        selectView.delegate = self
        return selectView
    }()
    /// 顶部导航栏
    private lazy var navView: UIView = {
        let navView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: MN_TOP_BAR_HEIGHT))
        navView.backgroundColor = .clear
        navView.contentMode = .scaleToFill
        navView.isUserInteractionEnabled = true
        navView.image = AssetPickerResource.image(named: "top")
        let back = UIButton(type: .custom)
        back.frame = CGRect(x: 15.0, y: 0.0, width: 25.0, height: 25.0)
        back.mn.midY = (navView.frame.height - MN_STATUS_BAR_HEIGHT)/2.0 + MN_STATUS_BAR_HEIGHT
        back.setBackgroundImage(AssetPickerResource.image(named: "back"), for: .normal)
        back.addTarget(self, action: #selector(back(_:)), for: .touchUpInside)
        navView.addSubview(back)
        var maxX: CGFloat = navView.frame.width - back.frame.minX
        if events.contains(.done) {
            let done = UIButton(type: .custom)
            done.frame = back.frame
            done.mn.maxX = maxX
            done.tag = Event.done.rawValue
            done.setBackgroundImage(AssetPickerResource.image(named: "done"), for: .normal)
            done.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
            navView.addSubview(done)
            maxX = done.frame.minX - 18.0
        }
        if events.contains(.select) {
            let select = UIButton(type: .custom)
            select.frame = back.frame
            select.mn.maxX = maxX
            select.isSelected = true
            select.tag = Event.select.rawValue
            select.clipsToBounds = true
            select.layer.cornerRadius = min(select.frame.width, select.frame.height)/2.0
            select.addTarget(self, action: #selector(selectButtonTouchUpInside(_:)), for: .touchUpInside)
            let normalImage = AssetPickerResource.image(named: "selectbox")
            let selectedImage = AssetPickerResource.image(named: "checkbox_fill")?.mn.rendering(to: options.themeColor)
            if #available(iOS 15.0, *) {
                var configuration = UIButton.Configuration.plain()
                configuration.background.backgroundColor = .clear
                select.configuration = configuration
                select.configurationUpdateHandler = { button in
                    switch button.state {
                    case .normal:
                        button.configuration?.background.image = normalImage
                        button.configuration?.background.backgroundColor = .clear
                    case .selected:
                        button.configuration?.background.image = selectedImage
                        button.configuration?.background.backgroundColor = .white
                    default: break
                    }
                }
            } else {
                select.adjustsImageWhenHighlighted = false
                select.setBackgroundImage(normalImage, for: .normal)
                select.setBackgroundImage(selectedImage, for: .selected)
            }
            navView.addSubview(select)
        }
        return navView
    }()
    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = itemInterSpacing
        layout.minimumInteritemSpacing = 0.0
        layout.headerReferenceSize = .zero
        layout.footerReferenceSize = .zero
        layout.itemSize = view.bounds.size
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: itemInterSpacing/2.0, bottom: 0.0, right: itemInterSpacing/2.0)
        let collectionView = UICollectionView(frame: view.bounds.inset(by: UIEdgeInsets(top: 0.0, left: -itemInterSpacing/2.0, bottom: 0.0, right: -itemInterSpacing/2.0)), collectionViewLayout: layout)
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
        collectionView.register(MNAssetBrowserCell.self, forCellWithReuseIdentifier: "com.mn.asset.preview.cell")
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never;
        }
        return collectionView
    }()
    
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
        guard cleanWhenExit else { return }
        for asset in assets.filter({ $0.content != nil }) {
            asset.content = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .black
        
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // 集合视图
        view.addSubview(collectionView)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        // 底部选择视图
        view.addSubview(selectView)
        // 导航
        view.addSubview(navView)
        // 事件
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(double(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
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
        if let cell = cellForItemAtCurrent() {
            cell.pauseDisplaying()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MNAssetPreviewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { assets.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.mn.asset.preview.cell", for: indexPath)
        if let cell = cell as? MNAssetBrowserCell {
            cell.isAllowsAutoPlaying = isAllowsAutoPlaying
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetBrowserCell, indexPath.item < assets.count else { return }
        let asset = assets[indexPath.item]
        cell.updateAsset(asset)
        cell.updateToolBar(navView.frame.minY >= 0.0, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetBrowserCell else { return }
        cell.endDisplaying()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false, scrollView.isDragging == false, scrollView.isDecelerating == false else { return }
        updateDisplayIndex()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateDisplayIndex()
    }
}

// MARK: -
private extension MNAssetPreviewController {
    
    /// 更新索引
    func updateDisplayIndex() {
        var currentIndex: Int = Int(round(collectionView.contentOffset.x/collectionView.bounds.width))
        if currentIndex == displayIndex { return }
        guard currentIndex < assets.count else { return }
        let asset = assets[currentIndex]
        if let index = assets.firstIndex(where: { $0.isSelected == false }) {
            // 删除无效资源
            if cleanWhenExit {
                // 清空资源 释放内存
                assets[index].content = nil
            }
            assets.remove(at: index)
            currentIndex = assets.firstIndex(of: asset)!
            UIView.performWithoutAnimation {
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
        displayIndex = currentIndex
        if let button = navView.viewWithTag(Event.select.rawValue) as? UIButton {
            button.isSelected = asset.isSelected
        }
        if asset.isSelected {
            selectView.selection(index: currentIndex)
        }
        if let cell = cellForItemAtCurrent() {
            cell.prepareDisplaying()
        }
        if let delegate = delegate {
            delegate.previewController?(didScroll: self)
        }
    }
    
    /// 获取当前表格
    /// - Returns: 当前表格
    func cellForItemAtCurrent() -> MNAssetBrowserCell? {
        if displayIndex == .min { return nil }
        return collectionView.cellForItem(at: IndexPath(item: displayIndex, section: 0)) as? MNAssetBrowserCell
    }
}

// MARK: - 手势交互
extension MNAssetPreviewController {
    
    /// 双击事件
    /// - Parameter recognizer: 手势
    @objc func double(recognizer: UITapGestureRecognizer) {
        guard let cell = cellForItemAtCurrent() else { return }
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
        if navView.frame.minY >= 0 {
            let location = recognizer.location(in: view)
            guard view.bounds.inset(by: UIEdgeInsets(top: navView.frame.maxY, left: 0.0, bottom: 0.0, right: 0.0)).contains(location) else { return }
            guard view.bounds.inset(by: UIEdgeInsets(top: selectView.frame.minY, left: 0.0, bottom: view.bounds.height - selectView.frame.maxY, right: 0.0)).contains(location) == false else { return }
        }
        guard let cell = cellForItemAtCurrent() else { return }
        let location = recognizer.location(in: cell.scrollView.contentView)
        guard cell.scrollView.contentView.bounds.contains(location) else { return }
        let isHidden = navView.frame.maxY <= 0.0
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
            guard let self = self else { return }
            self.navView.mn.minY = isHidden ? 0.0 : -self.navView.bounds.height
            self.selectView.alpha = isHidden ? 1.0 : 0.0
        }, completion: nil)
        cell.updateToolBar(isHidden, animated: true)
    }
}

// MARK: - Event
extension MNAssetPreviewController {
    
    /// 返回事件
    /// - Parameter sender: 返回按钮
    @objc private func back(_ sender: UIControl) {
        navigationController?.popViewController(animated: true)
    }
    
    /// 更新资源
    /// - Parameter sender: 选择按钮
    @objc private func selectButtonTouchUpInside(_ sender: UIButton) {
        guard displayIndex < assets.count else { return }
        let asset = assets[displayIndex]
        delegate?.previewControllerUpdateAsset?(asset)
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
    
    /// 自定义按钮点击事件
    /// - Parameter sender: 自定义按钮
    @objc private func buttonTouchUpInside(_ sender: UIControl) {
        delegate?.previewController?(self, buttonTouchUpInside: sender)
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
