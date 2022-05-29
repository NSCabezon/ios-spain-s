//  
//  SendMoneyOperativeCoordinator.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 5/1/22.
//

import Foundation
import CoreFoundationLib
import UI
import Operative
import OpenCombine

enum SendMoneyStep: Equatable {
    case selectAccount
    case selectDestination
    case otp
}

protocol SendMoneyOperativeCoordinator: OperativeCoordinator {
    var stepsCoordinator: StepsCoordinator<SendMoneyStep> { get }
}

final class DefaultSendMoneyOperativeCoordinator {
    
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SendMoneyOperativeExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    lazy var operative: SendMoneyOperative = {
        return dependencies.resolve()
    }()

    private lazy var dependencies: Dependency = {
        Dependency(external: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: SendMoneyOperativeExternalDependenciesResolver) {
        self.navigationController = dependencies.resolve()
        self.externalDependencies = dependencies
    }
}

extension DefaultSendMoneyOperativeCoordinator: SendMoneyOperativeCoordinator {
    func dismiss() {
        stepsCoordinator.finish()
        onFinish?()
    }
    
    func start() {
        operative.start()
    }
    
    func next() {}
    
    func back() {}
    
    func goToGlobalPosition() {}
    
    var opinatorCoordinator: BindableCoordinator {
        return ToastCoordinator()
    }
    
    var stepsCoordinator: StepsCoordinator<SendMoneyStep> {
        return dependencies.resolve()
    }
}

private extension DefaultSendMoneyOperativeCoordinator {
    final class Dependency: SendMoneyOperativeDependenciesResolver {
        let external: SendMoneyOperativeExternalDependenciesResolver
        let coordinator: SendMoneyOperativeCoordinator
        let dataBinding = DataBindingObject()
        lazy var operative: SendMoneyOperative = {
            return SendMoneyOperative(dependencies: self)
        }()
        lazy var stepsCoordinator: StepsCoordinator<SendMoneyStep> = {
            return StepsCoordinator(navigationController: external.resolve(), provider: stepProvider, steps: SendMoneyOperative.steps)
        }()
        
        init(external: SendMoneyOperativeExternalDependenciesResolver, coordinator: SendMoneyOperativeCoordinator) {
            self.external = external
            self.coordinator = coordinator
        }
        
        func resolve() -> SendMoneyOperativeCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func resolve() -> StepsCoordinator<SendMoneyStep> {
            return stepsCoordinator
        }
        
        func resolve() -> SendMoneyOperative {
            return operative
        }
        
        func resolve() -> SendMoneySelectAccountDependenciesResolver {
            return SendMoneySelectAccountDependency(dependencies: external, dataBinding: resolve(), coordinator: resolve(), operative: resolve())
        }
        
        func resolve() -> NavigationBarExternalDependenciesResolver {
            return external
        }
        
        func stepProvider(for step: SendMoneyStep) -> StepIdentifiable {
            switch step {
            case .selectAccount:
                let dependencies: SendMoneySelectAccountDependenciesResolver = resolve()
                return dependencies.resolve()
            case .selectDestination:
                let dependencies: SendMoneySelectAccountDependenciesResolver = resolve()
                let vc: SendMoneySelectAccountViewController = dependencies.resolve()
                vc.view.backgroundColor = .blue
                return vc
            case .otp:
                let dependencies: SendMoneySelectAccountDependenciesResolver = resolve()
                let vc: SendMoneySelectAccountViewController = dependencies.resolve()
                vc.view.backgroundColor = .black
                return vc
            }
        }
    }
}
