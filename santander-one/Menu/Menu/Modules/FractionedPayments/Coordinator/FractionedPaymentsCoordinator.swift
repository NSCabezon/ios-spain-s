import Foundation
import UI
import CoreDomain
import CoreFoundationLib

public protocol FractionedPaymentsCoordinatorDelegate: class {
    func didSelectMenu()
    func didSelectDismiss()
    func goToFractionedPaymentDetail(_ transaction: CardTransactionEntity, card: CardEntity)
    func gotoCardEasyPayOperative(card: CardEntity, transaction: CardTransactionEntity, easyPayOperativeData: EasyPayOperativeDataEntity?)
}

final class FractionedPaymentsCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let nibName = "FractionedPaymentsViewController"
    private(set) var launcher: FractionedPaymentsLauncher
    
    init(dependenciesResolver: DependenciesResolver,
         navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.launcher = dependenciesResolver.resolve(for: FractionedPaymentsLauncher.self)
        self.setupDependencies()
    }
    
    func start() {
        let controller = self.dependenciesEngine.resolve(for: FractionedPaymentsViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

private extension FractionedPaymentsCoordinator {
    var delegate: FractionedPaymentsCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: FractionedPaymentsCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: FractionedPaymentsPresenterProtocol.self) { dependenciesResolver in
            return FractionedPaymentsPresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: FractionedPaymentsViewController.self) { dependenciesResolver in
            let presenter: FractionedPaymentsPresenterProtocol = dependenciesResolver.resolve(for: FractionedPaymentsPresenterProtocol.self)
            let viewController = FractionedPaymentsViewController(
                nibName: self.nibName,
                bundle: .module,
                presenter: presenter
            )
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: FractionedPaymentsCoordinatorDelegate.self) { _ in
            return self
        }
        self.registerUseCases()
    }
    
    func registerUseCases() {
        self.dependenciesEngine.register(for: GetVisibleCardsUseCase.self) { dependenciesResolver in
            return GetVisibleCardsUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetCardTransactionEasyPaySuperUseCase.self) { dependenciesResolver in
            return GetCardTransactionEasyPaySuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetAllFractionedPaymentsForCardSuperUseCase.self) { dependenciesResolver in
            return GetAllFractionedPaymentsForCardSuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetCardEasyPayOperativeDataUseCase.self) { dependenciesResolver in
            return GetCardEasyPayOperativeDataUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: FirstFeeInfoEasyPayUseCase.self) { dependenciesResolver in
            return FirstFeeInfoEasyPayUseCase(dependenciesResolver: dependenciesResolver)
        }
    }
}

extension FractionedPaymentsCoordinator: FractionedPaymentsCoordinatorDelegate {
    func didSelectMenu() {
        launcher.didSelectInMenu()
    }
    
    func didSelectDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    func goToFractionedPaymentDetail(_ transaction: CardTransactionEntity,
                                     card: CardEntity) {
        launcher.goToFractionedPaymentDetail(
            transaction,
            card: card
        )
    }
    
    func gotoCardEasyPayOperative(card: CardEntity,
                                  transaction: CardTransactionEntity,
                                  easyPayOperativeData: EasyPayOperativeDataEntity?) {
        launcher.gotoCardEasyPayOperative(
            card: card,
            transaction: transaction,
            easyPayOperativeData: easyPayOperativeData
        )
    }
}
