//
//  TouchIDView.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 9/25/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

import UIKit

public protocol TouchIDLoginViewDelegate: AnyObject {
    func didTapOnAccessPassword()
    func didTapOnAccessWithTouchID()
    func didTapOnEcommerce()
}

public final class TouchIDLoginView: UIView {
    @IBOutlet private weak var touchIDLabel: UILabel!
    @IBOutlet private weak var touchIDButton: UIButton!
    @IBOutlet private weak var footerLogin: LoginFooterView!
        
    private var expirationTimer: Timer?
    private var view: UIView!
    public weak var delegate: TouchIDLoginViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    public func setTouchIDText(_ touchIDDescription: String) {
        self.touchIDLabel.text = touchIDDescription
    }
    
    public func disableTouchIDView() {
        self.touchIDButton.isEnabled = false
    }
    
    public func enableTouchIDView() {
        self.touchIDButton.isEnabled = true
    }
    
    public func setFooter() {
        self.footerLogin.configType(.code)
    }
    
    @IBAction func didTapOnAccessWithTouchID(_ sender: Any) {
        stopWaitingForUserInteraction()
        delegate?.didTapOnAccessWithTouchID()
    }
}

extension TouchIDLoginView: Expirable {
    public func startWaitingForUserInteraction(seconds: Double) {
        guard #available(iOS 10.0, *) else { return }
        self.expirationTimer = Timer.scheduledTimer(
            withTimeInterval: seconds,
            repeats: false,
            block: { [weak self] in
                $0.invalidate()
                self?.didTapOnAccessPassword()
        })
    }
    
    public func stopWaitingForUserInteraction() {
        self.expirationTimer?.invalidate()
    }
}

private extension TouchIDLoginView {
    func setupView() {
        xibSetup()
    }
    
    @objc
    func didTapOnAccessPassword() {
        stopWaitingForUserInteraction()
        delegate?.didTapOnAccessPassword()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        footerLogin.delegate = self
        self.backgroundColor = UIColor.clear
        touchIDButton.setImage(Assets.image(named: "icnFingerprintLogin"), for: .normal)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: .module)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        return view ?? UIView()
    }
}

extension TouchIDLoginView: DidTapInLoginFooterButtonsDelegate {
    func didTapInBiometrics(_ type: LoginFooterType) {
        if type == .code {
            delegate?.didTapOnAccessPassword()
        }
    }
    
    func didTapInRecovery() {}
    
    func didTapInEcommerce() {
        delegate?.didTapOnEcommerce()
    }
}

extension TouchIDLoginView: LoginCustomizable {
    public func setEcommerceEnabled(_ isEnabled: Bool) {
        self.footerLogin.configEcommerceButton(isEnabled)
    }
}
