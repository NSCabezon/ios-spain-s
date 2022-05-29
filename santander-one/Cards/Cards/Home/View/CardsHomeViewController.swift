//
//  CardsHomeViewController.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/22/19.
//

import UIKit
import UI
import CoreFoundationLib
import CoreDomain

protocol CardsHomeViewProtocol: AnyObject {
    func showCards(_ viewModels: [CardViewModel], withSelected selected: CardViewModel)
    func showTransactions(transactions: [CardTransactionsGroupViewModel], cardFilterViewModel: TransactionFilterViewModel?)
    func showCardActions(cardViewModel: CardViewModel, actionViewModels: [CardActionViewModel], isHideCardsAccessButtons: Bool)
    func updateCard(_ viewModel: CardViewModel)
    func showTransactionError(_ error: String, cardFilterViewModel: TransactionFilterViewModel?)
    func showTransactionLoadingIndicator()
    func dismissTransactionsLoadingIndicator()
    func showApplePaySuccessView()
    func isSearchEnabled(_ enabled: Bool)
    func clearTransactionTable()
    func showNotAvailable()
    func didRemoveFilter(_ remaining: [TagMetaData])
    func setPaymentMethod(_ description: LocalizedStylableText)
    func closeTooltip(_ completion: @escaping () -> Void)
    func setPendingTransactionOptions(hidden: Bool)
    func hideMoreOptionsButton(_ hide: Bool)
}

public class CardsHomeViewController: UIViewController {
    
    private let cellIdentifier = "CardMovementsTableViewCell"
    private let sectionIdentifier = "DateSectionView"
    private let presenter: CardsHomePresenterProtocol
    private var transactions: [CardTransactionsGroupViewModel] = []
    private lazy var applePaySuccessView: ApplePaySuccessView = {
        return ApplePaySuccessView()
    }()
    private var filterViewModel: TransactionFilterViewModel?
    @IBOutlet var messageView: UIView!
    @IBOutlet var messageViewLabel: UILabel!
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingViewMessageLabel: UILabel!
    @IBOutlet weak var loadingImage: UIImageView!
    private let cardsHeaderView = CardsHeaderView()
    private let cardsCollapsedHeaderView = CardsCollapsedHeaderView()
    private weak var tooltipViewController: UIViewController?
    private var tableViewFooter = PageLoadingView()
    private var isFooterViewVisible = false
    private var lineToTableFooterView: DateSectionView?
    lazy var scrollManager: ProductHomeScrollManager<CardsHeaderView, CardsCollapsedHeaderView> = {
        return ProductHomeScrollManager(
            on: self.view,
            tableView: self.tableView,
            header: self.cardsHeaderView,
            collapsedHeader: self.cardsCollapsedHeaderView,
            configuration: ProductHomeScrollManager.Configuration(collapsedHeaderHeight: Constants.heightOfCollapsedHeader)
        )
    }()
    private var cardsTableViewHeader: CardHeaderActionsView? {
        return self.cardsHeaderView.actionsHeaderView
    }
    
    private var tagsContainerView: TagsContainerView? {
        get {
            self.cardsHeaderView.tagsContainerView
        }
        set {
            self.cardsHeaderView.tagsContainerView = newValue
        }
    }
    
    var contentScrollSize: CGFloat {
        let minimumScrollSize = self.tableView.frame.size.height + self.cardsHeaderView.frame.size.height
        guard self.tableView.contentSize.height < minimumScrollSize else { return self.tableView.contentSize.height }
        return minimumScrollSize
    }
    
    public var isSearchEnabled: Bool = false {
        didSet {
            setupNavigationBar()
        }
    }
    
    private enum Constants {
        static let heightForSection: CGFloat = 39
        static let heightOfCollapsedHeader: CGFloat = 57
    }
    
    private let dependencies: DependenciesResolver
    
    init(nibName nibNameOrNil: String?, 
         bundle nibBundleOrNil: Bundle?,
         presenter: CardsHomePresenterProtocol, 
         dependenciesResolver: DependenciesResolver
    ) {
        self.presenter = presenter
        self.dependencies = dependenciesResolver
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCardsHeaderView()
        self.setupTableView()
        self.view.backgroundColor = .skyGray
        self.presenter.viewDidLoad()
        self.lineToTableFooterView = self.lastLineToTableFooterView()
    }
        
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMovingToParent { // View is being presented
            self.setupNavigationBar()
        }
        self.cardsTableViewHeader?.togglePdfDownload(toHidden: true)
        self.presenter.viewWillAppear()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isBeingPresented && !isMovingToParent { // Returned from detail view
            self.setupNavigationBar()
        }
    }

    private func setupCardsHeaderView() {
        self.cardsHeaderView.delegate = self
    }
    
    public override func viewDidLayoutSubviews() {
        self.messageView.frame.size.width = self.view.bounds.width
        self.messageView.frame.origin.y = self.cardsHeaderView.frame.maxY
        self.loadingView.frame.origin.y = self.cardsHeaderView.frame.maxY
        self.loadingView.frame.size.width = self.view.bounds.width
        self.scrollManager.viewDidLayoutSubviews()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        guard #available(iOS 13.0, *) else { return .default }
        return .darkContent
    }
    
    @objc private func openMenu() {
        self.presenter.didSelectMenu()
    }
    
    @objc private func dismissViewController() {
        self.presenter.didSelectDismiss()
    }
}

private extension CardsHomeViewController {
    
    func setupTableView() {
        self.tableView.bounces = false
        self.cardsCollapsedHeaderView.alpha = 0.0
        self.cardsCollapsedHeaderView.delegate = self
        self.cardsTableViewHeader?.delegate = self
        self.registerHeaderAndFooters()
        self.registerCell()
    }
    
    func registerCell() {
        let nib = UINib(nibName: cellIdentifier, bundle: Bundle.module)
        self.tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        let emptyTable = UINib(nibName: "MessageTableViewCell", bundle: Bundle.module)
        self.tableView.register(emptyTable, forCellReuseIdentifier: "MessageTableViewCell")
    }
    
    func registerHeaderAndFooters() {
        let nib = UINib(nibName: sectionIdentifier, bundle: Bundle.uiModule)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: sectionIdentifier)
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .tooltip(
                titleKey: "toolbar_title_cards",
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
    
    func getTooltipText(text: String, identifier: String = "", font: UIFont, separator: CGFloat) -> FullScreenToolTipViewItemData {
        let configuration = LabelTooltipViewConfiguration(text: localized(text), left: 18, right: 18, font: font, textColor: .lisboaGray)
        let view = LabelTooltipView(configuration: configuration)
        view.setLabelIdentifier("cardsTooltip_\(identifier)")
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: separator)
        return item
    }
    
    func getTooltipItem(text: String, image: String) -> FullScreenToolTipViewItemData {
        let configuration = ItemTooltipViewConfiguration(image: Assets.image(named: image), text: localized(text))
        let view = ItemTooltipView(configuration: configuration)
        let item = FullScreenToolTipViewItemData(view: view, bottomMargin: 8)
        return item
    }
    
    func showGeneralTooltip(_ sender: UIView) {
        let titleView = getTooltipText(text: "cardsTooltip_title_cards", identifier: "title", font: UIFont.santander(family: .text, type: .bold, size: 20), separator: 8)
        let videoView = FullScreenToolTipViewItemData(view: VideoTooltipView(imageName: "imgVideoCards", action: { [weak self] in
            self?.presenter.didTooltipVideoAction()
        }), bottomMargin: 11)
        let stickyItems: [FullScreenToolTipViewItemData] = [titleView]
        var scrolledItems: [FullScreenToolTipViewItemData] = self.getSrolledItems() 
        if self.presenter.isVideoOffer {
            scrolledItems.insert(videoView, at: 0)
        }
        let configuration = FullScreenToolTipViewData(topMargin: 0, stickyItems: stickyItems, scrolledItems: scrolledItems)
        tooltipViewController = configuration.show(in: self, from: sender)
        self.presenter.toolTipTrack()
    }
    
    func addNotResultMessage(_ message: String) {
        guard let tableHeaderView = tableView.tableHeaderView else { return }
        self.messageView.frame.origin.y = tableHeaderView.frame.maxY
        self.messageView.frame.size.width = tableHeaderView.frame.size.width
        let emptyView = SingleEmptyView()
        emptyView.updateTitle(localized(message))
        emptyView.titleFont(UIFont.santander(family: .headline, type: .regular, size: 18))
        messageView.addSubview(emptyView)
        emptyView.fullFit()
        tableHeaderView.addSubview(messageView)
        self.view.setNeedsLayout()
    }
    
    func addAnimatedLoadingView() {
        guard let tableHeaderView = tableView.tableHeaderView else { return }
        self.loadingView.frame.origin.y = tableHeaderView.frame.maxY
        self.loadingView.frame.size.width = tableHeaderView.bounds.width
        self.loadingViewMessageLabel.text = localized("loading_label_transactionsLoading")
        self.loadingImage.setPointsLoader()
        tableHeaderView.addSubview(loadingView)
    }
    
    func removeNotResultMessage() {
        self.messageView.removeFromSuperview()
    }
    
    func removeAnimatedLoadingView() {
        self.loadingImage.removeLoader()
        self.loadingView.removeFromSuperview()
    }
    
    func setTagsOnHeader() {
        self.tagsContainerView?.removeFromSuperview()
        guard let tagsMetadata = self.filterViewModel?.buildTags() else { return }
        self.cardsHeaderView.addTagContainer(withTags: tagsMetadata, delegate: self)
        self.tableView.updateHeaderViewFrame()
    }
    
    func removeTagsContainer() {
        self.tagsContainerView?.removeFromSuperview()
        self.tagsContainerView = nil
        self.tableView.updateHeaderViewFrame()
    }
    
    func toggleFilterInHeaderView(_ scrollView: UIScrollView) {
        let margins: CGFloat = 10
        let headerHeight = floor(cardsHeaderView.frame.size.height - margins)
        switch scrollView.contentOffset.y {
        case 0...headerHeight:
            self.cardsCollapsedHeaderView.hideFilter()
        default:
            self.cardsCollapsedHeaderView.showFilter()
        }
    }
    
    func getSrolledItems() -> [FullScreenToolTipViewItemData] {
        var scrolledItems: [FullScreenToolTipViewItemData] = []
        scrolledItems.append(
            getTooltipText(text: "cardsTooltip_text_viewWithholding",
                           identifier: "viewWithholding",
                           font: UIFont.santander(family: .text, type: .light, size: 16),
                           separator: 19))
        scrolledItems.append(
            getTooltipText(text: "cardsTooltip_title_andAlso",
                           identifier: "andAlso",
                           font: UIFont.santander(family: .text, type: .bold, size: 18),
                           separator: 8))
        let tooltipOption = self.getOptions()
        for option in tooltipOption {
            scrolledItems.append(
                getTooltipItem(text: option.textKey, image: option.iconKey)
            )
        }
        return scrolledItems
    }
    
    func defaultScrolledItems() -> [CustomOptionWithTooltipCarsdHome] {
        return [CustomOptionWithTooltipCarsdHome(text: "cardsTooltip_text_access", icon: "icnThunder"),
                CustomOptionWithTooltipCarsdHome(text: "cardsTooltip_text_viewCards", icon: "icnReceipt"),
                CustomOptionWithTooltipCarsdHome(text: "cardsTooltip_text_mapShopping", icon: "icnSimpleTouchPoint"),
                CustomOptionWithTooltipCarsdHome(text: "cardsTooltip_text_mobilePaymentConfig", icon: "icnMobilePayment")]
    }
}

private extension CardsHomeViewController {
    func getOptions() -> [CustomOptionWithTooltipCarsdHome] {
        if let cardsHomeTooltipOptions: CardHomeTooltipProtocol = self.dependencies.resolve(forOptionalType: CardHomeTooltipProtocol.self) {
            return cardsHomeTooltipOptions.getOptions()
        }
        return defaultScrolledItems()
    }
    
    func lastLineToTableFooterView() -> DateSectionView {
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifier) as? DateSectionView else {
            return DateSectionView()
        }
        footer.addTableViewFooter(toVisible: true)
        return footer
    }
    
    func showTableViewFooter() {
        if self.isFooterViewVisible {
            self.tableView.tableFooterView = self.lineToTableFooterView
            self.isFooterViewVisible = false
        }
    }
    
    func setTableFooterView (_ row: Int, _ section: Int) {
        if (section == self.transactions.count - 1) && (row == self.transactions[section].transactions.count - 1) {
            self.isFooterViewVisible = true
        }
    }
}

extension CardsHomeViewController: CardsHomeViewProtocol {

    func showNotAvailable() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func showCards(_ viewModels: [CardViewModel], withSelected selected: CardViewModel) {
        self.cardsHeaderView.updateCardsViewModels(viewModels, selectedViewModel: selected)
    }
    
    private func updateTableViewHeaderBasedOn(_ cardFilterViewModel: TransactionFilterViewModel?) {
        self.filterViewModel = cardFilterViewModel
        if filterViewModel != nil {
            self.setTagsOnHeader()
        } else {
            self.removeTagsContainer()
        }
        self.tableView.reloadData()
    }
    
    func showTransactions(transactions: [CardTransactionsGroupViewModel], cardFilterViewModel: TransactionFilterViewModel?) {
        self.transactions = transactions
        self.removeNotResultMessage()
        updateTableViewHeaderBasedOn(cardFilterViewModel)
    }
    
    func showCardActions(cardViewModel: CardViewModel, actionViewModels: [CardActionViewModel], isHideCardsAccessButtons: Bool) {
        self.cardsHeaderView.setCardActions(actionViewModels)
        self.cardsHeaderView.addInformationButtonsForViewModel(cardViewModel, hideCardsButtons: isHideCardsAccessButtons)
    }
    
    func showTransactionError(_ error: String, cardFilterViewModel: TransactionFilterViewModel?) {
        self.addNotResultMessage(error)
        self.filterViewModel = cardFilterViewModel
        updateTableViewHeaderBasedOn(cardFilterViewModel)
    }
    
    func showTransactionLoadingIndicator() {
        self.removeNotResultMessage()
        self.addAnimatedLoadingView()
    }
    
    func dismissTransactionsLoadingIndicator() {
        self.removeAnimatedLoadingView()
        self.hidePageLoading()
        self.view.setNeedsLayout()
    }
    
    func hidePageLoading() {
        self.tableViewFooter.stopLoading()
        self.showTableViewFooter()
    }
    
    func updateCard(_ viewModel: CardViewModel) {
        self.cardsHeaderView.updateCardViewModel(viewModel)
    }
    
    func showApplePaySuccessView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        self.applePaySuccessView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(self.applePaySuccessView)
        self.applePaySuccessView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
        self.applePaySuccessView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
        self.applePaySuccessView.leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true
        self.applePaySuccessView.rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true
    }
    
    func setPaymentMethod(_ description: LocalizedStylableText) {
        cardsHeaderView.setPaymentMethod(description)
    }
    
    func closeTooltip(_ completion: @escaping () -> Void) {
        tooltipViewController?.dismiss(animated: true, completion: completion)
    }
    
    func setPendingTransactionOptions(hidden: Bool) {
        self.cardsTableViewHeader?.setPendingMovement(hidden: hidden)
    }
    
    func hideMoreOptionsButton(_ hide: Bool) {
        if hide {
            self.cardsTableViewHeader?.hidePlushButton()
        } else {
            self.cardsTableViewHeader?.showPlusButton()
        }
    }
}

extension CardsHomeViewController: CardsHeaderViewDelegate {
    
    func isPANAlwaysSharable() -> Bool {
        return self.presenter.isPANAlwaysSharable()
    }
    
    func didSelectMap() {
        self.presenter.didSelectMap()
    }
    
    func setHeightForNormalContent() {
        self.tableView.updateHeaderViewFrame()
    }
    
    func setHeightForFullContent() {
        self.tableView.updateHeaderViewFrame()
    }
    
    func didSelectCardViewModel(_ viewModel: CardViewModel) {
        self.cardsCollapsedHeaderView.updateCardViewModel(viewModel)
        self.presenter.setSelectedCardViewModel(viewModel)
        self.clearTransactionTable()
        self.presenter.cardTransactions(for: viewModel)
        self.presenter.cardActions(for: viewModel)
    }
    
    public func clearTransactionTable() {
        self.tableView.tableFooterView = nil
        self.transactions = []
        self.tableView.reloadData()
    }
    
    func didTapOnShareViewModel(_ viewModel: CardViewModel) {
        self.presenter.didTapOnShareViewModel(viewModel)
    }
    
    func didSelectInformationButton(_ viewModel: CardViewModel, button: CardInformationButton) {
        self.presenter.didSelectInformationCardButton(for: viewModel, button: button)
    }
    
    func didTapOnCVVViewModel(_ viewModel: CardViewModel) {
        self.presenter.didTapOnCVVViewModel(viewModel)
    }
    func didTapOnActivateCard(_ viewModel: CardViewModel) {
        self.presenter.didTapOnActivateCard(viewModel)
    }
    
    func didTapOnShowPAN(_ viewModel: CardViewModel) {
        self.presenter.didTapOnShowPAN(viewModel)
    }
}

extension CardsHomeViewController: CardHeaderActionsViewDelegate {
    func didTapOnMoreOptions() {
        self.presenter.didTapOnMoreOptions()
    }
    
    func didTapOnFilterMovements() {
        self.presenter.showFiltersSelected()
    }
    
    func didTapOnDownloadMovements() {
        self.presenter.downloadTransactionsSelected()
    }
    
    func didSelectPendingMovement() {
        if let cardHomeDelegate = self.dependencies.resolve(forOptionalType: CardHomeModifierProtocol.self) {
            cardHomeDelegate.didSelectCardPendingTransactions()
        } else {
            self.cardsTableViewHeader?.setPendingMovement(hidden: true)
            self.clearTransactionTable()
            self.presenter.cardPendingTransactions()
        }
    }
}

extension CardsHomeViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionIdentifier) as? DateSectionView
        let isFilterEnabled = self.filterViewModel != nil
        let transaction = self.transactions[section].setDateFormatterFiltered(isFilterEnabled)
        header?.configure(withDate: transaction)
        section == 0 ? header?.toggleHorizontalLine(toVisible: false) : header?.toggleHorizontalLine(toVisible: true)
        tableView.removeUnnecessaryHeaderTopPadding()
        return header
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.heightForSection
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = self.transactions[indexPath.section].transactions[indexPath.row]
        self.presenter.didSelectTransaction(transaction)
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CardMovementsTableViewCell {
            cell.setupHighlightBackgroundColor(UIColor.prominentSanGray)
        }
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CardMovementsTableViewCell {
            cell.setupHighlightBackgroundColor(UIColor.white)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollManager.scrollViewDidScroll(scrollView)
        self.toggleFilterInHeaderView(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollManager.scrollViewDidEndDecelerating(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollManager.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
}

extension CardsHomeViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.transactions.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactions[section].transactions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.setTableFooterView(indexPath.row, indexPath.section)
        defer { paginateIfNeeded(for: indexPath) }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CardMovementsTableViewCell else {
                    return UITableViewCell()
                }
        cell.setupDiscontinueViewVisilibity(isLastCellForSectionIndexPath(indexPath))
        let viewModel = self.transactions[indexPath.section].transactions[indexPath.row]
        cell.configure(withViewModel: viewModel, index: indexPath)
        cell.delegate = self
        return cell
    }
    
    private func isLastCellForSectionIndexPath(_ indexPath: IndexPath) -> Bool {
        let lastIndexInSection = self.transactions[indexPath.section].transactions.endIndex - 1
        return lastIndexInSection == indexPath.row
    }
    
    private func paginateIfNeeded(for indexPath: IndexPath) {
        guard indexPath.section == (tableView.numberOfSections - 1) else { return }
        self.addPaginationLoader()
        self.presenter.loadMoreTransactions()
    }
    
    private func addPaginationLoader() {
        let size = CGSize(width: tableView.bounds.width, height: 68)
        let frame = CGRect(origin: .zero, size: size)
        self.tableViewFooter.frame = frame
        self.tableViewFooter.startLoading()
        self.tableView.tableFooterView = tableViewFooter
    }
}

extension CardsHomeViewController: RootMenuController {
    public var isSideMenuAvailable: Bool {
        return true
    }
}

extension CardsHomeViewController: NavigationBarWithSearchProtocol {
    public func searchButtonPressed() {
        self.presenter.doSearch()
    }
    public var searchButtonPosition: Int {
        return 1
    }
    public func isSearchEnabled(_ enabled: Bool) {
        self.isSearchEnabled = enabled
    }
}

extension CardsHomeViewController: TagsContainerViewDelegate {
    public func didRemoveFilter(_ remaining: [TagMetaData]) {
        self.presenter.didFilterRemove()
        self.removeFilters(with: remaining)
    }
    
    func removeFilters(with remaining: [TagMetaData]) {
        guard remaining.count > 0 else {
            self.filterViewModel = nil
            self.presenter.removeFilter(filter: nil)
            self.removeTagsContainer()
            return
        }
        
        // find wich filter will be removed
        for key in remaining {
            if key.identifier == TagMetaData.deleteTagMetaIdentifier {
                continue
            }
            let toBeRemoved = self.filterViewModel?.activeFilter(from: key, remainings: remaining)
            if toBeRemoved != nil {
                self.presenter.removeFilter(filter: toBeRemoved)
                break
            } else {
                continue
            }
        }
    }
}

extension CardsHomeViewController: HighlightedMenuProtocol {
    public func getOption() -> PrivateMenuOptions? {
        return .myProducts
    }
}

extension CardsHomeViewController: CardsCollapsedHeaderViewDelegate {
    func didTapInFilterButton() {
        presenter.showFiltersSelected()
    }
}

extension CardsHomeViewController: ApplePayOperativeViewLauncher {}

extension CardsHomeViewController: CardMovementsTableViewCellDelegate {
    func didTapLoadOfferOnCell(atIndexPath indexPath: IndexPath) {
        let transaction = self.transactions[indexPath.section]
            .transactions[indexPath.row]
        self.presenter.loadCandidatesOffersForViewModel(transaction)
    }
}
