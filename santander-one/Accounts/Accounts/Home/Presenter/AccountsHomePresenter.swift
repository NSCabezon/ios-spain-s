import CoreFoundationLib
import UI
import OfferCarousel
import CoreDomain

protocol AccountsHomePresenterProtocol: OtpScaAccountPresenterDelegate, AccountTransactionsSearchDelegate, MenuTextWrapperProtocol {
    var view: AccountsHomeViewProtocol? { get set }
    var isLoadMoreTransactionsAvailable: Bool { get }
    var allowTransactionsPrior90Days: Bool { get }
    var isPDFButtonHidden: Bool { get }
    var isTransactionEntryAvailable: Bool { get }
    var isPlusButtonHidden: Bool { get }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func setSelectedAccountViewModel(_ viewModel: AccountViewModel)
    func accountTransactions(for viewModel: AccountViewModel)
    func accountDetail(for viewModel: AccountViewModel)
    func didTapOnShareViewModel(_ viewModel: AccountViewModel)
    func didTapOnWithHolding(_ viewModel: AccountViewModel)
    func didTapOnMoreOptions()
    func showFiltersSelected()
    func removeFilter(filter: ActiveFilters?)
    func sortTransactionsSelected()
    func downloadTransactionsSelected()
    func loadMoreTransactions()
    func loadTransactionPrior90Days()
    func didSelectSearch()
    func didSelectTransaction(_ transaction: TransactionViewModel)
    func didTrackedSwipe()
    func crossSellingViewModel(transaction: TransactionViewModel) -> CrossSellingViewModel
    func loadCandidatesOffersForViewModel(_ viewModel: CrossSellingViewModel, indexPath: IndexPath)
    func gotoCrossSellingOfferForViewModel(_ viewModel: TransactionViewModel)
    func updateCrossSellingVieModel(_ viewModel: TransactionViewModel, withOfferHeight height: CGFloat)
    func didSelectedOffer(_ viewModel: OfferBannerViewModel?)
    func didSelectedOffer(_ offer: ExpirableOfferEntity?)
}

final class AccountsHomePresenter {
    private class ActiveRequests {
        var transactions: Set<AccountEntity>
        var details: Set<AccountEntity>
        
        init() {
            self.transactions = Set<AccountEntity>()
            self.details = Set<AccountEntity>()
        }
    }
    
    private struct TransactionList {
        let transactions: [Date: [AccountTransactionEntity]]
        let pagination: PaginationEntity?
    }
    
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    private var selected: AccountEntity? {
        didSet {
            self.transactions = nil
            self.checkOtherOperativesPlusButton(selected)
            self.loadAccountActionsTypes()
            self.checkBannerLocation()
        }
    }
    
    let dependenciesResolver: DependenciesResolver
    private var activeFilter: TransactionFiltersEntity?
    private var offers: [PullOfferLocation: OfferEntity] = [:]
    private var scaState: ScaState?
    private var transactions: TransactionList?
    private var activeRequests: ActiveRequests = ActiveRequests()
    private var scaFinishedSuccesfully: (() -> Void)?
    weak var view: AccountsHomeViewProtocol?
    var isLoadMoreTransactionsAvailable: Bool = false
    private let sorter = AccountTransferSorter()
    private var easyPayState: EasyPayState = .initial
    private var lastTransacionLoaded: GetAccountTransactionsState?
    private var crossSellingEnabled = false
    private var advancedCrosssSellingRequests: Set<CrossSellingRequest> = Set<CrossSellingRequest>()
    public var carouselOfferBuilder: OfferCarouselBuilderProtocol?
    private var accountsCrossSelling: [AccountMovementsCrossSellingProperties] = []
    private lazy var accountHomeModifier: AccountsHomePresenterModifier? = {
        self.dependenciesResolver.resolve(forOptionalType: AccountsHomePresenterModifier.self)
    }()
    var allowTransactionsPrior90Days: Bool {
        switch self.scaState {
        case .notApply:
            return true
        default:
            return false
        }
    }
    private var isTagFilterShown: Bool = false {
        didSet {
            if let tagsFiltersVisibility = self.accountsHomePresenterModifier?.tagsFiltersVisibility {
                self.view?.setTagsFiltersVisibility(isShown: tagsFiltersVisibility)
            } else {
                self.view?.setTagsFiltersVisibility(isShown: isTagFilterShown)
            }
        }
    }
    var isPlusButtonHidden = false
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.carouselOfferBuilder = self.dependenciesResolver.resolve(forOptionalType: OfferCarouselBuilderProtocol.self)
    }
}

private extension AccountsHomePresenter {
    enum EasyPayState {
        case initial
        case loaded(AccountEasyPay)
        case notLoaded
        
        var easyPay: AccountEasyPay? {
            switch self {
            case .loaded(let easyPay):
                return easyPay
            case .initial, .notLoaded:
                return nil
            }
        }
        
        var isInInitialState: Bool {
            switch self {
            case .initial:
                return true
            case .notLoaded, .loaded:
                return false
            }
        }
    }
    
    var accountsHomeUseCase: GetAccountsHomeUseCase {
        self.dependenciesResolver.resolve(for: GetAccountsHomeUseCase.self)
    }
    
    var accountDetailUseCase: GetAccountDetailUseCase {
        self.dependenciesResolver.resolve(for: GetAccountDetailUseCase.self)
    }
    
    var scaStateUseCase: GetScaStateUseCase {
        self.dependenciesResolver.resolve(for: GetScaStateUseCase.self)
    }
    
    var setReadAccountTransactionsUseCase: SetReadAccountTransactionsUseCase {
        self.dependenciesResolver.resolve(for: SetReadAccountTransactionsUseCase.self)
    }
    
    var getPullOffersUseCase: GetPullOffersUseCase {
        self.dependenciesResolver.resolve()
    }
    
    var easyPayAccountUseCase: GetAccountEasyPayUseCase {
        self.dependenciesResolver.resolve()
    }
    
    var accountsCoordinator: AccountsHomeCoordinator {
        self.dependenciesResolver.resolve(for: AccountsHomeCoordinator.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var accountTransactionModifier: AccountTransactionsModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: AccountTransactionsModifierProtocol.self)
    }
    
    var accountHomeActionUseCase: GetAccountHomeActionUseCaseProtocol {
        dependenciesResolver.resolve(for: GetAccountHomeActionUseCaseProtocol.self)
    }
    var accountsHomePresenterModifier: AccountsHomePresenterModifier? {
        self.dependenciesResolver.resolve(forOptionalType: AccountsHomePresenterModifier.self)
    }
}

extension AccountsHomePresenter: OtpScaAccountPresenterDelegate {
    func otpDidFinishSuccessfully() {
        if self.accountTransactionModifier == nil {
            self.scaState = .notApply
        }
        self.view?.hideLoadTransactionPrior90DaysView()
        if let entity = selected {
            switch self.lastTransacionLoaded {
            case .transactionsPrior90Days(_, let after):
                if let transactions = after {
                    self.lastTransacionLoaded = nil
                    let response = GetAccountTransactionsUseCaseOkOutput(transactionsType: .transactionsAfter90Days(transactions), futureBillList: nil)
                    self.transactionsLoaded(response, for: entity)
                } else {
                    self.manageLoadersView()
                    self.loadTransactions(for: entity, pagination: transactions?.pagination)
                }
            default:
                self.manageLoadersView()
                self.loadTransactions(for: entity, pagination: transactions?.pagination)
            }
        } else {
            self.view?.dismissTransactionsLoadingIndicator()
        }
    }
}

extension AccountsHomePresenter: AccountsHomePresenterProtocol {
    var isTransactionEntryAvailable: Bool {
        return self.accountHomeModifier?.transactionEntryStatusAvailable ?? false
    }
    var isPDFButtonHidden: Bool {
        return self.accountHomeModifier?.hidePDFButton ?? false
    }
    
    func updateCrossSellingVieModel(_ viewModel: TransactionViewModel, withOfferHeight height: CGFloat) {
        guard let cachedCrossSellingRequests = advancedCrossSellingRequestForTransaction(viewModel) else { return }
        var mutableCachedRequest = cachedCrossSellingRequests
        mutableCachedRequest.calcualtedBannerHeight = height
        self.advancedCrosssSellingRequests.update(with: mutableCachedRequest)
    }
    
    func gotoCrossSellingOfferForViewModel(_ viewModel: TransactionViewModel) {
        guard let cachedCrossSellingRequests = advancedCrossSellingRequestForTransaction(viewModel), let offer = cachedCrossSellingRequests.pulledOffer?.first else {
            self.didSelectTransaction(viewModel)
            return
        }
        self.accountsCoordinator.didSelectOffer(offer: offer.value)
    }
    
    func viewDidLoad() {
        self.loadIsSearchEnabled()
        self.dependenciesResolver.resolve(for: GlobalPositionReloadEngine.self).add(self)
        self.load()
        self.trackScreen()
    }
    
    func finishOTPSuccess(_ activeFilter: TransactionFiltersEntity?) {
        self.activeFilter = activeFilter
        self.transactions = nil
        self.isTagFilterShown = true
        self.view?.clearTransactionTable()
        self.view?.showTransactionLoadingIndicator()
        self.otpDidFinishSuccessfully()
    }
    
    func sortTransactionsSelected() {}
    
    func removeFilter(filter: ActiveFilters?) {
        guard let selected = self.selected else { return }
        if filter == nil {
            self.activeFilter = nil
        } else if let optionalFilter = filter {
            self.activeFilter?.removeFilter(optionalFilter)
        }
        self.transactions = nil
        self.view?.hideLoadTransactionPrior90DaysView()
        self.view?.clearTransactionTable()
        self.view?.showTransactionLoadingIndicator()
        if let activesFilters = activeFilter, activesFilters.containsDescriptionFilter() {
            self.loadFilteredTransactions(account: selected, transactionFilters: self.activeFilter, pagination: nil)
        } else {
            self.isTagFilterShown = (self.activeFilter?.filters ?? []).count > 0
            self.loadTransactions(for: selected, pagination: transactions?.pagination)
        }
    }
    
    func loadTransactionPrior90Days() {
        self.isTagFilterShown = false
        trackEvent(.moreMovements, parameters: [:])
        guard let entity = selected else {
            self.view?.dismissTransactionsLoadingIndicator()
            return
        }
        self.loadScaState(typeStateInput: .force) { [weak self, entity] in
            self?.onScaStateLoaded(entity: entity)
        }
    }
    
    func loadMoreTransactions() {
        if let entity = self.selected {
            self.loadMoreAccountTransactions(for: entity)
        } else {
            self.view?.dismissTransactionsLoadingIndicator()
        }
    }
    
    func setSelectedAccountViewModel(_ viewModel: AccountViewModel) {
        self.selected = viewModel.entity
    }
    
    func accountTransactions(for viewModel: AccountViewModel) {
        self.view?.hideLoadTransactionPrior90DaysView()
        self.view?.showTransactionLoadingIndicator()
        if !self.isTagFilterShown {
            self.activeFilter = nil
        }
        self.loadTransactions(for: viewModel.entity)
    }
    
    func accountDetail(for viewModel: AccountViewModel) {
        self.loadDetail(for: viewModel.entity)
    }
    
    func didTapOnShareViewModel(_ viewModel: AccountViewModel) {
        self.accountsCoordinator.didSelectShare(for: viewModel)
        self.trackEvent(.copy, parameters: [:])
    }
    
    func didTapOnWithHolding(_ viewModel: AccountViewModel) {
        guard let entity = viewModel.detail?.entity else { return }
        trackEvent(.witholding, parameters: [:])
        self.accountsCoordinator.didSelectWithholding(for: entity)
    }
    
    func didSelectTransaction(_ transaction: TransactionViewModel) {
        if self.isTransactionDetailAvailable {
            guard let selected = self.selected,
                  let transaction = transaction as? AccountTransactionViewModel,
                  let transactions = accountTransactionEntitiesFromTransaction() else { return }
            self.accountsCoordinator.didSelectTransaction(transaction.transaction, in: transactions, for: selected)
        } else {
            self.view?.showComingSoon()
        }
    }
    
    func didSelectMenu() {
        self.accountsCoordinator.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.accountsCoordinator.didSelectDismiss()
    }
    
    func didTapOnMoreOptions() {
        guard let selectedAccount = self.selected else { return }
        self.accountsCoordinator.gotToMoreOptions(for: selectedAccount)
    }
    
    func showFiltersSelected() {
        if self.isTransactionDetailAvailable {
            trackEvent(.filter, parameters: [:])
            self.accountsCoordinator.didSelectShowFilters(self)
        } else {
            self.view?.showComingSoon()
        }
    }
    
    func didApplyFilter(_ filter: TransactionFiltersEntity, _ criteria: CriteriaFilter) {
        self.activeFilter = filter
        self.transactions = nil
        self.isTagFilterShown = true
        self.view?.hideLoadTransactionPrior90DaysView()
        self.view?.clearTransactionTable()
        self.view?.showTransactionLoadingIndicator()
        guard let selectedAccountEntity = self.selected else {
            return
        }
        switch criteria {
        case .byCharacteristics:
            self.loadTransactions(for: selectedAccountEntity, pagination: nil)
        case .byTerm:
            self.loadFilteredTransactions(account: selectedAccountEntity, transactionFilters: self.activeFilter, pagination: nil)
        default:
            break
        }
    }
    
    func getFilters() -> TransactionFiltersEntity? {
        return self.activeFilter
    }
    
    func getSelectedAccount() -> AccountEntity? {
        return self.selected
    }
    
    func downloadTransactionsSelected() {
        guard let selectedAccount = self.selected else { return }
        trackEvent(.pdf, parameters: [:])
        self.accountsCoordinator.didSelectDownloadTransactions(for: selectedAccount, withFilters: self.activeFilter, withScaSate: self.scaState)
    }
    
    func didSelectSearch() {
        self.accountsCoordinator.didSelectSearch()
    }
    
    func didTrackedSwipe() {
        self.trackEvent(.swipe, parameters: [:])
    }
    
    func crossSellingViewModel(transaction: TransactionViewModel) -> CrossSellingViewModel {
        let isPiggyBankAccount = selected?.isPiggyBankAccount ?? false
        let model = CrossSellingViewModel(transaction: transaction,
                                          accountsCrossSelling: accountsCrossSelling,
                                          crossSellingEnabled: crossSellingEnabled,
                                          isPiggyBankAccount: isPiggyBankAccount,
                                          availableAccountBalance: self.selected?.availableAmount?.value)
        if let activeRequest = self.advancedCrossSellingRequestForTransaction(transaction) {
            model.offers = activeRequest.pulledOffer
            model.bannerHeight = activeRequest.calcualtedBannerHeight
            model.processed = activeRequest.processed
            return model
        }
        return model
    }
    
    func loadCandidatesOffersForViewModel(_ viewModel: CrossSellingViewModel, indexPath: IndexPath) {
        guard accountTransactionEntitiesFromTransaction() != nil,
              let selectedAccount = selected,
              let transaction = viewModel.transactionViewModel as? AccountTransactionViewModel else { return }
        let offerRequest = CrossSellingRequest(transaction: transaction, indexPath: indexPath)
        self.advancedCrosssSellingRequests.update(with: offerRequest)
        UseCaseWrapper(
            with: transactionPullOffersUseCase
                .setRequestValues(
                    requestValues: AccountTransactionOfferConfigurationUseCaseInput(
                        account: selectedAccount,
                        transaction: transaction.transaction,
                        locations: self.locations,
                        specificLocations: self.homeCrossSellingLocations,
                        filterToApply: FilterAccountLocation(location: AccountsPullOffers.homeCrossSelling,
                                                             indexOffer: viewModel.indexCrossSelling)
                    )),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                let candidates = result.pullOfferCandidates.location(key: AccountsPullOffers.homeCrossSelling)
                if let activeOffersRequest = self?.advancedCrosssSellingRequests.first(where: {$0.transaction == transaction }) {
                    var offerRequest = activeOffersRequest
                    guard let offer = candidates else {
                        self?.advancedCrosssSellingRequests.update(with: offerRequest)
                        self?.view?.finishedCrossSellingForIndexPath(activeOffersRequest.indexPath)
                        self?.gotoCrossSellingOfferForViewModel(viewModel.transactionViewModel)
                        return
                    }
                    offerRequest.pulledOffer = [offer.location: offer.offer]
                    self?.advancedCrosssSellingRequests.update(with: offerRequest)
                    self?.gotoCrossSellingOfferForViewModel(viewModel.transactionViewModel)
                    
                }
            }, onError: { [weak self] _ in
                if let activeOffersRequest = self?.advancedCrosssSellingRequests.first(where: {$0.transaction == transaction }) {
                    var offerRequest = activeOffersRequest
                    offerRequest.processed = true
                    self?.view?.finishedCrossSellingForIndexPath(activeOffersRequest.indexPath)
                }
                
            })
    }
    
    func didSelectedOffer(_ viewModel: OfferBannerViewModel?) {
        guard let offer = viewModel?.offer else {
            return
        }
        self.accountsCoordinator.didSelectOffer(offer: offer)
    }
    
    func didSelectedOffer(_ offer: ExpirableOfferEntity?) {
        guard let offer = offer else { return }
        self.accountsCoordinator.didSelectOffer(offer: offer)
        guard let offerId = offer.id, offer.expiresOnClick else { return }
        Scenario(
            useCase: self.dependenciesResolver.resolve(for: DisableOnSessionPullOfferUseCase.self),
            input: DisableOnSessionPullOfferUseCaseInput(offerId: offerId))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { _ in
                self.loadOfferCarousel()
            }
    }
    
}

extension AccountsHomePresenter: AutomaticScreenEmmaActionTrackable {
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: AccountsHomePage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.accountsEventID
        return AccountsHomePage(emmaToken: emmaToken)
    }
}

private extension AccountsHomePresenter {
    
    enum HeaderCellHeigh: CGFloat {
        case normal = 194.0
        case big = 236.0
        
        var height: CGFloat {
            return self.rawValue
        }
    }
    
    var scaTransactionParams: SCATransactionParams? {
        guard let account = self.selected else { return nil }
        return SCATransactionParams(account: account,
                                    pagination: self.transactions?.pagination,
                                    scaState: self.scaState,
                                    filters: self.activeFilter,
                                    filtersIsShown: self.isTagFilterShown)
    }

    func loadMoreAccountTransactions(for accountEntity: AccountEntity) {
        self.isLoadMoreTransactionsAvailable = false
        self.loadTransactions(for: accountEntity, pagination: transactions?.pagination)
    }
    
    func load() {
        self.view?.setDependenciesResolver(self.dependenciesResolver)
        self.loadAccounts()
        self.loadOfferCarousel()
    }
    
    func loadAccounts() {
        MainThreadUseCaseWrapper(
            with: accountsHomeUseCase,
            onSuccess: { [weak self] response in
                let accounts: [AccountEntity] = response.accounts
                self?.crossSellingEnabled = response.isCrossSellingEnabled
                self?.accountsCrossSelling = response.accountsCrossSelling
                let selectedAccount: AccountEntity = self?.selected ?? response.configuration.selectedAccount ?? accounts[0]
                guard let index = accounts.firstIndex(of: selectedAccount) else { return }
                self?.selected = accounts[index]
                self?.loadOffers { [weak self] in
                    guard let self = self, let selected = self.selected else { return }
                    let viewModels = accounts.map { AccountViewModel($0, dependenciesResolver: self.dependenciesResolver)}
                    let selectedViewModel = AccountViewModel(selected, dependenciesResolver: self.dependenciesResolver)
                    let headerCellHeight: HeaderCellHeigh = accounts.map { $0.earningsAmount != nil }
                        .contains(true) ? .big : .normal
                    self.view?.showAccounts(viewModels,
                                            withSelected: selectedViewModel,
                                            cellHeight: headerCellHeight.height)
                    self.loadDetail(for: selected)
                    self.loadEasyPay()
                }
            }
        )
    }
    
    func loadScaState(typeStateInput: GetScaStateUseCaseInput = .normal, completion: @escaping () -> Void) {
        switch self.scaState {
        case .none, .temporaryLock?, .error?:
            break
        case .notApply?, .requestOtp?:
            completion()
            return
        }
        UseCaseWrapper(
            with: scaStateUseCase.setRequestValues(requestValues: typeStateInput),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] response in
                self?.scaState = response.scaState
                completion()
            },
            onError: { [weak self] _ in
                self?.scaState = nil
                completion()
            }
        )
    }
    
    func loadDetail(for account: AccountEntity) {
        guard activeRequests.details.firstIndex(of: account) == nil else { return }
        activeRequests.details.insert(account)
        UseCaseWrapper(
            with: accountDetailUseCase.setRequestValues(requestValues: GetAccountDetailUseCaseInput(account: account)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] response in
                guard let self = self else { return }
                self.activeRequests.details.remove(account)
                let viewModel = AccountViewModel(account, dependenciesResolver: self.dependenciesResolver)
                viewModel.detail = AccountDetailViewModel(
                    response.detail,
                    allowWithholdings: self.localAppConfig.isEnabledWithholdings,
                    arrowWithholdVisible: self.accountsHomePresenterModifier?.arrowWithholdVisible,
                    allowOverdraft: self.accountsHomePresenterModifier?.allowOverdraft)
                self.view?.showAccountDetail(for: viewModel)
            },
            onError: { [weak self] _ in
                guard let self = self else { return }
                self.activeRequests.details.remove(account)
                let viewModel = AccountViewModel(account, dependenciesResolver: self.dependenciesResolver)
                self.view?.showAccountDetail(for: viewModel)
            }
        )
    }
    
    func loadTransactions(for account: AccountEntity, pagination: PaginationEntity? = nil) {
        guard !self.easyPayState.isInInitialState else { return }
        guard activeRequests.transactions.firstIndex(of: account) == nil else { return }
        activeRequests.transactions.insert(account)
        self.loadScaState { [weak self, account, pagination] in
            self?.loadTransactionsAfterSca(for: account, pagination: pagination)
        }
    }
    
    func loadTransactionsAfterSca(for account: AccountEntity, pagination: PaginationEntity?) {
        let accountTransactionsUseCase = self.dependenciesResolver.resolve(firstTypeOf: GetAccountTransactionsUseCaseProtocol.self)
        Scenario(
            useCase: accountTransactionsUseCase,
            input: GetAccountTransactionsUseCaseInput(
                account: account,
                pagination: pagination,
                scaState: scaState,
                filters: activeFilter,
                filtersIsShown: self.isTagFilterShown
            )
        )
        .execute(on: dependenciesResolver.resolve(for: UseCaseHandler.self))
        .onSuccess { [weak self] response in
            guard self?.selected == account else {
                self?.activeRequests.transactions.remove(account)
                return
            }
            self?.lastTransacionLoaded = response.transactionsType
            self?.transactionsLoaded(response, for: account)
        }
        .onError { [weak self] error in
            guard self?.selected == account else {
                self?.activeRequests.transactions.remove(account)
                return
            }
            switch error {
            case .networkUnavailable:
                self?.transactionsDidFail(for: account, error: "product_label_emptyError")
            default:
                self?.transactionsDidFail(for: account, error: "generic_label_emptyNotAvailableMoves")
            }
        }
    }
    
    func loadFilteredTransactions(account: AccountEntity, transactionFilters: TransactionFiltersEntity? = nil, pagination: PaginationEntity? = nil ) {
        let requestParameters = GetFilteredAccountTransactionsUseCaseInput(account: account, filters: transactionFilters, pagination: pagination)
        let filteredTransactionsUseCase = self.dependenciesResolver.resolve(firstTypeOf: GetFilteredAccountTransactionsUseCaseProtocol.self).setRequestValues(requestValues: requestParameters)
        UseCaseWrapper(
            with: filteredTransactionsUseCase,
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] response in
                self?.transactionsLoaded(response.transactionList, for: account)
            },
            onError: { [weak self] error in
                switch error {
                case .networkUnavailable:
                    self?.transactionsDidFail(for: account, error: error.getErrorDesc() ?? localized("product_label_emptyError"))
                default:
                    self?.transactionsDidFail(for: account, error: error.getErrorDesc() ?? localized("generic_label_emptyNotAvailableMoves"))
                }
            })
    }
    
    func transactionsLoaded(_ response: GetAccountTransactionsUseCaseOkOutput, for account: AccountEntity) {
        switch response.transactionsType {
        case .transactionsAfter90Days(let responseData):
            self.processTransactions(
                transactionList: responseData.transactions,
                billList: response.futureBillList?.billListRepresentable,
                account: account,
                pagination: responseData.pagination
            )
        case .transactionsPrior90Days(let responseData, _):
            self.processTransactions(
                transactionList: responseData.transactions,
                billList: response.futureBillList?.billListRepresentable,
                account: account,
                pagination: responseData.pagination
            )
            self.handleTransactionPrior90Days(
                billList: response.futureBillList?.billListRepresentable,
                account: account,
                pagination: responseData.pagination
            )
        case .noTransactions:
            guard let bills = response.futureBillList?.billListRepresentable, !bills.isEmpty else {
                self.setNotAvailableTransactions(for: account)
                return
            }
            self.setOnlyFutureBills(bills: bills, account: account)
        }
    }
    
    func transactionsLoaded(_ transactionsList: AccountTransactionListEntity, for account: AccountEntity) {
        // Always it shows transactionsAfter90Days:
        self.processTransactions(
            transactionList: transactionsList.transactions,
            billList: nil,
            account: account,
            pagination: transactionsList.pagination
        )
    }
    
    func setOnlyFutureBills(bills: [AccountFutureBillRepresentable], account: AccountEntity) {
        let billViewModels = self.getFutureBillVieModels(bills)
        let accountViewModel = AccountViewModel(account, dependenciesResolver: self.dependenciesResolver)
        self.view?.showTransactions(for: accountViewModel, transactions: billViewModels, filterViewModel: nil)
        self.isLoadMoreTransactionsAvailable = false
        self.activeRequests.transactions.remove(account)
        self.view?.dismissTransactionsLoadingIndicator()
    }
    
    func setNotAvailableTransactions(for account: AccountEntity) {
        activeRequests.transactions.remove(account)
        guard self.transactions?.transactions == nil else {
            self.view?.dismissTransactionsLoadingIndicator()
            return
        }
        self.transactionsDidFail(for: account, error: "generic_label_emptyNotAvailableMoves")
    }
    
    func processTransactions(transactionList: [AccountTransactionEntity],
                             billList: [AccountFutureBillRepresentable]?,
                             account: AccountEntity,
                             pagination: PaginationEntity) {
        let billViewModels = self.getFutureBillVieModels(billList)
        let pendingTransactionsViewModel = self.getPendingTransactionViewModels(for: transactionList)
        let transactionsViewModels = self.getTransactionsViewModels(for: transactionList, and: pagination)
        let accountViewModel = AccountViewModel(account, dependenciesResolver: self.dependenciesResolver)
        let viewModels: [TransactionsGroupViewModel] = billViewModels + pendingTransactionsViewModel + transactionsViewModels
        if let currentOptionalFilter = self.activeFilter {
            let filterViewModel = currentOptionalFilter.actives().count == 0 ? nil : TransactionFilterViewModel(currentOptionalFilter)
            self.view?.showTransactions(for: accountViewModel, transactions: viewModels, filterViewModel: filterViewModel )
        } else {
            self.view?.showTransactions(for: accountViewModel, transactions: viewModels, filterViewModel: nil )
        }
        self.isLoadMoreTransactionsAvailable = !pagination.isEnd
        self.activeRequests.transactions.remove(account)
    }
    
    func getTransactionsViewModels(for transactionList: [AccountTransactionEntity], and pagination: PaginationEntity) -> [TransactionsGroupViewModel] {
        var processedTransactionList = transactionList
        if self.accountHomeModifier?.transactionEntryStatusAvailable == true {
            processedTransactionList = transactionList.filter({$0.entryStatus == .booked})
        }
        let transactionsByDate: [Date: [AccountTransactionEntity]] = processedTransactionList.reduce([:], sorter.groupTransactionsByDate)
        let actualTransactions = transactions?.transactions ?? [:]
        let transactionsByDateMerged = actualTransactions.merging(transactionsByDate, uniquingKeysWith: { $0 + $1 })
        transactions = TransactionList(transactions: transactionsByDateMerged, pagination: pagination)
        self.view?.dismissTransactionsLoadingIndicator()
        let transactions = transactionsByDateMerged.map({
            AccountTransactionsGroupViewModel(
                date: $0.key,
                transactions: $0.value,
                offers: self.offers,
                dependenciesResolver: dependenciesResolver,
                easyPay: self.selected?.isPiggyBankAccount == false ? self.easyPayState.easyPay : nil
            )}).sorted(by: { $0.date > $1.date })
        return transactions
    }
    
    func getFutureBillVieModels(_ billList: [AccountFutureBillRepresentable]?) -> [TransactionsGroupViewModel] {
        guard let billList = billList else { return [] }
        let billsGroupedByDate: [Date: [AccountFutureBillRepresentable]] = billList.reduce([:], sorter.groupeBillByDate)
        let viewModles = billsGroupedByDate.map({
            AccountFutureBillGroupViewModel(
                date: $0.key,
                bills: $0.value,
                dependenciesResolver: dependenciesResolver
            )}).sorted(by: { $0.date < $1.date })
        return viewModles
    }
    
    func getPendingTransactionViewModels(for transactionList: [AccountTransactionEntity]) -> [TransactionsGroupViewModel] {
        let pendingTransactionEntities = self.getPendingTransactionsEntities(transactionList)
        guard pendingTransactionEntities.isEmpty else {
            return [AccountPendingTransactionGroupViewModel(transactions: pendingTransactionEntities,
                                                           dependenciesResolver: self.dependenciesResolver)]
        }
        return []
    }
    
    func getPendingTransactionsEntities(_ transactions: [AccountTransactionEntity]) -> [AccountPendingTransactionRepresentable] {
        let pendingTransactions = transactions.filter({$0.entryStatus == .pending})
        let pendingTransactionEntities = pendingTransactions.map({ $0.accountPendingTrasactionRepresentable })
        return pendingTransactionEntities
    }
    
    func handleTransactionPrior90Days(
        billList: [AccountFutureBillRepresentable]?,
        account: AccountEntity,
        pagination: PaginationEntity
    ) {
        let transactions = self.transactions?.transactions ?? [:]
        let bills = billList ?? []
        
        if transactions.isEmpty, bills.isEmpty {
            self.showTransactionPrior90DaysViewsWithMessage(for: account)
        } else {
            self.view?.dismissTransactionsLoadingIndicator()
            self.view?.showLoadTransactionPrior90DaysView()
        }
        self.isLoadMoreTransactionsAvailable = false
    }
    
    func showTransactionPrior90DaysViewsWithMessage(for account: AccountEntity) {
        self.transactionsDidFail(for: account, error: "product_label_emptyListSCA")
        self.view?.showLoadTransactionPrior90DaysView()
        self.view?.dismissTransactionsLoadingIndicator()
    }
    
    func transactionsDidFail(for account: AccountEntity, error: String) {
        defer {
            view?.dismissTransactionsLoadingIndicator()
            isLoadMoreTransactionsAvailable = false
            activeRequests.transactions.remove(account)
        }
        if let currentOptionalFilter = self.activeFilter {
            view?.showTransactionError(error, for: AccountViewModel(account, dependenciesResolver: self.dependenciesResolver), filterViewModel: TransactionFilterViewModel(currentOptionalFilter))
        } else {
            view?.showTransactionError(error, for: AccountViewModel(account, dependenciesResolver: self.dependenciesResolver), filterViewModel: nil)
        }
    }
    
    func onScaStateLoaded(entity: AccountEntity) {
        switch scaState {
        case .temporaryLock:
            showScaTemporaryLockDialog()
        case .error:
            showScaError()
        case .requestOtp:
            showScaRequestOtpDialog()
        case .notApply, .none:
            isLoadMoreTransactionsAvailable = false
            view?.hideLoadTransactionPrior90DaysView()
            let currentTransactions = transactions?.transactions ?? [:]
            if currentTransactions.isEmpty {
                view?.showTransactionLoadingIndicator()
            } else {
                view?.showLoadingPaginator()
            }
            loadTransactions(for: entity, pagination: transactions?.pagination)
        }
    }
    
    func showScaTemporaryLockDialog() {
        guard let view = (view as? UIViewController)?.navigationController else { return }
        accountsCoordinator.showDialog(
            acceptTitle: localized("generic_button_understand"),
            cancelTitle: nil,
            title: localized("otpSCA_alert_title_blocked"),
            body: localized("otpSCA_alert_text_blocked"),
            showsCloseButton: false,
            source: view,
            acceptAction: nil,
            cancelAction: nil
        )
    }
    
    func showScaError() {
        guard let view = (view as? UIViewController)?.navigationController?.visibleViewController else { return }
        accountsCoordinator.showDialog(
            acceptTitle: nil,
            cancelTitle: nil,
            title: nil,
            body: nil,
            showsCloseButton: false,
            source: view,
            acceptAction: nil,
            cancelAction: nil
        )
    }
    
    func showScaRequestOtpDialog() {
        guard let view = (view as? UIViewController)?.navigationController?.visibleViewController else { return }
        let acceptAction: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.trackerManager.trackEvent(
                screenId: AccountScaPage().page,
                eventId: AccountScaPage.Action.next.rawValue,
                extraParameters: [:]
            )
            guard let accountTransactionModifier = self.accountTransactionModifier else {
                if let scaTransactionParams = self.scaTransactionParams {
                    self.accountsCoordinator.goToAccountsOTP(delegate: self, scaTransactionParams: scaTransactionParams)
                }
                return
            }
            let currentTransactions = self.transactions?.transactions ?? [:]
            self.activeFilter = accountTransactionModifier.getActiveFilter(for: currentTransactions)
            if let scaTransactionParams = self.scaTransactionParams {
                self.accountsCoordinator.goToAccountsOTP(delegate: self, scaTransactionParams: scaTransactionParams)
            }
        }
        let cancelAction: () -> Void = { [weak self] in
            self?.trackerManager.trackEvent(
                screenId: AccountScaPage().page,
                eventId: AccountScaPage.Action.cancel.rawValue,
                extraParameters: [:]
            )
        }
        accountsCoordinator.showDialog(
            acceptTitle: localized("generic_button_continue"),
            cancelTitle: localized("generic_button_cancel"),
            title: localized("otpSCA_alert_title_safety"),
            body: localized("otpSCA_alert_text_safety"),
            showsCloseButton: false,
            source: view,
            acceptAction: acceptAction,
            cancelAction: cancelAction
        )
    }
    
    // MARK: - Pull offers
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().accountsTransactionDetail
    }
    
    func loadOffers(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: getPullOffersUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: self.locations)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.offers = result.pullOfferCandidates
                completion()
            }
        )
    }
    
    var transactionPullOffersUseCase: AccountTransactionPullOfferConfigurationUseCase {
        self.dependenciesResolver.resolve(for: AccountTransactionPullOfferConfigurationUseCase.self)
    }
    
    func loadEasyPay() {
        UseCaseWrapper(
            with: self.easyPayAccountUseCase.setRequestValues(requestValues: GetAccountEasyPayUseCaseInput(type: .transaction)),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.easyPayState = .loaded(result.accountEasyPay)
                guard let selectedAccount = self?.selected else { return }
                self?.loadTransactions(for: selectedAccount)
            },
            onError: { [weak self] error in
                self?.easyPayState = .notLoaded
                guard let selectedAccount = self?.selected else { return }
                self?.loadTransactions(for: selectedAccount)
                guard let error = error.getErrorDesc() else { return }
                guard let isDisabled = self?.dependenciesResolver.resolve(forOptionalType: AccountTransactionProtocol.self)?.disabledEasyPayAccount,
                      isDisabled == true else {
                    self?.trackEvent(.easyPayError, parameters: [.codError: error])
                    return
                }
            }
        )
    }
    
    func loadAccountActionsTypes() {
        guard let selected = self.selected else { return }
        let input = GetAccountHomeActionUseCaseInput(account: selected)
        Scenario(useCase: accountHomeActionUseCase, input: input)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.showAccountActions(accountActionTypes: result.actions)
            }
    }
    
    func showAccountActions(accountActionTypes: [AccountActionType]) {
        guard let selected = self.selected else { return }
        let actionsViewModels = self.dependenciesResolver.resolve(for: AccountActionAdapter.self).getHomeActions(accountTypes: accountActionTypes, entity: selected) { [weak self] action, entity in
            if let trackName = action.trackName {
                self?.trackEvent(.operative, parameters: [.accountOperative: trackName])
            }
            self?.accountsCoordinator.didSelectAction(action, entity)
        }
        self.view?.showAccountActions(actionsViewModels)
    }
    
    func checkBannerLocation() {
        guard let offer = self.offers.location(key: AccountsPullOffers.accountsHomePiggyBank),
              self.selected?.isPiggyBankAccount ?? false else {
            self.view?.setOfferBannerForLocation(viewModel: nil)
            return
        }
        let viewModel = OfferBannerViewModel(entity: offer.offer)
        self.view?.setOfferBannerForLocation(viewModel: viewModel)
    }
    
    func manageLoadersView() {
        let currentTransactions = transactions?.transactions ?? [:]
        if currentTransactions.isEmpty {
            view?.showTransactionLoadingIndicator()
        } else {
            view?.showLoadingPaginator()
        }
    }
    
    // MARK: - Check other operatives plus button. No other operatives, no button
    var otherOperativesLocations: [PullOfferLocation] {
        guard let locations = self.dependenciesResolver.resolve(forOptionalType: AccountModifierProtocol.self)?.accountsOtherOperatives else {
            return PullOffersLocationsFactoryEntity().accountsOtherOperatives
        }
        return locations
    }
    var otherOperativesUseCase: GetAccountOtherOperativesUseCaseProtocol {
        dependenciesResolver.resolve(for: GetAccountOtherOperativesUseCaseProtocol.self)
    }
    var accountOtherOperativesActionUseCase: GetAccountOtherOperativesActionUseCaseProtocol {
        dependenciesResolver.resolve(for: GetAccountOtherOperativesActionUseCaseProtocol.self)
    }
    
    func checkOtherOperativesPlusButton(_ account: AccountEntity?) {
        guard let account = account else { return }
        let input = GetAccountOtherOperativesUseCaseInput(account: account, locations: otherOperativesLocations)
        Scenario(useCase: otherOperativesUseCase, input: input)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.checkOtherOperativesResult(result)
            }
    }
    
    func checkOtherOperativesResult(_ response: GetOtherOperativesUseCaseOkOutput) {
        let input = GetAccountOtherOperativesActionUseCaseInput(account: response.configuration.account)
        Scenario(useCase: accountOtherOperativesActionUseCase, input: input)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.isPlusButtonHidden = self.dependenciesResolver.resolve(for: AccountActionAdapter.self).getOtherOperativeActions(
                    entity: response.configuration.account,
                    offers: response.pullOfferCandidates,
                    action: nil,
                    accounts: response.accounts,
                    otherOperativesActions: result.otherOperativeActions).isEmpty
            }
    }
}

extension AccountsHomePresenter: GlobalPositionReloadable {
    func reload() {
        easyPayState = .initial
        loadAccounts()
    }
}

extension AccountsHomePresenter: GlobalSearchEnabledManagerProtocol {
    private func loadIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] (resp) in
            self?.view?.isSearchEnabled(resp)
        }
    }
}

// MARK: - Adapters
private extension AccountsHomePresenter {
    
    func accountTransactionEntitiesFromTransaction() -> [AccountTransactionEntity]? {
        guard self.selected != nil else { return nil }
        let transactions: [AccountTransactionEntity] =
            self.transactions?
            .transactions
            .sorted(by: { $0.key > $1.key })
            .reduce(into: [], { $0.append(contentsOf: $1.value) }) ?? []
        return transactions
    }
}

// MARK: - Home CrossSelling
private extension AccountsHomePresenter {
    var homeCrossSellingLocations: [PullOfferLocation] {
        PullOffersLocationsFactoryEntity().accountHomeCrossSelling
    }
    
    func advancedCrossSellingRequestForTransaction(_ transaction: TransactionViewModel) -> CrossSellingRequest? {
        if let model = transaction as? AccountTransactionViewModel {
            return self.advancedCrosssSellingRequests.first(where: {$0.transaction == model})
        }
        return nil
    }
}

// MARK: - Account Home Modifier
private extension AccountsHomePresenter {
    var isTransactionDetailAvailable: Bool {
        guard let accountHomeModifier = self.accountHomeModifier else {
            return true
        }
        return accountHomeModifier.canGoToTransactionDetail
    }
}
