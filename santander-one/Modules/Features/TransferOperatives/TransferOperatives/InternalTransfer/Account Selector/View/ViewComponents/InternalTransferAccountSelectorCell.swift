//
//  InternalTransferAccountSelectorCell.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 8/9/21.
//

import UIKit
import UIOneComponents
import CoreFoundationLib

final class InternalTransferAccountSelectorCell: UITableViewCell {
    
    @IBOutlet private weak var accountView: OneAccountSelectionCardView!
    
    static var bundle: Bundle? {
        return .module
    }
    
    func configureAccountView(with item: OneAccountSelectionCardItem) {
        accountView.setupAccountItem(item)
    }

    func setCardAccessibilitySuffix(_ suffix: String) {
        accountView.setAccessibilitySuffix(suffix)
    }
}
