//
//  FeatureFlagsUseCase.swift
//  Account
//
//  Created by José Carlos Estela Anguita on 14/3/22.
//

import Foundation
import CoreDomain
import OpenCombine

protocol GetFeatureFlagsUseCase {
    func fetchAll() -> AnyPublisher<[FeatureFlagWithValue], Never>
}

struct DefaultGetFeatureFlagsUseCase {
    
    let repository: FeatureFlagsRepository
    
    init(dependencies: FeatureFlagsDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetFeatureFlagsUseCase: GetFeatureFlagsUseCase {
    
    func fetchAll() -> AnyPublisher<[FeatureFlagWithValue], Never> {
        return repository.fetchAll()
            .map {
                $0.map { FeatureFlagWithValue(feature: $0.key, value: $0.value) }
            }
            .map {
                $0.sorted(by: {
                    $0.feature.description < $1.feature.description
                })
            }
            .eraseToAnyPublisher()
    }
}
