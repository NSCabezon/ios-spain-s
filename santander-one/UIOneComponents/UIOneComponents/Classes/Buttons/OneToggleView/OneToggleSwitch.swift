//
//  OneToggleSwitch.swift
//  UIOneComponents
//
//  Created by Jose Javier Montes Romero on 1/3/22.
//

import Foundation
import CoreFoundationLib

final class OneToggleSwitch: UIControl {
    private var animationDelay: Double = 0
    private var animationSpriteWithDamping = CGFloat(0.7)
    private var initialSpringVelocity = CGFloat(0.5)
    private var animationDuration: Double = 0.5
    private var padding: CGFloat = 1
    private var cornerRadius: CGFloat = 0.5
    private var thumbCornerRadius: CGFloat = 0.5
    private var thumbSize: CGSize = CGSize.zero
    private var thumbView = UIView(frame: CGRect.zero)
    private var onImageView = UIImageView(frame: CGRect.zero)
    private var offImageView = UIImageView(frame: CGRect.zero)
    private var onPoint = CGPoint.zero
    private var offPoint = CGPoint.zero
    private var isAnimating = false
    private var widthImage = CGFloat(16)
    private var heightImage = CGFloat(16)
    public var isOn: Bool = true
    public var onTintColor: UIColor = .oneDarkTurquoise
    public var offTintColor: UIColor = .oneBrownGray
    public var thumbTintColor: UIColor = UIColor.white {
        didSet {
            self.thumbView.backgroundColor = self.thumbTintColor
        }
    }
    public var onImage: UIImage? {
        didSet {
            self.onImageView.image = onImage
            self.layoutSubviews()
        }
    }
    public var offImage: UIImage? {
        didSet {
            self.offImageView.image = offImage
            self.layoutSubviews()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        self.animate()
        return true
    }
    
    func setOn(on:Bool, animated:Bool) {
        switch animated {
        case true:
            self.animate(on: on)
        case false:
            self.isOn = on
            self.setupViewsOnAction()
            self.completeAction()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureUISize()
    }
}

// MARK: Private methods
private extension OneToggleSwitch {
    func setupUI() {
        self.clear()
        self.clipsToBounds = false
        self.thumbView.backgroundColor = self.thumbTintColor
        self.thumbView.isUserInteractionEnabled = false
        self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
        self.addSubview(self.thumbView)
        self.addSubview(self.onImageView)
        self.addSubview(self.offImageView)
        self.setAccessibility(setViewAccessibility: setAccessibilityInfo)
        self.setAccessibilityValue()
    }
    
    func clear() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    func animate(on:Bool? = nil) {
        self.isOn = on ?? !self.isOn
        setAccessibilityValue()
        self.isAnimating = true
        UIView.animate(withDuration: self.animationDuration,
                       delay: self.animationDelay,
                       usingSpringWithDamping: self.animationSpriteWithDamping,
                       initialSpringVelocity: self.initialSpringVelocity,
                       options: [UIView.AnimationOptions.curveEaseOut, UIView.AnimationOptions.beginFromCurrentState, UIView.AnimationOptions.allowUserInteraction], animations: {
            self.setupViewsOnAction()
        }, completion: { _ in
            self.completeAction()
        })
    }
    
    func setupViewsOnAction() {
        self.thumbView.frame.origin.x = self.isOn ? self.onPoint.x : self.offPoint.x
        self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
        self.setOnOffImageFrame()
    }
    
    func completeAction() {
        self.isAnimating = false
    }
    
    func setOnOffImageFrame() {
        guard onImage != nil && offImage != nil else {
            return
        }
        self.onImageView.alpha = self.isOn ? 1.0 : 0.0
        self.offImageView.alpha = self.isOn ? 0.0 : 1.0
    }
    
    func configureUISize() {
        if !self.isAnimating {
            self.layer.cornerRadius = self.bounds.size.height * self.cornerRadius
            self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
            let thumbSize = self.thumbSize != CGSize.zero ? self.thumbSize : CGSize(width: self.bounds.size.height - 2, height: self.bounds.height - 2)
            let yPostition = (self.bounds.size.height - thumbSize.height) / 2
            self.onPoint = CGPoint(x: self.bounds.size.width - thumbSize.width - self.padding, y: yPostition)
            self.offPoint = CGPoint(x: self.padding, y: yPostition)
            self.thumbView.frame = CGRect(origin: self.isOn ? self.onPoint : self.offPoint, size: thumbSize)
            self.thumbView.layer.cornerRadius = thumbSize.height * self.thumbCornerRadius
            configureImagesView()
        }
    }
    
    func configureImagesView() {
        guard onImage != nil && offImage != nil else {
            return
        }
        let onOffImageSize = CGSize(width: self.widthImage, height: self.heightImage)
        self.onImageView.frame.size = onOffImageSize
        self.offImageView.frame.size = onOffImageSize
        self.onImageView.center = CGPoint(x: self.onPoint.x + self.thumbView.frame.size.width / 2, y: self.thumbView.center.y)
        self.offImageView.center = CGPoint(x: self.offPoint.x + self.thumbView.frame.size.width / 2, y: self.thumbView.center.y)
        self.onImageView.alpha = self.isOn ? 1.0 : 0.0
        self.offImageView.alpha = self.isOn ? 0.0 : 1.0
    }
    
    func setAccessibilityInfo() {
        self.isAccessibilityElement = true
        self.accessibilityLabel = localized("voiceover_tapTo")
        self.accessibilityTraits = .button
    }
    
    func setAccessibilityValue() {
        self.accessibilityValue = self.isOn ? localized("voiceover_deactivate") : localized("voiceover_activate")
    }
}

extension OneToggleSwitch: AccessibilityCapable {}
