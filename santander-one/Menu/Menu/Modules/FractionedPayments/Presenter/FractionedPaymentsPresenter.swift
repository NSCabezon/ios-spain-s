import CoreFoundationLib

protocol FractionedPaymentsPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: FractionatedPaymentsViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectInSeeMoreCards()
    func didSelectFractionedPaymentMovement(_ viewModel: FractionablePurchaseViewModel)
    func didSelectSeeFrationateOptions(_ viewModel: FractionablePurchaseViewModel)
}

protocol FractionedPymentsPresenterDataProtocol: AnyObject {
    func createViewModel(_ movements: [Date: [FractionablePurchaseViewModel]]) -> [FractionedPaymentsViewModel]
    func setFractionedMovements(_ fractionablePurchases: [GetAllFractionedPaymentsForCardOutput]) -> [Date: [FractionablePurchaseViewModel]]
    func setAllCards(_ cards: [CardEntity])
    func setCardsPendingToProcess(_ cards: [CardEntity])
    func setSelectedTransaction(_ transaction: FinanceableTransaction)
}

final class FractionedPaymentsPresenter {
    weak var view: FractionatedPaymentsViewProtocol?
    let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    lazy var getAllFractionablePurchasesSuperUseCase: GetAllFractionedPaymentsForCardSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetAllFractionedPaymentsForCardSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    lazy var getCardTransactionEasyPaySuperUseCase: GetCardTransactionEasyPaySuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetCardTransactionEasyPaySuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    var getCardFinanceableTransactionsUseCase: GetCardFinanceableTransactionsUseCase {
        dependenciesResolver.resolve(firstTypeOf: GetCardFinanceableTransactionsUseCase.self)
    }
    var selectedCard: CardEntity?
    var selectedTransaction: FinanceableTransaction?
    fileprivate var fractionablePurchases = FractionablePurchases()
    fileprivate var paymentCards = PaymentCards()
}

private extension FractionedPaymentsPresenter {
    struct FractionablePurchases {
        var movementViewModel: FractionablePurchaseViewModel?
        var viewModelDict: [Date: [FractionablePurchaseViewModel]] = [:]
    }
    struct PaymentCards {
        var pendingToProcess: [CardEntity]?
        var cardsToRetrieve: [CardEntity] = []
        var allCards: [CardEntity] = []
        let numOfCards: Int = 3
    }
    var coordinator: FractionedPaymentsCoordinatorDelegate {
        dependenciesResolver.resolve(for: FractionedPaymentsCoordinatorDelegate.self)
    }
    var useCaseHandler: UseCaseHandler {
        dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var timeManager: TimeManager {
        dependenciesResolver.resolve(for: TimeManager.self)
    }
    var getVisibleCardsUseCase: GetVisibleCardsUseCase {
        dependenciesResolver.resolve(for: GetVisibleCardsUseCase.self)
    }
    
    // MARK: - Display customViews
    func showFractionatedPaymentsView() {
        let paymentModel = createViewModel(fractionablePurchases.viewModelDict)
        guard !paymentModel.isEmpty else {
            view?.showEmptyView()
            return
        }
        view?.showFractionatedPayments(paymentModel)
        showSeeMoreCardsFooterIfNeeded()
    }
    func showSeeMoreCardsFooterIfNeeded() {
        guard let pendingCards = paymentCards.pendingToProcess,
              !pendingCards.isEmpty,
              pendingCards.count > 0
        else {
            return
        }
        view?.showSeeMoreCardsView()
    }
    
    // MARK: SeeFractionableOptions
    func toggleExpandedView(forceCollapsed: Bool = false) {
        var tempViewModelDict: [Date: [FractionablePurchaseViewModel]] = [:]
        for key in fractionablePurchases.viewModelDict.keys {
            guard let movements: [FractionablePurchaseViewModel] = fractionablePurchases.viewModelDict[key] else { continue }
            var tempMovements: [FractionablePurchaseViewModel] = []
            movements.forEach({ movement in
                var newTransaction = movement
                if let viewModel = fractionablePurchases.movementViewModel, movement.identifier == viewModel.identifier, movement.getCardEntity().pan == viewModel.getCardEntity().pan {
                    if forceCollapsed {
                        newTransaction.setMovementExpanded(false)
                    } else {
                        newTransaction.setMovementExpanded(!newTransaction.getIsExpanded())
                    }
                    if newTransaction.getIsExpanded() {
                        trackEvent(.unfoldOptions)
                    }
                } else {
                    newTransaction.setMovementExpanded(false)
                }
                newTransaction.setMovementExpanded(newTransaction.getIsExpanded())
                tempMovements.append(newTransaction)
            })
            tempViewModelDict[key] = tempMovements
        }
        fractionablePurchases.viewModelDict = tempViewModelDict
    }

    func updateWithTransactionScenario(_ card: CardEntity) {
        var newTransactionViewModel: CardListFinanceableTransactionViewModel?
        let input = GetCardFinanceableTransactionsUseCaseInput(card: card)
        let useCase = getCardFinanceableTransactionsUseCase
        Scenario(useCase: useCase, input: input)
            .execute(on: self.useCaseHandler)
            .onSuccess { financeableTransactionOutput in
                let transaction = self.matchSubscriptionTransaction(financeableTransactionOutput)
                newTransactionViewModel = transaction
            }
            .onError { _ in
                newTransactionViewModel = nil
            }
            .finally {
                guard let transaction = newTransactionViewModel?.financeableTransaction.transaction,
                      let selectedTransaction = newTransactionViewModel?.financeableTransaction
                else {
                    self.updateFractionatePaymentViewOnError()
                    return
                }
                self.getCardTransactionEasyPaySuperUseCase.cancel()
                self.setSelectedTransaction(selectedTransaction)
                self.getCardTransactionEasyPaySuperUseCase.requestValue(
                    card: card,
                    transaction: transaction
                )
                self.getCardTransactionEasyPaySuperUseCase.execute()
            }
    }

    func matchSubscriptionTransaction(_ financeableTransactionOutput: GetCardFinanceableTransactionsUseCaseOkOutput) -> CardListFinanceableTransactionViewModel? {
        let financeableTransactions = financeableTransactionOutput.transations.map(FinanceableTransaction.init)
        var newTransactionViewModel: CardListFinanceableTransactionViewModel?
        financeableTransactions.forEach { financeableTransaction in
            let transaction = financeableTransaction.transaction
            guard transaction.amount?.value != nil,
                  let transactionDate = transaction.operationDate,
                  var transactionAmountValue = transaction.amount?.value,
                  let transactionId = transaction.identifier,
                  var vmAmountValue = fractionablePurchases.movementViewModel?.amount?.value,
                  let vmDate = fractionablePurchases.movementViewModel?.date,
                  let vmId = fractionablePurchases.movementViewModel?.identifier
            else {
                return
            }
            let isAmount = NSDecimalCompact(&transactionAmountValue) == NSDecimalCompact(&vmAmountValue)
            let isDate = transactionDate == vmDate
            let isId = transactionId == vmId
            guard isAmount, isDate, isId else {
                return
            }
            let transactionViewModel = CardListFinanceableTransactionViewModel(
                card: financeableTransactionOutput.card,
                financeableTransaction: financeableTransaction
            )
            newTransactionViewModel = transactionViewModel
        }
        return newTransactionViewModel
    }

    // MARK: - Methods used in GetCardTransactionEasyPay SuperUseCase callBacks
    func updateFractionatePaymentViewOnError() {
        didFinishCardTransactionEasyPayWithError(nil)
    }

    func updateFractionatePaymentViewOnSuccess(_ easyPayOperativeData: EasyPayOperativeDataEntity,
                                               fractionatePayment: FractionatePaymentEntity) {
        let tempViewModelDict = updateFractionedPaymentsWithCardTransactions(
            easyPayOperativeData,
            fractionatePayment: fractionatePayment
        )
        fractionablePurchases.viewModelDict = tempViewModelDict
        showFractionatedPaymentsView()
    }

    func didSelectEasyPayFee(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?) {
        let operativeData = easyPayOperativeData?.easyPayAmortization != nil ? easyPayOperativeData : nil
        self.coordinator.gotoCardEasyPayOperative(
            card: card,
            transaction: transaction,
            easyPayOperativeData: operativeData
        )
        trackEvent(.unfoldOptionsEasyPay)
    }

    func getFractionatePayment(_ cardTransactionEasyPay: CardTransactionEasyPay) -> FractionatePaymentEntity {
        var items = cardTransactionEasyPay.fractionatePayment.montlyFeeItems
        var fractionatePayment = cardTransactionEasyPay.fractionatePayment
        if self.selectedCard?.isAllInOne == true, items.count >= 2, items[1].months == 3 {
            items.swapAt(0, 1)
            fractionatePayment.montlyFeeItems = items
        }
        return fractionatePayment
    }

    func clearRequest() {
        self.selectedTransaction = nil
        self.selectedCard = nil
    }
    
    func updateFractionedPaymentsWithCardTransactions(_ easyPayOperativeData: EasyPayOperativeDataEntity,
                                                      fractionatePayment: FractionatePaymentEntity) -> [Date: [FractionablePurchaseViewModel]] {
        guard let viewModel = fractionablePurchases.movementViewModel,
              let selectedTransaction = self.selectedTransaction else {
                  return [:]
              }
        var tempViewModelDict: [Date: [FractionablePurchaseViewModel]] = [:]
        for key in fractionablePurchases.viewModelDict.keys {
            guard let movements: [FractionablePurchaseViewModel] = fractionablePurchases.viewModelDict[key] else {
                continue
            }
            var tempMovements: [FractionablePurchaseViewModel] = []
            movements.forEach({ movement in
                var newMovement = movement
                if movement.identifier == viewModel.identifier, movement.getCardEntity().pan == viewModel.getCardEntity().pan {
                    let newFinanciableTransactionVM = CardListFinanceableTransactionViewModel(
                        card: viewModel.getCardEntity(),
                        financeableTransaction: FinanceableTransaction(transaction: selectedTransaction.transaction)
                    )
                    newFinanciableTransactionVM.financeableTransaction.easyPayOperativeData = easyPayOperativeData
                    newFinanciableTransactionVM.financeableTransaction.fractionatedPayment = fractionatePayment
                    newFinanciableTransactionVM.easyPayAction = self.didSelectEasyPayFee
                    newMovement.setMovementTransaction(newFinanciableTransactionVM)
                }
                tempMovements.append(newMovement)
            })
            tempViewModelDict[key] = tempMovements
        }
        return tempViewModelDict
    }
    
    // MARK: - Methods for create viewModels
    func getAllMovementsByDay(_ movements: [Date: [FractionablePurchaseViewModel]]) -> [FractionablePurchaseViewModel] {
        var movementsListByDay: [FractionablePurchaseViewModel] = []
        let movementsSorted = movements.keys.sorted(by: { $0.compare($1) == .orderedDescending })
        movementsSorted.forEach({ key in
            guard let movements = movements[key] else { return }
            movements.forEach({ movement in
                var editedMovement = movement
                editedMovement.setMovementAssociatedCard(movement.getCardEntity())
                editedMovement.setMovementExpanded(movement.getIsExpanded())
                movementsListByDay.append(editedMovement)
            })
        })
        return movementsListByDay
    }
    
    func getMatchingMovements(card: CardEntity, date: Date, movements: [FractionablePurchaseViewModel]) -> [FinanceableMovementEntity] {
        var matchingMovements: [FinanceableMovementEntity] = []
        let movementsForCurrentDate = getAllMovementsForDate(movementsListByDay: movements,
                                                             date: date)
        movementsForCurrentDate.forEach({ currentMovement in
            if let pan = currentMovement.getAssociatedCard()?.pan, pan == card.pan {
                var mov = currentMovement
                if currentMovement.getIsExpanded() {
                    mov.setIsExpanded(currentMovement.getIsExpanded())
                }
                matchingMovements.append(mov)
            }
        })
        return matchingMovements
    }
    
    func getDetailViewModel(date: Date, matchingMovements: [FinanceableMovementEntity]) -> FractionedPaymentsDetailMovementsViewModel? {
        var convertedPurchases: [FractionablePurchaseViewModel] = []
        var pillWithMovementsViewModel: FractionedPaymentsDetailMovementsViewModel?
        if matchingMovements.count > 0 {
            matchingMovements.forEach { entity in
                guard let card = entity.getAssociatedCard() else {
                    return
                }
                var value = FractionablePurchaseViewModel(cardEntity: card,
                                                          financeableMovementEntity: entity,
                                                          timeManager: self.timeManager)
                value.setMovementExpanded(entity.getIsExpanded())
                convertedPurchases.append(value)
            }
            let pillMovementViewModel = FractionedPaymentsDetailMovementsViewModel(
                convertedPurchases,
                date: date,
                dependenciesResolver: self.dependenciesResolver
            )
            return pillMovementViewModel
        }
        return pillWithMovementsViewModel
    }
    
    func getUniqueDatesForAllMovements(movementsListByDay: [FractionablePurchaseViewModel]) -> [Date] {
        var allDates: [Date] = []
        movementsListByDay.forEach({ movement in
            if !allDates.contains(movement.date) {
                allDates.append(movement.date)
            }
        })
        return allDates
    }
                
    func getAllMovementsForDate(movementsListByDay: [FractionablePurchaseViewModel], date: Date) -> [FinanceableMovementEntity] {
        let entities: [FinanceableMovementEntity] = movementsListByDay
            .filter({ $0.getFinanceableMovementEntity().date == date })
            .map({ $0.getFinanceableMovementEntity() })
        return entities
    }

    // MARK: - FractionablePayments Pagination
    func loadFirstFractionedPaymentsForCards(_ cards: [CardEntity]) {
        let initialCards = cards.filter { $0.isCreditCard && $0.isCardContractHolder && !$0.isDisabled }
        if !initialCards.isEmpty, initialCards.count > 0 {
            paymentCards.allCards = initialCards
            retrieveFractionedPaymentsFor(initialCards)
        }
    }
    
    func retrieveFractionedPaymentsFor(_ cards: [CardEntity]) {
        if !cards.isEmpty, cards.count > paymentCards.numOfCards {
            let cardsPendingToProcess = Array(cards[paymentCards.numOfCards...cards.count-1])
            setCardsPendingToProcess(cardsPendingToProcess)
            paymentCards.cardsToRetrieve = Array(cards[0...paymentCards.numOfCards-1])
            getAllFractionablePurchasesSuperUseCase.loadFractionablePurchasesForCard(paymentCards.cardsToRetrieve)
        } else if cards.count > 0, cards.count <= paymentCards.numOfCards {
            getAllFractionablePurchasesSuperUseCase.loadFractionablePurchasesForCard(cards)
            paymentCards.cardsToRetrieve = cards
            setCardsPendingToProcess([])
        }
    }

    func addDownloadedViewModels(_ movements: [Date: [FractionablePurchaseViewModel]]) {
        let mergedDictionary = fractionablePurchases.viewModelDict.merging(movements, uniquingKeysWith: { $0 + $1 })
        fractionablePurchases.viewModelDict = mergedDictionary
    }
    
    func executeAutomaticPagination() {
        guard let cards = paymentCards.pendingToProcess else {
            view?.dismissLoading(completion: {
                self.view?.showEmptyView()
            })
            return
        }
        retrieveFractionedPaymentsFor(cards)
    }
    
    func checkIfPaginationNeeded(movements: [Date: [FractionablePurchaseViewModel]]) {
        if let pendingCards = paymentCards.pendingToProcess,
            !pendingCards.isEmpty,
            movements.isEmpty {
            executeAutomaticPagination()
        } else {
            view?.dismissLoading(completion: {
                self.addDownloadedViewModels(movements)
                self.showFractionatedPaymentsView()
            })
        }
    }
    
    func getErrorMessage(_ error: String?) -> String {
        let stringLoader: StringLoader = self.dependenciesResolver.resolve()
        var errorText = ""
        if error != nil {
            errorText = stringLoader.getWsErrorString(error ?? "").text
        } else {
            errorText = localized("generic_error_alert_text")
        }
        return errorText
    }
}

// MARK: - Methods for handling data and creating [FractionedPayments]
extension FractionedPaymentsPresenter: FractionedPymentsPresenterDataProtocol {
    func setSelectedTransaction(_ transaction: FinanceableTransaction) {
        selectedTransaction = transaction
    }
    
    func setAllCards(_ cards: [CardEntity]) {
        paymentCards.allCards = cards
    }
    
    func setCardsPendingToProcess(_ cards: [CardEntity]) {
        paymentCards.pendingToProcess = cards
    }
    
    func setFractionedMovements(_ fractionablePurchases: [GetAllFractionedPaymentsForCardOutput]) -> [Date: [FractionablePurchaseViewModel]] {
        var allFinanciableMovements: [FractionablePurchaseViewModel] = []
        fractionablePurchases.forEach({ movementsByCard in
            let movementsList: [FinanceableMovementEntity] = movementsByCard.getFinanceableMovements()
            let movementsListViewModel = movementsList.map {
                FractionablePurchaseViewModel(
                    cardEntity: movementsByCard.getCardEntity(),
                    financeableMovementEntity: $0,
                    timeManager: self.timeManager
                )
            }
            allFinanciableMovements.append(contentsOf: movementsListViewModel)
        })
        allFinanciableMovements.sort { return $0.date.compare($1.date) == .orderedDescending }
        var allFinanciableMovementsDict: [Date: [FractionablePurchaseViewModel]] = [:]
        allFinanciableMovements.forEach { movement in
            let date = movement.date.startOfDay().getUtcDate() ?? Date()
            if allFinanciableMovementsDict[date] == nil {
                allFinanciableMovementsDict[date] = [movement]
            } else {
                allFinanciableMovementsDict[date]?.append(movement)
            }
        }
        return allFinanciableMovementsDict
    }
    
    func createViewModel(_ movements: [Date: [FractionablePurchaseViewModel]]) -> [FractionedPaymentsViewModel] {
        let movementsListByDay = self.getAllMovementsByDay(movements)
        guard paymentCards.allCards.count > 0, !movementsListByDay.isEmpty else {
            return []
        }
        var paymentsViewModels: [FractionedPaymentsViewModel] = []
        let allDates = getUniqueDatesForAllMovements(movementsListByDay: movementsListByDay)
        paymentCards.allCards.forEach({ card in
            var pillDetailViewModels: [FractionedPaymentsDetailMovementsViewModel] = []
            allDates.forEach({ date in
                let matchingMovements = getMatchingMovements(card: card,
                                                             date: date,
                                                             movements: movementsListByDay)
                if let detailViewModel = getDetailViewModel(date: date,
                                                            matchingMovements: matchingMovements) {
                    pillDetailViewModels.append(detailViewModel)
                }
            })
            let paymentViewModel = FractionedPaymentsViewModel(
                cardEntity: card,
                fractionedPaymentMovements: pillDetailViewModels
            )
            paymentsViewModels.append(paymentViewModel)
        })
        let filteredViewModels = paymentsViewModels.filter({ !$0.fractionedPaymentMovements.isEmpty })
        return filteredViewModels
    }
}

// MARK: - Handle Presenter view protocol
extension FractionedPaymentsPresenter: FractionedPaymentsPresenterProtocol {
    func viewDidLoad() {
        view?.showLoading()
        getAllFractionablePurchases()
        trackScreen()
    }

    func didSelectDismiss() {
        coordinator.didSelectDismiss()
    }

    func didSelectMenu() {
        coordinator.didSelectMenu()
    }
    
    func getAllFractionablePurchases() {
        Scenario(useCase: self.getVisibleCardsUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] result in
                self?.setCardsPendingToProcess(result.cards)
            }
            .finally {
                guard let pendingCards = self.paymentCards.pendingToProcess else {
                    self.view?.showEmptyView()
                    return
                }
                self.loadFirstFractionedPaymentsForCards(pendingCards)
            }
    }

    func didSelectFractionedPaymentMovement(_ viewModel: FractionablePurchaseViewModel) {
        coordinator.goToFractionedPaymentDetail(
            viewModel.cardTransaction,
            card: viewModel.getCardEntity()
        )
        trackEvent(.clickDetail)
    }

    func didSelectSeeFrationateOptions(_ viewModel: FractionablePurchaseViewModel) {
        fractionablePurchases.movementViewModel = viewModel
        toggleExpandedView()
        showFractionatedPaymentsView()
        if !viewModel.getIsExpanded(), viewModel.getMovementTransaction() == nil {
            updateWithTransactionScenario(viewModel.getCardEntity())
        }
    }
    
    func didSelectInSeeMoreCards() {
        view?.showLoading()
        executeAutomaticPagination()
        trackEvent(.seeMoreCards)
    }
}

extension FractionedPaymentsPresenter: AutomaticScreenActionTrackable {
    var trackerPage: FractionedPaymentsPage {
        FractionedPaymentsPage()
    }

    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }

    func trackEvent(_ action: FractionedPaymentsPage.Action, parameters: [String: String] = [:]) {
        trackerManager.trackEvent(
            screenId: trackerPage.page,
            eventId: action.rawValue,
            extraParameters: parameters
        )
    }
}

// MARK: SuperUseCases callBacks
extension FractionedPaymentsPresenter: GetAllFractionedPaymentsForCardSuperUseCaseDelegate {
    func didFinishGetAllPurchasesSuccessfully(with fractionablePurchases: [GetAllFractionedPaymentsForCardOutput]) {
        let movements = setFractionedMovements(fractionablePurchases)
        checkIfPaginationNeeded(movements: movements)
    }

    func didFinishWithError(error: String?) {
        self.view?.dismissLoading(completion: {
            self.view?.showEmptyView()
        })
    }
}

extension FractionedPaymentsPresenter: GetCardTransactionEasyPaySuperUseCaseDelegate {
    func didFinishCardTransactionEasyPaySuccessfully(with cardTransactionEasyPay: CardTransactionEasyPay) {
        let fractionatePayment = self.getFractionatePayment(cardTransactionEasyPay)
        self.updateFractionatePaymentViewOnSuccess(
            cardTransactionEasyPay.easyPayOperativeData,
            fractionatePayment: fractionatePayment
        )
        self.clearRequest()
    }

    func didFinishCardTransactionEasyPayWithError(_ error: String?) {
        self.toggleExpandedView(forceCollapsed: true)
        self.showFractionatedPaymentsView()
        self.clearRequest()
        let errorText = getErrorMessage(error)
        view?.showErrorView(errorText)
    }
}
