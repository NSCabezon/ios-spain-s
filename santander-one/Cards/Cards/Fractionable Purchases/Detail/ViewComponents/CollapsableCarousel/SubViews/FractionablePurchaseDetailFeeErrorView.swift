//
//  FractionablePurchaseDetailFeeErrorView.swift
//  Cards
//
//  Created by Ignacio González Miró on 9/6/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class FractionablePurchaseDetailFeeErrorView: XibView {
    @IBOutlet private weak var numOfFeesLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configView(_ viewModel: FractionablePurchaseDetailViewModel) {
        numOfFeesLabel.configureText(withLocalizedString: viewModel.numOfFeesInErrorString)
        configProgressView(viewModel)
    }
}

private extension FractionablePurchaseDetailFeeErrorView {
    func setupView() {
        backgroundColor = .clear
        setNumOfFeeLabel()
        progressView.progressTintColor = .seafoamBlue
        setAccessibilityIds()
    }
    
    func setNumOfFeeLabel() {
        numOfFeesLabel.font = .santander(family: .text, type: .regular, size: 13)
        numOfFeesLabel.textColor = .lisboaGray
        numOfFeesLabel.numberOfLines = 2
        numOfFeesLabel.lineBreakMode = .byTruncatingTail
        numOfFeesLabel.textAlignment = .right
    }
    
    func configProgressView(_ viewModel: FractionablePurchaseDetailViewModel) {
        let numOfFees = Float(viewModel.financeableMovementEntity.pendingFees)
        let progress: Float = numOfFees * 0.1
        progressView.setProgress(progress, animated: false)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.feeDetailErrorBaseView
        numOfFeesLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.feeDetailErrorNumOfFeesLabel
        progressView.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.feeDetailErrorProgressView
    }
}
