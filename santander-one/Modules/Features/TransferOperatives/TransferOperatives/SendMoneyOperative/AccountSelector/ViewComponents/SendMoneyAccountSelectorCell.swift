//
//  SendMoneyAccountSelectorCell.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 8/9/21.
//

import UIKit
import UIOneComponents
import CoreFoundationLib

class SendMoneyAccountSelectorCell: UITableViewCell {
    
    @IBOutlet private weak var cardView: OneAccountSelectionCardView!
    
    static var bundle: Bundle? {
        return .module
    }
    
    func configureCardView(with viewModel: OneAccountSelectionCardItem, accountList: [OneAccountSelectionCardItem]) {
        self.cardView.setupAccountItem(viewModel)
    }

    func setCardAccessibilitySuffix(_ suffix: String) {
        self.cardView.setAccessibilitySuffix(suffix)
    }
}
