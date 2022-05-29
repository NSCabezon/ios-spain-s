//
//  NumberPadView.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 9/26/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

import CoreFoundationLib
import UIKit

public protocol NumberPadViewDelegate: AnyObject {
    func didTapOnNumber(number: Int)
    func didTapOnErase()
    func didTapOnOK()
}

public struct NumberPadViewStyle {
    public struct NumberPadViewShadowStyle {
        let offset: (x: Int, y: Int)
        let opacity: Float
        let color: UIColor
        let radius: CGFloat
    }
    let okButtonColor: UIColor
    let okButtonLabelColor: UIColor
    let okButtonPressedColor: UIColor
    let okButtonFont: UIFont
    let generalButtonColor: UIColor
    let generalButtonLabelColor: UIColor
    let generalButtonFont: UIFont
    let generalButtonShadow: NumberPadViewShadowStyle?
    let backImageKey: String
    
    public static let login: NumberPadViewStyle = NumberPadViewStyle(
        okButtonColor: .santanderRed,
        okButtonLabelColor: .white,
        okButtonPressedColor: .deepRed,
        okButtonFont: .santander(family: .text, type: .regular, size: 26),
        generalButtonColor: UIColor.white.withAlphaComponent(0.3),
        generalButtonLabelColor: .white,
        generalButtonFont: .santander(family: .text, type: .light, size: 36),
        generalButtonShadow: nil,
        backImageKey: "icnBackSpace"
    )
    
    public static let ecommerce: NumberPadViewStyle = NumberPadViewStyle(
        okButtonColor: .darkTorquoise,
        okButtonLabelColor: .white,
        okButtonPressedColor: .ultraDarkTurquoise,
        okButtonFont: .santander(family: .text, type: .regular, size: 26),
        generalButtonColor: .white,
        generalButtonLabelColor: .black,
        generalButtonFont: .santander(family: .text, type: .regular, size: 36),
        generalButtonShadow: NumberPadViewShadowStyle(offset: (0, 0), opacity: 0.42, color: .black, radius: 3),
        backImageKey: "icnBackSpaceBlack"
    )
}

public final class NumberPadView: UIView {
    var view: UIView!
    @IBOutlet private weak var okButton: NumberPadButton!
    @IBOutlet private weak var eraseButton: NumberPadButton!
    @IBOutlet private var numberButtons: [NumberPadButton]!
    @IBOutlet private var numberStackVies: [UIStackView]!
    public weak var delegate: NumberPadViewDelegate?
    private var style: NumberPadViewStyle = .login
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func setStyle(_ style: NumberPadViewStyle) {
        self.style = style
        okButton.normalColor = style.okButtonColor
        okButton.pressedColor = style.okButtonPressedColor
        okButton.setTitleColor(style.okButtonLabelColor, for: .normal)
        okButton.titleLabel?.font = style.okButtonFont
        (numberButtons + [eraseButton]).forEach { button in
            button?.normalColor = style.generalButtonColor
            button?.setTitleColor(style.generalButtonLabelColor, for: .normal)
            button?.titleLabel?.font = style.generalButtonFont
        }
        setButtonImage()
        guard let shadow = style.generalButtonShadow else { return }
        (numberButtons + [okButton, eraseButton]).forEach {
            $0.drawShadow(offset: shadow.offset, opacity: shadow.opacity, color: shadow.color, radius: shadow.radius)
        }
    }
    
    public func setOkButtonText(_ okButtonText: String) {
        okButton.setTitle(okButtonText, for: .normal)
    }
    
    public func hideOkButton() {
        okButton.alpha = 0.0
        okButton.isUserInteractionEnabled = false
    }
    
    public func hideEraseButton() {
        eraseButton.alpha = 0.0
        eraseButton.isUserInteractionEnabled = false
    }
    
    public func showOkButton() {
        okButton.normalColor = style.okButtonColor
        okButton.setTitleColor(style.okButtonLabelColor, for: .normal)
        okButton.titleLabel?.font = style.okButtonFont
        okButton.alpha = 1.0
        okButton.isUserInteractionEnabled = true
        okButton.accessibilityIdentifier = AccessibilityNumberPadView.okButton
    }
    
    public func showEraseButton() {
        eraseButton.normalColor = style.generalButtonColor
        setButtonImage()
        eraseButton.alpha = 1.0
        eraseButton.isUserInteractionEnabled = true
        eraseButton.accessibilityIdentifier = AccessibilityNumberPadView.eraseButton
    }
}

private extension NumberPadView {
    func setupView() {
        xibSetup()
        setupButtons()
    }
    
    func setupButtons() {
        setButtonRadius()
        setButtonTarget()
        okButton.setTitle(localized("login_keyboard_ok"), for: .normal)
        hideOkButton()
        hideEraseButton()
        setStackViewSpacing()
        setStyle(style)
    }
    
    func setStackViewSpacing() {
        if Screen.isIphone4or5 {
            numberStackVies.forEach { $0.spacing = 8 }
        } else {
            numberStackVies.forEach { $0.spacing = 16 }
        }
    }
    
    func setButtonRadius() {
        numberButtons.forEach { (button) in
            button.layer.cornerRadius = 6.0
        }
    }
    
    func setButtonTarget() {
        numberButtons.forEach { (button) in
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTouchOnKeyboardButton))
            button.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func setButtonImage() {
        let eraseImage = Assets.image(named: style.backImageKey)
        eraseButton.setImage(eraseImage, for: .normal)
    }
    
    @objc
    func didTouchOnKeyboardButton(sender: UITapGestureRecognizer) {
        guard let button = sender.view as? UIButton else {
            return
        }
        switch button {
        case okButton:
            delegate?.didTapOnOK()
        case eraseButton:
            delegate?.didTapOnErase()
        default:
            button.accessibilityIdentifier = AccessibilityNumberPadView.tagButton + "\(button.tag)"
            delegate?.didTapOnNumber(number: button.tag)
        }
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        self.backgroundColor = UIColor.clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: .module)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        return view ??  UIView()
    }
}
