//
//  SantanderKeyFirstLoginModifier.swift
//  Santander
//
//  Created by David Gálvez Alonso on 12/4/22.
//

import RetailLegacy
import CoreFoundationLib
import SantanderKey
import SANSpainLibrary
import UI
import OpenCombine

protocol SKFirstLoginModifierDependenciesResolver {
    func resolve() -> SantanderKeyGetClientStatusUseCaseProtocol
    func resolve() -> SKFirstStepOnboardingExternalDependenciesResolver
    func resolve() -> SKRegisteredAnotherDeviceExternalDependenciesResolver
    func resolve() -> UseCaseHandler
    var oldDependencies: DependenciesResolver { get }
}

final class SantanderKeyFirstLoginModifier: SantanderKeyFirstLoginModifierProtocol {
    let dependencies: SKFirstLoginModifierDependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    private var isSanKeyEnabled: Bool = false
    
    init(dependencies: SKFirstLoginModifierDependenciesResolver) {
        self.dependencies = dependencies
        bindSanKeyEnabled()
    }

    func evaluateSanKey(completion: @escaping (Bool) -> Void) {
        guard isSanKeyEnabled else {
            completion(false)
            return
        }
        let useCase: SantanderKeyGetClientStatusUseCaseProtocol = dependencies.resolve()
        Scenario(useCase: useCase)
            .execute(on: dependencies.resolve())
            .onSuccess { result in
                let status = result.clientStatus
                switch status.clientStatus {
                case SantanderKeyClientStatusState.rightRegisteredDevice:
                    completion(true)
                case SantanderKeyClientStatusState.anotherDeviceRegistered:
                    self.callRegisteredAnotherDeviceSantanderKey(clientStatus: result.clientStatus)
                case SantanderKeyClientStatusState.notRegistered:
                    self.callFirstStepSantanderKey(clientStatus: result.clientStatus)
                case SantanderKeyClientStatusState.resgisteredSafeDevice:
                    if let skInDevice = status.otherSKinDevice, skInDevice.lowercased() == "true" {
                        self.callRegisteredAnotherDeviceSantanderKey(clientStatus: result.clientStatus)
                    } else {
                        self.callFirstStepSantanderKey(clientStatus: result.clientStatus)
                    }
                default:
                    break
                }
                completion(true)
            }
    }
}

private extension SantanderKeyFirstLoginModifier {
    func callFirstStepSantanderKey(clientStatus: SantanderKeyStatusRepresentable) {
        let dependencies: SKFirstStepOnboardingExternalDependenciesResolver = dependencies.resolve()
        dependencies.skFirstStepOnboardingCoordinator()
            .set(clientStatus)
            .start()
    }
    
    func callRegisteredAnotherDeviceSantanderKey(clientStatus: SantanderKeyStatusRepresentable) {
        let dependencies: SKRegisteredAnotherDeviceExternalDependenciesResolver = dependencies.resolve()
        dependencies.skRegisteredAnotherDeviceCoordinator()
            .set(clientStatus)
            .start()
    }
    
    func bindSanKeyEnabled() {
        let booleanFeatureFlag: BooleanFeatureFlag = dependencies.oldDependencies.resolve()
        booleanFeatureFlag.fetch(SpainFeatureFlag.santanderKey)
            .sink { [unowned self] result in
                self.isSanKeyEnabled = result
            }
            .store(in: &subscriptions)
    }
}

