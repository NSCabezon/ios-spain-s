//
//  CardSubscriptionPresenter.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 24/02/2021.
//

import CoreFoundationLib

protocol CardSubscriptionPresenterProtocol: AnyObject {
    var view: CardSubscriptionGlobalViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectBack()
    func didSelectCardsHome(sender: UIViewController)
    func didSelectDetail(_ viewModel: CardSubscriptionViewModel)
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionViewModel)
    func didTapInSubscriptionSwitch(_ isOn: Bool, viewModel: CardSubscriptionViewModel)
    func didTapInPaymentsInDisabledShops()
}

final class CardSubscriptionPresenter {
    weak var view: CardSubscriptionGlobalViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var selectedCard: CardEntity?
    var selectedTransaction: FinanceableTransaction?
    public var subscriptionViewModels: [CardSubscriptionViewModel] = []
    private var selectedSubscriptionViewModel: CardSubscriptionViewModel?
    
    private var coordinator: CardSubscriptionCoordinatorProtocol {
        return dependenciesResolver.resolve(for: CardSubscriptionCoordinatorProtocol.self)
    }
    
    private var useCase: GetSubscriptionsListUseCase {
        dependenciesResolver.resolve(for: GetSubscriptionsListUseCase.self)
    }
    
    private var getCardFinanceableTransactionsUseCase: GetCardFinanceableTransactionsUseCase {
        dependenciesResolver.resolve(firstTypeOf: GetCardFinanceableTransactionsUseCase.self)
    }
    
    private var isM4MactiveSuscriptionEnabledUseCase: IsM4MactiveSuscriptionEnabledUseCaseAlias {
        dependenciesResolver.resolve(for: IsM4MactiveSuscriptionEnabledUseCaseAlias.self)
    }
    
    private var timeManager: TimeManager {
        return dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    private var colorsEngine: ColorsByNameEngine {
        return dependenciesResolver.resolve(for: ColorsByNameEngine.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var configuration: CardSubscriptionConfiguration {
        return self.dependenciesResolver.resolve(for: CardSubscriptionConfiguration.self)
    }
    
    private var useCaseHandler: UseCaseScheduler {
        return self.dependenciesResolver.resolve()
    }
    
    lazy var getCardTransactionEasyPaySuperUseCase: GetCardTransactionEasyPaySuperUseCase = {
        let superUseCase = self.dependenciesResolver.resolve(for: GetCardTransactionEasyPaySuperUseCase.self)
        superUseCase.delegate = self
        return superUseCase
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension CardSubscriptionPresenter: CardSubscriptionPresenterProtocol {
    func didSelectCardsHome(sender: UIViewController) {
        switch sender {
        case is CardWithSubscriptionsViewControllerProtocol:
            didSelectBack()
            
        case is CardsSubscriptionViewControllerProtocol:
            coordinator.gotoCardsHome()
        default:
            break
        }   
    }
    
    func viewDidLoad() {
        trackScreen()
        view?.showLoadingView { [weak self] in
            self?.loadList()
        }
    }
    
    func didSelectMenu() {
        coordinator.showMenu()
    }
    
    func didSelectBack() {
        coordinator.didSelectDismiss()
    }
    
    func didSelectDetail(_ viewModel: CardSubscriptionViewModel) {
        guard let type = viewModel.cardSubscriptionType else {
            return
        }
        trackDetail(type)
        coordinator.goToSubscriptionDetail(viewModel, delegate: self)
    }
    
    func didTapInPaymentsInDisabledShops() {
        trackEvent(.seeHistoricPayments, parameters: [:])
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: CardSubscriptionViewModel) {
        trackEvent(.fractionatedSubscription, parameters: [.cardOperative: trackerPage.easyPay])
        if viewModel.isSeeFractionableOptionsExpanded {
            self.showSeeFractionableOptionsClosed(viewModel)
        } else {
            // Update view with selected toggle
            guard let card = viewModel.card else {
                return
            }
            showSeeFractionableOptionsLoadingView(viewModel)
            // Execute Scenario
            self.selectedCard = card
            self.updateSubscriptionsWithTransactionScenario(card)
        }
    }
    
    func didTapInSubscriptionSwitch(_ isOn: Bool, viewModel: CardSubscriptionViewModel) {
        let config = self.updateSubscriptionPopupConfiguration(isOn, viewModel: viewModel)
        self.view?.showOptionsToUpdateSubscription(
            title: config.title, body: config.body, action: config.action, onActionable: { [weak self] _ in
                guard let strongSelf = self else { return }
                guard let card = viewModel.card else {
                    return
                }
                strongSelf.trackUpdateSubscription(isOn)
                strongSelf.coordinator.showActivateSubscription(card, subscription: viewModel.cardSubscription, subscriptionIsOn: !isOn, delegate: self)
            })
    }
}

private extension CardSubscriptionPresenter {
    func getMerchantList(_ output: SubscriptionsListUseCaseOkOutput) -> Scenario<Void,
                                                                                 GetMerchantUseCaseOutput,
                                                                                 StringErrorOutput> {
        let useCase: GetMerchantUseCase = dependenciesResolver.resolve()
        return Scenario(useCase: useCase)
    }
    
    func getIsM4MactiveSuscriptionEnabled() -> Scenario<Void, IsM4MactiveSuscriptionEnabledUseCaseOkOutput, StringErrorOutput> {
        return Scenario(useCase: isM4MactiveSuscriptionEnabledUseCase)
    }
    
    func loadList() {
        let configuration: CardSubscriptionConfiguration = dependenciesResolver.resolve()
        let dateTo = timeManager.toString(date: Date(), outputFormat: .yyyyMMdd, timeZone: .local)
        let monthsAgoDate = Calendar.current.date(byAdding: .month, value: -25, to: Date())
        let dateFrom = timeManager.toString(date: monthsAgoDate, outputFormat: .yyyyMMdd)
        let input = SubscriptionsListInput(pan: configuration.selectedCard?.pan ?? "",
                                           dateFrom: dateFrom,
                                           dateTo: dateTo)
        var subscriptions: [CardSubscriptionEntity]?
        var merchantList: [MerchantEntity]?
        var isM4MactiveSuscriptionEnabled = false
        Scenario(useCase: useCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { output in
                subscriptions = output.subscriptions
            }
            .then(scenario: getMerchantList)
            .onSuccess { merchantOutput in
                merchantList = merchantOutput.list
            }
            .thenIgnoringPreviousResult(scenario: getIsM4MactiveSuscriptionEnabled)
            .onSuccess({ isActiveSuscriptionSwitchOutput in
                isM4MactiveSuscriptionEnabled = isActiveSuscriptionSwitchOutput.isM4MactiveSuscriptionEnabled
            })
            .finally { [weak self] in
                guard let self = self else { return }
                self.view?.hideLoadingView()
                guard let subscriptions = subscriptions else {
                    self.view?.showEmptyView(cause: .error)
                    return
                }
                guard !subscriptions.isEmpty else {
                    self.view?.showEmptyView(cause: .nodata)
                    return
                }
                guard let card = configuration.selectedCard else {
                    return self.processResponse(
                        subscriptions: subscriptions,
                        merchantList: merchantList,
                        isM4MactiveSuscriptionEnabled: isM4MactiveSuscriptionEnabled
                    )
                }
                self.processSingleCardResponse(
                    subscriptions,
                    cardEntity: card,
                    merchantList: merchantList,
                    isM4MactiveSuscriptionEnabled: isM4MactiveSuscriptionEnabled
                )
            }
    }
    
    func processResponse(subscriptions: [CardSubscriptionEntity], merchantList: [MerchantEntity]?, isM4MactiveSuscriptionEnabled: Bool) {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = dependenciesResolver.resolve()
        let cards = globalPosition.cards.visibles()
        let viewModels = subscriptions.compactMap { entity -> CardSubscriptionViewModel? in
            guard
                let filteredEntity = cards.first(where: { $0.formattedPAN == entity.formattedPAN && $0.isVisible })
            else { return nil }
            let colorType = colorsEngine.get(entity.providerName)
            let merchant = merchantList?.lazy
                .first(where: { $0.names
                        .compactMap({ $0.lowercased() })
                        .contains(entity.providerName.lowercased()) })
            let viewModel = CardSubscriptionViewModel(subscriptionEntity: entity,
                                                      logoColor: ColorsByNameViewModel(colorType).color,
                                                      card: filteredEntity,
                                                      merchantImageUrl: merchant?.iconUrl,
                                                      baseUrl: baseURLProvider.baseURL,
                                                      comesFromViewType: .general,
                                                      isM4MactiveSuscriptionEnabled: isM4MactiveSuscriptionEnabled)
            return viewModel
        }
        if viewModels.isEmpty {
            view?.showEmptyView(cause: .nodata)
        } else {
            self.subscriptionViewModels = viewModels
            view?.showSubscriptionsMovements(viewModels)
        }
    }
    
    func processSingleCardResponse(_ subscriptions: [CardSubscriptionEntity], cardEntity: CardEntity, merchantList: [MerchantEntity]?, isM4MactiveSuscriptionEnabled: Bool) {
        let viewModels = subscriptions.compactMap { entity -> CardSubscriptionViewModel? in
            let colorType = colorsEngine.get(entity.providerName)
            let merchant = merchantList?.lazy
                .first(where: { $0.names
                        .compactMap({$0.lowercased()})
                        .contains(entity.providerName.lowercased()) })
            let model = CardSubscriptionViewModel(subscriptionEntity: entity,
                                                  logoColor: ColorsByNameViewModel(colorType).color,
                                                  card: cardEntity,
                                                  merchantImageUrl: merchant?.iconUrl,
                                                  baseUrl: baseURLProvider.baseURL,
                                                  comesFromViewType: .card,
                                                  isM4MactiveSuscriptionEnabled: isM4MactiveSuscriptionEnabled)
            return model
        }
        if !viewModels.isEmpty {
            self.subscriptionViewModels = viewModels
            view?.showSubscriptionsMovements(viewModels)
        }
    }
    
    func trackDetail(_ type: CardSubscriptionSeeMoreType) {
        switch type {
        case .payments:
            trackEvent(.seeMorePayments, parameters: [:])
        case .historic:
            trackEvent(.seeHistoricPayments, parameters: [:])
        }
    }
    
    // MARK: - FinanceableTransactions
    // MARK: Methods used in didSelectSeeFrationateOptions Tap Action
    func showSeeFractionableOptionsClosed(_ viewModel: CardSubscriptionViewModel) {
        let newSubscriptionViewModels: [CardSubscriptionViewModel] = self.subscriptionViewModels.map { subscription in
            if subscription.isActive, subscription.isFractionable, subscription.card == viewModel.card {
                var newSubscription = subscription
                newSubscription.isSeeFractionableOptionsExpanded = !viewModel.isSeeFractionableOptionsExpanded
                newSubscription.transactionViewModel = nil
                return newSubscription
            }
            return subscription
        }
        self.subscriptionViewModels = newSubscriptionViewModels
        view?.showSubscriptionsMovements(newSubscriptionViewModels)
    }
    
    func showSeeFractionableOptionsLoadingView(_ viewModel: CardSubscriptionViewModel) {
        let newSubscriptionViewModels: [CardSubscriptionViewModel] = self.subscriptionViewModels.map { subscription in
            if subscription.isActive, subscription.isFractionable, subscription.card == viewModel.card {
                var newSubscription = subscription
                newSubscription.isSeeFractionableOptionsExpanded.toggle()
                return newSubscription
            }
            return subscription
        }
        self.subscriptionViewModels = newSubscriptionViewModels
        view?.showSubscriptionsMovements(newSubscriptionViewModels)
    }
    
    // MARK: Fractionable UseCase
    func updateSubscriptionsWithTransactionScenario(_ card: CardEntity) {
        var newTransactionViewModel: CardListFinanceableTransactionViewModel?
        let input = GetCardFinanceableTransactionsUseCaseInput(card: card)
        let useCase = getCardFinanceableTransactionsUseCase
        Scenario(useCase: useCase, input: input)
            .execute(on: useCaseHandler)
            .onSuccess { financeableTransactionOutput in
                let transaction = self.matchSubscriptionTransaction(financeableTransactionOutput)
                newTransactionViewModel = transaction
            }
            .onError { _ in
                newTransactionViewModel = nil
            }
            .finally {
                guard let transaction = newTransactionViewModel?.financeableTransaction.transaction else {
                    self.view?.showEmptyView(cause: .nodata)
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
        self.subscriptionViewModels.enumerated().forEach { (index, subscriptionViewModel) in
            let subscription = subscriptionViewModel.cardSubscription
            financeableTransactions.forEach { (financeableTransaction) in
                let transaction = financeableTransaction.transaction
                guard let amountTransactionValue = transaction.amount?.value,
                      let transactionNum = transaction.transactionDay,
                      let transactionCode = transaction.balanceCode,
                      let amountSubcriptionValue = subscription.amount?.value,
                      let subscriptionNum = subscription.creditMovementNum,
                      let subscriptionCode = subscription.creditExtractNum else {
                    return
                }
                let isAmount = abs(amountTransactionValue) == amountSubcriptionValue
                let isNumber = Int(transactionNum) == Int(subscriptionNum)
                let isCode = Int(transactionCode) == Int(subscriptionCode)
                // Execute Matches
                guard isAmount, isNumber, isCode else {
                    return
                }
                let transactionViewModel = CardListFinanceableTransactionViewModel(card: financeableTransactionOutput.card,
                                                                                   financeableTransaction: financeableTransaction)
                transactionViewModel.toggle()
                newTransactionViewModel = transactionViewModel
                // Add transactionViewModel into proper subscription pill
                self.subscriptionViewModels[index].transactionViewModel = transactionViewModel
            }
        }
        return newTransactionViewModel
    }
    
    // MARK: Methods used in GetCardTransactionEasyPay SuperUseCase callBacks
    func updateFractionatePaymentViewOnError() {
        let updatedSubscriptions: [CardSubscriptionViewModel] = self.subscriptionViewModels.map { (subscription) in
            if let transactionViewModel = subscription.transactionViewModel, self.selectedCard == subscription.card {
                var newSubscription = subscription
                let newTransactionViewModel = transactionViewModel
                newTransactionViewModel.isExpanded.toggle()
                newSubscription.transactionViewModel = newTransactionViewModel
                return newSubscription
            }
            return subscription
        }
        view?.showSubscriptionsMovements(updatedSubscriptions)
    }
    
    func updateFractionatePaymentViewOnSuccess(_ easyPayOperativeData: EasyPayOperativeDataEntity, fractionatePayment: FractionatePaymentEntity) {
        let updatedSubscriptions: [CardSubscriptionViewModel] = self.subscriptionViewModels.map { (subscription) in
            if let transactionViewModel = subscription.transactionViewModel, self.selectedCard == subscription.card {
                var newSubscription = subscription
                let newTransactionViewModel = transactionViewModel
                newTransactionViewModel.financeableTransaction.easyPayOperativeData = easyPayOperativeData
                newTransactionViewModel.financeableTransaction.fractionatedPayment = fractionatePayment
                newTransactionViewModel.easyPayAction = self.didSelectEasyPayFee
                newSubscription.transactionViewModel = newTransactionViewModel
                return newSubscription
            }
            return subscription
        }
        view?.showSubscriptionsMovements(updatedSubscriptions)
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
        if selectedCard?.isAllInOne == true, items.count >= 2, items[1].months == 3 {
            items.swapAt(0, 1)
            fractionatePayment.montlyFeeItems = items
        }
        return fractionatePayment
    }
    
    func clearRequest() {
        self.selectedTransaction = nil
        self.selectedCard = nil
    }
    
    // MARK: Update Switch Subscriptions
    func updateSubscriptionPopupConfiguration(_ isOn: Bool, viewModel: CardSubscriptionViewModel) -> (title: LocalizedStylableText, body: LocalizedStylableText, action: LocalizedStylableText) {
        self.selectedSubscriptionViewModel = viewModel
        self.selectedSubscriptionViewModel?.isActiveSwitch = isOn
        let title, body, action: LocalizedStylableText
        let businessName = viewModel.businessName
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

extension CardSubscriptionPresenter: AutomaticScreenActionTrackable {
    var trackerPage: CardSubscriptionPage {
        guard let viewType = view?.showCardSubscriptionFrom else {
            return CardSubscriptionPage()
        }
        switch viewType {
        case .general:
            return CardSubscriptionPage(strategy: CardSubscriptionGeneralPage())
        case .card:
            return CardSubscriptionPage(strategy: CardSubscriptionCardPage())
        }
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension CardSubscriptionPresenter: GetCardTransactionEasyPaySuperUseCaseDelegate {
    func didFinishCardTransactionEasyPaySuccessfully(with cardTransactionEasyPay: CardTransactionEasyPay) {
        let fractionatePayment = self.getFractionatePayment(cardTransactionEasyPay)
        self.updateFractionatePaymentViewOnSuccess(cardTransactionEasyPay.easyPayOperativeData, fractionatePayment: fractionatePayment)
        self.clearRequest()
    }
    
    func didFinishCardTransactionEasyPayWithError(_ error: String?) {
        self.updateFractionatePaymentViewOnError()
        self.clearRequest()
        let stringLoader: StringLoader = dependenciesResolver.resolve()
        var errorWS = error != nil ? stringLoader.getWsErrorString(error ?? "") : localized("generic_error_alert_text")
        self.view?.showOldDialog(title: nil,
                                 description: errorWS.capitalizedBySentence(),
                                 acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
                                 cancelAction: nil,
                                 isCloseOptionAvailable: false)
    }
}

extension CardSubscriptionPresenter: CardSubscriptionDetailUpdatingSubscriptionSwitchProtocol {
    func updateSubscriptionSwitch() {
        self.loadList()
    }
}
