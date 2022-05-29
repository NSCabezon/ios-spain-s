import Foundation
import Operative
import OpenCombine
import UIOneComponents
import CoreFoundationLib
import CoreDomain
import SANSpainLibrary

struct SKOnboardingSetupCapability: WillStartCapability {
    let operative: SKOperative
    let dependencies: SKOperativeExternalDependenciesResolver
    var useCase: SantanderKeyRegisterAuthMethodUseCase {
        return dependencies.resolve()
    }
    
    var willStartPublisher: AnyPublisher<ConditionState, Never> {
        useCase.registerGetAuthMethod()
            .handleEvents(receiveOutput: setOperativeData,
                          receiveCompletion: onReceivedStartPublisher)
            .map { _ in
                return .success
            }
            .replaceError(with: .failure)
            .eraseToAnyPublisher()
    }
}

private extension SKOnboardingSetupCapability {
    func setOperativeData(_ authMethod: (SantanderKeyRegisterAuthMethodResultRepresentable, SignatureRepresentable)) {
        let operativeData = SKOnboardingOperativeData()
        let authMethodResult: SantanderKeyRegisterAuthMethodResultRepresentable = authMethod.0
        let signature: SignatureRepresentable = authMethod.1
        operativeData.sanKeyId = authMethodResult.sanKeyId
        if authMethodResult.authMethod?.lowercased() == "pin" {
            operativeData.authMethod = .pin
            operativeData.cardList = authMethodResult.cardsList
        } else {
            operativeData.authMethod = .sign
            operativeData.signPositions = authMethodResult.signPositions
        }
        operative.coordinator.dataBinding.set(operativeData)
        operative.coordinator.dataBinding.set(signature)
        operative.configureSteps()
    }
    
    func onReceivedStartPublisher(_ subscribers: Subscribers.Completion<Error>) {
        switch subscribers {
        case .finished: break
        case .failure:
            let operativeCoordinator: SKOperativeCoordinator = dependencies.resolve()
            operativeCoordinator.showAuthMethodError()
        }
    }
}
