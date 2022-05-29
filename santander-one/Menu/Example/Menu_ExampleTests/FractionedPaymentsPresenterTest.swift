import XCTest
import QuickSetup
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData
import UI

@testable import Menu_Example
@testable import Menu
@testable import CoreFoundationLib
@testable import Accounts

class FractionedPaymentsPresenterTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private var sut: (FractionedPaymentsPresenterProtocol & FractionedPymentsPresenterDataProtocol)!
    private var mockDataInjector = MockDataInjector()
    private let view = MockView()
    private var mockSuperUseCase: MockGetAllFractionedPaymentsForCardSuperUseCase!
    private var mockCardTransactionUseCase: MockGetCardTransactionEasyPaySuperUseCaseDelegate!
    private var timeManager: TimeManager!
    private var globalPosition: GlobalPositionRepresentable!
    private var coordinator: FractionedPaymentsCoordinator!
    private lazy var servicesProvider: QuickSetupForCoreTestData = {
        return QuickSetupForCoreTestData()
    }()
    
    override func setUp() {
        super.setUp()
        sut = FractionedPaymentsPresenter(dependenciesResolver: dependencies)
        sut.view = view
        setDependencies()
        coordinator = FractionedPaymentsCoordinator(
            dependenciesResolver: dependencies,
            navigationController: UINavigationController()
        )
        let gpDto = GlobalPositionDTO()
        globalPosition = GlobalPositionMock(gpDto,
                                            cardsData: [:],
                                            temporallyOffCards: [:],
                                            inactiveCards: [:],
                                            cardBalances: [:])
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        servicesProvider = QuickSetupForCoreTestData()
    }

    func test_viewDidLoad_whenManagerResponseWithOutCards_shouldRenderEmptyView() {
        sut.viewDidLoad()
        let emptyMovements: [Date: [FractionablePurchaseViewModel]] = [:]
        let viewModels = sut.createViewModel(emptyMovements)
        XCTAssertTrue(viewModels.isEmpty)
    }
    
    func test_viewDidLoad_whenSuperUseCaseResponseWithError_shouldSendEmptyViewModels() {
        sut.viewDidLoad()
        let cards: [CardEntity] = []
        mockSuperUseCase.loadFractionablePurchasesForCard(cards)
        mockSuperUseCase.completeWith(error: "an error")
        XCTAssertTrue(mockSuperUseCase.executeCalls == 1)
        XCTAssertTrue(view.viewModels.isEmpty)
    }
    
    func test_viewDidLoad_whenSuccessSuperUseCaseResponseWithEmptyData_shouldSendEmptyViewModels() {
        sut.viewDidLoad()
        let cards: [CardEntity] = []
        let outputs: [GetAllFractionedPaymentsForCardOutput] = []
        mockSuperUseCase.loadFractionablePurchasesForCard(cards)
        mockSuperUseCase.completeWith(outputs)
        XCTAssertTrue(mockSuperUseCase.executeCalls == 1)
        XCTAssertTrue(view.viewModels.isEmpty)
    }
    
    func test_viewDidLoad_whenSuccessSuperUseCaseResponseWithData_shouldCreateViewModels() {
        sut.viewDidLoad()
        let cards = getCardEntities(numOfCards: 5)
        sut.setAllCards(cards)
        mockSuperUseCase.loadFractionablePurchasesForCard(cards)
        let outputs: [GetAllFractionedPaymentsForCardOutput] = createMockedData()
        let fractionedMovements = sut.setFractionedMovements(outputs)
        let viewModels = sut.createViewModel(fractionedMovements)
        view.viewModels = viewModels
        mockSuperUseCase.completeWith(outputs)
        XCTAssertTrue(mockSuperUseCase.executeCalls == 1)
        XCTAssertTrue(view.viewModels.count == 6)
    }
    
    func test_didTapInSeeFractionedOptions_whenExpandsFeeOptions_shouldUpdateSelectedViewModelWithExpandedSelector() {
        let card = getMockedCardEntity()
        let selectedTransaction = createMockedFinanceableTransaction()
        sut.setSelectedTransaction(selectedTransaction)
        let transactionViewModel = CardListFinanceableTransactionViewModel(
            card: card,
            financeableTransaction: selectedTransaction
        )
        var viewModel = createdMockedFractionablePurchaseViewModel()
        sut.didSelectSeeFrationateOptions(viewModel)
        viewModel.setMovementExpanded(true)
        viewModel.setMovementTransaction(transactionViewModel)
        XCTAssertTrue(viewModel.getIsExpanded())
        XCTAssertNotNil(viewModel.getMovementTransaction())
    }
    
    func test_didTapInSeeFractionedOptions_whenExpandsFeeOptions_shouldExecuteCardTransactionSuperUseCaseWithMonthlyFeeItems() {
        let output = createMockedCardTransactionEasyPay()
        let card = getMockedCardEntity()
        let transaction = createMockedCardTransactionEntity()
        mockCardTransactionUseCase.requestValue(
            card: card,
            transaction: transaction
        )
        mockCardTransactionUseCase.completeWith(with: output)
        XCTAssertTrue(mockCardTransactionUseCase.executeCalls == 1)
        XCTAssertTrue(!output.fractionatePayment.montlyFeeItems.isEmpty)
    }
    
    func test_didTapInSeeMoreCards_withMultipleCardsWithMovements_shouldExecutePagination() {
        let allCards = getCardEntities(numOfCards: 10)
        let pendingCards = getCardEntities(numOfCards: 7)
        sut.setAllCards(allCards)
        sut.setCardsPendingToProcess(pendingCards)
        mockSuperUseCase.loadFractionablePurchasesForCard(allCards)
        let outputs: [GetAllFractionedPaymentsForCardOutput] = createMockedData()
        mockSuperUseCase.completeWith(outputs)
        sut.didSelectInSeeMoreCards()
        XCTAssertTrue(mockSuperUseCase.executeCalls >= 2)
    }
}

private extension FractionedPaymentsPresenterTest {    
    func setDependencies() {
        dependencies.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        dependencies.register(for: TrackerManager.self) { _ in
            TrackerManagerMock()
        }
        dependencies.register(for: UseCaseHandler.self) { resolver in
            UseCaseHandler(maxConcurrentOperationCount: 1, qualityOfService: .default)
        }
        dependencies.register(for: BaseURLProvider.self) { resolver in
            BaseURLProvider(baseURL: "")
        }
        dependencies.register(for: TimeManager.self) { resolver in
            let timeManagerMock = TimeManagerMock()
            self.timeManager = timeManagerMock
            return timeManagerMock
        }
        dependencies.register(for: GetAllFractionedPaymentsForCardSuperUseCase.self) { resolver in
            self.mockSuperUseCase
        }
        dependencies.register(for: FractionedPaymentsCoordinator.self) { _ in
            self.coordinator
        }
        dependencies.register(for: FractionedPaymentsLauncher.self) { _ in
            FractionedPaymentsLauncherMock()
        }
        dependencies.register(for: GetVisibleCardsUseCase.self) { dependenciesResolver in
            return GetVisibleCardsUseCase(dependenciesResolver: dependenciesResolver)
        }
        dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            self.globalPosition
        }
        dependencies.register(for: AppRepositoryProtocol.self) { _ in
            AppRepositoryMock()
        }
        dependencies.register(for: PfmHelperProtocol.self) { _ in
            PfmHelperMock()
        }
        setDependenciesForSuperUseCases()
    }
    
    func setDependenciesForSuperUseCases() {
        mockSuperUseCase = MockGetAllFractionedPaymentsForCardSuperUseCase(dependenciesResolver: dependencies)
        mockCardTransactionUseCase = MockGetCardTransactionEasyPaySuperUseCaseDelegate(dependenciesResolver: dependencies)
    }
    
    // MARK: Load FractionedPayments viewModels
    func createMockedFinanceableMovements(_ numOfItems: Int) -> [FinanceableMovementEntity] {
        var movements: [FinanceableMovementEntity] = []
        (0...numOfItems).forEach { index in
            let movement = createMockedFinanceableMovement(index)
            movements.append(movement)
        }
        return movements
    }
    
    func createMockedGetAllFractionedPaymentsForCardOutput(movements: [FinanceableMovementEntity]) -> [GetAllFractionedPaymentsForCardOutput] {
        var outputs: [GetAllFractionedPaymentsForCardOutput] = []
        let cards = getCardEntities(numOfCards: 5)
        (0...cards.count-1).forEach { index in
            let output = GetAllFractionedPaymentsForCardOutput(
                cardEntity: cards[index],
                financeableMovements: movements
            )
            outputs.append(output)
        }
        return outputs
    }
    
    func createMockedData() -> [GetAllFractionedPaymentsForCardOutput] {
        let movements: [FinanceableMovementEntity] = createMockedFinanceableMovements(2)
        let outputs: [GetAllFractionedPaymentsForCardOutput] = createMockedGetAllFractionedPaymentsForCardOutput(movements: movements)
        return outputs
    }
    
    func getCardEntities(numOfCards: Int) -> [CardEntity] {
        let card = getMockedCardEntity()
        var cards: [CardEntity] = []
        (0...numOfCards).forEach({ _ in cards.append(card) })
        return cards
    }
    
    func createMockedFinanceableMovement(_ index: Int) -> FinanceableMovementEntity {
        let currentDate = Date().dateByAdding(days: index * 10)
        let transactionDay = Date().dateByAdding(days: index * 5)
        let liquidationDate = Date().dateByAdding(days: index * 5)
        let accountingDate = Date().dateByAdding(days: index * 5)
        let currencyDto = CurrencyDTO(
            currencyName: "EUR",
            currencyType: .eur
        )
        let amountDto = AmountDTO(value: Decimal(10 * index), currency: currencyDto)
        let financeableDto = FinanceableMovementDTO(
            movementId: String(index),
            amount: amountDto,
            normalIndicator: index,
            liquidationDate: liquidationDate.toString("dd-MM-yyyy"),
            operationDate: currentDate.toString("dd-MM-yyyy"),
            accountingDate: accountingDate.toString("dd-MM-yyyy"),
            elegibleFinance: "S",
            description: "FinanceableDTO with index \(index)",
            clearedIndicator: .pending,
            movementType: .normal,
            status: nil,
            originalCurrency: currencyDto,
            balanceCode: currentDate.toString("dd-MM-yyyy") + "_\(index)",
            transactionDay: transactionDay.toString("dd-MM-yyyy")
        )
        let movement = FinanceableMovementEntity(
            dto: financeableDto,
            date: currentDate
        )
        return movement
    }
    
    func getMockedCardEntity() -> CardEntity {
        var cardDto = CardDTO()
        cardDto.PAN = "5415419610918005"
        let card = CardEntity(cardDto)
        card.cardType = .credit
        card.inactive = false
        card.isTemporallyOff = false
        card.isVisible = true
        return card
    }
    
    // MARK: - MockData 4 CardTransaction
    func createdMockedFractionablePurchaseViewModel() -> FractionablePurchaseViewModel {
        let card = getMockedCardEntity()
        let financeableMovement = createMockedFinanceableMovement(1)
        let time = dependencies.resolve(for: TimeManager.self)
        let viewModel = FractionablePurchaseViewModel(
            cardEntity: card,
            financeableMovementEntity: financeableMovement,
            timeManager: time
        )
        return viewModel
    }
    
    func createMockedEasyPayOperativeDataEntity() -> EasyPayOperativeDataEntity {
        let cardDetailEntity = createMockedCardDetailEntity()
        let cardTransactionDetail = createMockedCardTransactionDetailEntity()
        let contractTransactionEntity = createMockedEasyPayContractTransactionEntity()
        let easyPayEntity = createMockedEasyPayEntity()
        let feeDataEntity = createMockedFeeDataEntity()
        let easyPayOperativeDataEntity = EasyPayOperativeDataEntity(
            cardDetail: cardDetailEntity,
            cardTransactionDetail: cardTransactionDetail,
            easyPayContractTransaction: contractTransactionEntity,
            easyPay: easyPayEntity,
            feeData: feeDataEntity
        )
        return easyPayOperativeDataEntity
    }
    
    func createMockedCardDetailEntity() -> CardDetailEntity {
        let dto = CardDetailDTO()
        let entity = CardDetailEntity(dto)
        return entity
    }
    
    func createMockedCardTransactionDetailEntity() -> CardTransactionDetailEntity {
        let dto = CardTransactionDetailDTO()
        let entity = CardTransactionDetailEntity(dto)
        return entity
    }
    
    func createMockedEasyPayContractTransactionEntity() -> EasyPayContractTransactionEntity {
        let dto = EasyPayContractTransactionDTO()
        let entity = EasyPayContractTransactionEntity(dto)
        return entity
    }
    
    func createMockedEasyPayEntity() -> EasyPayEntity {
        let dto = EasyPayDTO()
        let entity = EasyPayEntity(dto)
        return entity
    }
    
    func createMockedFeeDataEntity() -> FeeDataEntity {
        let dto = FeeDataDTO()
        let entity = FeeDataEntity(dto)
        return entity
    }
    
    func createMockedFractions() -> [MontlyPaymentFeeEntity] {
        let monthlyPaymentFeeEntity = MontlyPaymentFeeEntity()
        let fractions = [monthlyPaymentFeeEntity, monthlyPaymentFeeEntity, monthlyPaymentFeeEntity]
        return fractions
    }
    
    func createMockedCardTransactionEntity() -> CardTransactionEntity {
        let dto = CardTransactionDTO()
        let entity = CardTransactionEntity(dto)
        return entity
    }
    
    func createMockedFinanceableTransaction() -> FinanceableTransaction {
        let entity = createMockedCardTransactionEntity()
        let transaction = FinanceableTransaction(transaction: entity)
        return transaction
    }
    
    func createMockedFractionatePaymentEntity() -> FractionatePaymentEntity {
        let monthlyPaymentFeeEntity = MontlyPaymentFeeEntity()
        let fractions = [monthlyPaymentFeeEntity, monthlyPaymentFeeEntity, monthlyPaymentFeeEntity]
        let fractionatePaymentEntity = FractionatePaymentEntity(
            fractions: fractions,
            minAmount: 0,
            maxMonths: 12
        )
        return fractionatePaymentEntity
    }
    
    func createMockedCardTransactionEasyPay() -> CardTransactionEasyPay {
        let fractionatePaymentEntity = createMockedFractionatePaymentEntity()
        let easyPayOperativeDataEntity = createMockedEasyPayOperativeDataEntity()
        let cardTransactionEasyPay = CardTransactionEasyPay(
            fractionatePayment: fractionatePaymentEntity,
            easyPayOperativeData: easyPayOperativeDataEntity
        )
        return cardTransactionEasyPay
    }
}

// MARK: - MockView + loading
fileprivate final class MockView: UIViewController {
    var setCardCarouselCount = 0
    var viewModels: [FractionedPaymentsViewModel] = []
    var associatedLoadingView: UIViewController { self }
}

extension MockView: LoadingViewPresentationCapable {
    public func showLoading(
        title: LocalizedStylableText = localized("generic_popup_loadingContent"),
        subTitle: LocalizedStylableText = localized("loading_label_moment"),
        completion: (() -> Void)? = nil ) {
            completion?()
    }
    
    func dismissLoading(completion: (() -> Void)?) {
        completion?()
    }
}

extension MockView: FractionatedPaymentsViewProtocol {
    func showFractionatedPayments(_ models: [FractionedPaymentsViewModel]) {
        self.viewModels.append(contentsOf: models)
    }
    
    func showEmptyView() {
        
    }
    
    func showSeeMoreCardsView() {
        
    }
}

// MARK: - Mocked SuperUseCase
fileprivate final class MockGetAllFractionedPaymentsForCardSuperUseCase: GetAllFractionedPaymentsForCardSuperUseCase {
    var executeCalls = 0

    func completeWith(_ response: [GetAllFractionedPaymentsForCardOutput]) {
        delegate?.didFinishGetAllPurchasesSuccessfully(with: response)
    }

    func completeWith(error: String?) {
        delegate?.didFinishWithError(error: error)
    }

    override func loadFractionablePurchasesForCard(_ cards: [CardEntity]) {
        executeCalls += 1
    }
}

fileprivate final class MockGetCardTransactionEasyPaySuperUseCaseDelegate: GetCardTransactionEasyPaySuperUseCase {
    var executeCalls = 0

    func completeWith(with cardTransactionEasyPay: CardTransactionEasyPay) {
        delegate?.didFinishCardTransactionEasyPaySuccessfully(with: cardTransactionEasyPay)
    }

    func completeWith(error: String?) {
        delegate?.didFinishCardTransactionEasyPayWithError(error)
    }

    override func requestValue(card: CardEntity, transaction: CardTransactionEntity) {
        executeCalls += 1
    }
}
