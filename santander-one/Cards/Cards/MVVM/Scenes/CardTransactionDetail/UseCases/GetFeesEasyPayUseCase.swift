//
//  GetFeeEasypayUseCase.swift
//  Cards
//
//  Created by Gloria Cano López on 5/4/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public protocol GetFeesEasypayUseCase {
    func fetchFeesEasypay(card: CardRepresentable) -> AnyPublisher<FeeDataRepresentable, Error>
}

struct DefaultGetFeesEasypayUseCase {
    private let repository: CardRepository
    
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        repository = dependencies.resolve()
    }
}

extension DefaultGetFeesEasypayUseCase: GetFeesEasypayUseCase {
    func fetchFeesEasypay(card: CardRepresentable) -> AnyPublisher<FeeDataRepresentable, Error> {
        return repository.loadFeesEasyPay(card: card)
            .eraseToAnyPublisher()
        }
}
