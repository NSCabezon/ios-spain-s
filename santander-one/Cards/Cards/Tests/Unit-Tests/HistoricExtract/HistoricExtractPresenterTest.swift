import XCTest
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData
import Operative
@testable import Cards

final class HistoricExtractPresenterTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    internal var dependenciesResolver = DependenciesDefault()
    let cardsServiceInjector = CardsServiceInjector()
    private var presenter: HistoricExtractPresenter!
    private var view: HistoricExtractViewMock!
    private var useCase: GetHistoricExtractUseCaseMock!
    private var container: ContainerProtocolMock!
    private var finishingCoordinator: FinishingCoordinatorMock!
    private var moduleCoordinator: ModuleCoordinatorDelegateMock!
    private lazy var bSanCardsManager: BSANCardsManager = {
        let managerProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        return managerProvider.getBsanCardsManager()
    }()
    
    override func setUp() {
        super.setUp()
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setDependencies()
        self.setMockData()
        self.useCase.setupOutput()
    }

    override func tearDown() {
        super.tearDown()
        self.presenter = nil
        self.dependenciesResolver.clean()
    }
    
    // MARK: ShoppingMap Pill
    func test_actionButtons_withNilDates_shouldEnableShoppingMapPill() {
        // Prepare
        self.useCase.setStartDateOrEndDateNil()
        presenter.container = self.container
        self.updatePresenterOperativeDataWithMockedData()
        // Execute
        XCTAssertTrue(presenter.isShoppingMapEnabled, "isShoppingMapEnabled when startDate and endDate are nil but result isMapEnabled should be true")
    }
    
    func test_actionButtons_withDates_shouldEnableShoppingMapPill() {
        // Prepare
        self.useCase.setStartDateAndEndDate()
        presenter.container = self.container
        self.updatePresenterOperativeDataWithMockedData()
        // Execute
        XCTAssertTrue(presenter.isShoppingMapEnabled, "isShoppingMapEnabled when startDate and endDate are Dates")
    }
    
    func test_actionButtons_withNilDatesAndResponseIsMapEnabledToFalse_shouldDisableShoppingMapPill() {
        // Prepare
        self.useCase.setStartDateOrEndDateNilAndDisabledMap()
        presenter.container = self.container
        self.updatePresenterOperativeDataWithMockedData()
        // Execute
        XCTAssertFalse(presenter.isShoppingMapEnabled, "isShoppingMapDisabled when when startDate and endDate are nil but result isMapEnabled should be false")
    }
    
    // MARK: ExtractPDF Pill
    func test_actionButtons_withIsSuperOwnerSpeedToFalse_shouldDisableExtractPdfPill() {
        presenter.container = self.container
        XCTAssertFalse(presenter.isExtractPdfEnabled, "Extract PDF Pill is disabled")
    }
    
    func test_actionButtons_withIsSuperOwnerSpeedToTrue_shouldEnableExtractPdfPill() {
        presenter.container = self.container
        self.setCardWithSuperOwnerSpeedInOperativeData()
        XCTAssertTrue(true)
    }
    
    // MARK: Load ViewModels
    func test_headerViewModel_withMockData_shouldSetHeaderViewModel() {
        // Prepare
        presenter.container = self.container
        self.updatePresenterOperativeDataWithMockedData()
        guard let headerViewModel = loadHeaderViewModel() else {
            return XCTFail("No HeaderViewModel founded")
        }
        // Execute
        presenter.view?.setHeaderViewModel(headerViewModel)
        XCTAssert(true)
    }

    func test_groupedViewModel_withMockData_shouldSetGroupedViewModels() {
        // Prepare
        presenter.container = self.container
        self.updatePresenterOperativeDataWithMockedData()
        // Execute
        guard let groupedViewModels = loadGroupedMovementsViewModels() else {
            return XCTFail("No GroupedViewModels founded")
        }
        presenter.view?.setGroupedViewModels(groupedViewModels)
        XCTAssert(true)
    }
    
    // MARK: Movements List
    func test_settlementMovements_withEmptyMovements_shouldDisplayEmptyView() {
        presenter.container = self.container
        guard let movements = self.useCase.output?.settlementMovementsList, !movements.isEmpty else {
            return XCTAssert(true, "There are no mocked movements to show.")
        }
        XCTFail("It contains movements to display")
    }

    func test_settlementMovements_withMockDataMovements_shouldDisplayMovementList() {
        // Prepare
        presenter.container = self.container
        self.registerSettlementDependencies()
        self.addMovementsToMockedOutput()
        // Execute
        guard let movements = self.useCase.output?.settlementMovementsList, !movements.isEmpty else {
            return XCTFail("There are no mocked movements to show.")
        }
        XCTAssert(!movements.isEmpty, "It contains movements to display")
    }
    
    // MARK: Actions
    func test_actionButtons_didTapInshoppingMapPillWithConfiguration_shouldOpenShoppingMapScreen() {
        // Prepare
        presenter.container = self.container
        self.setFinishingCoordinatorMock()
        // Execute
        presenter.didTapInShopMapPill()
        XCTAssertNotNil(self.finishingCoordinator.cardConfiguration, "")
    }

    func test_actionButtons_didTapInshoppingMapPillWithSelectedCard_shouldOpenShoppingMapScreen() {
        // Prepare
        presenter.container = self.container
        self.setFinishingCoordinatorMock()
        // Execute
        presenter.didTapInShopMapPill()
        XCTAssertNotNil(self.finishingCoordinator.selectedCard, "OK: It will display shoppingMap detail screen")
    }

    func test_actionButtons_didTapInExtractPdfPillWithCardEntity_shouldOpenExtractPdfScreen() {
        // Prepare
        presenter.container = self.container
        self.setModuleCoordinatorMock()
        // Execute
        presenter.didTapInPdfExtractPill()
        XCTAssertNotNil(self.moduleCoordinator.cardEntity, "OK: It will display Extract PDF detail screen")
    }
}

private extension HistoricExtractPresenterTest {
    func setDependencies() {
        self.setupCommonsDependencies()
        self.dependenciesResolver.register(for: HistoricExtractOperativeFinishingCoordinatorProtocol.self, with: { _ in
            self.finishingCoordinator = FinishingCoordinatorMock()
            return self.finishingCoordinator
        })
        self.dependenciesResolver.register(for: Operative.self) { _ in
            return OperativeMock(dependencies: self.dependenciesResolver)
        }
        self.dependenciesResolver.register(for: OperativeContainerCoordinatorProtocol.self) { _ in
            return CoordinatorProtocolMock()
        }
        self.dependenciesResolver.register(for: OperativeStepPresenterProtocol.self) { _ in
            return StepPresenterProtocolMock()
        }
        self.dependenciesResolver.register(for: HistoricExtractUseCase.self) { _ in
            return self.useCase
        }
        self.dependenciesResolver.register(for: HistoricExtractViewProtocol.self) { _ in
            return self.view
        }
    }
    
    func registerSettlementDependencies() {
        self.mockDataInjector.register(
            for: \.cardsData.getCardSettlementMovements,
            filename: "getSettlementMovements"
        )
    }
    
    func setMockData() {
        self.container = ContainerProtocolMock(dependencies: dependenciesResolver)
        self.view = HistoricExtractViewMock()
        self.useCase = GetHistoricExtractUseCaseMock(dependenciesResolver: dependenciesResolver)
        self.presenter = HistoricExtractPresenter(dependenciesResolver: dependenciesResolver)
        self.presenter.view = view
        self.finishingCoordinator = FinishingCoordinatorMock()
        self.moduleCoordinator = ModuleCoordinatorDelegateMock()
    }
    
    // MARK: Methods used in Tests
    func updatePresenterOperativeDataWithMockedData() {
        presenter.operativeData.cardDetail = self.useCase.output?.cardDetailEntity
        presenter.operativeData.cardSettlementDetailEntity = self.useCase.output?.cardSettlementDetailEntity
        presenter.operativeData.currentPaymentMethod = self.useCase.output?.currentPaymentMethod
        presenter.operativeData.currentPaymentMethodMode = self.useCase.output?.currentPaymentMethodMode
        presenter.operativeData.isMultipleMapEnabled = self.useCase.output?.isEnableCardsHomeLocationMap ?? false
        presenter.operativeData.scaDate = self.useCase.output?.scaDate
    }
    
    func addMovementsToMockedOutput() {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let card = globalPosition.cards.first else { return }
        do {
            let movementsResponse = try self.bSanCardsManager.getCardSettlementListMovements(card: card.dto, extractNumber: 5)
            guard movementsResponse.isSuccess(), let movementsDTO = try movementsResponse.getResponseData()
            else { return }
            let settlementMovementsList: [CardSettlementMovementEntity] = movementsDTO.map { CardSettlementMovementEntity($0) }
            self.useCase.output?.settlementMovementsList = settlementMovementsList
        } catch {
            print("Couldn't load movements in Mocked output data")
        }
    }
    
    func loadHeaderViewModel() -> NextSettlementViewModel? {
        var baseURLProvider: BaseURLProvider {
            return dependenciesResolver.resolve(for: BaseURLProvider.self)
        }
        guard let settlementMovementsOwnerPan = presenter.operativeData.ownerPan, let settlementMovementsScaDate = presenter.operativeData.scaDate, let detailEntity = presenter.operativeData.cardSettlementDetailEntity else {
            return nil
        }
        let panMovements: [NextSettlementMovementWithPANViewModel] = [NextSettlementMovementWithPANViewModel(presenter.operativeData.card, movementsEntity: presenter.operativeData.settlementMovements)]
        let configuration = NextSettlementConfiguration(card: presenter.operativeData.card, cardSettlementDetailEntity: detailEntity, isMultipleMapEnabled: presenter.isShoppingMapEnabled)
        return NextSettlementViewModel(configuration, cardDetail: presenter.operativeData.cardDetail, baseUrl: baseURLProvider.baseURL, movements: panMovements, paymentMethod: presenter.operativeData.currentPaymentMethod, paymentMethodDescription: presenter.operativeData.currentPaymentMethodMode, isMultipleMapEnabled: presenter.isShoppingMapEnabled, ownerPan: settlementMovementsOwnerPan, scaDate: settlementMovementsScaDate, enablePayLater: false)
    }
    
    func loadGroupedMovementsViewModels() -> [GroupedMovementsViewModel]? {
        self.addMovementsToMockedOutput()
        guard let movementsList = self.useCase.output?.settlementMovementsList else {
            return nil
        }
        let newSettlementMovements: [NextSettlementMovementViewModel] = movementsList.compactMap { (itemEntity) in
            return NextSettlementMovementViewModel(itemEntity)
        }
        let movementsByDate: [Date: [NextSettlementMovementViewModel]] = newSettlementMovements.reduce([:], groupMovementsByDate)
        return movementsByDate.map({ GroupedMovementsViewModel(date: $0.key, movements: $0.value)}).sorted(by: { $0.date > $1.date })
    }
    
    func groupMovementsByDate(_ groupedMovements: [Date: [NextSettlementMovementViewModel]], movement: NextSettlementMovementViewModel) -> [Date: [NextSettlementMovementViewModel]] {
        var groupedMovements = groupedMovements
        guard let operationDate = movement.completeDate else { return groupedMovements }
        guard
            let dateByDay = groupedMovements.keys.first(where: { $0.isSameDay(than: operationDate) }),
            let movementsByDate = groupedMovements[dateByDay]
        else {
            groupedMovements[operationDate.startOfDay()] = [movement]
            return groupedMovements
        }
        groupedMovements[dateByDay] = movementsByDate + [movement]
        return groupedMovements
    }
    
    func setFinishingCoordinatorMock() {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let card = globalPosition.cards.first else {
            return XCTFail("No card founded")
        }
        self.finishingCoordinator.selectedCard = card
        guard let startDate = self.useCase.output?.cardSettlementDetailEntity?.startDate,
            let endDate = self.useCase.output?.cardSettlementDetailEntity?.endDate else {
            return XCTFail("No Dates founded")
        }
        let configurationMapType = CardMapTypeConfiguration.date(startDate: startDate, endDate: endDate)
        self.finishingCoordinator.cardConfiguration = configurationMapType
    }
    
    func setModuleCoordinatorMock() {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let card = globalPosition.cards.first else {
            return XCTFail("No card founded")
        }
        self.moduleCoordinator.cardEntity = card
        self.moduleCoordinator.selectedMonth = "Octubre 2020"
    }
    
    func setCardWithSuperOwnerSpeedInOperativeData() {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let card = globalPosition.cards.filter({$0.isOwnerSuperSpeed}).first else {
            return XCTAssert(true)
        }
        presenter.operativeData.card = card
    }
}

extension HistoricExtractPresenterTest: RegisterCommonDependenciesProtocol { }
