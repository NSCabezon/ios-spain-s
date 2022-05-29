//
//  CardTransactionDetailUseCase.swift
//  Cards
//
//  Created by Hernán Villamil on 30/3/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public protocol CardTransactionDetailUseCase {
    func fetchCardDetailDataUseCase(card: CardRepresentable,
                                    transaction: CardTransactionRepresentable,
                                    showAmountBackground: Bool) -> AnyPublisher<CardTransactionViewItemRepresentable, Error>
}

struct DefaultCardTransactionDetailUseCase {
    private let repository: CardRepository
    private let getCardDetailDataUseCase: GetCardDetailDataUseCase
    private let getCardTransactionConfigUseCase: GetCardTransactionConfigUseCase
    private let getContractMovementUseCase: GetContractMovementUseCase
    private let getCardTransactionDetailDataUseCase: GetCardTransactionDetailDataUseCase
    
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
        self.getCardDetailDataUseCase = DefaultGetCardDetailDataUseCase(dependencies: dependencies)
        self.getCardTransactionConfigUseCase = DefaultGetCardTransactionConfigUseCase(dependencies: dependencies)
        self.getContractMovementUseCase = DefaultGetContractMovementUseCase(dependencies: dependencies)
        self.getCardTransactionDetailDataUseCase = DefaultGetCardTransactionDetailDataUseCase(dependencies: dependencies)
    }
    
}

extension DefaultCardTransactionDetailUseCase: CardTransactionDetailUseCase {
    func fetchCardDetailDataUseCase(card: CardRepresentable, transaction: CardTransactionRepresentable, showAmountBackground: Bool) -> AnyPublisher<CardTransactionViewItemRepresentable, Error> {
        let detaiDataPublisher = getCardDetailDataUseCase.fetchCardDetailDataUseCase(card: card,
                                                                                     transaction: transaction)
        let transactionConfigPublisher = getCardTransactionConfigUseCase.fetchConfig(card: card,
                                                                                     transaction: transaction)
        let contractmovementPublisher = getContractMovementUseCase.fetchContractMovement(card: card,
                                                                                         transaction: transaction)
        let transactionDetailPublisher = getCardTransactionDetailDataUseCase.fetchCardDetailDataUseCase(card: card,
                                                                                                        transaction: transaction)
        return Publishers.Zip4(detaiDataPublisher,
                               transactionConfigPublisher,
                               contractmovementPublisher,
                               transactionDetailPublisher)
            .map({ detail, configuration, contract, transactionDetail in
                self.getTransactionDetailItem(card: card,
                                              transaction: transaction,
                                              detail: detail,
                                              configuration: configuration,
                                              contract: contract,
                                              transactionDetail: transactionDetail,
                                              showAmountBackground: showAmountBackground)
            })
            .eraseToAnyPublisher()
    }
    
}

private extension DefaultCardTransactionDetailUseCase {
    func getTransactionDetailItem(card: CardRepresentable,
                                  transaction: CardTransactionRepresentable,
                                  detail: CardDetailRepresentable,
                                  configuration: CardTransactionDetailConfigRepresentable,
                                  contract: EasyPayContractTransactionRepresentable?,
                                  transactionDetail: CardTransactionDetailRepresentable,
                                  showAmountBackground: Bool) -> CardTransactionViewItemRepresentable {
        let response = CardTransactionItem(card: card,
                                           transaction: transaction,
                                           showAmountBackground: showAmountBackground)
        response.cardDetail = detail
        response.configuration = configuration
        response.contract = contract
        response.transactionDetail = transactionDetail
        response.shouldPresentFractionatedButton = true
        return response
    }
}
