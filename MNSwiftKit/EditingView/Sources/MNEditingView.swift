//
//  MNEditingView.swift
//  MNTest
//
//  Created by 冯盼 on 2022/8/22.
//  表格编辑视图

import UIKit
import CoreFoundation

protocol MNEditingViewDelegate: NSObjectProtocol {
    
    /// 按钮第一次点击事件 可选择提交二次视图
    /// - Parameters:
    ///   - editingView: 编辑视图
    ///   - action: 按钮
    ///   - index: 按钮索引
    func editingView(_ editingView: MNEditingView, actionButtonTouchUpInside action: UIView, index: Int) -> Void
}

/// 定义编辑触发方向
public enum MNEditingDirection: Int {
    /// 向左滑动以触发编辑
    case left
    // 向右滑动以触发编辑
    case right
}

private class MNEditingAction: UIControl {}

/// 集合视图表格的编辑视图
class MNEditingView: UIView {
    
    /// 配置信息
    let options: MNEditingOptions
    
    /// 当前的拖拽方向
    private(set) var direction: MNEditingDirection = .left
    
    /// 事件代理
    weak var delegate: MNEditingViewDelegate?
    
    /// 是否在动画/拖拽中
    var isAnimating: Bool = false
    
    /// 当前按钮的总宽度
    var constant: CGFloat = 0.0
    
    /// 依据配置信息构造
    /// - Parameter options: 配置信息
    init(options: MNEditingOptions) {
        self.options = options
        super.init(frame: .zero)
        clipsToBounds = true
        layer.cornerRadius = options.cornerRadius
        backgroundColor = options.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 添加至父视图时 决定自身高度
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }
        var rect = superview.bounds
        switch direction {
        case .left:
            rect.origin.x = rect.width - options.contentInset.right
        case .right:
            rect.origin.x = options.contentInset.left
        }
        rect.size.width = 0.0
        rect.origin.y = options.contentInset.top
        rect.size.height = max(0.0, rect.height - options.contentInset.top - options.contentInset.bottom)
        autoresizingMask = []
        frame = rect
        autoresizingMask = [.flexibleHeight]
    }
    
    /// 更新编辑方向
    /// - Parameter direction: 指定方向
    func update(direction: MNEditingDirection) {
        if self.direction == direction { return }
        self.direction = direction
        // 更新位置
        if let superview = superview {
            var rect = frame
            switch direction {
            case .left:
                rect.origin.x = superview.frame.width - rect.width - options.contentInset.right
            case .right:
                rect.origin.x = options.contentInset.left
            }
            autoresizingMask = []
            frame = rect
            autoresizingMask = [.flexibleHeight]
        }
        // 更新子视图
        for subview in subviews.filter ({ $0.isHidden == false }) {
            guard let action = subview.subviews.first else { continue }
            var rect = action.frame
            var autoresizingMask: UIView.AutoresizingMask = []
            if direction == .left {
                rect.origin.x = 0.0
                autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
            } else {
                rect.origin.x = subview.frame.width - rect.width
                autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
            }
            action.autoresizingMask = []
            action.frame = rect
            action.autoresizingMask = autoresizingMask
        }
    }
    
    /// 更新编辑视图(往编辑视图上添加子视图)
    /// - Parameter subviews: 子视图集合
    func update(actions: [UIView]) {
        // 先隐藏旧视图
        for subview in subviews {
            subview.isHidden = true
            for view in subview.subviews.reversed() {
                view.removeFromSuperview()
            }
        }
        // 更新宽度
        constant = actions.reduce(0.0, { $0 + $1.frame.width })
        assert(constant > 0.0, "actions width 0.0 not allowed.")
        // 添加子视图
        let subviews: [UIView] = subviews
        for (index, action) in actions.enumerated() {
            var control: MNEditingAction
            if index < subviews.count {
                control = subviews[index] as! MNEditingAction
                control.isHidden = false
                control.autoresizingMask = []
                bringSubviewToFront(control)
            } else {
                control = MNEditingAction()
                control.tag = index
                control.clipsToBounds = true
                control.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
                addSubview(control)
            }
            control.frame = CGRect(x: 0.0, y: 0.0, width: action.frame.width, height: frame.height)
            control.backgroundColor = action.backgroundColor
            control.autoresizingMask = .flexibleHeight
            action.autoresizingMask = []
            action.removeConstraints(action.constraints)
            action.translatesAutoresizingMaskIntoConstraints = true
            action.center = CGPoint(x: control.bounds.midX, y: control.bounds.midY)
            if options.usingInnerInteraction {
                action.isUserInteractionEnabled = false
            }
            switch direction {
            case .left:
                action.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
            case .right:
                action.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
            }
            control.addSubview(action)
        }
        // 更新宽度
        update(width: frame.width)
    }
    
    /// 更新编辑视图的宽度
    /// - Parameter width: 指定宽度
    func update(width: CGFloat) {
        var x: CGFloat = 0.0
        for subview in subviews.filter ({ $0.isHidden == false }) {
            guard let action = subview.subviews.first else { continue }
            let scale = action.frame.width/constant
            var rect = subview.frame
            rect.origin.x = x
            rect.size.width = min(ceil(width*scale), width - x)
            subview.frame = rect
            x += rect.width
        }
    }
    
    /// 替换新视图
    /// - Parameters:
    ///   - action: 新的视图
    ///   - index: 索引
    func replaceAction(with action: UIView, at index: Int) {
        guard let subview = subviews.first(where: { $0.tag == index }) else { return }
        constant = action.frame.width
        for view in subview.subviews.reversed() {
            view.removeFromSuperview()
        }
        subview.backgroundColor = action.backgroundColor
        var rect = action.frame
        rect.origin.x = 0.0
        rect.origin.y = (subview.frame.height - rect.height)/2.0
        action.autoresizingMask = []
        action.removeConstraints(action.constraints)
        action.translatesAutoresizingMaskIntoConstraints = true
        action.frame = rect
        if options.usingInnerInteraction {
            action.isUserInteractionEnabled = false
        }
        subview.addSubview(action)
        bringSubviewToFront(subview)
        isAnimating = true
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: [.beginFromCurrentState, .curveEaseInOut]) { [weak self] in
            guard let self = self else { return }
            var rect = subview.frame
            rect.origin = .zero
            rect.size.width = action.frame.width
            subview.frame = rect
            action.center = CGPoint(x: subview.bounds.midX, y: subview.bounds.midY)
            rect = self.frame
            rect.size.width = subview.frame.width
            if self.direction == .left , let superview = self.superview {
                let spacing = self.options.contentInset.right
                rect.origin.x = superview.frame.width - rect.width - spacing
            }
            self.frame = rect
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.isAnimating = false
            switch self.direction {
            case .left:
                action.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
            case .right:
                action.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
            }
            for subview in self.subviews.filter ({ ($0.isHidden == false && $0.tag != index) }) {
                subview.isHidden = true
                for view in subview.subviews.reversed() {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    /// 按钮点击事件
    /// - Parameter sender: 按钮
    @objc private func buttonTouchUpInside(_ sender: MNEditingAction) {
        guard isAnimating == false else { return }
        guard let delegate = delegate else { return }
        guard let action = sender.subviews.first else { return }
        delegate.editingView(self, actionButtonTouchUpInside: action, index: sender.tag)
    }
}
