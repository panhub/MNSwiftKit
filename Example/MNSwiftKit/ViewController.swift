//
//  ViewController.swift
//  MNSwiftKit
//
//  Created by panhub on 08/22/2025.
//  Copyright (c) 2025 mellow. All rights reserved.
//  .{png,json}','MNSwiftKit/EmoticonKeyboard/Resources/default/*.{png,jpg,jpeg}

import UIKit
import MNSwiftKit

class ViewController: UIViewController {
    
    lazy var textView = UITextView(frame: .init(x: 40.0, y: 100.0, width: view.frame.width - 80.0, height: 200.0))
    
    let label = UILabel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = .white
        
        //textView.font = .systemFont(ofSize: 18.0, weight: .regular)
        textView.clipsToBounds = true
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 10.0
        view.addSubview(textView)
        
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 150.0, weight: .regular)
        label.frame = .init(x: textView.frame.minX, y: textView.frame.maxY + 20.0, width: 50.0, height: 50.0)
        view.addSubview(label)
        label.text = "\u{1F697}"
        
//        let options = MNEmoticonKeyboard.Options()
//        options.returnKeyType = .done
//        options.hidesForSingle = true
//        options.packets = [MNEmoticon.Packet.Name.wechat.rawValue, MNEmoticon.Packet.Name.emotion.rawValue, MNEmoticon.Packet.Name.food.rawValue, MNEmoticon.Packet.Name.symbol.rawValue, MNEmoticon.Packet.Name.animal.rawValue, MNEmoticon.Packet.Name.vehicle.rawValue]
//        let emoticonKeyboard = MNEmoticonKeyboard(frame: .init(origin: .zero, size: .init(width: MN_SCREEN_WIDTH, height: 300.0 + MN_BOTTOM_SAFE_HEIGHT)), style: .paging, options: options)
//        emoticonKeyboard.delegate = self
//        textView.inputView = emoticonKeyboard
        
        
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
        textView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//extension ViewController: MNEmoticonKeyboardDelegate {
//    
//    func emoticonKeyboardShouldInput(emoticon: MNEmoticon) {
//        textView.mn.input(emoticon: emoticon)
//    }
//    
//    func emoticonKeyboardReturnButtonTouchUpInside(_ keyboard: MNSwiftKit.MNEmoticonKeyboard) {
//        
//        textView.resignFirstResponder()
//    }
//    
//    func emoticonKeyboardDeleteButtonTouchUpInside(_ keyboard: MNSwiftKit.MNEmoticonKeyboard) {
//        textView.deleteBackward()
//    }
//}
