//
//  EcommerceNumberPadCoordinator.swift
//  Pods
//
//  Created by Francisco del Real Escudero on 3/3/21.
//  

import UI
import CoreFoundationLib

protocol EcommerceNumberPadCoordinatorProtocol {
    func dismiss()
    func back()
}

final class EcommerceNumberPadCoordinator: ModuleCoordinator {
    public weak var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
        self.setupDependencies()
    }
    
    public func start() {
        let controller = self.dependenciesEngine.resolve(for: EcommerceNumberPadViewController.self)
        self.navigationController?.blockingPushViewController(controller, animated: false)
    }
}

extension EcommerceNumberPadCoordinator: EcommerceNumberPadCoordinatorProtocol {
    func dismiss() {
        self.animateNavigation(.reveal, subtype: .fromBottom)
        self.removeViewControllersIfNeeded()
    }
    
    func back() {
        self.navigationController?.popViewController(animated: false)
    }
}

/**
 #Register Scene depencencies.
*/

private extension EcommerceNumberPadCoordinator {
    func setupDependencies() {
        self.dependenciesEngine.register(for: EcommerceNumberPadCoordinatorProtocol.self) { _ in
            return self
        }
        self.dependenciesEngine.register(for: GetRecoverPasswordUrlUseCase.self) { resolver in
            return GetRecoverPasswordUrlUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: EcommerceNumberPadPresenterProtocol.self) { resolver in
            return EcommerceNumberPadPresenter(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: EcommerceNumberPadViewController.self) { resolver in
            var presenter = resolver.resolve(for: EcommerceNumberPadPresenterProtocol.self)
            let viewController = EcommerceNumberPadViewController(
                presenter: presenter
            )
            presenter.view = viewController
            return viewController
        }
    }
    
    func animateNavigation(_ type: CATransitionType, subtype: CATransitionSubtype?) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = type
        transition.subtype = subtype
        navigationController?.view.layer.add(transition, forKey: nil)
    }
    
    func removeViewControllersIfNeeded() {
        guard let viewControllers = self.navigationController?.viewControllers,
              let indexInNavigation = viewControllers.firstIndex(where: { $0 is EcommerceViewController }) else {
            return
        }
        self.navigationController?.viewControllers.removeSubrange(indexInNavigation...viewControllers.count-1)
    }
}
