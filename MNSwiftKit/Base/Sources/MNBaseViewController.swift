//
//  MNBaseViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/7/18.
//  控制器基类(提供基础功能)

import UIKit
import Foundation
import CoreFoundation

open class MNBaseViewController: UIViewController {
    
    /// 位置
    private var frame: CGRect = UIScreen.main.bounds
    
    /// 是否在显示中
    @objc public private(set) var isAppear: Bool = true
    
    /// 是否第一次显示
    @objc public private(set) var isFirstAppear: Bool = true
    
    /// 标记是否加载过数据
    private var isDataLoaded: Bool = false
    
    /// 标记需要刷新数据
    private var executeReloadData: Bool = false
    
    /// 状态栏相关
    @objc open var isStatusBarHidden: Bool = false
    @objc open var statusBarStyle: UIStatusBarStyle = .default
    @objc open var statusBarAnimation: UIStatusBarAnimation = .fade
    
    /// 数据请求体
    @objc open var httpRequest: HTTPPagingSupported?
    
    /// 内容视图
    @objc open private(set) lazy var contentView: UIView = {
        let contentView = UIView(frame: view.bounds.inset(by: UIEdgeInsets(top: 0.0, left: 0.0, bottom: preferredContentEdges.contains(.bottom) ? MN_BOTTOM_BAR_HEIGHT : 0.0, right: 0.0)))
        contentView.backgroundColor = .white
        return contentView
    }()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialized()
    }
    
    @objc public init() {
        super.init(nibName: nil, bundle: nil)
        initialized()
    }
    
    @objc public init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.frame = frame
        initialized()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初始化自身属性
    @objc open func initialized() {}
    
    /// 加载视图
    open override func loadView() {
        let view = UIView(frame: frame)
        view.backgroundColor = .white
        self.view = view
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // view的边缘允许额外布局的情况，默认为UIRectEdgeAll，意味着全屏布局(带穿透效果)
        edgesForExtendedLayout = .all
        // 额外布局是否包括不透明的Bar，默认为false
        extendedLayoutIncludesOpaqueBars = true
        // iOS11 后 additionalSafeAreaInsets 可抵消系统的安全区域
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = .zero
        } else {
            // 是否自动调整滚动视图的内边距,默认true 系统将会根据导航条和TabBar的情况自动增加上下内边距以防止被Bar遮挡
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(contentView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isChildViewController == false {
            setNeedsUpdateStatusBar(animated ? .fade : .none)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppear = true
        reloadDataIfNeeded()
        if isChildViewController == false {
            setNeedsUpdateStatusBar(animated ? .fade : .none)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isFirstAppear = false
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isAppear = false
    }
    
    /// 默认内容约束
    /// - Returns: 内容约束
    open var preferredContentEdges: UIViewController.Edge {
        let edges: UIViewController.Edge = []
        guard isChildViewController == false, isRootViewController else { return edges }
        return edges.union(.bottom)
    }
    
    /// 自动加载请求
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard isDataLoaded == false else { return }
        isDataLoaded = true
        guard prepareExecuteLoadData() else { return }
        loadData()
    }
    
    /// 触摸背景 收起键盘
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - LoadData
extension MNBaseViewController {
    
    /// 告知开始执行LoadData
    @objc open func prepareExecuteLoadData() -> Bool { true }
    
    /// 加载数据
    @objc open func loadData() {
        guard let request = httpRequest, request.isRunning == false else { return }
        request.start { [weak self] in
            guard let self = self, let request = self.httpRequest else { return }
            self.prepareLoadData(request)
        } completion: { [weak self] result in
            guard let self = self else { return }
            self.completeLoadData(result)
        }
    }
    
    /// 即将开始请求
    /// - Parameter request: 请求体
    @objc open func prepareLoadData(_ request: HTTPDataRequest) {
        guard contentView.mn.isToastAppearing == false else { return }
        contentView.mn.showActivityToast("请稍后")
    }
    
    /// 请求结束
    /// - Parameters:
    ///   - result: 请求结果
    @objc open func completeLoadData(_ result: HTTPResult) {
        if result.isSuccess {
            contentView.mn.closeToast()
        } else {
            contentView.mn.showMsgToast(result.msg)
        }
    }
}

// MARK: - ReloadData
extension MNBaseViewController {
    
    /// 重载数据
    @objc open func reloadData() {
        guard let httpRequest = httpRequest else { return }
        httpRequest.cancel()
        httpRequest.prepareReload()
        loadData()
    }
    
    /// 标记需要重载数据
    @objc open func setNeedsReloadData() {
        executeReloadData = true
    }
    
    /// 如果被标记就执行重载数据
    @objc open func reloadDataIfNeeded() {
        guard executeReloadData else { return }
        executeReloadData = false
        reloadData()
    }
}

// MARK: - 更新状态栏
extension MNBaseViewController {
    
    @objc open func setStatusBarHidden(_ isHidden: Bool, animation: UIStatusBarAnimation = .fade) {
        isStatusBarHidden = isHidden
        statusBarAnimation = animation
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc open func setStatusBarStyle(_ style: UIStatusBarStyle, animation: UIStatusBarAnimation = .fade) {
        statusBarStyle = style
        statusBarAnimation = animation
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc open func setNeedsUpdateStatusBar(_ animation: UIStatusBarAnimation = .fade) {
        statusBarAnimation = animation
        setNeedsStatusBarAppearanceUpdate()
    }
    
    open override var prefersStatusBarHidden: Bool { isStatusBarHidden }
    open override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { statusBarAnimation }
}

// MARK: - 设备方向限制
extension MNBaseViewController {
    
    open override var shouldAutorotate: Bool { false }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
}
