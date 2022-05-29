//
//  MonthTransfersListView.swift
//  Menu
//
//  Created by David Gálvez Alonso on 03/06/2020.
//

import UIKit
import CoreFoundationLib

protocol MonthTransfersListViewProtocol {
    func addResults(_ results: [EmittedGroupViewModel])
    func setDelegate(_ delegate: MonthTransfersListViewDelegate?)
    func scrollToTop()
    func configureEmptyTitle(_ title: LocalizedStylableText)
    func setTableViewHeader(transfersNumbers: Int, totalAmount: AmountEntity)
}

protocol MonthTransfersListViewDelegate: AnyObject {
    func didSelectEmitted(viewModel: TransferEmittedViewModel)
}

final class MonthTransfersListView: UIView {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        addSubview(tableView)
        return tableView
    }()
    
    private var list: [EmittedGroupViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private lazy var emptyView: MonthsTransfersEmptyView = {
        let view = MonthsTransfersEmptyView()
        addSubview(view)
        view.isHidden = true
        return view
    }()
    
    private lazy var resumeMovementsView: ResumeMovementsView = {
        let resumeMovementsView = ResumeMovementsView()
        resumeMovementsView.translatesAutoresizingMaskIntoConstraints = false
        return resumeMovementsView
    }()
    
    private lazy var tableHeaderViewContainer: UIView = {
        let container = UIView(frame: CGRect(origin: .zero,
                                             size: CGSize(width: tableView.frame.width,
                                                          height: 74.0)))
        container.addSubview(resumeMovementsView)
        resumeMovementsView.fullFit()
        
        return container
    }()
    
    private weak var delegate: MonthTransfersListViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

private extension MonthTransfersListView {
    func commonInit() {
        self.tableView.fullFit()
        self.configureTableView()
        self.layoutIfNeeded()
    }
    
    func configureEmptyView() {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyView.topAnchor.constraint(equalTo: self.topAnchor, constant: 92.0),
            emptyView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: 211.0)
        ])
    }
    
    func configureTableView() {
        self.tableView.register(MonthTransfersTableViewCell.self, bundle: .module)
        self.tableView.registerHeader(header: MonthTransfersDateSectionView.self, bundle: .module)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 74.0
    }
    
    func getAccessibilityIdentifier(in indexPath: IndexPath) -> String {
        let accesibilityIdentifier = (list[0..<indexPath.section]).reduce(indexPath.row + 1) { $0 + $1.transfer.count }
        return "Transfer\(accesibilityIdentifier)"
    }
}

extension MonthTransfersListView: MonthTransfersListViewProtocol {

    func addResults(_ results: [EmittedGroupViewModel]) {
        list = results
        self.emptyView.isHidden = !list.isEmpty
        tableView.isScrollEnabled = !list.isEmpty
    }
    
    func scrollToTop() {
        guard !list.isEmpty else { return }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func setDelegate(_ delegate: MonthTransfersListViewDelegate?) {
        self.delegate = delegate
    }
    
    func configureEmptyTitle(_ title: LocalizedStylableText) {
        emptyView.setTitleKey(title)
        self.configureEmptyView()
        self.layoutIfNeeded()
    }
    
    func setTableViewHeader(transfersNumbers: Int, totalAmount: AmountEntity) {
        let integerFont = UIFont.santander(family: .text, type: .bold, size: 28.0)
        let decorator = MoneyDecorator(totalAmount, font: integerFont, decimalFontSize: 22.0)
        let totalAmountDecorated = decorator.getFormatedCurrency() ?? NSAttributedString(string: totalAmount.getFormattedAmountAsMillions())
        let emptyDecorated = decorator.formatZeroDecimalWithCurrencyDecimalFont()
        resumeMovementsView.configView(localized("analysis_label_numberOfTransfers"), NSAttributedString(string: String(transfersNumbers)))
        resumeMovementsView.configExtraView(localized("analysis_label_totalAmount"), totalAmount.value == 0 ? emptyDecorated : totalAmountDecorated)
        
        self.tableView.tableHeaderView = tableHeaderViewContainer
    }
}

extension MonthTransfersListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list[section].transfer.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MonthTransfersTableViewCell", for: indexPath) as? MonthTransfersTableViewCell else {
            return UITableViewCell()
        }
        let emitted = list[indexPath.section].transfer[indexPath.row]
        
        cell.dottedHidden(isLast: indexPath.row == self.list[indexPath.section].transfer.count - 1)
        
        cell.setup(withViewModel: emitted)
        cell.accessibilityIdentifier = getAccessibilityIdentifier(in: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectEmitted(viewModel: self.list[indexPath.section].transfer[indexPath.row].transferEmitted)
    }
}

extension MonthTransfersListView: UITableViewDelegate {
    
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
}
