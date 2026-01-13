//
//  MNAssetPickerController.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/9/27.
//  资源挑选控制器

import UIKit
import Photos

class MNAssetPickerController: UIViewController {
    /// 配置信息
    private let options: MNAssetPickerOptions
    /// 是否进入相册
    private var isEnteredLibrary = false
    /// 当前资源集合
    private var assets: [MNAsset] = []
    /// 选中的资源集合
    private var selections: [MNAsset] = []
    /// 上一次交互索引
    private var lastTouchIndex: Int = .min
    /// 是否需要隐藏状态栏
    private var statusBarHidden: Bool = false
    /// 顶部栏
    private lazy var navBar = MNAssetPickerNavBar(options: options)
    /// 相册视图
    private lazy var albumView = MNAssetAlbumView(options: options)
    /// 底部工具栏
    private lazy var toolBar = MNAssetPickerToolBar(options: options)
    /// 状态栏修改
    private lazy var statusBarStyle: UIStatusBarStyle = options.mode == .dark ? .lightContent : .default
    /// 资源展示
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
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
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
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
        collectionView.mn.emptySource = self
        collectionView.mn.emptyDelegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = options.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(MNAssetCell.self, forCellWithReuseIdentifier: NSStringFromClass(MNAssetCell.self))
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        navBar.delegate = self
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navBar.heightAnchor.constraint(equalToConstant: options.contentInset.top)
        ])
        
        albumView.delegate = self
        albumView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(albumView)
        NSLayoutConstraint.activate([
            albumView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            albumView.leftAnchor.constraint(equalTo: view.leftAnchor),
            albumView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -options.contentInset.bottom),
            albumView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        toolBar.delegate = self
        toolBar.isHidden = options.maxPickingCount <= 1
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)
        NSLayoutConstraint.activate([
            toolBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            toolBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: options.bottomBarHeight)
        ])
        
        // 分页支持
        if options.sortAscending {
            // 升序则上拉加载更多
            let footer = MNAssetPickerFooter(target: self, action: #selector(loadMore))
            footer.color = options.mode == .light ? .black : .gray
            footer.offset = UIOffset(horizontal: 0.0, vertical: -options.contentInset.bottom)
            collectionView.mn.footer = footer
        } else {
            // 降序则下滑加载更多
            let header = MNRefreshStateHeader(target: self, action: #selector(loadMore))
            header.color = options.mode == .light ? .black : .gray
            header.offset = UIOffset(horizontal: 0.0, vertical: options.contentInset.top)
            collectionView.mn.header = header
        }
        
        if options.maxPickingCount > 1, options.allowsSlidePicking {
            // 滑动选择
            // collectionView.bounces = false
            let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(recognizer:)))
            pan.maximumNumberOfTouches = 1
            view.addGestureRecognizer(pan)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        // 请求相册
        if mn.isFirstTime {
            apply()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        statusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }
}

// MARK: - Completed
extension MNAssetPickerController {
    
    /// 导出资源并结束选择
    /// - Parameter assets: 需要导出内容的资源模型集合
    private func didPicking(_ assets: [MNAsset]) {
        MNToast.showActivity("正在导出")
        MNAssetHelper.exportAsynchronously(for: assets, options: options) { index, count in
            MNToast.showActivity("正在导出\(index)/\(count)")
        } completion: { [weak self] result in
            MNToast.close { _ in
                guard let self = self else { return }
                if result.count == assets.count {
                    self.finishPicking(result)
                } else if (result.isEmpty || result.count < self.options.minPickingCount) {
                    // 低于最小数量
                    let alert = UIAlertController(title: "提示", message: "iCloud资源下载失败", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                    alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.didPicking(assets)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // 有失败的
                    let alert = UIAlertController(title: "提示", message: "\(assets.count - result.count)项资源导出失败", preferredStyle: .alert)
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
        guard let delegate = picker.delegate as? MNAssetPickerDelegate else { return }
        delegate.assetPicker(picker, didFinishPicking: assets)
    }
}

// MARK: - Fetch
extension MNAssetPickerController {
    
    /// 请求权限
    private func apply() {
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
                    self.isEnteredLibrary = true
                    self.collectionView.reloadData()
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
        collectionView.mn.showActivityToast(nil)
        MNAssetHelper.fetchAlbum(using: options) { [weak self] albums in
            guard let self = self else { return }
            self.isEnteredLibrary = true
            if let album = albums.first {
                album.isSelected = true
                album.isFirstAppear = true
                self.albumView.update(albums: albums)
                self.navBar.badge.isEnabled = albums.count > 1
                self.navBar.badge.updateTitle(album.name, animated: albums.count > 1)
                self.fetchAssets(in: album)
            } else {
                // 确保显示占位图
                self.collectionView.reloadData()
                self.collectionView.mn.closeToast()
            }
        }
    }
    
    /// 加载相册内资源
    /// - Parameter album: 相册模型
    private func fetchAssets(in album: MNAssetAlbum) {
        let completionHandler: ()->Void = { [weak self] in
            guard let self = self else { return }
            if album.assets.isEmpty == false {
                album.assets.filter { $0.isEnabled == false }.forEach { $0.isEnabled = true }
                self.reload(assets: album.assets)
            }
            self.assets.removeAll()
            self.assets.append(contentsOf: album.assets)
            UIView.performWithoutAnimation {
                self.collectionView.reloadData()
            }
            if album.assets.isEmpty == false, album.isFirstAppear, self.options.sortAscending == false {
                // 降序则从底部开始显示
                let indexPath = IndexPath(item: album.assets.count - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
            album.isFirstAppear = false
            let hasMore: Bool = album.offset < album.count
            if let component = self.collectionView.mn.header ?? self.collectionView.mn.footer {
                if hasMore {
                    component.endRefreshing()
                } else {
                    component.endRefreshingAndNoMoreData()
                }
            }
            self.navBar.badge.isUserInteractionEnabled = true
            self.collectionView.mn.closeToast()
        }
        if album.assets.isEmpty == false, collectionView.mn.isLoading == false {
            completionHandler()
        } else {
            if collectionView.mn.isLoading == false {
                collectionView.mn.showActivityToast(nil)
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
            collectionView.mn.endRefreshing()
            collectionView.mn.endLoadMore()
            return
        }
        fetchAssets(in: album)
    }
}

// MARK: - Update
extension MNAssetPickerController {
    
    /// 更新资源
    /// - Parameter asset: 资源模型
    private func update(asset: MNAsset) {
        if asset.isSelected {
            asset.index = 0
            asset.isSelected = false
            selections.removeAll { $0 == asset }
        } else {
            asset.isSelected = true
            selections.append(asset)
        }
        // 更新索引
        for (index, asset) in selections.enumerated() {
            asset.index = index + 1
        }
        reload(assets: assets)
        toolBar.update(assets: selections)
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }
    
    /// 更新资源状态
    /// - Parameter assets: 需要更新状态的资源模型集合
    private func reload(assets: [MNAsset]) {
        // 判断是否超过限制
        if selections.count >= options.maxPickingCount {
            // 标记不能再选择
            assets.filter { $0.isSelected == false && $0.isEnabled }.forEach { $0.isEnabled = false }
        } else {
            // 结束限制
            assets.forEach { $0.isEnabled = true }
            // 类型限制
            if let first = selections.first {
                let type = first.type
                if options.allowsMixedPicking == false {
                    assets.filter { $0.type != type }.forEach { $0.isEnabled = false }
                }
                switch type {
                case .photo:
                    if options.allowsMultiplePickingPhoto == false {
                        assets.filter { $0.isSelected == false && $0.type == .photo }.forEach { $0.isEnabled = false }
                    }
                case .gif:
                    if options.allowsMultiplePickingGif == false {
                        assets.filter { $0.isSelected == false && $0.type == .gif }.forEach { $0.isEnabled = false }
                    }
                case .livePhoto:
                    if options.allowsMultiplePickingLivePhoto == false {
                        assets.filter { $0.isSelected == false && $0.type == .livePhoto }.forEach { $0.isEnabled = false }
                    }
                case .video:
                    if options.allowsMultiplePickingVideo == false {
                        assets.filter { $0.isSelected == false && $0.type == .video }.forEach { $0.isEnabled = false }
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
    @objc private func pan(recognizer: UIPanGestureRecognizer) {
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
            update(asset: asset)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < assets.count else { return }
        let asset = assets[indexPath.item]
        guard asset.isEnabled else { return }
        if options.maxPickingCount <= 1 {
            if asset.type == .video, options.maxExportDuration > 0.0, asset.duration > options.maxExportDuration {
                // 视频裁剪后导出
                tailorVideo(asset)
            } else {
                // 导出资源
                didPicking([asset])
            }
        } else {
            // 更新选择状态
            update(asset: asset)
        }
    }
    
    /// 裁剪视频
    /// - Parameter asset: 视频资源模型
    private func tailorVideo(_ asset: MNAsset) {
        view.mn.showActivityToast(nil)
        MNAssetHelper.fetchContents(for: asset, progress: nil) { [weak self] asset in
            guard let self = self else { return }
            if let videoPath = asset.contents as? String {
                asset.contents = nil
                self.view.mn.closeToast { [weak self] _ in
                    guard let self = self else { return }
                    let vc = MNTailorViewController(videoPath: videoPath)
                    vc.delegate = self
                    vc.outputPath = self.options.videoExportURL?.mn.path
                    vc.minTailorDuration = self.options.minExportDuration
                    vc.maxTailorDuration = self.options.maxExportDuration
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.view.mn.showMsgToast("导出视频失败")
            }
        }
    }
}

// MARK: - MNAssetCellEventHandler
extension MNAssetPickerController: MNAssetCellEventHandler {
    
    func assetCellShouldPreview(_ cell: MNAssetCell) {
        guard let asset = cell.asset, let _ = asset.cover else {
            MNToast.showMsg("暂无法预览")
            return
        }
        let browser = MNAssetBrowser(assets: [asset])
        browser.delegate = self
        browser.dragToDismiss = true
        browser.leftBarItemEvent = .back
        browser.backgroundColor = .black
        browser.shouldClearWhenDismiss = true
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

// MARK: - MNAssetBrowseDelegate
extension MNAssetPickerController: MNAssetBrowseDelegate {
    
    func assetBrowser(_ browser: MNAssetBrowser, fetchCover asset: any MNAssetBrowseSupported, completion completionHandler: @escaping MNAssetBrowserCell.CoverUpdateHandler) {
        
        MNAssetHelper.fetchCover(for: asset as! MNAsset, completion: completionHandler)
    }
    
    func assetBrowser(_ browser: MNAssetBrowser, fetchContents asset: any MNAssetBrowseSupported, progress progressHandler: @escaping MNAssetBrowserCell.ProgressUpdateHandler, completion completionHandler: @escaping MNAssetBrowserCell.ContentsUpdateHandler) {
        
        MNAssetHelper.fetchContents(for: asset as! MNAsset, progress: progressHandler, completion: completionHandler)
    }
}

// MARK: - MNDataEmptySource
extension MNAssetPickerController: MNDataEmptySource {
    
    func dataEmptyViewShouldDisplay(_ superview: UIView) -> Bool {
        isEnteredLibrary && assets.isEmpty
    }
    
    func imageForDataEmptyView(_ superview: UIView) -> UIImage? {
        AssetPickerResource.image(named: "picker_empty")
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
        return NSAttributedString(string: text, attributes: [.font:UIFont.systemFont(ofSize: 16.0, weight: .regular), .foregroundColor:UIColor(red: 103.0/255.0, green: 105.0/255.0, blue: 107.0/255.0, alpha: 1.0)])
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
            MNToast.showMsg("无法跳转设置界面\n请前往[设置]手动打开")
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
    
    func tailorController(_ tailorController: MNTailorViewController, didOutputVideoAtPath videoPath: String) {
        guard let asset = MNAsset(contents: videoPath, options: options) else {
            try? FileManager.default.removeItem(atPath: videoPath)
            MNToast.showMsg("视频导出失败")
            return
        }
        finishPicking([asset])
    }
}

// MARK: - MNAssetPickerNavDelegate
extension MNAssetPickerController: MNAssetPickerNavDelegate {
    
    func navBarCloseButtonTouchUpInside() {
        guard let picker = navigationController as? MNAssetPicker else { return }
        guard let delegate = picker.delegate as? MNAssetPickerDelegate else { return }
        delegate.assetPickerDidCancel?(picker)
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
        previewController.shouldClearWhenPop = true
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
                self.toolBar.update(assets: self.selections)
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
        navBar.badge.updateTitle(album.name, animated: navBar.badge.isEnabled)
        album.isFirstAppear = true
        fetchAssets(in: album)
    }
}

// MARK: - MNAssetPreviewControllerDelegate
extension MNAssetPickerController: MNAssetPreviewControllerDelegate {
    
    func previewControllerUpdateAsset(_ asset: MNAsset) {
        update(asset: asset)
    }
}

// MARK: - 屏幕旋转
extension MNAssetPickerController {
    override var shouldAutorotate: Bool { false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
}
