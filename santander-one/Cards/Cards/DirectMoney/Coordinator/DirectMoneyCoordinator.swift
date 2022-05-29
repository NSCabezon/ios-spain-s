import CoreFoundationLib
import UI

public final class DirectMoneyCoordinator: ModuleCoordinator {
    public var navigationController: UINavigationController?
    private var dependenciesEngine: DependenciesDefault
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let configuration: CardsHomeConfiguration = self.dependenciesEngine.resolve(for: CardsHomeConfiguration.self)
        guard let entity = configuration.selectedCard else {
            self.coordinatorSelectorList.start()
            return
        }
        self.didSelectCard(entity)
    }
}

private extension DirectMoneyCoordinator {
    var coordinatorSelectorList: CardSelectorListCoordinator {
        self.dependenciesEngine.resolve(for: CardSelectorListCoordinator.self)
    }
    var coordinatorDelegate: CardsHomeModuleCoordinatorDelegate {
        self.dependenciesEngine.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: GetDirectMoneyWebViewConfigurationUseCase.self) { resolver in
            return GetDirectMoneyWebViewConfigurationUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: CardSelectorListCoordinator.self) { resolver in
            return CardSelectorListCoordinator(dependenciesResolver: resolver, navigationController: self.navigationController)
        }
        self.dependenciesEngine.register(for: CardSelectorItemCoordinatorDelegate.self) { resolver in
            return DirectMoneyCoordinator(dependenciesResolver: resolver, navigationController: self.navigationController)
        }
        self.dependenciesEngine.register(for: CardSelectorListConfiguration.self) { _ in
            return CardSelectorListConfiguration(allowedTypes: [.credit], titleToolbar: "toolbar_title_directMoney")
        }
    }
}

extension DirectMoneyCoordinator: CardSelectorItemCoordinatorDelegate {
    func didSelectCard(_ cardEntity: CardEntity) {
        let getDirectMoneyUseCase = self.dependenciesEngine.resolve(for: GetDirectMoneyWebViewConfigurationUseCase.self)
        let input = GetDirectMoneyWebViewConfigurationUseCaseInput(card: cardEntity)
        Scenario(useCase: getDirectMoneyUseCase, input: input)
            .execute(on: self.dependenciesEngine.resolve())
            .onSuccess { response in
                self.coordinatorDelegate.goToWebView(configuration: response.configuration)
            }
    }
}
