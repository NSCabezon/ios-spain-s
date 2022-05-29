//
//  BizumDetailMultipleModuleCoordinator.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 27/01/2021.
//

import Foundation
import UI
import CoreFoundationLib

protocol DetailMultipleModuleCoordinatorProtocol {
    func openImageDetail(_ image: Data)
    func didSelectDismiss()
}

final class BizumDetailMultipleModuleCoordinator: ModuleCoordinator {
    weak var navigationController: UINavigationController?
    private weak var presentedNavigation: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }

    // MARK: - Start coordinator
    /// The custom navigator should be overFullScreen modal presentation Style
    func start() {
        let controller = self.dependenciesEngine.resolve(for: BizumDetailMultipleViewController.self)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .overFullScreen
        self.presentedNavigation = navigationController
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
}

extension BizumDetailMultipleModuleCoordinator: DetailMultipleModuleCoordinatorProtocol {
    func openImageDetail(_ image: Data) {
        let viewController = BizumImageViewerViewController(nibName: "BizumImageViewerViewController",
                                                            bundle: .module,
                                                            image: image)
        let transitioningDelegate = HalfSizePresentationManager()
        viewController.modalPresentationStyle = .custom
        viewController.modalTransitionStyle = .coverVertical
        viewController.transitioningDelegate = transitioningDelegate
        self.presentedNavigation?.present(viewController, animated: true, completion: nil)
    }

    func didSelectDismiss() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

private extension BizumDetailMultipleModuleCoordinator {
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
        self.dependenciesEngine.register(for: BizumDetailMultiplePresenterProtocol.self) { dependenciesResolver in
            let bizumHistoric: BizumHistoricOperationConfiguration = dependenciesResolver.resolve()
            let presenter = BizumDetailMultiplePresenter(dependenciesResolver: dependenciesResolver, detail: bizumHistoric.bizumHistoricOperationEntity)
            return presenter
        }
        self.dependenciesEngine.register(for: BizumDetailMultipleViewController.self) { dependenciesResolver in
            let presenter: BizumDetailMultiplePresenterProtocol = dependenciesResolver.resolve()
            let viewController = BizumDetailMultipleViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: DetailMultipleModuleCoordinatorProtocol.self) { _ in
            return self
        }
    }
}
