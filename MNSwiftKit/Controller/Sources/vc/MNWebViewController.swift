//
//  MNWebViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/8/7.
//  网页解决方案

import UIKit
import WebKit
#if canImport(MNSwiftKit_Layout)
import MNSwiftKit_Layout
#endif
#if canImport(MNSwiftKit_Networking)
import MNSwiftKit_Networking
#endif

/// 网页加载代理
@objc public protocol MNWebControllerDelegate: NSObjectProtocol {
    /// 开始加载网页
    /// - Parameter webViewController: 网页控制器
    @objc optional func webViewControllerDidStart(_ webViewController: MNWebViewController)
    /// 即将结束加载
    /// - Parameter webViewController: 网页控制器
    @objc optional func webViewControllerWillFinish(_ webViewController: MNWebViewController)
    /// 已经结束加载网页
    /// - Parameter webViewController: 网页控制器
    @objc optional func webViewControllerDidFinish(_ webViewController: MNWebViewController)
    /// 网页加载失败
    /// - Parameters:
    ///   - webViewController: 网页控制器
    ///   - error: 错误信息
    @objc optional func webViewController(_ webViewController: MNWebViewController, didFailLoad error: Error)
}

/// 网页控制器
open class MNWebViewController: MNExtendViewController {
    /// 资源定位器
    open var url: URL!
    /// 静态网页 优先级高于url
    @objc open var html: String?
    /// 外界指定请求对象
    @objc public var request: URLRequest?
    /// 外界可指定配置信息
    @objc public var configuration: WKWebViewConfiguration?
    /// 关闭按钮
    private(set) var closeButton: UIButton!
    /// 刷新按钮
    private(set) var reloadButton: UIButton!
    /// 网页控件
    private(set) var webView: WKWebView!
    /// 交互代理
    private let messageHandler = MNScriptMessageHandler()
    /// 加载事件代理
    @objc public weak var delegate: MNWebControllerDelegate?
    /// 进度条
    @objc public lazy var progressView: MNWebProgressView = MNWebProgressView()
    /// 是否在显示时刷新网页
    @objc public var reloadWhenAppear: Bool = false
    /// 是否允许刷新标题
    @objc public var allowsUpdateTitle: Bool = true
    
    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(url: URL!) {
        super.init()
        self.url = url
    }
    
    @objc convenience init(string: String) {
        self.init(url: URL(string: string))
    }
    
    public convenience init(html: String, baseURL: URL? = nil) {
        self.init(url: baseURL)
        self.html = html
    }
    
    public convenience init(configuration: WKWebViewConfiguration, request: URLRequest) {
        self.init()
        self.request = request
        self.configuration = configuration
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    open override func initialized() {
        super.initialized()
        addScript(responder: MNWebResponder())
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let configuration = configuration ?? WKWebViewConfiguration()
        let userContentController = configuration.userContentController
        for script in messageHandler.responders.keys {
            userContentController.add(messageHandler, name: script)
        }
        webView = WKWebView(frame: contentView.bounds, configuration: configuration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.backgroundColor = contentView.backgroundColor
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        contentView.addSubview(webView)
        
        progressView.mn_layout.size = CGSize(width: contentView.frame.width, height: 3.0)
        progressView.autoresizingMask = .flexibleWidth
        contentView.addSubview(progressView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstAppear == false, reloadWhenAppear {
            reload()
        }
    }
    
    open override func prepareExecuteLoadData() -> Bool {
        if let request = request {
            load(request)
        } else if let html = html {
            webView.loadHTMLString(html, baseURL: url)
        } else if let url = url {
            load(url: url)
        }
        return false
    }
    
    /// 监听标题/进度信息
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case #keyPath(WKWebView.title):
            // 标题
            guard allowsUpdateTitle else { break }
            title = webView.title
        case #keyPath(WKWebView.estimatedProgress):
            // 进度
            progressView.setProgress(webView.estimatedProgress, animated: true)
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

// MARK: - Load & Reload
extension MNWebViewController {
    
    /// 加载url
    /// - Parameter url: 请求url
    @objc open func load(url: URL?) {
        guard let url = url else { return }
        guard let request = request(for: url) else { return }
        load(request)
    }
    
    /// 定制请求
    /// - Parameter url: 请求url
    /// - Returns: 请求体
    @objc open func request(for url: URL) -> URLRequest? {
        return URLRequest(url: url)
    }
    
    /// 加载请求
    /// - Parameter request: 请求体
    @objc open func load(_ request: URLRequest) {
        guard let webView = webView else { return }
        webView.stopLoading()
        webView.load(request)
    }
    
    /// 重载
    @objc open func reload() {
        guard let webView = webView else { return }
        stop()
        webView.reload()
    }
    
    /// 停止加载
    @objc open func stop() {
        guard let webView = webView else { return }
        guard webView.isLoading else { return }
        webView.stopLoading()
        if let reloadButton = reloadButton, reloadButton.layer.speed == 1.0 {
            let pauseTime = reloadButton.layer.convertTime(CACurrentMediaTime(), from: nil)
            reloadButton.layer.speed = 0.0
            reloadButton.layer.timeOffset = pauseTime
        }
    }
}

// MARK: - Back & GoBack & Close
extension MNWebViewController {
    
    @objc open func back() {
        if goBack() { return }
        close()
    }
    
    // 网页内部返回
    @objc open func goBack() -> Bool {
        guard webView.canGoBack else { return false }
        stop()
        closeButton?.isHidden = false
        webView.goBack()
        return true
    }
    
    @objc open func close() {
        super.navigationBarLeftBarItemTouchUpInside(nil)
    }
}

// MARK: - 导航
extension MNWebViewController {
    
    /// 是否渲染返回按钮
    /// - Returns: 是否渲染返回按钮
    open override func navigationBarShouldDrawBackBarItem() -> Bool { false }
    
    /// 创建导航左按钮
    /// - Returns: 导航左按钮
    open override func navigationBarShouldCreateLeftBarItem() -> UIView? {
        let leftItemView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 62.0, height: 22.0))
        let backButton = UIButton(type: .custom)
        backButton.mn_layout.size = CGSize(width: leftItemView.frame.height, height: leftItemView.frame.height)
        backButton.setBackgroundImage(ControllerResourceLoader.image(named: "back"), for: .normal)
        backButton.setBackgroundImage(ControllerResourceLoader.image(named: "back"), for: .highlighted)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        leftItemView.addSubview(backButton)
        closeButton = UIButton(type: .custom)
        closeButton.isHidden = true
        closeButton.mn_layout.size = CGSize(width: 20.0, height: 20.0)
        closeButton.mn_layout.maxX = leftItemView.frame.width
        closeButton.mn_layout.midY = leftItemView.frame.height/2.0
        closeButton.setBackgroundImage(ControllerResourceLoader.image(named: "close"), for: .normal)
        closeButton.setBackgroundImage(ControllerResourceLoader.image(named: "close"), for: .highlighted)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        leftItemView.addSubview(closeButton)
        return leftItemView
    }
    
    /// 创建导航右按钮
    /// - Returns: 导航右按钮
    open override func navigationBarShouldCreateRightBarItem() -> UIView? {
        reloadButton = UIButton(type: .custom)
        reloadButton.frame = CGRect(x: 0.0, y: 0.0, width: 23.0, height: 23.0)
        reloadButton.setBackgroundImage(ControllerResourceLoader.image(named: "refresh"), for: .normal)
        reloadButton.setBackgroundImage(ControllerResourceLoader.image(named: "refresh"), for: .highlighted)
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 1.0
        animation.toValue = Double.pi*2.0
        animation.beginTime = 0.0
        animation.autoreverses = false
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.repeatCount = Float.greatestFiniteMagnitude
        reloadButton.layer.add(animation, forKey: "rotation")
        let pauseTime = reloadButton.layer.convertTime(CACurrentMediaTime(), from: nil)
        reloadButton.layer.speed = 0.0
        reloadButton.layer.timeOffset = pauseTime
        return reloadButton
    }
}

// MARK: - WKNavigationDelegate
extension MNWebViewController: WKNavigationDelegate {
    /// 开始加载
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let reloadButton = reloadButton, reloadButton.layer.speed == 0.0 {
            let pauseTime = reloadButton.layer.timeOffset
            reloadButton.layer.speed = 1.0
            reloadButton.layer.timeOffset = 0.0
            reloadButton.layer.beginTime = 0.0
            let timeSincePause = reloadButton.layer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
            reloadButton.layer.beginTime = timeSincePause
        }
        if let delegate = delegate {
            delegate.webViewControllerDidStart?(self)
        }
    }
    /*当内容开始到达主帧时被调用(即将完成)*/
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        delegate?.webViewControllerWillFinish?(self)
    }
    /*加载完成(并非真正的完成, 比如重定向)*/
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let reloadButton = reloadButton, reloadButton.layer.speed == 1.0 {
            let pauseTime = reloadButton.layer.convertTime(CACurrentMediaTime(), from: nil)
            reloadButton.layer.speed = 0.0
            reloadButton.layer.timeOffset = pauseTime
        }
        if let delegate = delegate {
            delegate.webViewControllerDidFinish?(self)
        }
    }
    /*加载失败*/
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == 102, (error as NSError).domain == WKErrorDomain { return }
        if let reloadButton = reloadButton, reloadButton.layer.speed == 1.0 {
            let pauseTime = reloadButton.layer.convertTime(CACurrentMediaTime(), from: nil)
            reloadButton.layer.speed = 0.0
            reloadButton.layer.timeOffset = pauseTime
        }
        if let delegate = delegate, (error as NSError).code != NSURLErrorCancelled {
            delegate.webViewController?(self, didFailLoad: error)
        }
    }
    /*在提交的主帧中发生错误时调用*/
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == 102, (error as NSError).domain == WKErrorDomain { return }
        if let reloadButton = reloadButton, reloadButton.layer.speed == 1.0 {
            let pauseTime = reloadButton.layer.convertTime(CACurrentMediaTime(), from: nil)
            reloadButton.layer.speed = 0.0
            reloadButton.layer.timeOffset = pauseTime
        }
    }
    /**当webView接受SSL认证挑战*/
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        DispatchQueue.global().async {
            var credential: URLCredential?
            var disposition = URLSession.AuthChallengeDisposition.performDefaultHandling
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                if HTTPSecurityPolicy().evaluate(server: challenge.protectionSpace.serverTrust!, domain: challenge.protectionSpace.host) {
                    disposition = .useCredential
                    credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                } else {
                    // 验证失败
                    disposition = .cancelAuthenticationChallenge
                }
            }
            completionHandler(disposition, credential)
        }
    }
    /*开始加载后调用(可处理一些简单交互)*/
    /*
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {}
    */
    /**在请求开始加载之前调用 -- 跳转操作*/
    /*
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let absoluteString = navigationAction.request.url?.absoluteString {
            if (absoluteString.contains("https://itunes.apple.com") || absoluteString.contains("itms-appss://apps.apple.com") || absoluteString.contains("https://apps.apple.com")) && absoluteString.contains("/app/") && absoluteString.contains("/id") {
                // 打开应用
                if let url = URL(string: absoluteString) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                }
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    */
    /**接收到服务器重定向时调用*/
    /*
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {}
    */
}

// MARK: - WKUIDelegate
extension MNWebViewController: WKUIDelegate {
    /**js脚本需要新webview加载网页*/
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame == false {
            // 当前界面加载
            webView.load(navigationAction.request)
        } else {
            // 打开新的界面加载
            let vc = MNWebViewController(configuration: configuration, request: navigationAction.request)
            if let nav = navigationController {
                nav.pushViewController(vc, animated: true)
            } else {
                present(vc, animated: true)
            }
        }
        return nil
    }
    /**输入框 在js中调用prompt函数时,会调用该方法*/
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = defaultText
            textField.placeholder = prompt
            textField.font = UIFont.systemFont(ofSize: 16.0)
        }
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
            completionHandler(nil)
#if DEBUG
            print("取消输入")
#endif
        }))
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak alertController] action in
            completionHandler(alertController?.textFields?.first?.text)
#if DEBUG
            print("确定输入")
#endif
        }))
        present(alertController, animated: true, completion: nil)
    }
    /**确认框 在js中调用confirm函数时,会调用该方法*/
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { action in
            completionHandler(false)
#if DEBUG
            print("取消输入")
#endif
        }))
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            completionHandler(true)
#if DEBUG
            print("确定")
#endif
        }))
        present(alertController, animated: true, completion: nil)
    }
    /**警告框 在js中调用alert函数时,会调用该方法*/
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            completionHandler()
#if DEBUG
            print("确定")
#endif
        }))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - 添加脚本
extension MNWebViewController: MNWebScriptAddHandler {
    
    // 添加响应者
    public func addScript(responder: MNWebScriptBridge) -> Void {
        if responder is MNWebResponder {
            (responder as! MNWebResponder).webViewController = self
        }
        messageHandler.addScript(responder: responder)
    }
}
