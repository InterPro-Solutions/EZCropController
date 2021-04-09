//
//  ViewController.swift
//  EZCropExample
//
//  Created by Xiang Li on 4/8/21.
//

import UIKit
import EZCropController

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let imageView = UIImageView()
    private var image: UIImage?

    private var croppedRect = CGRect.zero
    private var croppedAngle : EZCropRotation = .zero

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        self.shouldAutorotate
        let cropController =  EZCropController(image:image) //CropViewController(croppingStyle: croppingStyle, image: image)
        //cropController.modalPresentationStyle = .fullScreen
        cropController.delegate = self

        self.image = image

        //If profile picture, push onto the same navigation stack
        picker.dismiss(animated: true, completion: {
            UIViewController.swizzleShouldAutorotate()
            self.present(cropController, animated: true, completion: nil)
            //self.navigationController!.pushViewController(cropController, animated: true)
        })
    }

    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: EZCropController) {
        imageView.image = image
        layoutImageView()

        self.navigationItem.leftBarButtonItem?.isEnabled = true

        self.imageView.isHidden = false
        cropViewController.dismiss(animated: true, completion: {
            UIViewController.swizzleShouldAutorotate()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("CropViewController", comment: "")
        navigationController!.navigationBar.isTranslucent = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(sender:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
        navigationItem.leftBarButtonItem?.isEnabled = false

        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        if #available(iOS 11.0, *) {
            imageView.accessibilityIgnoresInvertColors = true
        }
        view.addSubview(imageView)

        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapImageView))
        imageView.addGestureRecognizer(tapRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc public func addButtonTapped(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }

    @objc public func didTapImageView() {
        // When tapping the image view, restore the image to the previous cropping state
        let cropViewController = EZCropController(image: self.image!, cropRect: self.croppedRect, angle: self.croppedAngle)
        cropViewController.delegate = self
        UIViewController.swizzleShouldAutorotate()
        self.present(cropViewController, animated: true, completion: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutImageView()
    }

    public func layoutImageView() {
        guard imageView.image != nil else { return }

        let padding: CGFloat = 20.0

        var viewFrame = self.view.bounds
        viewFrame.size.width -= (padding * 2.0)
        viewFrame.size.height -= ((padding * 2.0))

        var imageFrame = CGRect.zero
        imageFrame.size = imageView.image!.size;

        if imageView.image!.size.width > viewFrame.size.width || imageView.image!.size.height > viewFrame.size.height {
            let scale = min(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height)
            imageFrame.size.width *= scale
            imageFrame.size.height *= scale
            imageFrame.origin.x = (self.view.bounds.size.width - imageFrame.size.width) * 0.5
            imageFrame.origin.y = (self.view.bounds.size.height - imageFrame.size.height) * 0.5
            imageView.frame = imageFrame
        }
        else {
            self.imageView.frame = imageFrame;
            self.imageView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        }
    }

    @objc public func sharePhoto() {
        guard let image = imageView.image else {
            return
        }

        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem!
        present(activityController, animated: true, completion: nil)
    }
}

extension ViewController :  EZCropControllerDelegate{
    func cropViewControllerCancel(_ cropViewController: EZCropController) {
        cropViewController.dismiss(animated: true, completion: {
            UIViewController.swizzleShouldAutorotate()
        })
    }

    internal func cropViewController(_ cropViewController: EZCropController, didCropTo image: UIImage, with cropRect: CGRect, angle: EZCropRotation) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
}

