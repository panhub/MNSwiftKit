//
//  MNAssetPickerFooter.swift
//  MNSwiftKit
//
//  Created by 元气绘画 on 2023/11/29.
//

import UIKit
//#if canImport(MNSwiftKitRefresh)
//import MNSwiftKitRefresh
//#endif

class MNAssetPickerFooter: MNRefreshStateFooter {
    
    override func didChangeState(from oldState: MNRefreshComponent.State, to state: MNRefreshComponent.State) {
        super.didChangeState(from: oldState, to: state)
        textLabel.isHidden = true
    }
}
