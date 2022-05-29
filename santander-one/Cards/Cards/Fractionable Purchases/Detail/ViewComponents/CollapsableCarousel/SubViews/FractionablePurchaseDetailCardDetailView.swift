//
//  FractionablePurchaseDetailCardDetailView.swift
//  Cards
//
//  Created by Ignacio González Miró on 31/5/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class FractionablePurchaseDetailCardDetailView: XibView {
    @IBOutlet private weak var puchaseTitleLabel: UILabel!
    @IBOutlet private weak var cardTypeLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: FractionablePurchaseDetailViewModel) {
        puchaseTitleLabel.text = viewModel.financeableMovementEntity.name
        cardTypeLabel.text = viewModel.cardEntity.alias
    }
}

private extension FractionablePurchaseDetailCardDetailView {
    func setupView() {
        backgroundColor = .clear
        setTitleLabel()
        setDescriptionLabel()
        setAccessibilityIds()
    }
    
    func setTitleLabel() {
        puchaseTitleLabel.font = .santander(family: .text, type: .bold, size: 15)
        puchaseTitleLabel.textAlignment = .left
        puchaseTitleLabel.lineBreakMode = .byTruncatingTail
        puchaseTitleLabel.textColor = .lisboaGray
        puchaseTitleLabel.numberOfLines = 1
    }
    
    func setDescriptionLabel() {
        cardTypeLabel.font = .santander(family: .text, type: .regular, size: 14)
        cardTypeLabel.textAlignment = .left
        cardTypeLabel.lineBreakMode = .byTruncatingTail
        cardTypeLabel.textColor = .grafite
        cardTypeLabel.numberOfLines = 1
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.cardDetailBaseView
        puchaseTitleLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.cardDetailTitleLabel
        cardTypeLabel.accessibilityIdentifier = AccessibilityFractionablePurchaseDetail.cardDetailCardTypeLabel
    }
}
