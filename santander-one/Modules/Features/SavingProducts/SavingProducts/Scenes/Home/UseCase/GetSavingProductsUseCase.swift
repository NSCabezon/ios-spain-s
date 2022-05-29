//
//  GetSavingProductsUseCase.swift
//  SavingProducts
//
//  Created by Adrian Escriche Martin on 23/2/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetSavingProductsUsecase {
    func fechSavingProducts() -> AnyPublisher<[SavingProductRepresentable], Never>
}

struct DefaultGetSavingProductsUsecase {
    private var repository: GlobalPositionDataRepository
    
    init(dependencies: SavingsHomeExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
    }
}

extension DefaultGetSavingProductsUsecase: GetSavingProductsUsecase {
    func fechSavingProducts() -> AnyPublisher<[SavingProductRepresentable], Never> {
        return repository.getGlobalPosition()
            .map(\.savingProductRepresentables)
            .eraseToAnyPublisher()
    }
}
