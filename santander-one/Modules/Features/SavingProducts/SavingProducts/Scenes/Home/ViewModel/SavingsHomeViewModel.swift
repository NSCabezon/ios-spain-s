//
//  SavingsHomeViewModel.swift
//  Savings
//
//  Created by Adrian Escriche Martin on 15/2/22.
//
import UI
import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain
import OpenCombineDispatch
import PdfCommons

enum SavingsState: State {
    case idle
    case options([SavingProductOptionRepresentable])
    case shouldShowMoreOptionsButton(Bool)
    case savingsLoaded([Savings])
    case selectedSavingProduct(Savings)
    case comingSoon(String)
    case error(String)
    case isPaginationLoading(Bool)
    case savingDetail(Savings)
    case transactionsHeaderButtonActions([SavingProductsTransactionsButtonsType])
    case transactionsLoaded(DateTransactionGroup)
    case pendingFieldLoaded(String)
    case bottom(titleKey: String, infoKey: String)
}

final class SavingsHomeViewModel: DataBindable {    
    @BindingOptional var selectedSavingProduct: SavingProductRepresentable?
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SavingsHomeDependenciesResolver
    private lazy var coordinator: SavingsHomeCoordinator = dependencies.resolve()
    private lazy var getSavingTransactionsUseCase: GetSavingTransactionsUseCase = dependencies.resolve()
    private var transactionResult: [SavingTransactionRepresentable] = []
    private var transactionsForPDF: [SavingTransactionRepresentable] = []
    private var lastTransactionRequest: SavingTransactionParams?
    private var lastTransactionRequestForPDF: SavingTransactionParams?
    private var pdfCreator: PDFCreator?
    private var cancellables: Set<AnyCancellable> = []
    private let stateSubject = CurrentValueSubject<SavingsState, Never>(.idle)
    var state: AnyPublisher<SavingsState, Never>
    private lazy var accountNumberFormatter: AccountNumberFormatterProtocol? = dependencies.external.resolve()

    init(dependencies: SavingsHomeDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
    }
    
    func viewDidLoad() {
        loadSavingProducts()
        loadTransactionsButtonActions()
        loadProductShortcutActions()
        configureMoreOptionsButtonVisibility()
        loadDetail()
    }
    
    func viewWillAppear() {
        trackerManager.trackScreen(screenId: trackerPage.page, extraParameters: [:])
    }

    func reloadTransactions() {
        guard let savingProduct = selectedSavingProduct else { return }
        transactionResult.removeAll()
        loadTransactions(from: Savings(savings: savingProduct))
    }
    
    public func didSelect(product: Savings) {
        dataBinding.set(product.savings)
        loadProductShortcutActions()
        reloadTransactions()
        loadTransactionsButtonActions()
    }
    
    func didSelectSavingProduct(_ savingProduct: Savings){
        stateSubject.send(.comingSoon("generic_alert_notAvailableOperation"))
    }
    
    func didSelectOption(_ viewModel: SavingProductOptionRepresentable) {
        guard let savingProduct = selectedSavingProduct else { return }
        let eventId = SavingProductsHome.Action.clickFrecuentShortcut.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        switch viewModel.type {
        case .sendMoney:
            coordinator.goToSendMoney(with: viewModel)
            let eventId = SavingProductsHome.Action.clickSendMoney.rawValue
            trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        case .statements:
            stateSubject.send(.comingSoon("generic_alert_notAvailableOperation"))
            let eventId = SavingProductsHome.Action.clickStatements.rawValue
            trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        case .regularPayments:
            stateSubject.send(.comingSoon("generic_alert_notAvailableOperation"))
            let eventId = SavingProductsHome.Action.clickRegularPayments.rawValue
            trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        case .reportCard:
            stateSubject.send(.comingSoon("generic_alert_notAvailableOperation"))
            let eventId = SavingProductsHome.Action.clickViewCards.rawValue
            trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        case .apply:
            stateSubject.send(.comingSoon("generic_alert_notAvailableOperation"))
            let eventId = SavingProductsHome.Action.clickApply.rawValue
            trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        case .custom(identifier: _):
            coordinator.goToSavingCustomOption(with: Savings(savings: savingProduct), option: viewModel)
        }
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    @objc func didSelectGoBack() {
        coordinator.dismiss()
    }
    
    @objc func didSelectOpenMenu() {
        coordinator.openMenu()
    }
    
    func didSelect(action: SavingHeaderAction) {
        guard let product = selectedSavingProduct else { return }
        let coordinator = dependencies.external.savingsHomeTransactionsActionsCoordinator()
        switch action {
        case .download:
            let eventId = SavingProductsHome.Action.viewTransactionPdf.rawValue
            trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
            getDataForPDF()
        case .filter:
            coordinator
                .set(product)
                .set(SavingProductsTransactionsButtonsType.filter)
                .start()
        default:
            break
        }
    }
    
    func didSelectSavingsInfo() {
        let eventId = SavingProductsHome.Action.tapTooltipSaving.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        stateSubject.send(.bottom(titleKey: "savingsTooltip_title_savings", infoKey: "savingsTooltip_text_viewSavvingsSection"))
    }
    
    func didSelectShareId(_ savings: Savings) {
        let eventId = SavingProductsHome.Action.shareIban.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        coordinator.goToShareHandler(for: savings)
    }
    
    func didSelectBalanceInfo(_ savings: Savings) {
        let eventId = SavingProductsHome.Action.tapTooltipBalance.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        stateSubject.send(.bottom(titleKey: "savings_title_balances", infoKey: "savings_label_balanceInfo"))
    }

    func didSelectInterestRateLink(_ savings: Savings) {
        let eventId = SavingProductsHome.Action.viewInterestRateDetail.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        guard let url = savings.interestRateLinkRepresentable?.url else { return }
        coordinator.open(url: url)
    }
    
    func didSelectTransaction(_ transition: SavingTransaction) {
        let eventId = SavingProductsHome.Action.viewDetail.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        stateSubject.send(.comingSoon("generic_alert_notAvailableOperation"))
    }
    
    func didSwipeCarousel() {
        let eventId = SavingProductsHome.Action.swipe.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
    }

    func didSelectMoreOperativesButton() {
        let eventId = SavingProductsHome.Action.clickMoreOption.rawValue
        trackerManager.trackEvent(screenId: trackerPage.page, eventId: eventId, extraParameters: [:])
        guard let selectedSavingProduct = selectedSavingProduct else { return }
        coordinator.goToMoreOperatives(selectedSavingProduct)
    }
    
    func loadMoreTransactions() {
        guard lastTransactionRequest?.offset != nil else {
            stateSubject.send(.isPaginationLoading(false))
            return
        }
        fetchTransactions()
    }
    
    func loadProductShortcutActions() {
        guard let number = selectedSavingProduct?.contractRepresentable?.contractNumber,
              let savingsType = selectedSavingProduct?.accountSubType else { return }
        self.getSavingProductOptionsUsecase
            .fetchHomeOptions(contractNumber: number,
                              savingsProductType: savingsType)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .sink {[unowned self] options in
                self.stateSubject.send(.options(options))
            }.store(in: &self.anySubscriptions)
    }

    func configureMoreOptionsButtonVisibility() {
        guard let contractNumber = selectedSavingProduct?.contractRepresentable?.contractNumber,
              let savingsType = selectedSavingProduct?.accountSubType
        else {
            self.stateSubject.send(.shouldShowMoreOptionsButton(false))
            return
        }
        return getSavingProductOptionsUsecase
            .fetchOtherOperativesOptions(contractNumber: contractNumber,
                                       savingsProductType: savingsType)
            .flatMap({ options in
                return Just(options.count > 0)
            })
            .receive(on: Schedulers.main)
            .sink { shouldShowMoreOptionButtons in
                self.stateSubject.send(.shouldShowMoreOptionsButton(shouldShowMoreOptionButtons))
            }.store(in: &anySubscriptions)
    }
    
    func loadSavingProducts() {
        Publishers.Zip(getSavingProductsUseCase.fechSavingProducts(),
                       getSavingProductComplementaryDataUseCase.fechComplementaryDataPublisher())
            .receive(on: Schedulers.main)
            .sink {[weak self] value in
                guard let self = self else { return }
                let savings = self.getSavings(value.0, value.1)
                self.stateSubject.send(.savingsLoaded(savings))
                guard let safeSelectedSavings = savings.filter({ $0.accountID == self.selectedSavingProduct?.accountId }).first ?? savings.first else { return }
                self.stateSubject.send(.selectedSavingProduct(safeSelectedSavings))
                self.loadTransactions(from: safeSelectedSavings)
            }.store(in: &anySubscriptions)
    }
    
    func getSavings(_ savingsRepresentable: [SavingProductRepresentable], _ countryComplementaryData: [String : [DetailTitleLabelType]]) -> [Savings] {
        var savings:[Savings] = []
        savingsRepresentable.forEach { saving in
            let savingObject = Savings(savings: saving)
            countryComplementaryData.forEach { data in
                if data.key == savingObject.accountSubtype {
                    savingObject.complementaryData = data.value
                }
            }
            savingObject.totalNumberOfFields = self.getMaxNumberOfFields(savingsRepresentable,
                                                                         countryComplementaryData)
            savingObject.idLabelForLengthReference = self.getLongestID(savingsRepresentable)
            savingObject.didSelectShare = self.didSelectShareId(_:)
            savingObject.didSelectBalanceInfo = self.didSelectBalanceInfo(_:)
            savingObject.didSelectInterestRateLink = self.didSelectInterestRateLink(_:)
            savings.append(savingObject)
        }
        return savings
    }
    
    func getLongestID(_ savingsRepresentable: [SavingProductRepresentable]) -> String {
        var idToReturn: String = ""
        savingsRepresentable.forEach { value in
            if let identification = value.identification,
               identification.count > idToReturn.count {
                idToReturn = identification
            }
        }
        return idToReturn
    }

    func loadDetail() {
        guard let savingProduct = selectedSavingProduct else { return }
        stateSubject.send(.savingDetail(Savings(savings: savingProduct)))
    }
    
    func loadTransactionsButtonActions() {
        guard let selectedSavingProduct = self.selectedSavingProduct else { return }
        let useCase: SavingsHomeTransactionsActionsUseCase = dependencies.external.resolve()
        useCase.getAvailableTransactionsButtonActions(for: selectedSavingProduct)
            .sink { [weak self] buttonActions in
                guard let self = self else { return }
                self.stateSubject.send(.transactionsHeaderButtonActions(buttonActions))
            }.store(in: &cancellables)
    }
    
    func loadTransactions(from savings: Savings) {
        lastTransactionRequest = SavingTransactionParams(accountID: savings.accountID,
                                                         type: selectedSavingProduct?.accountSubType,
                                                         contract: selectedSavingProduct?.contractRepresentable)
        lastTransactionRequestForPDF = lastTransactionRequest
        fetchTransactions()
    }
    
    func getDataForPDF() {
        guard let lastTransactionRequestForPDF = lastTransactionRequestForPDF,
              let accountId = selectedSavingProduct?.accountId else { return }
        getSavingTransactionsUseCase
            .fetch(params: lastTransactionRequestForPDF)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .sink { [weak self] completion in
                guard case let .failure(error) = completion else { return }
                self?.trackEvent(.error, parameters: [.descError: error.localizedDescription])
                self?.stateSubject.send(.error("product_label_emptyError"))
            } receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.transactionsForPDF.append(contentsOf: value.data.transactions)
                self.lastTransactionRequestForPDF = SavingTransactionParams(accountID: accountId,
                                                                      type: self.selectedSavingProduct?.accountSubType,
                                                                      contract: self.selectedSavingProduct?.contractRepresentable,
                                                                      offset: value.pagination?.next)
                if self.transactionsForPDF.count < 1000,  self.lastTransactionRequestForPDF?.offset != nil {
                    self.getDataForPDF()
                } else {
                    self.generatePDF()
                }
            }.store(in: &cancellables)
    }
    
    func fetchTransactions() {
        guard let lastTransactionRequest = lastTransactionRequest,
              let accountId = selectedSavingProduct?.accountId  else { return }
        getSavingTransactionsUseCase
            .fetch(params: lastTransactionRequest)
            .subscribe(on: Schedulers.background)
            .receive(on: Schedulers.main)
            .sink { [weak self] completion in
                guard case let .failure(error) = completion else { return }
                self?.trackEvent(.error, parameters: [.descError: error.localizedDescription])
                self?.stateSubject.send(.error("product_label_emptyError"))
            } receiveValue: { [weak self] value in
                guard let self = self else { return }
                self.transactionResult.append(contentsOf: value.data.transactions)
                self.loadTransactions(self.transactionResult)
                self.loadPendingField(value.data.accounts ?? [])
                self.lastTransactionRequest = SavingTransactionParams(accountID: accountId,
                                                                      type: self.selectedSavingProduct?.accountSubType,
                                                                      contract: self.selectedSavingProduct?.contractRepresentable,
                                                                      offset: value.pagination?.next)
            }.store(in: &cancellables)
    }
    
    func loadTransactions(_ transactions: [SavingTransactionRepresentable]) {
        let timeManager: TimeManager = dependencies.external.resolve()
        let pending = (key: DateTransactionType.pending, value: transactions.filter { $0.status == "Pending" })
        let completed = transactions.filter { $0.status != "Pending" }
            .group(by: { $0.bookingDateTime })
            .sorted(by: { $0.0 > $1.0 })
            .map { (key: DateTransactionType.completed($0.key), value: $0.value) }
        let array = pending.value.isEmpty ? completed : [pending] + completed
        let allTransactions = array.map { group in
            return (key: group.key, value: group.value.map { SavingTransaction(transaction: $0, timeManager: timeManager) })
        }
        stateSubject.send(.transactionsLoaded(allTransactions))
    }
    
    func loadPendingField(_ accounts: [SavingAccountRepresentable?]) {
        let pendingAmount = accounts.first??.balances?.first?.creditLines?.first(where: {$0.type == "Pending"})?.amount
        let pending = pendingAmount.map(AmountEntity.init)
        stateSubject.send(.pendingFieldLoaded(pending?.getStringValue() ?? "--"))
    }
    
    func getMaxNumberOfFields(_ savingsRepresentable: [SavingProductRepresentable], _ countryComplementaryData: [String : [DetailTitleLabelType]]) -> Int {
        var numberOfFields = 0
        var fieldsByType: [String: Int] = [:]
        countryComplementaryData.forEach { value in
            fieldsByType[value.key] = value.value.count
        }
        savingsRepresentable.forEach { value in
            if let fields = fieldsByType[value.accountSubType ?? ""],
               fields > numberOfFields {
                numberOfFields = fields
            }
        }
        return numberOfFields
    }
    
    func generatePDF() {
        guard let accountId = selectedSavingProduct?.accountId else { return }
        let accountIdFormatted: String? = accountNumberFormatter?.accountNumberFormat(accountId)
        let info: SavingsTransactionListPdfHeaderInfo = SavingsTransactionListPdfHeaderInfo(
            accountNumber: accountIdFormatted ?? accountId, fromDate: nil, toDate: nil)
        pdfCreator = PDFCreator(renderer: SavingsTransactionListPrintPageRenderer(info: info, stringLoader: dependencies.external.resolve(), timeManager: dependencies.external.resolve()))
        let builder = SavingsTransactionsPdfBuilder(stringLoader: dependencies.external.resolve(), timeManager: dependencies.external.resolve())
        builder.addHeader()
        builder.addTransactionsInfo(transactionsForPDF)
        builder.addDisclaimer()
        self.pdfCreator?.createPDF(
            html: builder.build(),
            completion: { [weak self] data in
                self?.coordinator.goToPDF(with: data)
            }, failed: { [weak self] in
                
            }
        )
    }
}

private extension SavingsHomeViewModel {
    var getSavingProductsUseCase: GetSavingProductsUsecase {
        return dependencies.external.resolve()
    }
    
    var getSavingProductOptionsUsecase: GetSavingProductOptionsUseCase {
        return dependencies.external.resolve()
    }
    
    var getSavingProductComplementaryDataUseCase: GetSavingProductComplementaryDataUseCase {
        return dependencies.external.resolve()
    }
}

// MARK: - Analytics
extension SavingsHomeViewModel: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        dependencies.external.resolve()
    }
    
    var trackerPage: SavingProductsHome {
        SavingProductsHome()
    }
}
