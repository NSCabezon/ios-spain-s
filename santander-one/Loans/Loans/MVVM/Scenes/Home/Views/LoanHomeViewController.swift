//
//  LoandViewController.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 9/30/21.
//
import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

enum Constants {
    static let heightForSection: CGFloat = 39
    static let heightOfCollapsedHeader: CGFloat = 56
    static let estimatedRowHeight: CGFloat = 40
    static let loandingHight: CGFloat = 68
    static let searchPosition: Int = 1
}

enum Identifiers {
    static let transactionCell = "SingleMovementTableViewCell"
    static let loadingCell = "LoadingTableViewCell"
    static let emptyCell = "EmptyTableViewCell"
    static let headerView = "DateSectionView"
    static let loanCell = "LoanCollectionViewCell"
}

public protocol LoansHomeOperativeSource: UIViewController {}

final class LoanHomeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var paginationLoader: UIView!
    @IBOutlet private var paginationImageLoader: UIImageView!
    private let viewModel: LoanHomeViewModel
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: LoanHomeDependenciesResolver
    private let collapsedLoanView = CompressedLoansHeaderView()
    private let expandedLoanView = LoansHeaderView()
    private let navigationBarItemBuilder: NavigationBarItemBuilder
    
    private lazy var loansCollectionView: LoansCollectionView = {
        return expandedLoanView.collectionView
    }()
    private lazy var stateTableViewDatasource: StateTableDatasource = {
        return StateTableDatasource(initialState: .loading)
    }()
    private lazy var scrollManager: ProductHomeScrollManager<LoansHeaderView, CompressedLoansHeaderView> = {
        return ProductHomeScrollManager(
            on: self.view,
            tableView: self.tableView,
            header: self.expandedLoanView,
            collapsedHeader: self.collapsedLoanView,
            configuration: ProductHomeScrollManager.Configuration(collapsedHeaderHeight: Constants.heightOfCollapsedHeader)
        )
    }()
    
    init(dependencies: LoanHomeDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        self.navigationBarItemBuilder = dependencies.external.resolve()
        super.init(nibName: "LoansHome", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setupTableView()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        tableView.tableHeaderView = expandedLoanView
    }
    
    override func viewDidLayoutSubviews() {
        scrollManager.viewDidLayoutSubviews()
    }
}
private extension LoanHomeViewController {
    var headerHeight: CGFloat {
        let margins: CGFloat = 10
        return floor(expandedLoanView.frame.size.height - margins)
    }
    
    func setAppearance() {
        view.backgroundColor = .skyGray
        expandedLoanView.backgroundColor = .skyGray
        tableView.backgroundColor = UIColor.white
    }
    
    func setupTableView() {
        tableView.bounces = false
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.dataSource = stateTableViewDatasource
        tableView.delegate = stateTableViewDatasource
        registerCell()
    }
    
    func registerCell() {
        let cellTransactionNib = UINib(nibName: Identifiers.transactionCell, bundle: .module)
        let loadingCellNib = UINib(nibName: Identifiers.loadingCell, bundle: .module)
        let emptyCellNib = UINib(nibName: Identifiers.emptyCell, bundle: .module)
        let headerNib = UINib(nibName: Identifiers.headerView, bundle: .uiModule)
        tableView.register(cellTransactionNib, forCellReuseIdentifier: Identifiers.transactionCell)
        tableView.register(loadingCellNib, forCellReuseIdentifier: Identifiers.loadingCell)
        tableView.register(emptyCellNib, forCellReuseIdentifier: Identifiers.emptyCell)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: Identifiers.headerView)
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
    
    func setupNavigationBar() {
        navigationBarItemBuilder
            .addStyle(.sky)
            .addTitle(.title(key: "toolbar_title_loans"))
            .addLeftAction(.back, selector: #selector(didSelectGoBack))
            .addRightAction(.menu, selector: #selector(didSelectOpenMenu))
            .addRightAction(.search(position: 1),
                            selector: #selector(didSelectGlobalSearch))
            .build(on: self)
    }
    
    @objc func didSelectGoBack() {
        viewModel.didSelectGoBack()
    }
    
    @objc func didSelectOpenMenu() {
        viewModel.didSelectOpenMenu()
    }
    
    @objc func didSelectGlobalSearch() {
        viewModel.didSelectGlobalSearch()
    }
    
    func bind() {
        bindLoans()
        bindSelectDefaultLoan()
        bindLoansOptions()
        bindLoanDetail()
        bindSelectLoan()
        bindPageControl()
        bindFilters()
        bindFullLoading()
        bindTransactions()
        bindScrollManager()
        bindPagination()
        bindTagsFilters()
    }
    
    func bindLoans() {
        viewModel.state
            .case(LoanState.loansLoaded)
            .filter { !$0.isEmpty}
            .map {[unowned self] in
                $0.map { Loan(loan: $0, dependencies: self.dependencies) }}
            .sink {[unowned self] items in
                self.loansCollectionView.bind(
                    identifier: Identifiers.loanCell,
                    cellType: LoanCollectionViewCell.self,
                    items: items) { (indexPath, cell, item) in
                    cell?.configure(withViewModel: item)
                    cell?.didSelectShare = { [weak self] loan in
                        self?.viewModel.didSelectShare(loan)
                    }
                    let containerId = "\(AccessibilityIDLoansHome.loanCardContainer.rawValue)\(indexPath.row + 1)"
                    let ids = LoanCollectionViewCellIdentifiers(container: containerId)
                    cell?.setAccessibilityIds(ids)
                }
                self.loansCollectionView.reloadData()
                self.loansCollectionView.layoutIfNeeded()
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(LoanState.loansLoaded)
            .map(\.count)
            .sink {[unowned self] numberOfPages in
                self.expandedLoanView.pageControl.numberOfPages = numberOfPages
                self.expandedLoanView.pageControl.isHidden = numberOfPages <= 1
            }.store(in: &anySubscriptions)
    }
    
    func bindSelectDefaultLoan() {
        let selectLoanPublisher = viewModel.state
            .case(LoanState.selectedLoan)
            .compactMap { $0 }
            .map {[unowned self] in
                Loan(loan: $0, dependencies: self.dependencies)
            }.share()
        
        selectLoanPublisher
            .sink {[unowned self] loan in
                self.loansCollectionView.scrollTo(loan)
            }.store(in: &anySubscriptions)
        
        selectLoanPublisher
            .subscribe(collapsedLoanView.selectLoanSubject)
            .store(in: &anySubscriptions)
        
        selectLoanPublisher
            .sink {[unowned self] viewModel in
                self.expandedLoanView
                    .actionsHeaderView?
                    .selectLoanSubject.send(viewModel)
            }.store(in: &anySubscriptions)
        
        selectLoanPublisher
            .optional()
            .assign(to: \.loan, on: expandedLoanView)
            .store(in: &anySubscriptions)
    }
    
    func bindLoansOptions() {
        viewModel.state
            .case(LoanState.options)
            .map { values in
                values.map { LoanHomeOption($0) }
            }.subscribe(expandedLoanView.optionsSubject)
            .store(in: &anySubscriptions)
        
        expandedLoanView
            .didSelectOptionSubject
            .sink {[unowned self] values in
                self.viewModel.didSelectOption(values.option, loan: values.loan)
            }.store(in: &anySubscriptions)
    }
    
    func bindLoanDetail() {
        let loanDetailPublisher = viewModel.state
            .case(LoanState.detailLoaded)
            .map {[unowned self] in
                Loan(loan: $0.loan, detail: $0.detail, dependencies: self.dependencies)
            }.share()
        
        loanDetailPublisher
            .subscribe(loansCollectionView.detailSubject)
            .store(in: &anySubscriptions)
        
        loanDetailPublisher
            .optional()
            .assign(to: \.loan, on: expandedLoanView)
            .store(in: &anySubscriptions)
    }
    
    func bindSelectLoan() {
        loansCollectionView
            .didSelectLoanSubject
            .sink {[unowned self] loan in
                self.viewModel.didSelectLoan(loan)
            }.store(in: &anySubscriptions)
        
        loansCollectionView
            .didSelectLoanSubject
            .subscribe(collapsedLoanView.selectLoanSubject)
            .store(in: &anySubscriptions)
        
        loansCollectionView
            .didSelectLoanSubject
            .sink {[unowned self] loan in
                self.expandedLoanView
                    .actionsHeaderView?
                    .selectLoanSubject.send(loan)
            }.store(in: &anySubscriptions)
        
        loansCollectionView
            .didSelectLoanSubject
            .optional()
            .assign(to: \.loan, on: expandedLoanView)
            .store(in: &anySubscriptions)
    }
    
    func bindPageControl() {
        loansCollectionView
            .positionChangesSubject
            .assign(to: \.currentPage, on: expandedLoanView.pageControl)
            .store(in: &anySubscriptions)
    }
    
    func bindFilters() {
        collapsedLoanView
            .didSelectFilter
            .sink {[unowned self] loan in
                self.viewModel.didSelectFilter(loan)
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(LoanState.isHiddenFilters)
            .sink {[unowned self] hide in
                self.expandedLoanView.actionsHeaderView?.hideFilterSubject.send(hide)
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(LoanState.isHiddenFilters)
            .assign(to: \.isFilterDisabled, on: collapsedLoanView)
            .store(in: &anySubscriptions)
        
        expandedLoanView.actionsHeaderView?
            .didSelectActionSubject
            .sink {[unowned self] value in
                self.viewModel.didSelectFilter(value)
            }.store(in: &anySubscriptions)
        
        stateTableViewDatasource
            .didScrollSubject
            .filter {[unowned self] _ in
                self.headerHeight > 0
            }.map(\.contentOffset.y)
            .map {[unowned self] offset in
                0...self.headerHeight ~= offset
            }.subscribe(collapsedLoanView.hideFilterSubject)
            .store(in: &anySubscriptions)
    }
    
    func bindTagsFilters() {
    viewModel.state
        .case(LoanState.filters)
        .sink { [unowned self] filters in
            self.expandedLoanView.filterStateSubject.send(.loaded(filters))
            self.tableView.updateHeaderViewFrame()
        }.store(in: &anySubscriptions)
        
        expandedLoanView
            .filterStateSubject
            .case(LoansFilterState.removeAll)
            .sink { [unowned self] _ in
                self.tableView.updateHeaderViewFrame()
                self.viewModel.removeAllFilters()
            }.store(in: &anySubscriptions)
        
        expandedLoanView
            .filterStateSubject
            .case(LoansFilterState.remove)
            .sink { [unowned self] filter in
                self.viewModel.removeFilterFilter(filter)
            }.store(in: &anySubscriptions)
    }
    
    func bindFullLoading() {
        viewModel.state
            .case(LoanState.isFullScreenLoading)
            .sink {[unowned self] show in
                show ? self.showLoading() : self.dismissLoading()
            }.store(in: &anySubscriptions)
    }
    
    func bindTransactions() {
        let transactionPublisher = viewModel.state
            .case(LoanState.transactionsLoaded)
            .map { transactions in
                transactions.map(LoanTransaction.init)
            }.share()
        
        let sortOrderPublihser = viewModel.state
            .case(LoanState.transactionSortOrder)
        
        transactionPublisher
            .combineLatest(sortOrderPublihser)
            .map { transactions, orderBy in
                (transactions.group(by: \.date), orderBy)
            }.map { (transactions, order)  in
                transactions.sort(by: order)
            }.sink {[unowned self] dateTransactionGroups in
                // DOUBLE CHECK
                self.expandedLoanView.actionsHeaderView?.bottomView.isHidden = true
                self.stateTableViewDatasource.state = .filled(dateTransactionGroups)
                self.tableView.reloadData()
            }.store(in: &anySubscriptions)
        
        transactionPublisher
            .filter { $0.isEmpty }
            .sink {[unowned self] _ in
                self.stateTableViewDatasource.state = .empty(with: nil)
                self.tableView.reloadData()
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(LoanState.isTransactionLoading)
            .filter { showloanding in
                return showloanding == true
            }
            .sink {[unowned self] _ in
                // DOUBLE CHECK
                self.expandedLoanView.actionsHeaderView?.bottomView.isHidden = true
                self.stateTableViewDatasource.state = .loading
                self.tableView.reloadData()
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case(LoanState.transactionError)
            .sink { error in
                self.stateTableViewDatasource.state = .empty(with: error)
                self.tableView.reloadData()
            }.store(in: &anySubscriptions)
        
        stateTableViewDatasource
            .didSelectRowAtSubject
            .sink {[unowned self] transaction in
                self.viewModel.didSelectTransaction(transaction: transaction)
            }.store(in: &anySubscriptions)
    }
    
    func bindScrollManager() {
        stateTableViewDatasource
            .didScrollSubject
            .sink {[unowned self] scrollView in
                self.scrollManager.scrollViewDidScroll(scrollView)
            }.store(in: &anySubscriptions)
        
        stateTableViewDatasource
            .didEndDraggingSubject
            .sink {[unowned self] values in
                self.scrollManager.scrollViewDidEndDragging(values.scrollView, willDecelerate: values.decelerate)
            }.store(in: &anySubscriptions)
        
        stateTableViewDatasource
            .didEndDeceleratingSubject
            .sink {[unowned self] scrollView in
                self.scrollManager.scrollViewDidEndDecelerating(scrollView)
            }.store(in: &anySubscriptions)
    }
    
    func bindPagination() {
        viewModel.state
            .case(LoanState.isPaginationLoading)
            .sink {[unowned self] show in
                show ? self.showPaginationLoading() : hidePaginationLoading()
            }.store(in: &anySubscriptions)
        
        stateTableViewDatasource.paginationSubject
            .sink {[unowned self]  in
                self.viewModel.loadMoreTransactions()
            }.store(in: &anySubscriptions)
    }
}

extension LoanHomeViewController: LoadingViewPresentationCapable {}
extension LoanHomeViewController: NavigationBarWithSearch {}
extension LoanHomeViewController: LoansHomeOperativeSource {}
extension LoanHomeViewController: HighlightedMenuProtocol {
    func getOption() -> PrivateMenuOptions? {
        return .myProducts
    }
}
extension LoanHomeViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
