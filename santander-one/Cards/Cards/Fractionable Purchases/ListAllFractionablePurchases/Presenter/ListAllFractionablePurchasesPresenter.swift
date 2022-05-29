import CoreFoundationLib

protocol ListAllFractionablePurchasesPresenterProtocol {
    var view: ListAllFractionablePurchasesViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectItem(_ viewModel: FractionablePurchaseViewModel)
    func seeFractionateOptions(viewModel: FractionablePurchaseViewModel)
}

final class ListAllFractionablePurchasesPresenter {
    weak var view: ListAllFractionablePurchasesViewProtocol?
    internal let dependenciesResolver: DependenciesResolver
    var selectedCard: CardEntity?
    var selectedTransaction: FinanceableTransaction?
    private var getCardFinanceableTransactionsUseCase: GetCardFinanceableTransactionsUseCase {
        dependenciesResolver.resolve(firstTypeOf: GetCardFinanceableTransactionsUseCase.self)
    }
    lazy var getAllFractionablePurchasesSuperUseCase: GetAllFractionablePurchasesSuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetAllFractionablePurchasesSuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    lazy var getCardTransactionEasyPaySuperUseCase: GetCardTransactionEasyPaySuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetCardTransactionEasyPaySuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()

    var viewModel: FractionablePurchaseViewModel?
    var viewModelDict: [Date: [FractionablePurchaseViewModel]] = [:]

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
}

private extension ListAllFractionablePurchasesPresenter {
    var coordinator: ListAllFractionablePurchasesCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: ListAllFractionablePurchasesCoordinatorProtocol.self)
    }

    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
}

extension ListAllFractionablePurchasesPresenter: ListAllFractionablePurchasesPresenterProtocol {
    func viewDidLoad() {
        self.getAllFractionablePurchases()
        trackScreen()
    }

    func didSelectDismiss() {
        self.coordinator.dismiss()
    }

    func didSelectMenu() {
        self.coordinator.didSelectMenu()
    }

    func getAllFractionablePurchases() {
        self.getAllFractionablePurchasesSuperUseCase.execute()
        self.view?.showLoading(true)
    }

    func didSelectItem(_ viewModel: FractionablePurchaseViewModel) {
        trackEvent(.goToDetail)
        self.coordinator.goToDetail(viewModel.cardTransaction, card: viewModel.getCardEntity())
    }

    func seeFractionateOptions(viewModel: FractionablePurchaseViewModel) {
        self.viewModel = viewModel
        self.toggleExpandedView()
        if !viewModel.isExpanded, viewModel.transaction == nil {
            self.updateWithTransactionScenario(viewModel.getCardEntity())
        }
    }

    // MARK: - SeeFractionableOptions

    func toggleExpandedView(forceCollapsed: Bool = false) {
        var tempViewModelDict: [Date: [FractionablePurchaseViewModel]] = [:]
        for key in self.viewModelDict.keys {
            guard let movements: [FractionablePurchaseViewModel] = self.viewModelDict[key] else { continue }
            var tempMovements: [FractionablePurchaseViewModel] = []
            movements.forEach({ movement in
                var newTransaction = movement
                if let viewModel = self.viewModel, movement.identifier == viewModel.identifier, movement.getCardEntity().pan == viewModel.getCardEntity().pan {
                    if forceCollapsed {
                        newTransaction.isExpanded = false
                    } else {
                        newTransaction.isExpanded.toggle()
                    }
                    if newTransaction.isExpanded {
                        trackEvent(.showFractionateOptions)
                    }
                } else {
                    newTransaction.isExpanded = false
                }
                tempMovements.append(newTransaction)
            })
            tempViewModelDict[key] = tempMovements
        }
        self.viewModelDict = tempViewModelDict
        createViewModel(self.viewModelDict)
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
                guard let transaction = newTransactionViewModel?.financeableTransaction.transaction else {
                    self.updateFractionatePaymentViewOnError()
                    return
                }
                self.selectedTransaction = newTransactionViewModel?.financeableTransaction
                self.getCardTransactionEasyPaySuperUseCase.requestValue(card: card, transaction: transaction)
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
                  let transactionAmountValue = transaction.amount?.value,
                  let transactionId = transaction.identifier,
                  let vmAmountValue = viewModel?.amount?.value,
                  let vmDate = viewModel?.date,
                  let vmId = viewModel?.identifier
            else {
                return
            }
            let isAmount = transactionAmountValue == vmAmountValue
            let isDate = transactionDate == vmDate
            let isId = transactionId == vmId
            guard isAmount, isDate, isId else { return }
            let transactionViewModel = CardListFinanceableTransactionViewModel(card: financeableTransactionOutput.card, financeableTransaction: financeableTransaction)
            newTransactionViewModel = transactionViewModel
        }
        return newTransactionViewModel
    }

    // MARK: Methods used in GetCardTransactionEasyPay SuperUseCase callBacks
    func updateFractionatePaymentViewOnError() {
        didFinishCardTransactionEasyPayWithError(nil)
    }

    func updateFractionatePaymentViewOnSuccess(_ easyPayOperativeData: EasyPayOperativeDataEntity, fractionatePayment: FractionatePaymentEntity) {
        guard let viewModel = self.viewModel,
              let selectedTransaction = self.selectedTransaction else { return }
        var tempViewModelDict: [Date: [FractionablePurchaseViewModel]] = [:]
        for key in self.viewModelDict.keys {
            guard let movements: [FractionablePurchaseViewModel] = self.viewModelDict[key] else { continue }
            var tempMovements: [FractionablePurchaseViewModel] = []
            movements.forEach({ movement in
                var newMovement = movement
                if movement.identifier == viewModel.identifier {
                    let newFinanciableTransactionVM = CardListFinanceableTransactionViewModel(card: viewModel.getCardEntity(), financeableTransaction: FinanceableTransaction(transaction: selectedTransaction.transaction))
                    newFinanciableTransactionVM.financeableTransaction.easyPayOperativeData = easyPayOperativeData
                    newFinanciableTransactionVM.financeableTransaction.fractionatedPayment = fractionatePayment
                    newFinanciableTransactionVM.easyPayAction = self.didSelectEasyPayFee
                    newMovement.transaction = newFinanciableTransactionVM
                    newMovement.isExpanded = true
                }
                tempMovements.append(newMovement)
            })
            tempViewModelDict[key] = tempMovements
        }
        self.viewModelDict = tempViewModelDict
        createViewModel(self.viewModelDict)
    }

    func didSelectEasyPayFee(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?) {
        let operativeData = easyPayOperativeData?.easyPayAmortization != nil ? easyPayOperativeData : nil
        self.coordinator.gotoCardEasyPayOperative(card: card,
                                                  transaction: transaction,
                                                  easyPayOperativeData: operativeData)
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
}

extension ListAllFractionablePurchasesPresenter: AutomaticScreenActionTrackable {
    var trackerPage: EasyPayAllFractionablePurchasesPage {
        EasyPayAllFractionablePurchasesPage()
    }

    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }

    func trackEvent(_ action: EasyPayAllFractionablePurchasesPage.Action, parameters: [String: String] = [:]) {
        trackerManager.trackEvent(screenId: trackerPage.page,
                                  eventId: action.rawValue,
                                  extraParameters: parameters)
    }
}

extension ListAllFractionablePurchasesPresenter: GetAllFractionablePurchasesSuperUseCaseDelegate {
    func didFinishGetAllPurchasesSuccessfully(with fractionablePurchases: [GetAllFractionablePurchasesOutput]) {
        self.view?.showLoading(false)
        var allFinanciableMovements: [FractionablePurchaseViewModel] = []
        fractionablePurchases.forEach({ movementsByCard in
            let movementsList: [FinanceableMovementEntity] = movementsByCard.getFinanceableMovements()
            let movementsListViewModel = movementsList.map {
                FractionablePurchaseViewModel(
                    cardEntity: movementsByCard.getCardEntity(),
                    financeableMovementEntity: $0,
                    timeManager: timeManager
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
        self.viewModelDict = allFinanciableMovementsDict
        self.createViewModel(self.viewModelDict)
    }

    private func getId(for financiableMovementEntity: FinanceableMovementEntity) -> String? {
        guard let date = financiableMovementEntity.dto.operationDate, let movDay = financiableMovementEntity.dto.transactionDay else { return nil }
        return "\(date)_\(movDay)"
    }

    func createViewModel(_ movements: [Date: [FractionablePurchaseViewModel]]) {
        var viewModel: [ListAllFractionablePurchasesByDayViewModel] = []
        let movementsSorted = movements.keys.sorted(by: { $0.compare($1) == .orderedDescending })
        movementsSorted.forEach({ key in
            var movementsListByDay: [FractionablePurchaseViewModel] = []
            guard let movements = movements[key] else { return }
            movements.forEach({ movement in
                movementsListByDay.append(movement)
            })
            viewModel.append(ListAllFractionablePurchasesByDayViewModel(movementsListByDay, date: key, dependenciesResolver: self.dependenciesResolver))
        })
        if viewModel.isEmpty {
            self.view?.showEmptyView()
        } else {
            self.view?.showFractionableMovements(viewModel)
        }
    }

    func didFinishWithError(error: String?) {
        self.view?.showLoading(false)
        self.view?.showEmptyView()
    }
}

extension ListAllFractionablePurchasesPresenter: GetCardTransactionEasyPaySuperUseCaseDelegate {
    func didFinishCardTransactionEasyPaySuccessfully(with cardTransactionEasyPay: CardTransactionEasyPay) {
        let fractionatePayment = self.getFractionatePayment(cardTransactionEasyPay)
        self.updateFractionatePaymentViewOnSuccess(cardTransactionEasyPay.easyPayOperativeData, fractionatePayment: fractionatePayment)
        self.clearRequest()
    }

    func didFinishCardTransactionEasyPayWithError(_ error: String?) {
        toggleExpandedView(forceCollapsed: true)
        self.clearRequest()
        let stringLoader: StringLoader = self.dependenciesResolver.resolve()
        var errorWS = error != nil ? stringLoader.getWsErrorString(error ?? "") : localized("generic_error_alert_text")
        self.view?.showOldDialog(title: nil,
                                 description: errorWS.capitalizedBySentence(),
                                 acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
                                 cancelAction: nil,
                                 isCloseOptionAvailable: false)
    }
}
