//
//  EZCropVIew.swift
//  
//
//  Created by Xiang Li on 3/25/21.
//

import UIKit

internal final class EZCropView : UIView {



    //MARK: internal properties
    @objc internal var animating = false
    @objc internal var rotation : EZCropRotation = .zero



    //MARK: internal computed properties

    @objc dynamic internal var imageCropFrame : CGRect {
        set {
            if stopUpdateCropFrame == false{
                self._imageCropFrame = newValue
            }
        }
        get {
            return self._imageCropFrame
        }
    }

    @objc internal var image : UIImage {
        return _image
    }

    @objc internal var imageSize : CGSize {
        return self._image.size
    }

    @objc internal var backgroundImageView : UIImageView{
        return _backgroundImageView
    }
    @objc internal var backgroundContainer : UIScrollView{
        return self._backgroundContainer
    }
    @objc internal var foregroundContainer : EZCropForegroundView{
        return self._foregroundContainer
    }
    @objc internal var blurView : UIView {
        return self._blurView
    }
    @objc internal var overlay : EZCropOverlayView {
        return self._overlay
    }

    @objc internal var contentInsets : UIEdgeInsets = .zero

    @objc internal var adjustedContentInsets : UIEdgeInsets {
        let safeAreaInsets = self.safeAreaInsets
        return UIEdgeInsets(top: safeAreaInsets.top+self.contentInsets.top,
                            left: safeAreaInsets.left+self.contentInsets.left,
                            bottom: safeAreaInsets.bottom+self.contentInsets.bottom,
                            right: safeAreaInsets.right+self.contentInsets.right)
    }

    internal var cropAdjustingDelay:TimeInterval = 0.8

    internal var stopUpdateCropFrame : Bool = false

    //MARK: private properties
    private var intialized = false
    private var scrollingByUser = false
    private var resetTimer : Timer?
    private var needReset = true
    private let _image : UIImage
    private static let payGestureOfOverlayActiveWidth : CGFloat = 22
    private var keyValueObservationSet = Set<NSKeyValueObservation>()

    private let commandProcessor : EZCropProcessor
    private var _imageCropFrame : CGRect = .zero

    //MARK: private properties-layouts
    private var backgroundContainerLeadingArchor : NSLayoutConstraint!
    private var backgroundContainerTopArchor : NSLayoutConstraint!
    private var backgroundContainerHeightArchor : NSLayoutConstraint!
    private var backgroundContainerWidthArchor  : NSLayoutConstraint!

    private var foregroundContainerLeadingArchor : NSLayoutConstraint!
    private var foregroundContainerTopArchor  : NSLayoutConstraint!
    private var foregroundContainerHeightArchor : NSLayoutConstraint!
    private var foregroundContainerWidthArchor  : NSLayoutConstraint!



    //MARK: Views
    private let _backgroundImageView : UIImageView = UIImageView()
    private let _backgroundContainer : UIScrollView = UIScrollView()
    private let _blurView : UIVisualEffectView = UIVisualEffectView()
    private let _overlay : EZCropOverlayView = EZCropOverlayView()
    private let _foregroundContainer = EZCropForegroundView()


    //MARK: initialization
    static func instantiateByImage(_ image:UIImage,commandProcessor : EZCropProcessor) -> EZCropView{
        return EZCropView(image: image,commandProcessor:commandProcessor)
    }
    required init?(coder: NSCoder) {
        fatalError("Please static func \"instantiateByImage\" to initialized the EZCropVIew")
    }
    private override init(frame: CGRect) {
        fatalError("Please static func \"instantiateByImage\" to initialized the EZCropVIew")
    }
    private init(){
        fatalError("Please static func \"instantiateByImage\" to initialized the EZCropVIew")
    }
    private init(image:UIImage,commandProcessor : EZCropProcessor){
        self._imageCropFrame = CGRect(origin: .zero, size: image.size)
        self._image = image
        self.commandProcessor = commandProcessor
        super.init(frame: .zero)
        self.commandProcessor.cropView = self
        // initialized scroll container
        self._backgroundContainer.translatesAutoresizingMaskIntoConstraints = false
        self._backgroundContainer.clipsToBounds = false
        self._backgroundContainer.showsVerticalScrollIndicator = false
        self._backgroundContainer.showsHorizontalScrollIndicator = false
        self._backgroundContainer.alwaysBounceHorizontal = true
        self._backgroundContainer.alwaysBounceVertical = true
        self._backgroundContainer.decelerationRate = .fast
        self._backgroundContainer.delegate = self;
        self._backgroundContainer.contentInsetAdjustmentBehavior = .always
        self._backgroundContainer.minimumZoomScale = 0.1
        self.backgroundContainerLeadingArchor = self._backgroundContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
        self.backgroundContainerTopArchor = self._backgroundContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        self.backgroundContainerHeightArchor = self._backgroundContainer.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height)
        self.backgroundContainerWidthArchor = self._backgroundContainer.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        let contentObserver = self.backgroundContainer.observe(\.contentOffset, options: .new, changeHandler: {
            [weak self] scrollView,value in
            guard let self = self else {return}
            if(self.intialized == true){

                self.syncBackgroundToForeground()
            }
            if(self.scrollingByUser == true){
                self.syncImageCropFrameWithCurrentBackgroundContainer()
            }
        })
        let centerObserver = self.backgroundContainer.observe(\.center, options: .new, changeHandler: {
            [weak self] scrollView,value in
            guard let self = self else {return}
            if(self.intialized == true){
                self.syncBackgroundToForeground()
            }
        })
        self.keyValueObservationSet.insert(contentObserver)
        self.keyValueObservationSet.insert(centerObserver)
        self.addSubview(_backgroundContainer)
        // initial backgroundImageView
        self._backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self._backgroundImageView.contentMode = .scaleAspectFit
        self._backgroundContainer.addSubview(self._backgroundImageView)

        // initial Blur View
        self._blurView.isUserInteractionEnabled = false
        self._blurView.effect = UIBlurEffect(style: .dark)
        self._blurView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self._blurView)

        //initial foregroundView
        self.foregroundContainer.cropView = self
        self.foregroundContainer.isUserInteractionEnabled = false
        self.foregroundContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.foregroundContainer)

        // initial Overlay View
        self.overlay.translatesAutoresizingMaskIntoConstraints = false
        self.overlay.isUserInteractionEnabled = false
        self.addSubview(self.overlay)
        NSLayoutConstraint.activate([
            // scrollView layout
            self.backgroundContainerLeadingArchor,
            self.backgroundContainerTopArchor,
            self.backgroundContainerHeightArchor,
            self.backgroundContainerWidthArchor,
            //overlay layout
            self.leadingAnchor.constraint(equalTo: self._overlay.leadingAnchor),
            self.topAnchor.constraint(equalTo: self._overlay.topAnchor),
            self.trailingAnchor.constraint(equalTo: self._overlay.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: self._overlay.bottomAnchor),
            //imageView
            self._backgroundImageView.leadingAnchor.constraint(equalTo: self._backgroundContainer.leadingAnchor),
            self._backgroundImageView.trailingAnchor.constraint(equalTo: self._backgroundContainer.trailingAnchor),
            self._backgroundImageView.topAnchor.constraint(equalTo: self._backgroundContainer.topAnchor),
            self._backgroundImageView.bottomAnchor.constraint(equalTo: self._backgroundContainer.bottomAnchor),
            //blureView
            self._blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self._blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self._blurView.topAnchor.constraint(equalTo: self.topAnchor),
            self._blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            // foregroundcontainer
            self.leadingAnchor.constraint(equalTo: self._foregroundContainer.leadingAnchor),
            self.topAnchor.constraint(equalTo: self._foregroundContainer.topAnchor),
            self.trailingAnchor.constraint(equalTo: self._foregroundContainer.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: self._foregroundContainer.bottomAnchor),
        ])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureOfOverlay(_:)))
        panGesture.delegate = self
        self._backgroundContainer.panGestureRecognizer.require(toFail: panGesture)
        self.addGestureRecognizer(panGesture)
    }
    deinit {
        for observer in self.keyValueObservationSet{
            observer.invalidate()
        }
    }

    //MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.intialized == false{

            self.apsectScaleFitCroppedImage()
            self.intialized = true
        }
    }

    public func fitCroppedImageToCropBox(){
        let croppedBoxInCropView = self.overlay.convert(self.overlay.cropBoxFrame, to: self)
        let originalCoordinate = CGRect(origin: .zero, size: self.image.size)
        let rotatedFrame = EZCropUtilities.rotate(self.rotation, rectangle: self.imageCropFrame, withCoordinate: originalCoordinate)
        let rotatedCoordinate = EZCropUtilities.rotate(self.rotation, rectangle: originalCoordinate, withCoordinate: originalCoordinate)
        let scale = EZCropUtilities.calculateScaleOf(size: rotatedFrame.size, aspectFitToSize: croppedBoxInCropView.size)
        let minimumScale = EZCropUtilities.calculateScaleOf(size: rotatedCoordinate.size, aspectFillToSize: croppedBoxInCropView.size)

        let rotatedImage = EZCropUtilities.rotateImage(self.image, withRadians: self.rotation.angle)//self.image.rotate(radians: self.rotation.angle)

        self.foregroundContainer.setImage(rotatedImage)
        let foregroundContainerFrame = self.overlay.convert(self.overlay.cropBoxFrame, to: foregroundContainer)
        self.foregroundContainer.setCropFrame(foregroundContainerFrame)

        self.backgroundContainerLeadingArchor.constant = croppedBoxInCropView.minX
        self.backgroundContainerTopArchor.constant = croppedBoxInCropView.minY
        self.backgroundContainerHeightArchor.constant =  croppedBoxInCropView.height
        self.backgroundContainerWidthArchor.constant = croppedBoxInCropView.width


        self._backgroundImageView.image = rotatedImage//self.image.rotate(radians: self.rotation.angle)
        self._backgroundContainer.contentSize = rotatedCoordinate.size
        self._backgroundContainer.minimumZoomScale = minimumScale
        self._backgroundContainer.maximumZoomScale = scale * 15
        self._backgroundContainer.zoomScale = scale
        self._backgroundContainer.contentOffset = rotatedFrame.origin.applying(CGAffineTransform.identity.scaledBy(x: scale, y: scale))

        self.setNeedsDisplay()
    }

    public func syncImageCropFrameWithCurrentBackgroundContainer(){
        let cropdBoxInImageView = self._overlay.convert(self.overlay.cropBoxFrame, to: self.backgroundImageView)
        let tranform = EZCropUtilities.getTranformOfRotate(self.rotation, withCoordinate: CGRect(origin: .zero, size: self.imageSize)).inverted()
        let cropBoxInOrginImage = cropdBoxInImageView.applying(tranform)
        self.imageCropFrame = cropBoxInOrginImage
    }

    public func apsectScaleFitCroppedImage(animated:Bool = false){
        self.cancelResetTimer()
        let adjustsafeInset = self.adjustedContentInsets//self.safeAreaInsets
        
        let safeHeight = self.bounds.height - adjustsafeInset.top - adjustsafeInset.bottom
        let safeWidth = self.bounds.width - adjustsafeInset.left - adjustsafeInset.right
        let originalCoordinate = CGRect(origin: .zero, size: self.image.size)
        let rotatedFrame = EZCropUtilities.rotate(self.rotation, rectangle: self.imageCropFrame, withCoordinate: originalCoordinate)
        let rotatedCoordinate = EZCropUtilities.rotate(self.rotation, rectangle: originalCoordinate, withCoordinate: originalCoordinate)
        let scale = EZCropUtilities.calculateScaleOf(size: rotatedFrame.size, aspectFitToSize: CGSize(width: safeWidth, height: safeHeight))

        let scaledHeight = rotatedFrame.height * scale
        let scaledWidth = rotatedFrame.width * scale
        let leadingConstant = adjustsafeInset.left+(safeWidth-scaledWidth)/2
        let topConstant = adjustsafeInset.top+(safeHeight-scaledHeight)/2

        let minimumScale = EZCropUtilities.calculateScaleOf(size: rotatedCoordinate.size, aspectFillToSize: CGSize(width: scaledWidth, height: scaledHeight))

        self.backgroundContainerLeadingArchor.constant = leadingConstant
        self.backgroundContainerTopArchor.constant = topConstant
        self.backgroundContainerHeightArchor.constant =  scaledHeight
        self.backgroundContainerWidthArchor.constant = scaledWidth

        self.layoutIfNeeded()
        let rotatedImage = EZCropUtilities.rotateImage(self.image, withRadians: self.rotation.angle)//self.image.rotate(radians: self.rotation.angle)
        self._backgroundImageView.image = rotatedImage//self.image.rotate(radians: self.rotation.angle)
        self._backgroundImageView.sizeToFit()
        self._backgroundContainer.contentSize = rotatedCoordinate.size
        self._backgroundContainer.minimumZoomScale = minimumScale
        self._backgroundContainer.maximumZoomScale = scale * 15
        self._backgroundContainer.zoomScale = scale
        let scaledFrame = rotatedFrame.origin.applying(CGAffineTransform.identity.scaledBy(x: scale, y: scale))
        self._backgroundContainer.contentOffset = scaledFrame
        let cropBox = CGRect(x: leadingConstant, y: topConstant, width: scaledWidth, height: scaledHeight)
        self._overlay.setCropBoxFrame(self.convert(cropBox, to: self._overlay), animated: animated)

        self._backgroundContainer.layoutIfNeeded()
        let foregroundContainerCropFrame = self.convert(cropBox, to: self.foregroundContainer)
        self._foregroundContainer.setImage(rotatedImage)
        self._foregroundContainer.setCropFrame(foregroundContainerCropFrame)

        self._foregroundContainer.layoutIfNeeded()
        self._overlay.layoutIfNeeded()
    }

    //MARK: public function
    public func hideSubView(_ hide:Bool){
        self._backgroundContainer.isHidden = hide
        self._blurView.isHidden = hide
        self._foregroundContainer.isHidden = hide
        self._overlay.isHidden = hide
    }



    //MARK: gesture
    @objc func panGestureOfOverlay(_ gesture:UIPanGestureRecognizer){
        self.commandProcessor.execute(event: .resize, params: (gesture,nil))
        if gesture.state == .ended{
            self.needReset = true
            self.startResetTimer()
        }
    }

    @objc func timerTriggered(){
        self.needReset = false
        self.commandProcessor.execute(event: .noInteractionAwhile, params: (nil,nil))
    }

    //MARK: private func
    private func syncBackgroundToForeground(){
        self.foregroundContainer.syncImageViewFrame()

    }

    private func startResetTimer(){
        guard
            self.resetTimer == nil
        else {
            return
        }
        self.resetTimer = Timer(timeInterval: self.cropAdjustingDelay, target: self, selector: #selector(timerTriggered), userInfo: nil, repeats: false)
        RunLoop.current.add(self.resetTimer!, forMode: .default)
    }

    private func cancelResetTimer(){
        self.resetTimer?.invalidate()
        self.resetTimer = nil
    }
}

//MARK: UIScrollViewDelegate
extension EZCropView : UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self._backgroundImageView
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollingByUser = true
        self.cancelResetTimer()
        self.commandProcessor.dispatchCommand(event: .touchOnCropScrollView, params: (nil,nil))
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(decelerate == false){
            if self.needReset == true
            {
                self.startResetTimer()
            }
            self.syncImageCropFrameWithCurrentBackgroundContainer()
            self.commandProcessor.execute(event: .touchOffCropScrollView, params: (nil,nil))
            self.scrollingByUser = false
        }
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.needReset == true
        {
            self.startResetTimer()
        }
        self.syncImageCropFrameWithCurrentBackgroundContainer()
        self.commandProcessor.execute(event: .touchOffCropScrollView, params: (nil,nil))
        self.scrollingByUser = false
    }
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.cancelResetTimer()
        self.commandProcessor.execute(event: .touchOnCropScrollView, params: (nil,nil))
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.syncImageCropFrameWithCurrentBackgroundContainer()
    }
}

extension EZCropView : UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            self.backgroundContainer.isDecelerating == false,
            let panGesture = gestureRecognizer as? UIPanGestureRecognizer
        else {
            return false
        }
        let tapPoint = panGesture.location(in: self.overlay)
        let cropBox = self.overlay.cropBoxFrame
        let innerBox = cropBox.insetBy(dx: Self.payGestureOfOverlayActiveWidth, dy: Self.payGestureOfOverlayActiveWidth)
        let outerBox = cropBox.insetBy(dx: -Self.payGestureOfOverlayActiveWidth, dy: -Self.payGestureOfOverlayActiveWidth)
        if innerBox.contains(tapPoint) || outerBox.contains(tapPoint) == false {
            return false
        }
        self.cancelResetTimer()
        return true
    }
}
