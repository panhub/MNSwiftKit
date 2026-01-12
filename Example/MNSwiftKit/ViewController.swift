//
//  ViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/11/20.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class ViewController: UIViewController {
    // 标记是否已加载数据
    private var isLoaded: Bool = false
    // 数据模型数组
    private var rows: [HomeListRow] = []
    // 列表
    @IBOutlet weak var tableView: UITableView!
    // 标题顶部约束
    @IBOutlet weak var titleTop: NSLayoutConstraint!
    // 标题高度
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    // 导航高度
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        navHeight.constant = MN_TOP_BAR_HEIGHT
        titleTop.constant = (MN_NAV_BAR_HEIGHT - titleHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        let titles: [String] = ["提示弹窗", "资源浏览器", "资源选择器", "表情键盘", "表格编辑", "分段控制器", "提示弹框与操作表单", "弹出视图", "数字键盘与密码输入框", "网络请求", "导航转场动画", "页码指示器-常规", "页码指示器-自定义"]
        let subtitles: [String] = ["ToastViewController", "AssetBrowserController", "AssetPickerController", "EmoticonKeyboardController", "EditingViewController", "SegmentedViewController", "AlertViewController", "PopoverViewController", "PasscordViewController", "RequestViewController", "TransitionViewController", "PageControlController", "FontViewController"]
        let modules: [String] = ["Toast", "AssetBrowser", "AssetPicker", "EmoticonKeyboard", "EditingView", "SegmentedViewController", "Components", "Components", "Components", "Request", "Transitioning", "PageControl", "PageControl"]
        for (index, title) in titles.enumerated() {
            let row = HomeListRow(index: index, title: title, subtitle: subtitles[index], module: modules[index])
            rows.append(row)
        }
        
        tableView.rowHeight = 55.0
        tableView.register(UINib(nibName: "HomeTableCell", bundle: .main), forCellReuseIdentifier: "HomeTableCell")
        tableView.tableFooterView = UIView(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: MN_BOTTOM_SAFE_HEIGHT)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isLoaded == false else { return }
        isLoaded = true
        let indexPaths: [IndexPath] = (0..<rows.count).compactMap { IndexPath(row: $0, section: 0) }
        tableView.insertRows(at: indexPaths, with: .fade)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        isLoaded ? rows.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? HomeTableCell else { return }
        cell.update(row: rows[indexPath.row])
        
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.8
        animation.toValue = 1.0
        animation.autoreverses = false
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = true
        animation.mass = 0.38 // 值越大，惯性越大，振动越慢
        animation.stiffness = 180 // 值越大，弹簧越硬，回弹越快
        animation.damping = 5 // 值越大，衰减越快
        animation.duration = animation.settlingDuration
        cell.contentView.layer.removeAllAnimations()
        cell.contentView.layer.add(animation, forKey: "transform.scale")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = rows[indexPath.row]
        guard var nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else { return }
        nameSpace = nameSpace.replacingOccurrences(of: " ", with: "_")
        let cls: AnyClass? = NSClassFromString("\(nameSpace).\(row.subtitle)")
        guard let type = cls as? UIViewController.Type else { return }
        let vc = type.init()
        navigationController?.pushViewController(vc, animated: true)
    }
}
