//
//  MNRefreshStateFooter.swift
//  MNKit
//
//  Created by 冯盼 on 2021/9/24.
//  默认加载更多控件

import UIKit

open class MNRefreshStateFooter: MNRefreshFooter {
    // 修改颜色
    override open var color: UIColor {
        didSet {
            textLabel.textColor = color
            indicatorView.color = color
        }
    }
    // 文字提示
    open private(set) lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.isHidden = true
        textLabel.numberOfLines = 1
        textLabel.textAlignment = .center
        textLabel.textColor = color
        textLabel.text = "暂无更多数据"
        textLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        textLabel.sizeToFit()
        return textLabel
    }()
    // 指示图
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
        addSubview(textLabel)
        addSubview(indicatorView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if style == .large {
            textLabel.center = CGPoint(x: frame.width/2.0, y: frame.height - MN_BOTTOM_SAFE_HEIGHT - textLabel.height/2.0)
            indicatorView.center = CGPoint(x: frame.width/2.0, y: frame.height - MN_BOTTOM_SAFE_HEIGHT - indicatorView.height/2.0)
        } else {
            textLabel.center = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
            indicatorView.center = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
        }
    }
    
    open override func footerViewDidDragging(_ percent: CGFloat) {
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
        textLabel.isHidden = indicatorView.isHidden == false
        super.didChangeState(from: oldState, to: state)
    }
}
