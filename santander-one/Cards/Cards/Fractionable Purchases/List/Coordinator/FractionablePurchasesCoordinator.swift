//
//  FractionablePurchasesCoordinator.swift
//  Cards
//
//  Created by César González Palomino on 12/02/2021.
//

import CoreFoundationLib
import UI
import SANLegacyLibrary
import OpenCombine

protocol FractionablePurchasesCoordinatorProtocol: ModuleCoordinator {
    func didSelectDismiss()
    func didSelectMenu()
    func didSelectPurchase(_ card: CardEntity, movement: String, movements: [FinanceableMovementEntity])
    func goToTransaction(_ transaction: CardTransactionEntity, card: CardEntity)
    func didSelectViewMore()
}

final class FractionablePurchasesCoordinator {
    private let externalDependencies: CardExternalDependenciesResolver
    private let dependenciesEngine: DependenciesResolver & DependenciesInjector
    weak var navigationController: UINavigationController?
    private var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver,
         navigationController: UINavigationController?,
         externalDependencies: CardExternalDependenciesResolver) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.externalDependencies = externalDependencies
        self.setupDependencies()
    }
    
    private func setupDependencies() {
        dependenciesEngine.register(for: GetFractionablePurchasesUseCase.self) { resolver in
            return GetFractionablePurchasesUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: FractionablePurchasesPresenterProtocol.self) { resolver in
            return FractionablePurchasesPresenter(dependenciesResolver: resolver)
        }
        
        self.dependenciesEngine.register(for: GetVisibleCardsUseCase.self) { resolver in
            return GetVisibleCardsUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetAllFractionablePurchasesSuperUseCase.self) { resolver in
            return GetAllFractionablePurchasesSuperUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: FractionablePurchasesViewController.self) { resolver in
            var presenter: FractionablePurchasesPresenterProtocol = resolver.resolve(for: FractionablePurchasesPresenterProtocol.self)
            let viewController = FractionablePurchasesViewController(nibName: "FractionablePurchasesViewController",
                                                                     bundle: Bundle.module,
                                                                     presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: FractionablePurchasesListViewModel.self) { resolver in
            return FractionablePurchasesListViewModel(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCardEasyPayOperativeDataUseCase.self) { resolver in
            return GetCardEasyPayOperativeDataUseCase(dependenciesResolver: resolver)
        }
        dependenciesEngine.register(for: FirstFeeInfoEasyPayUseCase.self) { resolver in
            return FirstFeeInfoEasyPayUseCase(dependenciesResolver: resolver)
        }
    }
}

extension FractionablePurchasesCoordinator: FractionablePurchasesCoordinatorProtocol {
    public func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func didSelectMenu() {
        let cardHomeCoordinator = dependenciesEngine.resolve(for: CardsTransactionDetailModuleCoordinatorDelegate.self)
        cardHomeCoordinator.didSelectMenu()
    }
    
    public func didSelectPurchase(_ card: CardEntity, movement: String, movements: [FinanceableMovementEntity]) {
        self.dependenciesEngine.register(for: FractionablePurchaseDetailConfiguration.self) { _ in
            return FractionablePurchaseDetailConfiguration(card: card, movementID: movement, movements: movements)
        }
        let coordinator = FractionablePurchaseDetailCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController ?? UINavigationController())
        coordinator.start()
    }
    
    func goToTransaction(_ transaction: CardTransactionEntity, card: CardEntity) {
        let booleanFeatureFlag: BooleanFeatureFlag = dependenciesEngine.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.cardTransactionDetail)
            .filter { $0 == true }
            .sink { [unowned self] _ in
                externalDependencies
                    .cardTransactionDetailCoordinator()
                    .set(card.representable)
                    .set(transaction.representable)
                    .start()
            }.store(in: &subscriptions)
        
        booleanFeatureFlag.fetch(CoreFeatureFlag.cardTransactionDetail)
            .filter { $0 == false }
            .sink { [unowned self] _ in
                self.dependenciesEngine.register(for: CardTransactionDetailConfiguration.self) { _ in
                    return CardTransactionDetailConfiguration(selectedCard: card, selectedTransaction: transaction, allTransactions: [transaction])
                }
                let cardTransactionDetailCoordinator = OldCardTransactionDetailCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController ?? UINavigationController(), externalDependencies: externalDependencies)
                cardTransactionDetailCoordinator.start()
            }.store(in: &subscriptions)
    }
    
    func didSelectViewMore() {
        let coordinator = ListAllFractionablePurchasesCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController ?? UINavigationController(), externalDependencies: externalDependencies)
        coordinator.start()
    }
}

extension FractionablePurchasesCoordinator: ModuleCoordinator {
    func start() {
        let controller = self.dependenciesEngine.resolve(for: FractionablePurchasesViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
}

struct FractionablePurchasesConfiguration {
    let card: CardEntity
}
