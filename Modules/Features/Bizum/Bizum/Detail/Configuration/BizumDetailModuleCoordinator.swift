import UI
import CoreFoundationLib

protocol DetailModuleCoordinatorProtocol {
    func openImageDetail(_ image: Data)
    func didSelectDismiss()
    func didSelectReuseContact(_ contacts: [BizumContactEntity])
    func didSelectCancelNotRegistered(_ operationEntity: BizumHistoricOperationEntity)
    func didSelectAcceptRequest(_ entity: BizumHistoricOperationEntity)
    func didSelectRejectRequest(_ entity: BizumHistoricOperationEntity)
    func didSelectCancelRequest(_ entity: BizumHistoricOperationEntity)
    func didSelectRefund(_ entity: BizumHistoricOperationEntity)
    func didSelectSendAgain(_ type: BizumEmitterType, contact: BizumContactEntity, sendMoney: BizumSendMoney, items: [BizumDetailItemsViewModel])
    func didSelectRejectSend(_ entity: BizumHistoricOperationEntity)
    func sendAgainViewDisappear()
}

final class BizumDetailModuleCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private weak var presentedNavigation: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let sendAgainCoordinator: BizumSendAgainCoordinator

    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.sendAgainCoordinator = BizumSendAgainCoordinator(navigationController: navigationController, dependenciesResolver: dependenciesEngine)
        self.setupDependencies()
    }

    // MARK: - Start coordinator
    /// The custom navigator should be overFullScreen modal presentation Style
    func start() {
        let controller = self.dependenciesEngine.resolve(for: BizumDetailViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: true)
    }
}

extension BizumDetailModuleCoordinator: DetailModuleCoordinatorProtocol {
    func didSelectCancelRequest(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumCancelRequest(entity)
    }
    
    func didSelectRejectRequest(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumRejectRequest(entity)
    }
    
    func didSelectRejectSend(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumRejectSend(entity)
    }
    
    func didSelectRefund(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumRefundMoney(operation: entity)
    }
    
    func didSelectAcceptRequest(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumAcceptRequestMoney(entity)
    }
    
    func didSelectReject(_ entity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumCancel(entity)
    }
    
    func openImageDetail(_ image: Data) {
        let viewController = BizumImageViewerViewController(nibName: "BizumImageViewerViewController",
                                                            bundle: .module,
                                                            image: image)
        let transitioningDelegate = HalfSizePresentationManager()
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle = .coverVertical
        viewController.transitioningDelegate = transitioningDelegate
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }

    func didSelectDismiss() {
        self.navigationController?.popViewController(animated: true)
    }

    func didSelectReuseContact(_ contacts: [BizumContactEntity]) {
        self.dependenciesEngine.register(for: BizumDetailOperationConfiguration.self) { _ in
            return BizumDetailOperationConfiguration(contacts: contacts)
        }
        let reuseContactCoordinator = ReuseContactCoordinator(dependenciesResolver: dependenciesEngine, navigationController: self.navigationController)
        reuseContactCoordinator.start()
    }

    func didSelectCancelNotRegistered(_ operationEntity: BizumHistoricOperationEntity) {
        self.delegate.goToBizumCancel(operationEntity)
    }

    func didSelectSendAgain(_ type: BizumEmitterType, contact: BizumContactEntity, sendMoney: BizumSendMoney, items: [BizumDetailItemsViewModel]) {
        self.dependenciesEngine.register(for: BizumSendAgainConfiguration.self) { _ in
            return BizumSendAgainConfiguration(type, contact: contact, sendMoney: sendMoney, items: items)
        }
        sendAgainCoordinator.start()
    }
    
    func sendAgainViewDisappear() {
        self.sendAgainCoordinator.sendAgainViewDisappear()
    }
}

private extension BizumDetailModuleCoordinator {
    var delegate: BizumHomeModuleCoordinatorDelegate {
        return self.dependenciesEngine.resolve(for: BizumHomeModuleCoordinatorDelegate.self)
    }
    
    func setupDependencies() {
        self.dependenciesEngine.register(for: GetMultimediaContentUseCase.self) { dependenciesResolver in
            return GetMultimediaContentUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetGlobalPositionUseCaseAlias.self) { dependenciesResolver in
            return GetGlobalPositionUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: BizumDetailPresenterProtocol.self) { dependenciesResolver in
            let bizumHistoric: BizumHistoricOperationConfiguration = dependenciesResolver.resolve()
            let presenter = BizumDetailPresenter(dependenciesResolver: dependenciesResolver, detail: bizumHistoric.bizumHistoricOperationEntity)
            return presenter
        }
        self.dependenciesEngine.register(for: BizumDetailViewController.self) { dependenciesResolver in
            var presenter: BizumDetailPresenterProtocol = dependenciesResolver.resolve()
            let viewController = BizumDetailViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: DetailModuleCoordinatorProtocol.self) { _ in
            return self
        }
    }
}
