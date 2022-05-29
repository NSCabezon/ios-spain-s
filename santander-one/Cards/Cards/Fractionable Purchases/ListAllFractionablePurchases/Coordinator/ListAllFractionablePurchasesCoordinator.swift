import UI
import CoreFoundationLib
import OpenCombine

protocol ListAllFractionablePurchasesCoordinatorProtocol {
    func goToDetail(_ transaction: CardTransactionEntity, card: CardEntity)
    func dismiss()
    func didSelectMenu()
    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?)
}

final class ListAllFractionablePurchasesCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let externalDependencies: CardExternalDependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver,
         navigationController: UINavigationController?,
         externalDependencies: CardExternalDependenciesResolver) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.externalDependencies = externalDependencies
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: ListAllFractionablePurchasesViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension ListAllFractionablePurchasesCoordinator: ListAllFractionablePurchasesCoordinatorProtocol {
    func goToDetail(_ transaction: CardTransactionEntity, card: CardEntity) {
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
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        self.cardHomeCoordinatorDelegate.didSelectMenu()
    }
    
    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?) {
        cardHomeCoordinatorDelegate.easyPay(entity: card, transactionEntity: transaction, easyPayOperativeDataEntity: easyPayOperativeData)
    }
}

private extension ListAllFractionablePurchasesCoordinator {
    var cardHomeCoordinatorDelegate: CardsHomeModuleCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: CardsHomeModuleCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: ListAllFractionablePurchasesCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: ListAllFractionablePurchasesPresenterProtocol.self) { resolver in
            return ListAllFractionablePurchasesPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ListAllFractionablePurchasesViewController.self) { resolver in
            var presenter = resolver.resolve(for: ListAllFractionablePurchasesPresenterProtocol.self)
            let viewController = ListAllFractionablePurchasesViewController(
                dependenciesResolver: resolver,
                presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: GetAllFractionablePurchasesSuperUseCase.self) { resolver in
            return GetAllFractionablePurchasesSuperUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: GetCardTransactionEasyPaySuperUseCase.self) { resolver in
            return GetCardTransactionEasyPaySuperUseCase(dependenciesResolver: resolver)
        }
    }
}
