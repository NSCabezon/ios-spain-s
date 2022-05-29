//
//  SendMoneyDestinationAccountLastTransferCollectionViewCell.swift
//  TransferOperatives
//
//  Created by Juan Diego Vázquez Moreno on 29/9/21.
//

import UIOneComponents
import CoreFoundationLib

final class SendMoneyDestinationAccountLastTransferCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var pastTransferCard: OnePastTransferCardView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }

    private func setupView() {
        self.clipsToBounds = false
        self.contentView.isUserInteractionEnabled = false
    }

    public func setViewModel(_ viewModel: OnePastTransferViewModel) {
        self.pastTransferCard.setupPastTransferCard(viewModel)
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.pastTransferCard.setAccessibilitySuffix(suffix)
    }
}
