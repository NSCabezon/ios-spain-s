//
//  EcommerceKeyAccessContentView.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 8/3/21.
//

import UIKit
import UI
import CoreFoundationLib
import ESCommons

public protocol DidTapInUseKeyAccessDelegate: class {
    func didTapInUseKeyAccess()
}

public final class EcommerceKeyAccessContentView: XibView {
    @IBOutlet private weak var buttonContent: UIView!
    @IBOutlet private weak var buttonImage: UIImageView!
    @IBOutlet private weak var buttonLabel: UILabel!
    
    weak var delegate: DidTapInUseKeyAccessDelegate?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ isVisible: Bool) {
        self.buttonContent.isHidden = !isVisible
    }

    @IBAction func didTapInButton(_ sender: Any) {
        delegate?.didTapInUseKeyAccess()
    }
}

private extension EcommerceKeyAccessContentView {
    func setupView() {
        self.backgroundColor = .clear
        self.setAccessButton()
        self.setAccessibilityId()
    }
    
    func setAccessButton() {
        self.buttonLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        self.buttonLabel.text = localized("ecommerce_button_usePassword")
        self.buttonLabel.textColor = .darkTorquoise
        self.buttonImage.image = Assets.image(named: "icnAccessCode")
        self.buttonImage.tintColor = .lisboaGray
    }
    
    func setAccessibilityId() {
        self.buttonContent.accessibilityIdentifier = AccessibilityEcommerceContainerView.keyAccessButton
    }
}
