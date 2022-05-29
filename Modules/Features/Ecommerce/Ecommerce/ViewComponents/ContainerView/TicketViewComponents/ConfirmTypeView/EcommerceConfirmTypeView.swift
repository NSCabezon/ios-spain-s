//
//  EcommerceConfirmTypeView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 1/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public final class EcommerceConfirmTypeView: XibView {
    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    var biometryIconAction: ( () -> Void )?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ type: EcommerceAuthType, status: EcommerceAuthStatus) {
        self.configTopImage(type)
        self.configTitle(type, status: status)
    }
}

private extension EcommerceConfirmTypeView {
    func setupView() {
        self.backgroundColor = .clear
        self.setTitle()
        self.setAccessibilityIds()
    }
    
    func setTitle() {
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
    }
    
    func configTopImage(_ type: EcommerceAuthType) {
        let image = Assets.image(named: type.imageName())
        self.topImageView.image = image?.withRenderingMode(.alwaysTemplate)
        self.topImageView.tintColor = .brownGray
        switch type {
        case .faceId, .fingerPrint:
            setupTapGesture()
        case .code:
            break
        }
    }
    
    func setupTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(iconTapped))
        topImageView.isUserInteractionEnabled = true
        topImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func iconTapped() {
        biometryIconAction?()
    }
    
    func configTitle(_ type: EcommerceAuthType, status: EcommerceAuthStatus) {
        let localizedKey = type.labelKeyWithStatus(status)
        self.titleLabel.configureText(withKey: localizedKey)
        self.titleLabel.textColor = type.labelColorWithStatus(status)
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = AccessibilityEcommerceConfirmTypeView.baseView
        self.topImageView.accessibilityIdentifier = AccessibilityEcommerceConfirmTypeView.topImageView
        self.titleLabel.accessibilityIdentifier = AccessibilityEcommerceConfirmTypeView.titleLabel
    }
}
