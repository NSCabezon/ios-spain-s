import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import UIOneComponents

enum SavingHeaderAction: State {
    case idle
    case download
    case filter
}

enum Constants {
    static let heightForSection: CGFloat = 44
    static let heightOfCollapsedHeader: CGFloat = 72
    static let estimatedRowHeight: CGFloat = 76
    static let loadingHight: CGFloat = 68
    static let searchPosition: Int = 1
    static let complementaryFieldHeight: CGFloat = 20
}

enum Identifiers {
    static let transactionCell = "SavingsSingleMovementTableViewCell"
    static let loadingCell = "SavingsLoadingTableViewCell"
    static let emptyCell = "SavingsEmptyTableViewCell"
    static let headerView = "DateSectionView"
    static let savingsCell = "SavingProductsHomeCollectionViewCell"
    static let headerDateView = "DateSectionHeaderView"
    static let headerPendingView = "PendingSectionHeaderView"
}

final class SavingsHomeViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var paginationLoader: UIView!
    @IBOutlet private var paginationImageLoader: UIImageView!
    private let collapsedSavingsView = CompressedSavingsHeaderView()
    private let expandedSavingsView = SavingProductsHeaderView()
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SavingsHomeDependenciesResolver
    private let viewModel: SavingsHomeViewModel
    
    private lazy var savingsCollectionView: SavingsHomeCollectionView = {
        return expandedSavingsView.collectionView
    }()
    private lazy var stateTableViewDatasource: StateTableDatasource = {
        return StateTableDatasource(initialState: .loading)
    }()
    private lazy var scrollManager: SavingsHomeScrollManager<SavingProductsHeaderView, UIView> = {
        return SavingsHomeScrollManager(
            on: self.view,
            tableView: self.tableView,
            header: self.expandedSavingsView,
            collapsedHeader: self.collapsedSavingsView,
            configuration: SavingsHomeScrollManager.Configuration(collapsedHeaderHeight: Constants.heightOfCollapsedHeader,
                                                                  collapseThresholdPercentage: 1.10,
                                                                  isActionHeaderViewUnderneathCollapsedView: true))
    }()
    
    init(dependencies: SavingsHomeDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SavingsHome", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setupOneNavigationBar()
        setupTableView()
        bind()
        viewModel.viewDidLoad()
        UIAccessibility.post(notification: .layoutChanged, argument: navigationItem.titleView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableHeaderView = expandedSavingsView
        self.savingsCollectionView.reloadData()
        viewModel.viewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        scrollManager.viewDidLayoutSubviews()
    }
}

private extension SavingsHomeViewController {
    func setAppearance() {
        view.backgroundColor = .oneWhite
        expandedSavingsView.backgroundColor = .oneWhite
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
        tableView.register(cellTransactionNib, forCellReuseIdentifier: Identifiers.transactionCell)
        tableView.register(loadingCellNib, forCellReuseIdentifier: Identifiers.loadingCell)
        tableView.register(emptyCellNib, forCellReuseIdentifier: Identifiers.emptyCell)
        tableView.register(DateSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: Identifiers.headerDateView)
        tableView.register(PendingSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: Identifiers.headerPendingView)
    }
    
    func setupOneNavigationBar() {
        OneNavigationBarBuilder(.whiteWithRedComponents)
            .setTitle(withKey: "pgBasket_title_savingProducts")
            .setLeftAction(.back, customAction: {
                self.didSelectGoBack()
            })
            .setRightAction(.menu) {
                self.didSelectOpenMenu()
            }
            .setTooltip({ [weak self] _ in
                self?.viewModel.didSelectSavingsInfo()
            })
            .build(on: self)
    }
    
    @objc func didSelectGoBack() {
        viewModel.didSelectGoBack()
    }
    
    @objc func didSelectOpenMenu() {
        viewModel.didSelectOpenMenu()
    }
    
    func showPaginationLoading() {
        self.paginationImageLoader.setNewJumpingLoader()
        self.tableView.tableFooterView = paginationLoader
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func hidePaginationLoading() {
        self.paginationImageLoader.removeLoader()
        self.tableView.tableFooterView = nil
    }
    
    func bind() {
        bindSavings()
        bindSelectDefaultSavingProduct()
        bindSavingsOptions()
        bindPageControl()
        bindActions()
        bindComingSoon()
        bindError()
        bindPagination()
        bindSelectSaving()
        bindTransactionsLoaded()
        bindTransactionsActionButtons()
        bindSelectTransaction()
        bindScrollManager()
        bindPendingLoaded()
        bindBottom()
        bindMoreOptions()
    }
    
    func bindSavings() {
        viewModel.state
            .case(SavingsState.savingsLoaded)
            .filter { !$0.isEmpty }
            .sink {[unowned self] items in
                self.expandedSavingsView.updateHeight(CGFloat(items[0].totalNumberOfFields) * Constants.complementaryFieldHeight)
                self.savingsCollectionView.bind(
                    identifier: Identifiers.savingsCell,
                    cellType: SavingProductsHomeCollectionViewCell.self,
                    items: items) { (indexPath, cell, item) in
                        cell?.configure(withModel: item)
                        cell?.contentView.accessibilityLabel = localized("voiceover_savingsCarouselPosition",
                                                                         [StringPlaceholder(.number, "\(items.count)"),
                                                                          StringPlaceholder(.number, "\(indexPath.row + 1)"),
                                                                          StringPlaceholder(.number, "\(items.count)")]).text
                    }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.view.layoutIfNeeded()
                }
                self.savingsCollectionView.reloadData()
            }.store(in: &anySubscriptions)
        
        viewModel.state
            .case ( SavingsState.savingsLoaded )
            .map(\.count)
            .sink {[unowned self] numberOfPages in
                self.expandedSavingsView.pageControl.numberOfPages = numberOfPages
                self.expandedSavingsView.pageControl.isHidden = numberOfPages <= 1
            }.store(in: &anySubscriptions)
    }
    
    func bindSelectDefaultSavingProduct() {
        let selectSavingProductsPublisher = viewModel.state
            .case(SavingsState.selectedSavingProduct)
            .share()
        
        selectSavingProductsPublisher
            .sink {[unowned self] savingProduct in
                self.savingsCollectionView.scrollTo(savingProduct)
                self.expandedSavingsView.updatePageControlDots()
            }.store(in: &anySubscriptions)
        
        selectSavingProductsPublisher
            .optional()
            .assign(to: \.savingProduct, on: expandedSavingsView)
            .store(in: &anySubscriptions)
    }
    
    func bindSavingsOptions() {
        viewModel.state
            .case(SavingsState.options)
            .subscribe(expandedSavingsView.optionsSubject)
            .store(in: &anySubscriptions)

        viewModel.state
            .case(SavingsState.shouldShowMoreOptionsButton)
            .subscribe(expandedSavingsView.headerShouldShowMoreOptions)
            .store(in: &anySubscriptions)
        
        expandedSavingsView
            .didSelectOptionSubject
            .sink {[weak self] option in
                self?.viewModel.didSelectOption(option)
            }.store(in: &anySubscriptions)
    }
    
    func bindPageControl() {
        savingsCollectionView
            .positionChangesSubject
            .assign(to: \.currentPage, on: expandedSavingsView.pageControl)
            .store(in: &anySubscriptions)
        savingsCollectionView
            .positionChangesSubject
            .sink { [unowned self] _ in
                self.expandedSavingsView.updatePageControlDots()
            }.store(in: &anySubscriptions)
    }
    
    func bindActions() {
        expandedSavingsView
            .actionsHeaderView?
            .state
            .sink { [weak self] action in
                self?.viewModel.didSelect(action: action)
            }.store(in: &anySubscriptions)
        
        collapsedSavingsView
            .didSelectActionButton
            .sink { [weak self] action in
                self?.viewModel.didSelect(action: action)
            }.store(in: &anySubscriptions)
    }
    
    func bindComingSoon() {
        viewModel
            .state
            .case(SavingsState.comingSoon)
            .sink { value in
                Toast.show(localized(value))
            }.store(in: &anySubscriptions)
    }
    
    func bindError() {
        viewModel
            .state
            .case(SavingsState.error)
            .sink { [weak self] value in
                self?.stateTableViewDatasource.state = .empty(titleKey: nil, descriptionKey: "product_label_emptyError")
                self?.tableView.reloadData()
            }.store(in: &anySubscriptions)
    }
    
    func bindPagination() {
        viewModel.state
            .case(SavingsState.isPaginationLoading)
            .sink {[unowned self] show in
                show ? self.showPaginationLoading() : hidePaginationLoading()
            }.store(in: &anySubscriptions)
        
        stateTableViewDatasource.paginationSubject
            .sink {[unowned self]  in
                self.viewModel.loadMoreTransactions()
            }.store(in: &anySubscriptions)
    }
    
    func bindTransactionsLoaded() {
        viewModel
            .state
            .case(SavingsState.transactionsLoaded)
            .sink { [weak self] value in
                if !value.isEmpty {
                    self?.stateTableViewDatasource.state = .filled(value)
                } else {
                    self?.stateTableViewDatasource.state = .empty(titleKey: "generic_label_empty",
                                                                  descriptionKey: "generic_label_emptyNotAvailableMoves")
                }
                self?.tableView.reloadData()
            }.store(in: &anySubscriptions)
    }
    
    func bindPendingLoaded() {
        viewModel
            .state
            .case(SavingsState.pendingFieldLoaded)
            .sink { [weak self] value in
                self?.expandedSavingsView.collectionView.updatePendingField(value)
                self?.savingsCollectionView.layoutIfNeeded()
            }.store(in: &anySubscriptions)
    }
    
    func bindScrollManager() {
        stateTableViewDatasource
            .didScrollSubject
            .sink {[unowned self] scrollView in
                self.scrollManager.scrollViewDidScroll(scrollView)
            }.store(in: &anySubscriptions)
        
        stateTableViewDatasource
            .willScrollToTopSubject
            .sink {[unowned self] scrollView in
                self.scrollManager.scrollViewWillScrollToTop(scrollView)
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
    
    func bindTransactionsActionButtons() {
        viewModel.state
            .case(SavingsState.transactionsHeaderButtonActions)
            .subscribe(expandedSavingsView.transactionsButtonsSubject)
            .store(in: &anySubscriptions)
        
        viewModel.state
            .case(SavingsState.transactionsHeaderButtonActions)
            .subscribe(collapsedSavingsView.transactionsButtonsSubject)
            .store(in: &anySubscriptions)
    }
    
    func bindSelectTransaction() {
        stateTableViewDatasource
            .didSelectRowAtSubject
            .sink { [weak self] value in
                self?.viewModel.didSelectTransaction(value)
            }.store(in: &anySubscriptions)
    }
    
    func bindSelectSaving() {
        viewModel
            .state
            .case(SavingsState.savingDetail)
            .subscribe(collapsedSavingsView.selectSavingSubject)
            .store(in: &anySubscriptions)
        
        let didSelectSavingsSubject = expandedSavingsView
            .collectionView
            .didSelectSavingsSubject
            .map { Just($0).eraseToAnyPublisher() }
            .switchToLatest()
            .share()
        didSelectSavingsSubject
            .subscribe(collapsedSavingsView.selectSavingSubject)
            .store(in: &anySubscriptions)
        didSelectSavingsSubject
            .sink(receiveValue: { [unowned self] _ in
                self.viewModel.didSwipeCarousel()
            })
            .store(in: &anySubscriptions)
        didSelectSavingsSubject
            .sink(receiveValue: { [unowned self] savings in
                self.expandedSavingsView.collectionView.updateColors()
                self.stateTableViewDatasource.state = .loading
                self.tableView.reloadData()
                self.viewModel.didSelect(product: savings)
            })
            .store(in: &anySubscriptions)
    }
    
    func bindBottom() {
        viewModel
            .state
            .case(SavingsState.bottom)
            .sink { [weak self] (titleKey, infoKey) in
                guard let self = self else { return }
                let type: SizablePresentationType = .custom(isPan: true, bottomVisible: true, tapOutsideDismiss: true)
                let view = SavingsBottomView()
                view.configure(titleKey: titleKey, infoKey: infoKey)
                BottomSheet().show(in: self,
                                   type: type,
                                   view: view,
                                   btnCloseAccessibilityLabel: localized("voiceover_closeHelp"))
                UIAccessibility.post(notification: .announcement, argument: localized(titleKey) + " " + localized(infoKey))
            }.store(in: &anySubscriptions)
    }

    func bindMoreOptions() {
        expandedSavingsView.didTapMoreOptionsSubject
            .case(OneShortcutsViewStates.didTapMoreOptions)
            .sink { [unowned self] _ in
                self.viewModel.didSelectMoreOperativesButton()
            }.store(in: &anySubscriptions)
    }
}

extension SavingsHomeViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}
