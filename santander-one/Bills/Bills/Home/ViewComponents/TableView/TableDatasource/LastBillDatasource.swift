//
//  LastBillDatasource.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/19/20.
//

import CoreFoundationLib

protocol LastBillTableDatasourceDelegate: AnyObject {
    func didSelectLastBillViewModel(_ viewModel: LastBillViewModel)
}

class LastBillTableDatasource: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var strategy: BillStrategy
    private var state: ViewState<[LastBillViewModel]>
    private weak var datasourceDelegate: LastBillTableDatasourceDelegate?

    init(strategy: BillStrategy) {
        self.state = .loading
        self.strategy = strategy
        self.strategy.didStateChanged(self.state)
    }
    
    func setStrategy(_ strategy: BillStrategy) {
        self.strategy = strategy
        self.strategy.didStateChanged(state)
    }
    
    func setDelegate(delegate: LastBillTableDatasourceDelegate?) {
        self.datasourceDelegate = delegate
    }
    
    func didStateChanged(_ state: ViewState<[LastBillViewModel]>) {
        self.state = state
        self.strategy.didStateChanged(state)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.strategy.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.removeUnnecessaryHeaderTopPadding()
        return self.strategy.viewForHeader(in: tableView, for: section)
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.strategy.numberOfRowInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.strategy.state {
        case .loading:
            return self.strategy.loadingCell(for: tableView)
        case .empty:
            return self.strategy.emptyCell(for: tableView)
        case .filled:
            return self.strategy.cellFor(tableView, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard case .loading = self.strategy.state else { return true }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.strategy.didSelectRow(in: tableView, at: indexPath)
        guard let viewModel = self.strategy.getViewModel(for: indexPath) else { return }
        self.datasourceDelegate?.didSelectLastBillViewModel(viewModel)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        self.strategy.didHighlightRow(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        self.strategy.didUnhighlightRow(in: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension Sequence where Iterator.Element == LastBillViewModel {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        return Dictionary(grouping: self, by: key)
    }
}
