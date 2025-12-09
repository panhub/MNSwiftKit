//
//  MNAssetScrollView.swift
//  MNSwiftKit
//
//  Created by panhub on 2021/10/8.
//  资源浏览器表格内容缩放视图

import UIKit
import Photos
import PhotosUI

/// 资源浏览器表格内容缩放视图
public class MNAssetScrollView: UIScrollView {
    /// 内容视图
    public let contentView = UIView()
    /// 播放视频
    let playView = MNPlayView()
    /// 展示图片
    let imageView = UIImageView()
    /// LivePhoto标记
    var liveBadgeView: UIImageView!
    /// 展示LivePhoto
    lazy var livePhotoView: UIView? = {
        guard #available(iOS 9.1, *) else { return nil }
        let livePhotoView = PHLivePhotoView()
        livePhotoView.clipsToBounds = true
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.delegate = self
        return livePhotoView
    }()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        bouncesZoom = true
        backgroundColor = .clear
        maximumZoomScale = 3.0
        alwaysBounceVertical = false
        isUserInteractionEnabled = true
        alwaysBounceHorizontal = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        
        contentView.backgroundColor = .clear
        addSubview(contentView)
        
        playView.backgroundColor = .clear
        playView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playView)
        NSLayoutConstraint.activate([
            playView.topAnchor.constraint(equalTo: contentView.topAnchor),
            playView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            playView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            playView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        if #available(iOS 9.1, *), let livePhotoView = livePhotoView {
            livePhotoView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(livePhotoView)
            NSLayoutConstraint.activate([
                livePhotoView.topAnchor.constraint(equalTo: contentView.topAnchor),
                livePhotoView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                livePhotoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                livePhotoView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
            ])
            liveBadgeView = UIImageView()
            liveBadgeView.contentMode = .scaleToFill
            //liveBadgeView.image = PHLivePhotoView.livePhotoBadgeImage(options: [.liveOff])
            liveBadgeView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            liveBadgeView.translatesAutoresizingMaskIntoConstraints = false
            livePhotoView.addSubview(liveBadgeView)
            NSLayoutConstraint.activate([
                liveBadgeView.topAnchor.constraint(equalTo: livePhotoView.topAnchor, constant: 11.0),
                liveBadgeView.leftAnchor.constraint(equalTo: livePhotoView.leftAnchor, constant: 11.0),
                liveBadgeView.widthAnchor.constraint(equalToConstant: 27.0),
                liveBadgeView.heightAnchor.constraint(equalToConstant: 27.0)
            ])
        }
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard contentView.frame.size == .zero else { return }
        var coverImage: UIImage?
        if imageView.isHidden == false, let image = imageView.image {
            coverImage = image
        } else if playView.coverView.isHidden == false, let image = playView.coverView.image {
            coverImage = image
        }
        guard let image = coverImage else { return }
        adapt(with: image)
    }
    
    /// 适配位置
    /// - Parameter image: 图片
    func adapt(with image: UIImage) {
        if frame.size == .zero { return }
        zoomScale = 1.0
        contentOffset = .zero
        contentView.mn.size = image.size.mn.scaleFit(in: CGSize(width: frame.width, height: frame.height - 1.0))
        contentSize = CGSize(width: frame.width, height: max(contentView.frame.height, frame.height))
        contentView.center = CGPoint(x: frame.width/2.0, y: frame.height/2.0)
        if (contentView.frame.height > frame.height) {
            contentView.mn.minY = 0.0
            contentOffset = CGPoint(x: 0.0, y: (contentView.frame.height - frame.height)/2.0)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension MNAssetScrollView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX: CGFloat = scrollView.bounds.width > scrollView.contentSize.width ? (scrollView.bounds.width - scrollView.contentSize.width)/2.0 : 0.0
        let offsetY: CGFloat = scrollView.bounds.height > scrollView.contentSize.height ? (scrollView.bounds.height - scrollView.contentSize.height)/2.0 : 0.0
        contentView.center = CGPoint(x: scrollView.contentSize.width/2.0 + offsetX, y: scrollView.contentSize.height/2.0 + offsetY)
    }
}

@available(iOS 9.1, *)
extension MNAssetScrollView: PHLivePhotoViewDelegate {
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, canBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) -> Bool {
        liveBadgeView.alpha == 1.0
    }
    
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.liveBadgeView.alpha = 0.0
        }
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.liveBadgeView.alpha = 1.0
        }
    }
}
