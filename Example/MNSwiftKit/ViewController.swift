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
    
    private var isAppear: Bool = false
    
    private var rows: [HomeListRow] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleTop: NSLayoutConstraint!
    
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        titleTop.constant = (MN_NAV_BAR_HEIGHT - titleHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        let clss: [String] = ["ToastViewController", "AssetBrowserController", "AssetPickerController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController", "SplitViewController", "MenuViewController", "RequestViewController"]
        let modules: [String] = ["AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser", "AssetBrowser"]
        let names: [String] = ["Toast 提示控制器", "资源浏览器", "资源选择器", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器", "分页控制器", "菜单视图", "请求控制器"]
        for (index, name) in names.enumerated() {
            let row = HomeListRow(index: index, title: name, cls: clss[index], module: modules[index])
            rows.append(row)
        }
        
        tableView.rowHeight = 50.0
        tableView.register(UINib(nibName: "HomeTableCell", bundle: .main), forCellReuseIdentifier: "HomeTableCell")
        tableView.tableFooterView = UIView(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: MN_BOTTOM_SAFE_HEIGHT)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isAppear == false else { return }
        isAppear = true
        let indexPaths: [IndexPath] = (0..<rows.count).compactMap { IndexPath(row: $0, section: 0) }
        tableView.insertRows(at: indexPaths, with: .fade)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        isAppear ? rows.count : 0
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
        let cls: AnyClass? = NSClassFromString("\(nameSpace).\(row.cls)")
        guard let type = cls as? UIViewController.Type else { return }
        let vc = type.init()
        vc.title = row.title.string
        navigationController?.pushViewController(vc, animated: true)
    }
}
