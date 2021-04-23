//
//  EZCropUtilities.swift
//  
//
//  Created by Xiang Li on 3/26/21.
//

import Foundation
import UIKit

internal extension UIImage {

    func fixedOrientation() -> UIImage {

        if imageOrientation == UIImage.Orientation.up {
            return self
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi/2)
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        @unknown default:
            break
        }

        switch imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        @unknown default:
            break
        }

        let ctx: CGContext = CGContext(data: nil,
                                       width: Int(size.width),
                                       height: Int(size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent,
                                       bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        ctx.concatenate(transform)

        switch imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        let cgImage: CGImage = ctx.makeImage()!

        return UIImage(cgImage: cgImage)
    }
}
@objc public final class EZCropUtilities : NSObject {
    static let ezcropUtilitiesQueue = DispatchQueue(label: "com.interprosoft.ezcropUtilitiesQueue)")
    @objc public static func asyncCropImage(_ image:UIImage, inRect rect:CGRect,thenRotate radians:CGFloat,completion:@escaping (UIImage)->Void){
        Self.ezcropUtilitiesQueue.async {
            let image = Self.cropImage(image, inRect: rect, thenRotate: radians)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }

    @objc public static func asyncCropImage(_ image:UIImage, inRect rect:CGRect,completion:@escaping (UIImage)->Void){
        Self.ezcropUtilitiesQueue.async {
            let image = Self.cropImage(image, inRect: rect)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    @objc public static func asyncRotateImage(_ image:UIImage,withRadians radians:CGFloat,completion:@escaping (UIImage)->Void){
        Self.ezcropUtilitiesQueue.async {
            let image = Self.rotateImage(image, withRadians: radians)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    @objc public static func rotateImage(_ image:UIImage,withRadians radians:CGFloat) -> UIImage{
        if(radians == 0){
            return image
        }
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap.rotate(by: radians)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(image.cgImage!, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    @objc public static func cropImage(_ image:UIImage, inRect rect:CGRect) -> UIImage{
        guard let cgImage = image.cgImage else {
            return image
        }
        let coordinate = CGRect(origin: .zero, size: image.size)
        let clipedRect = Self.getRectWith(minX: min(coordinate.maxX,max(rect.minX,coordinate.minX)),
                                          minY: min(coordinate.maxY,max(rect.minY,coordinate.minY)),
                                          maxX: min(coordinate.maxX,max(rect.maxX,coordinate.minX)),
                                          maxY: min(coordinate.maxY,max(rect.maxY,coordinate.minY)))
        guard let croppedCGImage = cgImage.cropping(to: clipedRect) else {
            return image
        }
        return UIImage(cgImage: croppedCGImage)
    }

    @objc public static func cropImage(_ image:UIImage, inRect rect:CGRect,thenRotate radians:CGFloat) -> UIImage{
        return Self.rotateImage(Self.cropImage(image, inRect: rect), withRadians: radians) 
    }

    @objc public static func getRectWith(minX:CGFloat, minY:CGFloat,maxX:CGFloat,maxY:CGFloat) -> CGRect{
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }

    @objc public static func calculateScaleOf(size:CGSize, aspectFitToSize sizeToFit:CGSize) -> CGFloat {
        let v_scale = sizeToFit.height / size.height
        let h_scale = sizeToFit.width / size.width
        return min(v_scale, h_scale)
    }

    @objc public static func calculateScaleOf(size:CGSize, aspectFillToSize sizeToFit:CGSize) -> CGFloat {
        let v_scale = sizeToFit.height / size.height
        let h_scale = sizeToFit.width / size.width
        return max(v_scale, h_scale)
    }
    @objc public static func transformCropFrame(_ cropFrame:CGRect,withCoordinate coordinate:CGRect, byRotation rotation:EZCropRotation, scale:CGFloat) -> CGRect{
        let rotated_rect = Self.rotate(rotation, rectangle: cropFrame, withCoordinate: coordinate)
        return Self.scale(scale, rectangle: rotated_rect)
    }
    @objc public static func rotate(_ rotation:EZCropRotation, rectangle rect:CGRect, withCoordinate coordinate:CGRect) -> CGRect {
        if rotation == .zero{
            return rect
        }
        let transform_matrix = Self.getTranformOfRotate(rotation, withCoordinate: coordinate)
        return rect.applying(transform_matrix)
    }
    @objc public static func scale(_ scale:CGFloat, rectangle rect:CGRect) -> CGRect {
        return Self.scale(scale, rectangle: rect, atPoint: CGPoint(x: rect.midX, y: rect.midY))
    }
    @objc public static func scale(_ scale:CGFloat, rectangle rect:CGRect,atPoint point:CGPoint) ->CGRect {
        let transform_matrix = Self.getTranformOfScale(scale, atPoint: point)
        return rect.applying(transform_matrix)
    }

    @objc public static func getTranformOfScale(_ scale:CGFloat, atPoint point:CGPoint, thenRotate rotation:EZCropRotation, inCoordinate coordinate:CGRect) -> CGAffineTransform
    {
        return Self.getTranformOfScale(scale, atPoint: point).concatenating(Self.getTranformOfRotate(rotation, withCoordinate: coordinate))
    }

    @objc public static func getTranformOfRotate(_ rotation:EZCropRotation, withCoordinate coordinate:CGRect) -> CGAffineTransform {
        if(rotation == .zero){
            return .identity
        }
        var transform_matrix = CGAffineTransform.identity.translatedBy(x: -coordinate.midX, y: -coordinate.midY).concatenating(rotation.transform)
        let tranformedCoordinate = coordinate.applying(transform_matrix)
        transform_matrix = transform_matrix.concatenating(
            CGAffineTransform.identity.translatedBy(
                x: tranformedCoordinate.width/2,
                y: tranformedCoordinate.height/2))
        return transform_matrix
    }

    @objc public static func getTranformOfScale(_ scale:CGFloat, atPoint point:CGPoint) -> CGAffineTransform {
        if(scale == 1){
            return .identity
        }
        return CGAffineTransform.identity
            .translatedBy(x: -point.x, y: -point.y)
            .concatenating(CGAffineTransform.identity.scaledBy(x: scale, y: scale))
            .concatenating(CGAffineTransform.identity.translatedBy(x: point.x, y: point.y))
    }

    @objc public static func rotateRotation(_ rotation:EZCropRotation, clockwise:Bool) -> EZCropRotation{
        return rotation.rotateClockwise(clockwise)
    }

    @objc public static func angleOfRotation(_ rotation:EZCropRotation) -> CGFloat{
        return rotation.angle
    }

}
