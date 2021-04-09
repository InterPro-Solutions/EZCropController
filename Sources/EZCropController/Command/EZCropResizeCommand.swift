//
//  File.swift
//  
//
//  Created by Xiang Li on 3/26/21.
//

import UIKit
import Combine

internal final class EZCropResizeCommand : CommandProtocol {

    private weak var cropView : EZCropView!
    private weak var processor : EZCropProcessor!
    var activeEdge : EZCropOverlayViewEdge = .none
    private var originalFrame : CGRect!
    private var orginalPoint : CGPoint!
    //private var endedAnimation  = false

    private var maxValidRect : CGRect = .zero
    private var minValidRect : CGRect = .zero
    private static let boxSize : CGFloat = 42
    private var minDeltaX : CGFloat = .zero
    private var maxDeltaX : CGFloat = .zero
    private var minDeltaY : CGFloat = .zero
    private var maxDeltaY : CGFloat = .zero
    private weak var workingGesture : UIPanGestureRecognizer!

    init(cropView:EZCropView,processor:EZCropProcessor){
        self.cropView = cropView
        self.processor = processor
    }

    public func execute(_ gesture: UIGestureRecognizer?, params: Dictionary<String, Any>?) {
        guard
            let gesture = gesture as? UIPanGestureRecognizer
        else {
            #if DEBUG
            print("wrong event in")
            return
            #else
            return
            #endif
        }
        defer {
            if
                gesture.state == .ended
            {
                if let workGesture = self.workingGesture,
                   workGesture == gesture
                {
                    let originalCoordinate = CGRect(origin: .zero, size: self.cropView.imageSize)
                    let tranform = EZCropUtilities.getTranformOfRotate(self.cropView.rotation, withCoordinate: originalCoordinate).inverted()
                    let cropBoxFrameInImageView = self.cropView.overlay.convert(self.cropView.overlay.cropBoxFrame, to: self.cropView.backgroundImageView)
                    //let cropBoxFrameInCropView = self.cropView.overlay.convert(self.cropView.overlay.cropBoxFrame, to: self.cropView)
                    let newImageCropFrame = cropBoxFrameInImageView.applying(tranform).integral
                    self.cropView.imageCropFrame = newImageCropFrame
                    self.processor.lastCropImageFrame = newImageCropFrame
                    self.cropView.fitCroppedImageToCropBox()
                }
                self.processor.ongoingCommand = nil
                self.processor.setRotateCropViewWithOrientationEnable(true)
            }
        }
        let locationInOverLayView = gesture.location(in: self.cropView.overlay)
        //var locationInImageView = gesture.location(in: self.cropView.backgroundImageView)


        if
            self.workingGesture == nil,
            gesture.state == .began
        {
            self.workingGesture = gesture
            self.processor.setRotateCropViewWithOrientationEnable(false)
            self.activeEdge = self.setActiveEdgeFrom(point: locationInOverLayView)
        }
        if
            let workGesture = self.workingGesture,
            workGesture == gesture
        {
            self.updateCropBoxFrameWith(point: locationInOverLayView)
        }

    }
    public func undo() {

    }
    private func setActiveEdgeFrom(point:CGPoint) -> EZCropOverlayViewEdge{
        let adjustedContentInset = self.cropView.adjustedContentInsets
        self.originalFrame = self.cropView.overlay.cropBoxFrame
        self.orginalPoint = point
        let regionSize : CGFloat = 32
        let frame = self.originalFrame.insetBy(dx: -regionSize, dy: -regionSize)
        let topLeftRect = CGRect(origin: frame.origin, size: CGSize(width: regionSize*2, height: regionSize*2))
        let imageViewRectInOverlay = self.cropView.backgroundImageView.convert(self.cropView.backgroundImageView.bounds, to: self.cropView.overlay)
        let safeDrawableRect = self.cropView.overlay.bounds.inset(by: adjustedContentInset)
        let safeWorkingRect = imageViewRectInOverlay.intersection(safeDrawableRect)
        var deltaX_1 : CGFloat = .zero
        var deltaX_2 : CGFloat = .zero
        var deltaY_1 : CGFloat = .zero
        var deltaY_2 : CGFloat = .zero
        defer {
            self.minDeltaX = min(deltaX_1,deltaX_2)
            self.maxDeltaX = max(deltaX_1,deltaX_2)
            self.minDeltaY = min(deltaY_1,deltaY_2)
            self.maxDeltaY = max(deltaY_1,deltaY_2)
        }
        if topLeftRect.contains(point)
        {
            self.maxValidRect = EZCropUtilities.getRectWith(minX: min(safeWorkingRect.minX,self.originalFrame.minX),
                                                            minY: min(safeWorkingRect.minY,self.originalFrame.minY),
                                                            maxX: self.originalFrame.maxX,
                                                            maxY: self.originalFrame.maxY)
            self.minValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.maxX-Self.boxSize,
                                                            minY: self.originalFrame.maxY-Self.boxSize,
                                                            maxX: self.originalFrame.maxX,
                                                            maxY: self.originalFrame.maxY)
            deltaX_1 = maxValidRect.minX - self.originalFrame.minX
            deltaX_2 = minValidRect.minX - self.originalFrame.minX
            deltaY_1 = maxValidRect.minY - self.originalFrame.minY
            deltaY_2 = minValidRect.minY - self.originalFrame.minY
            return .topLeft
        }
        let topRightRect = CGRect(origin: CGPoint(x: frame.maxX-regionSize*2, y: frame.minY),
                                  size: CGSize(width: regionSize*2, height: regionSize*2))
        if topRightRect.contains(point)
        {
            self.maxValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                            minY: safeWorkingRect.minY,
                                                            maxX: safeWorkingRect.maxX,
                                                            maxY: self.originalFrame.maxY)
            self.minValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                            minY: self.originalFrame.maxY-Self.boxSize,
                                                            maxX: self.originalFrame.minX+Self.boxSize,
                                                            maxY: self.originalFrame.maxY)
            deltaX_1 = maxValidRect.maxX - self.originalFrame.maxX
            deltaX_2 = minValidRect.maxX - self.originalFrame.maxX
            deltaY_1 = maxValidRect.minY - self.originalFrame.minY
            deltaY_2 = minValidRect.minY - self.originalFrame.minY
            return .topRight
        }

        let bottomRightRect = CGRect(origin: CGPoint(x: frame.maxX-regionSize*2, y: frame.maxY-regionSize*2),
                                  size: CGSize(width: regionSize*2, height: regionSize*2))
        if bottomRightRect.contains(point)
        {
            self.maxValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                            minY: self.originalFrame.minY,
                                                            maxX: safeWorkingRect.maxX,
                                                            maxY: safeWorkingRect.maxY)
            self.minValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                            minY: self.originalFrame.minY,
                                                            maxX: self.originalFrame.minX+Self.boxSize,
                                                            maxY: self.originalFrame.minY+Self.boxSize)
            deltaX_1 = maxValidRect.maxX - self.originalFrame.maxX
            deltaX_2 = minValidRect.maxX - self.originalFrame.maxX
            deltaY_1 = maxValidRect.maxY - self.originalFrame.maxY
            deltaY_2 = minValidRect.maxY - self.originalFrame.maxY
            return .bottomRight
        }

        let bottomLeftRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY-regionSize*2), size: CGSize(width: regionSize*2, height: regionSize*2))
        if bottomLeftRect.contains(point)
        {
            self.maxValidRect = EZCropUtilities.getRectWith(minX: safeWorkingRect.minX,
                                                            minY: self.originalFrame.minY,
                                                            maxX: self.originalFrame.maxX,
                                                            maxY: safeWorkingRect.maxY)
            self.minValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.maxX-Self.boxSize,
                                                            minY: self.originalFrame.minY,
                                                            maxX: self.originalFrame.maxX,
                                                            maxY: self.originalFrame.minY+Self.boxSize)
            deltaX_1 = maxValidRect.minX - self.originalFrame.minX
            deltaX_2 = minValidRect.minX - self.originalFrame.minX
            deltaY_1 = maxValidRect.maxY - self.originalFrame.maxY
            deltaY_2 = minValidRect.maxY - self.originalFrame.maxY
            return .bottomLeft
        }

        let top = CGRect(origin: frame.origin,
                        size: CGSize(width: frame.width, height: regionSize*2))
        if top.contains(point)
        {
            self.maxValidRect = EZCropUtilities.getRectWith(minX: safeWorkingRect.minX,
                                                            minY: safeWorkingRect.minY,
                                                            maxX: safeWorkingRect.maxX,
                                                            maxY: self.originalFrame.maxY)
            self.minValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.midX-Self.boxSize/2,
                                                            minY: self.originalFrame.maxY-Self.boxSize,
                                                            maxX: self.originalFrame.midX+Self.boxSize/2,
                                                            maxY: self.originalFrame.maxY)
            deltaY_1 = maxValidRect.minY - self.originalFrame.minY
            deltaY_2 = minValidRect.minY - self.originalFrame.minY
            return .top
        }
        let right = CGRect(origin: CGPoint(x: frame.maxX-regionSize*2, y: frame.minX),
                          size: CGSize(width: regionSize*2, height:frame.height))
        if right.contains(point)
        {
            self.maxValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                            minY: safeWorkingRect.minY,
                                                            maxX: safeWorkingRect.maxX,
                                                            maxY: safeWorkingRect.maxY)
            self.minValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                            minY: self.originalFrame.midY-Self.boxSize/2,
                                                            maxX: self.originalFrame.minX+Self.boxSize,
                                                            maxY: self.originalFrame.midY+Self.boxSize/2)
            deltaX_1 = maxValidRect.maxX - self.originalFrame.maxX
            deltaX_2 = minValidRect.maxX - self.originalFrame.maxX
            return .right
        }

        let bottom = CGRect(origin: CGPoint(x: frame.minX, y: frame.maxY-regionSize*2),
                        size: CGSize(width: frame.width, height: regionSize*2))
        if bottom.contains(point)
        {
            self.maxValidRect = EZCropUtilities.getRectWith(minX: safeWorkingRect.minX,
                                                            minY: self.originalFrame.minY,
                                                            maxX: safeWorkingRect.maxX,
                                                            maxY: safeWorkingRect.maxY)
            self.minValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.midX-Self.boxSize/2,
                                                            minY: self.originalFrame.minY,
                                                            maxX: self.originalFrame.midX+Self.boxSize/2,
                                                            maxY: self.originalFrame.minY+Self.boxSize)
            deltaY_1 = maxValidRect.maxY - self.originalFrame.maxY
            deltaY_2 = minValidRect.maxY - self.originalFrame.maxY
            return .bottom
        }
        let left = CGRect(origin: frame.origin,
                          size: CGSize(width: regionSize*2, height:frame.height))
        if left.contains(point)
        {
            self.maxValidRect = EZCropUtilities.getRectWith(minX: safeWorkingRect.minX,
                                                            minY: safeWorkingRect.minY,
                                                            maxX: self.originalFrame.maxX,
                                                            maxY: safeWorkingRect.maxY)
            self.minValidRect = EZCropUtilities.getRectWith(minX: self.originalFrame.maxX-Self.boxSize,
                                                            minY: self.originalFrame.midY-Self.boxSize/2,
                                                            maxX: self.originalFrame.maxX,
                                                            maxY: self.originalFrame.midY+Self.boxSize/2)
            deltaX_1 = maxValidRect.minX - self.originalFrame.minX
            deltaX_2 = minValidRect.minX - self.originalFrame.minX
            return .left
        }
        return .none
    }

    private func updateCropBoxFrameWith(point:CGPoint){

        var xDelta = min(self.maxDeltaX, max((point.x - self.orginalPoint.x).rounded(.up), self.minDeltaX))
        var yDelta = min(self.maxDeltaY, max((point.y - self.orginalPoint.y).rounded(.up),self.minDeltaY))
        let aspectRatio = self.originalFrame.size.width/self.originalFrame.size.height
        let isLockAspectRatioEnable = self.processor.isLockAspectRatioEnable
        var translateX : CGFloat = 0
        var translateY : CGFloat = 0
        var scaleX : CGFloat = 1
        var scaleY : CGFloat = 1



        switch self.activeEdge {
        case .left:
            translateX = xDelta
            scaleX = max(1 - xDelta/self.originalFrame.width,CGFloat.leastNonzeroMagnitude)
            if isLockAspectRatioEnable {
                yDelta = xDelta / aspectRatio
                scaleY = max(1 - yDelta/self.originalFrame.height,CGFloat.leastNonzeroMagnitude)
            }
        case .right:
            scaleX = max(1 + xDelta/self.originalFrame.width,CGFloat.leastNonzeroMagnitude)
            if isLockAspectRatioEnable {
                yDelta = xDelta / aspectRatio
                scaleY = max(1 + yDelta/self.originalFrame.height,CGFloat.leastNonzeroMagnitude)
            }
        case .bottom:
            scaleY = max(1 + yDelta/self.originalFrame.height,CGFloat.leastNonzeroMagnitude)
            if isLockAspectRatioEnable {
                xDelta = yDelta * aspectRatio
                scaleX = max(1 + xDelta/self.originalFrame.width,CGFloat.leastNonzeroMagnitude)
            }
        case .top:
            translateY = yDelta
            scaleY = max(1 - yDelta/self.originalFrame.height,CGFloat.leastNonzeroMagnitude)
            if isLockAspectRatioEnable {
                xDelta = yDelta * aspectRatio
                scaleX = max(1 - xDelta/self.originalFrame.width,CGFloat.leastNonzeroMagnitude)
            }
        case .topLeft:
            translateX = xDelta
            scaleX = max(1 - xDelta/self.originalFrame.width,CGFloat.leastNonzeroMagnitude)
            translateY = yDelta
            scaleY = max(1 - yDelta/self.originalFrame.height,CGFloat.leastNonzeroMagnitude)
            if isLockAspectRatioEnable {
                let everageScale = (scaleY + scaleX)/2
                scaleX = everageScale
                scaleY = everageScale
            }
        case .topRight:
            scaleX = max(1 + xDelta/self.originalFrame.width,CGFloat.leastNonzeroMagnitude)
            translateY = yDelta
            scaleY = max(1 - yDelta/self.originalFrame.height,CGFloat.leastNonzeroMagnitude)
            if isLockAspectRatioEnable {
                let everageScale = (scaleY + scaleX)/2
                scaleX = everageScale
                scaleY = everageScale
            }
        case .bottomLeft:
            translateX = xDelta
            scaleX = max(1 - xDelta/self.originalFrame.width,CGFloat.leastNonzeroMagnitude)
            scaleY = max(1 + yDelta/self.originalFrame.height,CGFloat.leastNonzeroMagnitude)
            if isLockAspectRatioEnable {
                let everageScale = (scaleY + scaleX)/2
                scaleX = everageScale
                scaleY = everageScale
            }
        case .bottomRight:
            scaleX = max(1 + xDelta/self.originalFrame.width,CGFloat.leastNonzeroMagnitude)
            scaleY = max(1 + yDelta/self.originalFrame.height,CGFloat.leastNonzeroMagnitude)
            if isLockAspectRatioEnable {
                let everageScale = (scaleY + scaleX)/2
                scaleX = everageScale
                scaleY = everageScale
            }
        case .none:
            return
        }
        let newOrigin = self.originalFrame.origin.applying(CGAffineTransform.identity.translatedBy(x: translateX, y: translateY))
        let newSize = self.originalFrame.size.applying(CGAffineTransform.identity.scaledBy(x: scaleX, y: scaleY))

        var newCropBoxFrame = CGRect(origin: newOrigin, size: newSize)

        if(isLockAspectRatioEnable){
            switch self.activeEdge {
            case .topLeft:
                var width = newCropBoxFrame.width
                var height = newCropBoxFrame.height
                if(width  < Self.boxSize){
                    width = Self.boxSize
                    height = width / aspectRatio
                }
                else if(width > self.maxValidRect.width){
                    width = self.maxValidRect.width
                    height = width / aspectRatio
                }
                else if(height  < Self.boxSize){
                    height = Self.boxSize
                    width = height * aspectRatio
                }
                else if(height > self.maxValidRect.height){
                    height = self.maxValidRect.height
                    width = height * aspectRatio
                }
                newCropBoxFrame = EZCropUtilities.getRectWith(minX: self.originalFrame.maxX-width,
                                                              minY: self.originalFrame.maxY-height,
                                                              maxX: self.originalFrame.maxX,
                                                              maxY: self.originalFrame.maxY)

            case .topRight:
                var width = newCropBoxFrame.width
                var height = newCropBoxFrame.height
                if(width  < Self.boxSize){
                    width = Self.boxSize
                    height = width / aspectRatio
                }
                else if(width > self.maxValidRect.width){
                    width = self.maxValidRect.width
                    height = width / aspectRatio
                }
                else if(height  < Self.boxSize){
                    height = Self.boxSize
                    width = height * aspectRatio
                }
                else if(height > self.maxValidRect.height){
                    height = self.maxValidRect.height
                    width = height * aspectRatio
                }
                newCropBoxFrame = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                              minY: self.originalFrame.maxY-height,
                                                              maxX: self.originalFrame.minX+width,
                                                              maxY: self.originalFrame.maxY)
            case .bottomRight:
                var width = newCropBoxFrame.width
                var height = newCropBoxFrame.height
                if(width  < Self.boxSize){
                    width = Self.boxSize
                    height = width / aspectRatio
                }
                else if(width > self.maxValidRect.width){
                    width = self.maxValidRect.width
                    height = width / aspectRatio
                }
                else if(height  < Self.boxSize){
                    height = Self.boxSize
                    width = height * aspectRatio
                }
                else if(height > self.maxValidRect.height){
                    height = self.maxValidRect.height
                    width = height * aspectRatio
                }
                newCropBoxFrame = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                              minY: self.originalFrame.minY,
                                                              maxX: self.originalFrame.minX+width,
                                                              maxY: self.originalFrame.minY+height)
            case .bottomLeft:
                var width = newCropBoxFrame.width
                var height = newCropBoxFrame.height
                if(width  < Self.boxSize){
                    width = Self.boxSize
                    height = width / aspectRatio
                }
                else if(width > self.maxValidRect.width){
                    width = self.maxValidRect.width
                    height = width / aspectRatio
                }
                else if(height  < Self.boxSize){
                    height = Self.boxSize
                    width = height * aspectRatio
                }
                else if(height > self.maxValidRect.height){
                    height = self.maxValidRect.height
                    width = height * aspectRatio
                }
                newCropBoxFrame = EZCropUtilities.getRectWith(minX: self.originalFrame.maxX-width,
                                                              minY: self.originalFrame.minY,
                                                              maxX: self.originalFrame.maxX,
                                                              maxY: self.originalFrame.minY+height)
            case .top:
                var width = newCropBoxFrame.width
                var height = newCropBoxFrame.height
                if(width  < Self.boxSize){
                    width = Self.boxSize
                    height = width / aspectRatio
                }
                else if(width > self.maxValidRect.width){
                    width = self.maxValidRect.width
                    height = width / aspectRatio
                }
                newCropBoxFrame = EZCropUtilities.getRectWith(minX: self.originalFrame.midX-width/2,
                                                              minY: self.originalFrame.maxY-height,
                                                              maxX: self.originalFrame.midX+width/2,
                                                              maxY: self.originalFrame.maxY)
            case .right:
                var width = newCropBoxFrame.width
                var height = newCropBoxFrame.height

                if(height  < Self.boxSize){
                    height = Self.boxSize
                    width = height * aspectRatio
                }
                else if(height > self.maxValidRect.height){
                    height = self.maxValidRect.height
                    width = height * aspectRatio
                }
                newCropBoxFrame = EZCropUtilities.getRectWith(minX: self.originalFrame.minX,
                                                              minY: self.originalFrame.midY-height/2,
                                                              maxX: self.originalFrame.minX+width,
                                                              maxY: self.originalFrame.midY+height/2)

            case .bottom:
                var width = newCropBoxFrame.width
                var height = newCropBoxFrame.height
                if(width  < Self.boxSize){
                    width = Self.boxSize
                    height = width / aspectRatio
                }
                else if(width > self.maxValidRect.width){
                    width = self.maxValidRect.width
                    height = width / aspectRatio
                }
                newCropBoxFrame = EZCropUtilities.getRectWith(minX: self.originalFrame.midX-width/2,
                                                              minY: self.originalFrame.minY,
                                                              maxX: self.originalFrame.midX+width/2,
                                                              maxY: self.originalFrame.minY+height)
            case .left:
                var width = newCropBoxFrame.width
                var height = newCropBoxFrame.height

                if(height  < Self.boxSize){
                    height = Self.boxSize
                    width = height * aspectRatio
                }
                else if(height > self.maxValidRect.height){
                    height = self.maxValidRect.height
                    width = height * aspectRatio
                }
                newCropBoxFrame = EZCropUtilities.getRectWith(minX: self.originalFrame.maxX-width,
                                                              minY: self.originalFrame.midY-height/2,
                                                              maxX: self.originalFrame.maxX,
                                                              maxY: self.originalFrame.midY+height/2)
            case .none:
                break
            }
        }
        self.cropView.overlay.cropBoxFrame = newCropBoxFrame
        let frameInCropView = self.cropView.overlay.convert(newCropBoxFrame.integral, to: self.cropView.foregroundContainer)
        self.cropView.foregroundContainer.setCropFrame(frameInCropView)

    }
}
