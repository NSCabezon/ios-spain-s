//
//  FeePaymentHeaderPillView.swift
//  UI
//
//  Created by Ignacio González Miró on 12/5/21.
//

import UIKit
import CoreFoundationLib

public final class FeePaymentHeaderPillView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: FeeViewModel) {
        let titleConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 10), alignment: .left, lineHeightMultiple: 0.9, lineBreakMode: .byTruncatingTail)
        titleLabel.configureText(withKey: "generic_label_monthlyFee",
                                 andConfiguration: titleConfig)
        setAmountLabel(viewModel)
    }
}

private extension FeePaymentHeaderPillView {
    func setupView() {
        backgroundColor = .clear
        titleLabel.textColor = .grafite
        amountLabel.textColor = .darkTorquoise
        separatorView.backgroundColor = .mediumSkyGray
        setAccessibilityIds()
    }
    
    func setAmountLabel(_ viewModel: FeeViewModel) {
        if viewModel.isFeePerMonths() {
            // Amount
            let amountAttributedText = self.amountAttributedText(viewModel.amount)
            amountLabel.attributedText = amountAttributedText
        } else {
            // Other period
            let amountConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .bold, size: 18.8), alignment: .left, lineHeightMultiple: 0.9, lineBreakMode: .byTruncatingTail)
            amountLabel.configureText(withKey: "easyPay_button_anotherTerm", andConfiguration: amountConfig)
            amountLabel.adjustsFontSizeToFitWidth = true
        }
    }
    
    func amountAttributedText(_ amountEntity: AmountEntity?) -> NSAttributedString? {
        guard let amount = amountEntity else {
            return nil
        }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 18)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 13)
        return decorator.getFormatedCurrency()
    }
    
    func setAccessibilityIds() {
        titleLabel.accessibilityIdentifier = AccessibilitySeeFractionableOptions.feePaymentsTitleLabel
        amountLabel.accessibilityIdentifier = AccessibilitySeeFractionableOptions.feePaymentsAmountLabel
    }
}
