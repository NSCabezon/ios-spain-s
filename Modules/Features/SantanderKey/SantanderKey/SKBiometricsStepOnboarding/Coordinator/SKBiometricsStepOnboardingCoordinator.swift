//  
//  SKBiometricsStepOnboardingCoordinator.swift
//  SantanderKey
//
//  Created by Tania Castellano Brasero on 24/2/22.
//

import Foundation
import UI
import CoreFoundationLib
import UIOneComponents

protocol SKBiometricsStepOnboardingCoordinator: BindableCoordinator {
    func goToSecondStep()
    func showToast(success: Bool, isEnabling: Bool, type: BiometryTypeEntity)
}

final class DefaultSKBiometricsStepOnboardingCoordinator: SKBiometricsStepOnboardingCoordinator {
    weak var navigationController: UINavigationController?
    var onFinish: (() -> Void)?
    var childCoordinators: [Coordinator] = []
    private let externalDependencies: SKBiometricsStepOnboardingExternalDependenciesResolver
    lazy var dataBinding: DataBinding = dependencies.resolve()
    private var toast: OneToastView?
    
    private lazy var dependencies: Dependency = {
        Dependency(dependencies: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: SKBiometricsStepOnboardingExternalDependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.externalDependencies = dependencies
        self.toast = OneToastView()
    }
}

extension DefaultSKBiometricsStepOnboardingCoordinator {
    func start() {
        navigationController?.pushViewController(dependencies.resolve(), animated: true)
    }

    func goToSecondStep() {
        let secondStepCoordinator = dependencies.external.sKSecondStepOnboardingCoordinator()
        secondStepCoordinator
            .start()
        append(child: secondStepCoordinator)
    }

    func showToast(success: Bool, isEnabling: Bool, type: BiometryTypeEntity) {
        var message = ""
        if isEnabling {
            switch type {
            case .faceId:
                message = success ? "faceId_alert_activeSuccess" : "faceId_alert_errorActivation"
            case .touchId:
                message = success ? "touchId_alert_activeSuccess" : "touchId_alert_errorActivation"
            default:
                break
            }
        } else {
            switch type {
            case .faceId:
                message = success ? "faceId_alert_desactiveFaceId" : "faceId_alert_errorActivation"
            case .touchId:
                message = success ? "touchId_alert_desactiveTouchId" : "touchId_alert_errorActivation"
            default:
                break
            }
        }
        guard let toast = toast else { return }
        toast.setViewModel(OneToastViewModel(leftIconKey: success ? "oneIcnCheckOthers" : "icnAlert", titleKey: nil, subtitleKey: message, linkKey: nil, type: .small, position: .bottom, duration: .custom(3)))
        toast.present()
    }
}

private extension DefaultSKBiometricsStepOnboardingCoordinator {
    struct Dependency: SKBiometricsStepOnboardingDependenciesResolver {
        let dependencies: SKBiometricsStepOnboardingExternalDependenciesResolver
        let coordinator: SKBiometricsStepOnboardingCoordinator
        let dataBinding = DataBindingObject()
        
        var external: SKBiometricsStepOnboardingExternalDependenciesResolver {
            return dependencies
        }
        
        func resolve() -> SKBiometricsStepOnboardingCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
    }
}
