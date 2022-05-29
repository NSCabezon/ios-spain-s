//
//  GroupBillByNameStrategy.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/12/20.
//

import CoreFoundationLib

final class GroupBillByTransmitterStrategy: BillStrategy {
    var state: ViewState<[LastBillViewModel]> = .loading
    private var transmitterGroupViewModels: [TransmitterGroupViewModel] = []
    private weak var delegate: BillStrategyDelegate?
    
    init(delegate: BillStrategyDelegate) {
        self.delegate = delegate
    }
    
    func didStateChanged(_ state: ViewState<[LastBillViewModel]>) {
        self.state = state
        guard case let .filled(viewModels) = self.state else { return }
        self.setTransmitterGroupViewModels(for: viewModels)
    }
    
    var numberOfSections: Int {
        guard case .filled = self.state else { return 1 }
        return self.transmitterGroupViewModels.count
    }
    
    func viewForHeader(in tableView: UITableView, for section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfRowInSection(_ section: Int) -> Int {
        guard case .filled = self.state else { return 1 }
        return self.transmitterGroupViewModels[section].numberOfElements
    }
    
    func loadingCell(for tableView: UITableView) -> UITableViewCell {
        return self.cellFor(tableView, withIdentifier: LastBillLoadingTableViewCell.identifier)
    }
    
    func emptyCell(for tableView: UITableView) -> UITableViewCell {
        return self.cellFor(tableView, withIdentifier: LastBillEmptyTableViewCell.identifier)
    }
    
    func cellFor(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let groupViewModel = self.transmitterGroupViewModels[indexPath.section]
        switch groupViewModel.elementType(at: indexPath.row) {
        case .header:
            return self.headerCell(tableView, at: indexPath)
        case let .element(viewModel):
            return self.elementCell(tableView, at: indexPath, viewModel: viewModel)
        case .footer:
            return self.cellFor(tableView, withIdentifier: TransmitterFooterTableViewCell.identifier)
        }
    }
    
    func cellFor(_ tableView: UITableView, withIdentifier identifier: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        return cell ?? UITableViewCell()
    }
    
    func getViewModel(for indexPath: IndexPath) -> LastBillViewModel? {
        guard case .filled = self.state else { return nil }
        let groupViewModel = self.transmitterGroupViewModels[indexPath.section]
        guard case let .element(viewModel) = groupViewModel.elementType(at: indexPath.row) else { return  nil }
        return viewModel
    }
    
    func didSelectRow(in tableView: UITableView, at indexPath: IndexPath) {
        return
    }
    
    func didHighlightRow(in tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let groupViewModel = self.transmitterGroupViewModels[indexPath.section]
        guard case .element = groupViewModel.elementType(at: indexPath.row) else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? TransmitterElementTableViewCell)?.viewContainer.backgroundColor = .skyGray
    }
    
    func didUnhighlightRow(in tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let groupViewModel = self.transmitterGroupViewModels[indexPath.section]
        guard case .element = groupViewModel.elementType(at: indexPath.row) else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? TransmitterElementTableViewCell)?.viewContainer.backgroundColor = .white
    }
}

private extension GroupBillByTransmitterStrategy {
    func setTransmitterGroupViewModels(for viewModels: [LastBillViewModel]) {
        let gropedViewModels = viewModels
            .group(by: { $0.name })
            .sorted(by: { $0.key < $1.key })
        self.transmitterGroupViewModels = gropedViewModels.map { TransmitterGroupViewModel(group: $0) }
    }
    
    func headerCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = cellFor(tableView, withIdentifier: TransmitterHeaderTableViewCell.identifier) as?
        TransmitterHeaderTableViewCell
        let gropViewModel = self.transmitterGroupViewModels[indexPath.section]
        cell?.delegate = self
        cell?.setViewModel(gropViewModel)
        cell?.accessibilityIdentifier = "btnGroup\(indexPath.row)"
        return cell ?? UITableViewCell()
    }
    
    func elementCell(_ tableView: UITableView, at indexPath: IndexPath, viewModel: LastBillViewModel) -> UITableViewCell {
        let cell = self.cellFor(tableView, withIdentifier: TransmitterElementTableViewCell.identifier)
        (cell as? TransmitterElementTableViewCell)?.setViewModel(viewModel)
        cell.accessibilityIdentifier = "btn\(indexPath.row)"
        return cell
    }
}

extension GroupBillByTransmitterStrategy: TransmitterHeaderTableViewCellDelegate {
    func didSelectTransmitterHeaderCell(_ cell: TransmitterHeaderTableViewCell) {
        self.delegate?.reloadCellSection(cell)
    }
}
