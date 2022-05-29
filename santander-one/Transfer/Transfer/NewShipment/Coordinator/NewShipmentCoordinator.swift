import TransferOperatives
import CoreFoundationLib
import Operative
import UI

final class NewShipmentCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private let legacyDependenciesEngine: DependenciesInjector & DependenciesResolver
    let transferExternalDependencies: OneTransferHomeExternalDependenciesResolver
    var childCoordinators: [Coordinator] = []

    init(legacyDependencies: DependenciesResolver, transferExternalDependencies: OneTransferHomeExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.legacyDependenciesEngine = DependenciesDefault(father: legacyDependencies)
        self.navigationController = navigationController
        self.transferExternalDependencies = transferExternalDependencies
        self.setupDependencies()
    }
    
    func start() {
        let controller = legacyDependenciesEngine.resolve(for: NewShipmentViewController.self)
        controller.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(controller, animated: false, completion: nil)
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        self.navigationController?.presentedViewController?.dismiss(animated: true, completion: completion)
    }
    
    private func setupDependencies() {
        legacyDependenciesEngine.register(for: NewShipmentPresenterProtocol.self) { dependenciesResolver in
            return NewShipmentPresenter(dependenciesResolver: dependenciesResolver)
        }
        
        legacyDependenciesEngine.register(for: NewShipmentViewController.self) { dependenciesResolver in
            var presenter =  dependenciesResolver.resolve(for: NewShipmentPresenterProtocol.self)
            let controller = NewShipmentViewController(nibName: "NewShipment", bundle: .module, presenter: presenter)
            presenter.view = controller
            return controller
        }
    }
}

extension NewShipmentCoordinator: TransferActionCoordinator {
    func didSelectTransferBetweenAccounts(_ account: AccountEntity?, _ offer: OfferEntity?) {
        self.dismiss { [weak self] in
            guard let self = self else { return }
            let internalTransferLauncher: InternalTransferLauncher = self.transferExternalDependencies.resolve()
            if let account = account {
                internalTransferLauncher.set(account.representable)
            }
            internalTransferLauncher.start()
            internalTransferLauncher.onFinish = { [weak self] in
                self?.childCoordinators.removeAll()
            }
            self.childCoordinators.append(internalTransferLauncher)

        }
    }
    
    func didSelectScheduledTransfers() {
        let scheduledTransfersCoordinator = legacyDependenciesEngine.resolve(for: ScheduledTransfersCoordinator.self)
        scheduledTransfersCoordinator.start()
    }
}

extension NewShipmentCoordinator: OperativeLauncherHandler {
    var dependenciesResolver: DependenciesResolver {
        return legacyDependenciesEngine
    }
    
    var operativeNavigationController: UINavigationController? {
        return navigationController
    }
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        let delegate = legacyDependenciesEngine.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
        let viewController = legacyDependenciesEngine.resolve(for: TransferHomeViewController.self)
        delegate.showDialog(configuration: DialogConfiguration(acceptTitle: "generic_button_accept",
                                                               cancelTitle: nil,
                                                               title: keyTitle,
                                                               body: keyDesc,
                                                               source: viewController,
                                                               acceptAction: nil,
                                                               cancelAction: nil))
        completion?()
    }
}
