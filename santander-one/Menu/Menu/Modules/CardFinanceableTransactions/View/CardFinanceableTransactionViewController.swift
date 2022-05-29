//
//  CardFinanceableTransactionViewController.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/24/20.
//
import UI
import Foundation
import CoreFoundationLib

protocol CardFinanceableTransactionViewProtocol: OldDialogViewPresentationCapable {
    func showCardDropDown(with viewModels: [CardFinanceableViewModel], selectedCardViewModel: CardFinanceableViewModel)
    func showFinanceableTransactions(viewModels: [CardListFinanceableTransactionViewModel])
    func updateViewModel(for viewModel: CardListFinanceableTransactionViewModel) 
    func showDateFilters(_ dates: [Date])
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView(_ completion: (() -> Void)?)
    func showEmptyView()
}

class CardFinanceableTransactionViewController: UIViewController {
    let presenter: CardFinanceableTransactionPresenterProtocol
    let tableViewHeader = FinanceableTableViewHeader()
    let cardsSelectorView = FinanceableProductSelectorView<CardFinanceableViewModel>()
    let sortDateSegmented = SortDateSegmented()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackViewFilter: UIStackView!
    let identifiers = [
        CardListFinanceableTransactionTableViewCell.identifier,
        FinanceableEmptyTableViewCell.identifier
    ]
    lazy var datasource: CardListFinanceableTransactionDatasource = {
        return CardListFinanceableTransactionDatasource()
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: CardFinanceableTransactionPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialState()
        self.setupNavigationBar()
        self.addCardSelectorView()
        self.addFinanceableFilterView()
        self.setupTableView()
        self.presenter.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension CardFinanceableTransactionViewController {
    func initialState() {
        self.cardsSelectorView.isHidden = true
        self.sortDateSegmented.isHidden = true
        self.tableViewHeader.isHidden = true
        self.tableView.isHidden = true
    }
    
    func setupTableView() {
        self.registerCell()
        self.registerHeaderForSection()
        self.tableView.setTableHeaderView(headerView: tableViewHeader)
        self.tableView.delegate = self.datasource
        self.tableView.dataSource = self.datasource
        self.datasource.delegate = self
    }
    
    func registerCell() {
        self.identifiers.forEach({
            let nib = UINib(nibName: $0, bundle: .module)
            self.tableView.register(nib, forCellReuseIdentifier: $0)
        })
    }
    
    func registerHeaderForSection() {
        let nib = UINib(nibName: FinanceableSectionView.identifier, bundle: Bundle.module)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: FinanceableSectionView.identifier)
    }
    
    func addCardSelectorView() {
        self.stackViewFilter.addArrangedSubview(cardsSelectorView)
    }
    
    func addFinanceableFilterView() {
        self.sortDateSegmented.delegate = self
        self.stackViewFilter.addArrangedSubview(sortDateSegmented)
    }
    
    func setupNavigationBar() {
        NavigationBarBuilder(style: .sky, title: .title(key: "toolbar_title_installmentPayments"))
            .setLeftAction(.back(action: #selector(dismissViewController)))
            .setRightActions(.menu(action: #selector(openMenu)))
            .build(on: self, with: self.presenter)
    }
    
    @objc func dismissViewController() {
        self.presenter.dismissViewController()
    }
    
    @objc func openMenu() {
        self.presenter.openMenu()
    }
}

extension CardFinanceableTransactionViewController: CardFinanceableTransactionViewProtocol {
    func showCardDropDown(with viewModels: [CardFinanceableViewModel], selectedCardViewModel: CardFinanceableViewModel) {
        self.cardsSelectorView.isHidden = false
        self.cardsSelectorView.configureWithProducts(viewModels, title: localized("financing_hint_chooseCard")) { [weak self] selected in
            self?.presenter.didselectCardViewModel(selected)
        }
        self.cardsSelectorView.selectElement(selectedCardViewModel)
    }
    
    func showFinanceableTransactions(viewModels: [CardListFinanceableTransactionViewModel]) {
        self.tableViewHeader.isHidden = false
        self.tableView.isHidden = false
        self.tableView.updateHeaderWithAutoLayout()
        self.datasource.didStateChange(.filled(viewModels))
        self.tableView.reloadData()
    }
    
    func showDateFilters(_ dates: [Date]) {
        self.sortDateSegmented.isHidden = false
        self.sortDateSegmented.setDates(dates)
    }
    
    func showEmptyView() {
        self.sortDateSegmented.isHidden = false
        self.tableViewHeader.isHidden = false
        self.tableView.isHidden = false
        self.datasource.didStateChange(.empty)
        self.tableView.reloadData()
    }
    
    func updateViewModel(for viewModel: CardListFinanceableTransactionViewModel) {
        self.datasource.updateViewModel(viewModel)
        UIView.performWithoutAnimation { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension CardFinanceableTransactionViewController: SortDateSegmentedDelegate {
    func didSelectSortByDate(_ date: Date) {
        self.datasource.filterBy(date)
        self.tableView.reloadData()
    }
}

extension CardFinanceableTransactionViewController: CardListFinanceableTransactionCellDelegate {
    func didSelectTransaction(_ viewModel: CardListFinanceableTransactionViewModel) {
        self.presenter.didSelectTransaction(viewModel)
    }
    
    func loadEasyPay(for viewModel: CardListFinanceableTransactionViewModel) {
        self.datasource.updateViewModels()
        self.tableView.reloadData()
        self.presenter.didSelectSeeFrationateOptions(viewModel)
    }
    
    func didSelectCell(_ cell: CardListFinanceableTransactionTableViewCell) {
        self.tableView.beginUpdates()
        cell.collapseExpandAnimation(duration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
        self.tableView.endUpdates()
    }
}

extension CardFinanceableTransactionViewController: LoadingViewPresentationCapable {
    public var associatedLoadingView: UIViewController {
        return self
    }
    
    func showLoadingView(_ completion: (() -> Void)?) {
        self.showLoading(completion: completion)
    }
    
    func hideLoadingView(_ completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
}
