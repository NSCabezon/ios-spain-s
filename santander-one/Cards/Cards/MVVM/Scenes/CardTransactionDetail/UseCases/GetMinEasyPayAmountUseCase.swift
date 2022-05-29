//
//  GetMinEasyPayAmountUseCase.swift
//  Cards
//
//  Created by Hernán Villamil on 30/3/22.
//

import Foundation
import CoreDomain
import OpenCombine

public protocol GetMinEasyPayAmountUseCase {
    func fetchMinEasyPayAmountPublisher() -> AnyPublisher<Double, Never>
}

struct DefaultGetMinEasyPayAmountUseCase: GetMinEasyPayAmountUseCase {
    func fetchMinEasyPayAmountPublisher() -> AnyPublisher<Double, Never> {
        let defaultMinimimAmount = Double(60)
        return Just(defaultMinimimAmount)
            .eraseToAnyPublisher()
    }
}
