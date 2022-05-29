//
//  MonthSubscriptionsListView.swift
//  Menu
//
//  Created by Laura González on 11/06/2020.
//

import UIKit
import CoreFoundationLib

protocol MonthSubscriptionsListViewProtocol {
    func addResults(_ results: [SubscriptionsGroupViewModel])
    func setResume(_ subscriptionsNumbers: Int, totalAmount: AmountEntity)
    func setTableHeaderText(_ text: String, resultsNumber: Int)
    func clearTableHeader()
}

final class MonthSubscriptionsListView: UIView {
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
    
    private var list: [SubscriptionsGroupViewModel] = [] {
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

// MARK: - Private Methods

private extension MonthSubscriptionsListView {
    func commonInit() {
        self.tableView.fullFit()
        self.configureTableView()
        self.layoutIfNeeded()
    }
    
    func configureTableView() {
        self.tableView.register(MonthSubscriptionsTableViewCell.self, bundle: .module)
        self.tableView.registerHeader(header: MonthTransfersDateSectionView.self, bundle: .module)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 74.0
    }
    
    func getAccessibilityIdentifier(in indexPath: IndexPath) -> String {
        let accesibilityIdentifier = (list[0..<indexPath.section]).reduce(indexPath.row + 1) { $0 + $1.subscription.count
        }
        return "Subscription\(accesibilityIdentifier)"
    }
}

// MARK: - ListView Protocol

extension MonthSubscriptionsListView: MonthSubscriptionsListViewProtocol {
    func addResults(_ results: [SubscriptionsGroupViewModel]) {
        list = results
    }
    
    func setResume(_ subscriptionsNumbers: Int, totalAmount: AmountEntity) {
        let tableHeader = ResumeMovementsView(frame: CGRect(x: 0, y: 0, width: 0, height: 74.0))
        let integerFont = UIFont.santander(family: .text, type: .bold, size: 28.0)
        let decorator = MoneyDecorator(totalAmount, font: integerFont, decimalFontSize: 22.0)
        let totalAmountDecorated = decorator.getFormatedCurrency() ?? NSAttributedString(string: totalAmount.getFormattedAmountAsMillions())
        let emptyDecorated = decorator.formatZeroDecimalWithCurrencyDecimalFont()
        tableHeader.configView(localized("analysis_label_numberOf"), NSAttributedString(string: String(subscriptionsNumbers)))
        tableHeader.configExtraView(localized("analysis_label_totalAmount"), totalAmount.value == 0 ? emptyDecorated : totalAmountDecorated)
        
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

// MARK: - TableView DataSource

extension MonthSubscriptionsListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list[section].subscription.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MonthSubscriptionsTableViewCell", for: indexPath) as? MonthSubscriptionsTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = list[indexPath.section].subscription[indexPath.row]
        
        cell.dottedHidden(isLast: indexPath.row == self.list[indexPath.section].subscription.count - 1)
        
        cell.setup(withViewModel: viewModel)
        cell.accessibilityIdentifier = getAccessibilityIdentifier(in: indexPath)
        return cell
    }
}

// MARK: - TableView Delegate

extension MonthSubscriptionsListView: UITableViewDelegate {
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
