//
//  EZCropOverlayView.swift
//  
//
//  Created by Xiang Li on 3/25/21.
//

import UIKit



public class EZCropOverlayView : UIView, CAAnimationDelegate{
    public static let cornerLength : CGFloat = 22
    public static let cornerWidth : CGFloat = 4
    private var cropBoxLayer : EZCropOverlayLayer
    private var animationCompletion:((Bool)->Void)?
    @objc public var cropBoxFrame : CGRect  {
        set (value){
            self.cropBoxLayer.cropBoxFrame = value
            self.cropBoxLayer.setNeedsDisplay()
        }
        get {
            self.cropBoxLayer.cropBoxFrame
        }
    }
    

    init(){
        self.cropBoxLayer = EZCropOverlayLayer()
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.clipsToBounds = false
        self.layer.addSublayer(self.cropBoxLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.cropBoxLayer.frame = self.bounds
        self.cropBoxLayer.setNeedsDisplay()
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.cropBoxLayer.frame = self.bounds
        self.cropBoxLayer.setNeedsDisplay()
    }

    @objc public func setCropBoxFrame(_ rect:CGRect, animated:Bool, completion:((Bool)->Void)? = nil ){
        if animated == true {
            let animation = CABasicAnimation(keyPath: #keyPath(EZCropOverlayLayer.cropBoxFrame))
            animation.fromValue = self.cropBoxFrame
            animation.duration = 0.5
            animation.toValue = rect
            animation.isRemovedOnCompletion = true
            animation.fillMode = .removed
            animation.delegate = self
            self.cropBoxLayer.add(animation, forKey: "cropBoxFrameAnimation")
            self.cropBoxFrame = rect
            self.animationCompletion = completion
        }
        else {
            self.cropBoxFrame = rect
        }
    }
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.animationCompletion?(flag)
        self.animationCompletion = nil
    }
}

fileprivate class EZCropOverlayLayer : CALayer{
    @objc dynamic var cropBoxFrame : CGRect = .zero

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        if cropBoxFrame.equalTo(.zero){
            return
        }
        let halfWidth = (EZCropOverlayView.cornerWidth/2)
        let lineWidth = EZCropOverlayView.cornerWidth
        let cornerLength = EZCropOverlayView.cornerLength
        let leftTopPoint = CGPoint(x: cropBoxFrame.minX-1, y: cropBoxFrame.minY-1)
        let rightTopPoint = CGPoint(x: cropBoxFrame.maxX+1, y: cropBoxFrame.minY-1)
        let rightBottomPoint = CGPoint(x: cropBoxFrame.maxX+1, y: cropBoxFrame.maxY+1)
        let leftBottomPoint = CGPoint(x: cropBoxFrame.minX-1, y: cropBoxFrame.maxY+1)
        ctx.setStrokeColor(UIColor.white.cgColor)
        ctx.setLineWidth(1)
        //ctx.setLineDash(phase: 0, lengths: [10,5])

        ctx.strokeLineSegments(between: [leftTopPoint,rightTopPoint])
        ctx.strokeLineSegments(between: [rightTopPoint,rightBottomPoint])
        ctx.strokeLineSegments(between: [rightBottomPoint,leftBottomPoint])
        ctx.strokeLineSegments(between: [leftBottomPoint,leftTopPoint])
        ctx.setLineWidth(EZCropOverlayView.cornerWidth)
        //ctx.setLineDash(phase: 0, lengths: [])
        //left Top corner
        ctx.move(to: CGPoint(x: cropBoxFrame.minX-halfWidth, y: cropBoxFrame.minY+cornerLength))
        ctx.addLine(to: CGPoint(x: cropBoxFrame.minX-halfWidth, y: cropBoxFrame.minY-lineWidth))
        ctx.move(to: CGPoint(x: cropBoxFrame.minX, y: cropBoxFrame.minY-halfWidth))
        ctx.addLine(to: CGPoint(x: cropBoxFrame.minX+cornerLength, y: cropBoxFrame.minY-halfWidth))

        // right top corner
        ctx.move(to: CGPoint(x: cropBoxFrame.maxX-cornerLength, y: cropBoxFrame.minY-halfWidth))
        ctx.addLine(to: CGPoint(x: cropBoxFrame.maxX+lineWidth, y: cropBoxFrame.minY-halfWidth))
        ctx.move(to: CGPoint(x: cropBoxFrame.maxX+halfWidth, y: cropBoxFrame.minY))
        ctx.addLine(to: CGPoint(x: cropBoxFrame.maxX+halfWidth, y: cropBoxFrame.minY+cornerLength))

        // right bottom corner
        ctx.move(to: CGPoint(x: cropBoxFrame.maxX+halfWidth, y: cropBoxFrame.maxY-cornerLength))
        ctx.addLine(to: CGPoint(x: cropBoxFrame.maxX+halfWidth, y: cropBoxFrame.maxY+lineWidth))
        ctx.move(to: CGPoint(x: cropBoxFrame.maxX, y: cropBoxFrame.maxY+halfWidth))
        ctx.addLine(to: CGPoint(x: cropBoxFrame.maxX-cornerLength, y: cropBoxFrame.maxY+halfWidth))


        // left bottom corner
        ctx.move(to: CGPoint(x: cropBoxFrame.minX+cornerLength, y: cropBoxFrame.maxY+halfWidth))
        ctx.addLine(to: CGPoint(x: cropBoxFrame.minX-lineWidth, y: cropBoxFrame.maxY+halfWidth))
        ctx.move(to: CGPoint(x: cropBoxFrame.minX-halfWidth, y: cropBoxFrame.maxY))
        ctx.addLine(to: CGPoint(x: cropBoxFrame.minX-halfWidth, y: cropBoxFrame.maxY-cornerLength))
        ctx.strokePath()
    }

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(EZCropOverlayLayer.cropBoxFrame) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    /*override func action(forKey event: String) -> CAAction? {
        if event == #keyPath(EZCropOverlayLayer.cropBoxFrame) {
            let anim = CABasicAnimation(keyPath: #keyPath(LoadingLayer.percentage))
            anim.byValue = 0.01
            anim.timingFunction = CAMediaTimingFunction(name: .linear)
            anim.fromValue = presentation()?.percentage ?? 0
            return anim
        }
        return super.action(forKey: event)
    }*/

}
