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
    
    var splitController: MNSplitViewController!
    
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
        splitController = MNSplitViewController(frame: view.bounds.inset(by: .init(top: navHeight.constant, left: 0.0, bottom: 0.0, right: 0.0)), axis: axisSegment.selectedSegmentIndex == 0 ? .horizontal : .vertical)
        splitController.delegate = self
        splitController.dataSource = self
        mn.addChild(splitController)
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        splitController.axis = axisSegment.selectedSegmentIndex == 0 ? .horizontal : .vertical
        splitController.reloadSubpage()
    }
}

// MARK: - MNSplitViewControllerDataSource
extension SplitViewController: MNSplitViewControllerDataSource {
    
    var preferredPageIndex: Int {
        
        0
    }
    
    var pageHeaderView: UIView? {
        let image = UIImage(named: "b_16")!
        let imageView = UIImageView(image: image)
        imageView.mn.size = .init(width: view.frame.width, height: ceil(image.size.height/image.size.width*view.frame.width))
        return imageView
    }
    
    var preferredPageTitles: [String] {
        
        ["选项一", "选项二", "选项三", "选项四", "选项五", "选项六", "选项七", "选项八", "选项九", "选项十", "选项十一", "选项十二", "选项十三"]
    }
    
    func splitViewController(_ viewController: MNSwiftKit.MNSplitViewController, contentForPageAt index: Int) -> any MNSwiftKit.MNSplitPageConvertible {
        
        SplitListController(frame: viewController.contentRect, style: index % 2 == 0 ? .item : .row)
    }
}

// MARK: - MNSplitViewControllerDelegate
extension SplitViewController: MNSplitViewControllerDelegate {
    
    func splitViewController(_ splitController: MNSplitViewController, didChangePageAt index: Int) {
        
        print("*****选择了索引：\(index)")
    }
    
    func splitViewController(_ splitController: MNSplitViewController, headerOffsetChanged change: [NSKeyValueChangeKey : CGPoint]) {
        
        print("=====页头偏移变化：\(change[.oldKey]!)----\(change[.newKey]!)")
    }
    
    func splitViewController(_ splitController: MNSplitViewController, scrollView: UIScrollView, contentOffsetChanged contentOffset: CGPoint) {
        
        print("-----页面偏移量变化：\(contentOffset)")
    }
}
