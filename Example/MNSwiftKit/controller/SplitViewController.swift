//
//  SplitViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class SplitViewController: UIViewController {
    
    var segmentedViewController: MNSegmentedViewController!
    
    @IBOutlet weak var axisSegment: UISegmentedControl!
    
    
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航高度约束
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        // 这里先不布局控制器，界面还不确定
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard mn.isFirstAssociated else { return }
        createSplitController()
    }
    
    private func createSplitController() {
        segmentedViewController = MNSegmentedViewController(configuration: MNSegmentedConfiguration())
        segmentedViewController.delegate = self
        segmentedViewController.dataSource = self
        mn.addChild(segmentedViewController)
        segmentedViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: navHeight.constant),
            segmentedViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            segmentedViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            segmentedViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        
    }
}

// MARK: - MNSplitViewControllerDataSource
extension SplitViewController: MNSegmentedViewControllerDataSource {
    
    var preferredSubpageHeaderView: UIView? {
        
        let image = UIImage(named: "b_16")!
        let imageView = UIImageView(image: image)
        imageView.mn.size = .init(width: view.frame.width, height: ceil(image.size.height/image.size.width*view.frame.width))
        return imageView
    }
    
    
    func segmentedViewController(_ viewController: MNSwiftKit.MNSegmentedViewController, subpageAt index: Int) -> any MNSwiftKit.MNSegmentedSubpageConvertible {
        
        SplitListController(style: index % 2 == 0 ? .item : .row)
    }
    
    var preferredSegmentedTitles: [String] {
        
        ["选项一", "选项二", "选项三", "选项四", "选项五", "选项六", "选项七", "选项八", "选项九", "选项十", "选项十一", "选项十二", "选项十三"]
    }
}

// MARK: - MNSplitViewControllerDelegate
extension SplitViewController: MNSegmentedViewControllerDelegate {
    
    func segmentedViewController(_ viewController: MNSegmentedViewController, subpageDidChangeAt index: Int) {
        
        print("*****选择了索引：\(index)")
    }
    
    func segmentedViewController(_ viewController: MNSegmentedViewController, subpageOffsetDidChange contentOffset: CGPoint) {
        
    }
}
