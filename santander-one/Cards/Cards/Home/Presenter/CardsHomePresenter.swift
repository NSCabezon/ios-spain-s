//
//  CardsHomePresenter.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 10/23/19.
//

import CoreFoundationLib
import UI
import OpenCombine

protocol CardsHomePresenterProtocol: CardTransactionsSearchDelegate, MenuTextWrapperProtocol {
    var view: CardsHomeViewProtocol? { get set }
    var isVideoOffer: Bool { get }
    func viewDidLoad()
    func viewWillAppear()
    func didTapOnMoreOptions()
    func loadMoreTransactions()
    func showFiltersSelected()
    func downloadTransactionsSelected()
    func didSelectMenu()
    func didSelectDismiss()
    func setSelectedCardViewModel(_ viewModel: CardViewModel)
    func cardTransactions(for viewModel: CardViewModel)
    func cardPendingTransactions()
    func cardActions(for viewModel: CardViewModel)
    func didTapOnShareViewModel(_ viewModel: CardViewModel)
    func didTapOnCVVViewModel(_ viewModel: CardViewModel)
    func didTapOnActivateCard(_ viewModel: CardViewModel)
    func didTapOnShowPAN(_ viewModel: CardViewModel)
    func didSelectTransaction(_ transaction: CardTransactionViewModel)
    func doSearch()
    func didSelectInformationCardButton(for viewModel: CardViewModel, button: CardInformationButton)
    func didSelectMap()
    func removeFilter(filter: ActiveFilters?)
    func toolTipTrack()
    func didTooltipVideoAction()
    func didFilterRemove()
    func loadCandidatesOffersForViewModel(_ viewModel: CardTransactionViewModel)
    func isPANAlwaysSharable() -> Bool
}

final class CardsHomePresenter {
    
    weak var view: CardsHomeViewProtocol?
    internal let dependenciesResolver: DependenciesResolver
    private var cardTransactions: TransactionList?
    private var minEasyPayAmount: Double?
    private var activeFilter: TransactionFiltersEntity?
    private var isEnabledMap: Bool = false
    private var isPbUser: Bool = false
    private var easyPaymentEnabled = false
    private var crossSellingEnabled = false
    private var pendingRequest = PendingTransferRequest()
    private let localAppConfig: LocalAppConfig
    private var cardsCrossSelling: [CardsMovementsCrossSellingProperties] = []
    private var scaDate: Date?
    private var outsider = DefaultCardTransactionFilterOutsider()
    private var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.localAppConfig = dependenciesResolver.resolve(for: LocalAppConfig.self)
        self.outsider.publisher
            .map { $0.toEntity() }
            .sink {
                _ = self.didApplyFilter($0, .none)
            }
            .store(in: &subscriptions)
        
    }

    private struct TransactionList {
        let transactions: [Date: [CardTransactionEntityProtocol]]
    }

    private enum Constants {
        static let maxActionsNumberToShow: Int = 4
    }
    
    private var isPendingTransactionEntity: Bool {
        if let firstTransactions = cardTransactions?.transactions.first {
            if firstTransactions.value as? [CardPendingTransactionEntity] != nil {
                return true
            } else if firstTransactions.value as? [CardTransactionEntity] != nil {
                return false
            }
        }
       return false
    }
    
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    
    private var selectedCardEntity: CardEntity? {
        didSet {
            self.cardTransactions = nil
            self.pendingRequest.addPagination(nil)
            guard let selected = self.selectedCardEntity else { return }
            self.loadCardExtraInfo(for: selected)
            if self.localAppConfig.isEnabledPfm {
                self.updatePfmWithReadCard()
            }
        }
    }
    
    private var pfmController: PfmControllerProtocol {
        return dependenciesResolver.resolve(for: PfmControllerProtocol.self)
    }
    
    private var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var getCardsUseCase: GetCardsHomeUseCase {
        return dependenciesResolver.resolve(for: GetCardsHomeUseCase.self)
    }
    
    private var getCardApplePaySupport: GetCardApplePaySupportUseCase {
        return dependenciesResolver.resolve(for: GetCardApplePaySupportUseCase.self)
    }
    
    private var setReadCardTransactionsUseCase: SetReadCardTransactionsUseCase {
        return dependenciesResolver.resolve(for: SetReadCardTransactionsUseCase.self)
    }
    
    private lazy var cardsTransactionsManager: CardsTransactionsManagerProtocol = {
        return dependenciesResolver.resolve(for: CardsTransactionsManagerProtocol.self)
    }()
    
    private var getCardExpenses: GetCardExpensesCalculationUseCase {
        return dependenciesResolver.resolve(for: GetCardExpensesCalculationUseCase.self)
    }
    
    private var coordinator: CardsHomeModuleCoordinator {
        return dependenciesResolver.resolve(for: CardsHomeModuleCoordinator.self)
    }
    
    private lazy var cardActionFactory: CardActionFactoryProtocol = {
        self.dependenciesResolver.resolve(firstTypeOf: CardActionFactoryProtocol.self)
    }()
    
    var minEasyPayAmountUseCase: OldGetMinEasyPayAmountUseCase {
        self.dependenciesResolver.resolve(for: OldGetMinEasyPayAmountUseCase.self)
    }
    
    private var appConfig: AppConfigRepositoryProtocol {
        return self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    private var getCardPaymentMethod: GetCardPaymentMethodUseCase {
        return dependenciesResolver.resolve(for: GetCardPaymentMethodUseCase.self)
    }
    
    private var getCardSettlementDetailUseCase: GetCardSettlementDetailUseCase {
        return self.dependenciesResolver.resolve(for: GetCardSettlementDetailUseCase.self)
    }
    
    private var cardHomeDelegate: CardHomeModifierProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: CardHomeModifierProtocol.self)
    }
    
    private var getScaDate: GetCheckScaDateUseCase {
        return dependenciesResolver.resolve(for: GetCheckScaDateUseCase.self)
    }
    
    private var isPANMasked: Bool = false
}

extension CardsHomePresenter: CardsHomePresenterProtocol {
    var isVideoOffer: Bool {
        return (self.pullOfferCandidates.location(key: "CARD_TOOLBAR_TOOLTIP_VIDEO")?.offer) != nil
    }
    
    func loadCandidatesOffersForViewModel(_ viewModel: CardTransactionViewModel) {
        guard let selectedCardEntity = self.selectedCardEntity else { return }
        Scenario(useCase: cardTransactionPullOffersUseCase,
                 input: CardTransactionPullOffersConfigurationUseCaseInput(
                    transaction: viewModel.transaction,
                    card: selectedCardEntity,
                    specificLocations: self.locations,
                    filterToApply: FilterCardLocation(location: CardsPullOffers.homeCrossSelling,
                                                      indexOffer: viewModel.indexCardCrossSelling)
                 ))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                guard let candidates = result.pullOfferCandidates.location(key: CardsPullOffers.homeCrossSelling) else {
                    self?.didSelectTransaction(viewModel)
                    return
                }
                self?.coordinator.didSelectOffer(offer: candidates.offer)
            }
    }
    
    func removeFilter(filter: ActiveFilters?) {
        guard let selected = self.selectedCardEntity else { return }
        if filter == nil {
            self.activeFilter = nil
        } else if let optionalFilter = filter {
            self.activeFilter?.removeFilter(optionalFilter)
        }
        self.cardTransactions = nil
        self.pendingRequest.addPagination(nil)
        self.view?.clearTransactionTable()
        self.view?.showTransactionLoadingIndicator()
        self.loadCardTransactions(for: selected)
    }
    
    func viewDidLoad() {
        self.getPullOffersCandidates()
        self.loadIsSearchEnabled()
        self.dependenciesResolver.resolve(for: GlobalPositionReloadEngine.self).add(self)
        self.loadScaDate()
        self.loadMinEasyPayAmount { [weak self] in
            self?.loadCards(reloaded: false)
        }
        self.trackScreen()
        if let cardHomeDelegate = cardHomeDelegate {
            isPANMasked = cardHomeDelegate.isPANMasked()
        }
    }
    
    func viewWillAppear() {
        if let cardHomeDelegate = cardHomeDelegate,
           let selectedCard = cardHomeDelegate.getSelectedCardFromConfiguration() {
            self.selectedCardEntity = selectedCard
        }
    }
    
    func loadMoreTransactions() {
        guard let entity = self.selectedCardEntity,
              self.pendingRequest.isNotWaitingForResponse(),
              self.pendingRequest.allowMoreRequest()
        else {
            self.view?.dismissTransactionsLoadingIndicator()
            return
        }
        self.pendingRequest.addRequest()
        
        if isPendingTransactionEntity {
            self.loadCardTransationWithPendingLiquidation(for: entity)
        } else {
            self.loadCardTransactions(for: entity)
        }
    }
    
    func setSelectedCardViewModel(_ viewModel: CardViewModel) {
        self.selectedCardEntity = viewModel.entity
        self.view?.setPendingTransactionOptions(hidden: !viewModel.isCreditCard)
        self.trackEvent(.swipe, parameters: [.cardType: viewModel.trackId])
    }
    
    func cardTransactions(for viewModel: CardViewModel) {
        self.removePendingTransactionFilter()
        self.view?.showTransactionLoadingIndicator()
        self.loadCardTransactions(for: viewModel.entity)
    }
    
    func cardPendingTransactions() {
        guard let entity = self.selectedCardEntity else { return }
        self.trackEvent(.pendingTransaction, parameters: [.cardType: entity.trackId])
        self.cardTransactions = nil
        self.activeFilter = TransactionFiltersEntity()
        _ = self.activeFilter?.addCustome(CoreActiveFilter.cardPendingTransaction)
        self.view?.showTransactionLoadingIndicator()
        self.loadCardTransationWithPendingLiquidation(for: entity)
    }
    
    private var pullOfferUseCase: GetPullOffersUseCase {
        return self.dependenciesResolver.resolve(for: GetPullOffersUseCase.self)
    }
    
    private func getPullOffersCandidates() {
        UseCaseWrapper(
            with: self.pullOfferUseCase.setRequestValues(requestValues: GetPullOffersUseCaseInput(locations: locations)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self)) { [weak self] result in
                self?.pullOfferCandidates = result.pullOfferCandidates
            } onError: { [weak self] _ in
                self?.pullOfferCandidates = [:]
            }
    }
    
    func cardActions(for viewModel: CardViewModel) {
        self.showCardsActions(for: viewModel, offers: self.pullOfferCandidates)
    }
    
    private func showCardsActions(for viewModel: CardViewModel, offers: [PullOfferLocation: OfferEntity]) {
        let cardActions = (self.didSelectAction, self.addToApplePay)
        var actionViewModels = cardActionFactory.getCardHomeActions(for: viewModel, offers: offers, cardActions: cardActions, onlyFourActions: true, scaDate: self.scaDate)
        if actionViewModels.count > Constants.maxActionsNumberToShow {
            actionViewModels = Array(actionViewModels.prefix(Constants.maxActionsNumberToShow))
            self.view?.hideMoreOptionsButton(false)
        } else {
            self.view?.hideMoreOptionsButton(true)
        }
        cardActionFactory.isPb = self.isPbUser
        let isHideCardsAccessButtons = cardHomeDelegate?.isCardHighlitghtedButtonsHidden() ?? false
        self.view?.showCardActions(cardViewModel: viewModel, actionViewModels: actionViewModels, isHideCardsAccessButtons: isHideCardsAccessButtons)
    }
    
    private func isHideDetailsHomeCardConditions() -> Bool {
        if let cardHomeDelegate = cardHomeDelegate {
            return cardHomeDelegate.hideCardsHomeImageDetailsConditions()
        } else {
            return false
        }
    }
    
    private func trackCardAction(action: OldCardActionType, entity: CardEntity) {
        guard let trackName = action.trackName else { return }
        trackEvent(.operative, parameters: [.cardType: entity.trackId, .cardOperative: trackName])
    }
    
    func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity) {
        trackCardAction(action: action, entity: entity)
        coordinator.didSelectAction(action, entity)
    }
    
    func addToApplePay(_ action: OldCardActionType, _ entity: CardEntity) {
        guard case .applePay = action else { return }
        self.trackEvent(.applePay, parameters: [.cardType: entity.trackId])
        self.coordinator.goAddToApplePay(card: entity, delegate: self)
    }
    
    func didTapOnShareViewModel(_ viewModel: CardViewModel) {
        self.coordinator.didSelectShare(for: viewModel)
        self.trackEvent(.copyPan, parameters: [.cardType: viewModel.trackId])
    }
    
    func didTapOnMoreOptions() {
        guard let entity = self.selectedCardEntity else { return }
        self.coordinator.gotToMoreOptions(for: entity)
    }
    
    func showFiltersSelected() {
        guard let selectedCard = self.selectedCardEntity else { return }
        if self.activeFilter?.hasCustome() == true,
           let customeWrapper = self.activeFilter?.getCustome(),
           case .custome(let custome) = customeWrapper {
            self.activeFilter = nil
            self.view?.didRemoveFilter([
                TagMetaData(withLocalized: localized(custome.literal), accessibilityId: custome.accessibilityIdentifier)
            ])
        }
        self.coordinator.didSelectShowFilters(self, outsider: outsider, filter: self.activeFilter, card: selectedCard.representable)
    }
    
    func didApplyFilter(_ filter: TransactionFiltersEntity, _ criteria: CriteriaFilter) -> String? {
        guard let selectedCardEntity = self.selectedCardEntity else {
            return nil
        }
        self.activeFilter = filter
        self.view?.clearTransactionTable()
        self.cardTransactions = nil
        self.pendingRequest.addPagination(nil)
        self.view?.showTransactionLoadingIndicator()
        self.loadCardTransactions(for: selectedCardEntity)
        return selectedCardEntity.trackId
    }
    
    func getFilters() -> TransactionFiltersEntity? {
        return self.activeFilter
    }
    
    func downloadTransactionsSelected() {
        guard let entity = self.selectedCardEntity else { return }
        self.coordinator.didSelectDownloadTransactions(for: entity, withFilters: self.activeFilter)
    }
    
    func didSelectMenu() {
        self.coordinator.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinator.didSelectDismiss()
    }
    
    func didSelectTransaction(_ transaction: CardTransactionViewModel) {
        if let transaction = transaction.transaction as? CardTransactionEntity {
            self.gotoCardTransactionDetail(transaction)
        } else if let transaction = transaction.transaction as? CardPendingTransactionEntity {
            self.gotoCardPendingTransactionDetail(transaction)
        }
    }
    
    func gotoCardTransactionDetail(_ transactionEntity: CardTransactionEntity) {
        guard let entity = self.selectedCardEntity else { return }
        let orderedTransaction = self.cardTransactions?
            .transactions
            .sorted(by: { $0.key > $1.key })
            .flatMap { $0.value }
            .compactMap { $0 as? CardTransactionEntity } ?? []
        self.coordinator.goToTransaction(transactionEntity, in: orderedTransaction, for: entity)
    }
    
    func gotoCardPendingTransactionDetail(_ transactionEntity: CardPendingTransactionEntity) {
        guard let entity = self.selectedCardEntity else { return }
        let orderedTransaction = self.cardTransactions?
            .transactions
            .sorted { $1.key > $0.key }
            .flatMap { $0.value }
            .compactMap { $0 as? CardPendingTransactionEntity } ?? []
        self.coordinator.gotoPendingTransaction(transactionEntity, in: orderedTransaction, for: entity)
    }
    
    func doSearch() {
        guard let entity = self.selectedCardEntity else { return }
        self.coordinator.didSelectSearch(for: entity)
    }
    
    private func loadCardExtraInfo(for entity: CardEntity) {
        self.calculateExpenses(for: entity) { [weak self] response in
            self?.loadApplePaySupport(for: entity, completion: { applePayState in
                self?.determineWhichButtonToShow(entity, applePayState: applePayState, expenses: response.expenses)
            })
        }
    }
    
    func calculateExpenses(for entity: CardEntity, completion: @escaping (GetCardExpensesCalculationUseCaseOkOutput) -> Void) {
        UseCaseWrapper(
            with: self.getCardExpenses.setRequestValues(requestValues: GetCardExpensesCalculationUseCaseInput(card: entity)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { response in
                completion(response)
            }
        )
    }
    
    func getPaymentMethod(for entity: CardEntity, completion: @escaping (Bool, LocalizedStylableText) -> Void) {
        guard entity.cardType == .credit else {
            completion(false, .empty)
            return
        }
        UseCaseWrapper(
            with: self.getCardPaymentMethod.setRequestValues(requestValues: GetCardPaymentMethodUseCaseInput(card: entity)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self, let paymentMethodMode = result.currentPaymentMethodMode else { return }
                let paymentMethod = result.currentPaymentMethod
                if let description = self.selectPaymentMethod(paymentMethod, description: paymentMethodMode) {
                    completion(true, description)
                } else {
                    completion(false, .empty)
                }
            },
            onError: { _ in
                completion(false, .empty)
            }
        )
    }
    
    func selectPaymentMethod(_ method: CardPaymentMethodTypeEntity, description: String) -> LocalizedStylableText? {
        let amount = getAmount(description)
        switch method {
        case .monthlyPayment:
            return localized("cards_label_monthly")
        case .fixedFee:
            return localized("cards_label_fixedFee", [StringPlaceholder(.value, amount)])
        case .deferredPayment:
            return localized("cards_label_postpone", [StringPlaceholder(.value, amount)])
        case .minimalPayment, .immediatePayment:
            return nil
        }
    }
    
    func getAmount(_ amount: String) -> String {
        let regex = "(?:\\d+(?:\\.\\d*)?|\\.\\d+)"
        if let range = amount.range(of: regex, options: .regularExpression) {
            return String(amount[range])
        } else {
            return ""
        }
    }
    
    func didSelectInformationCardButton(for viewModel: CardViewModel, button: CardInformationButton) {
        switch button {
        case .cashDisposition:
            self.coordinator.didSelectAction(.withdrawMoneyWithCode, viewModel.entity)
        case .changePaymentMethod:
            trackEvent(.changePaymentMethod, parameters: [:])
            self.coordinator.didSelectAction(.changePaymentMethod, viewModel.entity)
        case .settlementDetail:
            trackEvent(.nextSettlement, parameters: [:])
            guard let cardSettlementDetailEntity = viewModel.settlementDetailEntity else { return }
            self.coordinator.goToNextSettlement(viewModel.entity, cardSettlementDetailEntity: cardSettlementDetailEntity, isEnabledMap: self.isMapEnable())
        default:
            break
        }
    }
    
    private func loadCards(reloaded: Bool) {
        MainThreadUseCaseWrapper(
            with: getCardsUseCase,
            onSuccess: { [weak self] response in
                self?.isEnabledMap = response.isEnabledMap
                self?.easyPaymentEnabled = response.isEasyPaymentEnabled
                self?.crossSellingEnabled = response.isCrossSellingEnabled
                self?.cardsCrossSelling = response.cardsCrossSelling
                self?.showCardsForReponse(response, reloaded: reloaded)
            })
    }
    
    private func loadScaDate() {
        Scenario(useCase: getScaDate)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                self?.scaDate = result.scaSystemDate
            }
    }
    
    private func showCardsForReponse(_ response: GetCardsHomeUseCaseOkOutput, reloaded: Bool) {
        self.isPbUser = response.isPBUser
        let showingData = self.getSelectedCard(response: response, reloaded: reloaded)
        self.view?.showCards(showingData.1, withSelected: CardViewModel(
                                showingData.0,
                                baseUrl: baseURLProvider.baseURL,
                                applePayState: .notSupported,
                                isMapEnable: isMapEnable(),
                                isEnableCashWithDrawal: isEnableCashWithDrawal(),
                                dependenciesResolver: self.dependenciesResolver,
                                maskedPAN: self.isPANMasked,
                                hideCardsImageDetails: self.isHideDetailsHomeCardConditions()))
    }
    
    // When reloading data from an operation, the configuration.selectedCard could be changed
    private func getSelectedCard(response: GetCardsHomeUseCaseOkOutput, reloaded: Bool) -> (CardEntity, [CardViewModel]) {
        let cardsEntities: [CardEntity] = response.cards
        let viewModels: [CardViewModel] = cardsEntities.map({ elem in
            if let cardId = elem.dto.contract?.contractNumber, self.cardHomeDelegate != nil {
                isPANMasked = isCardPANMasked(cardId: cardId)
                if !isPANMasked {
                    elem.representable.PAN = getCardPAN(cardId: cardId)
                }
            }
            let card = CardViewModel(elem,
                                     baseUrl: baseURLProvider.baseURL,
                                     applePayState: .notSupported,
                                     isMapEnable: isMapEnable(),
                                     isEnableCashWithDrawal: isEnableCashWithDrawal(),
                                     dependenciesResolver: self.dependenciesResolver,
                                     maskedPAN: self.isPANMasked,
                                     hideCardsImageDetails: self.isHideDetailsHomeCardConditions())
            return card
        })
        let selectedEntity: CardEntity = response.configuration.selectedCard ?? cardsEntities[0]
        guard reloaded, let index = cardsEntities.firstIndex(where: { $0.pan == selectedEntity.pan }) else {
            return (selectedEntity, viewModels)
        }
        return (cardsEntities[index], viewModels)
    }
    
    private func loadCardTransactions(for entity: CardEntity) {
        self.cardsTransactionsManager.loadTransactions(for: entity, filters: self.activeFilter, pagination: pendingRequest.nextPage()) { [weak self] result in
            self?.proccessTransactionResult(for: entity, result: result)
        }
    }
    
    private func loadCardTransationWithPendingLiquidation(for entity: CardEntity) {
        self.cardsTransactionsManager.loadPendingCardTransactions(for: entity, pagination: pendingRequest.nextPage()) { [weak self] result in
            self?.proccessTransactionResult(for: entity, result: result)
        }
    }
    
    private func proccessTransactionResult(for entity: CardEntity, result: CardTransactionResult) {
        switch result {
        case .success(let transactionList):
            self.transactionsLoaded(transactionList.transactions, for: entity)
            self.pendingRequest.addPagination(transactionList.pagination)
            self.pendingRequest.removeRequest()
        case .failure(let error):
            self.pendingRequest.removeRequest()
            guard self.cardTransactions == nil else {
                self.transactionsLoaded([], for: entity)
                return
            }
            switch error {
            case let .empty(key):
                self.transactionIsEmpty(localizedKey: key)
            case let .wsError(key):
                self.transactionsDidFail(localizedKey: key)
            }
        }
        if self.localAppConfig.isEnabledPfm {
            self.updatePfmWithReadCard()
        } 
    }
    
    private func loadApplePaySupport(for card: CardEntity, completion: @escaping (CardApplePayState) -> Void) {
        UseCaseWrapper(
            with: self.getCardApplePaySupport.setRequestValues(requestValues: GetCardApplePaySupportUseCaseInput(card: card)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                guard self.selectedCardEntity == card else { return }
                completion(result.applePayState)
            }
        )
    }
    
    private func updatePfmWithReadCard() {
        guard let selected = self.selectedCardEntity, self.pfmController.isPFMCardReady(card: selected) else { return }
        UseCaseWrapper(with: self.setReadCardTransactionsUseCase.setRequestValues(requestValues: SetReadCardTransactionsUseCaseInput(card: selected)), useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self))
    }
    
    func transactionsLoaded(_ transactions: [CardTransactionEntityProtocol], for entity: CardEntity) {
        let transactionsByDate: [Date: [CardTransactionEntityProtocol]] = transactions.reduce([:], groupTransactionsByDate)
        let transactionsByDateMerged = transactionsByDate.merging(cardTransactions?.transactions ?? [:], uniquingKeysWith: { $0 + $1 })
        cardTransactions = TransactionList(transactions: transactionsByDateMerged)
        var transactions = transactionsByDateMerged.map {
            CardTransactionsGroupViewModel(
                date: $0.key,
                transactions: $0.value,
                card: entity,
                minEasyPayAmount: self.minEasyPayAmount,
                dependenciesResolver: dependenciesResolver,
                easyPaymentEnabled: self.easyPaymentEnabled,
                crossSellingEnabled: self.crossSellingEnabled,
                cardsCrossSelling: self.cardsCrossSelling)
        }
        if let sortCardModifier = self.dependenciesResolver.resolve(forOptionalType: CardsTransactionListSortedProtocol.self)?.sortCondition {
            transactions = transactions.sorted(by: sortCardModifier)
        } else {
            transactions = defaultSorting(transactions)
        }
        self.view?.dismissTransactionsLoadingIndicator()
        
        guard let currentOptionalFilter = self.activeFilter, currentOptionalFilter.actives().count > 0 else {
            self.view?.showTransactions(transactions: transactions, cardFilterViewModel: nil)
            return
        }
        self.view?.showTransactions(transactions: transactions, cardFilterViewModel: TransactionFilterViewModel(currentOptionalFilter))
    }
    
    private func defaultSorting(_ transactions: [CardTransactionsGroupViewModel]) -> [CardTransactionsGroupViewModel] {
        if self.activeFilter != nil, self.activeFilter?.containsDescriptionFilter() == false {
            return transactions.sorted(by: { $0.date < $1.date })
        } else {
            return transactions.sorted(by: { $0.date > $1.date })
        }
    }
    
    private func transactionIsEmpty(localizedKey: String) {
        self.view?.dismissTransactionsLoadingIndicator()
        guard let currentOptionalFilter = self.activeFilter, currentOptionalFilter.actives().count > 0 else {
            self.view?.showTransactionError(localizedKey, cardFilterViewModel: nil)
            return
        }
        self.view?.showTransactionError(localizedKey, cardFilterViewModel: TransactionFilterViewModel(currentOptionalFilter))
    }
    
    private func transactionsDidFail(localizedKey: String) {
        self.view?.dismissTransactionsLoadingIndicator()
        guard let currentOptionalFilter = self.activeFilter, currentOptionalFilter.actives().count > 0 else {
            self.view?.showTransactionError(localizedKey, cardFilterViewModel: nil)
            return
        }
        self.view?.showTransactionError(localizedKey, cardFilterViewModel: TransactionFilterViewModel(currentOptionalFilter))
    }
    
    func groupTransactionsByDate(_ groupedTransactions: [Date: [CardTransactionEntityProtocol]], transaction: CardTransactionEntityProtocol) -> [Date: [CardTransactionEntityProtocol]] {
        var groupedTransactions = groupedTransactions
        guard let operationDate = transaction.transactionDate else { return groupedTransactions }
        guard
            let dateByDay = groupedTransactions.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let transactionsByDate = groupedTransactions[dateByDay]
        else {
            groupedTransactions[operationDate.startOfDay()] = [transaction]
            return groupedTransactions
        }
        groupedTransactions[dateByDay] = transactionsByDate + [transaction]
        return groupedTransactions
    }
    
    func loadMinEasyPayAmount(completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: self.minEasyPayAmountUseCase,
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                self?.minEasyPayAmount = result.minimumAmount
                completion()
            },
            onError: { _ in
                completion()
            }
        )
    }
    
    func isPANAlwaysSharable() -> Bool {
        return cardHomeDelegate?.isPANAlwaysSharable() ?? true
    }
    
    func didSelectMap() {
        trackEvent(.map, parameters: [:])
        if self.isEnabledMap {
            guard let selectedCard = self.selectedCardEntity else { return }
            self.coordinator.goToMapView(selectedCard, type: CardMapTypeConfiguration.multiple)
        } else {
            self.view?.showNotAvailable()
        }
    }
    
    private func isMapEnable() -> Bool {
        let isEnable = self.appConfig.getBool(CardConstants.isEnableCardsHomeLocationMap)
        return isEnable == true
    }
    
    private func isEnableCashWithDrawal() -> Bool {
        let isEnable = self.appConfig.getBool(CardConstants.isEnableCashWithDrawal)
        return isEnable == true
    }
    
    func didTapOnCVVViewModel(_ viewModel: CardViewModel) {
        trackEvent(.cvv, parameters: [:])
        self.coordinator.didSelectCVV(viewModel)
    }
    
    func didTapOnActivateCard(_ viewModel: CardViewModel) {
        self.coordinator.didSelectActivateCard(viewModel.entity)
    }
    
    func didTapOnShowPAN(_ viewModel: CardViewModel) {
        cardHomeDelegate?.showCardPAN(card: viewModel.entity)
    }
    
    func toolTipTrack() {
        self.trackEvent(.tooltip, parameters: [:])
    }
    
    func didTooltipVideoAction() {
        self.view?.closeTooltip { [weak self] in
            guard let self = self else { return }
            guard let offer = self.pullOfferCandidates.location(key: "CARD_TOOLBAR_TOOLTIP_VIDEO")?.offer else { return }
            self.coordinator.didSelectOffer(offer: offer)
        }
    }
    
    func didFilterRemove() {
        let hidden = !(self.selectedCardEntity?.isCreditCard == true)
        self.view?.setPendingTransactionOptions(hidden: hidden)
    }
    
    private func removePendingTransactionFilter() {
        let isPendingTransactionEnable = self.activeFilter?.actives().contains(where: {
            guard case .custome = $0 else { return false }
            return true
        }) ?? false
        guard isPendingTransactionEnable else { return }
        self.activeFilter = nil
    }
}

extension CardsHomePresenter: GlobalPositionReloadable {
    
    func reload() {
        self.loadCards(reloaded: true)
    }
}

extension CardsHomePresenter: ApplePayEnrollmentDelegate {
    func applePayEnrollmentDidFinishSuccessfully() {
        guard let selectedCard = self.selectedCardEntity else { return }
        self.view?.showApplePaySuccessView()
        let viewModel = CardViewModel(selectedCard,
                                      baseUrl: baseURLProvider.baseURL,
                                      applePayState: .active,
                                      isMapEnable: isMapEnable(),
                                      isEnableCashWithDrawal: isEnableCashWithDrawal(),
                                      dependenciesResolver: self.dependenciesResolver,
                                      maskedPAN: self.isPANMasked)
        self.cardActions(for: viewModel)
    }
    
    func applePayEnrollmentDidFinishWithError(_ error: ApplePayError) {
        // Nothing to do here
    }
}

extension CardsHomePresenter: AutomaticScreenEmmaActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: CardsHomePage {
        let emmaTrackEventList: EmmaTrackEventListProtocol = self.dependenciesResolver.resolve()
        let emmaToken = emmaTrackEventList.cardsEventID
        return CardsHomePage(emmaToken: emmaToken)
    }
}

extension CardsHomePresenter: GlobalSearchEnabledManagerProtocol {
    private func loadIsSearchEnabled() {
        getIsSearchEnabled(with: dependenciesResolver) { [weak self] (resp) in
            self?.view?.isSearchEnabled(resp)
        }
    }
}

private extension CardsHomePresenter {
    func determineWhichButtonToShow(_ entity: CardEntity, applePayState: CardApplePayState, expenses: AmountEntity) {
        getCardSettlementDetail(for: entity) { [weak self] result in
            guard let result = result else {
                self?.getPaymentMethod(for: entity, completion: { [weak self] (isSuccess, description) in
                    guard let self = self else { return }
                    self.updateCard(entity, applePayState: applePayState, expenses: expenses, isPaymentMethodSuccess: isSuccess, paymentMethodDescription: description)
                })
                return
            }
            self?.updateCard(entity, applePayState: applePayState, expenses: expenses, settlementDetail: result.cardSettlementDetailEntity, scaDate: result.scaDate)
        }
    }
    
    func updateCard(_ entity: CardEntity, applePayState: CardApplePayState, expenses: AmountEntity, isPaymentMethodSuccess: Bool = false, paymentMethodDescription: LocalizedStylableText? = nil, settlementDetail: CardSettlementDetailEntity? = nil, scaDate: Date? = nil, showLoading: Bool = false) {
        if let cardId = entity.dto.contract?.contractNumber, self.cardHomeDelegate != nil {
            isPANMasked = isCardPANMasked(cardId: cardId)
            if !isPANMasked {
                entity.representable.PAN = getCardPAN(cardId: cardId)
            }
        }
        let cardViewModel = CardViewModel(entity,
                                          baseUrl: self.baseURLProvider.baseURL,
                                          applePayState: applePayState,
                                          isMapEnable: self.isMapEnable(),
                                          isEnableCashWithDrawal: self.isEnableCashWithDrawal(),
                                          dependenciesResolver: self.dependenciesResolver,
                                          isPaymentMethodSuccess: isPaymentMethodSuccess,
                                          paymentMethodDescription: paymentMethodDescription,
                                          settlementDetailEntity: settlementDetail,
                                          scaDate: scaDate,
                                          showLoading: showLoading,
                                          maskedPAN: self.isPANMasked)
        cardViewModel.monthExpensesEntity = expenses
        self.view?.updateCard(cardViewModel)
        self.cardActions(for: cardViewModel)
    }
    
    func getCardSettlementDetail(for entity: CardEntity, completion: @escaping (GetCardSettlementDetailUseCaseOkOutput?) -> Void) {
        guard entity.cardType == .credit,
              !entity.isDisabled,
              entity.isVisible
        else {
            completion(nil)
            return
        }
        UseCaseWrapper(
            with: self.getCardSettlementDetailUseCase.setRequestValues(requestValues: GetCardSettlementDetailUseCaseInput(card: entity)),
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { result in
                completion(result)
            },
            onError: { _ in
                completion(nil)
            }
        )
    }
    
    func isCardPANMasked(cardId: String) -> Bool {
        return cardHomeDelegate?.isCardPANMasked(cardId: cardId) ?? true
    }
    
    func getCardPAN(cardId: String) -> String? {
        return cardHomeDelegate?.getCardPAN(cardId: cardId)
    }
    
    func hideMoreOptions() {
        if let cardHomeDelegate = self.cardHomeDelegate {
            self.view?.hideMoreOptionsButton(cardHomeDelegate.hideMoreOptionsButton())
        }
    }
}
