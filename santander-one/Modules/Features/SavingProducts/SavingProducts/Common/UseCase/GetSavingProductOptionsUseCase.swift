//
//  GetSavingProductOptionsUseCase.swift
//  SavingProducts
//
//  Created by José Norberto Hidalgo Romero on 2/3/22.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetSavingProductOptionsUseCase {
    func fetchHomeOptions(contractNumber: String?, savingsProductType: String) -> AnyPublisher<[SavingProductOptionRepresentable], Never>
    func fetchOtherOperativesOptions(contractNumber: String?, savingsProductType: String) -> AnyPublisher<[SavingProductOptionRepresentable], Never>
}

struct DefaultGetSavingProductOptionsUseCase: GetSavingProductOptionsUseCase {
    func fetchHomeOptions(contractNumber: String?, savingsProductType: String) -> AnyPublisher<[SavingProductOptionRepresentable], Never> {
        Just([]).eraseToAnyPublisher()
    }

    func fetchOtherOperativesOptions(contractNumber: String?, savingsProductType: String) -> AnyPublisher<[SavingProductOptionRepresentable], Never> {
        Just([]).eraseToAnyPublisher()
    }
}
