//
//  GetDigitalProfileUseCase.swift
//  PersonalArea
//
//  Created by alvola on 6/4/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetDigitalProfileUseCase {
    func fetchDigitalProfile() -> AnyPublisher<DigitalProfileRepresentable?, Never>
}

struct DefaultGetDigitalProfileUseCase {
    private let personalAreaRepository: PersonalAreaRepository
    
    init(dependencies: PersonalAreaHomeExternalDependenciesResolver) {
        self.personalAreaRepository = dependencies.resolve()
    }
}

extension DefaultGetDigitalProfileUseCase: GetDigitalProfileUseCase {
    func fetchDigitalProfile() -> AnyPublisher<DigitalProfileRepresentable?, Never> {
        return personalAreaRepository
            .fetchCompleteDigitalProfileInfo()
    }
}
