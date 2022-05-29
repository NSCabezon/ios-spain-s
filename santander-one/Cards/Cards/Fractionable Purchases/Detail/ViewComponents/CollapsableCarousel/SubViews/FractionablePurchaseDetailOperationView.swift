//
//  FractionablePurchaseDetailOperationView.swift
//  Cards
//
//  Created by Ignacio González Miró on 31/5/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class FractionablePurchaseDetailOperationView: XibView {
    @IBOutlet private weak var operationDateTitleLabel: UILabel!
    @IBOutlet private weak var operationDateLabel: UILabel!
    @IBOutlet private weak var dateTitleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var bottomSeparator: DashedLineView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configView(_ viewModel: FractionablePurchaseDetailViewModel) {
        operationDateLabel.text = viewModel.operationDateFormatted
        dateLabel.text = viewModel.lastLiquidationDateFormatted
    }
}

private extension FractionablePurchaseDetailOperationView {
    func setupView() {
        backgroundColor = .clear
        setLabelAppeareance()
        setSeparators()
        setAccessibilityIds()
    }
    
    func setLabelAppeareance() {
        setAmortizedTitleLabel()
        setDateTitleLabel()
        setOperationDateLabel()
        setDateLabel()
    }
    
    func setAmortizedTitleLabel() {
        let amortizedTitleConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13), alignment: .left, lineBreakMode: .byTruncatingTail)
        operationDateTitleLabel.configureText(withKey: "transaction_label_operationDate", andConfiguration: amortizedTitleConfig)
        operationDateTitleLabel.textColor = .grafite
        operationDateTitleLabel.numberOfLines = 1
    }
    
    func setDateTitleLabel() {
        let dateTitleConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13), alignment: .right, lineBreakMode: .byTruncatingTail)
        dateTitleLabel.configureText(withKey: "fractionatePurchases_label_deferDate", andConfiguration: dateTitleConfig)
        dateTitleLabel.textColor = .grafite
        dateTitleLabel.numberOfLines = 1
    }
    
    func setOperationDateLabel() {
        operationDateLabel.font = .santander(family: .text, type: .bold, size: 13)
        operationDateLabel.textAlignment = .left
        operationDateLabel.lineBreakMode = .byTruncatingTail
        operationDateLabel.textColor = .grafite
        operationDateLabel.numberOfLines = 1
    }
    
    func setDateLabel() {
        dateLabel.font = .santander(family: .text, type: .bold, size: 13)
        dateLabel.textAlignment = .right
        dateLabel.lineBreakMode = .byTruncatingTail
        dateLabel.textColor = .lisboaGray
        dateLabel.numberOfLines = 1
    }
    
    func setSeparators() {
        topSeparator.backgroundColor = .mediumSky
        bottomSeparator.strokeColor = .grafite
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.operationDetailBaseView
        operationDateTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.operationDetailOperationDateTitleLabel
        operationDateLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.operationDetailOperationDateLabel
        dateTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.operationDetailDateTitleLabel
        dateLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.operationDetailDateLabel
    }
}
