//
//  GroupBillByProductStrategy.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/2/20.
//

import CoreFoundationLib

final class GroupBillByProductStrategy: BillStrategy {
    var state: ViewState<[LastBillViewModel]> = .loading
    private var productGroupViewModels: [ProductGroupViewModel] = []
    private weak var delegate: BillStrategyDelegate?
    
    init(delegate: BillStrategyDelegate) {
        self.delegate = delegate
    }
    
    func didStateChanged(_ state: ViewState<[LastBillViewModel]>) {
        self.state = state
        guard case let .filled(viewModels) = self.state else { return }
        let groupedViewModels = viewModels
            .group(by: { $0.account })
            .sorted(by: { ($0.key.alias ?? "") < ($1.key.alias ?? "") })
        self.productGroupViewModels = groupedViewModels.map { ProductGroupViewModel(group: $0) }
    }
    
    var numberOfSections: Int {
        guard case .filled = self.state else { return 1 }
        return self.productGroupViewModels.count
    }
    
    func viewForHeader(in tableView: UITableView, for section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfRowInSection(_ section: Int) -> Int {
        guard case .filled = self.state else { return 1 }
        return self.productGroupViewModels[section].numberOfElements
    }
    
    func loadingCell(for tableView: UITableView) -> UITableViewCell {
        return self.cellFor(tableView, withIdentifier: LastBillLoadingTableViewCell.identifier)
    }
    
    func emptyCell(for tableView: UITableView) -> UITableViewCell {
        return self.cellFor(tableView, withIdentifier: LastBillEmptyTableViewCell.identifier)
    }
    
    func cellFor(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let groupViewModel = self.productGroupViewModels[indexPath.section]
        switch groupViewModel.elementType(at: indexPath.row) {
        case .header:
            return self.headerCell(tableView, at: indexPath)
        case let .element(viewModel):
            return self.elementCell(tableView, at: indexPath, viewModel: viewModel)
        case .footer:
            return cellFor(tableView, withIdentifier: ProductFooterTableViewCell.identifier)
        }
    }
    
    func cellFor(_ tableView: UITableView, withIdentifier identifier: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        return cell ?? UITableViewCell()
    }
    
    func getViewModel(for indexPath: IndexPath) -> LastBillViewModel? {
        return nil
    }
    
    func didSelectRow(in tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let productGroup = self.productGroupViewModels[indexPath.section]
        guard case let .element(viewModel) = productGroup.elementType(at: indexPath.row) else { return }
        self.delegate?.didSelectTransmitterGroup(viewModel)
    }
    
    func didHighlightRow(in tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let productGroup = self.productGroupViewModels[indexPath.section]
        guard case .element = productGroup.elementType(at: indexPath.row) else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? ProductElementTableViewCell)?.viewContainer.backgroundColor = .skyGray
    }
    
    func didUnhighlightRow(in tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let productGroup = self.productGroupViewModels[indexPath.section]
        guard case .element = productGroup.elementType(at: indexPath.row) else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? ProductElementTableViewCell)?.viewContainer.backgroundColor = .white
    }
}

private extension GroupBillByProductStrategy {
    func headerCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let groupViewModel = self.productGroupViewModels[indexPath.section]
        let cell = self.cellFor(tableView, withIdentifier: ProductHeaderTableViewCell.identifier) as? ProductHeaderTableViewCell
        cell?.delegate = self
        cell?.accessibilityIdentifier = "btnGroup\(indexPath.row)"
        cell?.setViewModel(groupViewModel)
        return cell ?? UITableViewCell()
    }
    
    func elementCell(_ tableView: UITableView, at indexPath: IndexPath, viewModel: TransmitterGroupViewModel) -> UITableViewCell {
        let cell = self.cellFor(tableView, withIdentifier: ProductElementTableViewCell.identifier)
        (cell as? ProductElementTableViewCell)?.setViewModel(viewModel)
        cell.accessibilityIdentifier = "btn\(indexPath.row)"
        return cell
    }
}

extension GroupBillByProductStrategy: ProductHeaderTableViewCellDelegate {
    func didSelectProductHeaderCell(_ cell: ProductHeaderTableViewCell) {
        self.delegate?.reloadCellSection(cell)
    }
}
