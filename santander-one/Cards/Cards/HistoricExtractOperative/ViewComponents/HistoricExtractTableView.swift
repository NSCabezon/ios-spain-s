//
//  HistoricExtractTableView.swift
//  Cards
//
//  Created by Ignacio González Miró on 17/11/2020.
//

import UIKit
import CoreFoundationLib

protocol HistoricExtractTableDelegate: AnyObject {
    func tableScrollViewDidScroll(_ scrollView: UIScrollView)
}

final class HistoricExtractTableView: UITableView {
    private var groupedViewModels: [GroupedMovementsViewModel] = []
    weak var tableDelegate: HistoricExtractTableDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setGroupedViewModels(_ groupedViewModels: [GroupedMovementsViewModel]) {
        self.groupedViewModels = groupedViewModels
        self.reloadData()
        self.alwaysBounceVertical = false
    }
}

private extension HistoricExtractTableView {
    func setupView() {
        self.dataSource = self
        self.delegate = self
        self.accessibilityIdentifier = AccessibilityHistoricExtract.table.rawValue
        let cell = UINib(nibName: SettlementMovementGroupedTableViewCell.identifier, bundle: .module)
        self.register(cell, forCellReuseIdentifier: SettlementMovementGroupedTableViewCell.identifier)
        let headerNib = UINib(nibName: SettlementMovementHeaderFooterView.identifier, bundle: Bundle.module)
        self.register(headerNib, forHeaderFooterViewReuseIdentifier: SettlementMovementHeaderFooterView.identifier)
        self.separatorStyle = .none
        self.backgroundColor = .white
        self.isScrollEnabled = false
        self.contentInset.bottom = 103 // size of actionButtonsViewHeight
    }
}

extension HistoricExtractTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedViewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedViewModels[section].movements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettlementMovementGroupedTableViewCell.identifier, for: indexPath) as? SettlementMovementGroupedTableViewCell else {
                return UITableViewCell()
        }
        let viewModel = groupedViewModels[indexPath.section].movements[indexPath.row]
        cell.configureCell(viewModel)
        cell.layoutIfNeeded()
        cell.setNeedsDisplay()
        return cell
    }
}

extension HistoricExtractTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettlementMovementHeaderFooterView.identifier)
            as? SettlementMovementHeaderFooterView else { return nil }
        headerView.configureWithDate(groupedViewModels[section].formatedDate)
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
}

extension HistoricExtractTableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableDelegate?.tableScrollViewDidScroll(scrollView)
    }
}
