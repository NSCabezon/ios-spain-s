import CoreFoundationLib
import CoreTestData
import CoreDomain
import QuickSetup
import Transfer
import UIKit
import UI

class ViewController: UIViewController {
    var navController = UINavigationController()
    let quickSetup = QuickSetupForCoreTestData()
    private lazy var servicesProvider: ServicesProvider = {
        return quickSetup
    }()
    
    private var serviceInjectors: [CustomServiceInjector] {
        return [
            TransferServiceInjector()
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presentModule()
    }
    
    private func presentModule() {
        let coordinator = TransferModuleCoordinator(
            transferExternalResolver: dependenciesResolver.resolve(),
            navigationController: navController
        )
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: false, completion: {
            coordinator.start(.home)
        })
    }
    
    private lazy var dependenciesResolver: DependenciesResolver = {
        let defaultResolver = DependenciesDefault()
        defaultResolver.register(for: [CustomServiceInjector].self) { _ in
            return self.serviceInjectors
        }
        self.servicesProvider.registerDependencies(in: defaultResolver)
        DefaultDependenciesInitializer(dependencies: defaultResolver).registerDefaultDependencies()
        TransferDependenciesInitializer(dependencies: defaultResolver, injector: quickSetup.mockDataInjector, navController: navController).registerDependencies()
        defaultResolver.register(for: TransferExternalDependenciesResolver.self) { _ in
            return ModuleDependencies(
                dependencies: defaultResolver,
                navigationController: self.navController,
                mockDataInjector: self.quickSetup.mockDataInjector
            )
        }
        return defaultResolver
    }()
}

struct ModuleDependencies {
    func resolve() -> AppConfigRepositoryProtocol {
        return dependencies.resolve()
    }
    
    func resolve() -> FaqsRepositoryProtocol {
        return dependencies.resolve()
    }
    
    func resolve() -> GetAllTransfersReactiveUseCase {
        return GetAllTransfersReactiveUseCaseMock(mockDataInjector: mockDataInjector)
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func resolve() -> CoreDependencies {
        return self
    }
    
    let dependencies: DependenciesInjector & DependenciesResolver
    let navigationController: UINavigationController
    let mockDataInjector: MockDataInjector
    let globalPositionRepository: GlobalPositionDataRepository
    
    init(dependencies: DependenciesInjector & DependenciesResolver,
         navigationController: UINavigationController,
         mockDataInjector: MockDataInjector) {
        self.dependencies = dependencies
        self.navigationController = navigationController
        self.mockDataInjector = mockDataInjector
        self.globalPositionRepository = DefaultGlobalPositionDataRepository()
    }
    
    func resolve() -> DependenciesInjector {
        return dependencies
    }
    
    func resolve() -> DependenciesResolver {
        return dependencies
    }
    
    func resolve() -> UINavigationController {
        return navigationController
    }
    
    func resolve() -> GetSendMoneyActionsUseCase {
        return DefaultGetSendMoneyActionsUseCase(candidateOfferUseCase: GetCandidateOfferUseCaseMock(mockDataInjector: mockDataInjector))
    }
}

extension ModuleDependencies: CoreDependencies {
    
}

extension ModuleDependencies: TransferExternalDependenciesResolver{
    func resolve() -> EngineInterface {
        return dependencies.resolve()
    }
    
    func resolve() -> PullOffersInterpreter {
        return dependencies.resolve()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> AppRepositoryProtocol {
        return dependencies.resolve()
    }
    
    func resolve() -> PullOffersConfigRepositoryProtocol {
        return dependencies.resolve()
    }
    
    func resolve() -> AccountNumberFormatterProtocol? {
        return nil
    }
}
