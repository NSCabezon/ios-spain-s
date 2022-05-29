import UI
import CoreFoundationLib

protocol CardTransactionDetailPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: CardTransactionDetailViewProtocol? { get set }
    var selectedTransaction: CardTransactionEntity { get set }
    func didSelectTransaction(_ viewModel: OldCardTransactionDetailViewModel)
    func didSelectMenu()
    func didSelectDismiss()
    func viewDidLoad()
    func didSelectFractionate()
    func didSelectMap()
    func didSelectEasyPayWithMontlyFee(_ montlyFee: MontlyPaymentFeeItem)
    func didSelectOffer(_ viewModel: OldCardTransactionDetailViewModel)
}

final class CardTransactionDetailPresenter {
    weak var view: CardTransactionDetailViewProtocol?
    var dependenciesResolver: DependenciesResolver
    
    private var isEnabledMap: Bool = false
    private var isEasyPayModeEnabled: Bool = false
    private var isSplitExpensesEnabled: Bool = false

    private var selectedCardTransactionDetail: CardTransactionDetailEntity?
    private var easyPayOperativeDataEntity: EasyPayOperativeDataEntity?
    private var movementLocation: CardMapItem?
    
    var configuration: CardTransactionDetailConfiguration
    var viewConfiguration: CardTransactionDetailViewConfigurationProtocol?
            
    var selectedCard: CardEntity {
        get {
            self.configuration.selectedCard
        }
        set(newValue) {
            self.configuration.selectedCard = newValue
        }
    }

    var selectedTransaction: CardTransactionEntity {
        didSet {
            self.selectedCardTransactionDetail = nil
            self.loadCardTransactionDetail()
        }
    }
    
    var transactions: [CardTransactionEntity] {
        self.configuration.allTransactions
    }
    
    var resultTransactions: [CardTransactionWithCardEntity]? {
        self.configuration.resultTransactions
    }
    
    var minEasyPayAmount: Double?
    
    var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    var transactionDetailUseCase: OldCardTransactionDetailUseCase {
        self.dependenciesResolver.resolve(for: OldCardTransactionDetailUseCase.self)
    }
    
    var minEasyPayAmountUseCase: OldGetMinEasyPayAmountUseCase {
        self.dependenciesResolver.resolve(for: OldGetMinEasyPayAmountUseCase.self)
    }
    
    var firstFeeInfoEasyPayUseCase: FirstFeeInfoEasyPayUseCase {
        self.dependenciesResolver.resolve()
    }
    
    var cardMovementLocationUseCase: OldGetSingleCardMovementLocationUseCase {
        self.dependenciesResolver.resolve(for: OldGetSingleCardMovementLocationUseCase.self)
    }
    
    var getCardsUseCase: GetCardsHomeUseCase {
        return dependenciesResolver.resolve(for: GetCardsHomeUseCase.self)
    }
    
    lazy var selectedTransactionViewModel: OldCardTransactionDetailViewModel = {
        OldCardTransactionDetailViewModel(transaction: self.selectedTransaction, card: self.selectedCard, detail: nil, minEasyPayAmount: self.minEasyPayAmount, timeManager: self.timeManager, isEasyPayModeEnabled: self.isEasyPayModeEnabled, isSplitExpensesEnabled: self.isSplitExpensesEnabled, offerEntity: self.crossSellingOffer)
    }()

    var locations: [PullOfferLocation] {
        return [
            PullOfferLocation(stringTag: CardsPullOffers.movCardDetails, hasBanner: true, pageForMetrics: self.trackerPage.page)
        ]
    }
    var offers: [PullOfferLocation: OfferEntity] = [:]
    var crossSellingOffer: OfferEntity? {
        return self.offers.location(key: CardsPullOffers.movCardDetails)?.offer
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.selectedTransaction = self.dependenciesResolver
            .resolve(for: CardTransactionDetailConfiguration.self).selectedTransaction
        self.configuration = self.dependenciesResolver.resolve(for: CardTransactionDetailConfiguration.self)
        self.viewConfiguration = self.dependenciesResolver.resolve(forOptionalType: CardTransactionDetailViewConfigurationProtocol.self)
    }

    weak var coordinatorDelegate: CardsTransactionDetailModuleCoordinatorDelegate? {
        dependenciesResolver.resolve(for: CardsTransactionDetailModuleCoordinatorDelegate.self)
    }
    
    private var coordinator: OldCardTransactionDetailCoordinator {
        return dependenciesResolver.resolve(for: OldCardTransactionDetailCoordinator.self)
    }
}

extension CardTransactionDetailPresenter: CardTransactionDetailPresenterProtocol {
    func didSelectEasyPayWithMontlyFee(_ montlyFee: MontlyPaymentFeeItem) {
        if montlyFee.entity != nil {
            self.easyPayOperativeDataEntity?.easyPayAmortization = montlyFee.entity
            coordinatorDelegate?.easyPay(entity: self.selectedCard, transactionEntity: self.selectedTransaction, easyPayOperativeDataEntity: self.easyPayOperativeDataEntity)
        } else {
            didSelectFractionate()
        }
    }
    
    func viewDidLoad() {
        self.dependenciesResolver.resolve(for: GlobalPositionReloadEngine.self).add(self)
        self.loadTransactions()
        self.loadMinEasyPayAmount { [weak self] in
            self?.loadCardTransactionDetail()
        }
        self.trackScreen()
    }
     
    func didSelectTransaction(_ viewModel: OldCardTransactionDetailViewModel) {
        self.selectedCard = viewModel.card
        self.selectedTransaction = viewModel.transaction
        self.selectedTransactionViewModel = viewModel
    }
    
    func didSelectMenu() {
        self.coordinatorDelegate?.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinatorDelegate?.didSelectDismiss()
    }
    
    func didSelectFractionate() {
        // operativedata is nil because is the mode classic button
        coordinatorDelegate?.easyPay(entity: self.selectedCard, transactionEntity: self.selectedTransaction, easyPayOperativeDataEntity: nil)
    }
    
    func didSelectMap() {
        trackEvent(.map, parameters: [:])
        if isEnabledMap, self.selectedCardTransactionDetail != nil, let movementLocation = self.movementLocation {
            let configurationMapType = CardMapTypeConfiguration.one(location: movementLocation)
            self.coordinator.goToMapView(selectedCard, type: configurationMapType)
        } else {
            self.view?.showNotAvailable()
        }
    }
    
    func didSelectOffer(_ viewModel: OldCardTransactionDetailViewModel) {
        guard let offer = self.offers.location(key: CardsPullOffers.movCardDetails) else { return }
        self.coordinatorDelegate?.didSelectOffer(offer: offer.offer)
    }
}

private extension CardTransactionDetailPresenter {
    
    private func loadTransactions() {
        
        if let results = self.resultTransactions {
            loadTransactionsFromGlobalSearch(with: results)
        } else {
            loadTransactionsFromCardHome()
        }
        
    }
    
    func loadTransactionsFromGlobalSearch(with results: [CardTransactionWithCardEntity]) {
        let viewModels = results.map { viewModelFor(resultTransaction: $0) }
        self.selectedTransactionViewModel = viewModelFor(transaction: selectedTransaction)
        self.view?.showTransactions(viewModels, withSelected: selectedTransactionViewModel)
    }
    
    func loadTransactionsFromCardHome() {
        let viewModels = self.transactions.map { viewModelFor(transaction: $0) }
        self.selectedTransactionViewModel = viewModelFor(transaction: selectedTransaction)
        self.view?.showTransactions(viewModels, withSelected: selectedTransactionViewModel)
    }
    
    private func viewModelFor(transaction: CardTransactionEntity) -> OldCardTransactionDetailViewModel {
        return OldCardTransactionDetailViewModel(
                    transaction: transaction,
                    card: self.selectedCard,
                    detail: nil, minEasyPayAmount: self.minEasyPayAmount,
                    timeManager: self.timeManager,
                    isEasyPayModeEnabled: self.isEasyPayModeEnabled,
            isSplitExpensesEnabled: self.isSplitExpensesEnabled,
                    offerEntity: nil,
            viewConfiguration: viewConfiguration)
    }
    
    private func viewModelFor(resultTransaction: CardTransactionWithCardEntity) -> OldCardTransactionDetailViewModel {
        return OldCardTransactionDetailViewModel(
            transaction: resultTransaction.cardTransactionEntity,
            card: resultTransaction.cardEntity,
            detail: nil, minEasyPayAmount: self.minEasyPayAmount,
            timeManager: self.timeManager,
            isEasyPayModeEnabled: self.isEasyPayModeEnabled,
            isSplitExpensesEnabled: self.isSplitExpensesEnabled,
            offerEntity: nil,
            viewConfiguration: viewConfiguration)
    }
    
    private func updateViewModel(with useCaseOutput: CardTransactionDetailUseCaseOkOutput) {
        self.selectedTransactionViewModel.transaction = self.selectedTransaction
        self.selectedTransactionViewModel.card = self.selectedCard
        self.selectedTransactionViewModel.detail = useCaseOutput.detail
        self.selectedTransactionViewModel.error = nil
        self.selectedTransactionViewModel.minEasyPayAmount = self.minEasyPayAmount
        self.selectedTransactionViewModel.timeManager = self.timeManager
        self.selectedTransactionViewModel.isEasyPayModeEnabled = useCaseOutput.isEasyPayEnabled
        self.selectedTransactionViewModel.isSplitExpensesEnabled = useCaseOutput.isSplitExpensesEnabled
        self.selectedTransactionViewModel.offerEntity = self.crossSellingOffer
        self.selectedTransactionViewModel.transactionUpdated = true
        self.isEnabledMap = useCaseOutput.isEnabledMap
        self.loadCardDetailActions(for: selectedTransactionViewModel)
        self.selectedTransactionViewModel.isAlreadyFractionated = useCaseOutput.isAlreadyFractionated
        self.view?.updateTransaction(selectedTransactionViewModel)
        self.selectedCardTransactionDetail = useCaseOutput.detail
        self.easyPayOperativeDataEntity = useCaseOutput.operativeData
    }
    
    func validateFractionatePayment(with useCaseOutput: CardTransactionDetailUseCaseOkOutput) {
        let fractionViewModel = FractionatePaymentItem()
        guard !useCaseOutput.isEasyPayClassicEnabled && useCaseOutput.isEasyPayEnabled,
            useCaseOutput.operativeData?.feeData != nil,
            let amount = selectedTransaction.amount?.value,
            let numberOfMonths = fractionViewModel.getNumberOfMonthsForQuoteCalculation(amount: amount,
                                                                                        isAllInOneCard: selectedCard.isAllInOne)
        else {
            self.selectedTransactionViewModel.isAlreadyFractionated = useCaseOutput.isAlreadyFractionated
            self.view?.updateTransaction(self.selectedTransactionViewModel)
            self.view?.removeFractionatePaymentView()
            return
        }
        var cuotesFees = [EasyPayCurrentFeeDataEntity]()
        numberOfMonths.forEach { (month) in
            let usecase = dependenciesResolver.resolve(for: FirstFeeInfoEasyPayUseCase.self)
            let input = EasyPayFirstFeeInfoUseCaseInput(numberOfFees: month,
                                                        cardDTO: self.selectedCard.dto,
                                                        transactionBalanceCode: useCaseOutput.operativeData?.easyPayContractTransaction.dto.balanceCode,
                                                        transactionDay: useCaseOutput.operativeData?.easyPayContractTransaction.transactionDay)
            Scenario(useCase: usecase, input: input)
                .execute(on: dependenciesResolver.resolve())
                .onSuccess { [weak self] (resp) in
                    cuotesFees.append(resp.currentFeeData)
                    if cuotesFees.count == numberOfMonths.count {
                        self?.showFractionatePayment(payments: cuotesFees,
                                                     fractionViewModel: fractionViewModel)
                    }
                }
        }
    }
    
    func showFractionatePayment(payments: [EasyPayCurrentFeeDataEntity], fractionViewModel: FractionatePaymentItem) {
        self.selectedTransactionViewModel.isAlreadyFractionated = false
        self.view?.updateTransaction(self.selectedTransactionViewModel)
        var paymentsSorted = payments.sorted { ($0.totalMonths ?? 0) < ($1.totalMonths ?? 0) }
        if selectedCard.isAllInOne, paymentsSorted.count >= 2, paymentsSorted[1].totalMonths == 3 {
            paymentsSorted.swapAt(0, 1)
        }
        var monthsPayments = paymentsSorted.map { (fee) -> MontlyPaymentFeeEntity in
            let feeAmount = fee.feeAmount
            return MontlyPaymentFeeEntity(fee: Decimal(feeAmount ?? 0.0),
                                          numberOfMonths: fee.totalMonths ?? 0,
                                          easyPayAmortization: EasyPayAmortizationEntity(from: fee))
        }
        monthsPayments.append(MontlyPaymentFeeEntity())
        let entity = FractionatePaymentEntity(fractions: monthsPayments, minAmount: 60, maxMonths: 36)
        fractionViewModel.updateEntity(entity: entity)
        self.view?.showFractionatePaymentWithViewModel(fractionViewModel)
    }
    
    private func updateViewModel(with errorString: String?) {
        let viewModel = OldCardTransactionDetailViewModel(
            transaction: self.selectedTransaction,
            card: self.selectedCard,
            error: errorString,
            minEasyPayAmount: self.minEasyPayAmount,
            timeManager: self.timeManager,
            isEasyPayModeEnabled: self.isEasyPayModeEnabled,
            isSplitExpensesEnabled: self.isSplitExpensesEnabled,
            offerEntity: self.crossSellingOffer,
            viewConfiguration: viewConfiguration)
        selectedTransactionViewModel.transaction = self.selectedTransaction
        selectedTransactionViewModel.card = self.selectedCard
        selectedTransactionViewModel.error = errorString
        selectedTransactionViewModel.minEasyPayAmount = self.minEasyPayAmount
        selectedTransactionViewModel.timeManager = self.timeManager
        
        self.loadCardDetailActions(for: viewModel)
        self.selectedTransactionViewModel = viewModel
        self.view?.updateTransaction(viewModel)
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
    
    func loadCardTransactionDetail() {
        self.view?.removeFractionatePaymentView()
        self.view?.removeMapViews()
        let useCase = self.transactionDetailUseCase.setRequestValues(
            requestValues: CardTransactionDetailUseCaseInput(
                transaction: self.selectedTransaction,
                card: self.selectedCard,
                locations: locations
            )
        )
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.offers = result.pullOfferCandidates
                self.updateViewModel(with: result)
                self.validateFractionatePayment(with: result)
                if self.isEnabledMap, self.selectedCardTransactionDetail != nil {
                    self.getMovementLocation(result.detail)
                }
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                var errorString: String? = ""
                if case .networkUnavailable = error {
                    errorString = error.getErrorDesc()
                }
                self.updateViewModel(with: errorString)
            }
        )
    }
    
    private func loadCardDetailActions() {
        let viewModel = self.viewModelFor(transaction: self.selectedTransaction)
        self.loadCardDetailActions(for: viewModel)
    }
    
    private func loadCardDetailActions(for viewModel: OldCardTransactionDetailViewModel) {
        guard let cardsDetailCoordinatorDelegate = self.coordinatorDelegate else { return }
        let actions = CardTransactionDetailActionFactory.getCardTransactionDetailActionForViewModel(
            viewModel: viewModel,
            self.selectedCard,
            dependenciesResolver: self.dependenciesResolver,
            action: { action, entity in
                let transactionAction = self.dependenciesResolver.resolve(forOptionalType: CardTransactionDetailActionFactoryModifierProtocol.self)
                let isActionModifierEnabled = transactionAction?.didSelectAction(action, forTransaction: self.selectedTransaction, andCard: entity) ?? false
                guard !isActionModifierEnabled else { return }
                cardsDetailCoordinatorDelegate.didSelectAction(action, entity)
                switch action {
                case .share:
                    self.trackEvent(.share, parameters: [:])
                case .divide:
                    self.trackEvent(.expensesDivide, parameters: [:])
                case .offCard:
                    self.trackEvent(.offCard, parameters: [:])
                case .pdfDetail:
                    break
                default:
                    break
                }
        })
        
        self.view?.showActions(actions)
    }
    
    private func getMovementLocation(_ transactionDetail: CardTransactionDetailEntity) {
        let useCase = self.cardMovementLocationUseCase.setRequestValues(
            requestValues: GetSingleCardMovementLocationUseCaseInput(
                transaction: self.selectedTransaction,
                transactionDetail: transactionDetail,
                card: self.selectedCard
            )
        )
        UseCaseWrapper(with: useCase,
                       useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
                       onSuccess: { [weak self] result in
                        switch result.status {
                        case .locatedMovement:
                            if let latitude = result.location.latitude, let longitude = result.location.longitude {
                                self?.movementLocation = CardMapItem(date: result.location.date, name: result.location.concept, alias: self?.selectedCard.alias, amount: result.location.amount, address: result.location.address, postalCode: result.location.postalCode, location: result.location.location, latitude: latitude, longitude: longitude, amountValue: result.location.amount?.value, totalValues: result.location.amount?.value ?? Decimal(0))
                            }
                            self?.view?.addLocationView(CardTransactionDetailLocationItem(title: result.location.concept, address: result.location.address, location: result.location.location, postalCode: result.location.postalCode, category: result.location.category, showMapButton: true))
                        case .notLocatedMovement:
                            self?.view?.addLocationView(CardTransactionDetailLocationItem(title: result.location.concept, address: result.location.address, location: result.location.location, postalCode: result.location.postalCode, category: result.location.category, showMapButton: false))
                        case .onlineMovement:
                            self?.view?.addLocationView(CardTransactionDetailLocationItem(title: localized("transaction_label_transactionOnline"), address: result.location.address, location: result.location.location, postalCode: result.location.postalCode, category: result.location.category, showMapButton: false))
                        case .neverLocalizable:
                            self?.view?.addNoLocalizableMovementView()
                        case .serviceError:
                            self?.view?.addTemporallyNotLocalizableMovementView()
                        }
            }
        )
    }
}

extension CardTransactionDetailPresenter: GlobalPositionReloadable {
    func reload() {
        MainThreadUseCaseWrapper(
            with: getCardsUseCase,
            onSuccess: { [weak self] response in
                guard let selected = self?.selectedCard else { return }
                self?.selectedCard = response.cards.first(where: { selected.pan == $0.pan }) ?? selected
                self?.viewDidLoad()
            })
    }
}

extension CardTransactionDetailPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    var trackerPage: CardsDetailMovementPage {
        return CardsDetailMovementPage()
    }
}
