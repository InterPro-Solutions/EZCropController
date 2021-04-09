//
//  File.swift
//  
//
//  Created by Xiang Li on 4/5/21.
//

import UIKit

internal class EZCropDefaultToolbar : EZCropAbstractToolbar {
    internal override func containerView() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let cancelButton = UIButton(type:.system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelEdit), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cancelButton)

        let resetButton = UIButton(type:.system)
        resetButton.isHidden = true
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(resetButton)

        let rotateCountClockwiseButton = UIButton(type:.system)
        if #available(iOS 13.0, *) {
            rotateCountClockwiseButton.setImage(UIImage(systemName: "rotate.left.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        rotateCountClockwiseButton.addTarget(self, action: #selector(rotateCounterClockwise), for: .touchUpInside)
        rotateCountClockwiseButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rotateCountClockwiseButton)

        let rotateClockwiseButton = UIButton(type:.system)
        if #available(iOS 13.0, *) {
            rotateClockwiseButton.setImage(UIImage(systemName: "rotate.right.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        rotateClockwiseButton.addTarget(self, action: #selector(rotateClockwise), for: .touchUpInside)
        rotateClockwiseButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rotateClockwiseButton)

        let ratioButton = UIButton(type:.system)
        if #available(iOS 13.0, *) {
            ratioButton.setImage(UIImage(systemName: "aspectratio.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        ratioButton.addTarget(self, action: #selector(modifiedRatio), for: .touchUpInside)
        ratioButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ratioButton)

        let doneButton = UIButton(type:.system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(doneButton)

        self.verticalLayouts = [
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            resetButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            rotateCountClockwiseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            rotateClockwiseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            ratioButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            doneButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            cancelButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            resetButton.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20),

            rotateCountClockwiseButton.bottomAnchor.constraint(equalTo: rotateClockwiseButton.topAnchor, constant: -20),
            rotateClockwiseButton.bottomAnchor.constraint(equalTo: ratioButton.topAnchor, constant: -20),
            ratioButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ]
        self.horizontalLayouts = [
            cancelButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            resetButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rotateCountClockwiseButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rotateClockwiseButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            ratioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            doneButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            resetButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 20),

            doneButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            ratioButton.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -20),
            rotateClockwiseButton.trailingAnchor.constraint(equalTo: ratioButton.leadingAnchor, constant: -20),
            rotateCountClockwiseButton.trailingAnchor.constraint(equalTo: rotateClockwiseButton.leadingAnchor, constant: -20),
        ]
        return containerView
    }

    @objc internal  func cancelEdit(){
        self.cancelTapped?()
    }

    @objc internal  func rotateCounterClockwise(){
        self.rotatedButtonTapped?(false)
    }

    @objc internal  func rotateClockwise(){
        self.rotatedButtonTapped?(true)
    }

    @objc internal  func modifiedRatio(){
        let croppedRect = self._processor.cropView.imageCropFrame
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if croppedRect.width < croppedRect.height{
            alert.addAction(UIAlertAction(title: "Square", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(1)
            }))

            alert.addAction(UIAlertAction(title: "9:16", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(9/16.0)
            }))

            alert.addAction(UIAlertAction(title: "8:10", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(8/10.0)
            }))

            alert.addAction(UIAlertAction(title: "5:7", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(5/7.0)
            }))

            alert.addAction(UIAlertAction(title: "3:4", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(3/4.0)
            }))

            alert.addAction(UIAlertAction(title: "3:5", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(3/5.0)
            }))

            alert.addAction(UIAlertAction(title: "2:3", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(2/3.0)
            }))
        }
        else {
            alert.addAction(UIAlertAction(title: "Square", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(1)
            }))

            alert.addAction(UIAlertAction(title: "16:9", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(16/9.0)
            }))

            alert.addAction(UIAlertAction(title: "10:8", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(10/8.0)
            }))

            alert.addAction(UIAlertAction(title: "7:5", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(7/5.0)
            }))

            alert.addAction(UIAlertAction(title: "4:3", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(4/3.0)
            }))

            alert.addAction(UIAlertAction(title: "5:3", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(5/3.0)
            }))

            alert.addAction(UIAlertAction(title: "3:2", style: .default, handler: {
                [weak self] action in
                guard let self = self else {return}
                self.setRatio?(3/2.0)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.cropController.present(alert, animated: true, completion: nil)
       /* let view = UIView()
        self.showAccessoryView?(view)*/
    }

    @objc internal  func reset(){
        self.resetButtonTapped?()
    }

    @objc internal  func done(){
        self.doneTapped?()
    }
}
