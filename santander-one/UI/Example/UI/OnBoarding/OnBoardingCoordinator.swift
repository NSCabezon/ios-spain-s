//
//  OnBoardingCoordinator.swift
//  UI_Example
//
//  Created by José Carlos Estela Anguita on 2/12/21.
//

import Foundation
import CoreFoundationLib
import UI
import UIKit

public enum OnBoardingStep: Equatable {
    case step1
    case step2
    case custom(identifier: String)
}

final class OnBoardingCoordinator: BindableCoordinator {
    
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    weak var navigationController: UINavigationController?
    private let dependencies: OnBoardingDependencies
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    init(dependencies: OnBoardingExternalDependencies) {
        self.dependencies = Dependencies(external: dependencies)
        self.navigationController = dependencies.resolve()
    }
    
    func start() {
        let stepsCoordinator: StepsCoordinator<OnBoardingStep> = dependencies.resolve()
        stepsCoordinator.start()
    }
    
    final class Dependencies: OnBoardingDependencies, DataBindable {
        let external: OnBoardingExternalDependencies
        let dataBinding: DataBinding = DataBindingObject()
        lazy var stepsCoordinator: StepsCoordinator<OnBoardingStep> = {
            return StepsCoordinator<OnBoardingStep>(navigationController: external.resolve(), provider: resolve, steps: dataBinding.get() ?? [])
        }()
        
        init(external: OnBoardingExternalDependencies) {
            self.external = external
        }
        
        func resolve() -> StepsCoordinator<OnBoardingStep> {
            return stepsCoordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        private func resolve(_ step: OnBoardingStep) -> StepIdentifiable {
            switch step {
            case .step1:
                return resolve() as OnBoardingStep1ViewController
            case .step2:
                return resolve() as OnBoardingStep2ViewController
            case .custom(identifier: let identifier):
                return external.resolveOnBoardingCustomStepView(for: identifier, coordinator: stepsCoordinator)
            }
        }
    }
}
