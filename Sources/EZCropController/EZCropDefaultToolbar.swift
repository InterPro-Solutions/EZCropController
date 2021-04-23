//
//  File.swift
//  
//
//  Created by Xiang Li on 4/5/21.
//

import UIKit

internal class EZCropDefaultToolbar : EZCropAbstractToolbar {
    @objc override var horizontalHeight : CGFloat {
        44
    }
    @objc override var verticalWidth : CGFloat {
        60
    }

    private var resetButton : UIButton!

    internal override func containerView() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let cancelButton = UIButton(type:.system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelEdit), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cancelButton)

        resetButton = UIButton(type:.system)
        resetButton.isHidden = true
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(resetButton)

        let rotateCountClockwiseButton = UIButton(type:.system)
        if #available(iOS 13.0, *) {
            rotateCountClockwiseButton.setImage(UIImage(systemName: "rotate.left.fill"), for: .normal)
        } else {
            rotateCountClockwiseButton.setImage(UIImage(named: "Rotate Left Fill",in: Bundle.module, compatibleWith: nil)!, for: .normal)
        }
        rotateCountClockwiseButton.addTarget(self, action: #selector(rotateCounterClockwise), for: .touchUpInside)
        rotateCountClockwiseButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rotateCountClockwiseButton)

        let rotateClockwiseButton = UIButton(type:.system)
        if #available(iOS 13.0, *) {
            rotateClockwiseButton.setImage(UIImage(systemName: "rotate.right.fill"), for: .normal)
        } else {
            rotateClockwiseButton.setImage(UIImage(named: "Rotate Right Fill",in: Bundle.module, compatibleWith: nil)!, for: .normal)
            // Fallback on earlier versions
        }
        rotateClockwiseButton.addTarget(self, action: #selector(rotateClockwise), for: .touchUpInside)
        rotateClockwiseButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rotateClockwiseButton)

        let ratioButton = UIButton(type:.system)
        if #available(iOS 13.0, *) {
            ratioButton.setImage(UIImage(systemName: "aspectratio.fill"), for: .normal)
        } else {
            ratioButton.setImage(UIImage(named: "Aspectratio Fill",in: Bundle.module, compatibleWith: nil)!, for: .normal)
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
            rotateCountClockwiseButton.widthAnchor.constraint(equalToConstant: 22),
            rotateCountClockwiseButton.heightAnchor.constraint(equalToConstant: 22),
            rotateClockwiseButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            rotateClockwiseButton.widthAnchor.constraint(equalToConstant: 22),
            rotateClockwiseButton.heightAnchor.constraint(equalToConstant: 22),
            ratioButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            ratioButton.widthAnchor.constraint(equalToConstant: 22),
            ratioButton.heightAnchor.constraint(equalToConstant: 22),
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
            rotateCountClockwiseButton.widthAnchor.constraint(equalToConstant: 22),
            rotateCountClockwiseButton.heightAnchor.constraint(equalToConstant: 22),
            rotateClockwiseButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rotateClockwiseButton.widthAnchor.constraint(equalToConstant: 22),
            rotateClockwiseButton.heightAnchor.constraint(equalToConstant: 22),
            ratioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            ratioButton.widthAnchor.constraint(equalToConstant: 22),
            ratioButton.heightAnchor.constraint(equalToConstant: 22),
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

    override func couldReset(_ resetable: Bool) {
        self.resetButton.isHidden = !resetable
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

    @objc internal  func modifiedRatio(_ sender:UIButton){
        if sender.isSelected == false {
            sender.isSelected = true
            self.processor.isLockAspectRatioEnable = true
            let ratioView = EZCropRatioAccessoryVIew()
            ratioView._processor = self.processor
            self.showAccessoryView?(ratioView)
        }
        else {
            self.processor.isLockAspectRatioEnable = true
            sender.isSelected = false
            self.hiddenAccessoryView?()
        }
    }

    @objc internal  func reset(){
        self.resetButtonTapped?()
    }

    @objc internal  func done(){
        self.doneTapped?()
    }
}
