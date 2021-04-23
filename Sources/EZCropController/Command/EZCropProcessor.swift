//
//  File.swift
//  
//
//  Created by Xiang Li on 3/31/21.
//

import Foundation
import UIKit
import Combine
internal class EZCropProcessor : NSObject {
    var isLockAspectRatioEnable:Bool = false
    var lastCropImageFrame:CGRect = .zero
    final var ongoingCommand:CommandProtocol?
    var isRotateCropViewWithOrientationEnable : Bool {
        if #available(iOS 13.0, *) {
            return self._isRotateCropViewWithOrientationEnableNotifier.value
        } else {
            return self._isRotateCropViewWithOrientationEnable
        }
    }

    @objc weak var cropView:EZCropView!
    private var _isRotateCropViewWithOrientationEnable = true
    @available(iOS 13.0, *)
    private lazy var _isRotateCropViewWithOrientationEnableNotifier = CurrentValueSubject<Bool,Never>(true)
    @available(iOS 13.0, *)
    lazy var subscriptions = Set<AnyCancellable>()

    var observeToken : NSObjectProtocol?

    deinit {
        if #available(iOS 13.0, *) {
            for cancellable in subscriptions{
                cancellable.cancel()
            }
        } else {
            if let token = self.observeToken{
                NotificationCenter.default.removeObserver(token)
            }
        }
    }
    func setRotateCropViewWithOrientationEnable(_ enable:Bool){
        if #available(iOS 13.0, *) {
            self._isRotateCropViewWithOrientationEnableNotifier.send(enable)
        } else {
            _isRotateCropViewWithOrientationEnable = enable
        }
    }

    func observeRotateCropViewWithOrientationEnable(_ observer :@escaping (Bool)->Void){
        if #available(iOS 13.0, *) {
            _isRotateCropViewWithOrientationEnableNotifier.sink(receiveValue: {
                value in
                observer(value)
            })
            .store(in: &subscriptions)
        } else {
            observeToken = NotificationCenter.default.addObserver(forName: Notification.Name("RotateCropViewWithOrientationEnableChanged"), object: self, queue: .main){
                [weak self] notification in
                guard let self = self else {return}
                observer(self._isRotateCropViewWithOrientationEnable)
            }
        }
    }

    //internal processEvent
    func execute(event:EZCropEvent,params:(UIGestureRecognizer?,Dictionary<String,Any>?)){
        if(lastCropImageFrame.equalTo(.zero)){
            lastCropImageFrame = self.cropView.imageCropFrame
        }
        let (gesture, dicParmas) = params
        if let ongoingCommand = self.ongoingCommand {
            ongoingCommand.execute(gesture, params: dicParmas)
            return
        }
        self.dispatchCommand(event: event, params: params)
        self.ongoingCommand?.execute(gesture, params: dicParmas)
    }

    func dispatchCommand(event:EZCropEvent,params:(UIGestureRecognizer?,Dictionary<String,Any>?)){
        var command : CommandProtocol
        switch event {
        case .resize:
            command = EZCropResizeCommand(cropView: self.cropView!, processor: self)
        case .rotate:
            command = EZCropRotationCommand(cropView: self.cropView!, processor: self)
        case .ratio:
            command = EZCropRatioCommand(cropView: self.cropView!, processor: self)
        case .reset:
            command = EZCropResetCommand(cropView: self.cropView!, processor: self)
        case .touchOnCropScrollView:
            self.setRotateCropViewWithOrientationEnable(false)
            return
        case .touchOffCropScrollView:
            self.setRotateCropViewWithOrientationEnable(true)
            return
        case .noInteractionAwhile:
            command = EZCropRecenterCommand(cropView: self.cropView!, processor: self)
        }
        self.ongoingCommand = command
    }
}
