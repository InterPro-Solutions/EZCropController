//
//  EZCropRatioCommand.swift
//  
//
//  Created by Xiang Li on 3/26/21.
//

import UIKit
import Combine

internal final class EZCropRatioCommand : CommandProtocol {
    private weak var cropView : EZCropView!
    private weak var processor : EZCropProcessor!
    private var animating = false
    init(cropView:EZCropView,processor:EZCropProcessor){
        self.cropView = cropView
        self.processor = processor
    }

    func execute(_ gesture: UIGestureRecognizer?, params: Dictionary<String, Any>?) {
        guard
            animating == false,
            let ratio = params?["ratio"] as? CGFloat
        else {
            return
        }
        animating = true
        self.cropView.isUserInteractionEnabled = true
        self.cropView.backgroundContainer.setContentOffset(self.cropView.backgroundContainer.contentOffset, animated: false)
        //self.cropView.hideSubView(true)
        if #available(iOS 13.0, *) {
            self.processor.setRotateCropViewWithOrientationEnable(false)
        } else {
            fatalError("need implemented under ios 13")
        }

        let adjustedContentInsets = self.cropView.adjustedContentInsets
        var safeDrawableRect = self.cropView.overlay.bounds.inset(by: adjustedContentInsets)
        var safeDrawableRectInBackgroundImage = self.cropView.overlay.convert(safeDrawableRect, to: self.cropView.backgroundImageView)
        var resizeSnapshot = false
        if self.cropView.backgroundImageView.bounds.contains(safeDrawableRectInBackgroundImage) == false{
            let center = CGPoint(x: safeDrawableRectInBackgroundImage.midX, y: safeDrawableRectInBackgroundImage.midY)
            let intersection = self.cropView.backgroundImageView.bounds.intersection(safeDrawableRectInBackgroundImage)
            let safeDrawbleHeightHalf = min(center.y - intersection.minY,intersection.maxY-center.y)
            let safeDrawbleWidthHalf = min(center.x - intersection.minX,intersection.maxX-center.x)
            safeDrawableRectInBackgroundImage = EZCropUtilities.getRectWith(minX: center.x-safeDrawbleWidthHalf,
                                                           minY: center.y-safeDrawbleHeightHalf,
                                                           maxX: center.x+safeDrawbleWidthHalf,
                                                           maxY: center.y+safeDrawbleHeightHalf)
            safeDrawableRect = self.cropView.backgroundImageView.convert(safeDrawableRectInBackgroundImage, to: self.cropView.overlay)
            resizeSnapshot = true
        }
        var ratioHeightInBackgroundImage = safeDrawableRectInBackgroundImage.height
        var ratioedWidthInBackgroundImage = ratioHeightInBackgroundImage * ratio
        if(ratioedWidthInBackgroundImage > safeDrawableRectInBackgroundImage.width){
            ratioedWidthInBackgroundImage = safeDrawableRectInBackgroundImage.width
            ratioHeightInBackgroundImage = ratioedWidthInBackgroundImage/ratio
        }
        let ratioedDrawRectinBackgroundImage = EZCropUtilities.getRectWith(minX: safeDrawableRectInBackgroundImage.midX-ratioedWidthInBackgroundImage/2,
                                                      minY: safeDrawableRectInBackgroundImage.midY-ratioHeightInBackgroundImage/2,
                                                      maxX: safeDrawableRectInBackgroundImage.midX+ratioedWidthInBackgroundImage/2,
                                                      maxY: safeDrawableRectInBackgroundImage.midY+ratioHeightInBackgroundImage/2)
        let ratioedSafeDrawableRect = self.cropView.backgroundImageView.convert(ratioedDrawRectinBackgroundImage, to: self.cropView.overlay)


        let originalCoordinate = CGRect(origin: .zero, size: self.cropView.imageSize)
        let tranform = EZCropUtilities.getTranformOfRotate(self.cropView.rotation, withCoordinate: originalCoordinate).inverted()


        self.cropView.imageCropFrame = ratioedDrawRectinBackgroundImage.applying(tranform)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))
        //CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: ))
        UIView.animate(withDuration: 0.5, animations: {
            [weak self] in
            guard let self = self else {return}
            self.cropView.foregroundContainer.setCropFrame(ratioedSafeDrawableRect)
        })
        print("\(ratioedSafeDrawableRect)")
        self.cropView.overlay.setCropBoxFrame(ratioedSafeDrawableRect, animated: true, completion: {
            [weak self] finished in
            guard let self = self else {return}
            self.processor.ongoingCommand = nil
            if resizeSnapshot == true {
                self.processor.execute(event: .noInteractionAwhile, params: (nil,nil))
            }
            else {
                self.cropView.isUserInteractionEnabled = true
                self.processor.setRotateCropViewWithOrientationEnable(false)
            }

        })
        CATransaction.commit()
    }
    func undo() {

    }
}
