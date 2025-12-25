//
//  TestViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/22.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class TestViewController: UIViewController {
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航高度约束
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal
    )

    private lazy var coordinator = MNSegmentedCoordinator(
        pageViewController: pageViewController,
        items: [
            .init(id: "A"),
            .init(id: "B"),
            .init(id: "C"),
            .init(id: "D"),
            .init(id: "E")
        ],
        factory: { MNPageContentViewController(item: $0) }
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: navHeight.constant + 50.0),
            pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        coordinator.onPageChanged = { [weak self] index in
            guard let self = self else { return }
            self.segmentedControl.selectedSegmentIndex = index
        }

        coordinator.onScrollProgress = { index, progress in
            //print("Scroll progress:", index, progress)
        }

        coordinator.setInitialIndex(2)
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        
        coordinator.select(index: sender.selectedSegmentIndex, animated: true)
    }
}
