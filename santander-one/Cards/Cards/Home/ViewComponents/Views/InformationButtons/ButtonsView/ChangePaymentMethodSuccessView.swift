//
//  ChangePaymentMethodSuccessView.swift
//  Cards
//
//  Created by Laura González on 23/04/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol ChangePaymentMethodSuccessViewDelegate: AnyObject {
    func changePaymentMethodWithCodeButtonTapped()
}

final class ChangePaymentMethodSuccessView: BaseInformationButton {
    @IBOutlet private weak var changePaymentMethodImageView: UIImageView!
    @IBOutlet private weak var changePaymentMethodLabel: UILabel!
    @IBOutlet private weak var paymentMethodLabel: UILabel!
    
    weak var delegate: ChangePaymentMethodSuccessViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setPaymentMethodLabel(text: LocalizedStylableText?) {
        guard let text = text else { return }
        paymentMethodLabel.configureText(withLocalizedString: text)
    }

    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        self.delegate?.changePaymentMethodWithCodeButtonTapped()
    }
}

private extension ChangePaymentMethodSuccessView {
    func setupView() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
        self.addGesture()
        self.configureLabel()
        self.changePaymentMethodImageView.image = Assets.image(named: "imgChangeWayToPay")
        self.setAccessibilityIdentifiers()
    }
    
    func addGesture() {
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    func configureLabel() {
        changePaymentMethodLabel.textColor = .lisboaGray
        changePaymentMethodLabel.configureText(withKey: "cards_button_changeWayToPay",
                                               andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                                    lineHeightMultiple: 0.8))
        paymentMethodLabel.text = nil
        paymentMethodLabel.textColor = .lisboaGray
        paymentMethodLabel.font = .santander(family: .text, type: .regular, size: 12)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = "paymentMethod_view"
        paymentMethodLabel.accessibilityIdentifier = "paymentMethod_subtitle"
        changePaymentMethodLabel.accessibilityIdentifier = "paymentMethod_title"
        changePaymentMethodImageView.accessibilityIdentifier = "paymentMethod_image"
    }
}
