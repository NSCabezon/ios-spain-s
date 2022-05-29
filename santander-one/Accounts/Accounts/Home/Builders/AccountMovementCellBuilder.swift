//
//  AccountMovementCellBuilder.swift
//  Account
//
//  Created by Juan Carlos López Robles on 2/6/20.
//

import Foundation
import CoreFoundationLib

protocol AccountTransactionTableViewCell: UITableViewCell {
    func configure(withViewModel: TransactionViewModel)
    func mustHideDiscontinueLine(_ isHidden: Bool)
}

protocol CrossSellingTransactionTableViewCell: UITableViewCell {
    func configure(viewModel: CrossSellingViewModel, indexPath: IndexPath)
}

final class AccountMovementCellBuilder {
    static let transactionCellIdentifier = "AccountMovementsTableViewCell"
    static let futureBillCellIdentifier = "AccountFutureBillTableViewCell"
    static let pendingCellIdentifier = "AccountPendingTableViewCell"
    
    func cell(for tableView: UITableView, at indexPath: IndexPath,
              and viewModel: TransactionViewModel) -> AccountTransactionTableViewCell? {
        
        if viewModel is AccountFutureBillViewModel {
            return tableView.dequeueReusableCell(
                withIdentifier: AccountMovementCellBuilder.futureBillCellIdentifier,
                for: indexPath) as? AccountTransactionTableViewCell
            
        } else if viewModel is AccountTransactionViewModel {
            return tableView.dequeueReusableCell(
                withIdentifier: AccountMovementCellBuilder.transactionCellIdentifier,
                for: indexPath) as? AccountTransactionTableViewCell
        } else if viewModel is AccountPendingTransactionViewModel {
            return tableView.dequeueReusableCell(
                withIdentifier: AccountMovementCellBuilder.pendingCellIdentifier,
                for: indexPath) as? AccountPendingTableViewCell
        } else {
            return nil
        }
    }
}
