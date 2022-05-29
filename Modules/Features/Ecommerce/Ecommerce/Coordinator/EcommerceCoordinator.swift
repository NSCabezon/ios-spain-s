import CoreFoundationLib
import UIKit
import UI
import ESCommons

protocol EcommerceCoordinatorDelegate: AnyObject {
    func dismiss(_ completion: (() -> Void)?)
    func moreInfo()
    func goToNumberPad()
    func confirmWithAccessKey(_ code: String)
}

extension EcommerceCoordinatorDelegate {
    func dismiss(_ completion: (() -> Void)? = nil) {
        dismiss(completion)
    }
}

final class EcommerceCoordinator: ModuleSectionedCoordinator {
    weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private let numberPadCoordinator: EcommerceNumberPadCoordinator

    init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.numberPadCoordinator = EcommerceNumberPadCoordinator(dependenciesResolver: dependenciesEngine, navigationController: navigationController)
        self.setupDependencies()
    }

    private func setupDependencies() {
        self.dependenciesEngine.register(for: GetEcommercePushNotificationUseCase.self) { dependenciesResolver in
            return GetEcommercePushNotificationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetTouchIdLoginDataUseCase.self) { dependenciesResolver in
            return GetTouchIdLoginDataUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: SetTouchIdLoginDataUseCase.self) { dependenciesResolver in
            return SetTouchIdLoginDataUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: Device.self) { _ in
            return IOSDevice()
        }
        self.dependenciesEngine.register(for: EcommerceCoordinatorDelegate.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: EcommercePresenterProtocol.self) { dependenciesResolver in
            return EcommercePresenter(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: EcommerceViewProtocol.self) { dependenciesResolver in
            return dependenciesResolver.resolve(for: EcommerceViewController.self)
        }
        self.dependenciesEngine.register(for: EcommerceConfirmWithBiometryUseCase.self) { dependenciesResolver in
            return EcommerceConfirmWithBiometryUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetLocalPushTokenUseCase.self) { dependenciesResolver in
            return GetLocalPushTokenUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: EcommerceGetLastOperationUseCase.self) { dependenciesResolver in
            return EcommerceGetLastOperationUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: EcommerceGetOperationDataUseCase.self) { dependenciesResolver in
            return EcommerceGetOperationDataUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: EcommerceConfirmWithAccessKeyUseCase.self) { dependenciesResolver in
            return EcommerceConfirmWithAccessKeyUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: EcommerceViewController.self) { dependenciesResolver in
            let viewController = EcommerceViewController(dependenciesResolver: dependenciesResolver)
            return viewController
        }
        self.dependenciesEngine.register(for: PullOfferCandidatesUseCase.self) { dependenciesResolver in
            return PullOfferCandidatesUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: EmptyPurchasesPresenterProtocol.self) { dependenciesResolver in
            return EmptyPurchasesPresenter(dependenciesResolver: dependenciesResolver)
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

    // MARK: - Main Module Coordinator actions
    public func start(_ section: EcommerceModuleCoordinator.EcommerceSection) {
        self.dependenciesEngine.register(for: EcommerceConfiguration.self) { _ in
            return EcommerceConfiguration(accessKeyCode: nil, section: section)
        }
        let controller = self.dependenciesEngine.resolve(for: EcommerceViewController.self)
        self.animateNavigation(.moveIn, subtype: .fromTop) { _ in
            Async.main {
                self.navigationController?.blockingPushViewController(controller, animated: false)
            }
        }
    }
}

private extension EcommerceCoordinator {
    func animateNavigation(_ type: CATransitionType, subtype: CATransitionSubtype?, completion: @escaping(_ isFinished: Bool) -> Void) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = type
        transition.subtype = subtype
        navigationController?.view.layer.add(transition, forKey: nil)
        completion(true)
    }
}

extension EcommerceCoordinator: EcommerceCoordinatorDelegate {
   
    func confirmWithAccessKey(_ code: String) {
        self.dependenciesEngine.register(for: EcommerceConfiguration.self) { _ in
            return EcommerceConfiguration(accessKeyCode: code)
        }
    }

    func dismiss(_ completion: (() -> Void)?) {
        self.animateNavigation(.reveal, subtype: .fromBottom) { _ in
            Async.main {
                _ = self.navigationController?.popViewController(animated: false)
                completion?()
            }
        }
    }

    func moreInfo() {
        let dialog = dependenciesEngine.resolve(for: EmptyDialogViewController.self)
        self.navigationController?.present(dialog, animated: true, completion: nil)
    }

    func goToNumberPad() {
        self.numberPadCoordinator.start()
    }
}
