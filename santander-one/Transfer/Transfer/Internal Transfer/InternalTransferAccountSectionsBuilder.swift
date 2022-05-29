import UI
import CoreFoundationLib

enum InternalTransferAccountSection {
    case visibleAccounts([InternalTransferAccountSelectionViewModel])
    case showMore(item: LabelArrowViewItem)
    case notVisibleAccounts([InternalTransferAccountSelectionViewModel], isExpanded: Bool)

    func cell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let accessibilityIdentifier = "_\(indexPath.row)"
        switch self {
        case .visibleAccounts(let accounts):
            let cell = tableView.dequeueReusableCell(AccountSelectionTableViewCell.self, indexPath: indexPath)
            cell.setViewModel(accounts[indexPath.row], accessibilityIdendtifier: accessibilityIdentifier)
            return cell
        case .showMore(item: let item):
            let cell = tableView.dequeueReusableCell(LabelArrowTableViewCell.self, indexPath: indexPath)
            cell.setAccountCellInfo(item)
            return cell
        case .notVisibleAccounts(let accounts, isExpanded: _):
            let cell = tableView.dequeueReusableCell(AccountSelectionTableViewCell.self, indexPath: indexPath)
            cell.setViewModel(accounts[indexPath.row], accessibilityIdendtifier: accessibilityIdentifier)
            return cell
        }
    }

    func numberOfRows() -> Int {
        switch self {
        case .visibleAccounts(let accounts):
            return accounts.count
        case .showMore:
            return 1
        case .notVisibleAccounts(let accounts, let isExpanded):
            return isExpanded ? accounts.count : 0
        }
    }
}

struct InternalTransferAccountSectionsBuilder {
    let accountVisibles: [InternalTransferAccountSelectionViewModel]
    let accountNotVisibles: [InternalTransferAccountSelectionViewModel]

    func generateSections() -> [InternalTransferAccountSection] {
        if accountNotVisibles.count == 0 {
            return [
                .visibleAccounts(accountVisibles)
            ]
        } else {
            return [
                .visibleAccounts(accountVisibles),
                .showMore(item: LabelArrowViewItem(numberPlaceHolder: accountNotVisibles.count)),
                .notVisibleAccounts(accountNotVisibles, isExpanded: false)
            ]
        }
    }
}

protocol NotVisibleAccountSectionProtocol: AnyObject {
    var sections: [InternalTransferAccountSection] { get set }
}
extension NotVisibleAccountSectionProtocol {
    func getNotVisibleAccountsSection() -> Int? {
        if let index = sections.firstIndex( where: { if case .notVisibleAccounts = $0 { return true } else { return false } }) {
            return Int(index)
        } else {
            return nil
        }
    }
}
