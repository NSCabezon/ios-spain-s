import UIKit
import UI
import CoreFoundationLib

protocol AccountFinanceableTransactionsViewProtocol: AnyObject {
    func showAccountDropDown(with viewModels: [AccountFinanceableViewModel], selectedViewModel: AccountFinanceableViewModel)
    func showFinanceableTransactions(viewModels: [AccountListFinanceableTransactionViewModel])
    func showDateFilters(_ dates: [Date])
    func showLoadingView(_ completion: (() -> Void)?)
    func hideLoadingView(_ completion: (() -> Void)?)
    func showEmptyView()
}

class AccountFinanceableTransactionsViewController: UIViewController {
    
    let presenter: AccountFinanceableTransactionsPresenterProtocol
    let tableViewHeader = FinanceableTableViewHeader()
    let accountsSelectorView = FinanceableProductSelectorView<AccountFinanceableViewModel>()
    let sortDateSegmented = SortDateSegmented()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackViewFilter: UIStackView!
    let identifiers: [String] = [
        AccountListFinanceableTransactionTableViewCell.identifier,
        FinanceableEmptyTableViewCell.identifier
    ]
    lazy var datasource: AccountListFinanceableTransactionDatasoure = {
        return AccountListFinanceableTransactionDatasoure()
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: AccountFinanceableTransactionsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialState()
        self.setupNavigationBar()
        self.addAccountSelectorView()
        self.addFinanceableFilterView()
        self.setupTableView()
        self.presenter.viewDidLoad()
    }
}

private extension AccountFinanceableTransactionsViewController {
    func initialState() {
        self.accountsSelectorView.isHidden = true
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
    
    func addAccountSelectorView() {
        self.stackViewFilter.addArrangedSubview(accountsSelectorView)
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

extension AccountFinanceableTransactionsViewController: AccountFinanceableTransactionsViewProtocol {
    func showAccountDropDown(with viewModels: [AccountFinanceableViewModel], selectedViewModel: AccountFinanceableViewModel) {
        guard viewModels.count > 1 else { return }
        self.accountsSelectorView.isHidden = false
        self.accountsSelectorView.configureWithProducts(viewModels, title: localized("financing_hint_chooseAccount")) { [weak self] selected in
            self?.presenter.didselectAccountViewModel(selected)
        }
        self.accountsSelectorView.selectElement(selectedViewModel)
    }
    
    func showFinanceableTransactions(viewModels: [AccountListFinanceableTransactionViewModel]) {
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
}

extension AccountFinanceableTransactionsViewController: SortDateSegmentedDelegate {
    
    func didSelectSortByDate(_ date: Date) {
        self.datasource.filterBy(date)
        self.tableView.reloadData()
    }
}

extension AccountFinanceableTransactionsViewController: AccountListFinanceableTransactionDatasoureDelegate {
    func didSelectTransaction(_ viewModel: AccountListFinanceableTransactionViewModel) {
        self.presenter.didSelectTransaction(viewModel)
    }
}

extension AccountFinanceableTransactionsViewController: LoadingViewPresentationCapable {
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
