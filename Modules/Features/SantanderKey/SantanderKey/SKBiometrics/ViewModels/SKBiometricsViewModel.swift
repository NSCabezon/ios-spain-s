//
//  SKBiometricsDependenciesResolver.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 24/2/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import UIOneComponents

enum SKBiometricsState: State {
    case idle
}

final class SKBiometricsViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKBiometricsDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingState, Never>(.idle)
    var biometricsManager: LocalAuthenticationPermissionsManagerProtocol
    private let biometricPassword = "biometricIsActive"
    private var device: Device
    private var compilation: CompilationProtocol
    private var toast: OneToastView?
    var state: AnyPublisher<OnboardingState, Never>
    var stepsCoordinator: StepsCoordinator<SKOperativeStep>?
    
    init(dependencies: SKBiometricsDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
        biometricsManager = dependencies.external.resolve()
        device = IOSDevice()
        compilation = dependencies.external.resolve()
    }
    
    func viewDidLoad() {
        stepsCoordinator = operative.stepsCoordinator
        toast = OneToastView()
    }
    
    var dataBinding: DataBinding {
        return dependencies.resolve()
    }
    
    @objc func didTouchContinue() {
        operative.coordinator.next()
    }

    func didChangeSwitch(_ isOn: Bool, type: BiometryTypeEntity) -> Bool {
        if isOn {
            let touchIdData = TouchIdData(
                deviceMagicPhrase: biometricPassword,
                touchIDLoginEnabled: true,
                footprint: device.footprint)
            do {
                try KeychainWrapper().saveTouchIdData(touchIdData, compilation: compilation)
                showToast(success: true, isEnabling: true, type: type)
                biometricsManager.enableBiometric()
                return true
            } catch {
                showToast(success: false, isEnabling: true, type: type)
                return false
            }
        } else {
            do {
                try KeychainWrapper().deleteTouchIdData(compilation: compilation)
                showToast(success: true, isEnabling: false, type: type)
                return true
            } catch {
                showToast(success: false, isEnabling: false, type: type)
                return false
            }
        }
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

private extension SKBiometricsViewModel {
    var operative: SKOperative {
        dependencies.resolve()
    }
}

// MARK: - Subscriptions

private extension SKBiometricsViewModel {

}

// MARK: - Publishers

private extension SKBiometricsViewModel {

}
