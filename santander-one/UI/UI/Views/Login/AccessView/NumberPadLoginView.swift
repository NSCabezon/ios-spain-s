//
//  NumberPadView.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 9/25/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib

public protocol NumberPadLoginViewDelegate: AnyObject {
    func didTapOnTouchID()
    func didTapOnFaceID()
    func didTapOnRestorePassword()
    func didTapOnOK(withMagic magic: String)
    func didFinishWrongPasswordAnimation()
    func didTapSantanderKey()
}

public final class NumberPadLoginView: UIView {
    private var view: UIView!
    private var minPasswordLength: Int = 4
    private var maxPasswordLength: Int = 8
    @IBOutlet private weak var accessPassword: AccessPasswordView!
    @IBOutlet private weak var numberPad: NumberPadView!
    @IBOutlet private weak var footerLogin: LoginFooterView!
    
    public weak var delegate: NumberPadLoginViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func setOkButtonText(_ okButtonText: String) {
        self.numberPad.setOkButtonText(okButtonText)
    }
    
    public func autocompletePasswordWith(_ password: String?) {
        password?.forEach { self.accessPassword.addCharacter("\($0)") }
    }
    
    public func setAvailableBiometryType(_ biometryType: BiometryTypeEntity) {
        switch biometryType {
        case .touchId:
            self.footerLogin.configType(.fingerPrint)
        case .faceId:
            self.footerLogin.configType(.faceId)
        default:
            self.footerLogin.configType(.none)
        }
    }

    public func wrongPassword() {
        accessPassword.requireUserAtencion()
        startResetPasswordAnimation()
    }
    
    public func clear() {
        self.accessPassword.clear()
    }

    public func setFooter() {
        self.footerLogin.configType(.code)
    }
}

extension NumberPadLoginView: NumberPadViewDelegate {
    public func didTapOnNumber(number: Int) {
        accessPassword.addCharacter("\(number)")
    }
    
    public func didTapOnErase() {
        accessPassword.removeLastCharacter()
    }
    
    public func didTapOnOK() {
        let magic = accessPassword.getDecryptedValue()
        delegate?.didTapOnOK(withMagic: magic)
    }
}

extension NumberPadLoginView: AccessPasswordViewDelegate {
    public func didPasswordChange(_ newValue: String) {
        if newValue.isEmpty {
            numberPad.hideEraseButton()
            numberPad.hideOkButton()
        } else if newValue.count < minPasswordLength {
            numberPad.showEraseButton()
            numberPad.hideOkButton()
        } else if newValue.count >= minPasswordLength {
            numberPad.showEraseButton()
            numberPad.showOkButton()
        }
    }
}

private extension NumberPadLoginView {
    
    func setupView() {
        xibSetup()
        footerLogin.delegate = self
        numberPad.delegate = self
        accessPassword.maxPasswordLength = self.maxPasswordLength
        accessPassword.delegate = self
        setAccessibilityIds()
    }
    
    func startResetPasswordAnimation() {
        guard #available(iOS 10.0, *) else { return }
        let animation: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.6, curve: .linear)
        animation.addAnimations { [weak self] in
            self?.setAnimatedViews()
        }
        animation.addCompletion { [weak self] _ in
            self?.setNormalState()
        }
        animation.startAnimation(afterDelay: 3.0)
    }
    
    func setAnimatedViews() {
        self.accessPassword.alpha = 0.0
        self.numberPad.hideOkButton()
        self.numberPad.hideEraseButton()
    }
    
    func setNormalState() {
        self.accessPassword.clear()
        self.accessPassword.alpha = 1.0
        self.delegate?.didFinishWrongPasswordAnimation()
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
        return view ?? UIView()
    }
    
    func setAccessibilityIds() {
        numberPad.accessibilityIdentifier = AccessibilityNumberPadLoginView.numberPad
        accessPassword.accessibilityIdentifier = AccessibilityNumberPadLoginView.accessPassword
    }
}

extension NumberPadLoginView: DidTapInLoginFooterButtonsDelegate {
    func didTapInBiometrics(_ type: LoginFooterType) {
        switch type {
        case .faceId:
            delegate?.didTapOnFaceID()
        case .fingerPrint:
            delegate?.didTapOnTouchID()
        case .code, .none:
            break
        }
    }
    
    func didTapInRecovery() {
        delegate?.didTapOnRestorePassword()
    }
    
    func didTapInEcommerce() {
        delegate?.didTapSantanderKey()
    }
}

extension NumberPadLoginView: LoginCustomizable {
    public func setEcommerceEnabled(_ isEnabled: Bool) {
        self.footerLogin.configEcommerceButton(isEnabled)
    }
}
