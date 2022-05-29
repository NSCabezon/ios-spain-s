//
//  SKBiometricsStepOnboardingViewModel.swift
//  SantanderKey
//
//  Created by Tania Castellano Brasero on 24/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

enum SKBiometricsStepOnboardingState: State {
    case idle
}

final class SKBiometricsStepOnboardingViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKBiometricsStepOnboardingDependenciesResolver
    private let stateSubject = CurrentValueSubject<SKBiometricsStepOnboardingState, Never>(.idle)
    var biometricsManager: LocalAuthenticationPermissionsManagerProtocol
    private let biometricPassword = "biometricIsActive"
    private var device: Device
    private var compilation: CompilationProtocol
    var state: AnyPublisher<SKBiometricsStepOnboardingState, Never>
    
    init(dependencies: SKBiometricsStepOnboardingDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
        biometricsManager = dependencies.external.resolve()
        device = IOSDevice()
        compilation = dependencies.external.resolve()
    }
    
    func viewDidLoad() {
        
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }

    func didTouchContinue() {
        self.coordinator.goToSecondStep()
    }

    func didChangeSwitch(_ isOn: Bool, type: BiometryTypeEntity) -> Bool {
        if isOn {
            let touchIdData = TouchIdData(
                deviceMagicPhrase: biometricPassword,
                touchIDLoginEnabled: true,
                footprint: device.footprint)
            do {
                try KeychainWrapper().saveTouchIdData(touchIdData, compilation: compilation)
                coordinator.showToast(success: true, isEnabling: true, type: type)
                biometricsManager.enableBiometric()
                return true
            } catch {
                coordinator.showToast(success: false, isEnabling: true, type: type)
                return false
            }
        } else {
            do {
                try KeychainWrapper().deleteTouchIdData(compilation: compilation)
                coordinator.showToast(success: true, isEnabling: false, type: type)
                return true 
            } catch {
                coordinator.showToast(success: false, isEnabling: false, type: type)
                return false
            }
        }
    }
}

private extension SKBiometricsStepOnboardingViewModel {}

// MARK: - Subscriptions

private extension SKBiometricsStepOnboardingViewModel {
    var coordinator: SKBiometricsStepOnboardingCoordinator {
        return dependencies.resolve()
    }
}

// MARK: - Publishers

private extension SKBiometricsStepOnboardingViewModel {}
