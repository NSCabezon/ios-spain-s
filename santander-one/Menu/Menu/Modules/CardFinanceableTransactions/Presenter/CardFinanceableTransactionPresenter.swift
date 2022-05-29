//
//  CardFinanceableTransactionPresenter.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 6/24/20.
//

import CoreFoundationLib
import CoreDomain

protocol CardFinanceableTransactionPresenterProtocol: MenuTextWrapperProtocol {
    func openMenu()
    func viewDidLoad()
    func dismissViewController()
    func didselectCardViewModel(_ viewModel: CardFinanceableViewModel)
    func didSelectTransaction(_ viewModel: CardListFinanceableTransactionViewModel)
    func didSelectSeeFrationateOptions(_ viewModel: CardListFinanceableTransactionViewModel)
    var view: CardFinanceableTransactionViewProtocol? { get set }
}

final class CardFinanceableTransactionPresenter {
    weak var view: CardFinanceableTransactionViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var cardList: [CardEntity] = []
    var cardTransactions: Set = Set<FinanceableTransationList>()
    var selectedCard: CardEntity?
    var selectedTransaction: FinanceableTransaction?
    var waitingEasyPayResponse = false
    
    var coordinatorDelegate: FinanceableTransactionCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: FinanceableTransactionCoordinatorDelegate.self)
    }
    var getCreditCardUseCase: GetCreditCardUseCase {
        self.dependenciesResolver.resolve(firstTypeOf: GetCreditCardUseCase.self)
    }
    var getCardFinanceableTransactionsUseCase: GetCardFinanceableTransactionsUseCase {
        dependenciesResolver.resolve(firstTypeOf: GetCardFinanceableTransactionsUseCase.self)
    }
    var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve(for: UseCaseHandler.self)
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

extension CardFinanceableTransactionPresenter: CardFinanceableTransactionPresenterProtocol {
    func viewDidLoad() {
        self.view?.showLoadingView(nil)
        self.getCreditCardList { [weak self] selectedCard in
            guard let self = self else { return }
            self.view?.hideLoadingView({
                self.loadCardTransactions(for: selectedCard)
            })
        }
        trackScreen()
    }
    
    func didselectCardViewModel(_ viewModel: CardFinanceableViewModel) {
        self.selectedCard = viewModel.card
        self.loadCardTransactions(for: viewModel.card)
    }
    
    func didSelectSeeFrationateOptions(_ viewModel: CardListFinanceableTransactionViewModel) {
        trackEvent(.clickDropdownOptions)
        guard !viewModel.isEasyPayLoaded() else { return }
        guard !self.waitingEasyPayResponse else { return }
        self.waitingEasyPayResponse = true
        self.selectedCard = viewModel.card
        self.selectedTransaction = viewModel.financeableTransaction
        self.getCardTransactionEasyPaySuperUseCase.requestValue(
            card: viewModel.card,
            transaction: viewModel.financeableTransaction.transaction)
        getCardTransactionEasyPaySuperUseCase.execute()
    }
    
    func didSelectTransaction(_ viewModel: CardListFinanceableTransactionViewModel) {
        trackEvent(.fractionablesCardMonthDetail)
        let card = viewModel.card
        let selectedTransaction = viewModel.financeableTransaction.transaction
        let transactionList = self.cardTransactions
            .first(where: { $0.card == card })?.transations
            .map({ $0.transaction })
            .sorted(by: { ($0.operationDate ?? Date()) > ($1.operationDate ?? Date()) }) ?? []
        self.coordinatorDelegate.gotoCardTransactionDetail(
            card: card, selectedTransaction: selectedTransaction, in: transactionList)
    }
    
    func didSelectEasyPayFee(card: CardEntity, transaction: CardTransactionEntity,
                             easyPayOperativeData: EasyPayOperativeDataEntity?) {
        trackEvent(.clickFractionableOption)
        let operativeData = easyPayOperativeData?.easyPayAmortization != nil ? easyPayOperativeData : nil
        self.coordinatorDelegate.gotoCardEasyPayOperative(
            card: card,
            transaction: transaction,
            easyPayOperativeData: operativeData
        )
    }
    
    func dismissViewController() {
        self.coordinatorDelegate.didSelectDismiss()
    }
    
    func openMenu() {
        self.coordinatorDelegate.didSelectMenu()
    }
}

private extension CardFinanceableTransactionPresenter {
    func getCreditCardList(completion: @escaping (CardEntity) -> Void) {
        MainThreadUseCaseWrapper(
            with: getCreditCardUseCase,
            onSuccess: { [weak self] response in
                self?.cardList = response.cardList
                guard let selectedCard = self?.getSelectedCard() else { return }
                self?.setCardSelector(selectedCard)
                completion(selectedCard)
        })
    }
    
    func getSelectedCard() -> CardEntity? {
        let configuration = self.dependenciesResolver.resolve(for: CardFinanceableTransactionConfiguration.self)
        return configuration.selectedCard ?? cardList.first
    }
    
    func setCardSelector(_ selectedCard: CardEntity) {
        guard cardList.count > 1 else { return }
        let viewModels = cardList.map({ CardFinanceableViewModel(card: $0) })
        let selectedViewModel = CardFinanceableViewModel(card: selectedCard)
        self.view?.showCardDropDown(with: viewModels, selectedCardViewModel: selectedViewModel)
    }
    
    func loadCardTransactions(for card: CardEntity) {
        let input = GetCardFinanceableTransactionsUseCaseInput(card: card)
        UseCaseWrapper(
            with: self.getCardFinanceableTransactionsUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.useCaseHandler,
            onSuccess: {[weak self] response in
                self?.addCardTransactions(response)
            },
            onError: {[weak self]_ in
                self?.view?.showEmptyView()
            }
        )
    }
    
    func addCardTransactions(_ response: GetCardFinanceableTransactionsUseCaseOkOutput) {
        let financeableTransationList = FinanceableTransationList(
            card: response.card,
            transations: response.transations.map(FinanceableTransaction.init)
        )
        self.cardTransactions.insert(financeableTransationList)
        self.showFinanceableTransactions(financeableTransationList)
    }
    
    func showFinanceableTransactions(_ transactionList: FinanceableTransationList) {
        let viewModels = self.generateViewModelsFor(transactionList)
        if viewModels.isEmpty {
            self.view?.showEmptyView()
        } else {
            self.view?.showFinanceableTransactions(viewModels: viewModels)
        }
        self.view?.showDateFilters(self.getSearchedDates())
    }
    
    func generateViewModelsFor(_ transactionList: FinanceableTransationList) -> [CardListFinanceableTransactionViewModel] {
        let card = transactionList.card
        let viewModels = transactionList.transations.map({ (transaction) -> CardListFinanceableTransactionViewModel in
            let viewModel = CardListFinanceableTransactionViewModel(card: card, financeableTransaction: transaction)
            viewModel.easyPayAction = self.didSelectEasyPayFee
            return viewModel
        })
        return viewModels
    }
    
    func showFractionatePayment() {
        guard let card = self.selectedCard, let transaction = self.selectedTransaction else { return }
        let viewModel = CardListFinanceableTransactionViewModel(card: card, financeableTransaction: transaction)
        self.view?.updateViewModel(for: viewModel)
    }
    
    func showFractionatePaymentError() {
        guard let card = self.selectedCard, let transaction = self.selectedTransaction else { return }
        let viewModel = CardListFinanceableTransactionViewModel(card: card, financeableTransaction: transaction)
        viewModel.setEasyPayError()
        self.view?.updateViewModel(for: viewModel)
    }
    
    func clearRequest() {
        self.selectedTransaction = nil
        self.selectedCard = nil
        self.waitingEasyPayResponse = false
    }
}

extension CardFinanceableTransactionPresenter: GetCardTransactionEasyPaySuperUseCaseDelegate {
    func didFinishCardTransactionEasyPaySuccessfully(with cardTransactionEasyPay: CardTransactionEasyPay) {
        self.selectedTransaction?.easyPayOperativeData = cardTransactionEasyPay.easyPayOperativeData
        var items = cardTransactionEasyPay.fractionatePayment.montlyFeeItems
        var fractionatePayment = cardTransactionEasyPay.fractionatePayment
        if selectedCard?.isAllInOne == true, items.count >= 2, items[1].months == 3 {
            items.swapAt(0, 1)
            fractionatePayment.montlyFeeItems = items
        }
        self.selectedTransaction?.fractionatedPayment = fractionatePayment
        self.showFractionatePayment()
        self.clearRequest()
    }
    
    func didFinishCardTransactionEasyPayWithError(_ error: String?) {
        self.showFractionatePaymentError()
        self.clearRequest()
        let stringLoader: StringLoader = dependenciesResolver.resolve()
        var errorWS = error != nil ? stringLoader.getWsErrorString(error ?? "") : localized("generic_error_alert_text")
        self.view?.showOldDialog(
            title: nil,
            description: errorWS.capitalizedBySentence(),
            acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
            cancelAction: nil,
            isCloseOptionAvailable: false)
    }
}

extension CardFinanceableTransactionPresenter: AutomaticScreenActionTrackable {
    var trackerPage: CardFinancebleTransactionpage {
        return CardFinancebleTransactionpage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension CardFinanceableTransactionPresenter: FinanciableTransactionsDatesProtocol {}
