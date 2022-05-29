//
//  GetTransactionDetailEasyPayUseCase.swift
//  Cards
//
//  Created by Gloria Cano López on 6/4/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public typealias EasyPay = (easyPay: EasyPayRepresentable?, isFractioned: Bool)

public protocol GetTransactionDetailEasyPayUseCase {
    func fetchTransactionDetailEasyPay(card: CardRepresentable,
                                       transaction: CardTransactionRepresentable,
                                       cardDetail: CardDetailRepresentable?,
                                       easyPayContract: EasyPayContractTransactionRepresentable?) -> AnyPublisher<EasyPay, Error>
    
}

struct DefaultGetTransactionDetailEasyPayUseCase {
    private let repository: CardRepository
    
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        repository = dependencies.resolve()
    }
}

extension DefaultGetTransactionDetailEasyPayUseCase: GetTransactionDetailEasyPayUseCase {
    func fetchTransactionDetailEasyPay(card: CardRepresentable, transaction: CardTransactionRepresentable, cardDetail: CardDetailRepresentable?, easyPayContract: EasyPayContractTransactionRepresentable?) -> AnyPublisher<EasyPay, Error> {
        return repository.loadTransactionDetailEasyPay(card: card,
                                                       cardDetail: cardDetail,
                                                       transaction: transaction,
                                                       easyPayContract: easyPayContract)
            .map { easyPay in
                return EasyPay(easyPay, false) }
            .eraseToAnyPublisher()
    }
}
