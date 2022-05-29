//
//  CardSubscriptionDateView.swift
//  Cards
//
//  Created by Ignacio González Miró on 8/4/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class CardSubscriptionDateView: XibView {
    @IBOutlet private weak var startLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel) {
        startLabel.text = localized("m4m_label_startedOn")
        dateLabel.text = viewModel.subscriptionDate
    }
}

private extension CardSubscriptionDateView {
    func setupView() {
        backgroundColor = .clear
        setStartLabel()
        setDateLabel()
        setAccessibilityIds()
    }
    
    func setStartLabel() {
        startLabel.numberOfLines = 1
        startLabel.textAlignment = .left
        startLabel.setSantanderTextFont(type: .regular, size: 16, color: .lisboaGray)
    }
    
    func setDateLabel() {
        dateLabel.numberOfLines = 1
        dateLabel.textAlignment = .right
        dateLabel.setSantanderTextFont(type: .bold, size: 16, color: .lisboaGray)
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailDateBaseView
        startLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailDateStartLabel
        dateLabel.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailDateDateLabel
    }
}
