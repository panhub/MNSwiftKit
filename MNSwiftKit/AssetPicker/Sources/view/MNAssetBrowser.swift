//
//  MNAssetBrowser.swift
//  MNKit
//
//  Created by 冯盼 on 2021/10/8.
//  资源浏览器

import UIKit
import CoreAudio
import CoreMedia
#if canImport(MNSwiftKit_Layout)
import MNSwiftKit_Layout
#endif
#if canImport(MNSwiftKit_Definition)
import MNSwiftKit_Definition
#endif

/// 资源浏览代理
@objc public protocol MNAssetBrowseDelegate: NSObjectProtocol {
    /// 资源浏览器浏览告知, 通过`displayIndex`获取当前展示索引
    /// - Parameter browser: 资源浏览器
    @objc optional func assetBrowserDidScroll(_ browser: MNAssetBrowser) -> Void
    /// 资源浏览器状态变化
    /// - Parameters:
    ///   - browser: 资源浏览器
    ///   - state: 状态
    @objc optional func assetBrowser(_ browser: MNAssetBrowser, didChange state: MNAssetBrowser.DisplayState) -> Void
    /// 资源浏览器按钮点击事件
    /// - Parameters:
    ///   - browser: 资源浏览器
    ///   - tag: 按钮标识
    @objc optional func assetBrowser(_ browser: MNAssetBrowser, navigationItemTouchUpInside tag: Int) -> Void
}

/// 资源浏览器标识
public let MNAssetBrowserTag: Int = 1010121

/// 资源浏览器
public class MNAssetBrowser: UIView {
    
    /// 事件类型
    public enum Event: Int {
        
        /// 返回
        case back = -1
        /// 确定
        case done = -2
        /// 保存
        case save = -3
        /// 分享
        case share = -4
        
        /// 资源图片名
        fileprivate var resource: String {
            switch self {
            case .back: return "back"
            case .done: return "done"
            case .save: return "save"
            case .share: return "share"
            }
        }
    }
    
    /// 状态
    @objc public enum DisplayState: Int {
        case willAppear, didAppear, willDisappear, didDisappear
    }
    
    /// 资源集合
    private var assets: [MNAsset] = []
    /// 功能按钮集合
    public var events: [MNAssetBrowser.Event] = []
    /// 是否允许自动播放
    @objc public var isAllowsAutoPlaying: Bool = true
    /// 是否在销毁时删除本地资源文件
    @objc public var clearWhenRemoved: Bool = false
    /// 是否在下拉时退出
    @objc public var dismissWhenPulled: Bool = true
    /// 是否在点击时退出
    @objc public var dismissWhenTouched: Bool = false
    /// 双击时的缩放比例
    @objc public var maximumZoomScale: CGFloat = 3.0
    /// 事件代理
    @objc public weak var delegate: MNAssetBrowseDelegate?
    /// 当前展示的索引
    private(set) var displayIndex: Int = .min
    /// 记录第一次截图
    private var lastBackgroundImage: UIImage?
    /// 记录退出时的目标视图
    private var interactiveToView: UIView!
    /// 记录交互视图的初始位置
    private var interactiveFrame: CGRect = .zero
    /// 记录交互数据
    private var interactiveDelay: CGFloat = 0.0
    /// 记录交互比例
    private var interactiveRatio: CGPoint = .zero
    /// 是否允许缩放退出
    private var isAllowsZoomInteractive: Bool = false
    /// 起始视图
    private var fromView: UIView!
    /// 起始索引
    private var fromIndex: Int = 0
    /// 状态更新回调
    private var stateHandler: ((MNAssetBrowser.DisplayState)->Void)?
    /// 间隔
    private static let interItemSpacing: CGFloat = 14.0
    /// 展示动画时间间隔
    private static let presentAnimationDuration: TimeInterval = 0.28
    /// 退出动画时间间隔
    private static let dismissAnimationDuration: TimeInterval = 0.46
    /// 导航右侧按钮区
    private var navigationItemView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: MN_NAV_BAR_HEIGHT))
    /// 背景颜色图
    private lazy var animationView: UIView = {
        let animationView = UIView(frame: bounds)
        animationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return animationView
    }()
    /// 背景图
    private lazy var backgroundView: UIImageView = {
        let backgroundView = UIImageView(frame: bounds)
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return backgroundView
    }()
    /// 交互视图
    private lazy var interactiveView: UIImageView = {
        let interactiveView = UIImageView(frame: .zero)
        interactiveView.clipsToBounds = true
        interactiveView.contentMode = .scaleAspectFill
        interactiveView.isUserInteractionEnabled = false
        return interactiveView
    }()
    /// 资源集合视图
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = MNAssetBrowser.interItemSpacing
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: MNAssetBrowser.interItemSpacing/2.0, bottom: 0.0, right: MNAssetBrowser.interItemSpacing/2.0)
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.scrollDirection = .horizontal
        layout.itemSize = bounds.size
        let collectionView = UICollectionView(frame: bounds.inset(by: UIEdgeInsets(top: 0.0, left: -MNAssetBrowser.interItemSpacing/2.0, bottom: 0.0, right: -MNAssetBrowser.interItemSpacing/2.0)), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollsToTop = false
        collectionView.allowsSelection = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.delaysContentTouches = false
        collectionView.canCancelContentTouches = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(MNAssetBrowserCell.self, forCellWithReuseIdentifier: "com.mn.asset.browser.cell")
        return collectionView
    }()
    /// 当前展示的表格
    private var currentDisplayCell: MNAssetBrowserCell? {
        collectionView.cellForItem(at: IndexPath(item: displayIndex, section: 0)) as? MNAssetBrowserCell
    }
    /// 顶部导航栏
    private lazy var navigationView: UIImageView = {
        let navigationView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: MN_TOP_BAR_HEIGHT))
        navigationView.alpha = 0.0
        var x: Double = navigationItemView.frame.width
        for event in events {
            let button = UIButton(type: .custom)
            button.tag = event.rawValue
            button.frame = CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0)
            let backgroundImage = PickerResourceLoader.image(named: event.resource)
            if #available(iOS 15.0, *) {
                var configuration = UIButton.Configuration.plain()
                configuration.background.backgroundColor = .clear
                button.configuration = configuration
                button.configurationUpdateHandler = { button in
                    switch button.state {
                    case .normal, .highlighted:
                        button.configuration?.background.image = backgroundImage
                    default: break
                    }
                }
            } else {
                button.adjustsImageWhenHighlighted = false
                button.setBackgroundImage(backgroundImage, for: .normal)
            }
            if event == .back {
                button.mn_layout.minX = 17.0
                button.mn_layout.midY = (navigationView.frame.height - MN_STATUS_BAR_HEIGHT)/2.0 + MN_STATUS_BAR_HEIGHT
                button.addTarget(self, action: #selector(back), for: .touchUpInside)
                navigationView.addSubview(button)
            } else {
                button.mn_layout.minX = x
                button.mn_layout.midY = navigationItemView.frame.height/2.0
                button.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
                navigationItemView.addSubview(button)
                x = button.frame.maxX + 17.0
            }
        }
        navigationItemView.mn_layout.width = x
        navigationItemView.mn_layout.maxX = navigationView.frame.width
        navigationItemView.mn_layout.maxY = navigationView.frame.height
        navigationView.insertSubview(navigationItemView, at: 0)
        if events.isEmpty == false || navigationItemView.subviews.isEmpty == false {
            navigationView.contentMode = .scaleToFill
            navigationView.isUserInteractionEnabled = true
            navigationView.image = PickerResourceLoader.image(named: "top")
        }
        return navigationView
    }()
    
    /// 构造资源浏览器
    /// - Parameter assets: 资源集合
    public init(assets: [MNAsset]) {
        super.init(frame: UIScreen.main.bounds)
        self.assets.append(contentsOf: assets)
        self.tag = MNAssetBrowserTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 构建视图
    private func buildView() {
        addSubview(backgroundView)
        addSubview(animationView)
        addSubview(collectionView)
        addSubview(interactiveView)
        addSubview(navigationView)
    }
    
    /// 设置事件
    private func setupEvent() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        if dismissWhenTouched {
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
            singleTap.numberOfTapsRequired = 1
            singleTap.require(toFail: doubleTap)
            addGestureRecognizer(singleTap)
        }
        if dismissWhenPulled {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
            addGestureRecognizer(pan)
        }
    }
    
    /// 删除时清理缓存
    public override func removeFromSuperview() {
        if clearWhenRemoved {
            for asset in assets.filter({ $0.content != nil }) {
                asset.content = nil
            }
        }
        super.removeFromSuperview()
    }
}

// MARK: - Update
extension MNAssetBrowser {
    
    /// 更新当前索引
    private func updateDisplayIndex() {
        let currentIndex: Int = Int(floor(collectionView.contentOffset.x/collectionView.bounds.width))
        if currentIndex == displayIndex { return }
        displayIndex = currentIndex
        if let cell = currentDisplayCell {
            cell.prepareDisplaying()
        }
        if let delegate = delegate {
            delegate.assetBrowserDidScroll?(self)
        }
    }
    
    /// 更新当前展示的资源
    /// - Parameter asset: 新的资源模型
    public func updateCurrentAsset(_ asset: MNAsset) {
        guard displayIndex >= 0, displayIndex < assets.count else { return }
        guard let cell = currentDisplayCell else { return }
        let model = assets[displayIndex]
        if displayIndex == fromIndex {
            asset.container = model.container
        }
        assets.remove(at: displayIndex)
        assets.insert(asset, at: displayIndex)
        cell.updateAsset(asset)
        cell.prepareDisplaying()
    }
    
    /// 添加视图到导航右视图
    /// - Parameter creator: 创建视图
    public func addCustomViewToNavigation(_ creator: ()->[UIView]) {
        let views = creator()
        for view in views {
            if let control = view as? UIControl, control.allTargets.isEmpty {
                control.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
            }
            view.mn_layout.minX = navigationItemView.frame.width
            view.mn_layout.midY = navigationItemView.frame.height/2.0
            navigationItemView.mn_layout.width = view.frame.maxX + 17.0
            navigationItemView.addSubview(view)
        }
        if let _ = navigationItemView.superview {
            // 已经放置导航右视图 更新位置
            navigationItemView.mn_layout.maxX = navigationView.frame.width
            if navigationView.isUserInteractionEnabled == false {
                // 未开启交互
                navigationView.contentMode = .scaleToFill
                navigationView.isUserInteractionEnabled = true
                navigationView.image = PickerResourceLoader.image(named: "top")
            }
        }
    }
}

// MARK: - 弹出
extension MNAssetBrowser {
    
    /// 展示资源浏览器
    /// - Parameters:
    ///   - superview: 弹出的父视图
    ///   - index: 起始索引
    ///   - animated: 是否动态展示
    ///   - handler: 状态更新回调
    public func present(in superview: UIView? = nil, from index: Int = 0, animated: Bool = true, states handler: ((_ state: MNAssetBrowser.DisplayState)->Void)? = nil) {
        
        guard let superview = superview ?? UIWindow.mn_picker.current else {
#if DEBUG
            print("browser superview is null.")
#endif
            return
        }
        
        // 保证资源模型可用
        guard assets.count > 0, index < assets.count else {
            fatalError("unknown assets.")
        }
        
        let asset = assets[index]
        guard let container = asset.container else {
            fatalError("unknown from asset container.")
        }
        
        var animatedImage: UIImage?
        if let cover = asset.cover {
            animatedImage = cover
        } else if container is UIImageView, let imageView = container as? UIImageView {
            animatedImage = imageView.image
        } else if container is UIButton, let button = container as? UIButton {
            animatedImage = button.currentBackgroundImage
            if animatedImage == nil { animatedImage = button.currentImage }
        } else if let content = asset.content, content is UIImage, let image = content as? UIImage {
            animatedImage = image
        }
        if let images = animatedImage?.images, images.count > 1 { animatedImage = images.first }
        
        guard let animatedImage = animatedImage else {
#if DEBUG
            print("unknown from asset thumbnail.")
#endif
            return
        }
        
        // 通知即将开始
        handler?(.willAppear)
        delegate?.assetBrowser?(self, didChange: .willAppear)
        
        let isUserInteractionEnabled = superview.isUserInteractionEnabled
        superview.isUserInteractionEnabled = false
        center = CGPoint(x: superview.bounds.midX, y: superview.bounds.midY)
        
        let backgroundColor = self.backgroundColor
        self.backgroundColor = nil
        
        let fromView = container
        self.fromIndex = index
        self.fromView = fromView
        self.stateHandler = handler
        
        fromView.isHidden = true
        backgroundView.image = superview.layer.mn_picker.snapshot
        fromView.isHidden = false
        
        buildView()
        setupEvent()
        superview.addSubview(self)
        
        collectionView.isHidden = true
        UIView.performWithoutAnimation {
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        }
        animationView.alpha = 0.0
        animationView.backgroundColor = backgroundColor ?? .black
        
        let targetSize = animatedImage.size.mn_picker.scaleFit(toSize: CGSize(width: frame.width, height: frame.height - 1.0))
        let toRect = CGRect(x: (self.bounds.width - targetSize.width)/2.0, y: (bounds.height - targetSize.height)/2.0, width: targetSize.width, height: targetSize.height)
        
        interactiveView.image = animatedImage
        interactiveView.frame = fromView.superview!.convert(fromView.frame, to: self)
        interactiveView.layer.cornerRadius = fromView.layer.cornerRadius
        interactiveView.contentMode = fromView.contentMode
        
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(true)
        let animationDuration: TimeInterval = animated ? MNAssetBrowser.presentAnimationDuration : 0.0
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
            guard let self = self else { return }
            self.animationView.alpha = 1.0
            self.navigationView.alpha = 1.0
            self.interactiveView.frame = toRect
            self.interactiveView.layer.setValue(0.0, forKey: #keyPath(CALayer.cornerRadius))
        } completion: { [weak self, weak superview] _ in
            guard let self = self else { return }
            UIView.setAnimationsEnabled(animationsEnabled)
            self.collectionView.isHidden = false
            self.interactiveView.isHidden = true
            superview?.isUserInteractionEnabled = isUserInteractionEnabled
            handler?(.didAppear)
            self.delegate?.assetBrowser?(self, didChange: .didAppear)
            self.updateDisplayIndex()
        }
    }
    
    /// 浏览某个资源内容
    /// - Parameters:
    ///   - container: 资源容器
    ///   - superview: 父视图
    ///   - image: 过渡动画图片
    ///   - animated: 是否动态展示
    ///   - handler: 状态更新提醒
    public class func present(container: UIView, in superview: UIView? = nil, using image: UIImage? = nil, animated: Bool = true, states handler: ((_ state: MNAssetBrowser.DisplayState)->Void)? = nil) {
        var animatedImage: UIImage? = image
        if animatedImage == nil {
            if container is UIImageView {
                let imageView = container as! UIImageView
                animatedImage = imageView.image
            } else if container is UIButton {
                let button = container as! UIButton
                animatedImage = button.currentBackgroundImage ?? button.currentImage
            }
        }
        if let images = animatedImage?.images, images.count > 1 {
            animatedImage = images.first
        }
        guard let animatedImage = animatedImage else {
#if DEBUG
            print("unknown present from image.")
#endif
            //fatalError("unknown animated image.")
            return
        }
        guard let asset = MNAsset(content: animatedImage) else {
#if DEBUG
            print("unknown asset.")
#endif
            //fatalError("unknown asset.")
            return
        }
        asset.container = container
        let browser = MNAssetBrowser(assets: [asset])
        browser.backgroundColor = .black
        browser.present(in: superview, animated: animated, states: handler)
    }
}

// MARK: - 消失
extension MNAssetBrowser {
    
    /// 结束浏览
    /// - Parameters:
    ///   - animated: 是否动态
    ///   - handler: 状态更新回调
    public func dismiss(animated: Bool = true, states handler: ((_ state: MNAssetBrowser.DisplayState)->Void)? = nil) {
        
        guard let superview = superview else { return }
        let isUserInteractionEnabled = superview.isUserInteractionEnabled
        superview.isUserInteractionEnabled = false
        
        let asset = assets[displayIndex]
        var toView: UIView! = displayIndex == fromIndex ? fromView : asset.container
        if let view = toView, view != fromView {
            let rect = convert(view.frame, from: view.superview!)
            if bounds.intersects(rect) == false { toView = fromView }
        }
        if toView == nil { toView = fromView }
        if toView! != fromView {
            // 重新截屏
            isHidden = true
            toView!.isHidden = true
            backgroundView.image = superview.layer.mn_picker.snapshot
            isHidden = false
            toView!.isHidden = false
        }
        
        let cell = currentDisplayCell
        cell?.pauseDisplaying()
        
        handler?(.willDisappear)
        delegate?.assetBrowser?(self, didChange: .willDisappear)
        
        var animatedImage: UIImage?
        if let cover = asset.cover {
            animatedImage = cover
        } else if toView is UIImageView, let imageView = toView as? UIImageView {
            animatedImage = imageView.image
        } else if toView is UIButton, let button = toView as? UIButton {
            animatedImage = button.currentBackgroundImage
            if animatedImage == nil { animatedImage = button.currentImage }
        } else if let cell = cell {
            animatedImage = cell.currentImage
        }
        if let images = animatedImage?.images, images.count > 1 { animatedImage = images.first }
        
        collectionView.isHidden = true
        interactiveView.isHidden = false
        interactiveView.image = animatedImage
        interactiveView.contentMode = toView.contentMode
        interactiveView.frame = convert(cell!.scrollView.contentView.frame, from: cell!.scrollView)
        
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(true)
        let cornerRadius = toView?.layer.cornerRadius ?? 0.0
        let toRect = convert(toView!.frame, from: toView!.superview!)
        let animationDuration: TimeInterval = animated ? MNAssetBrowser.dismissAnimationDuration : 0.0
        UIView.animate(withDuration: animationDuration) { [weak self] in
            guard let self = self else { return }
            self.animationView.alpha = 0.0
            UIView.setAnimationsEnabled(animationsEnabled)
        }
        UIView.animate(withDuration: animationDuration/2.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
            guard let self = self else { return }
            self.interactiveView.frame = toRect
            self.interactiveView.layer.setValue(0.99, forKeyPath: "transform.scale")
            self.interactiveView.layer.setValue(cornerRadius, forKey: #keyPath(CALayer.cornerRadius))
        } completion: { [weak self, weak superview] _ in
            UIView.animate(withDuration: animationDuration/2.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) {
                guard let self = self else { return }
                self.alpha = 0.0
                self.interactiveView.layer.setValue(1.0, forKeyPath: "transform.scale")
            } completion: { _ in
                guard let self = self else { return }
                self.removeFromSuperview()
                superview?.isUserInteractionEnabled = isUserInteractionEnabled
                handler?(.didDisappear)
                self.delegate?.assetBrowser?(self, didChange: .didDisappear)
            }
        }
    }
    
    private func dismissFromCurrent() {
        
        stateHandler?(.willDisappear)
        delegate?.assetBrowser?(self, didChange: .willDisappear)
        
        let superview = superview!
        let isUserInteractionEnabled = superview.isUserInteractionEnabled
        superview.isUserInteractionEnabled = false
        
        var toRect = interactiveView.frame
        var cornerRadius = interactiveView.layer.cornerRadius
        var contentMode = interactiveView.contentMode
        if isAllowsZoomInteractive, let interactiveToView = interactiveToView {
            contentMode = interactiveToView.contentMode
            cornerRadius = interactiveToView.layer.cornerRadius
            toRect = convert(interactiveToView.frame, from: interactiveToView.superview!)
        } else {
            toRect.origin.y = interactiveView.frame.minY < 0.0 ? -toRect.height : bounds.height
        }
        interactiveView.contentMode = contentMode
        
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(true)
        UIView.animate(withDuration: MNAssetBrowser.dismissAnimationDuration) { [weak self] in
            guard let self = self else { return }
            self.animationView.alpha = 0.0
            UIView.setAnimationsEnabled(animationsEnabled)
        }
        UIView.animate(withDuration: MNAssetBrowser.dismissAnimationDuration/2.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
            guard let self = self else { return }
            self.interactiveView.frame = toRect
            self.interactiveView.layer.setValue(cornerRadius, forKey: #keyPath(CALayer.cornerRadius))
        } completion: { [weak self, weak superview] _ in
            UIView.animate(withDuration: MNAssetBrowser.dismissAnimationDuration/2.0) {
                guard let self = self else { return }
                self.alpha = 0.0
            } completion: { _ in
                guard let self = self else { return }
                self.removeFromSuperview()
                superview?.isUserInteractionEnabled = isUserInteractionEnabled
                self.stateHandler?(.didDisappear)
                self.delegate?.assetBrowser?(self, didChange: .didDisappear)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MNAssetBrowser: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.mn.asset.browser.cell", for: indexPath)
        if let cell = cell as? MNAssetBrowserCell {
            cell.isAllowsAutoPlaying = isAllowsAutoPlaying
            cell.maximumZoomScale = maximumZoomScale
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetBrowserCell else { return }
        guard indexPath.item < assets.count else { return }
        let asset = assets[indexPath.item]
        cell.updateAsset(asset)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetBrowserCell else { return }
        cell.endDisplaying()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false, scrollView.isDragging == false, scrollView.isDecelerating == false else { return }
        updateDisplayIndex()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateDisplayIndex()
    }
}

// MARK: - Event
extension MNAssetBrowser {
    
    /// 返回事件
    /// - Parameter sender: 返回按钮
    @objc private func back() {
        if let cell = currentDisplayCell, cell.scrollView.zoomScale > 1.0 {
            cell.scrollView.setZoomScale(1.0, animated: true)
        } else {
            dismiss(states: stateHandler)
        }
    }
    
    /// 按钮点击事件
    /// - Parameter sender: 按钮
    @objc private func buttonTouchUpInside(_ sender: UIControl) {
        guard let delegate = delegate else { return }
        delegate.assetBrowser?(self, navigationItemTouchUpInside: sender.tag)
    }
}

// MARK: - 交互
extension MNAssetBrowser: UIGestureRecognizerDelegate {
    
    @objc private func tap(_ recognizer: UITapGestureRecognizer) {
        guard let cell = currentDisplayCell, cell.scrollView.zoomScale == 1.0 else { return }
        let location = recognizer.location(in: cell.scrollView.contentView)
        guard cell.scrollView.contentView.bounds.contains(location) else { return }
        dismiss(states: stateHandler)
    }
    
    @objc private func tapped(_ recognizer: UITapGestureRecognizer) {
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
    
    @objc private func pan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            guard let cell = currentDisplayCell, cell.scrollView.zoomScale <= 1.0 else { return }
            let location = recognizer.location(in: cell.scrollView.contentView)
            guard cell.scrollView.contentView.bounds.contains(location) else { return }
            
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self = self else { return }
                self.navigationView.alpha = 0.0
            }
            
            cell.pauseDisplaying()
            
            let asset = assets[displayIndex]
            var interactiveToView: UIView? = displayIndex == fromIndex ? fromView : asset.container
            if let view = interactiveToView, view != fromView {
                let rect = convert(view.frame, from: view.superview!)
                if bounds.intersects(rect) == false { interactiveToView = fromView }
            }
            if interactiveToView == nil { interactiveToView = fromView }
            if interactiveToView! != fromView {
                // 重新截屏
                isHidden = true
                interactiveToView!.isHidden = true
                lastBackgroundImage = backgroundView.image
                if let superview = superview {
                    backgroundView.image = superview.layer.mn_picker.snapshot
                }
                isHidden = false
                interactiveToView!.isHidden = false
            }
            self.interactiveToView = interactiveToView
            
            collectionView.isHidden = true
            interactiveView.isHidden = false
            interactiveView.image = cell.currentImage
            interactiveView.frame = convert(cell.scrollView.contentView.frame, from: cell.scrollView)
            interactiveFrame = interactiveView.frame
            
            var toSize = interactiveToView!.bounds.size
            if toSize.width > bounds.size.width || toSize.height > bounds.size.height { toSize = toSize.mn_picker.scaleFit(toSize: CGSize(width: bounds.width, height: bounds.height - 1.0)) }
            interactiveDelay = (bounds.height - toSize.height)/2.0
            interactiveRatio = CGPoint(x: toSize.width/interactiveFrame.width, y: toSize.height/interactiveFrame.height)
            isAllowsZoomInteractive = max(bounds.width, bounds.height) - max(interactiveView.bounds.width, interactiveView.bounds.height) >= 50.0

        case .changed:
            
            guard interactiveView.isHidden == false else { return }
            
            let ratio = abs(bounds.height/2.0 - interactiveView.frame.midY)/interactiveDelay
            
            let translation = recognizer.translation(in: self)
            recognizer.setTranslation(.zero, in: self)
            
            var center = interactiveView.center
            center.y += translation.y
            
            if isAllowsZoomInteractive {
                center.x += translation.x
                var rect = interactiveFrame
                rect.size.width = (1.0 - (1.0 - self.interactiveRatio.x)*ratio)*rect.width
                rect.size.height = (1.0 - (1.0 - self.interactiveRatio.y)*ratio)*rect.height
                rect.origin.x = center.x - rect.width/2.0
                rect.origin.y = center.y - rect.height/2.0
                rect.origin.x = min(max(0.0, rect.minX), bounds.width - rect.width)
                rect.origin.y = min(max(0.0, rect.minY), bounds.height - rect.height)
                interactiveView.frame = rect
            } else {
                interactiveView.center = center
                var rect = interactiveView.frame
                rect.origin.y = min(bounds.height, max(-rect.height, rect.minY))
                interactiveView.frame = rect
            }
            
            animationView.alpha = 1.0 - ratio*0.8
            
        case .ended:
            
            guard interactiveView.isHidden == false else { return }
            
            if interactiveView.frame.midY >= (bounds.midY + 50.0) {
                dismissFromCurrent()
            } else {
                endPanFromCurrent()
            }
        case .cancelled:
            guard interactiveView.isHidden == false else { return }
            endPanFromCurrent()
        default:
            break
        }
    }
    
    private func endPanFromCurrent() {
        UIView.animate(withDuration: MNAssetBrowser.dismissAnimationDuration/2.0, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
            guard let self = self else { return }
            self.animationView.alpha = 1.0
            self.navigationView.alpha = 1.0
            self.interactiveView.frame = self.interactiveFrame
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.isHidden = false
            self.interactiveView.isHidden = true
            if let image = self.lastBackgroundImage {
                self.backgroundView.image = image
                self.lastBackgroundImage = nil
            }
        }
    }
}
