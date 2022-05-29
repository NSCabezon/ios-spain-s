//
//  FundTransactionsPaginationLoadingViewCell.swift
//  Funds
//
//  Created by Simón Aparicio on 27/4/22.
//

import UI
import CoreFoundationLib

final class FundTransactionsPaginationLoadingViewCell: UITableViewCell {
    @IBOutlet private weak var loadingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        appearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingImageView.setPointsLoader()
    }
}

private extension FundTransactionsPaginationLoadingViewCell {
    func appearance() {
        loadingImageView.isAccessibilityElement = true
        loadingImageView.accessibilityIdentifier = AccessibilityIdFundLoading.icnLoader.rawValue
        loadingImageView.setNewJumpingLoader()
    }
}
