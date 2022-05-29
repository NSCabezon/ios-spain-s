//
//  FractionablePurchaseDetailFeeDetailView.swift
//  Cards
//
//  Created by Ignacio González Miró on 31/5/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class FractionablePurchaseDetailFeeDetailView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var numOfFeeLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: FractionablePurchaseDetailViewModel) {
        amountLabel.attributedText = viewModel.pendingPaymentCapitalAmountAttributeString
        configNumOfFeeLabel(viewModel)
        configProgressView(viewModel)
    }
}

private extension FractionablePurchaseDetailFeeDetailView {
    func setupView() {
        backgroundColor = .clear
        setTitleLabel()
        setAmountLabel()
        setNumOfFeeLabel()
        progressView.progressTintColor = .seafoamBlue
        setAccessibilityIds()
    }
    
    func setTitleLabel() {
        let titleConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 13), alignment: .left, lineBreakMode: .byTruncatingTail)
        titleLabel.configureText(withKey: "transaction_label_pendingAmount", andConfiguration: titleConfig)
        titleLabel.textColor = .grafite
        titleLabel.numberOfLines = 1
    }
    
    func setAmountLabel() {
        amountLabel.font = .santander(family: .text, type: .bold, size: 30)
        amountLabel.textColor = .lisboaGray
        amountLabel.numberOfLines = 1
        amountLabel.textAlignment = .left
    }
    
    func setNumOfFeeLabel() {
        numOfFeeLabel.font = .santander(family: .text, type: .regular, size: 13)
        numOfFeeLabel.textColor = .lisboaGray
        numOfFeeLabel.numberOfLines = 2
        numOfFeeLabel.lineBreakMode = .byTruncatingTail
        numOfFeeLabel.textAlignment = .right
    }
    
    func configNumOfFeeLabel(_ viewModel: FractionablePurchaseDetailViewModel) {
        guard let numOfFeeLocalizedString = viewModel.numOfFeeLocalizedString else {
            return
        }
        numOfFeeLabel.configureText(withLocalizedString: numOfFeeLocalizedString)
    }
    
    func configProgressView(_ viewModel: FractionablePurchaseDetailViewModel) {
        guard let detailEntity = viewModel.financeableMovementDetailEntity,
              let paidFees = detailEntity.paidQuotas,
              let totalFees = detailEntity.numberFees else {
            return
        }
        let paidFeeFloat = Float(paidFees)
        let totalFeesFloat = Float(totalFees)
        let progress = Float(paidFeeFloat/totalFeesFloat)
        progressView.setProgress(progress, animated: false)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.feeDetailBaseView
        titleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.feeDetailTitleLabel
        amountLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.feeDetailAmountLabel
        numOfFeeLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.feeDetailNumOfFeeLabel
    }
}
