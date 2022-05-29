//
//  BiometryValidatorCoordinator.swift
//  Pods
//
//  Created by Rubén Márquez Fernández on 20/5/21.
//

import CoreFoundationLib
import UI
import ESCommons

protocol BiometryValidatorModuleCoordinatorProtocol: AnyObject {
    func success(deviceToken: String, footprint: String)
    func cancel()
    func signProcess()
    func moreInfo()
    func getScreen() -> String
}

public protocol BiometryValidatorModuleCoordinatorDelegate: AnyObject {
    func success(deviceToken: String, footprint: String, onCompletion: @escaping (Bool, String?) -> Void)
    func continueSignProcess()
    func biometryDidSuccessfullyDisappear()
    func biometryDidDisappear(withError error: String?)
    func getScreen() -> String
}

public class BiometryValidatorModuleCoordinator: ModuleCoordinator {
    
    weak public var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private weak var presentedNavigation: UINavigationController?

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.navigationController = navigationController
        self.setupDependencies()
    }

    // MARK: - Start coordinator
    /// The custom navigator should be overFullScreen modal presentation Style
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: BiometryValidatorViewController.self)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .overFullScreen
        self.presentedNavigation = navigationController
        self.navigationController?.present(navigationController, animated: true)
    }
}

private extension BiometryValidatorModuleCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: BiometryValidatorPresenterProtocol.self) { _ in
            return BiometryValidatorPresenter(dependenciesResolver: self.dependenciesEngine)
        }
        self.dependenciesEngine.register(for: BiometryValidatorViewController.self) { _ in
            var presenter: BiometryValidatorPresenterProtocol = self.dependenciesEngine.resolve()
            let viewController = BiometryValidatorViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: BiometryValidatorPresenterProtocol.self) { _ in
            return BiometryValidatorPresenter(dependenciesResolver: self.dependenciesEngine)
        }
        self.dependenciesEngine.register(for: BiometryValidatorModuleCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: GetTouchIdDataUseCase.self) { dependenciesResolver in
            return GetTouchIdDataUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: EmptyPurchasesPresenterProtocol.self) { dependenciesResolver in
            let presenter = EmptyPurchasesPresenter(dependenciesResolver: dependenciesResolver)
            return presenter
        }
        self.dependenciesEngine.register(for: PullOfferCandidatesUseCase.self) { dependenciesResolver in
            return PullOfferCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: EmptyPurchasesViewController.self) { dependenciesResolver in
            var presenter: EmptyPurchasesPresenterProtocol = dependenciesResolver.resolve(for: EmptyPurchasesPresenterProtocol.self)
            let viewController = EmptyPurchasesViewController(presenter: presenter)
            presenter.view = viewController
            return viewController
        }
        self.dependenciesEngine.register(for: EmptyDialogViewController.self) { dependenciesResolver in
            let emptyViewController: EmptyPurchasesViewController = dependenciesResolver.resolve(for: EmptyPurchasesViewController.self)
            let viewController = EmptyDialogViewController(emptyViewController: emptyViewController)
            return viewController
        }
    }
    
    var delegate: BiometryValidatorModuleCoordinatorDelegate? {
        return self.dependenciesEngine.resolve(for: BiometryValidatorModuleCoordinatorDelegate.self)
    }
}

extension BiometryValidatorModuleCoordinator: BiometryValidatorModuleCoordinatorProtocol {
    func success(deviceToken: String, footprint: String) {
        self.delegate?.success(deviceToken: deviceToken, footprint: footprint, onCompletion: { isSuccess, error in
            self.navigationController?.dismiss(animated: true, completion: {
                if isSuccess {
                    self.delegate?.biometryDidSuccessfullyDisappear()
                } else {
                    self.delegate?.biometryDidDisappear(withError: error)
                }
            })
        })
    }
    
    func cancel() {
        self.navigationController?.dismiss(animated: true)
    }
    
    func signProcess() {
        self.navigationController?.dismiss(animated: true, completion: {
            self.delegate?.continueSignProcess()
        })
    }

    func moreInfo() {
        let dialog = self.dependenciesEngine.resolve(for: EmptyDialogViewController.self)
        self.presentedNavigation?.present(dialog, animated: true, completion: nil)
    }
    
    func getScreen() -> String {
        self.delegate?.getScreen() ?? ""
    }
}
