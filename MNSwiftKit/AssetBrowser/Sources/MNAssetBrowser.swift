//
//  MNAssetBrowser.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/8.
//  资源浏览器

import UIKit
import CoreAudio
import CoreMedia


/// 资源浏览代理
@objc public protocol MNAssetBrowseDelegate: AnyObject {
    
    /// 资源浏览器浏览告知
    /// - Parameters:
    ///   - browser: 资源浏览器
    ///   - index: 索引
    @objc optional func assetBrowser(_ browser: MNAssetBrowser, didScrollToItemAt index: Int)
    
    /// 资源浏览器状态变化
    /// - Parameters:
    ///   - browser: 资源浏览器
    ///   - state: 状态
    @objc optional func assetBrowser(_ browser: MNAssetBrowser, didChange state: MNAssetBrowser.State)
    
    /// 资源浏览器按钮点击事件
    /// - Parameters:
    ///   - browser: 资源浏览器
    ///   - tag: 按钮标识
    @objc optional func assetBrowser(_ browser: MNAssetBrowser, navigationItemTouchUpInside event: MNAssetBrowser.Event)
    
    /// 资源浏览器获取封面
    /// - Parameters:
    ///   - browser: 资源浏览器
    ///   - asset: 资源模型
    ///   - completionHandler: 结束回调
    @objc optional func assetBrowser(_ browser: MNAssetBrowser, fetchCover asset: any MNAssetBrowseSupported, completion completionHandler: @escaping MNAssetBrowserCell.CoverUpdateHandler)
    
    /// 资源浏览器获取内容
    /// - Parameters:
    ///   - browser: 资源浏览器
    ///   - asset: 资源模型
    ///   - progressHandler: 进度回调
    ///   - completionHandler: 结束回调
    @objc optional func assetBrowser(_ browser: MNAssetBrowser, fetchContents asset: any MNAssetBrowseSupported, progress progressHandler: @escaping MNAssetBrowserCell.ProgressUpdateHandler, completion completionHandler: @escaping MNAssetBrowserCell.ContentsUpdateHandler)
}

/// 资源类型
@objc public enum MNAssetType: Int {
    /// 静态图
    case photo
    /// 动图
    case gif
    /// LivePhoto
    case livePhoto
    /// 视频
    case video
}

/// 资源浏览支持
@objc public protocol MNAssetBrowseSupported: AnyObject {
    
    /// 唯一标识
    var identifier: String { get }
    
    /// 内容
    var contents: Any? { set get }
    
    /// 资源类型
    var type: MNAssetType { get }
    
    /// 封面
    var cover: UIImage? { get }
    
    /// 外部引用容器
    var container: UIView? { set get }
    
    /// 加载进度
    var progress: Double { get }
}

/// 资源浏览器
public class MNAssetBrowser: UIView {
    
    /// 事件类型
    @objc(MNAssetBrowserEvent)
    public enum Event: Int {
        /// 返回
        case back = -1
        /// 确定
        case done = -2
        /// 保存
        case save = -3
        /// 分享
        case share = -4
        /// 没有
        case none = 0
        
        /// 资源图片名
        fileprivate var img: String {
            switch self {
            case .none: return ""
            case .back: return "browser_back"
            case .done: return "browser_done"
            case .save: return "browser_save"
            case .share: return "browser_share"
            }
        }
    }
    
    /// 状态
    @objc(MNAssetBrowserState)
    public enum State: Int {
        case willAppear, didAppear, willDisappear, didDisappear
    }
    
    /// 资源浏览项
    @objc(MNAssetBrowserItem)
    public class Item: NSObject, MNAssetBrowseSupported {
        
        @objc public var identifier: String = "\(Date().timeIntervalSince1970)"

        @objc public var contents: Any?
        
        @objc public var type: MNAssetType = .photo
        
        @objc public var cover: UIImage?
        
        @objc public weak var container: UIView?
        
        @objc public var progress: Double = 0.0
    }
    
    /// 资源集合
    private var assets: [MNAssetBrowseSupported] = []
    /// 左按钮事件
    @objc public var leftBarItemEvent: MNAssetBrowser.Event = .none
    /// 右按钮事件
    @objc public var rightBarItemEvent: MNAssetBrowser.Event = .none
    /// 是否允许自动播放
    @objc public var autoPlay: Bool = true
    /// 是否在点击时退出
    @objc public var tapToDismiss: Bool = false
    /// 是否在下拉时退出
    @objc public var dragToDismiss: Bool = true
    /// 是否在销毁时删除本地资源文件
    @objc public var shouldClearWhenDismiss: Bool = false
    /// 间隔
    @objc public var interItemSpacing: CGFloat = 14.0
    /// 双击时的缩放比例
    @objc public var maximumZoomScale: CGFloat = 3.0
    /// 动画时长
    @objc public var animationDuration: TimeInterval = 0.28
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
    private var isAllowZoomDismiss: Bool = false
    /// 拖拽开始时记录是否应该结束时继续播放
    private var resumeWhenEndDragging = false
    /// 起始视图
    private var fromView: UIView!
    /// 起始索引
    private var fromIndex: Int = 0
    /// 背景颜色图
    private lazy var animationView = UIView()
    /// 顶部导航栏
    private lazy var navigationView = UIImageView()
    /// 交互视图
    private lazy var interactiveView = UIImageView()
    /// 背景图
    private lazy var backgroundView = UIImageView()
    /// 资源集合视图
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    
    /// 构造资源浏览器
    /// - Parameter assets: 资源集合
    public init(assets: [MNAssetBrowseSupported]) {
        super.init(frame: .zero)
        self.assets.append(contentsOf: assets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if shouldClearWhenDismiss {
            assets.forEach { $0.contents = nil }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 构建视图
    private func createSubview() {
        // 背景
        backgroundView.contentMode = .scaleToFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        // 转场动画
        animationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.leftAnchor.constraint(equalTo: leftAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor),
            animationView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        // 资源浏览
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = frame.size
        layout.scrollDirection = .horizontal
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = interItemSpacing
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: interItemSpacing/2.0, bottom: 0.0, right: interItemSpacing/2.0)
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
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(MNAssetBrowserCell.self, forCellWithReuseIdentifier: "MNAssetBrowserCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor, constant: -interItemSpacing/2.0),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor, constant: interItemSpacing/2.0)
        ])
        
        // 交互转场
        interactiveView.clipsToBounds = true
        interactiveView.contentMode = .scaleAspectFill
        interactiveView.isUserInteractionEnabled = false
        addSubview(interactiveView)
        
        // 导航栏 适配资源选择器
        var statusBarHeight = 0.0
        var navigationViewHeight = 55.0
        if let superview = superview, let window = UIWindow.mn.current, superview.bounds == window.bounds {
            // 全屏展示
            statusBarHeight = MN_STATUS_BAR_HEIGHT
            navigationViewHeight = MN_NAV_BAR_HEIGHT
        }
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationView)
        NSLayoutConstraint.activate([
            navigationView.topAnchor.constraint(equalTo: topAnchor),
            navigationView.leftAnchor.constraint(equalTo: leftAnchor),
            navigationView.rightAnchor.constraint(equalTo: rightAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: statusBarHeight + navigationViewHeight)
        ])
        
        // 导航左按钮
        let leftBarItemImg = leftBarItemEvent.img
        if leftBarItemImg.isEmpty == false {
            let leftBarItemImage = AssetBrowserResource.image(named: leftBarItemImg)
            let button = UIButton(type: .custom)
            button.tag = leftBarItemEvent.rawValue
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(self.navigationBarItemTouchUpInside(_:)), for: .touchUpInside)
            if #available(iOS 15.0, *) {
                var configuration = UIButton.Configuration.plain()
                configuration.background.backgroundColor = .clear
                button.configuration = configuration
                button.configurationUpdateHandler = { button in
                    switch button.state {
                    case .normal, .highlighted:
                        button.configuration?.background.image = leftBarItemImage
                    default: break
                    }
                }
            } else {
                button.adjustsImageWhenHighlighted = false
                button.setBackgroundImage(leftBarItemImage, for: .normal)
            }
            navigationView.addSubview(button)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 24.0),
                button.heightAnchor.constraint(equalToConstant: 24.0),
                button.leftAnchor.constraint(equalTo: navigationView.leftAnchor, constant: 16.0),
                button.topAnchor.constraint(equalTo: navigationView.topAnchor, constant: statusBarHeight + (navigationViewHeight - 24.0)/2.0)
            ])
        }
        
        // 导航右按钮
        let rightBarItemImg = rightBarItemEvent.img
        if rightBarItemImg.isEmpty == false {
            let rightBarItemImage = AssetBrowserResource.image(named: rightBarItemImg)
            let button = UIButton(type: .custom)
            button.tag = rightBarItemEvent.rawValue
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(navigationBarItemTouchUpInside(_:)), for: .touchUpInside)
            if #available(iOS 15.0, *) {
                var configuration = UIButton.Configuration.plain()
                configuration.background.backgroundColor = .clear
                button.configuration = configuration
                button.configurationUpdateHandler = { button in
                    switch button.state {
                    case .normal, .highlighted:
                        button.configuration?.background.image = rightBarItemImage
                    default: break
                    }
                }
            } else {
                button.adjustsImageWhenHighlighted = false
                button.setBackgroundImage(rightBarItemImage, for: .normal)
            }
            navigationView.addSubview(button)
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 24.0),
                button.heightAnchor.constraint(equalToConstant: 24.0),
                button.rightAnchor.constraint(equalTo: navigationView.rightAnchor, constant: -16.0),
                button.topAnchor.constraint(equalTo: navigationView.topAnchor, constant:  statusBarHeight + (navigationViewHeight - 24.0)/2.0)
            ])
        }
        
        // 导航栏阴影
        if navigationView.subviews.isEmpty == false {
            navigationView.contentMode = .scaleToFill
            navigationView.isUserInteractionEnabled = true
            navigationView.image = AssetBrowserResource.image(named: "browser_top")
        }
    }
    
    /// 添加手势识别
    private func addGestureRecognizer() {
        // 缩放
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        // 退出/清屏
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
        // 拖拽时退出
        if dragToDismiss {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
            addGestureRecognizer(pan)
        }
    }
}

// MARK: - Update
extension MNAssetBrowser {
    
    /// 当前展示的表格
    private var currentDisplayCell: MNAssetBrowserCell? {
        collectionView.cellForItem(at: IndexPath(item: displayIndex, section: 0)) as? MNAssetBrowserCell
    }
    
    /// 更新当前索引
    private func updateDisplayIndex() {
        let currentIndex: Int = Int(round(collectionView.contentOffset.x/collectionView.bounds.width))
        if currentIndex == displayIndex { return }
        displayIndex = currentIndex
        if let cell = currentDisplayCell {
            cell.preparedDisplay()
        }
        if let delegate = delegate {
            delegate.assetBrowser?(self, didScrollToItemAt: displayIndex)
        }
    }
    
    /// 更新当前展示的资源
    /// - Parameter asset: 新的资源模型
    public func updateDisplayAsset(_ asset: MNAssetBrowseSupported) {
        guard displayIndex >= 0, displayIndex < assets.count else { return }
        guard let cell = currentDisplayCell else { return }
        let old = assets.remove(at: displayIndex)
        if displayIndex == fromIndex {
            asset.container = old.container
        }
        assets.insert(asset, at: displayIndex)
        cell.willDisplay(asset)
        cell.preparedDisplay()
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
    public func present(in superview: UIView? = nil, from index: Int = 0, animated: Bool = true, state handler: ((_ state: MNAssetBrowser.State)->Void)? = nil) {
        
        guard let superview = superview ?? UIWindow.mn.current else {
#if DEBUG
            print("browser superview is null.")
#endif
            return
        }
        
        // 保证资源模型可用
        guard assets.isEmpty == false, index < assets.count else {
#if DEBUG
            print("unknown assets.")
#endif
            return
        }
        
        let asset = assets[index]
        guard let container = asset.container else {
#if DEBUG
            print("unknown from asset container.")
#endif
            return
        }
        
        // 提取转场图片
        var animatedImage: UIImage?
        if let cover = asset.cover {
            animatedImage = cover
        } else if container is UIImageView {
            let imageView = container as! UIImageView
            animatedImage = imageView.image
        } else if container is UIButton {
            let button = container as! UIButton
            animatedImage = button.currentBackgroundImage ?? button.currentImage
        } else if let contents = asset.contents, contents is UIImage {
            let image = contents as! UIImage
            animatedImage = image
        }
        if let image = animatedImage, let images = image.images, images.count > 1 {
            // 取第一帧
            animatedImage = images.first
        }
        
        guard let animatedImage = animatedImage else {
#if DEBUG
            print("unknown from asset thumbnail.")
#endif
            return
        }
        
        // 通知即将开始
        if let handler = handler {
            handler(.willAppear)
        }
        if let delegate = delegate {
            delegate.assetBrowser?(self, didChange: .willAppear)
        }
        
        frame = superview.bounds
        
        let isUserInteractionEnabled = superview.isUserInteractionEnabled
        superview.isUserInteractionEnabled = false
        center = CGPoint(x: superview.bounds.midX, y: superview.bounds.midY)
        
        let backgroundColor = backgroundColor
        self.backgroundColor = .clear
        
        fromIndex = index
        fromView = container
        
        let hidden = container.isHidden
        container.isHidden = true
        backgroundView.image = superview.layer.mn.snapshotImage
        container.isHidden = hidden
        
        superview.addSubview(self)
        createSubview()
        addGestureRecognizer()
        
        layoutIfNeeded()
        collectionView.isHidden = true
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        }
        animationView.alpha = 0.0
        animationView.backgroundColor = backgroundColor ?? .black
        
        let targetSize = animatedImage.size.mn.scaleFit(in: CGSize(width: frame.width, height: frame.height - 1.0))
        let toRect = CGRect(x: (frame.width - targetSize.width)/2.0, y: (frame.height - targetSize.height)/2.0, width: targetSize.width, height: targetSize.height)
        
        interactiveView.image = animatedImage
        interactiveView.frame = container.superview!.convert(container.frame, to: self)
        interactiveView.contentMode = container.contentMode
        interactiveView.layer.cornerRadius = container.layer.cornerRadius
        
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(true)
        let animations: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.animationView.alpha = 1.0
            self.navigationView.alpha = 1.0
            self.interactiveView.frame = toRect
            self.interactiveView.layer.setValue(0.0, forKey: #keyPath(CALayer.cornerRadius))
        }
        let completion: (Bool)->Void = { [weak self, weak superview] _ in
            UIView.setAnimationsEnabled(animationsEnabled)
            if let superview = superview {
                superview.isUserInteractionEnabled = isUserInteractionEnabled
            }
            guard let self = self else { return }
            self.collectionView.isHidden = false
            self.interactiveView.isHidden = true
            if let handler = handler {
                handler(.didAppear)
            }
            if let delegate = self.delegate {
                delegate.assetBrowser?(self, didChange: .didAppear)
            }
            self.updateDisplayIndex()
        }
        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: animations, completion: completion)
        } else {
            animations()
            completion(true)
        }
    }
    
    /// 浏览某个资源内容
    /// - Parameters:
    ///   - container: 资源容器
    ///   - superview: 父视图
    ///   - image: 过渡动画图片
    ///   - animated: 是否动态展示
    ///   - handler: 状态更新提醒
    public class func present(container: UIView, in superview: UIView? = nil, using image: UIImage? = nil, animated: Bool = true, state handler: ((_ state: MNAssetBrowser.State)->Void)? = nil) {
        var animatedImage: UIImage?
        if let image = image {
            animatedImage = image
        } else if container is UIImageView {
            let imageView = container as! UIImageView
            animatedImage = imageView.image
        } else if container is UIButton {
            let button = container as! UIButton
            animatedImage = button.currentBackgroundImage ?? button.currentImage
        }
        if let image = animatedImage, let images = image.images, images.count > 1 {
            animatedImage = images.first
        }
        guard let animatedImage = animatedImage else {
#if DEBUG
            print("unknown present from image.")
#endif
            //fatalError("unknown animated image.")
            return
        }
        let item = MNAssetBrowser.Item()
        item.cover = animatedImage
        item.contents = animatedImage
        item.container = container
        item.type = animatedImage.mn.isAnimatedImage ? .gif : .photo
        let browser = MNAssetBrowser(assets: [item])
        browser.backgroundColor = .black
        browser.present(in: superview, from: 0, animated: animated, state: handler)
    }
}

// MARK: - 消失
extension MNAssetBrowser {
    
    /// 结束浏览
    /// - Parameters:
    ///   - animated: 是否动态
    ///   - handler: 状态更新回调
    public func dismiss(animated: Bool = true, state handler: ((_ state: MNAssetBrowser.State)->Void)? = nil) {
        
        guard let superview = superview else { return }
        let isUserInteractionEnabled = superview.isUserInteractionEnabled
        superview.isUserInteractionEnabled = false
        
        let asset = assets[displayIndex]
        var toView: UIView! = displayIndex == fromIndex ? fromView : asset.container
        if let subview = toView {
            if subview != fromView {
                let rect = subview.superview!.convert(subview.frame, to: self)
                if bounds.intersects(rect) == false { toView = fromView }
            }
        } else {
            toView = fromView
        }
        if let toView = toView, toView != fromView {
            // 重新截屏
            isHidden = true
            let hidden = toView.isHidden
            toView.isHidden = true
            backgroundView.image = superview.layer.mn.snapshotImage
            isHidden = false
            toView.isHidden = hidden
        }
        
        let cell = currentDisplayCell
        if let cell = cell {
            cell.pauseDisplaying()
        }
        
        if let handler = handler {
            handler(.willDisappear)
        }
        if let delegate = delegate {
            delegate.assetBrowser?(self, didChange: .willDisappear)
        }
        
        var animatedImage: UIImage?
        if let cover = asset.cover {
            animatedImage = cover
        } else if toView is UIImageView {
            let imageView = toView as! UIImageView
            animatedImage = imageView.image
        } else if toView is UIButton {
            let button = toView as! UIButton
            animatedImage = button.currentBackgroundImage ?? button.currentImage
        } else if let cell = cell {
            animatedImage = cell.displayedImage
        }
        if let image = animatedImage, let images = image.images, images.count > 1 {
            animatedImage = images.first
        }
        
        collectionView.isHidden = true
        interactiveView.isHidden = false
        interactiveView.image = animatedImage
        interactiveView.contentMode = toView.contentMode
        if let cell = cell {
            interactiveView.frame = cell.scrollView.convert(cell.scrollView.contentView.frame, to: self)
        }
        
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(true)
        let cornerRadius = toView.layer.cornerRadius
        let toRect = toView.superview!.convert(toView.frame, to: self)
        let animations1: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.animationView.alpha = 0.0
        }
        let animations2: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.interactiveView.frame = toRect
            self.interactiveView.layer.setValue(0.99, forKeyPath: "transform.scale")
            self.interactiveView.layer.setValue(cornerRadius, forKey: #keyPath(CALayer.cornerRadius))
        }
        let animations3: ()->Void = { [weak self] in
            guard let self = self else { return }
            self.alpha = 0.0
            self.interactiveView.layer.setValue(1.0, forKeyPath: "transform.scale")
        }
        let completion: (Bool)->Void = { [weak self, weak superview] _ in
            UIView.setAnimationsEnabled(animationsEnabled)
            if let superview = superview {
                superview.isUserInteractionEnabled = isUserInteractionEnabled
            }
            guard let self = self else { return }
            self.removeFromSuperview()
            if let handler = handler {
                handler(.didDisappear)
            }
            if let delegate = self.delegate {
                delegate.assetBrowser?(self, didChange: .didDisappear)
            }
        }
        if animated {
            UIView.animate(withDuration: animationDuration*2.0, animations: animations1)
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: animations2) { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: self.animationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: animations3, completion: completion)
            }
        } else {
            animations1()
            animations2()
            animations3()
            completion(true)
        }
    }
    
    private func dismissFromCurrent() {
        
        let superview = superview!
        let isUserInteractionEnabled = superview.isUserInteractionEnabled
        superview.isUserInteractionEnabled = false
        
        var toRect = interactiveView.frame
        var contentMode = interactiveView.contentMode
        var cornerRadius = interactiveView.layer.cornerRadius
        if isAllowZoomDismiss, let interactiveToView = interactiveToView {
            contentMode = interactiveToView.contentMode
            cornerRadius = interactiveToView.layer.cornerRadius
            toRect = interactiveToView.superview!.convert(interactiveToView.frame, to: self)
        } else {
            toRect.origin.y = interactiveView.frame.minY < 0.0 ? -toRect.height : frame.height
        }
        interactiveView.contentMode = contentMode
        
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(true)
        UIView.animate(withDuration: animationDuration*2.0) { [weak self] in
            guard let self = self else { return }
            self.animationView.alpha = 0.0
        }
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
            guard let self = self else { return }
            self.interactiveView.frame = toRect
            self.interactiveView.layer.setValue(cornerRadius, forKey: #keyPath(CALayer.cornerRadius))
        } completion: { [weak self, weak superview] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: self.animationDuration) { [weak self] in
                guard let self = self else { return }
                self.alpha = 0.0
            } completion: { [weak self] _ in
                UIView.setAnimationsEnabled(animationsEnabled)
                if let superview = superview {
                    superview.isUserInteractionEnabled = isUserInteractionEnabled
                }
                guard let self = self else { return }
                self.removeFromSuperview()
                if let delegate = self.delegate {
                    delegate.assetBrowser?(self, didChange: .didDisappear)
                }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MNAssetBrowserCell", for: indexPath)
        if cell is MNAssetBrowserCell {
            let cell = cell as! MNAssetBrowserCell
            cell.delegate = self
            cell.autoPlay = autoPlay
            cell.maximumZoomScale = maximumZoomScale
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetBrowserCell else { return }
        guard indexPath.item < assets.count else { return }
        let asset = assets[indexPath.item]
        cell.willDisplay(asset)
        cell.updateToolBar(visible: navigationView.transform == .identity, animated: false)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MNAssetBrowserCell else { return }
        cell.endDisplaying()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false, scrollView.isDragging == false, scrollView.isDecelerating == false else { return }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateDisplayIndex()
    }
}

// MARK: - MNAssetBrowseResourceHandler
extension MNAssetBrowser: MNAssetBrowseResourceHandler {
    
    public func browserCell(_ cell: MNAssetBrowserCell, fetchCover asset: any MNAssetBrowseSupported, completion completionHandler: @escaping (any MNAssetBrowseSupported) -> Void) {
        if let _ = asset.cover {
            completionHandler(asset)
        } else if let delegate = delegate {
            delegate.assetBrowser?(self, fetchCover: asset, completion: completionHandler)
        }
    }
    
    public func browserCell(_ cell: MNAssetBrowserCell, fetchContents asset: any MNAssetBrowseSupported, progress progressHandler: @escaping (any MNAssetBrowseSupported, Double, (any Error)?) -> Void, completion completionHandler: @escaping (any MNAssetBrowseSupported) -> Void) {
        if let _ = asset.contents {
            completionHandler(asset)
        } else if let delegate = delegate {
            delegate.assetBrowser?(self, fetchContents: asset, progress: progressHandler, completion: completionHandler)
        }
    }
}

// MARK: - Event
extension MNAssetBrowser {
    
    /// 按钮点击事件
    /// - Parameter sender: 按钮
    @objc private func navigationBarItemTouchUpInside(_ sender: UIButton) {
        guard let event = MNAssetBrowser.Event(rawValue: sender.tag) else { return }
        if event == .back {
            if let cell = currentDisplayCell, cell.scrollView.zoomScale > 1.0 {
                cell.scrollView.setZoomScale(1.0, animated: true)
            } else {
                dismiss()
            }
        } else if let delegate = delegate {
            delegate.assetBrowser?(self, navigationItemTouchUpInside: event)
        }
    }
}

// MARK: - 交互
extension MNAssetBrowser: UIGestureRecognizerDelegate {
    
    @objc private func tap(_ recognizer: UITapGestureRecognizer) {
        let visible = navigationView.transform == .identity
        if visible, navigationView.subviews.isEmpty == false {
            let location = recognizer.location(in: self)
            guard bounds.inset(by: UIEdgeInsets(top: navigationView.frame.maxY, left: 0.0, bottom: 0.0, right: 0.0)).contains(location) else { return }
        }
        guard let cell = currentDisplayCell else { return }
        var shouldDismiss = false
        if tapToDismiss, cell.scrollView.zoomScale == 1.0 {
            let location = recognizer.location(in: cell.scrollView.contentView)
            if cell.scrollView.contentView.bounds.contains(location) {
                shouldDismiss = true
            }
        }
        if shouldDismiss {
            // 退出浏览
            dismiss()
        } else {
            // 控制是否清屏
            cell.updateToolBar(visible: visible == false, animated: true)
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                self.navigationView.transform = visible ? .init(translationX: 0.0, y: -self.navigationView.frame.maxY) : .identity
            }
        }
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
            
            guard let cell = currentDisplayCell, cell.scrollView.zoomScale == 1.0 else { break }
            let location = recognizer.location(in: cell.scrollView.contentView)
            guard cell.scrollView.contentView.bounds.contains(location) else { break }
            
            UIView.animate(withDuration: 0.25) { [weak self] in
                guard let self = self else { return }
                self.navigationView.alpha = 0.0
            }
            
            resumeWhenEndDragging = cell.isPlaying
            cell.pauseDisplaying()
            
            let asset = assets[displayIndex]
            var interactiveToView: UIView! = displayIndex == fromIndex ? fromView : asset.container
            if let subview = interactiveToView {
                if subview != fromView {
                    let rect = subview.superview!.convert(subview.frame, to: self)
                    if bounds.intersects(rect) == false { interactiveToView = fromView }
                }
            } else {
                interactiveToView = fromView
            }
            if interactiveToView! != fromView {
                // 重新截屏
                isHidden = true
                let hidden = interactiveToView.isHidden
                interactiveToView.isHidden = true
                lastBackgroundImage = backgroundView.image
                if let superview = superview {
                    backgroundView.image = superview.layer.mn.snapshotImage
                }
                isHidden = false
                interactiveToView.isHidden = hidden
            }
            self.interactiveToView = interactiveToView
            
            collectionView.isHidden = true
            interactiveView.isHidden = false
            interactiveView.image = cell.displayedImage
            interactiveView.frame = cell.scrollView.convert(cell.scrollView.contentView.frame, to: self)
            interactiveFrame = interactiveView.frame
            
            var toSize = interactiveToView.bounds.size
            if toSize.width > bounds.size.width || toSize.height > bounds.size.height { toSize = toSize.mn.scaleFit(in: CGSize(width: bounds.width, height: bounds.height - 1.0)) }
            interactiveDelay = (bounds.height - toSize.height)/2.0
            interactiveRatio = CGPoint(x: toSize.width/interactiveFrame.width, y: toSize.height/interactiveFrame.height)
            isAllowZoomDismiss = max(frame.width, frame.height) - max(interactiveView.frame.width, interactiveView.frame.height) >= 50.0

        case .changed:
            
            guard interactiveView.isHidden == false else { break }
            
            let ratio = abs(bounds.height/2.0 - interactiveView.frame.midY)/interactiveDelay
            
            let translation = recognizer.translation(in: self)
            recognizer.setTranslation(.zero, in: self)
            
            var center = interactiveView.center
            center.y += translation.y
            
            if isAllowZoomDismiss {
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
            
            guard interactiveView.isHidden == false else { break }
            
            if interactiveView.frame.midY >= (bounds.midY + 50.0) {
                dismissFromCurrent()
            } else {
                endPanFromCurrent()
            }
        case .cancelled:
            guard interactiveView.isHidden == false else { break }
            endPanFromCurrent()
        default: break
        }
    }
    
    private func endPanFromCurrent() {
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
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
            if self.resumeWhenEndDragging, let cell = self.currentDisplayCell {
                cell.resume()
            }
        }
    }
}
