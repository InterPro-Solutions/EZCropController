//
//  EZCropAbstractToolbar.swift
//  
//
//  Created by Xiang Li on 4/5/21.
//

import UIKit

open class EZCropAbstractToolbar : UIView {

    @objc open var horizontalHeight : CGFloat {
        44
    }
    @objc open var verticalWidth : CGFloat {
        44
    }
    @objc public internal(set) weak var cropController       : EZCropController!
    @objc public internal(set) var verticalLayouts      = [NSLayoutConstraint]()
    @objc public internal(set) var horizontalLayouts    = [NSLayoutConstraint]()
    @objc public internal(set) var rotatedButtonTapped  :((Bool)->Void)?
    @objc public internal(set) var showAccessoryView    :((UIView)->Void)?
    @objc public internal(set) var setRatio             :((CGFloat)->Void)?
    @objc public internal(set) var resetButtonTapped    :(()->Void)?
    @objc public internal(set) var cancelTapped         :(()->Void)?
    @objc public internal(set) var doneTapped           :(()->Void)?
    internal var processor: EZCropProcessor {
        return self._processor
    }
    
    internal weak var _processor : EZCropProcessor!
    private var privateToolbarHeightForHorizontal : NSLayoutConstraint!
    private var privateToolbarWidthForVertical : NSLayoutConstraint!
    private var privateBackgroundViewVerticalLayouts = [NSLayoutConstraint]()
    private var privateBackgroundViewHorizontalLayouts = [NSLayoutConstraint]()

    private var _backgroundView : UIView!
    private var _containerView : UIView!

    private var currentStyle : EZCropLayoutStyle!
    public init(){
        super.init(frame: .zero)
        self._backgroundView = self.backgroundView()
        self._containerView = self.containerView()
        self._backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self._containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self._containerView)
        NSLayoutConstraint.activate([
            self._containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self._containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self._containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self._containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        self.privateToolbarHeightForHorizontal = self.heightAnchor.constraint(equalToConstant: self.horizontalHeight)
        self.privateToolbarWidthForVertical = self.widthAnchor.constraint(equalToConstant: self.verticalWidth)
    }
    public required init?(coder: NSCoder) {
        fatalError("Please init() as designated initalizer")
    }

    public override init(frame: CGRect) {
        fatalError("Please init() as designated initalizer")
    }

    open func containerView() -> UIView {
        fatalError("Please subclass EZCropAbstractToolbar and override \"containerView()\"")
    }

    open func backgroundView() -> UIView{
        let view = UIVisualEffectView()
        view.effect = UIBlurEffect(style: .dark)
        return view
    }

    open override func layoutSubviews() {
        if let superview = self.superview {
            let superviewWidth = superview.frame.width
            let superviewHeight = superview.frame.height
            if(superviewWidth > superviewHeight){
                self.setLayoutStyle(.vertical)
            }
            else {
                self.setLayoutStyle(.horizontal)
            }
        }
        super.layoutSubviews()
    }

    private func setLayoutStyle(_ style:EZCropLayoutStyle){
        if
            let currentStyle = self.currentStyle,
            style == currentStyle
        {
            return
        }
        switch style {
        case .vertical:
            NSLayoutConstraint.deactivate(self.horizontalLayouts)
            NSLayoutConstraint.deactivate(self.privateBackgroundViewHorizontalLayouts)
            NSLayoutConstraint.deactivate([self.privateToolbarHeightForHorizontal])
            NSLayoutConstraint.activate(self.verticalLayouts)
            NSLayoutConstraint.activate(self.privateBackgroundViewVerticalLayouts)
            NSLayoutConstraint.activate([self.privateToolbarWidthForVertical])
        case .horizontal:
            NSLayoutConstraint.deactivate(self.verticalLayouts)
            NSLayoutConstraint.deactivate([self.privateToolbarWidthForVertical])
            NSLayoutConstraint.deactivate(self.privateBackgroundViewVerticalLayouts)
            NSLayoutConstraint.activate(self.horizontalLayouts)
            NSLayoutConstraint.activate(self.privateBackgroundViewHorizontalLayouts)
            NSLayoutConstraint.activate([self.privateToolbarHeightForHorizontal])
        }
        self.currentStyle = style
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        self._backgroundView.removeFromSuperview()
        self.privateBackgroundViewVerticalLayouts.removeAll()
        self.privateBackgroundViewHorizontalLayouts.removeAll()
        guard let superview = newSuperview else {return}
        self.addSubview(self._backgroundView)
        self.bringSubviewToFront(self._containerView)
        self.privateBackgroundViewHorizontalLayouts = [
            self._backgroundView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self._backgroundView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            self._backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self._backgroundView.topAnchor.constraint(equalTo: superview.topAnchor),
        ]
        self.privateBackgroundViewVerticalLayouts = [
            self._backgroundView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self._backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self._backgroundView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self._backgroundView.topAnchor.constraint(equalTo: superview.topAnchor),
        ]
    }

}
