//
//  SendMoneyAccountSelectorSectionBuilder.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 8/9/21.
//
import CoreFoundationLib
import UIOneComponents

enum SendMoneyAccountSelectorSection {
    case visible([OneAccountSelectionCardItem])
    case showHidden(item: LabelArrowViewItem, isExpanded: Bool)
    case hidden([OneAccountSelectionCardItem], isExpanded: Bool)
    
    func numberOfRows() -> Int {
        switch self {
        case .visible(let accounts):
            return accounts.count
        case .showHidden:
            return 1
        case .hidden(let accounts, let isExpanded):
            return isExpanded ? accounts.count : 0
        }
    }
    
    func cell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        switch self {
        case .visible(let accounts), .hidden(let accounts, _):
            let cell = tableView.dequeueReusableCell(SendMoneyAccountSelectorCell.self, indexPath: indexPath)
            cell.configureCardView(with: accounts[indexPath.item], accountList: accounts)
            return cell
        case .showHidden(let viewModel, let isExpanded):
            let cell = tableView.dequeueReusableCell(AccountSelectorShowMoreCell.self, indexPath: indexPath)
            cell.setCellInfo(viewModel, isExpanded: isExpanded)
            return cell
        }
    }
}

struct SendMoneyAccountSelectorSectionBuilder {
    let accountVisibles: [OneAccountSelectionCardItem]
    let accountNotVisibles: [OneAccountSelectionCardItem]
    
    func buildSections() -> [SendMoneyAccountSelectorSection] {
        let shouldExpand = self.accountNotVisibles.first(where: { $0.cardStatus == .selected }) != nil
        if self.accountVisibles.count == 0 {
            return [.hidden(self.accountNotVisibles, isExpanded: true)]
        } else if self.accountNotVisibles.count == 0 {
            return [.visible(self.accountVisibles)]
        } else {
            return [.visible(self.accountVisibles),
                    .showHidden(item: LabelArrowViewItem(numberPlaceHolder: accountNotVisibles.count), isExpanded: shouldExpand),
                    .hidden(self.accountNotVisibles, isExpanded: shouldExpand)]
        }
    }
}
