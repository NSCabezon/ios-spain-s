//
//  InternalTransferAccountSelectorSectionBuilder.swift
//  TransferOperatives
//
//  Created by Mario Rosales Maillo
//
import CoreFoundationLib
import UIOneComponents

enum InternalTransferAccountSelectorSection {
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
            let cell = tableView.dequeueReusableCell(InternalTransferAccountSelectorCell.self, indexPath: indexPath)
            cell.configureAccountView(with: accounts[indexPath.item])
            return cell
        case .showHidden(let item, let isExpanded):
            let cell = tableView.dequeueReusableCell(InternalTransferAccountSelectorShowMoreCell.self, indexPath: indexPath)
            cell.setCellInfo(item, isExpanded: isExpanded)
            return cell
        }
    }
    
    func clearSelection() {
        switch self {
        case .visible(let accounts), .hidden(let accounts, isExpanded: _):
            accounts.first { item in item.cardStatus == .selected }?.cardStatus = .inactive
        default:
            break
        }
    }
}

struct InternalTransferAccountSelectorSectionBuilder {
    let visibles: [OneAccountSelectionCardItem]
    let hidden: [OneAccountSelectionCardItem]
    
    func buildSections() -> [InternalTransferAccountSelectorSection] {
        let shouldExpand = self.hidden.first(where: { $0.cardStatus == .selected }) != nil
        if self.visibles.count == 0 {
            return [.hidden(self.hidden, isExpanded: true)]
        } else if self.hidden.count == 0 {
            return [.visible(self.visibles)]
        } else {
            return [.visible(self.visibles),
                    .showHidden(item: LabelArrowViewItem(numberPlaceHolder: hidden.count), isExpanded: shouldExpand),
                    .hidden(self.hidden, isExpanded: shouldExpand)]
        }
    }
}
