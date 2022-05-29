//
//  GetDigitalProfilePercentageUseCase.swift
//  PrivateMenu
//
//  Created by Daniel Gómez Barroso on 23/12/21.
//

import OpenCombine
import CoreDomain

struct DefaultGetDigitalProfilePercentageUseCase {
    private let personalAreaRepository: PersonalAreaRepository
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        self.personalAreaRepository = dependencies.resolve()
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
