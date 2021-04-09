//
//  EZCropPanGestureCommand.swift
//  
//
//  Created by Xiang Li on 3/26/21.
//

import UIKit
import Combine

internal final class EZCropMoveCommand : CommandProtocol {

    private weak var cropView : EZCropView!
    private weak var processor : EZCropProcessor!
    


    init(cropView:EZCropView,processor:EZCropProcessor){
        self.cropView = cropView
        self.processor = processor
    }

    func execute(_ gesture: UIGestureRecognizer?, params: Dictionary<String, Any>?) {
        let cropBoxInScrollView = self.cropView.backgroundContainer.bounds.inset(by: self.cropView.backgroundContainer.adjustedContentInset)
        let cropdBoxInImageView = self.cropView.backgroundContainer.convert(cropBoxInScrollView, to: self.cropView.backgroundImageView)
        if self.cropView.backgroundImageView.bounds.contains(cropdBoxInImageView){
            let tranform = EZCropUtilities.getTranformOfRotate(self.cropView.rotation, withCoordinate: CGRect(origin: .zero, size: self.cropView.imageSize)).inverted()
            let cropBoxInOrginImage = cropdBoxInImageView.applying(tranform)
            self.cropView.imageCropFrame = cropBoxInOrginImage.integral
        }

        self.processor.ongoingCommand = nil
    }
    func undo() {

    }
}
