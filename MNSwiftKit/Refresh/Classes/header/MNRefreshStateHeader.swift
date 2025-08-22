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
    
    open override func initialized() {
        super.initialized()
        addSubview(indicatorView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        var center = CGPoint(x: bounds.width/2.0, y: bounds.height/2.0)
        if style == .large {
            center.y =  (frame.height - MN_STATUS_BAR_HEIGHT)/2.0 + MN_STATUS_BAR_HEIGHT
        }
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
