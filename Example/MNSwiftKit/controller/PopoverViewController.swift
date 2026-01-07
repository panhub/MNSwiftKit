//
//  PopoverViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/1/4.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class PopoverViewController: UIViewController {
    /// 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    /// 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    /// 目标视图
    @IBOutlet weak var targetView: UIButton!
    /// 方向控制
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    /// 动画控制
    @IBOutlet weak var animationSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonTouchUpInside(_ sender: UIButton) {
        if sender.isSelected {
            // 收起
            sender.isSelected = false
            view.mn.closePopoverView(animated: true) {
                print("取消弹出")
            }
            return
        }
        sender.isSelected = true
        popup()
    }
    
    private func popup() {
        
        var configuration = MNPopoverConfiguration()
        configuration.titleFont = .systemFont(ofSize: 13.0, weight: .medium)
        configuration.titleColor = .white
        configuration.cornerRadius = 8.0
        configuration.borderWidth = 2.0
        configuration.borderColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        configuration.arrowSize = .init(width: 10.0, height: 8.0)
        switch directionSegmentedControl.selectedSegmentIndex {
        case 0:
            configuration.arrowDirection = .up
            configuration.arrowOffset = .init(horizontal: 0.0, vertical: 3.0)
        case 1:
            configuration.arrowDirection = .left
            configuration.arrowOffset = .init(horizontal: 3.0, vertical: 0.0)
        case 2:
            configuration.arrowDirection = .down
            configuration.arrowOffset = .init(horizontal: 0.0, vertical: -3.0)
        default:
            configuration.arrowDirection = .right
            configuration.arrowOffset = .init(horizontal: -3.0, vertical: 0.0)
        }
        switch animationSegmentedControl.selectedSegmentIndex {
        case 0:
            configuration.animationType = .fade
        case 1:
            configuration.animationType = .zoom
        default:
            configuration.animationType = .move
        }
        switch configuration.arrowDirection {
        case .up, .down:
            configuration.axis = .vertical
            configuration.itemWidth = .fixed(80.0)
            configuration.itemHeight = .fixed(35.0)
            configuration.dividerSize = .init(width: 70.0, height: 1.0)
        case .left, .right:
            configuration.axis = .horizontal
            configuration.itemWidth = .fixed(68.0)
            configuration.itemHeight = .fixed(34.0)
            configuration.dividerSize = .init(width: 1.0, height: 16.0)
        }
        let popoverView = MNPopoverView(titles: "选项一", "选项二", "选项三", configuration: configuration)
        popoverView.allowUserInteraction = true
        popoverView.popup(in: view, target: targetView, animated: true) { [weak self] index in
            guard let self = self else { return }
            self.targetView.isSelected = false
            print("点击了第 \(index + 1)个按钮")
        } completion: {
            print("已弹出")
        }
    }
    
    @IBAction func directionValueChanged(_ sender: UISegmentedControl) {
        guard view.mn.isPopoverAppearing else { return }
        view.mn.removePopoverView()
        popup()
    }
    
    @IBAction func animationValueChanged(_ sender: UISegmentedControl) {
        guard view.mn.isPopoverAppearing else { return }
        view.mn.removePopoverView()
        popup()
    }
}
