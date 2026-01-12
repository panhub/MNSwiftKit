//
//  FontViewController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2026/1/12.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class FontViewController: UIViewController {
    // 字体簇
    private var fontFamilys: [FontFamily] = []
    // 排序
    private var familyCollations: [FontFamilyCollation] = []
    // 滑动中是否允许动画
    private var allowScrollAnimation: Bool = true
    // 列表
    @IBOutlet weak var tableView: UITableView!
    // 页码指示器
    @IBOutlet weak var pageControl: MNPageControl!
    // 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    // 导航高度约束
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    // 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        pageControl.delegate = self
        pageControl.dataSource = self
        pageControl.axis = .vertical
        pageControl.contentVerticalAlignment = .center
        pageControl.contentHorizontalAlignment = .left
        pageControl.currentPageIndicatorTintColor = UIColor(hex: 0x4699D9)
        
        tableView.register(UINib(nibName: "FontTableCell", bundle: .main), forCellReuseIdentifier: "FontTableCell")
        tableView.register(FontSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "FontSectionHeaderView")
        tableView.tableFooterView = UIView(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: MN_BOTTOM_SAFE_HEIGHT)))
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // 通常已自动排序，为保证排序，这里再排序一次
            let fontFamilys = UIFont.familyNames.compactMap { FontFamily(name: $0) }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            let familyCollations = fontFamilys.reduce(into: [String:[FontFamily]]()) { partialResult, family in
                let title = String(family.name.prefix(1)).uppercased()
                partialResult[title, default: []].append(family)
            }.compactMap {
                FontFamilyCollation(title: $0.key, familys: $0.value)
            }.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.fontFamilys.append(contentsOf: fontFamilys)
                self.familyCollations.append(contentsOf: familyCollations)
                self.tableView.insertSections(IndexSet(integersIn: 0..<self.fontFamilys.count), with: .fade)
                self.pageControl.reloadPageIndicators()
            }
        }
    }

    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pageValueChanged(_ sender: MNPageControl) {
        guard sender.currentPageIndex < familyCollations.count else { return }
        let familys = familyCollations[sender.currentPageIndex].familys
        guard let first = familys.first else { return }
        guard first.fontNames.isEmpty == false else { return }
        guard let section = fontFamilys.firstIndex(where: { $0.name == first.name }) else { return }
        let sectionRect = tableView.rectForHeader(inSection: section)
        allowScrollAnimation = false
        tableView.setContentOffset(.init(x: 0.0, y: min(sectionRect.minY, tableView.contentSize.height - tableView.frame.height)), animated: false)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FontViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        fontFamilys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        fontFamilys[section].fontNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        45.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        tableView.dequeueReusableHeaderFooterView(withIdentifier: "FontSectionHeaderView")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        fontFamilys[indexPath.section].fontNames[indexPath.row].rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.dequeueReusableCell(withIdentifier: "FontTableCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FontTableCell else { return }
        cell.update(font: fontFamilys[indexPath.section].fontNames[indexPath.row], index: indexPath.row)
        guard allowScrollAnimation else { return }
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.8
        animation.toValue = 1.0
        animation.autoreverses = false
        animation.repeatCount = 1
        animation.isRemovedOnCompletion = true
        animation.mass = 0.38 // 值越大，惯性越大，振动越慢
        animation.stiffness = 180 // 值越大，弹簧越硬，回弹越快
        animation.damping = 5 // 值越大，衰减越快
        animation.duration = animation.settlingDuration
        cell.contentView.layer.removeAllAnimations()
        cell.contentView.layer.add(animation, forKey: "transform.scale")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? FontSectionHeaderView else { return }
        view.update(family: fontFamilys[section])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - UIScrollViewDelegate
extension FontViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        allowScrollAnimation = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

// MARK: - MNPageControlDataSource
extension FontViewController: MNPageControlDataSource {
    
    func numberOfPageIndicator(in pageControl: MNPageControl) -> Int {
        
        familyCollations.count
    }
    
    func pageControl(_ pageControl: MNPageControl, viewForPageIndicator index: Int) -> UIView {
        let indicator = UIView()
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .darkText
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10.0, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        indicator.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: indicator.topAnchor),
            label.leftAnchor.constraint(equalTo: indicator.leftAnchor),
            label.bottomAnchor.constraint(equalTo: indicator.bottomAnchor),
            label.rightAnchor.constraint(equalTo: indicator.rightAnchor)
        ])
        return indicator
    }
}

// MARK: - MNPageControlDelegate
extension FontViewController: MNPageControlDelegate {
    
    func pageControl(_ pageControl: MNPageControl, willDisplay indicator: UIView, forPageAt index: Int) {
        guard let label = indicator.subviews.first as? UILabel else { return }
        label.text = familyCollations[index].title
        label.textColor = index == pageControl.currentPageIndex ? .white : .darkText
    }
    
    func pageControl(_ pageControl: MNPageControl, didUpdate indicator: UIView, forPageAt index: Int) {
        guard let label = indicator.subviews.first as? UILabel else { return }
        label.textColor = index == pageControl.currentPageIndex ? .white : .darkText
    }
}
