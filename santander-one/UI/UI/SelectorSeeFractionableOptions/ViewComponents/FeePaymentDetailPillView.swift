//
//  FeePaymentDetailPillView.swift
//  UI
//
//  Created by Ignacio González Miró on 12/5/21.
//

import UIKit
import CoreFoundationLib

public final class FeePaymentDetailPillView: XibView {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var bottomStackViewConstraint: NSLayoutConstraint!

    private var monthLabel = UILabel()
    private var noInterestLabel = UILabel()
    private let singleLabelStackBottomMargin = 20.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: FeeViewModel, viewIndexInContainer: Int) {
        if viewModel.isFeePerMonths() {
            fillWithFeePerMonths(viewModel, viewIndexInContainer: viewIndexInContainer)
        } else {
            fillWithOtherFee(viewModel.maxMonths)
        }
    }
}

private extension FeePaymentDetailPillView {
    func setupView() {
        backgroundColor = .clear
        setupLabel(monthLabel, textColor: .lisboaGray)
        setupLabel(noInterestLabel, textColor: .bostonRed)
        setAccessibilityIds()
    }
    
    func fillWithFeePerMonths(_ viewModel: FeeViewModel, viewIndexInContainer: Int) {
        let monthsText = self.monthsText(viewModel)
        let monthConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 12), alignment: .left, lineHeightMultiple: 0.9, lineBreakMode: .byTruncatingTail)
        monthLabel.configureText(withLocalizedString: monthsText,
                                 andConfiguration: monthConfig)
        stackView.addArrangedSubview(monthLabel)
        if getShowNoInterestText(viewModel: viewModel, viewIndex: viewIndexInContainer) {
            let noInterestConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 10), alignment: .left, lineBreakMode: .byTruncatingTail)
            noInterestLabel.configureText(withKey: "easyPay_text_noInterest",
                                          andConfiguration: noInterestConfig)
            stackView.addArrangedSubview(noInterestLabel)
        } else {
            updateBottomStackViewConstraint()
        }
    }
    
    func fillWithOtherFee(_ maxMonths: String) {
        let monthConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 12), alignment: .left, lineHeightMultiple: 0.9, lineBreakMode: .byTruncatingTail)
        let monthLocalizedText = localized("simulator_label_untilMonths", [StringPlaceholder(.number, maxMonths)])
        monthLabel.configureText(withLocalizedString: monthLocalizedText,
                                 andConfiguration: monthConfig)
        monthLabel.adjustsFontSizeToFitWidth = true
        updateBottomStackViewConstraint()
        stackView.addArrangedSubview(monthLabel)
    }
    
    func monthsText(_ viewModel: FeeViewModel) -> LocalizedStylableText {
        return viewModel.isEasyPayMonthText
            ? localized("easyPay_text_payIn", [StringPlaceholder(.number, viewModel.months)])
            : localized("simulator_label_months", [StringPlaceholder(.value, viewModel.months)])
    }
    
    func getShowNoInterestText(viewModel: FeeViewModel, viewIndex: Int) -> Bool {
        return viewModel.isAllInOneCard &&
        viewIndex == InstallmentsConstants.averageTermIndex &&
        viewModel.getFeeEntity.months == InstallmentsConstants.allInOneNoInterestTerm &&
        viewModel.getFeeEntity.currentAmount >= InstallmentsConstants.allInOneCardLowerLimitQuote &&
        viewModel.getFeeEntity.currentAmount <= InstallmentsConstants.allInOneCardUpperLimitQuote
    }
    
    func setupLabel(_ label: UILabel, textColor: UIColor) {
        label.contentMode = .top
        label.textColor = textColor
    }
    
    func updateBottomStackViewConstraint() {
        bottomStackViewConstraint.constant = singleLabelStackBottomMargin
    }
    
    func setAccessibilityIds() {
        monthLabel.accessibilityIdentifier = AccessibilitySeeFractionableOptions.feePaymentsMonthLabel
        noInterestLabel.accessibilityIdentifier = AccessibilitySeeFractionableOptions.feePaymentsNoInterestLabel
    }
}
