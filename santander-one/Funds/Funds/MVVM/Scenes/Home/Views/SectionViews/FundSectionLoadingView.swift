//
//  FundSectionLoadingView.swift
//  Funds
//
//  Created by Simón Aparicio on 28/3/22.
//

import UIKit
import UI
import CoreFoundationLib

enum FundSectionLoadingViewType {
    case details, transactions
}

final class FundSectionLoadingView: XibView {

    @IBOutlet private weak var loadingImageView: UIImageView!
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

    func updateTitle(with type: FundSectionLoadingViewType) {
        titleLabel.text = localized(type == .transactions ? "loading_label_transactionsLoading" : "generic_popup_loadingContent")
    }
}

private extension FundSectionLoadingView {
    func setupView() {
        loadingImageView.setNewJumpingLoader()
        titleLabel.font = .santander(family: .headline, type: .bold, size: 18)
        subTitleLabel.font = .santander(family: .micro, type: .regular, size: 16)
        titleLabel.text = localized("generic_popup_loadingContent")
        subTitleLabel.text = localized("loading_label_moment")
        titleLabel.textColor = .oneLisboaGray
        subTitleLabel.textColor = .oneLisboaGray
    }

    func setAccessibilityIdentifiers() {
        loadingImageView.accessibilityIdentifier = AccessibilityIdFundLoading.icnLoader.rawValue
        titleLabel.accessibilityIdentifier = AccessibilityIdFundLoading.genericPopupLoadingContent.rawValue
        subTitleLabel.accessibilityIdentifier = AccessibilityIdFundLoading.loadingLabelMoment.rawValue
    }
}
