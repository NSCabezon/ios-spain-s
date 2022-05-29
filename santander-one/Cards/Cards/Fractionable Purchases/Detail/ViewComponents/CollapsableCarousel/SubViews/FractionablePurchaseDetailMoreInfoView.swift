//
//  FractionablePurchaseDetailMoreInfoView.swift
//  Cards
//
//  Created by Ignacio González Miró on 31/5/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class FractionablePurchaseDetailMoreInfoView: XibView {
    @IBOutlet private weak var numOfMonthsTitleLabel: UILabel!
    @IBOutlet private weak var numOfMonthsLabel: UILabel!
    @IBOutlet private weak var feeTitleLabel: UILabel!
    @IBOutlet private weak var feeLabel: UILabel!
    @IBOutlet private weak var interestsTitleLabel: UILabel!
    @IBOutlet private weak var interestsLabel: UILabel!
    @IBOutlet private weak var capitalTitleLabel: UILabel!
    @IBOutlet private weak var capitalLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configView(_ viewModel: FractionablePurchaseDetailViewModel) {
        guard let numOfMonthsLocalizedString = viewModel.numOfMonthsLocalizedString else {
            return
        }
        numOfMonthsLabel.configureText(withLocalizedString: numOfMonthsLocalizedString)
        feeLabel.text = viewModel.feeAmountString
        interestsLabel.text = viewModel.interestAmountString
        capitalLabel.text = viewModel.capitalAmountString
    }
}

private extension FractionablePurchaseDetailMoreInfoView {
    func setupView() {
        backgroundColor = .clear
        setLabelAppeareance()
        setAccessibilityIds()
    }
    
    func setLabelAppeareance() {
        let localizedConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 14), alignment: .left, lineBreakMode: .none)
        setNumOfMonthSection(localizedConfig)
        setFeeSection(localizedConfig)
        setInterestsSection(localizedConfig)
        setCapitalSection(localizedConfig)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoBaseView
        numOfMonthsTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoNumOfMonthsTitleLabel
        numOfMonthsLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoNumOfMonthsLabel
        feeTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoFeeTitleLabel
        feeLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoFeeLabel
        interestsTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoInterestsTitleLabel
        interestsLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoInterestsLabel
        capitalTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoCapitalTitleLabel
        capitalLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.moreInfoCapitalLabel
    }
    
    // MARK: Set Sections
    func setNumOfMonthSection(_ localizedConfig: LocalizedStylableTextConfiguration) {
        numOfMonthsTitleLabel.configureText(withKey: "easyPay_label_toPay", andConfiguration: localizedConfig)
        setTitleLabelAppeareance(self.numOfMonthsTitleLabel)
        setDescriptionLabelAppeareance(self.numOfMonthsLabel)
    }
    
    func setFeeSection(_ localizedConfig: LocalizedStylableTextConfiguration) {
        feeTitleLabel.configureText(withKey: "fractionatePurchases_label_instalment", andConfiguration: localizedConfig)
        setTitleLabelAppeareance(self.feeTitleLabel)
        setDescriptionLabelAppeareance(self.feeLabel)
    }
    
    func setInterestsSection(_ localizedConfig: LocalizedStylableTextConfiguration) {
        interestsTitleLabel.configureText(withKey: "easyPay_label_interest", andConfiguration: localizedConfig)
        setTitleLabelAppeareance(self.interestsTitleLabel)
        setDescriptionLabelAppeareance(self.interestsLabel)
    }
    
    func setCapitalSection(_ localizedConfig: LocalizedStylableTextConfiguration) {
        capitalTitleLabel.configureText(withKey: "transaction_label_amount", andConfiguration: localizedConfig)
        setTitleLabelAppeareance(self.capitalTitleLabel)
        setDescriptionLabelAppeareance(self.capitalLabel)
    }
    
    func setTitleLabelAppeareance(_ label: UILabel) {
        label.textColor = .grafite
        label.numberOfLines = 1
    }
    
    func setDescriptionLabelAppeareance(_ label: UILabel) {
        label.font = .santander(family: .text, type: .bold, size: 13)
        label.textAlignment = .right
        label.textColor = .lisboaGray
        label.numberOfLines = 1
    }
}
