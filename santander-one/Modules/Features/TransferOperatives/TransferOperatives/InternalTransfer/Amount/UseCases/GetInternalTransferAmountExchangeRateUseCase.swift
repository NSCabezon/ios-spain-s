//
//  GetInternalTransferAmountExchangeRateUseCase.swift
//  TransferOperatives
//
//  Created by Mario Rosales Maillo on 2/3/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol GetInternalTransferAmountExchangeRateUseCase {
    func fetchExchangeRate(input: GetInternalTransferAmountExchangeRateUseCaseInput) -> AnyPublisher<GetInternalTransferAmountExchangeRateUseCaseOutput, Error>
}

public struct GetInternalTransferAmountExchangeRateUseCaseInput {
    public let localCurrency: CurrencyType
    public let initialCurrency: CurrencyType
    public let targetCurrency: CurrencyType
    
    public init(localCurrency: CurrencyType, initialCurrency: CurrencyType, targetCurrency: CurrencyType) {
        self.initialCurrency = initialCurrency
        self.localCurrency = localCurrency
        self.targetCurrency = targetCurrency
    }
}

public enum GetInternalTransferAmountExchangeRateUseCaseOutput {
    case success(result: GetInternalTransferAmountExchangeRateUseCaseSuccessOutput)
    case failure
}

public struct GetInternalTransferAmountExchangeRateUseCaseSuccessOutput {
    public let initialCurrency: CurrencyType
    public let targetCurrency: CurrencyType
    public let sellRate: Decimal
    public let buyRate: Decimal?
    
    public init(initialCurrency: CurrencyType, targetCurrency: CurrencyType, sellRate: Decimal, buyRate: Decimal?) {
        self.initialCurrency = initialCurrency
        self.targetCurrency = targetCurrency
        self.sellRate = sellRate
        self.buyRate = buyRate
    }
}

struct DefaultGetInternalTransferAmountExchangeRateUseCase {}

extension DefaultGetInternalTransferAmountExchangeRateUseCase: GetInternalTransferAmountExchangeRateUseCase {
    func fetchExchangeRate(input: GetInternalTransferAmountExchangeRateUseCaseInput) -> AnyPublisher<GetInternalTransferAmountExchangeRateUseCaseOutput, Error> {
        return Just(
            .success(result:GetInternalTransferAmountExchangeRateUseCaseSuccessOutput(initialCurrency: input.initialCurrency,
                                                                                      targetCurrency: input.targetCurrency,
                                                                                      sellRate: 1,
                                                                                      buyRate: 1))
        ).tryMap({ output in
            return output
        })
        .eraseToAnyPublisher()
    }
}
