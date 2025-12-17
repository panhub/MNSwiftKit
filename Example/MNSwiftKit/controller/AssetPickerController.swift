//
//  AssetPickerController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import PhotosUI
import MNSwiftKit

class AssetPickerController: UIViewController {
    
    private let player = MNPlayer()
    
    private let livePhotoView = PHLivePhotoView()
    
    @IBOutlet weak var pickGifSwitch: UISwitch!
    
    @IBOutlet weak var pickLivePhotoSwitch: UISwitch!
    
    @IBOutlet weak var pickPhotoSwitch: UISwitch!
    
    @IBOutlet weak var pickVideoSwitch: UISwitch!
    
    @IBOutlet weak var mixedPickSwitch: UISwitch!
    
    @IBOutlet weak var countTextField: UITextField!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var themeColorView: UIView!
    
    @IBOutlet weak var themeColorRSlider: UISlider!
    
    @IBOutlet weak var themeColorGSlider: UISlider!
    
    @IBOutlet weak var themeColorBSlider: UISlider!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var playView: MNPlayView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var backTop: NSLayoutConstraint!
    
    @IBOutlet weak var navHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navHeight.constant = MN_TOP_BAR_HEIGHT
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        themeColorRSlider.value = 72.0
        themeColorGSlider.value = 122.0
        themeColorBSlider.value = 245.0
        themeColorView.backgroundColor = UIColor(red: 72.0/255.0, green: 122.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        
        playView.isHidden = true
        playView.isTouchEnabled = false
        playView.coverView.isHidden = true
        playView.player = player.player
        
        imageView.isHidden = true
        
        livePhotoView.isHidden = true
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(livePhotoView)
        NSLayoutConstraint.activate([
            livePhotoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            livePhotoView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            livePhotoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            livePhotoView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }


    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func countUp() {
        
        let number = NSDecimalNumber(string: countTextField.text)
        let value = number.intValue
        countTextField.text = NSNumber(value: value + 1).stringValue
    }
    
    @IBAction func countDown() {
        
        let number = NSDecimalNumber(string: countTextField.text)
        let value = number.intValue
        countTextField.text = NSNumber(value: max(1, value - 1)).stringValue
    }
    
    @IBAction func durationUp() {
        
        let number = NSDecimalNumber(string: durationTextField.text)
        let value = number.intValue
        durationTextField.text = NSNumber(value: value + 1).stringValue
    }
    
    @IBAction func durationDown() {
        
        let number = NSDecimalNumber(string: durationTextField.text)
        let value = number.intValue
        durationTextField.text = NSNumber(value: max(5, value - 1)).stringValue
    }
    
    @IBAction func themeColorRValueChanged(_ sender: UISlider) {
        
        themeColorView.backgroundColor = UIColor(red: CGFloat(sender.value)/255.0, green: CGFloat(themeColorGSlider.value)/255.0, blue: CGFloat(themeColorBSlider.value)/255.0, alpha: 1.0)
    }
    
    @IBAction func themeColorGValueChanged(_ sender: UISlider) {
        
        themeColorView.backgroundColor = UIColor(red: CGFloat(themeColorRSlider.value)/255.0, green: CGFloat(sender.value)/255.0, blue: CGFloat(themeColorBSlider.value)/255.0, alpha: 1.0)
    }
    
    @IBAction func themeColorBValueChanged(_ sender: UISlider) {
        
        themeColorView.backgroundColor = UIColor(red: CGFloat(themeColorRSlider.value)/255.0, green: CGFloat(themeColorGSlider.value)/255.0, blue: CGFloat(sender.value)/255.0, alpha: 1.0)
    }
    
    @IBAction func pick() {
        let options = MNAssetPickerOptions()
        options.allowsExportLiveResource = true
        options.allowsPickingVideo = pickVideoSwitch.isOn
        options.allowsPickingPhoto = pickPhotoSwitch.isOn
        options.allowsPickingGif = pickGifSwitch.isOn
        options.allowsPickingLivePhoto = pickLivePhotoSwitch.isOn
        options.allowsMixedPicking = mixedPickSwitch.isOn
        options.maxPickingCount = NSDecimalNumber(string: countTextField.text).intValue
        options.maxExportDuration = NSDecimalNumber(string: durationTextField.text).doubleValue
        options.mode = darkModeSwitch.isOn ? .dark : .light
        options.themeColor = UIColor(red: CGFloat(themeColorRSlider.value)/255.0, green: CGFloat(themeColorGSlider.value)/255.0, blue: CGFloat(themeColorBSlider.value)/255.0, alpha: 1.0)
        let picker = MNAssetPicker(options: options)
        picker.present { [weak self] picker, assets in
            guard let self = self else { return }
            if let asset = assets.first {
                self.update(asset: asset)
            }
        } cancelHandler: { picker in
            print("资源选择器取消")
        }
    }
    
    private func update(asset: MNAsset) {
        guard let contents = asset.contents else { return }
        switch asset.type {
        case .photo, .gif:
            imageView.image = contents as? UIImage
            imageView.isHidden = false
            player.removeAll()
            playView.isHidden = true
            livePhotoView.livePhoto = nil
            livePhotoView.isHidden = true
        case .livePhoto:
            player.removeAll()
            playView.isHidden = true
            imageView.image = nil
            imageView.isHidden = true
            livePhotoView.livePhoto = contents as? PHLivePhoto
            livePhotoView.isHidden = false
        case .video:
            playView.isHidden = false
            player.removeAll()
            player.append(urls: [URL(fileAtPath: contents as! String)])
            player.play()
            imageView.image = nil
            imageView.isHidden = true
            livePhotoView.livePhoto = nil
            livePhotoView.isHidden = true
        }
    }
}
