//
//  ViewController.swift
//  PROJECT_Example
//
//  Created by Juan Carlos López Robles on 11/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import UI
import CoreFoundationLib
import OfferCarousel
import CoreDomain

protocol AccountsHomeViewProtocol: AnyObject {
    func showAccounts(_ viewModels: [AccountViewModel], withSelected selected: AccountViewModel, cellHeight: CGFloat?)
    func showTransactions(for accountViewModel: AccountViewModel, transactions: [TransactionsGroupViewModel], filterViewModel: TransactionFilterViewModel?)
    func showTransactionError(_ error: String, for accountViewModel: AccountViewModel, filterViewModel: TransactionFilterViewModel?)
    func showTransactionLoadingIndicator()
    func dismissTransactionsLoadingIndicator()
    func showAccountDetail(for viewModel: AccountViewModel)
    func showAccountActions(_ viewModels: [AccountActionViewModel])
    func showLoadTransactionPrior90DaysView()
    func hideLoadTransactionPrior90DaysView()
    func showLoadingPaginator()
    func isSearchEnabled(_ enabled: Bool)
    func clearTransactionTable()
    func finishedCrossSellingForIndexPath(_ indexPath: IndexPath)
    func setOfferBannerForLocation(viewModel: OfferBannerViewModel?)
    func setTagsFiltersVisibility(isShown: Bool)
    func setAccountOfferCarousel(offers: [OfferCarouselViewModel])
    func reloadAccountOfferCarousel()
    func setDependenciesResolver(_ dependenciesResolver: DependenciesResolver)
    func showComingSoon()
}

final class AccountsHomeViewController: UIViewController {
    struct SectionIdentifiers {
        static let pending = "PendingSectionView"
        static let date = "DateSectionView"
    }
    private let accountsHeaderView = AccountsHeaderView()
    private let accountsCollapsedHeaderView = AccountsCollapsedHeaderView()
    private var transactions: [TransactionsGroupViewModel] = []
    private var filterViewModel: TransactionFilterViewModel?
    private var presenter: AccountsHomePresenterProtocol
    private var cellBuilder = AccountMovementCellBuilder()
    private var dependenciesResolver: DependenciesResolver!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var messageView: UIView!
    @IBOutlet var messageViewLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var loadingViewMessageLabel: UILabel!
    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet var paginationLoader: UIView! {
        didSet {
            self.paginationLoader.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    @IBOutlet var paginationImageLoader: UIImageView!
    @IBOutlet weak var movementAfter90DaysView: UIView!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMovementsPrior90DaysButton: WhiteLisboaButton!
    @IBOutlet weak var loadingViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTopConstraint: NSLayoutConstraint!
    var isSearchEnabled: Bool = false {
        didSet {
            setupNavigationBar()
        }
    }
    lazy var scrollManager: ProductHomeScrollManager<AccountsHeaderView, AccountsCollapsedHeaderView> = {
        return ProductHomeScrollManager(
            on: self.view,
            tableView: self.tableView,
            header: self.accountsHeaderView,
            collapsedHeader: self.accountsCollapsedHeaderView,
            configuration: ProductHomeScrollManager.Configuration(collapsedHeaderHeight: Constants.heightOfCollapsedHeader)
        )
    }()
    
    private var actionsHeaderView: AccountHeaderActionsView? {
        return self.accountsHeaderView.actionsHeaderView
    }
    
    private var tagsContainerView: TagsContainerView? {
        get {
            self.accountsHeaderView.tagsContainerView
        }
        set {
            self.accountsHeaderView.tagsContainerView = newValue
        }
    }
    
    private enum HeaderTopSpace: CGFloat {
        case small = 20.0
        case medium = 60.0
    }
    
    private enum Constants {
        static let heightForSection: CGFloat = 39
        static let heightOfCollapsedHeader: CGFloat = 49
        static let estimatedRowHeight: CGFloat = 150.0
    }
    private var tagsFiltersVisibility = false
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, presenter: AccountsHomePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccountHeaderView()
        self.setupView()
        self.setupTableView()
        self.presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBeingPresented || isMovingToParent { // View is being presented
            self.setupNavigationBar()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isBeingPresented && !isMovingToParent { // Returned from detail view
            self.setupNavigationBar()
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollManager.viewDidLayoutSubviews()
    }
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc internal func searchButtonPressed() {
        self.presenter.didSelectSearch()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        return .darkContent
    }
    
    private func paginateIfNeeded(for indexPath: IndexPath) {
        if presenter.isLoadMoreTransactionsAvailable &&
            indexPath.section == (tableView.numberOfSections - 1) {
            self.addPaginationLoader()
            self.presenter.loadMoreTransactions()
        }
    }
    
    @objc func didTapOnLoadMovementsAfter90Days() {
        self.presenter.loadTransactionPrior90Days()
    }
}

private extension AccountsHomeViewController {
    
    func setupView() {
        self.setupAccessibilityIds()
    }
    
    func setupTableView() {
        self.view.backgroundColor = .skyGray
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = Constants.estimatedRowHeight
        self.tableView.bounces = false
        self.tableView.backgroundColor = UIColor.white
        self.actionsHeaderView?.delegate = self
        self.registerHeaderAndFooters()
        self.registerCell()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnLoadMovementsAfter90Days))
        self.showMovementsPrior90DaysButton.addGestureRecognizer(tapGesture)
    }
    
    func registerCell() {
        let movementNib = UINib(nibName: AccountMovementCellBuilder.transactionCellIdentifier, bundle: .module)
        let billNib = UINib(nibName: AccountMovementCellBuilder.futureBillCellIdentifier, bundle: .module)
        let pendingNib = UINib(nibName: AccountMovementCellBuilder.pendingCellIdentifier, bundle: .module)
        let emptyTableNib = UINib(nibName: "MessageTableViewCell", bundle: Bundle.module)
        self.tableView.register(movementNib, forCellReuseIdentifier: AccountMovementCellBuilder.transactionCellIdentifier)
        self.tableView.register(billNib, forCellReuseIdentifier: AccountMovementCellBuilder.futureBillCellIdentifier)
        self.tableView.register(pendingNib, forCellReuseIdentifier: AccountMovementCellBuilder.pendingCellIdentifier)
        self.tableView.register(emptyTableNib, forCellReuseIdentifier: "MessageTableViewCell")
    }
    
    func registerHeaderAndFooters() {
        let nib = UINib(nibName: SectionIdentifiers.date, bundle: Bundle.uiModule)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: SectionIdentifiers.date)
        self.tableView.register(PendingSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SectionIdentifiers.pending)
    }
    
    private func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .tooltip(
                titleKey: "toolbar_title_accounts",
                type: .red,
                action: { [weak self] sender in
                    self?.showGeneralTooltip(sender)
                }
            )
        )
        builder.setLeftAction(.back(action: #selector(dismissViewController)))
        builder.setRightActions(.menu(action: #selector(openMenu)))
        builder.build(on: self, with: self.presenter)
    }
    
    func showGeneralTooltip(_ sender: UIView) {
        let navigationToolTip = NavigationToolTip()
        navigationToolTip.add(title: localized("accountsTooltip_title_accounts"))
        navigationToolTip.add(description: localized("accountsTooltip_text_viewAccountsSection"))
        navigationToolTip.show(in: self, from: sender)
        UIAccessibility.post(notification: .announcement, argument: localized("accountsTooltip_text_viewAccountsSection").text)
    }
    
    func addPaginationLoader() {
        self.paginationImageLoader.setPointsLoader()
        self.tableView.tableFooterView = paginationLoader
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func removePaginationLoader() {
        self.paginationImageLoader.removeLoader()
    }
    
    func setupAccountHeaderView() {
        self.accountsHeaderView.backgroundColor = UIColor.skyGray
        self.accountsHeaderView.delegate = self
        self.accountsHeaderView.dependenciesResolver = self.dependenciesResolver
        self.accountsCollapsedHeaderView.delegate = self
        if self.presenter.isPDFButtonHidden {
            self.accountsHeaderView.hidePDFButton()
        }
    }
    
    func addNotResultMessage(_ message: String) {
        self.centerMessgeViewLabel()
        let emptyView = SingleEmptyView()
        emptyView.updateTitle(localized(message))
        emptyView.titleFont(UIFont.santander(family: .text,
                                             type: .italic,
                                             size: 16.0))
        messageView.addSubview(emptyView)
        emptyView.fullFit()
        self.tableView.tableHeaderView?.addSubview(messageView)
        self.actionsHeaderView?.togglePdfDownload(toHidden: true)
    }
    
    func centerMessgeViewLabel() {
        if Screen.isIphone5 {
            self.messageTopConstraint.constant = 50
        } else {
            self.messageTopConstraint.constant = 100
        }
    }
    
    func addAnimatedLoadingView() {
        guard let tableHeaderView = tableView.tableHeaderView else { return }
        self.loadingViewTopConstraint.constant = self.getTopSpaceForHeaderConstraint()
        self.loadingViewMessageLabel.text = localized("loading_label_transactionsLoading")
        self.loadingImage.setPointsLoader()
        self.loadingImage.startAnimating()
        tableHeaderView.addSubview(loadingView)
    }
    
    func getTopSpaceForHeaderConstraint() -> CGFloat {
        if Screen.isIphone5 {
            return HeaderTopSpace.small.rawValue
        } else {
            return HeaderTopSpace.medium.rawValue
        }
    }
    
    func removeNotResultMessage() {
        self.messageView.removeFromSuperview()
    }
    
    func setTagsOnHeader() {
        self.tagsContainerView?.removeFromSuperview()
        guard let tagsMetadata = self.filterViewModel?.buildTags() else { return }
        self.accountsHeaderView.addTagContainer(withTags: tagsMetadata, delegate: self)
        self.tableView.updateHeaderViewFrame()
    }
    
    func removeAnimatedLoadingView() {
        self.loadingImage.stopAnimating()
        self.loadingView.removeFromSuperview()
    }
    
    func createMoreTransactionsView() -> UIView {
        let moreView = MoreMovementsView(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 74.0))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnLoadMovementsAfter90Days))
        moreView.showMovementsButton.addGestureRecognizer(tapGesture)
        return moreView
    }
    
    func removeTagsContainer() {
        self.tagsContainerView?.removeFromSuperview()
        self.tagsContainerView = nil
        self.tableView.updateHeaderViewFrame()
    }
}

extension AccountsHomeViewController: AccountsHomeViewProtocol {
    func finishedCrossSellingForIndexPath(_ indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func showAccounts(_ viewModels: [AccountViewModel], withSelected selected: AccountViewModel, cellHeight: CGFloat?) {
        self.accountsHeaderView.updateAccountsViewModels(viewModels,
                                                         selecteViewModel: selected,
                                                         height: cellHeight)
    }
    
    func showTransactions(for accountViewModel: AccountViewModel,
                          transactions: [TransactionsGroupViewModel],
                          filterViewModel: TransactionFilterViewModel?) {
        self.actionsHeaderView?.togglePdfDownload(toHidden: false)
        self.transactions = transactions
        self.filterViewModel = filterViewModel
        self.removeNotResultMessage()
        if filterViewModel != nil && self.tagsFiltersVisibility {
            self.setTagsOnHeader()
        } else {
            self.removeTagsContainer()
        }
        self.tableView.reloadData()
    }
    
    func showAccountDetail(for viewModel: AccountViewModel) {
        self.accountsHeaderView.updateAccountViewModel(viewModel)
    }
    
    func showAccountActions(_ viewModels: [AccountActionViewModel]) {
        self.accountsHeaderView.setAccountActions(viewModels)
        self.accountsHeaderView.hidePlusButton(self.presenter.isPlusButtonHidden || viewModels.isEmpty)
    }
    
    func showTransactionError(_ error: String, for accountViewModel: AccountViewModel, filterViewModel: TransactionFilterViewModel?) {
        self.actionsHeaderView?.togglePdfDownload(toHidden: true)
        self.filterViewModel = filterViewModel
        if filterViewModel != nil {
             self.setTagsOnHeader()
         }
        self.addNotResultMessage(error)
    }
    
    func showTransactionLoadingIndicator() {
        self.removeNotResultMessage()
        self.addAnimatedLoadingView()
    }
    
    func dismissTransactionsLoadingIndicator() {
        self.removePaginationLoader()
        self.removeAnimatedLoadingView()
        self.view.setNeedsLayout()
    }
    
    func showLoadTransactionPrior90DaysView() {
        if self.tableView.numberOfSections > 0 {
            self.tableView.tableFooterView = createMoreTransactionsView()
        } else {
            self.tableBottomConstraint.constant = movementAfter90DaysView.frame.height - 1
            self.movementAfter90DaysView.isHidden = false
        }
    }
    
    func hideLoadTransactionPrior90DaysView() {
        self.tableView.tableFooterView = nil
        self.tableBottomConstraint.constant = 0
        self.movementAfter90DaysView.isHidden = true
    }
    
    func showLoadingPaginator() {
        self.addPaginationLoader()
        guard let footerView = self.tableView.tableFooterView else { return }
        self.tableView.scrollRectToVisible(footerView.frame, animated: true)
    }
    
    func setOfferBannerForLocation(viewModel: OfferBannerViewModel?) {
        self.accountsHeaderView.setOfferBannerForLocation(viewModel: viewModel)
    }
    
    func setTagsFiltersVisibility(isShown: Bool) {
        self.tagsFiltersVisibility = isShown
    }
    
    func setAccountOfferCarousel(offers: [OfferCarouselViewModel]) {
        self.accountsHeaderView.setAccountOfferCarouselViewDelegate(self)
        self.accountsHeaderView.dependenciesResolver = self.dependenciesResolver
        self.accountsHeaderView.setAccountOfferCarousel(offers: offers)
    }
    
    func reloadAccountOfferCarousel() {
        self.accountsHeaderView.reloadAccountOfferCarousel()
    }
    
    func setDependenciesResolver(_ dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func showComingSoon() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
}

extension AccountsHomeViewController: TagsContainerViewDelegate {
    
    func didRemoveFilter(_ remaining: [TagMetaData]) {
        guard remaining.count > 0 else {
            self.filterViewModel = nil
            self.presenter.removeFilter(filter: nil)
            self.removeTagsContainer()
            return
        }
        let toBeRemoved = self.filterViewModel?.activeFilter(remainings: remaining)
        if toBeRemoved != nil {
            self.presenter.removeFilter(filter: toBeRemoved)
        }
    }
}

extension AccountsHomeViewController: AccountHeaderActionsViewDelegate {

    func didTapOnMoreOptions() {
        self.presenter.didTapOnMoreOptions()
    }
    
    func didTapOnFilterMovements() {
        self.presenter.showFiltersSelected()
    }
    
    func didTapOnDownloadMovements() {
        self.presenter.downloadTransactionsSelected()
    }
}

extension AccountsHomeViewController: AccountsHeaderViewDelegate {
    
    func didSelectAccountViewModel(_ viewModel: AccountViewModel) {
        self.accountsCollapsedHeaderView.updateAccountViewModel(viewModel)
        self.presenter.setSelectedAccountViewModel(viewModel)
        self.clearTransactionTable()
        self.presenter.accountTransactions(for: viewModel)
        self.presenter.accountDetail(for: viewModel)
        self.presenter.didTrackedSwipe()
    }
    
    func clearTransactionTable() {
        self.transactions = []
        self.tableView.reloadData()
    }
    
    func didTapOnShareViewModel(_ viewModel: AccountViewModel) {
        self.presenter.didTapOnShareViewModel(viewModel)
    }
    
    func didTapOnWithHolding(_ viewModel: AccountViewModel) {
        self.presenter.didTapOnWithHolding(viewModel)
    }
    
    func didBeginScrolling() {
        self.tableView.isScrollEnabled = false
    }
    
    func didEndScrolling() {
        self.tableView.isScrollEnabled = true
    }
    
    func didEndScrollingSelectedItem() {
        self.tableView.isScrollEnabled = true
    }
    
    func didSelectBanner(_ viewModel: OfferBannerViewModel?) {
        self.presenter.didSelectedOffer(viewModel)
    }
    
    func headerLayoutSubviews() {
        guard self.loadingView.frame.origin.y != self.accountsHeaderView.frame.maxY else { return }
        self.messageView.frame.size.width = self.view.bounds.width
        self.messageView.frame.origin.y = self.accountsHeaderView.frame.maxY
        self.loadingView.frame.origin.y = self.accountsHeaderView.frame.maxY
        self.loadingView.frame.size.width = self.view.bounds.width
    }
    
    func updateHeaderViewFrame() {
        self.tableView.updateHeaderViewFrame()
        guard self.loadingView.frame.origin.y != self.accountsHeaderView.frame.maxY else { return }
        guard let tableHeaderView = tableView.tableHeaderView else { return }
        self.loadingView.frame = tableHeaderView.frame
        self.messageView.frame = tableHeaderView.frame
    }
}

extension AccountsHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.removeUnnecessaryHeaderTopPadding()
        if self.presenter.isTransactionEntryAvailable && section == .zero {
            let pendingView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionIdentifiers.pending)
            return pendingView
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionIdentifiers.date) as? DateSectionView
            let isFilterEnabled = self.filterViewModel != nil && tagsFiltersVisibility
            let transaction = self.transactions[section].setDateFormatterFiltered(isFilterEnabled)
            header?.configure(withDate: transaction)
            section == .zero ? header?.toggleHorizontalLine(toVisible: false) : header?.toggleHorizontalLine(toVisible: true)
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightForSection
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = self.transactions[indexPath.section].transactions[indexPath.row]
        self.presenter.didSelectTransaction(transaction)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AccountMovementsTableViewCell {
            cell.setupHighlightBackgroundColor(UIColor.bg)
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AccountMovementsTableViewCell {
            cell.setupHighlightBackgroundColor(UIColor.white)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollManager.scrollViewDidScroll(scrollView)
        self.accountsHeaderView.detectTopOfferCarouselScrolled(scrollView)
        let margins: CGFloat = 10
        let headerHeight = floor(accountsHeaderView.frame.size.height - margins)
        switch scrollView.contentOffset.y {
        case 0...headerHeight:
            self.accountsCollapsedHeaderView.hideFilter()
        default:
            self.accountsCollapsedHeaderView.showFilter()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollManager.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollManager.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}

extension AccountsHomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        defer { paginateIfNeeded(for: indexPath) }
        let viewModel = self.transactions[indexPath.section].transactions[indexPath.row]
        let cell = self.cellBuilder.cell(for: tableView, at: indexPath, and: viewModel)
        cell?.mustHideDiscontinueLine(isLastCellForSectionIndexPath(indexPath))
        cell?.configure(withViewModel: viewModel)
        if let cell = cell as? AccountMovementsTableViewCell {
            cell.delegate = self
        }
        if let cell = cell as? CrossSellingTransactionTableViewCell {
            let crossSellingViewModel = presenter.crossSellingViewModel(transaction: viewModel)
            cell.configure(viewModel: crossSellingViewModel, indexPath: indexPath)
        }
        return cell ?? UITableViewCell()
    }
    
    private func isLastCellForSectionIndexPath(_ indexPath: IndexPath) -> Bool {
        let lastIndexInSection = self.transactions[indexPath.section].transactions.endIndex - 1
        return lastIndexInSection == indexPath.row
    }
}

extension AccountsHomeViewController: RootMenuController {
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension AccountsHomeViewController: NavigationBarWithSearchProtocol {
    public var searchButtonPosition: Int { return 1 }
    public func isSearchEnabled(_ enabled: Bool) { isSearchEnabled = enabled }
}

extension AccountsHomeViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return .myProducts
    }
}

extension AccountsHomeViewController: AccountsCollapsedHeaderViewDelegate {
    func didTapInFilterButton() {
        self.presenter.showFiltersSelected()
    }
}

extension AccountsHomeViewController: AccountMovementsTableViewCellDelegate {
    func didUpdateCrossSellingOfferImageWithHeight(_ height: CGFloat, atCell cell: AccountMovementsTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell), let transactionViewModel = transactionViewModelRepresentingCell(cell) else {
            return
        }
        presenter.updateCrossSellingVieModel(transactionViewModel, withOfferHeight: height)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func gotoTransactionForViewModel(_ viewModel: CrossSellingViewModel) {
        self.presenter.didSelectTransaction(viewModel.transactionViewModel)
    }

    func didTapLoadOfferOnCell(_ viewModel: CrossSellingViewModel, indexPath: IndexPath) {
        self.presenter.loadCandidatesOffersForViewModel(viewModel, indexPath: indexPath)
    }
}

private extension AccountsHomeViewController {
    func transactionViewModelRepresentingCell(_ cell: AccountMovementsTableViewCell) -> TransactionViewModel? {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return nil
        }
        return self.transactions[indexPath.section].transactions[indexPath.row]
    }
    
    func setupAccessibilityIds() {
        self.tableView.accessibilityIdentifier = AccessibilityAccountsHome.accountsHomeListTransactions
    }
}

extension AccountsHomeViewController: AccountOfferCarouselViewDelegate {
    func didSelectPregrantedBanner(_ offer: ExpirableOfferEntity?) {
        self.presenter.didSelectedOffer(offer)
    }
    
    func didSelectPullOffer(_ info: ExpirableOfferEntity) {
        self.presenter.didSelectedOffer(info)
    }
    
    func hideCarousel() {
        self.accountsHeaderView.hideCarousel()
    }

}
