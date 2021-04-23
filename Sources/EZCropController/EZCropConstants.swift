//
//  File.swift
//  
//
//  Created by Xiang Li on 3/26/21.
//

import Foundation
import UIKit

/*public struct EZCropRatio {
    public let width:CGFloat
    public let height:CGFloat
    public func reverse() -> EZCropRatio{
        return EZCropRatio(width: self.height, height: self.width)
    }
}*/
@objc public enum EZCropRotation : Int8 {
    case zero = 0
    case ninty
    case oneHundredAndEighty
    case twoHunderdAndSeventy

    var angle:CGFloat {
        var angle : CGFloat = 0;
        switch self {
        case .ninty:
            angle = .pi / 2
        case .oneHundredAndEighty:
            angle = .pi
        case .twoHunderdAndSeventy:
            angle = (CGFloat.pi * 1.5)
        default:
            angle = 0
        }
        return angle
    }

    var transform:CGAffineTransform {
        return CGAffineTransform.identity.rotated(by: angle)
    }

    public func rotateClockwise(_ clockwise:Bool) -> EZCropRotation{
        let result = clockwise ? (rawValue+1):(rawValue-1)
        return EZCropRotation(rawValue: self.mod4(result))!
    }
    private func mod4(_ left:Int8) -> Int8{
        let right:Int8 = 4
        if left >= 0 { return left % right }
        if left >= -right { return (left+right) }
        return ((left % right)+right)%right
    }
}

@frozen
enum EZCropOverlayViewEdge {
    case none
    case topLeft
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
    case left
}

internal enum EZCropEvent {
    case resize
    case rotate
    case ratio
    case reset
    case touchOnCropScrollView
    case touchOffCropScrollView
    case noInteractionAwhile
}


public enum EZCropLayoutStyle {
    case vertical
    case horizontal
}


