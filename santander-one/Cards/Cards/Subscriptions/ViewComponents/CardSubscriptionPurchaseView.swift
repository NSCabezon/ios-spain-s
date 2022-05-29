//
//  CardSubscriptionPurchaseView.swift
//  Cards
//
//  Created by Ignacio González Miró on 8/4/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol CardSubscriptionPurchaseViewDelegate: AnyObject {
    func didTapInPurchaseView()
    func didTapInSubscriptionSwitch(_ isOn: Bool)
}

public final class CardSubscriptionPurchaseView: XibView {

    @IBOutlet private weak var roundedView: CardSubscriptionPurchaseImageView!
    @IBOutlet private weak var businessNameLabel: UILabel!
    @IBOutlet private weak var subscriptionInfoStackView: UIStackView!
    @IBOutlet private weak var subscriptionAmountLabel: UILabel!
    @IBOutlet private weak var subscriptionDateLabel: UILabel!
    @IBOutlet private weak var subscriptionStatusLabel: UILabel!
    @IBOutlet private weak var subscriptionSwitch: UISwitch!
    @IBOutlet private weak var subscriptionSwitchStackView: UIStackView!

    weak var delegate: CardSubscriptionPurchaseViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel) {
        roundedView.configView(viewModel)
        subscriptionAmountLabel.attributedText = viewModel.amountAttributeString
        setBusinessName(viewModel.businessName)
        subscriptionDateLabel.text = viewModel.subscriptionDate
        setStackViews(viewModel)
        setStatusLabel(isOn: viewModel.isSubscriptionPaymentEnabled)
        setSwitch(isOn: viewModel.isSubscriptionPaymentEnabled)
    }
    
    @IBAction func didTapInSubscriptionSwitch(_ sender: UISwitch) {
        delegate?.didTapInSubscriptionSwitch(sender.isOn)
    }
}

private extension CardSubscriptionPurchaseView {
    func setupView() {
        setSubscriptionDateAndAmount()
        addTapGesture()
        setAccessibilityIds()
    }
    
    func setBusinessName(_ text: String) {
        let font = UIFont.santander(family: .text, type: .bold, size: 18)
        let configuration = LocalizedStylableTextConfiguration(font: font, alignment: .left, lineHeightMultiple: 0.75, lineBreakMode: .byTruncatingTail)
        businessNameLabel.configureText(withKey: text, andConfiguration: configuration)
        businessNameLabel.textColor = .lisboaGray
    }
    
    func setSubscriptionDateAndAmount() {
        subscriptionAmountLabel.setSantanderTextFont(type: .bold, size: 26.0, color: .lisboaGray)
        subscriptionDateLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .brownishGray)
        subscriptionAmountLabel.textAlignment = .right
        subscriptionDateLabel.textAlignment = .right
    }
    
    func setStackViews(_ viewModel: CardSubscriptionViewModel) {
        if viewModel.isActive {
            self.subscriptionInfoStackView.isHidden = false
            self.subscriptionSwitchStackView.isHidden = true
        } else {
            self.subscriptionInfoStackView.isHidden = true
            self.subscriptionSwitchStackView.isHidden = !viewModel.isM4MactiveSuscriptionEnabled
        }
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscription.purchaseBaseView
        businessNameLabel.accessibilityIdentifier = AccessibilityCardSubscription.purchaseNameLabel
        subscriptionDateLabel.accessibilityIdentifier = AccessibilityCardSubscription.purchaseDateLabel
        subscriptionAmountLabel.accessibilityIdentifier = AccessibilityCardSubscription.purchaseAmountLabel
    }

    func setStatusLabel(isOn: Bool) {
        subscriptionStatusLabel.text = isOn
            ? localized("m4m_label_enabled")
            : localized("m4m_label_disabled")
        subscriptionStatusLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        subscriptionStatusLabel.textAlignment = .right
        subscriptionStatusLabel.textColor = .darkTorquoise
        subscriptionStatusLabel.numberOfLines = 0
        subscriptionStatusLabel.lineBreakMode = .byTruncatingTail
    }
    
    func setSwitch(isOn: Bool) {
        subscriptionSwitch.isOn = isOn
        subscriptionSwitch.onTintColor = .limeGreen
        subscriptionSwitch.thumbTintColor = .white
        subscriptionSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    func addTapGesture() {
        if self.gestureRecognizers != nil {
            self.gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapInPurchaseView))
        addGestureRecognizer(tap)
    }
    
    @objc func didTapInPurchaseView() {
        delegate?.didTapInPurchaseView()
    }
}
