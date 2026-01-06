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
        
        // https://vdept3.bdstatic.com/mda-jgczxj3hrixc6cgz/mda-jgczxj3hrixc6cgz.mp4?v_from_s=hkapp-haokan-nanjing&auth_key=1767730395-0-0-748398fc29621ccd17dfc4dc431bb8cb&bcevod_channel=searchbox_feed&cr=0&cd=0&pd=1&pt=3&logid=0795649871&vid=4503085386691377183&klogid=0795649871&abtest=
        // https://vdept3.bdstatic.com/mda-kdun1ep7pga02wt3/v1-cae/mda-kdun1ep7pga02wt3.mp4?v_from_s=hkapp-haokan-nanjing&auth_key=1767731250-0-0-627091817697e7af51cd1eca1f97a941&bcevod_channel=searchbox_feed&cr=0&cd=0&pd=1&pt=3&logid=1650337440&vid=13600840354969990691&klogid=1650337440&abtest=
        
        // https://vdept3.bdstatic.com/mda-jfss685v77ndea1m/mda-jfss685v77ndea1m.mp4?v_from_s=hkapp-haokan-nanjing&auth_key=1767731312-0-0-9f1089d347503a0d4cd5f41f9cdd0b5f&bcevod_channel=searchbox_feed&cr=0&cd=0&pd=1&pt=3&logid=1712727608&vid=8986735944979594339&klogid=1712727608&abtest=
        
        // https://vdept3.bdstatic.com/mda-kf3pzcw3f2zu2mr2/mda-kf3pzcw3f2zu2mr2.mp4?v_from_s=hkapp-haokan-nanjing&auth_key=1767731374-0-0-6a1365e3b1821db184de58c550bc1e9b&bcevod_channel=searchbox_feed&cr=0&cd=0&pd=1&pt=3&logid=1774708086&vid=5106310553708043304&klogid=1774708086&abtest=
        
        let clss: [String] = ["ToastViewController", "AssetBrowserController", "AssetPickerController", "EmoticonKeyboardController", "EditingViewController", "SegmentedViewController", "AlertViewController", "PopoverViewController"]
        let modules: [String] = ["Toast", "AssetBrowser", "AssetPicker", "EmoticonKeyboard", "EditingView", "SegmentedViewController", "Components", "Components"]
        let names: [String] = ["Toast 提示弹窗", "资源浏览器", "资源选择器", "表情键盘", "表格编辑", "分段控制器", "提示弹框与操作表单", "弹出视图"]
        for (index, name) in names.enumerated() {
            let row = HomeListRow(index: index, title: name, cls: clss[index], module: modules[index])
            rows.append(row)
        }
        
        tableView.rowHeight = 55.0
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
        navigationController?.pushViewController(vc, animated: true)
    }
}
