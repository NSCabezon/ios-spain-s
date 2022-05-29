//
//  GetCardPaymentMethodUseCase.swift
//  Account
//
//  Created by Laura González on 23/04/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetCardPaymentMethodUseCase: UseCase<GetCardPaymentMethodUseCaseInput, GetCardPaymentMethodUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private var provider: BSANManagersProvider {
        return dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetCardPaymentMethodUseCaseInput) throws -> UseCaseResponse<GetCardPaymentMethodUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
        let cardDTO = requestValues.card.dto
        let response = try cardsManager.getPaymentChange(cardDTO: cardDTO)
        guard response.isSuccess(), let changePaymentDTO = try response.getResponseData(),
            let paymentMethod =  CardPaymentMethodTypeEntity(changePaymentDTO.currentPaymentMethod) else {
            return .error(GetCardPaymentMethodUseCaseErrorOutput(try response.getErrorMessage()))
        }
        return .ok(GetCardPaymentMethodUseCaseOkOutput(currentPaymentMethod: paymentMethod, currentPaymentMethodMode: changePaymentDTO.currentPaymentMethodDescription))
    }
}

struct GetCardPaymentMethodUseCaseInput {
    let card: CardEntity
}

struct GetCardPaymentMethodUseCaseOkOutput {
    public var currentPaymentMethod: CardPaymentMethodTypeEntity
    public var currentPaymentMethodMode: String?
}

class GetCardPaymentMethodUseCaseErrorOutput: StringErrorOutput {}
