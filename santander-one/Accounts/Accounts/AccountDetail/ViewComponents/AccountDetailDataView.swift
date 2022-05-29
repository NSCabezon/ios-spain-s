//
//  AccountDetailDataView.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 05/02/2021.
//

import Foundation
import UI
import UIKit
import CoreFoundationLib

final class AccountDetailDataView: XibView {
    
    @IBOutlet private weak var titleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleMainConstraint: NSLayoutConstraint!
    @IBOutlet private weak var accountNameLabel: UILabel!
    @IBOutlet private weak var ibanLabel: UILabel!
    @IBOutlet private weak var copyIconIbanImageView: UIImageView!
    @IBOutlet private weak var balanceLabel: UILabel!
    @IBOutlet private weak var balanceTooltipButton: UIButton!
    @IBOutlet private weak var amountBalanceLabel: UILabel!
    @IBOutlet private weak var retentionLabel: UILabel!
    @IBOutlet private weak var amountRetentionLabel: UILabel!
    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var mainLabel: UILabel!
    weak var delegate: AccountDetailDataViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setupAccountDetailDataView(viewModel: AccountDetailDataViewModel) {
        self.setUpAccountName(viewModel.accountName)
        self.ibanLabel?.text = viewModel.productNumber
        self.amountBalanceLabel?.attributedText = viewModel.availableBigAmountAttributedString
        if let retention = viewModel.hold {
            self.amountRetentionLabel?.text = retention
        } else {
            self.amountRetentionLabel.isHidden = true
            self.retentionLabel.isHidden = true
        }
        if let isMainAccount = viewModel.mainItem {
            self.titleMainConstraint.isActive = true
            self.titleConstraint.isActive = false
            if isMainAccount == true {
                self.configureMainAccountView()
            } else {
                self.mainView.isHidden = true
            }
        } else {
            self.mainView.isHidden = true
        }
    }
    
    func setUpAccountName(_ accountName: String) {
        self.accountNameLabel?.text = accountName
    }
    
    func isMainAccount() {
        self.configureMainAccountView()
        self.titleMainConstraint.isActive = true
        self.titleConstraint.isActive = false
        self.mainView.isHidden = false
    }
    
    @IBAction func didTapOnBalanceTooltipButton(_ sender: UIButton) {
        let styledText: LocalizedStylableText = localized("accountDetail_tooltip_availableBalance")
        BubbleLabelView.startWith(associated: sender, text: styledText.text, position: .bottom)
    }
}

extension AccountDetailDataView {
    
    var amountRetentionLabelIsHidden: Bool {
        return amountRetentionLabel.isHidden
    }
}

private extension AccountDetailDataView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.accountNameLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.accountNameLabel.textColor = .lisboaGray
        self.ibanLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.ibanLabel.textColor = .grafite
        self.balanceLabel.textColor = .grafite
        self.balanceLabel?.configureText(withKey: "accountHome_label_availableBalance",
                                         andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13)))
        self.amountBalanceLabel.font = .santander(family: .text, type: .bold, size: 36)
        self.amountBalanceLabel.textColor = .lisboaGray
        self.retentionLabel.textColor = .grafite
        self.retentionLabel?.configureText(withKey: "productDetail_label_withholding",
                                           andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13)))
        self.amountRetentionLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.amountRetentionLabel.textColor = .lisboaGray
        self.balanceTooltipButton.setImage(Assets.image(named: "icnInfoRedLight")?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.balanceTooltipButton.isAccessibilityElement = true
        self.copyIconIbanImageView.image = Assets.image(named: "icnCopyGreen")
        self.drawBorder(cornerRadius: 4, color: .mediumSkyGray, width: 1)
        self.imageTap()
        self.setAccessibilityIdentifiers()
        self.setupAccessibilityIds()
    }
    
    func configureMainAccountView() {
        self.mainView?.drawBorder(cornerRadius: 2, color: .limeGreen, width: 1)
        self.mainView.backgroundColor = .limeGreen
        self.mainLabel.font = .santander(family: .text, type: .bold, size: 12)
        self.mainLabel?.textColor = .white
        self.mainLabel.text = localized("pt_productDetail_tag_principal").uppercased()
    }
    
    func imageTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(copyIban(tapGestureRecognizer:)))
        self.copyIconIbanImageView.isUserInteractionEnabled = true
        self.copyIconIbanImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func copyIban(tapGestureRecognizer: UITapGestureRecognizer) {
        UIPasteboard.general.string = self.ibanLabel?.text
        self.copyIconIbanImageView.isUserInteractionEnabled = false
        self.delegate?.didTapOnCopyIban({ [weak self] in
            self?.copyIconIbanImageView.isUserInteractionEnabled = true
        })
    }
    
    func setAccessibilityIdentifiers() {
        self.accountNameLabel.accessibilityIdentifier = AccessibilityAccountDetail.accountAlias
        self.ibanLabel.accessibilityIdentifier = AccessibilityAccountDetail.accountIban
        self.copyIconIbanImageView.accessibilityIdentifier = AccessibilityAccountDetail.copyIBAN
        self.balanceLabel.accessibilityIdentifier = AccessibilityAccountDetail.accountAvailableBalanceLabel
        self.balanceTooltipButton.accessibilityIdentifier = AccessibilityAccountDetail.accountTooltip
        self.balanceTooltipButton.imageView?.accessibilityIdentifier = AccessibilityAccountDetail.icnAccountTooltip
        self.amountBalanceLabel.accessibilityIdentifier = AccessibilityAccountDetail.accountAvailableBalanceAmount
        self.retentionLabel.accessibilityIdentifier = AccessibilityAccountDetail.accountRetentionLabel
        self.amountRetentionLabel.accessibilityIdentifier = AccessibilityAccountDetail.accountRetentionAmount
        self.view?.accessibilityIdentifier = AccessibilityAccountDetail.accountHeaderView
        self.mainLabel.accessibilityIdentifier = AccessibilityAccountDetail.mainLabel
    }
    
    func setupAccessibilityIds() {
        self.copyIconIbanImageView.accessibilityLabel = localized(AccessibilityAccountDetail.copyIBAN)
        self.copyIconIbanImageView.accessibilityTraits = .button
        self.balanceTooltipButton.accessibilityLabel = localized(AccessibilityAccountDetail.tooltipButton)
    }
}
