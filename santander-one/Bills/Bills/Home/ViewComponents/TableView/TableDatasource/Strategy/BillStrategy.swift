//
//  BillStrategy.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 3/4/20.
//

import Foundation
import CoreFoundationLib

protocol BillStrategy {
    var numberOfSections: Int { get }
    var state: ViewState<[LastBillViewModel]> { get set }
    func didStateChanged(_ state: ViewState<[LastBillViewModel]>)
    func viewForHeader(in tableView: UITableView, for section: Int) -> UIView?
    func numberOfRowInSection(_ section: Int) -> Int
    func loadingCell(for tableView: UITableView) -> UITableViewCell
    func emptyCell(for tableView: UITableView) -> UITableViewCell
    func cellFor(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    func cellFor(_ tableView: UITableView, withIdentifier identifier: String) -> UITableViewCell
    func getViewModel(for indexPath: IndexPath) -> LastBillViewModel?
    func didSelectRow(in tableView: UITableView, at indexPath: IndexPath)
    func didHighlightRow(in tableView: UITableView, at indexPath: IndexPath)
    func didUnhighlightRow(in tableView: UITableView, at indexPath: IndexPath)
}

protocol BillStrategyDelegate: AnyObject {
    func reloadCellSection(_ cell: UITableViewCell)
    func tableViewDidReachTheEndOfTheList()
    func didSelectTransmitterGroup(_ viewModel: TransmitterGroupViewModel)
    func didSwipeBegin(on cell: LastBillTableViewCell)
    func didSelectReturnReceipt(_ viewModel: LastBillViewModel)
    func didSelectSeePDF(_ viewModel: LastBillViewModel)
}
