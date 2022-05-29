//
//  SetupActivateCardUseCase.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 09/10/2020.
//

import Foundation
import SANLegacyLibrary
import CoreFoundationLib
import Operative
import UI

public protocol SetupActivateCardUseCaseProtocol: UseCase<SetupActivateCardUseCaseInput, SetupActivateCardUseCaseOkOutput, StringErrorOutput> { }
    
final class SetupActivateCardUseCase: UseCase<SetupActivateCardUseCaseInput, SetupActivateCardUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: SetupActivateCardUseCaseInput) throws -> UseCaseResponse<SetupActivateCardUseCaseOkOutput, StringErrorOutput> {
       
        let cardsManager = provider.getBsanCardsManager()
        let cardDto = requestValues.card.dto
        let cardDetailDto = try getCardDetailDTO(cardDto: cardDto)
        guard let expirationDate = cardDetailDto?.expirationDate else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let response = try cardsManager.activateCard(cardDTO: cardDto, expirationDate: expirationDate)
        if response.isSuccess(), let activateCardDto = try response.getResponseData(), let scaRepresentable = activateCardDto.scaRepresentable {
            let scaEntity = SCAEntity(scaRepresentable)
            return UseCaseResponse.ok(SetupActivateCardUseCaseOkOutput(scaEntity: scaEntity, expirationDate: expirationDate))
        }
        return UseCaseResponse.error(StringErrorOutput(try response.getErrorMessage() ?? ""))
    }

    private func getCardDetailDTO(cardDto: CardDTO) throws -> CardDetailDTO? {
        let cardsManager = provider.getBsanCardsManager()
        let response = try cardsManager.getCardDetail(cardDTO: cardDto)
        
        return try response.getResponseData()
    }
}

extension SetupActivateCardUseCase: SetupActivateCardUseCaseProtocol {}

public struct SetupActivateCardUseCaseInput {
    let card: CardEntity
    
    public init(card: CardEntity) {
        self.card = card
    }
}

public struct SetupActivateCardUseCaseOkOutput {
    let scaEntity: SCAEntity?
    let expirationDate: Date?
    
    public init(scaEntity: SCAEntity?, expirationDate: Date?) {
        self.scaEntity = scaEntity
        self.expirationDate = expirationDate
    }
}
