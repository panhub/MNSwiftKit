//
//  MNEditingRecognizer.swift
//  MNTest
//
//  Created by 冯盼 on 2022/8/23.
//  表格编辑手势

import UIKit

class MNEditingRecognizer: UIPanGestureRecognizer {
    
    /// 实例化拖拽手势
    /// - Parameters:
    ///   - target: 响应者
    ///   - action: 响应方法
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delegate = self
    }
}

// MARK: - UIGestureRecognizerDelegate
extension MNEditingRecognizer: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let recognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        // 判断方向
        let translation = recognizer.translation(in: recognizer.view)
        guard abs(translation.y) < abs(translation.x) else { return false }
        let velocity = recognizer.velocity(in: recognizer.view)
        guard abs(velocity.x) > 0.0 else { return false }
        return true
    }
}
