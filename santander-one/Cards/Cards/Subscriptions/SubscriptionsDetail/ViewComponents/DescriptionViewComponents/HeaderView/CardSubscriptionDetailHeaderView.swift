//
//  CardSubscriptionDetailHeaderView.swift
//  Cards
//
//  Created by Ignacio González Miró on 8/4/21.
//

import UIKit
import UI
import CoreFoundationLib

public final class CardSubscriptionDetailHeaderView: XibView {
    @IBOutlet private weak var headerImage: CardSubscriptionPurchaseImageView!
    @IBOutlet private weak var headerTitle: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: CardSubscriptionViewModel) {
        headerImage.configView(viewModel)
        headerTitle.text = viewModel.businessName
    }
}

private extension CardSubscriptionDetailHeaderView {
    func setupView() {
        backgroundColor = .clear
        setTitle()
        setAccessibilityIds()
    }
    
    func setTitle() {
        headerTitle.font = UIFont.santander(family: .text, type: .bold, size: 20)
        headerTitle.textAlignment = .left
        headerTitle.textColor = .lisboaGray
        headerTitle.numberOfLines = 0
        headerTitle.lineBreakMode = .byTruncatingTail
    }
    
    func setAccessibilityIds() {
        accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailHeaderBaseView
        headerImage.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailHeaderTitleLabel
        headerTitle.accessibilityIdentifier = AccessibilityCardSubscriptionDetail.detailHeaderImageView
    }
}
