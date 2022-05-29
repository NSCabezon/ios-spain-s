//
//  SKOperativeSignatureStrategy.swift
//  SantanderKey
//
//  Created by Andres Aguirre Juarez on 25/3/22.
//

import Foundation
import OpenCombine
import Operative
import CoreDomain
import CoreFoundationLib
import SANSpainLibrary
import SANLibraryV3

final class SKOperativeSignatureStrategy: SignatureCapabilityStrategy {
    
    let operative: SKOperative
    let validateStep: SKOperativeStep = .deviceAlias
    var signatureStep: SKOperativeStep = .signature
    let dependencies: SKOperativeExternalDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    var coordinator: SKOperativeCoordinator

    var signaturePublisher: Deferred<AnyPublisher<Void, Error>> {
        return Deferred {
            Future { promise in
                guard let signatureRepresentable: SignatureRepresentable? = self.operative.dataBinding.get() else {
                    return promise(.failure(GenericErrorOTPErrorOutput(localized("login_error_connection"), .unknown, "")))
                }
                var skOperativeData: SKOnboardingOperativeData? = self.operative.dataBinding.get()
                let sankeyId = skOperativeData?.sanKeyId
                guard let positions = signatureRepresentable?.positions, let valuePositions = signatureRepresentable?.values else {
                    return promise(.failure(GenericErrorOTPErrorOutput(localized("login_error_connection"), .unknown, "")))
                }
                let stringPositions = positions.map { String($0) }.joined(separator: "")
                let stringValues = valuePositions.map { String($0) }.joined(separator: "")
                self.registerValidationPublisher(sanKeyId: sankeyId ?? "", positions: stringPositions, valuePositions: stringValues)
                    .subscribe(on: Schedulers.global)
                    .receive(on: Schedulers.main)
                    .sink { [unowned self] completion in
                        if case .failure(let error) = completion {
                            guard let errorType = error as? SantanderKeyError else {
                                promise(.failure(error))
                                return
                            }
                            switch errorType.getAction() {
                            case .goToPG:
                                let skError = GenericErrorSignatureErrorOutput(errorType.getLocalizedDescription(), .revoked, "")
                                promise(.failure(skError))
                            case .goToOperative:
                                let skError = GenericErrorSignatureErrorOutput(errorType.getLocalizedDescription(), .otherError, "")
                                promise(.failure(skError))
                            case .stay:
                                let skError = GenericErrorSignatureErrorOutput(errorType.getLocalizedDescription(), .unknown, "")
                                promise(.failure(skError))
                            }
                        }
                    } receiveValue: { [unowned self] result in
                        let operativeConfig: OperativeConfig? = OperativeConfig(signatureSupportPhone: nil, otpSupportPhone: nil, cesSupportPhone: nil, consultiveUserPhone: result.0.mobileNumber, loanAmortizationSupportPhone: nil)
                        skOperativeData?.otpReference = result.0.otpReference
                        self.operative.dataBinding.set(skOperativeData)
                        self.operative.dataBinding.set(result.1)
                        self.operative.dataBinding.set(operativeConfig)
                        promise(.success(()))
                    }
                    .store(in: &self.anySubscriptions)
            }.eraseToAnyPublisher()
        }
    }
    
    public init(operative: SKOperative, dependencies: SKOperativeExternalDependenciesResolver) {
        self.operative = operative
        self.dependencies = dependencies
        self.coordinator = dependencies.resolve()
    }
}

extension SKOperativeSignatureStrategy {
    var registerValidationUseCase: SantanderKeyRegisterValidationWithPositionsUseCase {
        dependencies.resolve()
    }
    
    func registerValidationPublisher(sanKeyId: String, positions: String, valuePositions: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> {
        return registerValidationUseCase.registerValidationPositions(sanKeyId: sanKeyId, positions: positions, valuePositions: valuePositions)
    }
}
