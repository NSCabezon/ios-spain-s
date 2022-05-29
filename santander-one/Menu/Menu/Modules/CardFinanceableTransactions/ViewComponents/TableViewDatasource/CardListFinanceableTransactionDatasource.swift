//
//  CardListFinanceableTransactionDatasoure.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/26/20.
//

import Foundation
import CoreFoundationLib

enum TransationState {
    case filled([CardListFinanceableTransactionViewModel])
    case empty
}

final class CardListFinanceableTransactionDatasource: NSObject {
    private var state: TransationState  = .empty
    private var viewModels = [CardListFinanceableTransactionViewModel]()
    private var groupViewModels = [(key: Date, value: [CardListFinanceableTransactionViewModel])]()
    weak var delegate: CardListFinanceableTransactionCellDelegate?
    private let headerSection = 0
    
    func didStateChange(_ state: TransationState) {
        self.state = state
        self.viewModels = []
        guard case let .filled(viewModels) = state else { return }
        self.viewModels = viewModels
        self.setGroupedViewModel(viewModels)
    }
    
    func updateViewModel(_ viewModel: CardListFinanceableTransactionViewModel) {
        self.viewModels.forEach({
            $0.isEasyPayEnable = true
            guard $0 == viewModel else { return }
            $0.updateWith(viewModel)
        })
    }
    
    func updateViewModels() {
        self.viewModels.forEach({ $0.isEasyPayEnable = false })
    }
    
    func filterBy(_ date: Date) {
        let filteredViewModels = self.viewModels.filter({ $0.operativeDate.month == date.month })
        self.state = (filteredViewModels.isEmpty) ? .empty : .filled(filteredViewModels)
        self.setGroupedViewModel(filteredViewModels)
    }
}

private extension CardListFinanceableTransactionDatasource {
    func setGroupedViewModel(_ viewModels: [CardListFinanceableTransactionViewModel]) {
        self.groupViewModels = viewModels
            .group(by: { $0.operativeDate.startOfDay() })
            .sorted(by: { $0.key > $1.key })
    }
}

extension CardListFinanceableTransactionDatasource: UITableViewDataSource {
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
        let localizedDate = self.setLocalisedDate(section)
        (sectionHeader as? FinanceableSectionView)?.setLocalizedDate(localizedDate)
        tableView.removeUnnecessaryHeaderTopPadding()
        return sectionHeader
    }
    
    func setLocalisedDate(_ section: Int) -> LocalizedStylableText? {
        guard let viewModel = self.groupViewModels[section].value.first else {
            return nil
        }
        let decorator = DateDecorator(viewModel.operativeDate)
        return decorator.setDateFormatter(false)
    }
    
    func cellFor(_ tableView: UITableView, withIdentifier identifier: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        return cell ?? UITableViewCell()
    }
    
    func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardListFinanceableTransactionTableViewCell.identifier) as? CardListFinanceableTransactionTableViewCell else {
            return CardListFinanceableTransactionTableViewCell()
        }
        let viewModel = self.groupViewModels[indexPath.section].value[indexPath.row]
        let isLastCell = self.isLastCell(at: indexPath)
        cell.setDelegate(delegate)
        cell.setViewModel(viewModel)
        cell.updateSeparators(isLastCell)
        cell.accessibilityIdentifier = "areaMovement(\(indexPath.row))"
        return cell
    }
    
    func isLastCell(at indexPath: IndexPath) -> Bool {
        let lastIndexInSection = self.groupViewModels[indexPath.section].value.endIndex - 1
        return lastIndexInSection == indexPath.row
    }
}

extension CardListFinanceableTransactionDatasource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .filled = state else { return }
        let viewModel = self.groupViewModels[indexPath.section].value[indexPath.row]
        self.delegate?.didSelectTransaction(viewModel)
    }
}

private extension Sequence where Iterator.Element == CardListFinanceableTransactionViewModel {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        return Dictionary(grouping: self, by: key)
    }
}
