import CoreFoundationLib
import UI

protocol BizumHistoricModuleCoordinatorProtocol {
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectDetail(_ entity: BizumHistoricOperationEntity)
    func didSelectAccept(_ entity: BizumHistoricOperationEntity)
    func didSelectRefund(_ entity: BizumHistoricOperationEntity)
    func didSelectRejectRequest(_ entity: BizumHistoricOperationEntity)
    func didSelectCancel(_ entity: BizumHistoricOperationEntity)
    func didSelectCancelRequest(_ entity: BizumHistoricOperationEntity)
}

final class BizumHistoricModuleCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private var detailModuleCoordinator: BizumDetailModuleCoordinator?
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: BizumHistoricViewController.self)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension BizumHistoricModuleCoordinator: BizumHistoricModuleCoordinatorProtocol {
    func didSelectRejectRequest(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumRejectRequest(entity)
    }
    
    func didSelectRefund(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumRefundMoney(operation: entity)
    }
    
    func didSelectAccept(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumAcceptRequestMoney(entity)
    }
    
    func didSelectCancel(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumCancel(entity)
    }
    
    func didSelectCancelRequest(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumCancelRequest(entity)
    }
    
    func didSelectMenu() {
        self.delegate.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectDetail(_ entity: BizumHistoricOperationEntity) {
        self.dependenciesEngine.register(for: BizumHistoricOperationConfiguration.self) { _ in
            BizumHistoricOperationConfiguration(bizumHistoricOperationEntity: entity)
        }
        self.detailModuleCoordinator = BizumDetailModuleCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
        self.detailModuleCoordinator?.start()
    }

    func didSelectSearch() {
        self.delegate.didSelectSearch()
    }
}

private extension BizumHistoricModuleCoordinator {
    var delegate: BizumHomeModuleCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: BizumHomeModuleCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: BizumHistoricPresenterProtocol.self) { dependenciesResolver in
            let configuration: BizumCheckPaymentConfiguration = dependenciesResolver.resolve()
            return BizumHistoricPresenter(dependenciesResolver: dependenciesResolver, bizumCheckPaymentEntity: configuration.bizumCheckPaymentEntity)
        }
        self.dependenciesEngine.register(for: BizumHistoricViewController.self) { dependenciesResolver in
            let presenter: BizumHistoricPresenterProtocol = dependenciesResolver.resolve(for: BizumHistoricPresenterProtocol.self)
            let viewController = BizumHistoricViewController(nibName: "BizumHistoricViewController", bundle: Bundle.module, presenter: presenter)
            presenter.setView(viewController)
            return viewController
        }
        self.dependenciesEngine.register(for: BizumHistoricModuleCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: BizumOperationListMultipleUseCase.self) { dependenciesResolver in
            return BizumOperationListMultipleUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: BizumOperationMultipleDetailUseCase.self) { dependenciesResolver in
            return BizumOperationMultipleDetailUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: BizumHistoricSuperUseCase.self) { dependenciesResolver in
            return BizumHistoricSuperUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: BizumOperationUseCase.self) { dependenciesResolver in
            return BizumOperationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: BizumHistoricOperationMixerUseCase.self) { _ in
            return BizumHistoricOperationMixerUseCase()
        }
    }
}
