//
//  StateTableDatasource.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 10/21/21.
//

import UI
import CoreDomain
import CoreFoundationLib
import Foundation
import OpenCombine

final class StateTableDatasource: NSObject {
    var state: ViewState<DateTransactionGroup> = .loading
    let paginationSubject = PassthroughSubject<Void, Never>()
    let didSelectRowAtSubject = PassthroughSubject<SavingTransaction, Never>()
    let didScrollSubject = PassthroughSubject<UIScrollView, Never>()
    let willScrollToTopSubject = PassthroughSubject<UIScrollView, Never>()
    let didEndDraggingSubject = PassthroughSubject<(scrollView: UIScrollView, decelerate: Bool), Never>()
    let didEndDeceleratingSubject = PassthroughSubject<UIScrollView, Never>()

    init(initialState: ViewState<DateTransactionGroup>) {
        state = initialState
    }
}

extension StateTableDatasource {
    enum ViewState<T> {
        case loading
        case empty(titleKey: String?, descriptionKey: String)
        case filled(T)
    }
}

private extension StateTableDatasource {
    func isLastRow(_ indexPath: IndexPath) -> Bool {
        guard case let .filled(viewModels) = state else { return false }
        return indexPath.section == (viewModels.count - 1)
            && indexPath.row == viewModels[indexPath.section].value.endIndex - 1
    }
    
    func mustHideSeparation(at indexPath: IndexPath) -> Bool {
        guard case let .filled(viewModels) = state else { return true }
        guard viewModels[indexPath.section].value.count > 1 else { return true }
        return indexPath.row == viewModels[indexPath.section].value.endIndex - 1
    }
}

extension StateTableDatasource: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard case let .filled(viewModels) = state else { return 1 }
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.removeUnnecessaryHeaderTopPadding()
        guard case let .filled(viewModels) = state else { return UIView() }
        switch viewModels[section].key {
        case let .completed(date):
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Identifiers.headerDateView) as? DateSectionHeaderView
            else { return nil }
            headerView.configure(withDate: date)
            return headerView
        case .pending:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Identifiers.headerPendingView) as? PendingSectionHeaderView
            else { return nil }
            return headerView
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case let .filled(viewModels) = state else { return 1 }
        return viewModels[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.loadingCell) as? SavingsLoadingTableViewCell
            cell?.setIdentifiers(label: "loading_label_transactionsLoading",
                                 infoLabel: "loading_label_moment",
                                 image: "productHomeLoaderTransactionList")
            return  cell ?? UITableViewCell()
        case let .empty(titleKey, descriptionKey):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.emptyCell)
            (cell as? SavingsEmptyTableViewCell)?.configure(titleKey: titleKey, descriptionKey: descriptionKey)
            return cell ?? UITableViewCell()
        case let .filled(viewModels):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.transactionCell) as? SavingsSingleMovementTableViewCell
            let viewModel = viewModels[indexPath.section].value[indexPath.row]
            viewModel.mustShowBottomLineForSingleCell = indexPath.row == viewModels[indexPath.section].value.count - 1
            viewModel.mustHideSeparationLine = mustHideSeparation(at: indexPath)
            viewModel.isFirstRow = indexPath.row == 0
            cell?.configure(withViewModel: viewModel)
            cell?.setIdentifiers(descriptionIdentifier: "productHomeTransactionListLabelConcept",
                                 amountIdentifier: "productHomeTransactionListLabelAmount",
                                 detailIdentifier: viewModel.isActive ? "productHomeTransactionListLabelBalance"
                                 : "productHomeTransactionListLabelDatePending")
            cell?.accessibilityIdentifier = "loansViewItem\(indexPath.row + 1)"
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard case .loading = state else { return true }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let .filled(viewModels) = state else { return }
        let viewModel = viewModels[indexPath.section].value[indexPath.row]
        didSelectRowAtSubject.send(viewModel)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard case .filled = state else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? SavingsSingleMovementTableViewCell)?.highlightView.backgroundColor = .prominentSanGray
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard case .filled = state else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? SavingsSingleMovementTableViewCell)?.highlightView.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isLastRow(indexPath) else { return }
        paginationSubject.send()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightForSection
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollSubject.send(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndDraggingSubject.send((scrollView, decelerate))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDeceleratingSubject.send(scrollView)
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        willScrollToTopSubject.send(scrollView)
        return true
    }
}
