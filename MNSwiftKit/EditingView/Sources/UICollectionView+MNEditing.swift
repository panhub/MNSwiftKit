//
//  UICollectionView+MNEditing.swift
//  MNTest
//
//  Created by 冯盼 on 2022/8/26.
//

import UIKit
import Foundation
import CoreFoundation
import ObjectiveC.runtime

public protocol UICollectionViewEditingDelegate {
    
    /// 提交表格的编辑方向
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - indexPath: 索引
    /// - Returns: 编辑方向
    func collectionView(_ collectionView: UICollectionView, editingDirectionsForItemAt indexPath: IndexPath) -> [MNEditingDirection]
    
    /// 提交编辑视图
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - indexPath: 索引
    ///   - direction: 拖拽方向
    /// - Returns: 编辑视图
    func collectionView(_ collectionView: UICollectionView, editingActionsForItemAt indexPath: IndexPath, direction: MNEditingDirection) -> [UIView]
    
    /// 提交二次编辑视图
    /// - Parameters:
    ///   - collectionView: 集合视图
    ///   - action: 点击的按钮
    ///   - indexPath: 索引
    ///   - direction: 拖拽方向
    /// - Returns: 二次编辑视图
    func collectionView(_ collectionView: UICollectionView, commitEditing action: UIView, forItemAt indexPath: IndexPath, direction: MNEditingDirection) -> UIView?
}

extension UICollectionView {
    
    fileprivate struct MNEditingAssociated {
        // 是否处于编辑状态
        static var editing = "com.mn.collection.view.editing"
        // 编辑配置
        static var options = "com.mn.collection.view.editing.options"
        // 事件监听者
        static var observer = "com.mn.collection.view.editing.observer"
    }
}

extension MNNameSpaceWrapper where Base: UICollectionView {
    
    /// 是否有表格处于编辑状态
    fileprivate var isEditing: Bool {
        get { objc_getAssociatedObject(base, &UICollectionView.MNEditingAssociated.editing) as? Bool ?? false }
        set { objc_setAssociatedObject(base, &UICollectionView.MNEditingAssociated.editing, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    /// 编辑视图的配置
    public var editingOptions: MNEditingOptions {
        if let options = objc_getAssociatedObject(base, &UICollectionView.MNEditingAssociated.options) as? MNEditingOptions { return options }
        if objc_getAssociatedObject(base, &UICollectionView.MNEditingAssociated.observer) == nil {
            let observer = MNEditingObserver(scrollView: base)
            observer.delegate = base
            objc_setAssociatedObject(base, &UICollectionView.MNEditingAssociated.observer, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        let options = MNEditingOptions()
        objc_setAssociatedObject(base, &UICollectionView.MNEditingAssociated.options, options, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return options
    }
    
    /// 结束编辑
    /// - Parameter animated: 是否动态显示过程
    public func endEditing(animated: Bool) {
        guard isEditing else { return }
        isEditing = false
        for cell in base.subviews.compactMap({ $0 as? UICollectionViewCell }) {
            cell.mn.endEditing(animated: animated)
        }
    }
}

// MARK: - MNEditingObserverHandler
extension UICollectionView: MNEditingObserverHandler {
    
    func scrollView(_ scrollView: UIScrollView, contentSize change: [NSKeyValueChangeKey : Any]?) {
        mn.endEditing(animated: false)
    }
    
    func scrollView(_ scrollView: UIScrollView, contentOffset change: [NSKeyValueChangeKey : Any]?) {
        mn.endEditing(animated: (scrollView.isDragging || scrollView.isDecelerating))
    }
}

extension UICollectionViewCell {
    
    fileprivate struct MNEditingAssociated {
        // 内容视图位置
        static var contentX = "com.mn.collection.view.cell.content.view.x"
        // 编辑视图
        static var editingView = "com.mn.collection.view.cell.editing.view"
        // 是否允许编辑
        static var allowsEditing = "com.mn.collection.view.cell.allows.editing"
    }
}

// MARK: - 开启表格编辑
extension MNNameSpaceWrapper where Base: UICollectionViewCell {
    
    /// 编辑开始时的x
    fileprivate var contentViewX: CGFloat {
        get { objc_getAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.contentX) as? CGFloat ?? 0.0 }
        set { objc_setAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.contentX, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    
    /// 编辑视图
    fileprivate var editingView: MNEditingView? {
        get { objc_getAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.editingView) as? MNEditingView }
        set { objc_setAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.editingView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 是否处于编辑状态
    fileprivate var isEditing: Bool {
        guard let editingView = editingView, editingView.frame.width > 0.0 else { return false }
        return true
    }
    
    /// 是否允许编辑
    public var allowsEditing: Bool {
        get { (objc_getAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.allowsEditing) as? Bool) ?? false }
        set {
            if allowsEditing == newValue { return }
            objc_setAssociatedObject(base, &UICollectionViewCell.MNEditingAssociated.allowsEditing, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if newValue {
                let pan = MNEditingRecognizer(target: base, action: #selector(base.mn_handleItemEditing(_:)))
                base.contentView.addGestureRecognizer(pan)
            } else {
                guard let gestureRecognizers = base.contentView.gestureRecognizers else { return }
                for recognizer in gestureRecognizers.filter ({ $0 is MNEditingRecognizer }) {
                    recognizer.removeTarget(nil, action: nil)
                    base.contentView.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
    
    /// 结束编辑状态
    /// - Parameter animated: 是否动态显示过程
    public func endEditing(animated: Bool) {
        guard isEditing else { return }
        updateEditing(false, animated: animated)
    }
    
    /// 约束编辑视图
    public func layoutEditingView() {
        guard let editingView = editingView, editingView.frame.width > 0.0 else { return }
        var rect = base.contentView.frame
        rect.origin.x = contentViewX
        if editingView.direction == .left {
            rect.origin.x -= editingView.frame.width
        } else {
            rect.origin.x += editingView.frame.width
        }
        base.contentView.frame = rect
    }
}

// MARK: - 寻找集合视图
extension MNNameSpaceWrapper where Base: UICollectionViewCell {
    
    /// 所在集合视图的索引
    public var indexPath: IndexPath? {
        guard let collectionView = collectionView else { return nil }
        return collectionView.indexPath(for: base)
    }
    
    /// 在响应链上寻找集合视图
    public var collectionView: UICollectionView? {
        var next = base.next
        while let responder = next {
            if responder is UICollectionView { return responder as? UICollectionView }
            next = responder.next
        }
        return nil
    }
    
    /// 更新编辑状态
    /// - Parameters:
    ///   - editing: 是否开启编辑
    ///   - animated: 是否显示动画过程
    fileprivate func updateEditing(_ editing: Bool, animated: Bool) {
        collectionView?.mn.isEditing = editing
        guard let editingView = editingView else { return }
        base.willBeginUpdateEditing(editing, animated: animated)
        if animated {
            editingView.isAnimating = true
            let completionHandler: (Bool)->Void = { [weak self] _ in
                guard let self = self else { return }
                editingView.isAnimating = false
                self.base.didEndUpdateEditing(editing, animated: animated)
            }
            if editing {
                UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.update(editing: true)
                }, completion: completionHandler)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState, .curveEaseInOut], animations: { [weak self] in
                    guard let self = self else { return }
                    self.update(editing: false)
                }, completion: completionHandler)
            }
        } else {
            update(editing: editing)
            base.didEndUpdateEditing(editing, animated: animated)
        }
    }
    
    /// 更新编辑状态
    /// - Parameter editing: 是否编辑
    fileprivate func update(editing: Bool) {
        guard let editingView = editingView else { return }
        var rect = editingView.frame
        if editing {
            rect.size.width = editingView.constant
        } else {
            rect.size.width = 0.0
        }
        if editingView.direction == .left, let collectionView = collectionView {
            let spacing = collectionView.mn.editingOptions.contentInset.right
            rect.origin.x = base.frame.width - rect.width - spacing
        }
        editingView.frame = rect
        editingView.update(width: rect.width)
        base.setNeedsLayout()
        base.layoutIfNeeded()
    }
}

// MARK: - 拖拽处理
extension UICollectionViewCell {
    
    /// 处理拖拽手势
    /// - Parameter recognizer: 手势
    @objc fileprivate func mn_handleItemEditing(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            guard let collectionView = mn.collectionView else { break }
            var editingView: MNEditingView! = mn.editingView
            let velocity = recognizer.velocity(in: recognizer.view)
            if editingView == nil || editingView.frame.width <= 0.0 {
                // 依据方向更新视图
                guard let indexPath = collectionView.indexPath(for: self) else { break }
                guard let delegate = collectionView.dataSource as? UICollectionViewEditingDelegate else { break }
                let direction: MNEditingDirection = velocity.x > 0.0 ? .right : .left
                let directions = delegate.collectionView(collectionView, editingDirectionsForItemAt: indexPath)
                guard directions.contains(direction) else { break }
                let actions = delegate.collectionView(collectionView, editingActionsForItemAt: indexPath, direction: direction)
                guard actions.isEmpty == false else { break }
                collectionView.mn.endEditing(animated: true)
                if editingView == nil {
                    editingView = MNEditingView(options: collectionView.mn.editingOptions)
                    editingView.delegate = self
                    insertSubview(editingView, belowSubview: contentView)
                    mn.editingView = editingView
                    mn.contentViewX = contentView.frame.minX
                }
                editingView.update(direction: direction)
                editingView.update(actions: actions)
            }
            let translation = recognizer.translation(in: recognizer.view)
            recognizer.setTranslation(.zero, in: recognizer.view)
            var rect = editingView.frame
            var m: CGFloat = translation.x
            if rect.width >= editingView.constant {
                // 超过最优距离, 加阻尼, 减缓拖拽效果
                m = m/3.0*2.0
            }
            switch editingView.direction {
            case .left:
                let spacing = collectionView.mn.editingOptions.contentInset.right
                rect.size.width = max(0.0, floor(rect.width - m))
                rect.origin.x = frame.width - rect.width - spacing
            case .right:
                rect.size.width = max(0.0, floor(rect.width + m))
            }
            editingView.frame = rect
            editingView.update(width: rect.width)
            setNeedsLayout()
            layoutIfNeeded()
        case .ended:
            guard let editingView = mn.editingView else { break }
            let constant = editingView.constant
            let velocity = recognizer.velocity(in: recognizer.view)
            if editingView.frame.width <= 0.0 {
                mn.collectionView?.mn.isEditing = false
            } else if editingView.frame.width == constant {
                mn.collectionView?.mn.isEditing = true
            } else if editingView.frame.width > constant || (editingView.frame.width >= 40.0 && ((editingView.direction == .left && velocity.x < 0.0) || (editingView.direction == .right && velocity.x > 0.0))) {
                mn.updateEditing(true, animated: true)
            } else {
                // 结束编辑
                mn.updateEditing(false, animated: true)
            }
        default: break
        }
    }
}

// MARK: - MNEditingViewDelegate
extension UICollectionViewCell: MNEditingViewDelegate {
    
    func editingView(_ editingView: MNEditingView, actionButtonTouchUpInside action: UIView, index: Int) {
        guard let collectionView = mn.collectionView else { return }
        guard let indexPath = collectionView.indexPath(for: self) else { return }
        guard let delegate = collectionView.dataSource as? UICollectionViewEditingDelegate else { return }
        guard let newAction = delegate.collectionView(collectionView, commitEditing: action, forItemAt: indexPath, direction: editingView.direction) else { return }
        editingView.replaceAction(with: newAction, at: index)
    }
}

// MARK: -
@objc extension UICollectionViewCell {
    
    /// 即将更新编辑状态
    /// - Parameters:
    ///   - editing: 指定编辑状态
    ///   - animated: 是否显示动画过程
    @objc func willBeginUpdateEditing(_ editing: Bool, animated: Bool) {}
    
    /// 更新编辑状态结束
    /// - Parameters:
    ///   - editing: 编辑状态
    ///   - animated: 是否显示动画过程
    @objc func didEndUpdateEditing(_ editing: Bool, animated: Bool) {}
}
