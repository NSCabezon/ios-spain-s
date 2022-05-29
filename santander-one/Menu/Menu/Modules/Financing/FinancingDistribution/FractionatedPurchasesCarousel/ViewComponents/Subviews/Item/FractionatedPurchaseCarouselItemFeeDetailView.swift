//
//  FractionatedPurchaseCarouselItemView.swift
//  Menu
//
//  Created by Ignacio González Miró on 7/7/21.
//

import UIKit
import UI
import CoreFoundationLib

final class FractionatedPurchaseCarouselItemFeeDetailView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var easyPayMonthlyFeeView: EasyPayMonthlyFeeView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func configView(_ viewModel: FractionatePurchasesCarouselDetailViewModel) {
        addTitleLabel()
        addDetailView(viewModel)
    }
}

private extension FractionatedPurchaseCarouselItemFeeDetailView {
    func setupView() {
        backgroundColor = .clear
        accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.itemCellFeeDetailBaseView
    }
    
    func addTitleLabel() {
        let titleConfig = LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 10), alignment: .left, lineBreakMode: .none)
        titleLabel.configureText(withKey: "fractionatePurchases_label_nextInstalment", andConfiguration: titleConfig)
        titleLabel.textColor = .brownishGray
        titleLabel.numberOfLines = 1
        titleLabel.accessibilityIdentifier = AccessibilityFractionatedPurchasesCarouselItem.itemCellFeeDetailNextFeeLabel
    }
    
    func addDetailView(_ viewModel: FractionatePurchasesCarouselDetailViewModel) {
        easyPayMonthlyFeeView.setMonthlyFee(viewModel)
        easyPayMonthlyFeeView.hideBottomSeparator(true)
    }
}
