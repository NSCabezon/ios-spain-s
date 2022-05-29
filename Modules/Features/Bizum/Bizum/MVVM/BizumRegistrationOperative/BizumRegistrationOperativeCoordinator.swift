//  
//  BizumRegistrationOperativeCoordinator.swift
//  Bizum
//
//  Created by Tania Castellano Brasero on 25/4/22.
//

import Foundation
import CoreFoundationLib
import Operative
import OpenCombine
import UI

public enum BizumRegistrationOperativeStep: Equatable {
    case selectAccount
    case pin
    case signature
    case otp
    case resume
}

protocol BizumRegistrationOperativeCoordinator: OperativeCoordinator {
    var stepsCoordinator: StepsCoordinator<BizumRegistrationOperativeStep> { get }
}

public final class DefaultBizumRegistrationOperativeCoordinator {
    weak public var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    private let externalDependencies: BizumRegistrationOperativeExternalDependenciesResolver
    lazy public var dataBinding: DataBinding = dependencies.resolve()
    
    lazy var operative: BizumRegistrationOperative = {
        return dependencies.resolve()
    }()
    
    private lazy var dependencies: Dependency = {
        Dependency(externalDependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: BizumRegistrationOperativeExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
    }
}

extension DefaultBizumRegistrationOperativeCoordinator: BizumRegistrationOperativeCoordinator {
    public func start() {
        operative.start()
    }
    
    public var stepsCoordinator: StepsCoordinator<BizumRegistrationOperativeStep> {
        return dependencies.resolve()
    }
    
    public var opinatorCoordinator: BindableCoordinator {
        return ToastCoordinator()
    }
    
    public func next() {
        operative.next()
    }
    
    public func back() {
        operative.back()
    }
    
    public func goToGlobalPosition() {
        onFinish = {
            self.navigationController?.popToRootViewController(animated: false)
        }
        dismiss()
    }
    
    public func dismiss() {
//        stepsCoordinator.finish(onFinishAction:{})
    }
}

private extension DefaultBizumRegistrationOperativeCoordinator {
    final class Dependency: BizumRegistrationOperativeDependenciesResolver {
        let external: BizumRegistrationOperativeExternalDependenciesResolver
        let coordinator: BizumRegistrationOperativeCoordinator
        let dataBinding = DataBindingObject()
        
        lazy var operative: BizumRegistrationOperative = {
            return BizumRegistrationOperative(dependencies: self)
        }()
        
        lazy var stepsCoordinator: StepsCoordinator<BizumRegistrationOperativeStep> = {
            return StepsCoordinator(navigationController: external.resolve(), provider: stepProvider, steps: BizumRegistrationOperative.steps)
        }()
        
        init(externalDependencies: BizumRegistrationOperativeExternalDependenciesResolver, coordinator: BizumRegistrationOperativeCoordinator) {
            self.external = externalDependencies
            self.coordinator = coordinator
            let navigationController: UINavigationController = external.resolve()
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        func resolve() -> BizumRegistrationOperativeCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func resolve() -> StepsCoordinator<BizumRegistrationOperativeStep> {
            return stepsCoordinator
        }
        
        func resolve() -> BizumRegistrationOperative {
            return operative
        }
        
        //TODO: - Resolver aquí las Scenes de cada step, por ejemplo del selector de cuentas:
        func resolve() -> BizumRegistrationAccountSelectorStepDependenciesResolver {
            return BizumRegistrationAccountSelectorDependency(dependencies: external, dataBinding: resolve(), coordinator: resolve(), operative: resolve())
        }
        
        func stepProvider(for step: BizumRegistrationOperativeStep) -> StepIdentifiable {
            switch step {
            case .selectAccount:
                let dependencies: BizumRegistrationAccountSelectorStepDependenciesResolver = resolve()
                let accountSelectorViewController: BizumRegistrationAccountSelectorStepViewController = dependencies.resolve()
                return accountSelectorViewController
            case .pin:
                //                let dependencies: SKPinStepDependenciesResolver = resolve()
                //                let pinStepViewController: SKPinStepViewController = dependencies.resolve()
                //                return pinStepViewController
                break
            case .signature:
//                let dependencies: RegistrationReactiveOperativeSignatureExternalDependenciesResolver = resolve()
//                let viewController: RegistrationReactiveOperativeSignatureViewController = dependencies.resolve()
//                return viewController
                break
            case .otp:
//                let dependencies: RegistrationReactiveOperativeOTPExternalDependenciesResolver = resolve()
//                let viewController: RegistrationReactiveOperativeOTPViewController = dependencies.resolve()
//                return viewController
                break
            case .resume:
                break
            }
            //TODO: - Temporal, después borrar este código cuando tengamos todos los pasos:
            let dependencies: BizumRegistrationAccountSelectorStepDependenciesResolver = resolve()
            let accountSelectorViewController: BizumRegistrationAccountSelectorStepViewController = dependencies.resolve()
            return accountSelectorViewController
        }
    }
}
