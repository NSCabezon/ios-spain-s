//
//  StateTableDatasource.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 10/21/21.
//

import UI
import CoreFoundationLib
import Foundation
import OpenCombine

typealias DateTransactionGroup = [(key: Date, value: [LoanTransaction])]

final class StateTableDatasource: NSObject {
    var state: ViewState<DateTransactionGroup> = .loading
    let paginationSubject = PassthroughSubject<Void, Never>()
    let didSelectRowAtSubject = PassthroughSubject<LoanTransaction, Never>()
    let didScrollSubject = PassthroughSubject<UIScrollView, Never>()
    let didEndDraggingSubject = PassthroughSubject<(scrollView: UIScrollView, decelerate: Bool), Never>()
    let didEndDeceleratingSubject = PassthroughSubject<UIScrollView, Never>()

    init(initialState: ViewState<DateTransactionGroup>) {
        state = initialState
    }
}

extension StateTableDatasource {
    enum ViewState<T> {
        case loading
        case empty(with: LocalizedError?)
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
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Identifiers.headerView) as? DateSectionView
        else { return nil }
        let date = viewModels[section].key
        let localizedDate = DateDecorator(date).setDateFormatter(false)
        headerView.configure(withDate: localizedDate)
        headerView.setLabelIdentifier(AccessibilityIDLoansHome.movementDateLabel.rawValue)
        return headerView
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case let .filled(viewModels) = state else { return 1 }
        return viewModels[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.loadingCell)
            (cell as? LoadingTableViewCell)?.setIdentifiers(
                label: AccessibilityIDLoansHome.loadingLabel.rawValue,
                image: AccessibilityIDLoansHome.loadingImage.rawValue
            )
            return  cell ?? UITableViewCell()
        case .empty(let error):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.emptyCell)
            (cell as? EmptyTableViewCell)?.configure(with: error)
            cell?.accessibilityIdentifier = AccessibilityIDLoansHome.movementsError.rawValue
            return cell ?? UITableViewCell()
        case let .filled(viewModels):
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.transactionCell)
            let viewModel = viewModels[indexPath.section].value[indexPath.row]
            viewModel.mustHideSeparationLine = mustHideSeparation(at: indexPath)
            (cell as? SingleMovementTableViewCell)?.configure(withViewModel: viewModel)
            (cell as? SingleMovementTableViewCell)?.setIdentifiers(
                descriptionIdentifier: AccessibilityIDLoansHome.movementConceptLabel.rawValue,
                amountIdentifier: AccessibilityIDLoansHome.movementAmountLabel.rawValue
            )
            cell?.accessibilityIdentifier = "transactionCell\(indexPath.row)"
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
        (cell as? SingleMovementTableViewCell)?.highlightView.backgroundColor = .prominentSanGray
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard case .filled = state else { return }
        let cell = tableView.cellForRow(at: indexPath)
        (cell as? SingleMovementTableViewCell)?.highlightView.backgroundColor = .white
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
}
