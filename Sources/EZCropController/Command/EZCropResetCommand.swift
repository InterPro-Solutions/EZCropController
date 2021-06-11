//
//  EZCropResetCommand.swift
//  
//
//  Created by Xiang Li on 4/23/21.
//


import UIKit
import Combine

internal final class EZCropResetCommand : CommandProtocol {

    private weak var cropView : EZCropView!
    private weak var processor : EZCropProcessor!
    private var animating = false


    init(cropView:EZCropView,processor:EZCropProcessor){
        self.cropView = cropView
        self.processor = processor
    }

    func execute(_ gesture: UIGestureRecognizer?, params: Dictionary<String, Any>?) {
        guard
            animating == false
        else {
            return
        }
        animating = true

        self.cropView.imageCropFrame = CGRect(origin: .zero, size: self.cropView.imageSize)
        self.cropView.rotation = .zero
        UIView.animate(withDuration: 0.5, animations: {
            self.cropView.apsectScaleFitCroppedImage(animated: true)
        }, completion: {
            [weak self] finished in
            self?.processor.ongoingCommand = nil
        })
    }
    func undo() {

    }
}
