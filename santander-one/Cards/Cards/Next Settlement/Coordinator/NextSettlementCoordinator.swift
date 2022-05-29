//
//  NextSettlementCoordinator.swift
//  Cards
//
//  Created by Laura González on 05/10/2020.
//

import CoreFoundationLib
import UI

public final class NextSettlementCoordinator {
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    private let externalDependencies: CardExternalDependenciesResolver
    weak public var navigationController: UINavigationController?
    private let nextSettlementMovementsCoordinator: NextSettlementMovementsCoordinator
    
    public init(dependenciesResolver: DependenciesResolver,
                navigationController: UINavigationController?,
                externalDependencies: CardExternalDependenciesResolver) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.externalDependencies = externalDependencies
        self.nextSettlementMovementsCoordinator = NextSettlementMovementsCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController, externalDependencies: self.externalDependencies)
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        self.dependenciesEngine.register(for: NextSettlementCoordinator.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: NextSettlementPresenterProtocol.self) { dependenciesResolver in
            return NextSettlementPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: NextSettlementViewController.self) { dependenciesResolver in
            let presenter: NextSettlementPresenterProtocol = dependenciesResolver.resolve(for: NextSettlementPresenterProtocol.self)
            let viewController = NextSettlementViewController(nibName: "NextSettlementViewController", bundle: Bundle.module, presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: GetCardSettlementMovementsUseCase.self) { dependenciesResolver in
            return GetCardSettlementMovementsUseCase(dependenciesResolver: dependenciesResolver)
        }

        self.dependenciesEngine.register(for: GetCardPaymentMethodUseCase.self) { dependenciesResolver in
            return GetCardPaymentMethodUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension NextSettlementCoordinator: ModuleCoordinator {
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: NextSettlementViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gotoNextSettlementMovements(_ cardEntity: CardEntity, nextSettlementViewModel: NextSettlementViewModel?) {
        guard let nextSettlementViewModelCopy = nextSettlementViewModel?.copy() as? NextSettlementViewModel else { return }
        self.dependenciesEngine.register(for: NextSettlementMovementsConfiguration.self) { _ in
            return NextSettlementMovementsConfiguration(card: cardEntity, nextSettlementViewModel: nextSettlementViewModelCopy)
        }
        nextSettlementMovementsCoordinator.start()
    }
        
    func goToMapView(_ selectedCard: CardEntity, type: CardMapTypeConfiguration) {
        let coordinator = externalDependencies.shoppingMapCoordinator()
        let configuration = CardMapConfiguration(type: type,
                                                 card: selectedCard.representable)
        coordinator.set(configuration)
        coordinator.start()
    }
}
