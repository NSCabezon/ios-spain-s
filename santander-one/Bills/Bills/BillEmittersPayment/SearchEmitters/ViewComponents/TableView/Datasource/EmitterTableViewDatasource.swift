//
//  EmitterTableViewDatasource.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 5/19/20.
//

import Foundation
import UIKit
import CoreFoundationLib

protocol EmitterTableViewDatasourceDelegate: AnyObject {
    func didSelectEmitterViewModel(_ viewModel: EmitterViewModel)
    func didSelectIncomeViewModel(_ viewModel: IncomeViewModel, emitterViewModel: EmitterViewModel)
    func reloadCellSection(_ cell: UITableViewCell)
    func reloadCellSection(_ section: Int)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func tableViewDidReachTheEndOfTheList()
}

final class EmitterTableViewDatasource: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var state: ViewState<[EmitterViewModel]>
    private var emitterViewModels: [EmitterViewModel] = []
    private weak var datasourceDelegate: EmitterTableViewDatasourceDelegate?
    private var searchTerm: String?
    
    init(state: ViewState<[EmitterViewModel]>) {
        self.state = state
        guard case let .filled(viewModels) = state else { return }
        self.emitterViewModels = viewModels
    }
    
    func didStateChanged(_ state: ViewState<[EmitterViewModel]>) {
        self.state = state
        guard case let .filled(viewModels) = state else {
            self.emitterViewModels = []
            return
        }
        self.emitterViewModels = viewModels
    }
    
    func setSearchTerm(_ term: String?) {
        self.searchTerm = term 
    }
    
    func setDelegate(delegate: EmitterTableViewDatasourceDelegate?) {
        self.datasourceDelegate = delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard case .filled = state else {  return 1 }
        return emitterViewModels.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case .filled = state else { return 1 }
        return emitterViewModels[section].numberOfElements
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loading:
            return self.loadingCell(for: tableView)
        case .empty:
            return self.emptyCell(for: tableView, searchTerm: searchTerm)
        case .filled:
            return self.cellFor(tableView, at: indexPath)
        }
    }
    
    func loadingCell(for tableView: UITableView) -> UITableViewCell {
        return self.cellFor(tableView, withIdentifier: EmitterLoadingTableViewCell.identifier)
    }
    
    func emptyCell(for tableView: UITableView, searchTerm: String?) -> UITableViewCell {
        let cell = self.cellFor(tableView, withIdentifier: EmitterEmptyTableViewCell.identifier)
        (cell as? EmitterEmptyTableViewCell)?.setSearchTerm(term: searchTerm)
        return cell
    }
    
    func cellFor(_ tableView: UITableView, withIdentifier identifier: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        return cell ?? UITableViewCell()
    }
    
    func cellFor(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        defer { self.paginateIfNeed(tableView, at: indexPath) }
        let emitterViewModel = self.emitterViewModels[indexPath.section]
        switch emitterViewModel.elementType(at: indexPath.row) {
        case .header:
            return self.headerCell(tableView, at: indexPath)
        case let .element(viewModel):
            return self.elementCell(tableView, at: indexPath, viewModel: viewModel)
        case .footer:
            return cellFor(tableView, withIdentifier: EmitterFooterTableViewCell.identifier)
        case .loading:
            return cellFor(tableView, withIdentifier: ElementLoadingTableViewCell.identifier)
        }
    }
    
    func headerCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let emitterViewModel = self.emitterViewModels[indexPath.section]
        let cell = self.cellFor(tableView, withIdentifier: EmitterHeaderTableViewCell.identifier) as? EmitterHeaderTableViewCell
        cell?.accessibilityIdentifier = "btnGroup\(indexPath.row)"
        cell?.setViewModel(emitterViewModel)
        cell?.delegate = self
        return cell ?? UITableViewCell()
    }
    
    func elementCell(_ tableView: UITableView, at indexPath: IndexPath, viewModel: IncomeViewModel) -> UITableViewCell {
        let cell = self.cellFor(tableView, withIdentifier: EmitterElementTableViewCell.identifier)
        (cell as? EmitterElementTableViewCell)?.setViewModel(viewModel)
        cell.accessibilityIdentifier = "btn\(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard case .loading = state else { return true }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .filled = state else { return }
        let emitterViewModel = self.emitterViewModels[indexPath.section]
        guard case let .element(viewModel) = emitterViewModel.elementType(at: indexPath.row) else { return }
        self.datasourceDelegate?.didSelectIncomeViewModel(viewModel, emitterViewModel: emitterViewModel)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let emitterViewModel = self.emitterViewModels[indexPath.section]
        guard case .element = emitterViewModel.elementType(at: indexPath.row) else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? EmitterElementTableViewCell)?.viewContainer.backgroundColor = .skyGray
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        let emitterViewModel = self.emitterViewModels[indexPath.section]
        guard case .element = emitterViewModel.elementType(at: indexPath.row) else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? EmitterElementTableViewCell)?.viewContainer.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func updateEmitterViewModel(_ viewModel: EmitterViewModel) {
        guard let section = self.emitterViewModels.firstIndex(where: { $0 == viewModel }) else { return }
        self.emitterViewModels[section].incomes = viewModel.incomes
        if self.emitterViewModels[section].isExpanded {
            self.emitterViewModels[section].isExpanded = !viewModel.incomes.isEmpty
        }
        self.datasourceDelegate?.reloadCellSection(section)
    }
    
    func paginateIfNeed(_ tableView: UITableView, at indexPath: IndexPath) {
        guard case .filled = self.state else { return }
        guard indexPath.section == (self.emitterViewModels.count - 1) else {
            return
        }
        self.datasourceDelegate?.tableViewDidReachTheEndOfTheList()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.datasourceDelegate?.scrollViewDidScroll(scrollView)
    }
}

extension EmitterTableViewDatasource: EmitterHeaderTableViewCellDelegate {
    func didSelectEmitterHeaderCell(_ cell: EmitterHeaderTableViewCell, viewModel: EmitterViewModel) {
        self.datasourceDelegate?.reloadCellSection(cell)
        self.datasourceDelegate?.didSelectEmitterViewModel(viewModel)
    }
}
