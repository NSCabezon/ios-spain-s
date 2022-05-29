//
//  TipDetailBuilder.swift
//  Menu
//
//  Created by Margaret López Calderon on 05/08/2020.
//

import Foundation

struct TipDetailBuilder {
    static let tipCellIdentifier = "TipDetailTableViewCell"

    func cell(for tableView: UITableView, at indexPath: IndexPath, viewModel: TipDetailViewModel) -> TipDetailTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TipDetailBuilder.tipCellIdentifier,
                                                       for: indexPath) as? TipDetailTableViewCell else { fatalError() }
        viewModel.updateView(cell)
        return cell
    }
}
