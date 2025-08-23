//
//  MNRefreshStateHeader.swift
//  MNKit
//
//  Created by 冯盼 on 2021/8/19.
//  默认下拉刷新控件

import UIKit

open class MNRefreshStateHeader: MNRefreshHeader {
    // 指示图层
    open override var color: UIColor {
        didSet {
            indicatorView.color = color
        }
    }
    open private(set) lazy var indicatorView: UIActivityIndicatorView = {
        var style: UIActivityIndicatorView.Style!
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .gray
        }
        let indicatorView = UIActivityIndicatorView(style: style)
        indicatorView.color = color
        indicatorView.hidesWhenStopped = false
        indicatorView.stopAnimating()
        return indicatorView
    }()
    
    open override func commonInit() {
        super.commonInit()
        addSubview(indicatorView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let rect = bounds.inset(by: contentInset)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        indicatorView.center = center
    }
    
    open override func headerViewDidDragging(_ percent: CGFloat) {
        let angle = CGFloat.pi/180.0*360.0*percent
        indicatorView.transform = CGAffineTransform(rotationAngle: angle)
    }
    
    open override func didChangeState(from oldState: MNRefreshComponent.State, to state: MNRefreshComponent.State) {
        if state == .refreshing {
            indicatorView.startAnimating()
        } else {
            indicatorView.stopAnimating()
        }
        indicatorView.isHidden = state == .noMoreData
        super.didChangeState(from: oldState, to: state)
    }
}
