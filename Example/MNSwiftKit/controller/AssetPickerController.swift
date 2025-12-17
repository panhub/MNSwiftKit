//
//  AssetPickerController.swift
//  MNSwiftKit_Example
//
//  Created by mellow on 2025/12/15.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class AssetPickerController: UIViewController {
    
    @IBOutlet weak var pickGifSwitch: UISwitch!
    
    @IBOutlet weak var pickLivePhotoSwitch: UISwitch!
    
    @IBOutlet weak var pickPhotoSwitch: UISwitch!
    
    @IBOutlet weak var pickVideoSwitch: UISwitch!
    
    @IBOutlet weak var mixedPickSwitch: UISwitch!
    
    @IBOutlet weak var countTextField: UITextField!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var themeColorView: UIView!
    
    @IBOutlet weak var themeColorRSlider: UISlider!
    
    @IBOutlet weak var themeColorGSlider: UISlider!
    
    @IBOutlet weak var themeColorBSlider: UISlider!
    
    @IBOutlet weak var tintColorView: UIView!
    
    @IBOutlet weak var tintColorRSlider: UISlider!
    
    @IBOutlet weak var tintColorGSlider: UISlider!
    
    @IBOutlet weak var tintColorBSlider: UISlider!
    
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
        
        tintColorRSlider.value = 0.0
        tintColorGSlider.value = 0.0
        tintColorBSlider.value = 0.0
        tintColorView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
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
    
    @IBAction func tintColorRValueChanged(_ sender: UISlider) {
        
        tintColorView.backgroundColor = UIColor(red: CGFloat(sender.value)/255.0, green: CGFloat(tintColorGSlider.value)/255.0, blue: CGFloat(tintColorBSlider.value)/255.0, alpha: 1.0)
    }
    
    @IBAction func tintColorGValueChanged(_ sender: UISlider) {
        
        tintColorView.backgroundColor = UIColor(red: CGFloat(tintColorRSlider.value)/255.0, green: CGFloat(sender.value)/255.0, blue: CGFloat(tintColorBSlider.value)/255.0, alpha: 1.0)
    }
    
    @IBAction func tintColorBValueChanged(_ sender: UISlider) {
        
        tintColorView.backgroundColor = UIColor(red: CGFloat(tintColorRSlider.value)/255.0, green: CGFloat(tintColorGSlider.value)/255.0, blue: CGFloat(sender.value)/255.0, alpha: 1.0)
    }
    
    @IBAction func pick() {
        
    }
}
