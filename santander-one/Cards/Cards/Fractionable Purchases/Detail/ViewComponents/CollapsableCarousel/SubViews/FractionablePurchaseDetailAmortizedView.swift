//
//  FractionablePurchaseDetailAmortizedView.swift
//  Cards
//
//  Created by Ignacio González Miró on 31/5/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class FractionablePurchaseDetailAmortizedView: XibView {
    @IBOutlet private weak var amortizedTitleLabel: UILabel!
    @IBOutlet private weak var amortizedLabel: UILabel!
    @IBOutlet private weak var totalAmountTitleLabel: UILabel!
    @IBOutlet private weak var totalAmountLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: FractionablePurchaseDetailViewModel) {
        amortizedLabel.text = viewModel.paidCapitalAmountString
        totalAmountLabel.text = viewModel.totalAmountString
    }
}

private extension FractionablePurchaseDetailAmortizedView {
    func setupView() {
        backgroundColor = .clear
        setLabelAppeareance()
        setAccessibilityIds()
    }
    
    func setLabelAppeareance() {
        setAmortizedTitleLabel()
        setAmortizedAmountLabel()
        setTotalAmountTitleLabel()
        setTotalAmountLabel()
    }
    
    func setAmortizedTitleLabel() {
        let amortizedTitleConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13), alignment: .left, lineBreakMode: .byTruncatingTail)
        amortizedTitleLabel.configureText(withKey: "fractionatePurchases_label_capitalRepaid", andConfiguration: amortizedTitleConfig)
        amortizedTitleLabel.textColor = .grafite
        amortizedTitleLabel.numberOfLines = 1
    }
    
    func setTotalAmountTitleLabel() {
        let dateTitleConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13), alignment: .right, lineBreakMode: .byTruncatingTail)
        totalAmountTitleLabel.configureText(withKey: "easyPay_label_totalAmount", andConfiguration: dateTitleConfig)
        totalAmountTitleLabel.textColor = .grafite
        totalAmountTitleLabel.numberOfLines = 1
    }
    
    func setAmortizedAmountLabel() {
        amortizedLabel.font = .santander(family: .text, type: .bold, size: 16)
        amortizedLabel.textAlignment = .left
        amortizedLabel.lineBreakMode = .byTruncatingTail
        amortizedLabel.textColor = .grafite
        amortizedLabel.numberOfLines = 1
    }
    
    func setTotalAmountLabel() {
        totalAmountLabel.font = .santander(family: .text, type: .bold, size: 16)
        totalAmountLabel.textAlignment = .right
        totalAmountLabel.lineBreakMode = .byTruncatingTail
        totalAmountLabel.textColor = .lisboaGray
        totalAmountLabel.numberOfLines = 1
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.amortizedBaseView
        amortizedTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.amortizedTitleLabel
        amortizedLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.amortizedValueLabel
        totalAmountTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.amortizedTotalAmountTitleLabel
        totalAmountLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.amortizedTotalAmountValueLabel
    }
}
