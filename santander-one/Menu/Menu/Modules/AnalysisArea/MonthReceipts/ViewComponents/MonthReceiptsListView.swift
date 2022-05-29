//
//  MonthReceiptsListView.swift
//  Menu
//
//  Created by Ignacio González Miró on 09/06/2020.
//

import UIKit
import CoreFoundationLib

protocol MonthReceiptsListViewProtocol {
    func addResults(_ results: [ReceiptsGroupViewModel])
    func setDelegate(_ delegate: MonthReceiptsListViewDelegate?)
    func scrollToTop()
    func setTableViewHeader(receiptNumbers: Int, totalAmount: AmountEntity)
}

protocol MonthReceiptsListViewDelegate: AnyObject {
    func didSelectReceipt(viewModel: ReceiptsViewModel)
}

final class MonthReceiptsListView: UIView {
    
    weak var listViewDelegate: AnalysisListViewProtocolDelegate?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        addSubview(tableView)
        return tableView
    }()
    
    private weak var delegate: MonthReceiptsListViewDelegate?

    private var list: [ReceiptsGroupViewModel] = [] {
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

private extension MonthReceiptsListView {
    func commonInit() {
        self.tableView.fullFit()
        self.configureTableView()
        self.layoutIfNeeded()
    }
    
    func configureTableView() {
        self.tableView.register(MonthReceiptTableViewCell.self, bundle: .module)
        self.tableView.registerHeader(header: MonthTransfersDateSectionView.self, bundle: .module)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func getAccessibilityIdentifier(in indexPath: IndexPath) -> String {
        let accesibilityIdentifier = (list[0..<indexPath.section]).reduce(indexPath.row + 1) { $0 + $1.receipts.count }
        return "Receipt\(accesibilityIdentifier)"
    }
}

extension MonthReceiptsListView: MonthReceiptsListViewProtocol {
    func addResults(_ results: [ReceiptsGroupViewModel]) {
        list = results
        tableView.isScrollEnabled = !list.isEmpty
    }
    
    func setDelegate(_ delegate: MonthReceiptsListViewDelegate?) {
        self.delegate = delegate
    }
    
    func scrollToTop() {
        guard !list.isEmpty else { return }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func setTableViewHeader(receiptNumbers: Int, totalAmount: AmountEntity) {
        let resumeMovementsView = ResumeMovementsView(frame: CGRect(x: 0, y: 0, width: 0, height: 74.0))
        let integerFont = UIFont.santander(family: .text, type: .bold, size: 28.0)
        let totalAmountDecorated = MoneyDecorator(totalAmount, font: integerFont, decimalFontSize: 22.0).getFormatedCurrency() ?? NSAttributedString(string: totalAmount.getFormattedAmountAsMillions())
        resumeMovementsView.configView(localized("analysis_label_numberOfReceipts"), NSAttributedString(string: String(receiptNumbers)))
        resumeMovementsView.configExtraView(localized("analysis_label_totalAmount"), totalAmountDecorated)
        self.tableView.tableHeaderView = resumeMovementsView
    }
}

extension MonthReceiptsListView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list[section].receipts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MonthReceiptTableViewCell.identifier, for: indexPath) as? MonthReceiptTableViewCell else { return MonthReceiptTableViewCell() }
        let receipt = list[indexPath.section].receipts[indexPath.row]
        cell.config(receipt)
        cell.selectionStyle = .none
        cell.accessibilityIdentifier = getAccessibilityIdentifier(in: indexPath)
        return cell
    }
}

extension MonthReceiptsListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MonthTransfersDateSectionView") as? MonthTransfersDateSectionView else {
            return UIView()
        }
        let date = self.list[section].dateFormatted
        headerView.configure(withDate: date)
        headerView.hideSeparator(true)
        tableView.removeUnnecessaryHeaderTopPadding()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listViewDelegate?.didSelectRowAtIndexPath(indexPath)
    }
}
