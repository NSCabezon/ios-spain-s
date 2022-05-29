//
//  SKOperativeCoordinator.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 22/2/22.
//

import Foundation
import UI
import CoreFoundationLib
import Operative
import OpenCombine
import UIOneComponents
import Accelerate

public enum SKOperativeStep: Equatable {
    case deviceAlias
    case selectCard
    case pin
    case signature
    case otp
    case biometrics
}

public protocol SKOperativeCoordinator: OperativeCoordinator {
    var stepsCoordinator: StepsCoordinator<SKOperativeStep> { get }
    func showAuthMethodError()
}

public final class DefaultSKOperativeCoordinator {
    
    weak public var navigationController: UINavigationController?
    public var onFinish: (() -> Void)?
    public var childCoordinators: [Coordinator] = []
    private let externalDependencies: SKExternalDependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    lazy public var dataBinding: DataBinding = dependencies.resolve()
    lazy var errorView = OneOperativeAlertErrorView()
    lazy var operative: SKOperative = {
        return dependencies.resolve()
    }()
    
    private lazy var dependencies: Dependency = {
        Dependency(external: externalDependencies, coordinator: self)
    }()
    
    public init(dependencies: SKExternalDependenciesResolver) {
        self.navigationController = dependencies.resolve()
        self.externalDependencies = dependencies
        self.bindAlertView()
    }
}

extension DefaultSKOperativeCoordinator: SKOperativeCoordinator {
    public func dismiss() {
        self.dismissOperative(goToGP: true)
    }
    
    public func start() {
        operative.start()
    }
    
    public var opinatorCoordinator: BindableCoordinator {
        return ToastCoordinator()
    }
    
    public var stepsCoordinator: StepsCoordinator<SKOperativeStep> {
        return dependencies.resolve()
    }
    
    public func next() {
        if (stepsCoordinator.current.type == .otp && (stepsCoordinator.steps.first(where: { $0.type == .biometrics }) == nil)) || stepsCoordinator.current.type == .biometrics {
            dismissOperative(goToGP: false)
        } else {
            operative.next()
        }
    }
    
    public func back() {}
    
    public func goToGlobalPosition() {
        onFinish = {
            self.navigationController?.popToRootViewController(animated: false)
        }
        dismissOperative(goToGP: false)
    }
    
    public func resetOperative() {
        self.operative.back(to: .deviceAlias)
    }
    
    func bindAlertView() {
        guard let navController = navigationController else { return }
        self.errorView.publisher
            .subscribe(on: Schedulers.main)
            .receive(on: Schedulers.main)
            .case(ReactiveOneOperativeAlertErrorViewState.didTapAcceptButton)
            .sink { [unowned self] _ in
                BottomSheet().close(navController)
            }.store(in: &subscriptions)
    }
    
    public func showAuthMethodError() {
        guard let navigation = navigationController else { return }
        let errorViewModel = OneOperativeAlertErrorViewData(
            iconName: "oneIcnWarning",
            alertDescription: localized("generic_error_txt"),
            floatingButtonText: localized("generic_button_accept"),
            floatingButtonAction: { },
            typeBottomSheet: .unowned,
            viewAccessibilityIdentifier: ""
        )
        errorView.setData(errorViewModel)
        
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: navigation,
                         type: .custom(height: nil, isPan: true, bottomVisible: true),
                         component: errorViewModel.typeBottomSheet,
                         view: errorView)
    }
}

private extension DefaultSKOperativeCoordinator {
    final class Dependency: SKOperativeDependenciesResolver {
        let external: SKOperativeExternalDependenciesResolver
        let coordinator: SKOperativeCoordinator
        let dataBinding = DataBindingObject()
        lazy var operative: SKOperative = {
            return SKOperative(dependencies: self)
        }()
        lazy var stepsCoordinator: StepsCoordinator<SKOperativeStep> = {
            return StepsCoordinator(navigationController: external.resolve(), provider: stepProvider, steps: SKOperative.steps)
        }()
        
        init(external: SKOperativeExternalDependenciesResolver, coordinator: SKOperativeCoordinator) {
            self.external = external
            self.coordinator = coordinator
            let navigationController: UINavigationController = external.resolve()
            navigationController.setPopGestureEnabled(false)
        }
        
        func resolve() -> SKOperativeCoordinator {
            return coordinator
        }
        
        func resolve() -> DataBinding {
            return dataBinding
        }
        
        func resolve() -> StepsCoordinator<SKOperativeStep> {
            return stepsCoordinator
        }
        
        func resolve() -> SKOperative {
            return operative
        }
        
        func resolve() -> SKDeviceAliasDependenciesResolver {
            return SKDeviceAliasDependency(dependencies: external, dataBinding: resolve(), coordinator: resolve(), operative: resolve())
        }
        
        func resolve() -> SKCardSelectorDependenciesResolver {
            return SKCardSelectorDependency(dependencies: external, dataBinding: resolve(), coordinator: resolve(), operative: resolve())
        }
        
        func resolve() -> SKPinStepDependenciesResolver {
            return SKPinStepDependency(dependencies: external, dataBinding: resolve(), coordinator: resolve(), operative: resolve())
        }
        
        func resolve() -> SKBiometricsDependenciesResolver {
            return SKBiometricsDependency(dependencies: external, dataBinding: resolve(), coordinator: resolve(), operative: resolve())
        }
        
        func resolve() -> ReactiveOperativeSignatureExternalDependenciesResolver {
            return ReactiveOperativeSignatureDependency(dependencies: external, dataBinding: resolve(), coordinator: resolve(), operative: resolve())
        }
        
        func resolve() -> ReactiveOperativeOTPExternalDependenciesResolver {
            return ReactiveOperativeOTPDependency(dependencies: external, dataBinding: resolve(), coordinator: resolve(), operative: resolve())
        }
        
        func stepProvider(for step: SKOperativeStep) -> StepIdentifiable {
            switch step {
            case .deviceAlias:
                let dependencies: SKDeviceAliasDependenciesResolver = resolve()
                let deviceAliasViewController: SKDeviceAliasViewController = dependencies.resolve()
                return deviceAliasViewController
            case .selectCard:
                let dependencies: SKCardSelectorDependenciesResolver = resolve()
                let cardSelectorViewController: SKCardSelectorViewController = dependencies.resolve()
                return cardSelectorViewController
            case .pin:
                let dependencies: SKPinStepDependenciesResolver = resolve()
                let pinStepViewController: SKPinStepViewController = dependencies.resolve()
                return pinStepViewController
            case .signature:
                let dependencies: ReactiveOperativeSignatureExternalDependenciesResolver = resolve()
                let viewController: ReactiveOperativeSignatureViewController = dependencies.resolve()
                return viewController
            case .otp:
                let dependencies: ReactiveOperativeOTPExternalDependenciesResolver = resolve()
                let viewController: ReactiveOperativeOTPViewController = dependencies.resolve()
                return viewController
            case .biometrics:
                let dependencies: SKBiometricsDependenciesResolver = resolve()
                let bioStepViewController: SKBiometricsViewController = dependencies.resolve()
                return bioStepViewController
            }
        }
    }
    
    func dismissOperative(goToGP: Bool) {
        if goToGP {
            goToGlobalPosition()
        } else {
            navigationController?.setPopGestureEnabled(true)
            stepsCoordinator.finish(onFinishAction:{})
        }
    }
}
