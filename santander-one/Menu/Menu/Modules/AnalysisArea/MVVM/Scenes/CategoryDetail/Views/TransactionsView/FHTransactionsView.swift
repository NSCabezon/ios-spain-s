//
//  FHTransactionsView.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 31/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine

private extension FHTransactionsView {}

final class FHTransactionsView: XibView {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var paginationLoader: UIView! {
        didSet {
            self.paginationLoader.heightAnchor.constraint(equalToConstant: 64).isActive = true
        }
    }
    @IBOutlet private weak var paginationImageLoader: UIImageView!
    private var subscriptions = Set<AnyCancellable>()
    private let cellIdentifier = "FHTransactionTableViewCell"
    private let sectionIdentifier = "FHTransactionSectionView"
    private let emptyCellIdentifier = "FHEmtpyResultTableViewCell"
    private let loaderTransactionsIdentifier = "FHLoaderTableViewCell"
    private enum Constants {
        static let heightForSection: CGFloat = 40
        static let estimatedRowHeight: CGFloat = 80
    }
    private var transactions: [FHTransactionListRepresentable] = []
    private var showEmptyList = true
    private var isShowFullLoader = false
    let paginationSubject = PassthroughSubject<Void, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
    
    func setupHeaderView(_ view: UIView) {
        configureHeaderView(view)
    }
    
    func setTransactions(_ transactions: [FHTransactionListRepresentable]) {
        isShowFullLoader = false
        showEmptyList = transactions.count == 0
        self.transactions = transactions
        reloadTableView()
    }
    
    func didChangeHeaderHeight() {
        reloadTableView()
    }
    
    func showFullLoader() {
        transactions = []
        isShowFullLoader = true
        showEmptyList = false
        reloadTableView()
    }
    
    func hideFullLoader() {
        isShowFullLoader = false
    }
    
    func showPaginationLoading() {
        self.paginationImageLoader.setPointsLoader()
        self.tableView.tableFooterView = paginationLoader
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func hidePaginationLoading() {
        self.paginationImageLoader.removeLoader()
        self.tableView.tableFooterView = nil
    }
}

private extension FHTransactionsView {
    func bind() {}
    
    func setupView() {
        setupTableView()
    }
    
    func setupTableView() {
        registerHeaderAndFooters()
        registerCell()
        tableView.bounces = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func configureHeaderView(_ headerView: UIView) {
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
        tableView.widthAnchor.constraint(equalTo: headerView.widthAnchor).isActive = true
        tableView.tableHeaderView?.heightAnchor.constraint(equalTo: headerView.heightAnchor).isActive = true
        tableView.tableHeaderView?.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        tableView.tableHeaderView?.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
    }
    
    func registerCell() {
        let nib = UINib(nibName: cellIdentifier, bundle: Bundle.module)
        self.tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        let emptyTable = UINib(nibName: "FHEmtpyResultTableViewCell", bundle: Bundle.module)
        self.tableView.register(emptyTable, forCellReuseIdentifier: "FHEmtpyResultTableViewCell")
        let loaderTransactionCell = UINib(nibName: "FHLoaderTableViewCell", bundle: Bundle.module)
        self.tableView.register(loaderTransactionCell, forCellReuseIdentifier: "FHLoaderTableViewCell")
    }
    
    func registerHeaderAndFooters() {
        let nib = UINib(nibName: sectionIdentifier, bundle: Bundle.module)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: sectionIdentifier)
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }        
    }
    
    func getNumberOfSections() -> Int {
        let numberOfDates = transactions.count
        if numberOfDates == 0 {
            return 1
        } else {
            return numberOfDates
        }
    }
    
    func isLastRow(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == (transactions.count - 1)
            && indexPath.row == transactions[indexPath.section].items.endIndex - 1
    }
}

extension FHTransactionsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifier) as? FHTransactionSectionView
        if transactions.count == 0 {
            header?.configure(withDate: localized(""))
        } else {
            let detailDate = self.transactions[section].setDateFormatterFiltered()
            header?.configure(withDate: detailDate)
        }
        tableView.removeUnnecessaryHeaderTopPadding()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightForSection
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isLastRow(indexPath) else { return }
        paginationSubject.send()
    }
}

extension FHTransactionsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (showEmptyList || isShowFullLoader) ? 1 : transactions[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showEmptyList {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellIdentifier, for: indexPath) as? FHEmtpyResultTableViewCell else {
                return UITableViewCell()
            }
            cell.setCellInfo(message: localized("analysis_label_emptyNotMovesThisPeriod"))
            return cell
        } else if isShowFullLoader {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: loaderTransactionsIdentifier, for: indexPath) as? FHLoaderTableViewCell else {
                return UITableViewCell()
            }
            cell.showLoader()
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FHTransactionTableViewCell else {
            return UITableViewCell()
        }
        let transactionItem = transactions[indexPath.section].items[indexPath.row]
        cell.setupCell(with: transactionItem)
        return cell
    }
    
}
