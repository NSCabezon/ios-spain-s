import CoreFoundationLib
import CoreTestData
import OpenCombine
import CoreDomain
import QuickSetup
import Transfer
import UI

class OneTransferHomeExternalDependenciesResolverMock: OneTransferHomeExternalDependenciesResolver {
    private let oldDependencies: DependenciesInjector & DependenciesResolver
    private let mockDataInjector: MockDataInjector
    private let globalPositionRepository: GlobalPositionDataRepository
    var contactsUseCase: GetReactiveContactsUseCaseMock!
    var actionsUseCase: GetSendMoneyActionsUseCase!
    var emittedTransfersUseCase: GetAllTransfersReactiveUseCaseMock!
    
    init(oldDependencies: DependenciesInjector & DependenciesResolver,
         mockDataInjector: MockDataInjector) {
        self.oldDependencies = oldDependencies
        self.mockDataInjector = mockDataInjector
        self.globalPositionRepository = DefaultGlobalPositionDataRepository()
    }
    
    func resolve() -> DependenciesInjector {
        return oldDependencies
    }
    
    func resolve() -> DependenciesResolver {
        return oldDependencies
    }
    
    func resolve() -> UINavigationController {
        return UINavigationController()
    }
    
    func resolve() -> GlobalPositionRepresentable {
        return GlobalPositionMock(
            mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
            cardsData: [:],
            temporallyOffCards: [:],
            inactiveCards: [:],
            cardBalances: [:]
        )
    }
    
    func resolve() -> AppRepositoryProtocol {
        return AppRepositoryMock()
    }
    
    func resolve() -> TransfersRepository {
        return MockTransfersRepository(mockDataInjector: mockDataInjector)
    }
    
    func resolve() -> GetReactiveContactsUseCase {
        return contactsUseCase
    }
    
    func resolve() -> GetSendMoneyActionsUseCase {
        return actionsUseCase
    }
    
    func resolve() -> GetAllTransfersReactiveUseCase {
        return emittedTransfersUseCase
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func resolve() -> CoreDependencies {
        return self
    }
    
    func resolve() -> PullOffersInterpreter {
        return PullOffersInterpreterMock()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        return MockPullOffersConfigRepository(mockDataInjector: mockDataInjector)
    }
    
    func resolve() -> AccountNumberFormatterProtocol? {
        return nil
    }
    
    func resolve() -> EngineInterface {
        return BaseEngine()
    }
}

extension OneTransferHomeExternalDependenciesResolverMock: CoreDependencies {
    func resolve() -> FaqsRepositoryProtocol {
        return MockFaqsRepository(mockDataInjector: mockDataInjector)
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return AppConfigRepositoryMock()
    }
}
