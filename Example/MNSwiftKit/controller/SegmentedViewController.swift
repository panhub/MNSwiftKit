//
//  SegmentedViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/19.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class SegmentedViewController: UIViewController {
    
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
        
        createSegmentedController()
    }
    
    private func createSegmentedController() {
        
        if let segmentedViewController = segmentedViewController {
            segmentedViewController.mn.removeFromParent()
            self.segmentedViewController = nil
        }
        
        var configuration = MNSegmentedConfiguration()
        configuration.separator.style = .trailing
        configuration.indicator.animationStyle = .stretch
        configuration.separator.backgroundColor = .gray.withAlphaComponent(0.15)
        if axisSegment.selectedSegmentIndex == 1 {
            // 纵向
            configuration.orientation = .vertical
            configuration.navigation.dimension = 90.0
            configuration.navigation.adjustmentBehavior = .centered
            configuration.item.dimension = 45.0
            configuration.item.dividerConstraint = .init(inset: 5.0, dimension: 0.7)
            configuration.item.dividerColor = .gray.withAlphaComponent(0.15)
            configuration.indicator.constraint = .matchTitle(dimension: 2.5)
        }
        segmentedViewController = MNSegmentedViewController(configuration: configuration)
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
    
    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        
        createSegmentedController()
    }
}

// MARK: - MNSplitViewControllerDataSource
extension SegmentedViewController: MNSegmentedViewControllerDataSource {
    
    var preferredSegmentedNavigationHeaderView: UIView? {
        
        let image = UIImage(named: "b_16")!
        let imageView = UIImageView(image: image)
        imageView.mn.size = .init(width: view.frame.width, height: ceil(image.size.height/image.size.width*view.frame.width))
        return imageView
    }
    
    
    func segmentedViewController(_ viewController: MNSwiftKit.MNSegmentedViewController, subpageAt index: Int) -> any MNSwiftKit.MNSegmentedSubpageConvertible {
        
        SegmentedSubpageController(style: index % 2 == 0 ? .grid : .table)
    }
    
    var preferredSegmentedNavigationTitles: [String] {
        
        ["选项一", "选项二", "选项三", "选项四", "选项五", "选项六", "选项七", "选项八", "选项九", "选项十", "选项十一", "选项十二", "选项十三"]
    }
}

// MARK: - MNSplitViewControllerDelegate
extension SegmentedViewController: MNSegmentedViewControllerDelegate {
    
    func segmentedViewController(_ viewController: MNSegmentedViewController, subpageDidChangeAt index: Int) {
        
        //print("选择了索引：\(index)")
    }
    
    func segmentedViewController(_ viewController: MNSegmentedViewController, subpageDidChangeContentOffset contentOffset: CGPoint) {
        
        //print("========：\(contentOffset)")
    }
    
    func segmentedViewController(_ viewController: MNSegmentedViewController, headerViewDidChangeOffset offset: CGPoint, from: CGPoint) {
        
        //print("--------：\(offset)")
    }
}
