//
//  DefaultPersonalAreaRepository.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 4/2/22.
//

import CoreDomain
import OpenCombine

public struct DefaultPersonalAreaRepository {
    let dependenciesResolver: PersonalAreaDependenciesResolver
    
    public init(dependenciesResolver: PersonalAreaDependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

}

extension DefaultPersonalAreaRepository: PersonalAreaRepository {
    public func fetchDigitalProfilePercentage() -> AnyPublisher<DigitalProfilePercentageRepresentable, Error> {
        let digitalProfileExecutor = DigitalProfileExecutorWrapper(input: self.executorWrapperInput)
        do {
            let result = try digitalProfileExecutor.execute()
            let digitalProfile = DigitalProfile(percentage: result.percentage,
                                                notConfiguredItems: result.notConfiguredItems)
            return Just(digitalProfile)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: CustomError())
                .eraseToAnyPublisher()
        }
    }
    
    public func fetchCompleteDigitalProfileInfo() -> AnyPublisher<DigitalProfileRepresentable?, Never> {
        let digitalProfileExecutor = DigitalProfileExecutorWrapper(input: self.executorWrapperInput)
        let result = try? digitalProfileExecutor.execute()
        return Just(result)
            .eraseToAnyPublisher()
        
    }
}

private extension DefaultPersonalAreaRepository {
    struct DigitalProfile: DigitalProfilePercentageRepresentable {
        var percentage: Double
        var notConfiguredItems: [DigitalProfileElemProtocol]
    }
    struct CustomError: Error {}
    
    var executorWrapperInput: DigitalProfileExecutorWrapperInput {
        DigitalProfileExecutorWrapperInput(
            globalPosition: self.dependenciesResolver.resolve(),
            provider: self.dependenciesResolver.resolve(),
            pushNotificationPermissionsManager: self.dependenciesResolver.resolve(),
            locationPermissionsManager: self.dependenciesResolver.resolve(),
            localAuthPermissionsManager: self.dependenciesResolver.resolve(),
            appRepositoryProtocol: self.dependenciesResolver.resolve(),
            appConfigRepository: self.dependenciesResolver.resolve(),
            applePayEnrollmentManager: self.dependenciesResolver.resolve(),
            dependenciesResolver: self.dependenciesResolver.resolve())
    }
}
