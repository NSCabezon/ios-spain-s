//
//  FundTransactionsLoadingViewCell.swift
//  Funds
//
//  Created by Simón Aparicio on 29/4/22.
//

import UIKit

final class FundTransactionsLoadingViewCell: UITableViewCell {

    @IBOutlet private weak var loadingView: FundSectionLoadingView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.setupView()
    }
}

private extension FundTransactionsLoadingViewCell {
    func setupView() {
        self.loadingView.updateTitle(with: .transactions)
    }
}
