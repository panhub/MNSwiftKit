//
//  MNAssetScrollView.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/8.
//  资源浏览器表格内容缩放视图

import UIKit

/// 资源浏览器表格内容缩放视图
class MNAssetScrollView: UIScrollView {
    
    /// 内容视图
    let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        bouncesZoom = true
        backgroundColor = .clear
        maximumZoomScale = 3.0
        alwaysBounceVertical = false
        isUserInteractionEnabled = true
        alwaysBounceHorizontal = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        
        contentView.frame = bounds
        contentView.backgroundColor = .clear
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIScrollViewDelegate
extension MNAssetScrollView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX: CGFloat = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width)/2.0 : 0.0
        let offsetY: CGFloat = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height)/2.0 : 0.0
        contentView.center = CGPoint(x: scrollView.contentSize.width/2.0 + offsetX, y: scrollView.contentSize.height/2.0 + offsetY)
    }
}
