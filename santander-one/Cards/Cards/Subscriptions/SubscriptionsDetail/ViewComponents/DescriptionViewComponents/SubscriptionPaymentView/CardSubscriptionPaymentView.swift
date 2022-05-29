//
//  CardSubscriptionPaymentView.swift
//  Cards
//
//  Created by Ignacio González Miró on 8/4/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol DidTapInCardSubscriptionPaymentDelegate: AnyObject {
    func didTapInSubscriptionSwitch(_ isOn: Bool)
}

public final class CardSubscriptionPaymentView: XibView {
    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var toolTipButton: ToolTipButton!
    @IBOutlet private weak var subscriptionStatusLabel: UILabel!
    @IBOutlet private weak var subscriptionSwitch: UISwitch!
    @IBOutlet private weak var switchWidhtConstraint: NSLayoutConstraint!
    
    weak var delegate: DidTapInCardSubscriptionPaymentDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel) {
        subscriptionStatusLabel.text = viewModel.isSubscriptionPaymentEnabled
            ? localized("m4m_label_enabled")
            : localized("m4m_label_disabled")
        subscriptionSwitch.isOn = viewModel.isSubscriptionPaymentEnabled
        setSwitch(switchVisible: viewModel.isM4MactiveSuscriptionEnabled)
    }
    
    @objc func didTapInSubscriptionSwitch(_ sender: UISwitch) {
        Async.main { sender.setOn(!sender.isOn, animated: true) }
        delegate?.didTapInSubscriptionSwitch(sender.isOn)
    }
}

private extension CardSubscriptionPaymentView {
    func setupView() {
        setBaseColors()
        setToolTip()
        setStatusLabel()
        setAccessibilityIds()
    }
    
    func setBaseColors() {
        topSeparator.backgroundColor = .lightSkyBlue
        backgroundColor = .skyGray
    }
    
    func setStatusLabel() {
        subscriptionStatusLabel.font = UIFont.santander(family: .text, type: .regular, size: 14)
        subscriptionStatusLabel.textAlignment = .right
        subscriptionStatusLabel.textColor = .darkTorquoise
        subscriptionStatusLabel.numberOfLines = 1
    }
    
    func setToolTip() {
        toolTipButton.backgroundColor = .clear
        toolTipButton.setTitle(localized("m4m_label_paySubscriptions"), for: .normal)
        toolTipButton.setTitleColor(.lisboaGray, for: .normal)
        toolTipButton.setupBg(type: .red, action: toolTipAction)
        toolTipButton.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        toolTipButton.titleLabel?.numberOfLines = 2
        toolTipButton.titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    func toolTipAction(_ sender: UIView) {
        let associated: UIView = toolTipButton.getInfoImageView() ?? toolTipButton
        BubbleLabelView.startWith(associated: associated,
                                  text: localized("tooltip_text_PaySubscription"),
                                  position: .bottom)
    }
    
    func setSwitch(switchVisible: Bool) {
        subscriptionSwitch.isHidden = !switchVisible
        switchWidhtConstraint.constant = switchVisible ? 36 : 0
        subscriptionSwitch.onTintColor = .limeGreen
        subscriptionSwitch.thumbTintColor = .white
        subscriptionSwitch.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.subscriptionPaymentBaseView
        toolTipButton.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.subscriptionPaymentToolTip
        subscriptionStatusLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.subscriptionPaymentStatusLabel
        subscriptionSwitch.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.subscriptionPaymentSwitch
        subscriptionSwitch.addTarget(self, action: #selector(didTapInSubscriptionSwitch), for: .valueChanged)
    }
}
