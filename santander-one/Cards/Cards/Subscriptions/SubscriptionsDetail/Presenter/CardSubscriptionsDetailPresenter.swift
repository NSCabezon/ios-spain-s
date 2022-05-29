//
//  CardSubscriptionsDetailPresenter.swift
//  Cards
//
//  Created by Ignacio González Miró on 7/4/21.
//

import CoreFoundationLib

public protocol CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol: AnyObject {
    func updateSubscriptionSwitch()
}

protocol CardSubscriptionsDetailPresenterProtocol {
    var view: CardSubscriptionsDetailViewProtocol? { get set }
    func viewDidLoad()
    func dismiss()
    func didTapInSubscriptionSwitch(_ isOn: Bool)
    func didTapInSeeMorePayments(_ isOpen: Bool)
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionDetailHistoricViewModel)
}

final class CardSubscriptionsDetailPresenter {
    weak var view: CardSubscriptionsDetailViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private var historicViewModels: [CardSubscriptionDetailHistoricViewModel]?
    private var cardSubscriptionViewModel: CardSubscriptionViewModel?
    private var getCardFinanceableTransactionsUseCase: GetCardFinanceableTransactionsUseCase {
        dependenciesResolver.resolve(firstTypeOf: GetCardFinanceableTransactionsUseCase.self)
    }
    private var selectedFractionableTransactionviewModel: CardSubscriptionDetailHistoricViewModel?
    
    lazy var getCardTransactionEasyPaySuperUseCase: GetCardTransactionEasyPaySuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetCardTransactionEasyPaySuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension CardSubscriptionsDetailPresenter: CardSubscriptionsDetailPresenterProtocol {
    // MARK: View
    func viewDidLoad() {
        self.loadData()
    }
        
    // MARK: Actions
    func dismiss() {
        coordinator.dismiss()
    }
    
    func didTapInSubscriptionSwitch(_ isOn: Bool) {
        let config = self.updateSubscriptionPopupConfiguration(isOn)
        self.view?.showOptionsToUpdateSubscription(
            title: config.title, body: config.body, action: config.action, onActionable: { _ in
                guard let detailViewModel = self.cardSubscriptionViewModel,
                      let card = detailViewModel.card else {
                    return
                }
                self.trackUpdateSubscription(isOn)
                self.coordinator.showActivateSubscription(card: card, subscription: detailViewModel.cardSubscription, subscriptionIsOn: !isOn, delegate: self)
            })
    }
    
    // MARK: Historic Actions
    func didTapInSeeMorePayments(_ isOpen: Bool) {
        guard let viewModels =  historicViewModels, !viewModels.isEmpty else {
            return
        }
        trackEvent(.seeInactiveShops, parameters: [:])
        view?.updateHistoricView(viewModels, isOpen: !isOpen)
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        self.selectedFractionableTransactionviewModel = viewModel
        trackEvent(.fractionatedSubscription, parameters: [.cardOperative: trackerPage.easyPay])
        if viewModel.transactionViewModel?.isExpanded ?? false {
            self.showSeeFractionableOptionsClosed(viewModel)
        } else {
            showSeeFractionableOptionsLoadingView(viewModel)
            guard let card = configuration.detailViewModel.card else {
                return
            }
            self.updateHistoricsWithTransactionScenario(card)
        }
    }
}

private extension CardSubscriptionsDetailPresenter {
    var coordinator: CardSubscriptionDetailCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: CardSubscriptionDetailCoordinatorDelegate.self)
    }
    
    var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }
            
    var getGraphDataUseCase: GetSubscriptionGraphDataUseCase {
        self.dependenciesResolver.resolve(for: GetSubscriptionGraphDataUseCase.self)
    }
    
    var getHistoricalUseCase: GetSubscriptionHistoricalUseCase {
        self.dependenciesResolver.resolve(for: GetSubscriptionHistoricalUseCase.self)
    }
    
    var configuration: CardSubscriptionDetailConfiguration {
        return self.dependenciesResolver.resolve(for: CardSubscriptionDetailConfiguration.self)
    }
    
    var useCaseHandler: UseCaseScheduler {
        return self.dependenciesResolver.resolve()
    }
        
    func loadData() {
        trackScreen()
        view?.showLoadingView { [weak self] in
            guard let self = self else { return }
            self.view?.configCardSubscriptionDetailView(self.configuration.detailViewModel)
            self.loadAllInformation()
        }
    }
    
    func loadAllInformation() {
        let monthsAgoDate = Calendar.current.date(byAdding: .month, value: -25, to: Date())
        guard let pan = configuration.detailViewModel.cardSubscription.formattedPAN,
            let instaId = configuration.detailViewModel.cardSubscription.instaId,
            let dateTo = timeManager.toString(date: Date(), outputFormat: .yyyyMMdd, timeZone: .local),
            let dateFrom = timeManager.toString(date: monthsAgoDate, outputFormat: .yyyyMMdd)
        else {
            self.showGenericError()
            view?.hideLoadingView()
            return
        }
        let graphInput = GetSubscriptionGraphDataUseCaseInput(pan: pan,
                                                              instaId: instaId)
        let historicalInput = GetSubscriptionHistoricalUseCaseInput(pan: pan,
                                                          instaId: instaId,
                                                          startDate: dateFrom,
                                                          endDate: dateTo)
        let graphScenario = graphDataScenario(graphInput)
        let historicalScenario = historicalDataScenario(historicalInput)
        let values: (graphData: CardSubscriptionGraphDataEntity?, historicalData: [CardSubscriptionHistoricalEntity]?) = (nil, [])
        MultiScenario(handledOn: useCaseHandler, initialValue: values)
            .addScenario(graphScenario) { (updatedValues, output, _) in
                updatedValues.graphData = output.graphData
            }.addScenario(historicalScenario) { (updatedValues, output, _) in
                updatedValues.historicalData = output.subscriptions
            }
            .asScenarioHandler()
            .onSuccess { [weak self] values in
                guard let self = self else { return }
                if (values.graphData == nil) && (values.historicalData == nil) {
                    self.showGenericError()
                } else {
                    if values.graphData == nil {
                        self.showEmptyViewInGrahpView()
                    } else if values.historicalData == nil {
                        self.showEmptyViewInHistoricView()
                    } else {
                        self.showGraphView(values.graphData)
                        self.showHistoricView(values.historicalData)
                    }
                }
            }.onError { [weak self] _ in
                self?.showGenericError()
            }.finally { [weak self] in
                self?.view?.hideLoadingView()
            }
    }
    
    func graphDataScenario(_ graphInput: GetSubscriptionGraphDataUseCaseInput) -> Scenario<GetSubscriptionGraphDataUseCaseInput, GetSubscriptionGraphDataUseCaseOkOutput, StringErrorOutput> {
        return Scenario(useCase: getGraphDataUseCase, input: graphInput)
    }
    
    func historicalDataScenario(_ historicalInput: GetSubscriptionHistoricalUseCaseInput) -> Scenario<GetSubscriptionHistoricalUseCaseInput, GetSubscriptionHistoricalUseCaseOkOutput, StringErrorOutput> {
        return Scenario(useCase: getHistoricalUseCase, input: historicalInput)
    }
    
    func showHistoricView(_ subscriptions: [CardSubscriptionHistoricalEntity]?) {
        guard let subscriptions = subscriptions, !subscriptions.isEmpty else {
            self.showEmptyViewInHistoricView()
            return
        }
        let viewModels: [CardSubscriptionDetailHistoricViewModel] = subscriptions.map({ CardSubscriptionDetailHistoricViewModel($0) })
        self.historicViewModels = viewModels
        view?.updateHistoricView(viewModels, isOpen: false)
    }
    
    func showEmptyViewInHistoricView() {
        view?.updateHistoricView([], isOpen: false)
    }
    
    func showGraphView(_ graphData: CardSubscriptionGraphDataEntity?) {
        if let graphData = graphData {
            let builder = CardSubscriptionDetailBuilder(graphData)
            let model = builder.createGraphData()
            self.view?.configGraphView(model, type: .graph)
        } else {
            showEmptyViewInGrahpView()
        }
    }
    
    func showEmptyViewInGrahpView() {
        let builder = CardSubscriptionDetailBuilder()
        let model = builder.getEmptyGraphData()
        self.view?.configGraphView(model, type: .empty)
    }
    
    func showGenericError() {
        self.view?.showGlobalEmptyView()
    }
    
    // MARK: - SeeFractionableOptions
    func showSeeFractionableOptionsClosed(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        guard let viewModels = self.historicViewModels else {
            return
        }
        let newSubscriptionDetailViewModels: [CardSubscriptionDetailHistoricViewModel] = viewModels.map { historic in
            let isProvider = historic.historicalEntity.providerName == viewModel.historicalEntity.providerName
            var newHistoric = historic
            newHistoric.isSeeFractionableOptionsExpanded = !viewModel.isSeeFractionableOptionsExpanded
            newHistoric.transactionViewModel = nil
             if historic.isFractionable, isProvider {
                var newHistoric = historic
                newHistoric.transactionViewModel?.isExpanded.toggle()
                newHistoric.transactionViewModel = nil
                return newHistoric
             }
            return historic
        }
        view?.updateHistoricView(newSubscriptionDetailViewModels, isOpen: nil)
    }
    
    func updateHistoricsWithTransactionScenario(_ card: CardEntity) {
        var newTransactionViewModel: CardListFinanceableTransactionViewModel?
        let input = GetCardFinanceableTransactionsUseCaseInput(card: card)
        let useCase = getCardFinanceableTransactionsUseCase
        Scenario(useCase: useCase, input: input)
            .execute(on: useCaseHandler)
            .onSuccess { financeableTransactionOutput in
                let transaction = self.matchHistoricTransaction(financeableTransactionOutput)
                newTransactionViewModel = transaction
            }
            .onError { _ in
                newTransactionViewModel = nil
            }
            .finally {
                guard let transaction = newTransactionViewModel?.financeableTransaction.transaction else {
                    return
                }
                self.getCardTransactionEasyPaySuperUseCase.requestValue(card: card, transaction: transaction)
                self.getCardTransactionEasyPaySuperUseCase.execute()
            }
    }
    
    func matchHistoricTransaction(_ financeableTransactionOutput: GetCardFinanceableTransactionsUseCaseOkOutput) -> CardListFinanceableTransactionViewModel? {
        guard var historicViewModels = self.historicViewModels,
              let selectedFractionableTransactionviewModel = self.selectedFractionableTransactionviewModel else {
            return nil
        }
        let financeableTransactions = financeableTransactionOutput.transations.map(FinanceableTransaction.init)
        var newTransactionViewModel: CardListFinanceableTransactionViewModel?
        _ = historicViewModels.enumerated().map { (index, historicViewModel) in
            financeableTransactions.map { (financeableTransaction) in
                guard transactionBelongsToMovement(financeableTransaction.transaction, movement: historicViewModel),
                      isTheSameMovement(historicViewModel, secondMovement: selectedFractionableTransactionviewModel)
                else { return }
                newTransactionViewModel = CardListFinanceableTransactionViewModel(card: financeableTransactionOutput.card, financeableTransaction: financeableTransaction)
                historicViewModels[index].transactionViewModel = newTransactionViewModel
                self.historicViewModels = historicViewModels
            }
        }
        return newTransactionViewModel
    }
    
    func transactionBelongsToMovement(_ transaction: CardTransactionEntity, movement: CardSubscriptionDetailHistoricViewModel) -> Bool {
        guard let transactionAmount = transaction.amount?.value, let movementAmount = movement.historicalEntity.amount?.value else { return false }
        let sameAmount = abs(transactionAmount) == abs(movementAmount)
        let sameTransactionDay = Int(transaction.transactionDay ?? "") ==  Int(movement.historicalEntity.creditMovementNum ?? "")
        let sameBalanceCode = Int(transaction.balanceCode ?? "") == Int(movement.historicalEntity.creditExtractNum ?? "")
        return sameAmount && sameTransactionDay && sameBalanceCode
    }
    
    func showSeeFractionableOptionsLoadingView(_ viewModel: CardSubscriptionDetailHistoricViewModel) {
        guard let historicViewModels = self.historicViewModels else { return }
        let newSubscriptionDetailViewModels: [CardSubscriptionDetailHistoricViewModel] = historicViewModels.map { (historic) in
            if isTheSameMovement(historic, secondMovement: viewModel), historic.isFractionable {
                var newViewModel = viewModel
                newViewModel.isSeeFractionableOptionsExpanded = true
                newViewModel.transactionViewModel?.isExpanded = true
                return newViewModel
            }
            return historic
        }
        view?.updateHistoricView(newSubscriptionDetailViewModels, isOpen: nil)
    }
    
    func isTheSameMovement(_ firstMovement: CardSubscriptionDetailHistoricViewModel, secondMovement: CardSubscriptionDetailHistoricViewModel) -> Bool {
        let isAmount = firstMovement.historicalEntity.amount?.value == secondMovement.historicalEntity.amount?.value
        let isExtractNum = firstMovement.historicalEntity.creditExtractNum == secondMovement.historicalEntity.creditExtractNum
        let isMovementNum = firstMovement.historicalEntity.creditMovementNum == secondMovement.historicalEntity.creditMovementNum
        return isAmount && isExtractNum && isMovementNum
    }
    
    // MARK: Methods used in GetCardTransactionEasyPay SuperUseCase callBacks
    func updateFractionatePaymentViewOnError() {
        guard let viewModels = self.historicViewModels else {
            return
        }
        let updatedHistoricViewModels: [CardSubscriptionDetailHistoricViewModel] = viewModels.map { (historic) in
            var newHistoric = historic
            newHistoric.isSeeFractionableOptionsExpanded = false
            return newHistoric
        }
        view?.updateHistoricView(updatedHistoricViewModels, isOpen: nil)
    }
    
    func updateFractionatePaymentViewOnSuccess(_ easyPayOperativeData: EasyPayOperativeDataEntity, fractionatePayment: FractionatePaymentEntity) {
        guard let historicViewModels = self.historicViewModels,
              let selectedFractionableTransactionviewModel = self.selectedFractionableTransactionviewModel else {
            return
        }
        let updatedSubscriptions: [CardSubscriptionDetailHistoricViewModel] = historicViewModels.map { (historic) in
            if historic.isFractionable, isTheSameMovement(historic, secondMovement: selectedFractionableTransactionviewModel) {
                var newViewModel = historic
                let newTransactionViewModel = historic.transactionViewModel
                newTransactionViewModel?.financeableTransaction.easyPayOperativeData = easyPayOperativeData
                newTransactionViewModel?.financeableTransaction.fractionatedPayment = fractionatePayment
                newTransactionViewModel?.easyPayAction = self.didSelectEasyPayFee
                newTransactionViewModel?.isExpanded = true
                newViewModel.transactionViewModel = newTransactionViewModel
                newViewModel.isSeeFractionableOptionsExpanded = true
                return newViewModel
            }
            return historic
        }
        view?.updateHistoricView(updatedSubscriptions, isOpen: nil)
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
        if self.configuration.detailViewModel.card?.isAllInOne == true, items.count >= 2, items[1].months == 3 {
            items.swapAt(0, 1)
            fractionatePayment.montlyFeeItems = items
        }
        return fractionatePayment
    }
    
    // MARK: Update Switch Subscriptions
    func updateSubscriptionPopupConfiguration(_ isOn: Bool) -> (title: LocalizedStylableText, body: LocalizedStylableText, action: LocalizedStylableText) {
        self.cardSubscriptionViewModel = self.configuration.detailViewModel
        self.cardSubscriptionViewModel?.isActiveSwitch = isOn
        let title, body, action: LocalizedStylableText
        let businessName = self.configuration.detailViewModel.businessName
        if isOn {
            title = localized("m4m_alert_title_activatePayament")
            body = localized("m4m_alert_text_activatePayament", [StringPlaceholder(.name, businessName)])
            action = localized("m4m_button_yesEnable")
        } else {
            title = localized("m4m_alert_title_disablePayament")
            body = localized("m4m_alert_text_disablePayament", [StringPlaceholder(.name, businessName)])
            action = localized("m4m_button_yesDisable")
        }
        return (title: title, body: body, action: action)
    }
    
    func trackUpdateSubscription(_ isOn: Bool) {
        if isOn {
            self.trackEvent(.enableSubscription, parameters: [.cardOperative: CardSubscriptionDetailSubscriptionType.activate.rawValue])
        } else {
            self.trackEvent(.disableSubscription, parameters: [.cardOperative: CardSubscriptionDetailSubscriptionType.deactivate.rawValue])
        }
    }
}

extension CardSubscriptionsDetailPresenter: AutomaticScreenActionTrackable {
    var trackerPage: CardSubscriptionDetailPage {
        CardSubscriptionDetailPage()
    }
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension CardSubscriptionsDetailPresenter: GetCardTransactionEasyPaySuperUseCaseDelegate {
    func didFinishCardTransactionEasyPaySuccessfully(with cardTransactionEasyPay: CardTransactionEasyPay) {
        let fractionatePayment = self.getFractionatePayment(cardTransactionEasyPay)
        self.updateFractionatePaymentViewOnSuccess(cardTransactionEasyPay.easyPayOperativeData, fractionatePayment: fractionatePayment)
    }
    
    func didFinishCardTransactionEasyPayWithError(_ error: String?) {
        self.updateFractionatePaymentViewOnError()
        let stringLoader: StringLoader = dependenciesResolver.resolve()
        var errorWS = error != nil ? stringLoader.getWsErrorString(error ?? "") : localized("generic_error_alert_text")
        self.view?.showOldDialog(title: nil,
                                 description: errorWS.capitalizedBySentence(),
                                 acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
                                 cancelAction: nil,
                                 isCloseOptionAvailable: false)
    }
}

extension CardSubscriptionsDetailPresenter: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol {
    func updateSubscriptionSwitch() {
        guard var cardSubscriptionViewModel = self.cardSubscriptionViewModel,
              let isActiveSwitch = cardSubscriptionViewModel.isActiveSwitch else {
            return
        }
        cardSubscriptionViewModel.isSubscriptionPaymentEnabled = isActiveSwitch
        view?.updateCardSubscriptionDetailView(cardSubscriptionViewModel)
    }
}
