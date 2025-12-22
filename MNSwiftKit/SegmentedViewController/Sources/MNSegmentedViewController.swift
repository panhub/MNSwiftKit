//
//  MNSegmentedViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 2022/5/28.
//  分段视图控制器

import UIKit
import CoreFoundation

extension MNSegmentedViewController {
    
    /// 指示视图的尺寸
    public enum IndicatorMode {
        /// 与标题同宽
        case matchTitle(height: CGFloat)
        /// 与item同宽
        case matchItem(height: CGFloat)
        /// 使用固定值
        case fixed(width: CGFloat, height: CGFloat)
    }
    
    /// 指示视图与标题的对齐方式
    public enum IndicatorAlignment {
        /// 头部对齐
        case leading
        /// 中心对齐
        case center
        /// 尾部对齐
        case trailing
    }
    
    /// 指示视图移动样式
    public enum IndicatorTransitionStyle {
        /// 平滑移动
        case slide
        /// 拉伸
        case stretch
    }
    
    /// 分段视图内容不足时约束行为
    public enum SegmentedLayoutBehavior {
        /// 自然
        case standard
        /// 居中
        case centered
        /// 充满
        case expanded
    }
    
    /// 分割线显示选项
    public struct SeparatorVisibility: OptionSet {
        /// 显示前/左一条
        public static let leading = SeparatorVisibility(rawValue: 1 << 0)
        /// 显示后/右一条
        public static let trailing = SeparatorVisibility(rawValue: 1 << 1)
        /// 全部显示
        public static let all: SeparatorVisibility = [.leading, .trailing]
        /// 不显示
        public static let none: SeparatorVisibility = []
        
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    public class Options {
        
        
        public var indicatorMode: MNSegmentedViewController.IndicatorMode = .fixed(width: 15.0, height: 3.0)
        
        public var indicatorAlignment: MNSegmentedViewController.IndicatorAlignment = .center
        
        public var indicatorTransitionStyle: MNSegmentedViewController.IndicatorTransitionStyle = .slide
        
        public var segmentedLayoutBehavior: MNSegmentedViewController.SegmentedLayoutBehavior = .standard
        
        public var separatorVisibility: MNSegmentedViewController.SeparatorVisibility = .all
        
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
