//
//  FintechTPPConfirmationCoordinator.swift
//  Ecommerce
//
//  Created by alvola on 15/04/2021.
//

import Foundation
import UI
import CoreFoundationLib

protocol FintechTPPConfirmationCoordinatorProtocol {
    func dismiss()
    func openUrl(_ url: String)
}

final class FintechTPPConfirmationCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }

    func start() {
        guard let viewController = self.dependenciesEngine.resolve(for: FintechTPPConfirmationViewProtocol.self) as? UIViewController
        else { return }
        self.animateNavigation(.moveIn, subtype: .fromTop, completion: { [weak self] in
            self?.navigationController?.blockingPushViewController(viewController, animated: false)
        })
    }

    func start(_ userAuthentication: FintechUserAuthenticationRepresentable?) {
        guard let viewController = self.dependenciesEngine.resolve(for: FintechTPPConfirmationViewProtocol.self) as? UIViewController,
            let userAuthentication = userAuthentication else { return }
        self.dependenciesEngine.register(for: FintechTPPConfiguration.self) { _ in
            return FintechTPPConfiguration(userAuthentication)
        }
        guard !(navigationController?.visibleViewController is FintechTPPConfirmationViewController) else { return }
        self.animateNavigation(.moveIn, subtype: .fromTop, completion: { [weak self] in
            self?.navigationController?.blockingPushViewController(viewController, animated: false)
        })
    }
}

extension FintechTPPConfirmationCoordinator: FintechTPPConfirmationCoordinatorProtocol, OpenUrlCapable {
    func openUrl(_ url: String) {
        guard let url = URL(string: url) else { return }
        openUrl(url)
    }
    
    func dismiss() {
        self.animateNavigation(.reveal, subtype: .fromBottom, completion: { [weak self] in
            self?.navigationController?.popViewController(animated: false)
        })
    }  
}

private extension FintechTPPConfirmationCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: FintechTPPConfirmationCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: FintechTPPConfirmationPresenterProtocol.self) { resolver in
            return FintechTPPConfirmationPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: FintechTPPConfirmationViewProtocol.self) { resolver in
            var presenter = resolver.resolve(for: FintechTPPConfirmationPresenterProtocol.self)
            let viewController = FintechTPPConfirmationViewController(dependenciesResolver: resolver)
            presenter.view = viewController
            return viewController
        }
        
        self.dependenciesEngine.register(for: GetRememberedUserNameUseCase.self) { dependenciesResolver in
            return GetRememberedUserNameUseCase(dependenciesResolver: dependenciesResolver)
        }
        self.dependenciesEngine.register(for: GetTouchIdLoginDataUseCase.self) { dependenciesResolver in
            return GetTouchIdLoginDataUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: FintechConfirmAccessKeyUseCase.self) { dependenciesResolver in
            return FintechConfirmAccessKeyUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: FintechConfirmFootprintUseCase.self) { dependenciesResolver in
            return FintechConfirmFootprintUseCase(dependenciesResolver: dependenciesResolver)
        }
        
        self.dependenciesEngine.register(for: GetRecoverPasswordUrlUseCase.self) { resolver in
            return GetRecoverPasswordUrlUseCase(dependenciesResolver: resolver)
        }
        
    }
    
    func animateNavigation(_ type: CATransitionType, subtype: CATransitionSubtype?, completion: @escaping() -> Void) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = type
        transition.subtype = subtype
        navigationController?.view.layer.add(transition, forKey: nil)
        completion()
    }
}
