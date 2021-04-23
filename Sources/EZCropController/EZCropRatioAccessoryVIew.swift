//
//  EZCropRatioAccessoryVIew.swift
//  
//
//  Created by Xiang Li on 4/22/21.
//

import UIKit

internal class EZCropRatioAccessoryVIew : EZCropAbstractAccessoryView {
    private var widthGreaterThanHeight = false
    private var token : NSKeyValueObservation?
    private let _9_16 = UIButton(type: .system)
    private let _8_10 = UIButton(type: .system)
    private let _5_7 = UIButton(type: .system)
    private let _3_4 = UIButton(type: .system)
    private let _3_5 = UIButton(type: .system)
    private let _2_3 = UIButton(type: .system)
    private var selectedButton : UIButton?
    @objc override var horizontalHeight : CGFloat {
        44
    }
    @objc override var verticalWidth : CGFloat {
        80
    }
    deinit {
        self.token?.invalidate()
    }
    internal override func containerView() -> UIView {
        let containerView = UIScrollView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let squareButton = UIButton(type: .system)
        squareButton.translatesAutoresizingMaskIntoConstraints = false
        squareButton.setTitle("Square", for: .normal)
        squareButton.tag = 1
        squareButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(squareButton)



        _9_16.translatesAutoresizingMaskIntoConstraints = false
        _9_16.tag = 2
        _9_16.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(_9_16)

        _8_10.translatesAutoresizingMaskIntoConstraints = false
        _8_10.tag = 3
        _8_10.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(_8_10)

        _5_7.translatesAutoresizingMaskIntoConstraints = false
        _5_7.tag = 4
        _5_7.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(_5_7)

        _3_4.translatesAutoresizingMaskIntoConstraints = false
        _3_4.tag = 5
        _3_4.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(_3_4)

        _3_5.translatesAutoresizingMaskIntoConstraints = false
        _3_5.tag = 6
        _3_5.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(_3_5)

        _2_3.translatesAutoresizingMaskIntoConstraints = false
        _2_3.tag = 7
        _2_3.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(_2_3)
        self.verticalLayouts = [
            squareButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            _9_16.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),
            _8_10.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),
            _5_7.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),
            _3_4.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),
            _3_5.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),
            _2_3.centerXAnchor.constraint(equalTo: squareButton.centerXAnchor),

            squareButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            _9_16.topAnchor.constraint(equalTo: squareButton.bottomAnchor, constant: 20),
            _8_10.topAnchor.constraint(equalTo: _9_16.bottomAnchor, constant: 20),
            _5_7.topAnchor.constraint(equalTo: _8_10.bottomAnchor, constant: 20),
            _3_4.topAnchor.constraint(equalTo: _5_7.bottomAnchor, constant: 20),
            _3_5.topAnchor.constraint(equalTo: _3_4.bottomAnchor, constant: 20),
            _2_3.topAnchor.constraint(equalTo: _3_5.bottomAnchor, constant: 20),
        ]
        self.horizontalLayouts = [
            squareButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            _9_16.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            _8_10.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            _5_7.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            _3_4.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            _3_5.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),
            _2_3.centerYAnchor.constraint(equalTo: squareButton.centerYAnchor),

            squareButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            _9_16.leadingAnchor.constraint(equalTo: squareButton.trailingAnchor, constant: 20),
            _8_10.leadingAnchor.constraint(equalTo: _9_16.trailingAnchor, constant: 20),
            _5_7.leadingAnchor.constraint(equalTo: _8_10.trailingAnchor, constant: 20),
            _3_4.leadingAnchor.constraint(equalTo: _5_7.trailingAnchor, constant: 20),
            _3_5.leadingAnchor.constraint(equalTo: _3_4.trailingAnchor, constant: 20),
            _2_3.leadingAnchor.constraint(equalTo: _3_5.trailingAnchor, constant: 20),
        ]
        return containerView
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            token = self.processor.cropView.overlay.observe(\.cropBoxFrame, options: .new, changeHandler: {
                [weak self] overLay, value in
                guard
                    let self = self,
                    let newFrame = value.newValue
                else {return}

                self.widthGreaterThanHeight = newFrame.width > newFrame.height
                if self.widthGreaterThanHeight {
                    self._9_16.setTitle("16:9", for: .normal)
                    self._8_10.setTitle("8:10", for: .normal)
                    self._5_7.setTitle("7:5", for: .normal)
                    self._3_4.setTitle("4:3", for: .normal)
                    self._3_5.setTitle("5:3", for: .normal)
                    self._2_3.setTitle("3:2", for: .normal)
                }
                else {
                    self._9_16.setTitle("9:16", for: .normal)
                    self._8_10.setTitle("8:10", for: .normal)
                    self._5_7.setTitle("5:7", for: .normal)
                    self._3_4.setTitle("3:4", for: .normal)
                    self._3_5.setTitle("3:5", for: .normal)
                    self._2_3.setTitle("2:3", for: .normal)
                }
                return
            })
        }

    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }

    @objc func buttonTapped(_ sender:UIButton){
        guard
            sender.isSelected == false
        else {
            return
        }
        self.selectedButton?.isSelected = false
        self.selectedButton = sender
        var width : CGFloat = 0
        var height : CGFloat = 1
        switch sender.tag {
        case 1:
            width = 1
            height = 1
        case 2:
            width = 9
            height = 16
        case 3:
            width = 8
            height = 10
        case 4:
            width = 5
            height = 7
        case 5:
            width = 3
            height = 4
        case 6:
            width = 3
            height = 5
        case 7:
            width = 2
            height = 3
        default:
            return
        }
        if self.widthGreaterThanHeight {
            let temp = width
            width = height
            height = temp
        }
        sender.isSelected = true
        self.processor.execute(event: .ratio, params: (nil,["ratio":width/height]))
    }
    /*@objc internal  func cancelEdit(){
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
    }*/
}
