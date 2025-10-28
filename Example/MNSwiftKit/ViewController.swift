//
//  ViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 08/22/2025.
//  Copyright (c) 2025 mellow. All rights reserved.
//  .{png,json}','MNSwiftKit/EmoticonKeyboard/Resources/default/*.{png,jpg,jpeg}

import UIKit
import MNSwiftKit
import ObjectiveC

class ViewController: UIViewController {
    
    let imageView = UIImageView()
    
    lazy var slider = MNSlider(frame: .init(x: imageView.frame.minX, y: imageView.frame.maxY + 50.0, width: 200.0, height: 50.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .red
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10.0
        imageView.image = UIImage(named: "image_1")
        imageView.frame = .init(x: 150.0, y: 150.0, width: 150.0, height: 150.0)
        view.addSubview(imageView)
        
        let error = MNPlayError.playFailed
        
        slider.minimumValue = -1.0
        slider.maximumValue = 1.0
        slider.setValueChange(handler: valueChanged(_:))
        view.addSubview(slider)
        
        
        //        print("============\(MN_SCREEN_WIDTH)============")
        //        print("============\(MN_SCREEN_HEIGHT)============")
        //        print("============\(MN_SCREEN_MAX)============")
        //        print("============\(MN_SCREEN_MIN)============")
        //        print("============\(MN_TAB_BAR_HEIGHT)============")
        //        print("============\(MN_BOTTOM_SAFE_HEIGHT)============")
        //        print("============\(MN_BOTTOM_BAR_HEIGHT)============")
        //        print("============\(MN_STATUS_BAR_HEIGHT)============")
        //        print("============\(MN_NAV_BAR_HEIGHT)============")
        //        print("============\(MN_TOP_BAR_HEIGHT)============")
        //        print("============\("md5测试".crypto.md5)============")
        //        print("============\(String.uuid)============")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touche = touches.first else { return }
        let location = touche.location(in: view)
        if imageView.frame.contains(location) {
            MNAssetBrowser.present(container: imageView, in: view)
        } else {
            //slider.setValue(0.0, animated: true)
            let options: MNAssetPickerOptions = MNAssetPickerOptions()
            options.allowsPreview = true
            options.allowsPickingAlbum = true
            options.showFileSize = true
            options.maxPickingCount = 10
            let picker = MNAssetPicker(options: options)
            picker.present { picker, assets in
                
            }
        }
    }
    
    @objc private func valueChanged(_ slider: MNSlider) {
        print(slider.value)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
