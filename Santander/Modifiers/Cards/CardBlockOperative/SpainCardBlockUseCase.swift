//
//  SpainCardBlockUseCase.swift
//  Santander
//
//  Created by Laura González on 08/06/2021.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import Cards

final class SpainCardBlockUseCase: UseCase<CardBlockUseCaseInput, CardBlockUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: CardBlockUseCaseInput) throws -> UseCaseResponse<CardBlockUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = provider.getBsanCardsManager()
        let cardDto = requestValues.card.dto
        let response = try cardsManager.blockCard(cardDTO: cardDto, blockText: requestValues.blockText, cardBlockType: requestValues.blockType)
        if response.isSuccess(), let cardBlock = try response.getResponseData(), let signature = cardBlock.signature {
            let scaEntity = SCAEntity(signature)
            let output = CardBlockUseCaseOkOutput(scaEntity: scaEntity, residentialAddress: nil)
            return .ok(output)
        }
        return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
    }
}

extension SpainCardBlockUseCase: CardBlockUseCaseProtocol {}
