//
//  AccountListFinanceableTransactionDatasoure.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import Foundation

protocol AccountListFinanceableTransactionDatasoureDelegate: AnyObject {
    func didSelectTransaction(_ viewModel: AccountListFinanceableTransactionViewModel)
}

final class AccountListFinanceableTransactionDatasoure: NSObject {
    private var state: State  = .empty
    private var viewModels = [AccountListFinanceableTransactionViewModel]()
    private var groupViewModels = [(key: Date, value: [AccountListFinanceableTransactionViewModel])]()
    weak var delegate: AccountListFinanceableTransactionDatasoureDelegate?
    private let headerSection = 0
    enum State {
        case filled([AccountListFinanceableTransactionViewModel])
        case empty
    }
    
    func didStateChange(_ state: State) {
        self.state = state
        self.viewModels = []
        guard case let .filled(viewModels) = state else { return }
        self.viewModels = viewModels
        self.setGroupedViewModel(viewModels)
    }

    func filterBy(_ date: Date) {
        let filteredViewModels = self.viewModels.filter({ $0.operativeDate.month == date.month })
        self.state = (filteredViewModels.isEmpty) ? .empty : .filled(filteredViewModels)
        self.setGroupedViewModel(filteredViewModels)
    }
}

private extension AccountListFinanceableTransactionDatasoure {
    func setGroupedViewModel(_ viewModels: [AccountListFinanceableTransactionViewModel]) {
        self.groupViewModels = viewModels
            .group(by: { $0.operativeDate.startOfDay() })
            .sorted(by: { $0.key > $1.key })
    }
}

extension AccountListFinanceableTransactionDatasoure: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard case .filled = state else { return 1 }
        return self.groupViewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case .filled = state else { return 1 }
        return self.groupViewModels[section].value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.state {
        case .filled:
            return self.cellFor(tableView: tableView, at: indexPath)
        case .empty:
            return self.cellFor(tableView, withIdentifier: FinanceableEmptyTableViewCell.identifier)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard case .filled = state else { return UIView() }
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: FinanceableSectionView.identifier)
        let localizedDate = self.groupViewModels[section].value.first?.localizedDate
        (sectionHeader as? FinanceableSectionView)?.setLocalizedDate(localizedDate)
        tableView.removeUnnecessaryHeaderTopPadding()
        return sectionHeader
    }

    func cellFor(_ tableView: UITableView, withIdentifier identifier: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        return cell ?? UITableViewCell()
    }

    func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let viewModel = self.groupViewModels[indexPath.section].value[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AccountListFinanceableTransactionTableViewCell.identifier)
            as? AccountListFinanceableTransactionTableViewCell else { return UITableViewCell() }
        cell.setViewModel(viewModel)
        cell.pointLineDivider.isHidden = isLastCell(at: indexPath)
        cell.dividerView.isHidden = !isLastCell(at: indexPath)
        cell.accessibilityIdentifier = "areaMovement(\(indexPath.row))"
        return cell
    }

    func isLastCell(at indexPath: IndexPath) -> Bool {
        let lastIndexInSection = self.groupViewModels[indexPath.section].value.endIndex - 1
        return lastIndexInSection == indexPath.row
    }
}

extension AccountListFinanceableTransactionDatasoure: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .filled = state else { return }
        let viewModel = self.groupViewModels[indexPath.section].value[indexPath.row]
        self.delegate?.didSelectTransaction(viewModel)
    }
}

private extension Sequence where Iterator.Element == AccountListFinanceableTransactionViewModel {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        return Dictionary(grouping: self, by: key)
    }
}
