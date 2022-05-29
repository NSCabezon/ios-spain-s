//
//  GetDigitalProfilePercentageUseCase.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 23/12/21.
//

import CoreDomain
import OpenCombine

struct DefaultGetDigitalProfilePercentageUseCase {
    private let personalAreaRepository: PersonalAreaRepository
    
    init(dependencies: OnboardingCommonExternalDependenciesResolver) {
        personalAreaRepository = dependencies.resolve()
    }
}

extension DefaultGetDigitalProfilePercentageUseCase: GetDigitalProfilePercentageUseCase {
    func fetchDigitalProfilePercentage() -> AnyPublisher<Double, Error> {
        return personalAreaRepository.fetchDigitalProfilePercentage()
            .map { $0.percentage }
            .eraseToAnyPublisher()
    }
    
    func fetchIsDigitalProfileEnabled() -> AnyPublisher<Bool, Never> {
        return Just(false)
            .eraseToAnyPublisher()
    }
}
