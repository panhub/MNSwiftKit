//
//  PageControlController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/11.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class PageControlController: UIViewController {
    /// 滑动视图
    @IBOutlet weak var scrollView: UIScrollView!
    /// 页码
    @IBOutlet weak var pageControl: MNPageControl!
    /// 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    /// 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pageValueChanged(_ sender: MNPageControl) {
        
        var contentOffset = scrollView.contentOffset
        contentOffset.x = scrollView.frame.width*CGFloat(sender.currentPageIndex)
        scrollView.setContentOffset(contentOffset, animated: false)
    }
}

extension PageControlController: UIScrollViewDelegate {
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let contentOffset = targetContentOffset.pointee
        let index = Int(round(contentOffset.x/scrollView.frame.width))
        pageControl.currentPageIndex = index
    }
}
