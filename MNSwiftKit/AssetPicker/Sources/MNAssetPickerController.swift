//
//  MNAssetPickerController.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  资源挑选控制器

import UIKit
import Photos
//#if canImport(MNSwiftKitToast)
//import MNSwiftKitToast
//#endif
//#if canImport(MNSwiftKitDefinition)
//import MNSwiftKitDefinition
//#endif
//#if canImport(MNSwiftKitEmptyView)
//import MNSwiftKitEmptyView
//#endif

class MNAssetPickerController: UIViewController {
    /// 配置信息
    private let options: MNAssetPickerOptions
    /// 是否进入相册
    private var isEnterLibrary: Bool = false
    /// 是否加载了资源
    private var isAssetLoaded: Bool = false
    /// 当前资源集合
    private var assets: [MNAsset] = [MNAsset]()
    /// 选中的资源集合
    private var selections: [MNAsset] = [MNAsset]()
    /// 上一次交互索引
    private var lastTouchIndex: Int = .min
    /// 状态栏修改
    private lazy var statusBarStyle: UIStatusBarStyle = {
        return options.mode == .dark ? .lightContent : .default
    }()
    private var statusBarHidden: Bool = false
    override var prefersStatusBarHidden: Bool { statusBarHidden }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
    /// 顶部栏
    private lazy var navBar: MNAssetPickerNavBar = MNAssetPickerNavBar(options: options)
    /// 相册视图
    private lazy var albumView: MNAssetAlbumView = MNAssetAlbumView(options: options)
    /// 底部工具栏
    private lazy var toolBar: MNAssetPickerToolBar = MNAssetPickerToolBar(options: options)
    /// 资源展示
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    init(options: MNAssetPickerOptions) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.backgroundColor = options.backgroundColor
        
        let numberOfColumns: Int = max(options.numberOfColumns, 3)
        let itemWidth = floor((view.frame.width - CGFloat(numberOfColumns - 1)*options.minimumInteritemSpacing)/CGFloat(numberOfColumns))
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = options.minimumLineSpacing
        layout.minimumInteritemSpacing = options.minimumInteritemSpacing
        layout.headerReferenceSize = .zero
        layout.footerReferenceSize = .zero
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = options.contentInset
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.mn_empty.delegate = self
        collectionView.mn_empty.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = options.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MNAssetCell.self, forCellWithReuseIdentifier: NSStringFromClass(MNAssetCell.self))
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(collectionView)
        view.addConstraints([
            NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: collectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: collectionView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        navBar.delegate = self
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)
        navBar.addConstraint(NSLayoutConstraint(item: navBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: options.contentInset.top))
        view.addConstraints([
            NSLayoutConstraint(item: navBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: navBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: navBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        albumView.delegate = self
        albumView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(albumView)
        view.addConstraints([
            NSLayoutConstraint(item: albumView, attribute: .top, relatedBy: .equal, toItem: navBar, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: albumView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: albumView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: options.contentInset.bottom),
            NSLayoutConstraint(item: albumView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        toolBar.delegate = self
        toolBar.isHidden = options.maxPickingCount <= 1
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)
        toolBar.addConstraint(NSLayoutConstraint(item: toolBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: options.bottomBarHeight))
        view.addConstraints([
            NSLayoutConstraint(item: toolBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: toolBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: toolBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        ])
        
        // 分页支持
        if options.sortAscending {
            // 升序则上拉加载更多
            let footer = MNAssetPickerFooter(target: self, action: #selector(loadMore))
            footer.mn_layout.height = MN_TAB_BAR_HEIGHT
            footer.color = options.mode == .light ? .black : .gray
            footer.offset = UIOffset(horizontal: 0.0, vertical: -options.contentInset.bottom)
            collectionView.mn_refresh.footer = footer
        } else {
            // 降序则下滑加载更多
            let header = MNRefreshStateHeader(target: self, action: #selector(loadMore))
            header.color = options.mode == .light ? .black : .gray
            header.offset = UIOffset(horizontal: 0.0, vertical: options.contentInset.top)
            collectionView.mn_refresh.header = header
        }
        
        if options.maxPickingCount > 1, options.allowsSlidePicking, options.allowsMultiplePickingPhoto, options.allowsMultiplePickingGif, options.allowsMultiplePickingVideo, options.allowsMultiplePickingLivePhoto {
            // 滑动选择
            // collectionView.bounces = false
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
            pan.maximumNumberOfTouches = 1
            view.addGestureRecognizer(pan)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        // 请求相册
        if isAssetLoaded == false {
            isAssetLoaded = true
            applyPermission()
        }
    }
}

// MARK: - Completed
extension MNAssetPickerController {
    
    /// 导出资源并结束选择
    /// - Parameter assets: 需要导出内容的资源模型集合
    private func didPicking(_ assets: [MNAsset]) {
        guard let view = navigationController?.view else { return }
        view.showActivityToast("请稍后")
        view.isUserInteractionEnabled = false
        MNAssetHelper.exportAsynchronously(assets, options: options) { [weak view] index, count in
            guard let view = view else { return }
            view.updateToast(status: "正在导出\(index)/\(count)")
        } completion: { [weak view, weak self] result in
            guard let view = view else { return }
            view.isUserInteractionEnabled = true
            view.closeToast {
                guard let self = self else { return }
                if result.count == assets.count {
                    self.finishPicking(result)
                } else if (result.isEmpty || result.count < self.options.minPickingCount) {
                    // 低于最小数量
                    let alert = UIAlertController(title: nil, message: "iCloud资源下载失败!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                    alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.didPicking(assets)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // 有失败的
                    let alert = UIAlertController(title: nil, message: "\(assets.count - result.count)项资源导出失败!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.finishPicking(result)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    /// 结束选择
    /// - Parameter assets: 已导出的资源集合
    private func finishPicking(_ assets: [MNAsset]) {
        guard let picker = navigationController as? MNAssetPicker else { return }
        guard let delegate = options.delegate else { return }
        delegate.assetPicker(picker, didFinishPicking: assets)
    }
}

// MARK: - Fetch
extension MNAssetPickerController {
    
    /// 请求权限
    private func applyPermission() {
        var availables: [PHAuthorizationStatus] = [.authorized]
        if #available(iOS 14, *) {
            availables.append(.limited)
        }
        let authorizationHandler: (PHAuthorizationStatus)->Void = { [weak self] status in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if availables.contains(status) {
                    // 可以调用相册API
                    self.fetchAlbums()
                } else {
                    // 确保显示占位图
                    self.isEnterLibrary = true
                    self.collectionView.reloadData()
                    self.collectionView.closeToast()
                }
            }
        }
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            authorizationHandler(.restricted)
            return
        }
        var status: PHAuthorizationStatus = .denied
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        switch status {
        case .notDetermined:
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite, handler: authorizationHandler)
            } else {
                PHPhotoLibrary.requestAuthorization(authorizationHandler)
            }
        default:
            authorizationHandler(status)
        }
    }
    
    /// 获取相簿集合
    private func fetchAlbums() {
        collectionView.showActivityToast("请稍后")
        MNAssetHelper.fetchAlbum(options) { [weak self] albums in
            guard let self = self else { return }
            self.isEnterLibrary = true
            if let first = albums.first {
                first.isSelected = true
                self.albumView.update(albums: albums)
                self.navBar.badge.isEnabled = albums.count > 1
                self.fetchAssets(in: first)
            } else {
                // 确保显示占位图
                self.collectionView.reloadData()
                self.collectionView.closeToast()
            }
        }
    }
    
    private func fetchAssets(in album: MNAssetAlbum) {
        let completionHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.updateAlbum(album)
            self.collectionView.mn_refresh.endRefreshing()
            self.collectionView.mn_refresh.endLoadMore()
            let hasMore: Bool = album.offset < album.count
            if let header = self.collectionView.mn_refresh.header {
                if hasMore {
                    header.endRefreshing()
                } else {
                    header.endRefreshingAndNoMoreData()
                }
            }
            if let footer = self.collectionView.mn_refresh.footer {
                if hasMore {
                    footer.endRefreshing()
                } else {
                    footer.endRefreshingAndNoMoreData()
                }
            }
            self.navBar.badge.isUserInteractionEnabled = true
            self.collectionView.closeToast()
        }
        if (album.assets.count > 0 || album.page > 1) && collectionView.mn_refresh.isLoading == false {
            completionHandler()
        } else {
            if collectionView.mn_refresh.isLoading == false {
                collectionView.showActivityToast("请稍后")
            }
            navBar.badge.isUserInteractionEnabled = false
            MNAssetHelper.fetchAsset(in: album, options: options, completion: completionHandler)
        }
    }
}

// MARK: - Loading
extension MNAssetPickerController {
    
    /// 加载更多
    @objc private func loadMore() {
        guard let album = albumView.albums.first(where: { $0.isSelected }) else {
            collectionView.mn_refresh.endRefreshing()
            collectionView.mn_refresh.endLoadMore()
            return
        }
        fetchAssets(in: album)
    }
}

// MARK: - Update
extension MNAssetPickerController {
    
    /// 更新相簿
    /// - Parameter album: 相簿模型
    private func updateAlbum(_ album: MNAssetAlbum) {
        // 处理不可选
        if album.assets.count > 0 {
            for asset in album.assets.filter({ $0.isEnabled == false }) {
                asset.isEnabled = true
            }
            reloadAssets(album.assets)
        }
        assets.removeAll()
        assets.append(contentsOf: album.assets)
        collectionView.reloadData()
        navBar.badge.updateTitle(album.name, animated: navBar.badge.isEnabled)
        if assets.count > 0, album.page == 1, options.sortAscending == false {
            let indexPath = IndexPath(item: assets.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        }
    }
    
    /// 更新资源
    /// - Parameter asset: 资源模型
    private func updateAsset(_ asset: MNAsset) {
        if asset.isSelected {
            asset.index = 0
            asset.isSelected = false
            selections.removeAll { $0 == asset }
        } else {
            asset.isSelected = true
            selections.append(asset)
        }
        // 更新标记
        for (index, asset) in selections.enumerated() {
            asset.index = index + 1
        }
        reloadAssets(assets)
        toolBar.updateAssets(selections)
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }
    
    /// 更新资源状态
    /// - Parameter assets: 需要更新状态的资源模型集合
    private func reloadAssets(_ assets: [MNAsset]) {
        // 判断是否超过限制
        if selections.count >= options.maxPickingCount {
            // 标记不能再选择
            for asset in assets.filter({ $0.isSelected == false && $0.isEnabled }) {
                asset.isEnabled = false
            }
        } else {
            // 结束限制
            for asset in assets {
                asset.isEnabled = true
            }
            // 类型限制
            if selections.count > 0 {
                let type = selections.first!.type
                if options.allowsMixPicking == false {
                    for asset in assets.filter({ $0.isSelected == false && $0.type != type }) {
                        asset.isEnabled = false
                    }
                }
                // 检查限制(可不加)
                if type == .photo, options.allowsMultiplePickingPhoto == false {
                    for asset in assets.filter({ $0.isSelected == false && $0.type == .photo }) {
                        asset.isEnabled = false
                    }
                } else if type == .gif, options.allowsMultiplePickingGif == false {
                    for asset in assets.filter({ $0.isSelected == false && $0.type == .gif }) {
                        asset.isEnabled = false
                    }
                } else if type == .video, options.allowsMultiplePickingVideo == false {
                    for asset in assets.filter({ $0.isSelected == false && $0.type == .video }) {
                        asset.isEnabled = false
                    }
                } else if type == .livePhoto, options.allowsMultiplePickingLivePhoto == false {
                    for asset in assets.filter({ $0.isSelected == false && $0.type == .livePhoto }) {
                        asset.isEnabled = false
                    }
                }
            }
        }
    }
}

// MARK: - PanGestureRecognizer
extension MNAssetPickerController {
    
    /// 滑动手势事件
    /// - Parameter recognizer: 滑动手势
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            guard assets.count > 0 else { return }
            let location = recognizer.location(in: view)
            guard view.bounds.inset(by: options.contentInset).contains(location) else { return }
            let point = view.convert(location, to: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: point), indexPath.item != lastTouchIndex, indexPath.item < assets.count else { return }
            lastTouchIndex = indexPath.item
            let asset = assets[indexPath.item]
            guard asset.isEnabled else { return }
            updateAsset(asset)
        default:
            lastTouchIndex = .min
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MNAssetPickerController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { assets.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(MNAssetCell.self), for: indexPath)
        if let cell = cell as? MNAssetCell {
            cell.delegate = self
            cell.options = options
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item < assets.count else { return }
        guard let cell = cell as? MNAssetCell else { return }
        let asset = assets[indexPath.item]
        cell.updateAsset(asset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetCell else { return }
        cell.endDisplaying()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < assets.count else { return }
        let asset = assets[indexPath.item]
        guard asset.isEnabled else { return }
        if options.maxPickingCount <= 1 || (asset.type == .photo && options.allowsMultiplePickingPhoto == false) || (asset.type == .gif && options.allowsMultiplePickingGif == false) || (asset.type == .video && options.allowsMultiplePickingVideo == false) || (asset.type == .livePhoto && options.allowsMultiplePickingLivePhoto == false) {
            if asset.type == .photo, options.allowsEditing {
                // TODO 图片裁剪
            } else if asset.type == .video, options.allowsEditing {
                // 视频裁剪
                tailorVideo(asset)
            } else {
                // 导出
                didPicking([asset])
            }
        } else {
            // 更新资源状态
            updateAsset(asset)
        }
    }
    
    /// 裁剪视频
    /// - Parameter asset: 视频资源模型
    private func tailorVideo(_ asset: MNAsset) {
        view.showActivityToast("请稍后")
        MNAssetHelper.fetchContent(asset, progress: nil) { [weak self] asset in
            guard let self = self else { return }
            if let videoPath = asset.content as? String {
                asset.content = nil
                self.view.closeToast()
                let vc = MNTailorViewController(videoPath: videoPath)
                vc.delegate = self
                vc.exportingPath = self.options.outputURL?.path
                vc.minTailorDuration = self.options.minExportDuration
                vc.maxTailorDuration = self.options.maxExportDuration
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.view.showMsgToast("导出视频失败")
            }
        }
    }
}

// MARK: - MNDataEmptySource
extension MNAssetPickerController: MNDataEmptySource {
    
    func dataEmptyViewShouldDisplay(_ superview: UIView) -> Bool {
        isEnterLibrary && assets.isEmpty
    }
    
    func imageForDataEmptyView(_ superview: UIView) -> UIImage? {
        AssetPickerResource.image(named: "empty")
    }
    
    func imageSizeForDataEmptyView(_ superview: UIView) -> CGSize {
        CGSize(width: 125.0, height: 125.0)
    }
    
    func descriptionForDataEmptyView(_ superview: UIView) -> NSAttributedString? {
        var status: PHAuthorizationStatus = .notDetermined
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        var availables: [PHAuthorizationStatus] = [.authorized]
        if #available(iOS 14, *) {
            availables.append(.limited)
        }
        var text: String?
        if status == .denied {
            text = "请允许访问系统相册"
        } else if availables.contains(status) {
            text = "相簿下暂无照片"
        }
        guard let text = text else { return nil }
        return NSAttributedString(string: text, attributes: [.font:UIFont.systemFont(ofSize: 16.5, weight: .regular), .foregroundColor:UIColor(red: 103.0/255.0, green: 105.0/255.0, blue: 107.0/255.0, alpha: 1.0)])
    }
    
    func buttonSizeForDataEmptyView(_ superview: UIView) -> CGSize {
        var status: PHAuthorizationStatus = .notDetermined
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        return status == .denied ? CGSize(width: 85.0, height: 35.0) : .zero
    }
    
    func buttonRadiusForDataEmptyView(_ superview: UIView) -> CGFloat {
        5.0
    }
    
    func buttonAttributedTitleForDataEmptyView(_ superview: UIView, with state: UIControl.State) -> NSAttributedString? {
        NSAttributedString(string: "授权访问", attributes: [.font:UIFont.systemFont(ofSize: 15.0, weight: .medium), .foregroundColor:UIColor.lightGray])
    }
    
    func buttonBackgroundColorForDataEmptyView(_ superview: UIView) -> UIColor? {
        options.mode == .dark ? UIColor(red: 103.0/255.0, green: 105.0/255.0, blue: 107.0/255.0, alpha: 1.0) : UIColor(red: 221.0/255.0, green: 223.0/255.0, blue: 225.0/255.0, alpha: 1.0)
    }
}

// MARK: - MNDataEmptySource
extension MNAssetPickerController: MNDataEmptyDelegate {
    
    func dataEmptyViewButtonTouchUpInside() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            view.showInfoToast("无法跳转设置界面,\n请前往[设置]手动打开")
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            _ = UIApplication.shared.openURL(url)
        }
    }
}

// MARK: - MNTailorViewControllerDelegate
extension MNAssetPickerController: MNTailorViewControllerDelegate {
    
    func tailorControllerDidCancel(_ tailorController: MNTailorViewController) {
        tailorController.navigationController?.popViewController(animated: true)
    }
    
    func tailorController(_ tailorController: MNTailorViewController, didTailorVideoAtPath videoPath: String) {
        guard let asset = MNAsset(content: videoPath, options: options) else {
            try? FileManager.default.removeItem(atPath: videoPath)
            tailorController.view.showMsgToast("视频导出失败")
            return
        }
        finishPicking([asset])
    }
}

// MARK: - MNAssetCellDelegate
extension MNAssetPickerController: MNAssetCellDelegate {
    
    func assetCellShouldPreviewAsset(_ cell: MNAssetCell) {
        guard let asset = cell.asset, let _ = asset.cover else {
            view.showMsgToast("暂无法预览")
            return
        }
        let browser = MNAssetBrowser(assets: [asset])
        browser.events = [.back]
        browser.backgroundColor = .black
        browser.dismissWhenPulled = true
        browser.clearWhenRemoved = true
        browser.present(in: view) { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .willAppear:
                self.statusBarStyle = .lightContent
                self.setNeedsStatusBarAppearanceUpdate()
            case .willDisappear:
                self.statusBarStyle = self.options.mode == .dark ? .lightContent : .default
                self.setNeedsStatusBarAppearanceUpdate()
            default: break
            }
        }
    }
}

// MARK: - MNAssetPickerNavDelegate
extension MNAssetPickerController: MNAssetPickerNavDelegate {
    
    func navBarCloseButtonTouchUpInside() {
        guard let picker = navigationController as? MNAssetPicker else { return }
        options.delegate?.assetPickerDidCancel?(picker)
    }
    
    func navBarAlbumButtonTouchUpInside(_ badge: MNAssetAlbumBadge) {
        badge.isUserInteractionEnabled = false
        let isShow: Bool = badge.isSelected == false
        badge.isSelected = isShow
        let completionHandler: ()->Void = {
            badge.isUserInteractionEnabled = true
        }
        if isShow {
            albumView.show(completion: completionHandler)
        } else {
            albumView.dismiss(completion: completionHandler)
        }
    }
}

// MARK: - MNAssetPickerToolDelegate
extension MNAssetPickerController: MNAssetPickerToolDelegate {
    
    func previewButtonTouchUpInside(_ toolBar: MNAssetPickerToolBar) {
        let previewController = MNAssetPreviewController(assets: selections, options: options)
        previewController.delegate = self
        previewController.events = [.select]
        previewController.cleanWhenExit = true
        navigationController?.pushViewController(previewController, animated: true)
    }
    
    func clearButtonTouchUpInside(_ toolBar: MNAssetPickerToolBar) {
        let alert = UIAlertController(title: nil, message: "确定清空已选内容?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清空", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            for album in self.albumView.albums {
                for asset in album.assets.filter({ $0.isSelected || $0.isEnabled == false }) {
                    asset.index = 0
                    asset.isEnabled = true
                    asset.isSelected = false
                }
            }
            self.selections.removeAll()
            UIView.performWithoutAnimation {
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            }
            if self.albumView.isHidden == false {
                self.albumView.reloadVisibleRows()
            }
            if self.options.maxPickingCount > 1 {
                self.toolBar.updateAssets(self.selections)
            }
        }))
        present(alert, animated: true)
    }
    
    func doneButtonTouchUpInside(_ toolBar: MNAssetPickerToolBar) {
        didPicking(selections)
    }
}

// MARK: - MNAssetAlbumViewDelegate
extension MNAssetPickerController: MNAssetAlbumViewDelegate {
    
    func albumView(_ albumView: MNAssetAlbumView, didSelect album: MNAssetAlbum?) {
        albumView.dismiss()
        navBar.badge.isSelected = false
        guard let album = album else { return }
        MNAssetHelper.fetchAsset(in: album, options: options) { [weak self] in
            guard let self = self else { return }
            self.collectionView.showActivityToast("请稍后")
            self.navBar.badge.isUserInteractionEnabled = false
        } completion: { [weak self] in
            guard let self = self else { return }
            self.collectionView.closeToast()
            self.navBar.badge.isUserInteractionEnabled = true
            self.updateAlbum(album)
        }
    }
}

// MARK: - MNAssetPreviewControllerDelegate
extension MNAssetPickerController: MNAssetPreviewControllerDelegate {
    
    func previewControllerUpdateAsset(_ asset: MNAsset) {
        updateAsset(asset)
    }
}

// MARK: - 屏幕旋转
extension MNAssetPickerController {
    override var shouldAutorotate: Bool { false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
}
