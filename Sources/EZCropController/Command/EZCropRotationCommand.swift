//
//  EZCropRotationCommand.swift
//  
//
//  Created by Xiang Li on 3/26/21.
//

import UIKit
import Combine

internal final class EZCropRotationCommand : CommandProtocol {
    private weak var cropView : EZCropView!
    private weak var processor : EZCropProcessor!
    private var animating = false
    init(cropView:EZCropView,processor:EZCropProcessor){
        self.cropView = cropView
        self.processor = processor
    }
    internal func execute(_ gesture: UIGestureRecognizer?, params: Dictionary<String, Any>?) {
        guard
            animating == false,
            let clockwise = params?["rotationClockwise"] as? Bool
        else {
            return
        }
        animating = true

        let cropViewSafeInset = self.cropView.adjustedContentInsets //self.cropView.safeAreaInsets
        let safeHeight = self.cropView.bounds.height - cropViewSafeInset.top - cropViewSafeInset.bottom
        let safeWidth = self.cropView.bounds.width - cropViewSafeInset.left - cropViewSafeInset.right

        self.cropView.isUserInteractionEnabled = false
        self.cropView.hideSubView(true)
        self.cropView.backgroundContainer.setContentOffset(self.cropView.backgroundContainer.contentOffset, animated: false)
        self.processor.setRotateCropViewWithOrientationEnable(false)

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.cropView.addSubview(imageView)

        let cropBoxFrameInImageView = self.cropView.overlay.convert(self.cropView.overlay.cropBoxFrame, to: self.cropView.backgroundImageView)
        let cropBoxFrameInCropView = self.cropView.overlay.convert(self.cropView.overlay.cropBoxFrame, to: self.cropView)
        let cropedImage = EZCropUtilities.cropImage(self.cropView.backgroundImageView.image!, inRect: cropBoxFrameInImageView)
        imageView.image = cropedImage
        imageView.contentMode = .scaleToFill

        let heightArchor = imageView.heightAnchor.constraint(equalToConstant: cropBoxFrameInCropView.height)
        let widthArchor = imageView.widthAnchor.constraint(equalToConstant: cropBoxFrameInCropView.width)
        let leadingArchor = imageView.centerXAnchor.constraint(equalTo: self.cropView.leadingAnchor,
                                                               constant: cropViewSafeInset.left + safeWidth/2)
        let topArchor = imageView.centerYAnchor.constraint(equalTo: self.cropView.topAnchor,
                                                           constant: cropViewSafeInset.top + safeHeight/2)

        let scale = EZCropUtilities.calculateScaleOf(size: CGSize(width: cropBoxFrameInImageView.height,
                                                                  height: cropBoxFrameInImageView.width),
                                                     aspectFitToSize: CGSize(width: safeWidth,
                                                                             height: safeHeight))
        let scaledHeight = cropBoxFrameInImageView.height * scale
        let scaledWidth = cropBoxFrameInImageView.width * scale
        NSLayoutConstraint.activate([
            leadingArchor,
            topArchor,
            heightArchor,
            widthArchor
        ])
        self.cropView.layoutIfNeeded()
    

        let direction = self.cropView.rotation.rotateClockwise(clockwise)
        self.cropView.rotation = direction
        self.cropView.apsectScaleFitCroppedImage()
        self.cropView.foregroundContainer.syncImageViewFrame()


        UIView.animate(withDuration: 0.5, animations: {
            [weak self] in
            guard
                let self = self
            else {
                return
            }
            heightArchor.constant = scaledHeight
            widthArchor.constant = scaledWidth
            imageView.transform = CGAffineTransform(rotationAngle: clockwise ? EZCropRotation.ninty.angle:EZCropRotation.twoHunderdAndSeventy.angle)
            self.cropView.layoutIfNeeded()
        }, completion: {
            [weak self] finished in
            guard let self = self else {return}
            imageView.removeFromSuperview()
            self.cropView.hideSubView(false)
            self.cropView.isUserInteractionEnabled = true
            self.processor.ongoingCommand = nil
            self.processor.setRotateCropViewWithOrientationEnable(true)
        })
    }
    internal func undo() {

    }
}
