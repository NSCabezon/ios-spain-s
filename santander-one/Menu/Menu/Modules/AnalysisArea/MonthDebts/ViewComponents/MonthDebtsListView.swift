//
//  MonthDebtsListView.swift
//  Menu
//
//  Created by Laura González on 08/06/2020.
//

import UIKit
import CoreFoundationLib

protocol AnalysisListViewProtocolDelegate: AnyObject {
    func didSelectRowAtIndexPath(_ indexPath: IndexPath)
}

protocol MonthDebtsListViewProtocol {
    func addResults(_ results: [DebtsGroupViewModel])
    func setTableViewHeader(_ totalAmount: AmountEntity)
    func setTableHeaderText(_ text: String, resultsNumber: Int)
    func clearTableHeader()
}

final class MonthDebtsListView: UIView {
    
    weak var delegate: AnalysisListViewProtocolDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        addSubview(tableView)
        return tableView
    }()
    
    private lazy var tableHeaderViewContainer: UIView = {
        let container = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 47.0)))
        return container
    }()
    
    private var list: [DebtsGroupViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

private extension MonthDebtsListView {
    func commonInit() {
        self.tableView.fullFit()
        self.configureTableView()
        self.layoutIfNeeded()
    }
    
    func configureTableView() {
        self.tableView.register(MonthDebtsTableViewCell.self, bundle: .module)
        self.tableView.registerHeader(header: MonthTransfersDateSectionView.self, bundle: .module)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 74.0
    }
    
    func getAccessibilityIdentifier(in indexPath: IndexPath) -> String {
        let accesibilityIdentifier = (list[0..<indexPath.section]).reduce(indexPath.row + 1) { $0 + $1.debt.count
        }
        return "Debt\(accesibilityIdentifier)"
    }
}

extension MonthDebtsListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list[section].debt.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MonthDebtsTableViewCell", for: indexPath) as? MonthDebtsTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = list[indexPath.section].debt[indexPath.row]
        
        cell.dottedHidden(isLast: indexPath.row == self.list[indexPath.section].debt.count - 1)
        
        cell.setup(withViewModel: viewModel)
        cell.accessibilityIdentifier = getAccessibilityIdentifier(in: indexPath)
        return cell
    }
}

extension MonthDebtsListView: MonthDebtsListViewProtocol {
    func addResults(_ results: [DebtsGroupViewModel]) {
        list = results
    }
    
    func setTableViewHeader(_ totalAmount: AmountEntity) {
        let tableHeader = ResumeMovementsView(frame: CGRect(x: 0, y: 0, width: 0, height: 74.0))
        let integerFont = UIFont.santander(family: .text, type: .bold, size: 28.0)
        let totalAmountDecorated = MoneyDecorator(totalAmount, font: integerFont, decimalFontSize: 22.0).getFormatedCurrency() ?? NSAttributedString(string: totalAmount.getFormattedAmountAsMillions())
        tableHeader.singleView()
        tableHeader.configView(localized("analysis_label_reducedYourDebt"), totalAmountDecorated)
        
        self.tableView.tableHeaderView = tableHeader
    }
    
    func setTableHeaderText(_ text: String, resultsNumber: Int) {
        guard resultsNumber > 0 else { return clearTableHeader() }
        tableView.tableHeaderView = tableHeaderViewContainer
    }
    
    func clearTableHeader() {
        tableView.tableHeaderView = nil
    }
}

extension MonthDebtsListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MonthTransfersDateSectionView")
            as? MonthTransfersDateSectionView else { return nil }
        
        headerView.configure(withDate: list[section].dateFormatted)
        headerView.hideSeparator(true)
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectRowAtIndexPath(indexPath)
    }
}
