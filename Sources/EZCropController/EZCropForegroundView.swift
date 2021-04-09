//
//  EZCropForegroundView.swift
//  
//
//  Created by Xiang Li on 4/2/21.
//


import UIKit



public class EZCropForegroundView : UIView{

    private var imageView = UIImageView()
    private var container = UIView()
    internal weak var cropView:EZCropView!

    @objc public init(){
        super.init(frame: .zero)
        self.imageView.contentMode = .scaleToFill
        self.container.clipsToBounds = true
        self.addSubview(self.container)
        self.container.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setImage(_ image:UIImage){
        self.imageView.image = image
    }

    @objc public func setCropFrame(_ rect:CGRect){
        self.container.frame = rect
        self.syncImageViewFrame()
        self.layoutIfNeeded()
    }

    @objc public func syncImageViewFrame(){
        let frame = self.cropView.backgroundContainer.convert(self.cropView.backgroundImageView.frame, to: self.container)
        self.imageView.frame = frame
    }
}

