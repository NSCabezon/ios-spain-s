//
//  FaceIDLoginView.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 9/26/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

import UIKit

public protocol Expirable {
    func startWaitingForUserInteraction(seconds: Double)
    func stopWaitingForUserInteraction()
}

public protocol FaceIDLoginViewDelegate: AnyObject {
    func didTapOnAccessPassword()
    func didTapOnAccessWithFaceID()
    func didTapOnEcommerce()
}

public final class FaceIDLoginView: UIView {
    @IBOutlet private weak var faceIDLabel: UILabel!
    @IBOutlet private weak var faceIdImage: UIImageView!
    @IBOutlet private weak var footerView: LoginFooterView!
    
    private var expirationTimer: Timer?
    private var view: UIView!
    public weak var delegate: FaceIDLoginViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    @IBAction func didTapOnAccessWithFaceID(_ sender: Any) {
        stopWaitingForUserInteraction()
        delegate?.didTapOnAccessWithFaceID()
    }
    
    @IBAction func didTapOnEcommerce(_ sender: Any) {
        delegate?.didTapOnEcommerce()
    }
    
    public func setFaceIDText(_ faceIDDescription: String) {
        self.faceIDLabel.text = faceIDDescription
    }
    
    public func setFooter() {
        self.footerView.configType(.code)
    }
}

extension FaceIDLoginView: Expirable {
    public func startWaitingForUserInteraction(seconds: Double) {
        guard #available(iOS 10.0, *) else { return }
        self.expirationTimer = Timer
            .scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] _ in
                self?.didTapOnAccessPassword()
            })
    }
    
    public func stopWaitingForUserInteraction() {
        self.expirationTimer?.invalidate()
    }
}

private extension FaceIDLoginView {
    func setupView() {
        xibSetup()
        self.footerView.delegate = self
    }
    
    @objc
    func didTapOnAccessPassword() {
        stopWaitingForUserInteraction()
        delegate?.didTapOnAccessPassword()
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
}

extension FaceIDLoginView: DidTapInLoginFooterButtonsDelegate {
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

extension FaceIDLoginView: LoginCustomizable {
    public func setEcommerceEnabled(_ isEnabled: Bool) {
        self.footerView.configEcommerceButton(isEnabled)
    }
}
