//
//  FundSectionEmptyView.swift
//  Funds
//
//  Created by Simón Aparicio on 28/3/22.
//

import UIKit
import UI
import CoreFoundationLib

final class FundSectionEmptyView: XibView {

    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setAccessibilityIdentifiers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setAccessibilityIdentifiers()
    }
}

private extension FundSectionEmptyView {
    func setupView() {
        backgroundImageView.setLeavesLoader()
        titleLabel.font = .santander(family: .headline, type: .bold, size: 18)
        subTitleLabel.font = .santander(family: .micro, type: .regular, size: 16)
        titleLabel.text = localized("generic_label_empty")
        subTitleLabel.text = localized("generic_label_emptyNotAvailableMoves")
        titleLabel.textColor = .oneLisboaGray
        subTitleLabel.textColor = .oneLisboaGray
    }

    func setAccessibilityIdentifiers() {
        backgroundImageView.accessibilityIdentifier = AccessibilityIdFundEmptyList.imgEmptyView.rawValue
        titleLabel.accessibilityIdentifier = AccessibilityIdFundEmptyList.genericLabelEmpty.rawValue
        subTitleLabel.accessibilityIdentifier = AccessibilityIdFundEmptyList.genericLabelEmptyNotAvailableMoves.rawValue
    }
}
