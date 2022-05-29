//
//  SantanderKeyRegisterValidationWithPositionsUseCase.swift
//  SantanderKey
//
//  Created by Ali Ghanbari Dolatshahi on 10/3/22.
//

import OpenCombine
import CoreDomain
import SANSpainLibrary

public protocol SantanderKeyRegisterValidationWithPositionsUseCase {
    func registerValidationPositions(sanKeyId: String, positions: String, valuePositions: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error>
}

struct DefaultSantanderKeyRegisterValidationWithPositionsUseCase {
    private var repository: SantanderKeyOnboardingRepository
    
    init(dependencies: SKExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
}

extension DefaultSantanderKeyRegisterValidationWithPositionsUseCase: SantanderKeyRegisterValidationWithPositionsUseCase {
    
    func registerValidationPositions(sanKeyId: String, positions: String, valuePositions: String) -> AnyPublisher<(SantanderKeyRegisterValidationResultRepresentable, OTPValidationRepresentable), Error> {
        return repository.registerValidationWithPositionsReactive(sanKeyId: sanKeyId, positions: positions, valuePositions: valuePositions).eraseToAnyPublisher()
    }
}
