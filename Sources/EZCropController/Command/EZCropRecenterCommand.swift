//
//  File.swift
//  
//
//  Created by Xiang Li on 4/5/21.
//

import UIKit
import Combine

internal final class EZCropRecenterCommand : CommandProtocol {

    private weak var cropView : EZCropView!
    private weak var processor : EZCropProcessor!
    private var animating = false
    init(cropView:EZCropView,processor:EZCropProcessor){
        self.cropView = cropView
        self.processor = processor
    }

    func execute(_ gesture: UIGestureRecognizer?, params: Dictionary<String, Any>?) {
        guard animating == false else {
            return
        }
        animating = true
        self.cropView.isUserInteractionEnabled = false

        let cropBoxFrameInImageView = self.cropView.overlay.convert(self.cropView.overlay.cropBoxFrame, to: self.cropView.backgroundImageView)
        let cropBoxFrameInCropView = self.cropView.overlay.convert(self.cropView.overlay.cropBoxFrame, to: self.cropView)
        self.cropView.hideSubView(true)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.cropView.addSubview(imageView)
        let cropedImage = EZCropUtilities.cropImage(self.cropView.backgroundImageView.image!, inRect: cropBoxFrameInImageView)
        imageView.image = cropedImage
        imageView.contentMode = .scaleToFill
        let leadArchor = imageView.leadingAnchor.constraint(equalTo: self.cropView.leadingAnchor, constant: cropBoxFrameInCropView.minX)
        let topArchor = imageView.topAnchor.constraint(equalTo: self.cropView.topAnchor, constant: cropBoxFrameInCropView.minY)
        let heightArchor = imageView.heightAnchor.constraint(equalToConstant: cropBoxFrameInCropView.height)
        let widthArchor = imageView.widthAnchor.constraint(equalToConstant: cropBoxFrameInCropView.width)

        let cropViewSafeInset = self.cropView.adjustedContentInsets //self.cropView.safeAreaInsets
        let safeHeight = self.cropView.bounds.height - cropViewSafeInset.top - cropViewSafeInset.bottom
        let safeWidth = self.cropView.bounds.width - cropViewSafeInset.left - cropViewSafeInset.right
        let scale = EZCropUtilities.calculateScaleOf(size: cropBoxFrameInImageView.size, aspectFitToSize: CGSize(width: safeWidth, height: safeHeight))
        let scaledHeight = cropBoxFrameInImageView.height * scale
        let scaledWidth = cropBoxFrameInImageView.width * scale
        let newX = cropViewSafeInset.left + (safeWidth-scaledWidth)/2
        let newY = cropViewSafeInset.top + (safeHeight-scaledHeight)/2
        NSLayoutConstraint.activate([
            leadArchor,
            topArchor,
            heightArchor,
            widthArchor
        ])
        self.cropView.layoutIfNeeded()
        self.cropView.apsectScaleFitCroppedImage()
        DispatchQueue.main.async {
            [weak self] in
            guard let self  = self else {return}
            UIView.animate(withDuration: 0.5, animations: {
                [weak self] in
                guard
                    let self = self
                else {
                    return
                }
                leadArchor.constant = newX
                topArchor.constant = newY
                heightArchor.constant = scaledHeight
                widthArchor.constant = scaledWidth
                self.cropView.layoutIfNeeded()

            }, completion: {
                [weak self] finished in
                guard
                    let self = self
                else {
                    return
                }

                self.cropView.hideSubView(false)
                
                imageView.removeFromSuperview()
                self.processor.ongoingCommand = nil
                self.processor.setRotateCropViewWithOrientationEnable(true)
                self.cropView.isUserInteractionEnabled = true
            })
        }
    }
    public func undo() {

    }
}
