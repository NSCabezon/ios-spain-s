//
//  FirstFeeInfoEasyPayReactiveUseCase.swift
//  Pods
//
//  Created by Hernán Villamil on 21/4/22.
//

import Foundation
import CoreDomain
import OpenCombine
import SANLegacyLibrary

public protocol FirstFeeInfoEasyPayReactiveUseCase {
    func fetchFirstFeeInfoEasyPay(numberOfFees: Int,
                                  card: CardRepresentable,
                                  transactionBalanceCode: String?,
                                  transactionDay: String?) -> AnyPublisher<FeesInfoRepresentable, Error>
}

public final class DefaultFirstFeeInfoEasyPayReactiveUseCase {
    let cardRepository: CardRepository
    
    public init(repository: CardRepository) {
        cardRepository = repository
    }
}

extension DefaultFirstFeeInfoEasyPayReactiveUseCase: FirstFeeInfoEasyPayReactiveUseCase {
    public func fetchFirstFeeInfoEasyPay(numberOfFees: Int, card: CardRepresentable, transactionBalanceCode: String?, transactionDay: String?) -> AnyPublisher<FeesInfoRepresentable, Error> {
        return cardRepository
            .loadEasyPayFees(card: card,
                             numFees: numberOfFees,
                             balanceCode: transactionBalanceCode,
                             transactionDay: transactionDay)
            .flatMap { (fees: FeesInfoRepresentable) -> AnyPublisher<FeesInfoRepresentable, Error> in
                return self.getoutput(fees,
                                      numberOfFees: numberOfFees)
            }
            .eraseToAnyPublisher()
    }
}

private extension DefaultFirstFeeInfoEasyPayReactiveUseCase {
    func getoutput(_ fees: FeesInfoRepresentable,
                   numberOfFees: Int) -> AnyPublisher<FeesInfoRepresentable, Error> {
        var output = FeesInfoDTO(representable: fees)
        output.totalMonths = numberOfFees
        return Just(output)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
