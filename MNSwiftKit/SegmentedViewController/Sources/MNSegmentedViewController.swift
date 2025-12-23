//
//  MNSegmentedViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//  分段视图控制器

import UIKit
import CoreFoundation

extension MNSegmentedViewController {
    
    /// 指示视图尺寸模式
    public enum SizeMode {
        /// 与标题同宽
        case matchTitle(height: CGFloat)
        /// 与item同宽
        case matchItem(height: CGFloat)
        /// 使用固定值
        case fixed(width: CGFloat, height: CGFloat)
    }
    
    
    
    
    
    
    
    public class Options {
        
        
        
        
        
        
        
        /// 标题项选中时transform动画缩放因数
        /// 不能小于1.0
        public var highlightedScale: CGFloat = 1.0
        /// 转场动画时长
        public var transitionDuration: TimeInterval = 0.3
    }
}

public class MNSegmentedViewController: UIViewController {
    
    // 方向
    public var orientation = UIPageViewController.NavigationOrientation.horizontal

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
