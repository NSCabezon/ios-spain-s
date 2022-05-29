//
//  FinancingDistributionDataSource.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 31/08/2020.
//

import Foundation
import CoreFoundationLib

final class FinancingDistributionDataSource: NSObject, UITableViewDataSource {
    
    private var viewModel: FinanceDistributionViewModel?
    
    public var state: ViewState<FinanceDistributionViewModel> = .loading {
        didSet {
            if case let .filled(viewModel) = state {
                self.viewModel = viewModel
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.rowsAtSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FinancingDistributionProductCell.cellIdentifier, for: indexPath) as? FinancingDistributionProductCell
        
        guard let item = viewModel?.itemAtIndexPath(indexPath), let reusedCell = cell else {
            return UITableViewCell()
        }
        reusedCell.configureCellWithItem(item)
        reusedCell.selectionStyle = .none
        return reusedCell
    }
}
