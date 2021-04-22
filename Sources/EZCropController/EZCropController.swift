//
//  File.swift
//  
//
//  Created by Xiang Li on 3/25/21.
//

import UIKit
import Combine

@objc public protocol EZCropControllerDelegate {
    @objc func cropViewControllerCancel(_ cropViewController: EZCropController)
    @objc optional func cropViewController(_ cropViewController: EZCropController, didCropTo image: UIImage, with cropRect: CGRect, angle: EZCropRotation)
}

public final class EZCropController : UIViewController {
    @objc public weak var delegate : EZCropControllerDelegate?
    @objc public var cropView:EZCropView!
    
    private var toolbar : EZCropAbstractToolbar
    private let commandProcessor : EZCropProcessor
    private var toolbarVerticalLayouts : [NSLayoutConstraint]!
    private var toolbarHorizontalLayouts : [NSLayoutConstraint]!

    private var accessoryBar : EZCropAbstractAccessoryView?
    private var accessoryViewVerticalLayouts : [NSLayoutConstraint]?
    private var accessoryViewHorizontalLayouts : [NSLayoutConstraint]?

    public override var shouldAutorotate: Bool {
        print("\(commandProcessor.isRotateCropViewWithOrientationEnable)")
        return commandProcessor.isRotateCropViewWithOrientationEnable
    }


    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }


    @objc public convenience init(image:UIImage){
        self.init(image: image, toolbar: EZCropDefaultToolbar())
    }

    @objc public convenience init(image:UIImage,
                            cropRect:CGRect,
                            angle:EZCropRotation)
    {
        self.init(image: image, toolbar: EZCropDefaultToolbar())
        self.cropView.imageCropFrame = cropRect
        self.cropView.rotation = angle
    }

    @objc public convenience init(image:UIImage,
                            cropRect:CGRect,
                            angle:EZCropRotation,
                            toolbar : EZCropAbstractToolbar)
    {
        self.init(image: image, toolbar: toolbar)
        self.cropView.imageCropFrame = cropRect
        self.cropView.rotation = angle
    }

    @objc public init(image:UIImage,
                toolbar : EZCropAbstractToolbar){
        self.commandProcessor = EZCropProcessor()
        toolbar._processor = commandProcessor
        self.toolbar = toolbar
        super.init(nibName: nil, bundle: nil)
        toolbar.cropController = self
        let orientedImage = image.fixedOrientation()
        cropView = EZCropView.instantiateByImage(orientedImage, commandProcessor: commandProcessor)

        self.commandProcessor.observeRotateCropViewWithOrientationEnable{
            [weak self]isEnable in
            guard let self = self else {return}
            if(isEnable == true){
                EZCropController.attemptRotationToDeviceOrientation()
            }
        }


    }

    @objc public init(){
        fatalError("Please use ")
    }

    internal required init?(coder: NSCoder) {
        fatalError("Please use 'init(image: UIImage)'")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.view.backgroundColor = .black
        self.view.addSubview(cropView)
        self.cropView.translatesAutoresizingMaskIntoConstraints = false
        self.toolbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.toolbar)

        toolbar.cancelTapped = {
            [weak self] in
            guard let self = self else {return}
            self.delegate?.cropViewControllerCancel(self)
        }

        toolbar.resetButtonTapped = {
            [weak self] in
            guard
                let self = self,
                self.commandProcessor.ongoingCommand == nil
            else {return}
            return
        }

        toolbar.rotatedButtonTapped = {
            [weak self] clockwise in
            guard
                let self = self,
                self.commandProcessor.ongoingCommand == nil
            else {return}
            self.commandProcessor.execute(event: .rotate, params: (nil,["rotationClockwise":clockwise]))
        }

        toolbar.showAccessoryView = {
            [weak self] accessoryview in
            guard let self = self else {return}
            self.accessoryBar = accessoryview
            accessoryview.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(accessoryview)
            self.accessoryViewHorizontalLayouts = [
                accessoryview.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                accessoryview.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                accessoryview.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            ]
            self.accessoryViewVerticalLayouts = [
                accessoryview.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                accessoryview.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                accessoryview.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            ]

            if self.view.bounds.width > self.view.bounds.height {
                if
                    let accessoryBar = self.accessoryBar,
                    let accessoryViewVerticalLayouts = self.accessoryViewVerticalLayouts,
                    let accessoryViewHorizontalLayouts = self.accessoryViewHorizontalLayouts
                {
                    self.cropView.contentInsets = UIEdgeInsets(top: 5, left: 5 + self.toolbar.verticalWidth, bottom: 5, right: 5 + accessoryBar.verticalWidth)
                    NSLayoutConstraint.deactivate(accessoryViewHorizontalLayouts)
                    NSLayoutConstraint.activate(accessoryViewVerticalLayouts)
                }
                else {
                    self.cropView.contentInsets = UIEdgeInsets(top: 5, left: 5 + self.toolbar.verticalWidth, bottom: 5, right: 5)
                }
            }
            else
            {
                if
                    let accessoryBar = self.accessoryBar,
                    let accessoryViewVerticalLayouts = self.accessoryViewVerticalLayouts,
                    let accessoryViewHorizontalLayouts = self.accessoryViewHorizontalLayouts
                {
                    NSLayoutConstraint.deactivate(accessoryViewVerticalLayouts)
                    NSLayoutConstraint.activate(accessoryViewHorizontalLayouts)
                    self.cropView.contentInsets = UIEdgeInsets(top: 5 + self.toolbar.horizontalHeight, left: 5, bottom: 5 + accessoryBar.horizontalHeight, right: 5)
                }
                else {
                    self.cropView.contentInsets = UIEdgeInsets(top: 5 + self.toolbar.horizontalHeight, left: 5, bottom: 5, right: 5)
                }
            }
            self.view.layoutIfNeeded()
            accessoryview.isHidden = true
            self.view.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.5, animations: {
                [weak self] in
                guard let self = self else {return}
                accessoryview.isHidden = false

                self.cropView.apsectScaleFitCroppedImage(animated: true)
            }, completion: {
                [weak self] finished in
                guard let self = self else {return}
                self.view.isUserInteractionEnabled = true
            })
            return
        }

        toolbar.hiddenAccessoryView = {
            [weak self] in
            guard
                let self = self,
                let accessoryBar = self.accessoryBar
            else {return}
            self.view.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.5, animations: {
                [weak self] in
                guard
                    let self = self
                else {return}
                accessoryBar.isHidden = true
                if self.view.bounds.width > self.view.bounds.height {
                    self.cropView.contentInsets = UIEdgeInsets(top: 5, left: 5 + self.toolbar.verticalWidth, bottom: 5, right: 5)
                }
                else
                {
                    self.cropView.contentInsets = UIEdgeInsets(top: 5 + self.toolbar.horizontalHeight, left: 5, bottom: 5, right: 5)
                }
                self.cropView.apsectScaleFitCroppedImage(animated: true)
            }, completion: {
                [weak self] finished in
                accessoryBar.removeFromSuperview()
                self?.accessoryViewHorizontalLayouts = nil
                self?.accessoryViewHorizontalLayouts = nil
                self?.view.isUserInteractionEnabled = true
            })
        }

        toolbar.doneTapped = {
            [weak self] in
            guard let self = self else {return}
            let image = self.cropView.image
            let rect = self.cropView.imageCropFrame
            let coordinate = CGRect(origin: .zero, size: image.size)
            let clipedRect = EZCropUtilities.getRectWith(minX: min(coordinate.maxX,max(rect.minX,coordinate.minX)),
                                              minY: min(coordinate.maxY,max(rect.minY,coordinate.minY)),
                                              maxX: min(coordinate.maxX,max(rect.maxX,coordinate.minX)),
                                              maxY: min(coordinate.maxY,max(rect.maxY,coordinate.minY)))
            let croppedImage = EZCropUtilities.cropImage(image, inRect: clipedRect, thenRotate: self.cropView.rotation.angle)
            self.delegate?.cropViewController?(self, didCropTo: croppedImage, with: clipedRect, angle: self.cropView.rotation)
        }
        toolbar.setRatio = {
            [weak self] ratio in
            guard
                let self = self,
                self.commandProcessor.ongoingCommand == nil
            else {return}
            self.commandProcessor.execute(event: .ratio, params: (nil,["ratio":ratio]))
        }
        NSLayoutConstraint.activate([
            self.cropView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.cropView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.cropView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.cropView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        self.toolbarVerticalLayouts = [
            self.toolbar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.toolbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.toolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ]
        self.toolbarHorizontalLayouts = [
            self.toolbar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.toolbar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.toolbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ]

    }



    public override func viewDidLayoutSubviews() {
        self.layoutViews()
        super.viewDidLayoutSubviews()
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.isUserInteractionEnabled = false
        self.cropView.backgroundContainer.setContentOffset(self.cropView.backgroundContainer.contentOffset, animated: false)
        self.cropView.stopUpdateCropFrame = true
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {
            [weak self] context in
            self?.cropView.apsectScaleFitCroppedImage(animated: false)
        }, completion: {
            [weak self] context in
            self?.cropView.stopUpdateCropFrame = false
            self?.view.isUserInteractionEnabled = true
        })
    }



    func adjustOrientationIfNeeded() {
        UIDevice.current
          .setValue(self.preferredInterfaceOrientationForPresentation.rawValue,
                    forKey: "orientation")  
    }

    private func layoutViews(){
        if self.view.bounds.width > self.view.bounds.height {
            NSLayoutConstraint.deactivate(self.toolbarHorizontalLayouts)
            NSLayoutConstraint.activate(self.toolbarVerticalLayouts)
            if
                let accessoryBar = self.accessoryBar,
                let accessoryViewVerticalLayouts = self.accessoryViewVerticalLayouts,
                let accessoryViewHorizontalLayouts = self.accessoryViewHorizontalLayouts
            {
                cropView.contentInsets = UIEdgeInsets(top: 5, left: 5 + self.toolbar.verticalWidth, bottom: 5, right: 5 + accessoryBar.verticalWidth)
                NSLayoutConstraint.deactivate(accessoryViewHorizontalLayouts)
                NSLayoutConstraint.activate(accessoryViewVerticalLayouts)
            }
            else {
                cropView.contentInsets = UIEdgeInsets(top: 5, left: 5 + self.toolbar.verticalWidth, bottom: 5, right: 5)
            }
        }
        else
        {
            NSLayoutConstraint.deactivate(self.toolbarVerticalLayouts)
            NSLayoutConstraint.activate(self.toolbarHorizontalLayouts)
            if
                let accessoryBar = self.accessoryBar,
                let accessoryViewVerticalLayouts = self.accessoryViewVerticalLayouts,
                let accessoryViewHorizontalLayouts = self.accessoryViewHorizontalLayouts
            {
                NSLayoutConstraint.deactivate(accessoryViewVerticalLayouts)
                NSLayoutConstraint.activate(accessoryViewHorizontalLayouts)
                cropView.contentInsets = UIEdgeInsets(top: 5 + self.toolbar.horizontalHeight, left: 5, bottom: 5 + accessoryBar.horizontalHeight, right: 5)
            }
            else {
                cropView.contentInsets = UIEdgeInsets(top: 5 + self.toolbar.horizontalHeight, left: 5, bottom: 5, right: 5)
            }
        }
    }

    @objc func cancel(){
        self.dismiss(animated: true)
    }

    @objc func done(){

    }

    @objc func rotateClockwise(){
        self.commandProcessor.execute(event: .rotate, params: (nil,["rotationClockwise":true]))
    }

    @objc func rotateCounterClockwise(){
        self.commandProcessor.execute(event: .rotate, params: (nil,["rotationClockwise":false]))
    }

    @objc func ratio(){
        self.commandProcessor.execute(event: .ratio, params: (nil,["ratio":CGFloat(1)]))
    }
}
