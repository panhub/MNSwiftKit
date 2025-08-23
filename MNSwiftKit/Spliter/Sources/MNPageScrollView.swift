//
//  MNPageScrollView.swift
//  anhe
//
//  Created by 冯盼 on 2022/5/27.
//  分页滑动支持

import UIKit

open class MNPageScrollView: UIScrollView {
    
    /// 布局方向
    public var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            let numberOfPages = numberOfPages
            self.numberOfPages = numberOfPages
        }
    }
    
    /// 页数
    public var numberOfPages: Int = 0 {
        didSet {
            let currentPageIndex = currentPageIndex
            let numberOfPages = numberOfPages
            var contentSize = frame.size
            switch axis {
            case .horizontal:
                contentSize.width *= CGFloat(max(numberOfPages, 1))
            default:
                contentSize.height *= CGFloat(max(numberOfPages, 1))
            }
            self.contentSize = contentSize
            setContentOffset(contentOffset(for: max(0, min(currentPageIndex, numberOfPages - 1))), animated: false)
        }
    }
    
    /// 当前页码
    public var currentPageIndex: Int {
        get {
            var index: Int = 0
            switch axis {
            case .horizontal:
                let x = contentOffset.x
                let w = frame.width
                index = Int(round(x/w))
            default:
                let y = contentOffset.y
                let h = frame.height
                index = Int(round(y/h))
            }
            return index
        }
        set {
            setContentOffset(contentOffset(for: newValue), animated: false)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        bounces = false
        scrollsToTop = false
        isPagingEnabled = true
        contentSize = frame.size
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 偏移量
    /// - Parameter index: 页码
    /// - Returns: 横向偏移
    public func contentOffset(for index: Int) -> CGPoint {
        switch axis {
        case .horizontal:
            return CGPoint(x: frame.width*CGFloat(index), y: 0.0)
        default:
            return CGPoint(x: 0.0, y: frame.height*CGFloat(index))
        }
    }
    
    /// 设置当前页码
    /// - Parameters:
    ///   - index: 页码
    ///   - animated: 是否动态
    public func setCurrentPage(at index: Int, animated: Bool) {
        let contentOffset = contentOffset(for: index)
        setContentOffset(contentOffset, animated: animated)
    }
}
