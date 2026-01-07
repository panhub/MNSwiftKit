//
//  RequestViewController.swift
//  MNSwiftKit_Example
//
//  Created by 冯盼 on 2026/1/7.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import MNSwiftKit

class RequestViewController: UIViewController {
    // 播放视频
    private let player = MNPlayer()
    /// 下载进度轨迹视图
    @IBOutlet weak var trackView: UIView!
    /// 播放视图
    @IBOutlet weak var playView: MNPlayView!
    /// 请求结果展示
    @IBOutlet weak var resultView: UITextView!
    /// 下载信息提示
    @IBOutlet weak var downloadLabel: UILabel!
    /// 返回按钮顶部约束
    @IBOutlet weak var backTop: NSLayoutConstraint!
    /// 返回按钮高度约束
    @IBOutlet weak var backHeight: NSLayoutConstraint!
    /// 下载进度控制
    @IBOutlet weak var progressWidth: NSLayoutConstraint!
    /// 暂停的数据
    private var resumeData: Data?
    /// 记录下载请求
    private let downloadRequest = HTTPDownloadRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        backTop.constant = (MN_NAV_BAR_HEIGHT - backHeight.constant)/2.0 + MN_STATUS_BAR_HEIGHT
        
        resultView.isHidden = true
        resultView.textContainerInset = .zero
        resultView.textContainer.lineFragmentPadding = 0.0
        
        playView.isHidden = true
        playView.isTouchEnabled = false
        playView.coverView.isHidden = true
        playView.player = player.player
    }
    

    @IBAction func back() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func get(_ sender: UIButton) {
        player.removeAll()
        playView.isHidden = true
        resultView.isHidden = true
        let request = HTTPDataRequest(url: "https://jsonplaceholder.typicode.com/posts")
        request.method = .get
        request.contentType = .json
        request.start {
            MNToast.showActivity("请稍后...", style: .large, at: .center)
        } completion: { [weak self] result in
            if result.code == .succeed {
                MNToast.close()
                guard let self = self else { return }
                guard self.playView.isHidden else { return }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result.data!, options: .prettyPrinted)
                    self.resultView.text = String(data: jsonData, encoding: .utf8)
                    self.resultView.isHidden = false
                } catch {
                    MNToast.showMsg(error.localizedDescription)
                }
            } else {
                MNToast.showMsg(result.msg)
            }
        }
    }
    
    @IBAction func post(_ sender: UIButton) {
        player.removeAll()
        playView.isHidden = true
        resultView.isHidden = true
        let request = HTTPDataRequest(url: "https://httpbin.org/post")
        request.method = .post
        request.contentType = .json
        request.body = ["text":"测试Post请求"]
        request.start {
            MNToast.showActivity("请稍后...", style: .large, at: .center)
        } completion: { [weak self] result in
            if result.code == .succeed {
                MNToast.close()
                guard let self = self else { return }
                guard self.playView.isHidden else { return }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result.data!, options: .prettyPrinted)
                    self.resultView.text = String(data: jsonData, encoding: .utf8)
                    self.resultView.isHidden = false
                } catch {
                    MNToast.showMsg(error.localizedDescription)
                }
            } else {
                MNToast.showMsg(result.msg)
            }
        }
    }
    
    @IBAction func download(_ sender: UIButton) {
        if let _ = downloadRequest.resumeData {
            downloadRequest.resume { [weak self] isSuccess in
                guard let self = self else { return }
                if isSuccess {
                    self.downloadLabel.text = "正在下载"
                } else {
                    self.downloadLabel.text = "重启下载失败"
                }
            }
            return
        }
        if downloadRequest.isRunning {
            downloadRequest.suspend { [weak self] resumeData in
                guard let self = self else { return }
                if let _ = resumeData {
                    self.downloadLabel.text = "已暂停"
                }
            }
            return
        }
        player.removeAll()
        playView.isHidden = true
        resultView.isHidden = true
        let url = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"
        downloadRequest.url = url
        downloadRequest.downloadOptions = [.createIntermediateDirectories, .removeExistsFile]
        let downloadPath: String = .mn.caches(appending: url.mn.lastPathComponent)
        downloadRequest.start { [weak self] in
            guard let self = self else { return }
            self.downloadLabel.text = "正在下载"
        } location: { response, url in
            return URL(fileAtPath: downloadPath)
        } progress: { [weak self] progress in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.progressWidth.constant = self.trackView.frame.width*progress.fractionCompleted
            }
        } completion: { [weak self] result in
            guard let self = self else { return }
            if result.code == .succeed {
                self.downloadLabel.text = "下载完成"
                guard self.resultView.isHidden else { return }
                self.playView.isHidden = false
                self.player.append(URL(fileAtPath: downloadPath))
                self.player.play()
            } else {
                self.downloadLabel.text = result.msg
            }
        }
    }
}
