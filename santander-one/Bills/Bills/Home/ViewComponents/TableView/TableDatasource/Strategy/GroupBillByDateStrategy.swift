//
//  SortByDateStrategy.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/4/20.
//

import CoreFoundationLib

final class GroupBillByDateStrategy: BillStrategy {
    var state: ViewState<[LastBillViewModel]> = .loading
    private var groupedViewModels: [(key: Date, value: [LastBillViewModel])] = []
    private weak var delegate: BillStrategyDelegate?
    
    init(delegate: BillStrategyDelegate) {
        self.delegate = delegate
    }
    
    func didStateChanged(_ state: ViewState<[LastBillViewModel]>) {
        self.state = state
        guard case let .filled(viewModels) = state else { return }
        self.groupedViewModels = self.groupedViewModelByDate(viewModels)
    }
    
    var numberOfSections: Int {
        guard case .filled = state else { return 1 }
        return groupedViewModels.count
    }
    
    func viewForHeader(in tableView: UITableView, for section: Int) -> UIView? {
        guard case .filled = self.state else { return UIView() }
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: DateTableSectionHeaderView.identifier)
        let viewModel = self.groupedViewModels[section].value.first
        (sectionHeader as? DateTableSectionHeaderView)?.setDate(dateString: viewModel?.dateLocalized)
        return sectionHeader
    }
    
    func numberOfRowInSection(_ section: Int) -> Int {
        guard case .filled = self.state else { return 1 }
        return self.groupedViewModels[section].value.count
    }
    
    func loadingCell(for tableView: UITableView) -> UITableViewCell {
        return self.cellFor(tableView, withIdentifier: LastBillLoadingTableViewCell.identifier)
    }
    
    func emptyCell(for tableView: UITableView) -> UITableViewCell {
        return self.cellFor(tableView, withIdentifier: LastBillEmptyTableViewCell.identifier)
    }
    
    func cellFor(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        defer { self.paginateIfNeed(tableView, at: indexPath) }
        let cell = self.cellFor(tableView, withIdentifier: LastBillTableViewCell.identifier) as? LastBillTableViewCell
        let viewModel = groupedViewModels[indexPath.section].value[indexPath.row]
        cell?.setViewModel(viewModel)
        cell?.setDelegate(self)
        cell?.accessibilityIdentifier = "btnReceipt1\(indexPath.row)"
        return cell ?? UITableViewCell()
    }
    
    func cellFor(_ tableView: UITableView, withIdentifier identifier: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        return cell ?? UITableViewCell()
    }
    
    func getViewModel(for indexPath: IndexPath) -> LastBillViewModel? {
        guard case .filled = self.state else { return nil }
        return groupedViewModels[indexPath.section].value[indexPath.row]
    }
    
    func didSelectRow(in tableView: UITableView, at indexPath: IndexPath) {
        return
    }
    
    func didHighlightRow(in tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? LastBillTableViewCell)?.lastBillView.view?.backgroundColor = .skyGray
    }
    
    func didUnhighlightRow(in tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? LastBillTableViewCell)?.lastBillView.view?.backgroundColor = .white
    }
}

extension GroupBillByDateStrategy: LastBillDelegate {
    func didSwipeBegin(on cell: LastBillTableViewCell) {
        self.delegate?.didSwipeBegin(on: cell)
    }
    
    func didSelectReturnReceipt(_ viewModel: LastBillViewModel) {
        self.delegate?.didSelectReturnReceipt(viewModel)
    }
    
    func didSelectSeePDF(_ viewModel: LastBillViewModel) {
        self.delegate?.didSelectSeePDF(viewModel)
    }
}

private extension GroupBillByDateStrategy {
    func groupedViewModelByDate(_ viewModels: [LastBillViewModel]) -> [(key: Date, value: [LastBillViewModel])] {
        return viewModels
            .group(by: { $0.expirationDate.startOfDay() })
            .sorted(by: { $0.key > $1.key })
    }
    
    func paginateIfNeed(_ tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        guard indexPath.section == (self.groupedViewModels.count - 1) else {
            return
        }
        self.delegate?.tableViewDidReachTheEndOfTheList()
    }
}
