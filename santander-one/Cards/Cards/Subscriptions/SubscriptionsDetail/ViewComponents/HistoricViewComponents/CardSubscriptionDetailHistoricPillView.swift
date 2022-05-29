//
//  CardSubscriptionDetailHistoricPillView.swift
//  Cards
//
//  Created by Ignacio González Miró on 15/4/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class CardSubscriptionDetailHistoricPillView: XibView {
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    
    private var viewModel: CardSubscriptionDetailHistoricViewModel?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        self.viewModel = viewModel
        dateLabel.text = viewModel.dateString
        titleLabel.text = viewModel.businessName
        amountLabel.attributedText = viewModel.amountAttributeString
    }
}

private extension CardSubscriptionDetailHistoricPillView {
    func setupView() {
        backgroundColor = .clear
        amountLabel.textColor = .lisboaGray
        setDateLabel()
        setTitleLabel()
        setAccessibilityIds()
    }
    
    func setDateLabel() {
        dateLabel.font = UIFont.santander(family: .text, type: .bold, size: 14)
        dateLabel.numberOfLines = 1
        dateLabel.lineBreakMode = .byTruncatingTail
        dateLabel.textAlignment = .left
        dateLabel.textColor = .bostonRed
    }
    
    func setTitleLabel() {
        titleLabel.font = UIFont.santander(family: .text, type: .bold, size: 16)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .left
        titleLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.historicPillBaseView
        dateLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.historicPillDateLabel
        titleLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.historicPillBaseViewTitleLabel
        amountLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.historicPillBaseViewAmountLabel
    }
}
