//
//  SimplePGHeaderView.swift
//  toTest
//
//  Created by alvola on 08/10/2019.
//  Copyright © 2019 alp. All rights reserved.
//

import UIKit
import UI
import CoreFoundationLib
import UIOneComponents

protocol SimplePGHeaderViewProtocol {
    func setUsername(_ username: String, money: NSAttributedString?, birthDay: Bool, isMoneyVisible: Bool)
    func estimatedHeightForUsername() -> CGFloat
    func setDelegate(_ delegate: SimplePGHeaderViewDelegate?)
    func setDiscreteMode(_ enabled: Bool)
}

protocol SimplePGHeaderViewDelegate: AnyObject {
    func usernameDidPressed()
    func balanceDidPressed()
}

final class SimplePGHeaderView: DesignableView, SimplePGHeaderViewProtocol {
    
    @IBOutlet private weak var topConstraint: NSLayoutConstraint?
    @IBOutlet private weak var yourMoneyHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var infoTooltipButton: UIButton!
    @IBOutlet private weak var infoImageView: UIImageView!
    @IBOutlet private weak var regardLabel: UILabel!
    @IBOutlet private weak var contextSelectorButton: UIButton!
    @IBOutlet private weak var yourMoneyLabel: UILabel!
    @IBOutlet private weak var moneyNumberLabel: UILabel!
    @IBOutlet private weak var actionsBar: OneShortcutsView!

    private weak var delegate: SimplePGHeaderViewDelegate?
    private var contextSelectorModifier: ContextSelectorModifierProtocol?
    private var discretMode = false
    private var regards: LocalizedStylableText?

    override internal func commonInit() {
        super.commonInit()
        self.configureLabels()
        self.configureView()
        self.configureImages()
        self.setAccessibility()
        self.setAccessibilityIdentifiers()
    }

    func setDelegate(_ delegate: SimplePGHeaderViewDelegate?) {
        self.delegate = delegate
    }

    func setContextSelectorModifier(_ contextSelectorModifier: ContextSelectorModifierProtocol?) {
        self.contextSelectorModifier = contextSelectorModifier
    }
    
    func setUsername(_ username: String, money: NSAttributedString?, birthDay: Bool, isMoneyVisible: Bool) {
        if !isMoneyVisible {
            self.hideYourMoney()
        }
        let titleKey = birthDay ? "pg_title_happyBirthday" : "pg_title_welcome"
        let isContextSelectorEnabled = self.contextSelectorModifier?.isContextSelectorEnabled ?? false
        self.configureRegard(titleKey, name: username, isContextSelectorEnabled: isContextSelectorEnabled)
        self.moneyNumberLabel?.attributedText = money
        self.setAmountLabelAccessibility()
        guard !isContextSelectorEnabled else { return }
        if birthDay { self.birthDayEnabled() }
    }
    
    func estimatedHeightForUsername() -> CGFloat {
        guard let label = self.regardLabel else { return 0.0 }
        return self.height(for: label.text ?? "", label.font, label.frame.width)
    }

    func setDiscreteMode(_ enabled: Bool) {
        self.discretMode = enabled
        self.setAccessibility()
        guard enabled else {
            self.moneyNumberLabel?.removeBlur()
            return
        }
        self.moneyNumberLabel?.blur(5.0)
        self.layoutIfNeeded()
    }
    
    func setAvailableActions(_ actions: [GpOperativesViewModel]?, areActionsHidden: Bool) {
        self.actionsBar.isHidden = actions == nil || areActionsHidden
        var shortcutsButtons = [OneShortcutButtonConfiguration]()
        actions?.forEach { action in
            if case let .defaultButton(viewModel) = action.viewType {
                let shortcutButton = OneShortcutButtonConfiguration(title: viewModel.title,
                                                                    icon: viewModel.imageKey,
                                                                    backgroundColor: .oneWhite,
                                                                    backgroundImage: nil,
                                                                    offerImage: nil,
                                                                    tagTitle: nil,
                                                                    isDisabled: action.isDisabled,
                                                                    action: { action.action?(action.type, action.entity) })
                shortcutsButtons.append(shortcutButton)
            }
        }
        self.actionsBar.removeButtons()
        self.actionsBar.addButtons(buttons: shortcutsButtons)
    }

    @IBAction func didPressContextSelector(_ sender: UIButton) {
        self.contextSelectorModifier?.pressedContextSelector()
    }

    @IBAction func showToolTip(_ sender: UIButton) {
        guard infoImageView != nil else { return }
        delegate?.balanceDidPressed()
    }
}

// MARK: - privateMethods

private extension SimplePGHeaderView {
    private func configureView() {
        self.actionsBar.hideMoreOptionsButton()
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 0
        self.layer.shadowColor = UIColor.botonRedLight.cgColor
        self.layer.shadowOpacity = 0.7
        self.topConstraint?.constant = UIApplication.shared.statusBarFrame.height + (Screen.isScreenSizeBiggerThanIphone5() ? 0 : 2)
    }

    private func configureImages() {
        self.contextSelectorButton.setImage(Assets.image(named: "oneIcnChevronKontext"), for: .normal)
        self.infoImageView.image = Assets.image(named: "oneIcnHelp")
    }

    private func configureLabels() {
        self.yourMoneyLabel.font = UIFont.typography(fontName: .oneB300Regular)
        self.yourMoneyLabel.textColor = .brownishGray
        self.yourMoneyLabel.text = localized("pg_label_totMoney")
        self.moneyNumberLabel.textColor = .lisboaGray
        self.configureRegard("pg_title_welcome", name: "", isContextSelectorEnabled: false)
    }

    private func birthDayEnabled() {
        self.regardLabel.isUserInteractionEnabled = true
        self.regardLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(usernameDidPressed)))
    }

    @objc private func usernameDidPressed() {
        self.delegate?.usernameDidPressed()
    }

    private func configureRegard(_ key: String, name: String, isContextSelectorEnabled: Bool) {
        self.regardLabel.textColor = .lisboaGray
        self.regards = localized(key, [StringPlaceholder(StringPlaceholder.Placeholder.name, name)])
        if isContextSelectorEnabled {
            self.configureContextSelector(withName: name)
        }
        guard let regards = self.regards else { return }
        let regardTextConfiguration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, size: 28))
        self.regardLabel.configureText(withLocalizedString: regards, andConfiguration: regardTextConfiguration)
    }

    private func configureContextSelector(withName name: String) {
        let contextName = self.contextSelectorModifier?.contextName?.camelCasedString ?? ""
        let name = (contextName.isBlank ? name : contextName).withMaxSize(20, truncateTail: !contextName.isBlank)
        self.regards = localized("pg_title_welcome", [StringPlaceholder(StringPlaceholder.Placeholder.name, name)])
        let showContextSelector = self.contextSelectorModifier?.showContextSelector ?? false
        self.contextSelectorButton.isHidden = !showContextSelector
    }

    private func height(for text: String, _ font: UIFont, _ width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }

    private func hideYourMoney() {
        self.yourMoneyHeightConstraint?.constant = 0
        self.yourMoneyLabel.isHidden = true
        self.moneyNumberLabel.isHidden = true
        self.infoTooltipButton.isHidden = true
        self.infoImageView.isHidden = true
        self.setNeedsLayout()
    }

    private func setAccessibility() {
        self.regardLabel.accessibilityIdentifier = AccessibilityGlobalPosition.generalProductSimpleHeaderRegardLabel
        self.regardLabel.isAccessibilityElement = false
        self.infoImageView.accessibilityIdentifier = AccessibilityGlobalPosition.icnSmallInfo
        self.infoImageView.isAccessibilityElement = false
        self.yourMoneyLabel.accessibilityIdentifier = AccessibilityGlobalPosition.generalProductSimpleHeaderYourMoneyLabel
        self.yourMoneyLabel.isAccessibilityElement = false
        self.moneyNumberLabel.accessibilityIdentifier = AccessibilityGlobalPosition.generalProductSimpleHeaderMoneyNumberLabel
        self.moneyNumberLabel.isAccessibilityElement = !self.discretMode
        self.infoTooltipButton.accessibilityIdentifier = AccessibilityGlobalPosition.btnYourBalanceToolTip
        self.infoTooltipButton.isAccessibilityElement = true
        self.infoTooltipButton.accessibilityLabel = localized(self.yourMoneyLabel.text ?? "")
        self.contextSelectorButton.accessibilityIdentifier = AccessibilityGlobalPosition.pgBtnContext
    }

    private func setAmountLabelAccessibility() {
        guard let label = self.moneyNumberLabel.attributedText?.string else { return }
        let billons = localized("voiceover_billions").text
        let millons = localized("voiceover_millons").text
        self.moneyNumberLabel.accessibilityLabel = label.replacingOccurrences(of: "B", with: billons)
        self.moneyNumberLabel.accessibilityLabel = label.replacingOccurrences(of: "M", with: millons)
    }
    
    private func setAccessibilityIdentifiers() {
        self.regardLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgTitleWelcome
        self.infoImageView.accessibilityIdentifier = AccessibilityGlobalPosition.pgInfoImage
        self.yourMoneyLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgYourMoney
        self.moneyNumberLabel.accessibilityIdentifier = AccessibilityGlobalPosition.pgYourMoneyValue
    }
}
